---
tags: [google-flow, image-upload, file-dialog, cdp, automation]
created: 2026-09-21
updated: 2026-09-21
---

# 🖼️ Image Upload & OS File Dialog Automation for Google Flow

> [!SUCCESS] Autonomous Image & Media Uploading
> When adding reference images, avatar portraits, or style assets into Google Flow (or YouTube Studio), clicking "Upload" or "Add media" triggers a native Windows OS file picker. Yorky uses `scripts/handle_file_dialog.py` to bypass or auto-fill this dialog in seconds.

---

## ⚡ How It Works (Dual-Engine Architecture)

`scripts/handle_file_dialog.py` runs with a dual-engine watcher for `--timeout` seconds (default 25s):

1. **Primary: Chrome CDP File Chooser Interceptor**
   * Connects to Chrome port `9222` on the active Google Flow tab.
   * Enables `Page.setInterceptFileChooserDialog`.
   * When Google Flow triggers a file upload, Chrome intercepts the event (`Page.fileChooserOpened`) and injects the file directly via `DOM.setFileInputFiles`.
   * **Result: The native Windows OS dialog never even opens on screen.**

2. **Fallback: Native Windows OS Dialog Auto-Filler**
   * If an OS dialog does appear (e.g. titled "Open" or "Select a file to upload"), the script activates the window, focuses the file input with `Alt + N`, pastes the absolute path, and presses `{ENTER}`.

---

### Option A: Complete One-Command Auto-Upload (Recommended for Google Flow)
Yorky can upload any image directly to Google Flow with zero manual clicks or coordinates needed:

```bash
python scripts/handle_file_dialog.py --file "C:\path\to\image.png" --flow
```
*What happens:*
1. Arms the file chooser interceptor on the active Google Flow tab.
2. Automatically triggers the "Add media menu" -> "Upload" flow via CDP.
3. Automatically injects the file and attaches it to the media gallery in <4 seconds.

---

### Option B: If the OS Dialog is Already Open On-Screen
If the dialog is already open and waiting for input:
```bash
python scripts/handle_file_dialog.py --file "C:\path\to\image.png"
```
*What happens:*
1. Switches to `WinSta0\default` interactive desktop.
2. Uses Win32 `AttachThreadInput` to join input queues with the dialog.
3. Injects the absolute path into the `Edit` control via `SetWindowTextW`.
4. Clicks the `&Open` button (`BM_CLICK` / Enter) and dismisses the window cleanly.

---

### Option C: Arming in Background Before Custom Actions
```powershell
Start-Process python -ArgumentList 'scripts/handle_file_dialog.py', '--file', '\"C:\path\to\image.png\"', '--timeout', '25'
```
*Then click any upload button in YouTube Studio or Google Flow.*

---

### Option D: In Python Production Scripts
```python
from scripts.handle_file_dialog import arm_file_dialog_handler

handler = arm_file_dialog_handler(r"C:\path\to\avatar_reference.png", timeout=25)
# ... perform upload action ...
success = handler.wait(timeout=10)
if success:
    print("Image attached successfully!")
```

---

See also: [[⚡ Google Flow Master Guide]] • [[👤 Master Avatar & Studio Anchor]] • [[⚙️ Active Skills Architecture]]
