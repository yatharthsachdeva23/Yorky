"""
Robust Dual-Engine File Dialog Handler & Auto-Uploader for Google Flow & YouTube Studio.
Solves the native OS file picker blocking issue by:
1. Win32 Desktop Switching to WinSta0\\default so background processes can see user dialogs.
2. Win32 AttachThreadInput + SetWindowTextW + BM_CLICK to reliably inject path and submit native dialogs.
3. Chrome CDP File Chooser Interception to bypass the OS dialog altogether at the browser level.
4. Optional --flow flag to trigger the entire Google Flow upload sequence end-to-end autonomously.
"""

import sys
import os
import time
import json
import argparse
import threading
import urllib.request
import ctypes
from ctypes import wintypes
import websocket

# Force UTF-8 terminal encoding
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

CDP_DEFAULT_PORT = 9222
user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

WM_SETTEXT = 0x000C
WM_COMMAND = 0x0111
BM_CLICK = 0x00F5
IDOK = 1
SW_RESTORE = 9
WM_KEYDOWN = 0x0100
WM_KEYUP = 0x0101
VK_RETURN = 0x0D
WM_CHAR = 0x0102


def switch_to_interactive_desktop():
    """Switches the current thread desktop to WinSta0\\default to access user GUI windows."""
    try:
        hdesk = user32.OpenDesktopW("default", 0, False, 0x01FF)
        if hdesk:
            res = user32.SetThreadDesktop(hdesk)
            return bool(res)
    except Exception as e:
        print(f"[!] Warning switching desktop: {e}")
    return False


def find_file_dialogs():
    """Finds all visible file picker dialogs (#32770) on the default desktop."""
    dialogs = []
    
    def enum_proc(hwnd, lParam):
        if user32.IsWindowVisible(hwnd):
            cls_buff = ctypes.create_unicode_buffer(256)
            user32.GetClassNameW(hwnd, cls_buff, 256)
            cls_name = cls_buff.value
            
            length = user32.GetWindowTextLengthW(hwnd)
            txt_buff = ctypes.create_unicode_buffer(length + 1)
            user32.GetWindowTextW(hwnd, txt_buff, length + 1)
            title = txt_buff.value
            
            # Common file dialog criteria
            is_dialog_class = (cls_name == "#32770")
            has_dialog_title = any(k in title.lower() for k in ["open", "select a file", "choose file", "upload", "select media"])
            
            if is_dialog_class or has_dialog_title:
                dialogs.append((hwnd, cls_name, title))
        return True

    WNDENUMPROC = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    user32.EnumWindows(WNDENUMPROC(enum_proc), 0)
    return dialogs


def get_dialog_controls(dialog_hwnd):
    """Enumerate all child controls inside a dialog."""
    controls = []
    
    def enum_child(hwnd, lParam):
        cls_b = ctypes.create_unicode_buffer(256)
        user32.GetClassNameW(hwnd, cls_b, 256)
        
        length = user32.GetWindowTextLengthW(hwnd)
        txt_b = ctypes.create_unicode_buffer(length + 1)
        user32.GetWindowTextW(hwnd, txt_b, length + 1)
        
        ctrl_id = user32.GetDlgCtrlID(hwnd)
        visible = user32.IsWindowVisible(hwnd)
        enabled = user32.IsWindowEnabled(hwnd)
        
        controls.append({
            "hwnd": hwnd,
            "id": ctrl_id,
            "class": cls_b.value,
            "text": txt_b.value,
            "visible": bool(visible),
            "enabled": bool(enabled)
        })
        return True

    WNDENUMPROC = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    user32.EnumChildWindows(dialog_hwnd, WNDENUMPROC(enum_child), 0)
    return controls


def fill_and_submit_dialog(dialog_hwnd, abs_file_path):
    """Fills the file path into the dialog using AttachThreadInput + Win32 Control Injection."""
    print(f"[*] [OS Engine] Processing dialog hwnd={dialog_hwnd}...")
    
    target_tid = user32.GetWindowThreadProcessId(dialog_hwnd, None)
    cur_tid = kernel32.GetCurrentThreadId()
    attached = bool(user32.AttachThreadInput(cur_tid, target_tid, True))
    
    try:
        # 1. Bring dialog to front and activate
        user32.ShowWindow(dialog_hwnd, SW_RESTORE)
        user32.SetForegroundWindow(dialog_hwnd)
        time.sleep(0.2)

        controls = get_dialog_controls(dialog_hwnd)
        edit_ctrl = None
        open_btn = None
        
        # Look for Edit control and Open button
        for c in controls:
            if c["class"] == "Edit" and c["visible"]:
                if c["id"] in [1148, 1001]:
                    edit_ctrl = c
                    break
                elif edit_ctrl is None:
                    edit_ctrl = c
                    
        for c in controls:
            if c["class"] == "Button":
                if c["id"] == IDOK or any(w in c["text"].lower() for w in ["open", "&open", "select"]):
                    open_btn = c
                    break

        path_set = False

        # Method 1: SetWindowTextW & WM_SETTEXT via AttachThreadInput
        if edit_ctrl:
            print(f"[*] [OS Engine] Found Edit control (hwnd={edit_ctrl['hwnd']}). Setting text...")
            user32.SetFocus(edit_ctrl["hwnd"])
            time.sleep(0.1)
            
            # Set text using SetWindowTextW
            user32.SetWindowTextW(edit_ctrl["hwnd"], abs_file_path)
            # Also notify parent combo/dialog
            user32.SendMessageW(edit_ctrl["hwnd"], WM_SETTEXT, 0, abs_file_path)
            time.sleep(0.2)
            
            # Verify text was received
            length = user32.GetWindowTextLengthW(edit_ctrl["hwnd"])
            txt_b = ctypes.create_unicode_buffer(length + 1)
            user32.GetWindowTextW(edit_ctrl["hwnd"], txt_b, length + 1)
            
            if abs_file_path.lower() in txt_b.value.lower():
                print(f"[+] [OS Engine] Text successfully verified in Edit box: '{txt_b.value}'")
                path_set = True
            else:
                # Method 2: WM_CHAR typing fallback
                print("[*] [OS Engine] Fallback: typing characters via WM_CHAR...")
                user32.SetFocus(edit_ctrl["hwnd"])
                for ch in abs_file_path:
                    user32.SendMessageW(edit_ctrl["hwnd"], WM_CHAR, ord(ch), 0)
                time.sleep(0.2)
                path_set = True

        # Method 3: Clipboard / PyAutoGUI fallback if needed
        if not path_set:
            try:
                import pyperclip
                import pyautogui
                pyautogui.FAILSAFE = False
                pyperclip.copy(abs_file_path)
                pyautogui.hotkey('alt', 'n')
                time.sleep(0.15)
                pyautogui.hotkey('ctrl', 'a')
                time.sleep(0.1)
                pyautogui.hotkey('ctrl', 'v')
                time.sleep(0.2)
                path_set = True
            except Exception as e:
                print(f"[!] PyAutoGUI note: {e}")

        # Submit dialog
        if open_btn:
            print(f"[*] [OS Engine] Clicking Open button (hwnd={open_btn['hwnd']})...")
            user32.SendMessageW(open_btn["hwnd"], BM_CLICK, 0, 0)
        else:
            user32.SendMessageW(dialog_hwnd, WM_COMMAND, IDOK, 0)

        time.sleep(0.4)
        
        # If dialog is still visible, send Return / Enter
        if user32.IsWindowVisible(dialog_hwnd):
            if edit_ctrl:
                user32.SendMessageW(edit_ctrl["hwnd"], WM_KEYDOWN, VK_RETURN, 0)
                user32.SendMessageW(edit_ctrl["hwnd"], WM_KEYUP, VK_RETURN, 0)
            time.sleep(0.4)

        if user32.IsWindowVisible(dialog_hwnd):
            user32.SendMessageW(dialog_hwnd, WM_COMMAND, IDOK, 0)
            time.sleep(0.4)

        # Final verification
        if not user32.IsWindowVisible(dialog_hwnd):
            print("[+] [OS Engine] Dialog successfully closed!")
            return True
        else:
            print("[*] [OS Engine] Dialog handled, check application for file receipt.")
            return path_set

    finally:
        if attached:
            user32.AttachThreadInput(cur_tid, target_tid, False)


def os_dialog_watcher_worker(abs_file_path: str, timeout: float, stop_event: threading.Event, success_event: threading.Event):
    """Watches the interactive desktop for the appearance of a file dialog and submits the file."""
    switch_to_interactive_desktop()
    
    start_t = time.time()
    while not stop_event.is_set() and (time.time() - start_t < timeout):
        dialogs = find_file_dialogs()
        if dialogs:
            for dhwnd, dcls, dtitle in dialogs:
                print(f"[+] [OS Engine] Detected active file dialog: '{dtitle}' ({dcls}, hwnd={dhwnd})")
                if fill_and_submit_dialog(dhwnd, abs_file_path):
                    success_event.set()
                    stop_event.set()
                    return
        time.sleep(0.25)


def cdp_interceptor_worker(abs_file_path: str, timeout: float, stop_event: threading.Event, success_event: threading.Event, port: int):
    """Arms Chrome CDP Page.setInterceptFileChooserDialog on active tab."""
    try:
        req = urllib.request.Request(f"http://127.0.0.1:{port}/json/list")
        with urllib.request.urlopen(req, timeout=3) as resp:
            tabs = json.loads(resp.read().decode('utf-8'))
        
        target_tab = next((t for t in tabs if 'flow.google.com' in t.get('url', '') and t.get('type') == 'page'), None)
        if not target_tab:
            target_tab = next((t for t in tabs if 'studio.youtube.com' in t.get('url', '') and t.get('type') == 'page'), None)
        if not target_tab:
            target_tab = next((t for t in tabs if t.get('type') == 'page' and not t.get('url', '').startswith('chrome://')), None)

        if not target_tab:
            return

        ws_url = target_tab.get('webSocketDebuggerUrl')
        if not ws_url:
            return

        ws = websocket.create_connection(ws_url, suppress_origin=True, timeout=5)
        ws.send(json.dumps({"id": 1, "method": "Page.enable"}))
        ws.recv()
        ws.send(json.dumps({"id": 2, "method": "DOM.enable"}))
        ws.recv()
        ws.send(json.dumps({"id": 3, "method": "Page.setInterceptFileChooserDialog", "params": {"enabled": True}}))
        ws.recv()
        print(f"[*] [CDP Engine] File chooser interceptor ARMED on tab: '{target_tab.get('title', '')[:30]}'")

        start_time = time.time()
        while not stop_event.is_set() and (time.time() - start_time < timeout):
            ws.settimeout(0.5)
            try:
                msg = ws.recv()
                data = json.loads(msg)
                if data.get("method") == "Page.fileChooserOpened":
                    backend_node_id = data.get("params", {}).get("backendNodeId")
                    if backend_node_id:
                        ws.send(json.dumps({
                            "id": 10,
                            "method": "DOM.setFileInputFiles",
                            "params": {"files": [abs_file_path], "backendNodeId": backend_node_id}
                        }))
                        ws.recv()
                        print(f"[+] [CDP Engine] Successfully injected file via CDP DOM.setFileInputFiles!")
                        success_event.set()
                        stop_event.set()
                        break
            except websocket.WebSocketTimeoutException:
                continue
            except Exception:
                break

        try:
            ws.send(json.dumps({"id": 99, "method": "Page.setInterceptFileChooserDialog", "params": {"enabled": False}}))
            ws.close()
        except Exception:
            pass
    except Exception:
        pass


class FileDialogHandler:
    def __init__(self, file_path: str, timeout: float = 30.0, port: int = CDP_DEFAULT_PORT):
        self.file_path = os.path.abspath(file_path)
        self.timeout = timeout
        self.port = port
        self.stop_event = threading.Event()
        self.success_event = threading.Event()
        self.threads = []

    def start(self):
        if not os.path.exists(self.file_path):
            raise FileNotFoundError(f"File not found: {self.file_path}")

        t_os = threading.Thread(
            target=os_dialog_watcher_worker,
            args=(self.file_path, self.timeout, self.stop_event, self.success_event),
            daemon=True
        )
        t_cdp = threading.Thread(
            target=cdp_interceptor_worker,
            args=(self.file_path, self.timeout, self.stop_event, self.success_event, self.port),
            daemon=True
        )

        self.threads = [t_os, t_cdp]
        t_os.start()
        t_cdp.start()
        print(f"[*] File dialog handler ARMED for {self.timeout}s.")
        print(f"[*] Target file: {self.file_path}")

    def wait(self, timeout: float = None) -> bool:
        wait_t = timeout or self.timeout
        start_t = time.time()
        while time.time() - start_t < wait_t:
            if self.success_event.is_set():
                return True
            time.sleep(0.1)
        self.stop_event.set()
        return self.success_event.is_set()

    def stop(self):
        self.stop_event.set()


def arm_file_dialog_handler(file_path: str, timeout: float = 30.0, port: int = CDP_DEFAULT_PORT) -> FileDialogHandler:
    handler = FileDialogHandler(file_path, timeout=timeout, port=port)
    handler.start()
    return handler


def trigger_flow_upload_click(port: int = CDP_DEFAULT_PORT):
    """Triggers the 'Add media menu' and 'Upload' button in Google Flow via CDP mouse events."""
    try:
        req = urllib.request.Request(f"http://127.0.0.1:{port}/json/list")
        with urllib.request.urlopen(req, timeout=3) as resp:
            tabs = json.loads(resp.read().decode('utf-8'))
        
        target_tab = next((t for t in tabs if 'flow.google.com' in t.get('url', '') and t.get('type') == 'page'), None)
        if not target_tab:
            print("[!] Google Flow tab not found in Chrome.")
            return False

        ws_url = target_tab.get('webSocketDebuggerUrl')
        ws = websocket.create_connection(ws_url, suppress_origin=True, timeout=5)
        
        mid = 0
        def cdp_send(method, params):
            nonlocal mid
            mid += 1
            ws.send(json.dumps({"id": mid, "method": method, "params": params}))
            return json.loads(ws.recv())

        def cdp_click(x, y):
            for t in ['mouseMoved', 'mousePressed', 'mouseReleased']:
                p = {'type': t, 'x': x, 'y': y}
                if t != 'mouseMoved':
                    p['button'] = 'left'
                    p['clickCount'] = 1
                cdp_send('Input.dispatchMouseEvent', p)

        # 1. Click "Add media menu" button at (1270, 38)
        print("[*] [Auto-Flow] Clicking 'Add media menu' button...")
        cdp_click(1270, 38)
        time.sleep(0.6)

        # 2. Click "Upload" menu item at (1343.8, 86)
        print("[*] [Auto-Flow] Clicking 'Upload' menu item...")
        cdp_click(1343.8, 86)
        time.sleep(0.5)

        ws.close()
        return True
    except Exception as e:
        print(f"[!] Error in trigger_flow_upload_click: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Auto-handle Google Flow / Windows file picker dialogs.")
    parser.add_argument("--file", "-f", required=True, help="Absolute path to the image/media file.")
    parser.add_argument("--timeout", "-t", type=float, default=30.0, help="Seconds to watch (default: 30s).")
    parser.add_argument("--port", "-p", type=int, default=CDP_DEFAULT_PORT, help="Chrome CDP port (default: 9222).")
    parser.add_argument("--flow", action="store_true", help="Automatically click Add Media -> Upload in Google Flow.")
    args = parser.parse_args()

    file_path = os.path.abspath(args.file)
    if not os.path.exists(file_path):
        print(f"[ERROR] Target file does not exist: {file_path}")
        sys.exit(1)

    print("=======================================================")
    print("  Google Flow & Web OS File Dialog Auto-Handler")
    print("=======================================================")

    handler = FileDialogHandler(file_path, timeout=args.timeout, port=args.port)
    handler.start()

    if args.flow:
        time.sleep(0.5)
        print("[*] Automatically triggering Google Flow UI upload button...")
        trigger_flow_upload_click(port=args.port)

    print(f"[*] Handler is ACTIVE for {args.timeout}s.")
    print("[*] If dialog is already open, it will be handled immediately.")
    print("[*] If not open yet, click 'Add media' or 'Upload' now.")

    success = handler.wait()
    if success:
        print(f"[SUCCESS] Image file '{os.path.basename(file_path)}' uploaded/selected successfully!")
        sys.exit(0)
    else:
        print("[TIMEOUT] No file dialog was detected or handled within timeout.")
        sys.exit(1)


if __name__ == "__main__":
    main()
