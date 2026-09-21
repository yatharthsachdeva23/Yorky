---
tags: [google-flow, image-upload, file-dialog, cdp, automation]
created: 2026-09-21
updated: 2026-09-21
---

# 🖼️ Image Upload & OS File Dialog Protocol

> [!SUCCESS] In-Platform Asset Ingestion Architecture
> Google Flow image and photo asset ingestion is driven directly in the browser via CDP. Native Windows file chooser dialogs (`#32770`) are handled concurrently via the `scripts/handle_file_dialog.py` OS bridge.

---

## 🧭 Architecture & Layer Division

```text
[Chrome Browser (Profile 8)]                    [Windows OS Layer]
  │                                                    │
  ├─ 1. Arm OS Handler in background ──────────────────┼──> python scripts/handle_file_dialog.py
  │                                                    │      (Watches WinSta0\default & CDP)
  ├─ 2. Click button[aria-label="Add media menu"]       │
  ├─ 3. Click menuitem "Upload"                        │
  │     │                                              │
  │     └── Triggers File Chooser ─────────────────────┼──> [CDP DOM.setFileInputFiles OR
  │                                                    │     Win32 AttachThreadInput + SetWindowTextW]
  ├─ 4. Asset uploads to Flow CDN                      │
  └─ 5. Verify image in Media Gallery ─────────────────┘
```

### 1. Browser Execution Layer (Google Flow DOM)
All platform interaction executes directly on the active Flow tab:
* **Header Trigger**: `<button aria-label="Add media menu">` at coordinates `(1270, 38)`
* **Menu Selection**: `<button role="menuitem">` with text `"Upload"` at coordinates `(1343.8, 86)`
* **Asset Confirmation**: `<flow-grid-tile-container>` in "All media" or "Uploads"

### 2. Native OS Bridge Layer (`handle_file_dialog.py`)
Browser automation tools cannot cross the desktop boundary to interact with Windows `#32770` modal windows. The script bridges this gap:
* **Desktop Isolation**: Switches worker thread to `WinSta0\default` (`OpenDesktopW` + `SetThreadDesktop`).
* **UIPI & Message Queues**: Connects to the dialog thread via `AttachThreadInput(cur_tid, target_tid, True)`.
* **Control Injection**: Injects absolute file path into `Edit` (`id=1148` / `1001`) via `SetWindowTextW`, then fires `BM_CLICK` on `&Open` (`id=1`).
* **CDP Fast-Path**: Arms `Page.setInterceptFileChooserDialog` to catch `Page.fileChooserOpened` and feed `DOM.setFileInputFiles` before the OS window renders.

---

## 📋 Operational Step-by-Step Sequence

### Step 1: Arm the OS Bridge in Background
Before triggering the upload in Flow:
```powershell
Start-Process python -ArgumentList 'scripts/handle_file_dialog.py', '--file', '\"C:\path\to\image.png\"', '--timeout', '30'
```

### Step 2: Trigger Upload in Google Flow
Execute via CDP / browser tool:
```javascript
// 1. Expand media menu
document.querySelector('button[aria-label="Add media menu"]').click();

// 2. Click Upload menuitem
setTimeout(() => {
  const items = Array.from(document.querySelectorAll('[role="menuitem"], button'));
  const uploadBtn = items.find(el => el.textContent.trim().includes('Upload'));
  if (uploadBtn) uploadBtn.click();
}, 400);
```

### Step 3: Confirm Asset Ingestion
Inspect the gallery:
```javascript
const uploaded = Array.from(document.querySelectorAll('flow-grid-tile-container, img'))
  .some(el => (el.getAttribute('aria-label') || el.src || '').includes('image_name'));
```

---

## 🛠️ On-Screen Dialog Recovery
If a `#32770` "Open" dialog is already open on screen:
```bash
python scripts/handle_file_dialog.py --file "C:\path\to\image.png"
```
Immediately binds to the active dialog HWND, injects the path, clicks Open, and closes it.

---

See also: [[⚡ Google Flow Master Guide]] • [[👤 Master Avatar & Studio Anchor]] • [[⚙️ Active Skills Architecture]]
