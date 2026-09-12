import os
import sys

# Ensure process attaches to interactive user desktop
if sys.platform == "win32":
    try:
        import ctypes
        u32 = ctypes.windll.user32
        hdesk = u32.OpenDesktopW("Default", 0, False, 0x10000000)
        if hdesk:
            u32.SetThreadDesktop(hdesk)
    except Exception:
        pass

import time
import json
import threading
import tkinter as tk
from PIL import Image, ImageTk, ImageOps

# Ensure companion package directory is on path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from hermes_watcher import HermesWatcher

SETTINGS_FILE = os.path.join(BASE_DIR, "settings.json")
ASSETS_DIR = os.path.join(BASE_DIR, "assets")

CHROMA_KEY = "#010101"

class SubagentCompanionWindow:
    """A compact, floating desktop companion representing an active subagent."""
    def __init__(self, parent_root, delegation_id, photo_img, char_w, char_h, scale_height=125):
        self.delegation_id = delegation_id
        self.scale_height = scale_height
        self.canvas_width = int(self.scale_height * 1.15)
        self.canvas_height = self.scale_height + 45
        self.photo = photo_img
        self.char_w = char_w
        self.char_h = char_h
        self.activity_text = "Working..."
        self.anim_tick = 0
        self.target_x = 0
        self.target_y = 0

        self.window = tk.Toplevel(parent_root)
        self.window.title(f"Subagent {delegation_id}")
        self.window.overrideredirect(True)
        self.window.wm_attributes("-topmost", True)
        self.window.wm_attributes("-transparentcolor", CHROMA_KEY)
        self.window.config(bg=CHROMA_KEY)

        self.canvas = tk.Canvas(
            self.window,
            width=self.canvas_width,
            height=self.canvas_height,
            bg=CHROMA_KEY,
            highlightthickness=0,
            bd=0
        )
        self.canvas.pack(fill=tk.BOTH, expand=True)

    def set_position(self, target_x, target_y):
        self.target_x = target_x
        self.target_y = target_y
        self.window.geometry(f"{self.canvas_width}x{self.canvas_height}+{int(target_x)}+{int(target_y)}")

    def update_activity(self, text):
        self.activity_text = text

    def render_frame(self):
        self.anim_tick += 1
        import math
        # Active laptop typing keystroke bobbing
        bob = int(math.sin(self.anim_tick * 0.4) * 2)

        self.canvas.delete("all")

        # 1. Thought / Activity Bubble
        text = self.activity_text or "Working..."
        if len(text) > 30:
            text = text[:28] + "..."

        bubble_x = self.canvas_width // 2
        bubble_y = 18

        full_label = f"💻 {text}"
        font = ("Segoe UI", 8, "bold")
        text_w = len(full_label) * 6 + 14
        x1 = max(3, bubble_x - text_w // 2)
        x2 = min(self.canvas_width - 3, bubble_x + text_w // 2)
        y1 = bubble_y - 11
        y2 = bubble_y + 11

        bg_col = "#1b2234"
        border_col = "#74c7ec"
        text_col = "#cdd6f4"

        # Rounded pill shape
        self.canvas.create_oval(x1, y1, x1 + 12, y2, fill=bg_col, outline=border_col, width=1.5)
        self.canvas.create_oval(x2 - 12, y1, x2, y2, fill=bg_col, outline=border_col, width=1.5)
        self.canvas.create_rectangle(x1 + 6, y1, x2 - 6, y2, fill=bg_col, outline=border_col, width=1.5)
        self.canvas.create_rectangle(x1 + 5, y1 + 1, x2 - 5, y2 - 1, fill=bg_col, outline=bg_col)

        # Little pointer triangle down
        self.canvas.create_polygon(
            bubble_x - 3, y2,
            bubble_x + 3, y2,
            bubble_x, y2 + 4,
            fill=border_col, outline=border_col
        )

        self.canvas.create_text(
            bubble_x, bubble_y,
            text=full_label,
            fill=text_col,
            font=font
        )

        # 2. Draw Mini Character
        draw_x = (self.canvas_width - self.char_w) // 2
        draw_y = 30 + bob
        self.canvas.create_image(draw_x, draw_y, image=self.photo, anchor=tk.NW)

    def destroy(self):
        try:
            self.window.destroy()
        except Exception:
            pass


class YorkyDesktopPet:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Yorky Companion")
        
        # Frameless, Always on Top, Transparent
        self.root.overrideredirect(True)
        self.root.wm_attributes("-topmost", True)
        self.root.wm_attributes("-transparentcolor", CHROMA_KEY)
        self.root.config(bg=CHROMA_KEY)

        # Settings
        self.settings = self.load_settings()
        self.scale_height = self.settings.get("scale_height", 200)
        self.show_bubble = self.settings.get("show_bubble", True)

        # Animation & State tracking
        self.current_state = "WAITING"
        self.activity_text = "Ready for command ✨"
        self.images = {}
        self.subagent_photo = None
        self.subagent_char_w = 0
        self.subagent_char_h = 0
        self.subagent_scale_h = 125
        self.subagent_windows = {}
        self.load_images()

        # Canvas for character & bubble
        self.canvas_width = int(self.scale_height * 0.9)
        self.canvas_height = self.scale_height + 50  # extra room for thought bubble
        
        self.canvas = tk.Canvas(
            self.root,
            width=self.canvas_width,
            height=self.canvas_height,
            bg=CHROMA_KEY,
            highlightthickness=0,
            bd=0
        )
        self.canvas.pack(fill=tk.BOTH, expand=True)

        # Position window
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        default_x = screen_w - self.canvas_width - 50
        default_y = screen_h - self.canvas_height - 65

        x = self.settings.get("x", default_x)
        y = self.settings.get("y", default_y)
        # Ensure inside screen bounds
        x = max(0, min(x, screen_w - self.canvas_width))
        y = max(0, min(y, screen_h - self.canvas_height))
        self.root.geometry(f"{self.canvas_width}x{self.canvas_height}+{x}+{y}")

        # Drag event bindings
        self.drag_start_x = 0
        self.drag_start_y = 0
        self.canvas.bind("<ButtonPress-1>", self.on_drag_start)
        self.canvas.bind("<B1-Motion>", self.on_drag_motion)
        self.canvas.bind("<ButtonRelease-1>", self.on_drag_release)

        # Right-click context menu
        self.canvas.bind("<Button-3>", self.show_context_menu)
        self.create_context_menu()

        # Hover event for bubble
        self.hover_active = False
        self.canvas.bind("<Enter>", self.on_hover_enter)
        self.canvas.bind("<Leave>", self.on_hover_leave)

        # Subtle bobbing / breathing loop
        self.anim_tick = 0
        self.char_image_id = None
        self.bubble_bg_id = None
        self.bubble_text_id = None
        self.bubble_fade_timer = time.time() + 5.0

        # Start Hermes watcher thread
        self.watcher = HermesWatcher()
        self.running = True
        self.monitor_thread = threading.Thread(target=self.hermes_monitor_loop, daemon=True)
        self.monitor_thread.start()

        # Start animation frame loop
        self.render_frame()

    def load_settings(self):
        if os.path.exists(SETTINGS_FILE):
            try:
                with open(SETTINGS_FILE, "r") as f:
                    return json.load(f)
            except Exception:
                pass
        return {"scale_height": 200, "show_bubble": True}

    def save_settings(self):
        try:
            self.settings["x"] = self.root.winfo_x()
            self.settings["y"] = self.root.winfo_y()
            self.settings["scale_height"] = self.scale_height
            self.settings["show_bubble"] = self.show_bubble
            with open(SETTINGS_FILE, "w") as f:
                json.dump(self.settings, f, indent=2)
        except Exception:
            pass

    def load_images(self):
        poses = {
            "WAITING": "yorky_waiting.png",
            "WORKING": "yorky_working.png",
            "DONE": "yorky_done.png",
            "WAITING_API": "yorky_bored.png",
            "SUBAGENT": "yorky_subagent.png"
        }
        for state_key, filename in poses.items():
            path = os.path.join(ASSETS_DIR, filename)
            if os.path.exists(path):
                raw = Image.open(path).convert("RGBA")
                # Scale keeping aspect ratio
                aspect = raw.width / raw.height
                w = int(self.scale_height * aspect)
                h = self.scale_height
                resized = raw.resize((w, h), Image.Resampling.LANCZOS)
                
                # Composite onto CHROMA_KEY (#010101 -> (1,1,1)) for perfect transparency
                bg = Image.new("RGBA", (w, h), (1, 1, 1, 255))
                bg.paste(resized, (0, 0), resized)
                final = bg.convert("RGB")

                self.images[state_key] = {
                    "photo": ImageTk.PhotoImage(final),
                    "width": w,
                    "height": h
                }

        # Prepare mini subagent character (scaled to ~62% of Yorky, e.g. 125px)
        working_path = os.path.join(ASSETS_DIR, "yorky_working.png")
        if os.path.exists(working_path):
            raw_w = Image.open(working_path).convert("RGBA")
            sub_h = int(self.scale_height * 0.62)
            sub_w = int(sub_h * (raw_w.width / raw_w.height))
            resized_sub = raw_w.resize((sub_w, sub_h), Image.Resampling.LANCZOS)
            bg_sub = Image.new("RGBA", (sub_w, sub_h), (1, 1, 1, 255))
            bg_sub.paste(resized_sub, (0, 0), resized_sub)
            self.subagent_photo = ImageTk.PhotoImage(bg_sub.convert("RGB"))
            self.subagent_char_w = sub_w
            self.subagent_char_h = sub_h
            self.subagent_scale_h = sub_h

    def on_drag_start(self, event):
        self.drag_start_x = event.x
        self.drag_start_y = event.y

    def on_drag_motion(self, event):
        deltax = event.x - self.drag_start_x
        deltay = event.y - self.drag_start_y
        x = self.root.winfo_x() + deltax
        y = self.root.winfo_y() + deltay
        self.root.geometry(f"+{x}+{y}")
        self.update_subagent_positions()

    def on_drag_release(self, event):
        self.save_settings()
        self.update_subagent_positions()

    def on_hover_enter(self, event):
        self.hover_active = True
        self.bubble_fade_timer = time.time() + 6.0

    def on_hover_leave(self, event):
        self.hover_active = False

    def update_subagent_positions(self):
        yorky_x = self.root.winfo_x()
        yorky_y = self.root.winfo_y()
        for i, (did, win) in enumerate(self.subagent_windows.items()):
            spacing = 10
            sub_x = yorky_x - (i + 1) * (win.canvas_width + spacing)
            sub_y = (yorky_y + self.canvas_height) - win.canvas_height
            win.set_position(sub_x, sub_y)

    def sync_subagent_windows(self, active_subs):
        """Spawns, updates, or removes subagent mini-companion windows."""
        active_ids = {s["id"] for s in active_subs}

        # 1. Destroy windows for completed/stopped subagents
        for did in list(self.subagent_windows.keys()):
            if did not in active_ids:
                win = self.subagent_windows.pop(did)
                win.destroy()

        # 2. Spawn or update windows for currently running subagents
        yorky_x = self.root.winfo_x()
        yorky_y = self.root.winfo_y()

        for i, sdata in enumerate(active_subs):
            did = sdata["id"]
            action = sdata.get("action", "Working...")
            if did not in self.subagent_windows:
                if self.subagent_photo:
                    sub_win = SubagentCompanionWindow(
                        self.root, did, self.subagent_photo,
                        self.subagent_char_w, self.subagent_char_h,
                        scale_height=self.subagent_scale_h
                    )
                    self.subagent_windows[did] = sub_win

            win = self.subagent_windows.get(did)
            if win:
                win.update_activity(action)
                spacing = 10
                sub_x = yorky_x - (i + 1) * (win.canvas_width + spacing)
                sub_y = (yorky_y + self.canvas_height) - win.canvas_height
                win.set_position(sub_x, sub_y)

    def create_context_menu(self):
        self.menu = tk.Menu(self.root, tearoff=0, bg="#1e1e2e", fg="#cdd6f4", activebackground="#45475a", activeforeground="#ffffff")
        self.menu.add_command(label="Yorky - Hermes Companion", state="disabled")
        self.menu.add_separator()
        
        # Size submenu
        size_menu = tk.Menu(self.menu, tearoff=0, bg="#1e1e2e", fg="#cdd6f4")
        size_menu.add_command(label="Small (160px)", command=lambda: self.change_size(160))
        size_menu.add_command(label="Normal (200px)", command=lambda: self.change_size(200))
        size_menu.add_command(label="Large (250px)", command=lambda: self.change_size(250))
        self.menu.add_cascade(label="Character Size", menu=size_menu)

        self.menu.add_command(label="Toggle Speech Bubble", command=self.toggle_bubble)
        self.menu.add_command(label="Reset to Bottom-Right", command=self.reset_position)
        self.menu.add_separator()
        self.menu.add_command(label="Exit Yorky", command=self.quit)

    def show_context_menu(self, event):
        self.menu.post(event.x_root, event.y_root)

    def change_size(self, new_height):
        self.scale_height = new_height
        self.canvas_width = int(self.scale_height * 0.9)
        self.canvas_height = self.scale_height + 50
        self.canvas.config(width=self.canvas_width, height=self.canvas_height)
        self.load_images()
        self.update_subagent_positions()
        self.save_settings()

    def toggle_bubble(self):
        self.show_bubble = not self.show_bubble
        self.save_settings()

    def reset_position(self):
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        x = screen_w - self.canvas_width - 50
        y = screen_h - self.canvas_height - 65
        self.root.geometry(f"+{x}+{y}")
        self.update_subagent_positions()
        self.save_settings()

    def hermes_monitor_loop(self):
        while self.running:
            try:
                st, act = self.watcher.get_state()
                if st != self.current_state or act != self.activity_text:
                    self.current_state = st
                    self.activity_text = act
                    # Show bubble for 6 seconds on state change
                    self.bubble_fade_timer = time.time() + 6.0

                # Track active subagents and sync mini-windows
                active_subs = self.watcher.get_all_active_subagents()
                self.root.after(0, self.sync_subagent_windows, active_subs)
            except Exception:
                pass
            time.sleep(2.0)  # Exactly 2 seconds live update interval

    def render_frame(self):
        self.anim_tick += 1
        now = time.time()

        # Subtle bobbing: 2 pixels up/down smoothly (breathing cycle ~1.5s)
        import math
        bob = int(math.sin(self.anim_tick * 0.1) * 2)

        # State-specific animation tweaks
        if self.current_state == "WORKING":
            shake = int(math.sin(self.anim_tick * 0.5) * 1.5)
            bob += shake
        elif self.current_state == "WAITING_API":
            bob = int(math.sin(self.anim_tick * 0.05) * 1.2) + 2
        elif self.current_state == "SUBAGENT":
            bob = int(math.sin(self.anim_tick * 0.08) * 1.5)

        # Clear previous elements
        self.canvas.delete("all")

        # 1. Draw Thought / Speech Bubble if active
        show_bubble = self.show_bubble and (now < self.bubble_fade_timer or self.hover_active or self.current_state in ("WORKING", "WAITING_API", "SUBAGENT", "DONE"))
        if show_bubble and self.activity_text:
            text = self.activity_text
            if len(text) > 34:
                text = text[:32] + "..."

            bubble_y = 22
            bubble_x = self.canvas_width // 2

            # Color scheme based on state
            if self.current_state == "WAITING_API":
                bg_col = "#2a1e1e"
                border_col = "#fab387"
                text_col = "#fab387"
                badge = "⏳ "
            elif self.current_state == "SUBAGENT":
                bg_col = "#1b2b2b"
                border_col = "#a6e3a1"
                text_col = "#a6e3a1"
                badge = "👀 "
            elif self.current_state == "WORKING":
                bg_col = "#1e2030"
                border_col = "#89dceb"
                text_col = "#89dceb"
                badge = "⚡ "
            elif self.current_state == "DONE":
                bg_col = "#24273a"
                border_col = "#f9e2af"
                text_col = "#f9e2af"
                badge = "⌚ "
            else:
                bg_col = "#181926"
                border_col = "#cba6f7"
                text_col = "#cba6f7"
                badge = "✨ "

            full_label = f"{badge}{text}"
            
            # Draw rounded pill
            pad_x = 10
            pad_y = 5
            font = ("Segoe UI", 8, "bold")
            
            # Measure text roughly
            text_w = len(full_label) * 6 + 16
            x1 = max(4, bubble_x - text_w // 2)
            x2 = min(self.canvas_width - 4, bubble_x + text_w // 2)
            y1 = bubble_y - 12
            y2 = bubble_y + 12

            # Rounded rectangle (pill shape)
            self.canvas.create_oval(x1, y1, x1 + 14, y2, fill=bg_col, outline=border_col, width=1.5)
            self.canvas.create_oval(x2 - 14, y1, x2, y2, fill=bg_col, outline=border_col, width=1.5)
            self.canvas.create_rectangle(x1 + 7, y1, x2 - 7, y2, fill=bg_col, outline=border_col, width=1.5)
            # Inner fill to cover seam
            self.canvas.create_rectangle(x1 + 6, y1 + 1, x2 - 6, y2 - 1, fill=bg_col, outline=bg_col)

            # Little pointer triangle down
            self.canvas.create_polygon(
                bubble_x - 4, y2,
                bubble_x + 4, y2,
                bubble_x, y2 + 5,
                fill=border_col, outline=border_col
            )

            self.canvas.create_text(
                bubble_x, bubble_y,
                text=full_label,
                fill=text_col,
                font=font
            )

        # 2. Draw Yorky Character Sprite
        img_data = self.images.get(self.current_state, self.images.get("WAITING"))
        if img_data:
            photo = img_data["photo"]
            char_w = img_data["width"]
            char_h = img_data["height"]
            
            draw_x = (self.canvas_width - char_w) // 2
            draw_y = 38 + bob  # below bubble

            self.canvas.create_image(draw_x, draw_y, image=photo, anchor=tk.NW)

        # Render active subagent companion windows
        for win in list(self.subagent_windows.values()):
            win.render_frame()

        # Next frame in ~40ms (25 fps for silky smooth floating)
        self.root.after(40, self.render_frame)

    def quit(self):
        self.running = False
        self.save_settings()
        for win in list(self.subagent_windows.values()):
            win.destroy()
        self.subagent_windows.clear()
        self.root.destroy()
        sys.exit(0)

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    try:
        pet = YorkyDesktopPet()
        pet.run()
    except Exception:
        import traceback
        err_path = os.path.join(BASE_DIR, "yorky_companion.log")
        with open(err_path, "a", encoding="utf-8") as f:
            f.write(f"\n--- Crash at {time.ctime()} ---\n")
            traceback.print_exc(file=f)
