"""
Standalone File Dialog Handler & Chrome CDP File Chooser Interceptor.
Enables Yorky (and autonomous subagents) to upload local images/files into Google Flow
and other web apps without getting blocked by native Windows OS file dialogs.

Dual-Engine Architecture:
1. Primary: Chrome CDP `Page.setInterceptFileChooserDialog` -> catches file chooser events
   at the browser engine level and injects files via `DOM.setFileInputFiles` without opening an OS window.
2. Fallback: Native Windows OS Dialog Watcher -> if an OS dialog opens on screen, brings it
   to foreground, pastes the target file path, and hits Enter.
"""

import sys
import os
import time
import json
import argparse
import threading
import urllib.request
import websocket

# Set UTF-8 encoding for terminal output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

CDP_DEFAULT_PORT = 9222


def cdp_interceptor_worker(abs_file_path: str, timeout: float, stop_event: threading.Event, success_event: threading.Event, port: int):
    """Watches Chrome CDP for Page.fileChooserOpened and injects files directly."""
    try:
        req = urllib.request.Request(f"http://127.0.0.1:{port}/json/list")
        with urllib.request.urlopen(req, timeout=3) as resp:
            tabs = json.loads(resp.read().decode('utf-8'))
        
        # Priority: flow.google.com, then studio.youtube.com, then any active page
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
        
        # Enable domains
        ws.send(json.dumps({"id": 1, "method": "Page.enable"}))
        ws.recv()
        ws.send(json.dumps({"id": 2, "method": "DOM.enable"}))
        ws.recv()

        # Arm file chooser interception
        ws.send(json.dumps({
            "id": 3,
            "method": "Page.setInterceptFileChooserDialog",
            "params": {"enabled": True}
        }))
        ws.recv()
        print(f"[*] [CDP Engine] File chooser interceptor ARMED on tab: '{target_tab.get('title', '')[:30]}'")

        start_time = time.time()
        while not stop_event.is_set() and (time.time() - start_time < timeout):
            ws.settimeout(0.5)
            try:
                msg = ws.recv()
                data = json.loads(msg)
                method = data.get("method")
                
                if method == "Page.fileChooserOpened":
                    backend_node_id = data.get("params", {}).get("backendNodeId")
                    print(f"[+] [CDP Engine] Detected Page.fileChooserOpened (backendNodeId={backend_node_id})")
                    
                    if backend_node_id:
                        ws.send(json.dumps({
                            "id": 10,
                            "method": "DOM.setFileInputFiles",
                            "params": {
                                "files": [abs_file_path],
                                "backendNodeId": backend_node_id
                            }
                        }))
                        inject_res = json.loads(ws.recv())
                        print(f"[+] [CDP Engine] Successfully injected file: {inject_res}")
                        success_event.set()
                        stop_event.set()
                        break
            except websocket.WebSocketTimeoutException:
                continue
            except Exception:
                break

        # Cleanup interception
        try:
            ws.send(json.dumps({
                "id": 99,
                "method": "Page.setInterceptFileChooserDialog",
                "params": {"enabled": False}
            }))
            ws.close()
        except Exception:
            pass

    except Exception as e:
        # Fallback to OS watcher silently
        pass


def os_dialog_watcher_worker(abs_file_path: str, timeout: float, stop_event: threading.Event, success_event: threading.Event):
    """Watches Windows for native 'Open' or 'Select File' file picker dialogs and submits the path."""
    try:
        import win32com.client
        import pyperclip
        import pyautogui
        pyautogui.FAILSAFE = False
    except ImportError:
        return

    # Titles typically used by Windows file dialogs
    target_titles = ["Open", "Select a file to upload", "Choose File to Upload", "Upload Image", "Select media to upload"]
    
    start_time = time.time()
    wscript = None
    try:
        wscript = win32com.client.Dispatch("Wscript.Shell")
    except Exception:
        pass

    while not stop_event.is_set() and (time.time() - start_time < timeout):
        if not wscript:
            time.sleep(0.5)
            continue

        dialog_found = False
        for title in target_titles:
            try:
                # AppActivate returns True if the window exists and was activated
                if wscript.AppActivate(title):
                    dialog_found = True
                    print(f"[+] [OS Engine] Activated native file dialog: '{title}'")
                    time.sleep(0.3)
                    
                    # Focus file name input box and paste path
                    pyautogui.hotkey('alt', 'n')
                    time.sleep(0.15)
                    pyperclip.copy(abs_file_path)
                    pyautogui.hotkey('ctrl', 'v')
                    time.sleep(0.2)
                    pyautogui.press('enter')
                    time.sleep(0.5)
                    
                    print(f"[+] [OS Engine] Successfully pasted file path and pressed Enter!")
                    success_event.set()
                    stop_event.set()
                    break
            except Exception:
                pass
        
        if dialog_found:
            break

        time.sleep(0.3)


class FileDialogHandler:
    def __init__(self, file_path: str, timeout: float = 25.0, port: int = CDP_DEFAULT_PORT):
        self.file_path = os.path.abspath(file_path)
        self.timeout = timeout
        self.port = port
        self.stop_event = threading.Event()
        self.success_event = threading.Event()
        self.threads = []

    def start(self):
        """Starts both CDP and OS watchers in background threads."""
        if not os.path.exists(self.file_path):
            raise FileNotFoundError(f"Target file does not exist: {self.file_path}")

        t_cdp = threading.Thread(
            target=cdp_interceptor_worker,
            args=(self.file_path, self.timeout, self.stop_event, self.success_event, self.port),
            daemon=True
        )
        t_os = threading.Thread(
            target=os_dialog_watcher_worker,
            args=(self.file_path, self.timeout, self.stop_event, self.success_event),
            daemon=True
        )

        self.threads = [t_cdp, t_os]
        t_cdp.start()
        t_os.start()
        print(f"[*] File dialog auto-handler started for {self.timeout}s.")
        print(f"[*] Target file: {self.file_path}")

    def wait(self, timeout: float = None) -> bool:
        """Waits for either engine to succeed or timeout."""
        wait_time = timeout or self.timeout
        start_t = time.time()
        while time.time() - start_t < wait_time:
            if self.success_event.is_set():
                return True
            time.sleep(0.1)
        self.stop_event.set()
        return self.success_event.is_set()

    def stop(self):
        self.stop_event.set()


def arm_file_dialog_handler(file_path: str, timeout: float = 25.0, port: int = CDP_DEFAULT_PORT) -> FileDialogHandler:
    """Convenience factory function to start and return the handler immediately."""
    handler = FileDialogHandler(file_path, timeout=timeout, port=port)
    handler.start()
    return handler


def main():
    parser = argparse.ArgumentParser(description="Auto-handle Google Flow / Windows file picker dialogs.")
    parser.add_argument("--file", "-f", required=True, help="Absolute path to the image or media file to upload.")
    parser.add_argument("--timeout", "-t", type=float, default=25.0, help="Seconds to keep handler armed (default: 25s).")
    parser.add_argument("--port", "-p", type=int, default=CDP_DEFAULT_PORT, help="Chrome CDP port (default: 9222).")
    args = parser.parse_args()

    file_path = os.path.abspath(args.file)
    if not os.path.exists(file_path):
        print(f"[ERROR] File not found: {file_path}")
        sys.exit(1)

    print("=======================================================")
    print("  Google Flow & Web OS File Dialog Auto-Handler")
    print("=======================================================")
    
    handler = FileDialogHandler(file_path, timeout=args.timeout, port=args.port)
    handler.start()

    print(f"[*] Handler is ACTIVE for {args.timeout} seconds.")
    print("[*] Yorky / Chrome can now click 'Add image' or 'Upload' in the browser.")
    print("[*] Waiting for file selection event...")

    success = handler.wait()
    if success:
        print("[SUCCESS] File was automatically attached and selected!")
        sys.exit(0)
    else:
        print("[TIMEOUT] No file chooser or dialog was detected within the timeout period.")
        sys.exit(1)


if __name__ == "__main__":
    main()
