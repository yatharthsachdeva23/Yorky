import os
import numpy as np
from PIL import Image

def remove_chroma_key(input_path, output_path):
    print(f"Processing {input_path} -> {output_path}...")
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)

    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]

    # Chroma key algorithm for bright green (#00FF00 or close)
    # Green screen detection: green channel significantly higher than red and blue
    green_diff = g - np.maximum(r, b)
    
    # Soft thresholding for smooth edges
    low_thresh = 25.0
    high_thresh = 55.0

    alpha = np.clip(1.0 - (green_diff - low_thresh) / (high_thresh - low_thresh), 0.0, 1.0) * 255.0

    # Spill suppression: remove green cast on edge pixels
    spill = np.clip((green_diff - 10.0) / 40.0, 0.0, 1.0)
    arr[:, :, 1] = np.where(green_diff > 10, np.maximum(r, b), g)
    arr[:, :, 3] = alpha

    # Also trim excess transparent borders
    result_img = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    
    # Crop to bounding box of non-transparent pixels
    bbox = result_img.getbbox()
    if bbox:
        # add 5px padding
        x1, y1, x2, y2 = bbox
        x1 = max(0, x1 - 5)
        y1 = max(0, y1 - 5)
        x2 = min(result_img.width, x2 + 5)
        y2 = min(result_img.height, y2 + 5)
        result_img = result_img.crop((x1, y1, x2, y2))
        
    result_img.save(output_path, "PNG")
    print(f"Saved {output_path} (size: {result_img.size})")

def remove_white_background(input_path, output_path):
    print(f"Processing white bg {input_path} -> {output_path}...")
    import scipy.ndimage as ndi
    im = Image.open(input_path).convert("RGBA")
    arr = np.array(im, dtype=np.uint8)
    white = (arr[:, :, 0] > 245) & (arr[:, :, 1] > 245) & (arr[:, :, 2] > 245)
    labeled, _ = ndi.label(white)
    b_labels = set(np.unique(labeled[0, :])) | set(np.unique(labeled[-1, :])) | set(np.unique(labeled[:, 0])) | set(np.unique(labeled[:, -1]))
    b_labels.discard(0)
    bg = np.isin(labeled, list(b_labels))
    arr[:, :, 3] = np.where(bg, 0, 255).astype(np.uint8)
    res = Image.fromarray(arr, mode="RGBA")
    bbox = res.getbbox()
    if bbox:
        res = res.crop(bbox)
    res.save(output_path, "PNG")
    print(f"Saved {output_path} (size: {res.size})")

if __name__ == "__main__":
    assets_dir = r"c:\Desktop\Antigravity Projects\YouTube Manager\companion\assets"
    source_dir = r"C:\Users\DELL\.gemini\antigravity\brain\d2723832-7768-4750-8aa8-e04b8f263a24"
    
    # Green screen images
    green_images = [
        ("yorky_smart_waiting_1788921832878.jpg", "yorky_waiting.png"),
        ("yorky_smart_working_1788921859439.jpg", "yorky_working.png"),
        ("yorky_smart_done_1788922067219.jpg", "yorky_done.png"),
        ("yorky_bored_green_1788923725581.jpg", "yorky_bored.png"),
        ("yorky_subagent_green_1788923746151.jpg", "yorky_subagent.png")
    ]
    for src_name, out_name in green_images:
        src = os.path.join(source_dir, src_name)
        out = os.path.join(assets_dir, out_name)
        if os.path.exists(src):
            remove_chroma_key(src, out)
        else:
            print(f"File not found: {src}")
