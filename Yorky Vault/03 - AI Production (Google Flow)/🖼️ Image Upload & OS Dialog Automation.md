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

## 🚀 How Yorky Executes It

### Option A: In the Terminal (Run in Background Before Clicking)
Before clicking "Add media" / "Upload image" in Google Flow, Yorky launches the handler:

```powershell
# Arms the handler for 25 seconds in the background
Start-Process python -ArgumentList 'scripts/handle_file_dialog.py', '--file', '\"C:\path\to\image.png\"', '--timeout', '25'
```
*Then Yorky clicks the upload button in Google Flow via CDP.*  
The handler intercepts it immediately, selects the image, and exits.

---

### Option B: In Python Automation Scripts
```python
from scripts.handle_file_dialog import arm_file_dialog_handler

# 1. Arm handler for 25 seconds
handler = arm_file_dialog_handler(r"C:\path\to\avatar_reference.png", timeout=25)

# 2. Click the upload button in Google Flow via CDP
# ... click element ...

# 3. Wait for file to attach (returns True on success)
success = handler.wait(timeout=10)
if success:
    print("Image attached successfully!")
```

---

### Option C: If the OS Dialog is Already Open On-Screen
If the dialog is already open and blocking Chrome:
```bash
python scripts/handle_file_dialog.py --file "C:\path\to\image.png"
```
It immediately detects the open dialog, inputs the path, presses Enter, and dismisses the window in <1 second.

---

See also: [[⚡ Google Flow Master Guide]] • [[👤 Master Avatar & Studio Anchor]] • [[⚙️ Active Skills Architecture]]
