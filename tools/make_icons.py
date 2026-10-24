#!/usr/bin/env python3
"""Draw the Pyrewick icon set. Original art, released CC0 with this project."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "3d_game"
IOS = ROOT / "icons" / "ios"
ANDROID = ROOT / "icons" / "android"

IOS_SIZES = {
    "settings_58x58": 58,
    "settings_87x87": 87,
    "notification_40x40": 40,
    "notification_60x60": 60,
    "notification_76x76": 76,
    "notification_114x114": 114,
    "spotlight_80x80": 80,
    "spotlight_120x120": 120,
    "iphone_120x120": 120,
    "iphone_180x180": 180,
    "ipad_167x167": 167,
    "ipad_152x152": 152,
    "ios_128x128": 128,
    "ios_192x192": 192,
    "ios_136x136": 136,
    "app_store_1024x1024": 1024,
    "icon_1024x1024": 1024,
}


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(size, top, bottom):
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        color = lerp(top, bottom, y / max(1, size - 1))
        row = color + (255,)
        for x in range(size):
            px[x, y] = row
    return img


def flame(cx, cy, height):
    return [
        (cx, cy - height * 0.56),
        (cx + height * 0.18, cy - height * 0.22),
        (cx + height * 0.08, cy - height * 0.06),
        (cx + height * 0.30, cy + height * 0.18),
        (cx + height * 0.06, cy + height * 0.30),
        (cx, cy + height * 0.50),
        (cx - height * 0.06, cy + height * 0.30),
        (cx - height * 0.30, cy + height * 0.18),
        (cx - height * 0.08, cy - height * 0.06),
        (cx - height * 0.18, cy - height * 0.22),
    ]


def draw_glyph(draw, size, colors, scale):
    s = size * scale
    cx = size * 0.50
    cy = size * 0.48
    ring = s * 0.31
    width = max(2, int(s * 0.045))
    box = [cx - ring, cy - ring - s * 0.02, cx + ring, cy + ring - s * 0.02]
    draw.ellipse(box, outline=colors["ring"], width=width)
    draw.ellipse(
        [cx - ring * 0.78, cy - ring * 0.78 - s * 0.02, cx + ring * 0.78, cy + ring * 0.78 - s * 0.02],
        outline=colors["ring_dim"],
        width=max(1, width // 2),
    )
    base = cy - s * 0.02
    draw.polygon(flame(cx, base - s * 0.02, s * 0.62), fill=colors["flame"])
    draw.polygon(flame(cx, base + s * 0.02, s * 0.40), fill=colors["flame_mid"])
    draw.polygon(flame(cx, base + s * 0.05, s * 0.20), fill=colors["core"])
    # Brass key, chunky enough to read at notification size.
    ky = cy + s * 0.30
    bow = s * 0.115
    draw.rounded_rectangle(
        [cx - s * 0.02, ky - s * 0.045, cx + s * 0.30, ky + s * 0.045],
        radius=s * 0.03,
        fill=colors["key"],
    )
    draw.rectangle([cx + s * 0.18, ky + s * 0.01, cx + s * 0.24, ky + s * 0.11], fill=colors["key"])
    draw.rectangle([cx + s * 0.26, ky + s * 0.01, cx + s * 0.31, ky + s * 0.08], fill=colors["key"])
    draw.ellipse([cx - bow * 2.05, ky - bow, cx - s * 0.01, ky + bow], fill=colors["key"])
    hole = bow * 0.48
    hx = cx - bow * 1.02
    draw.ellipse([hx - hole, ky - hole, hx + hole, ky + hole], fill=colors["hole"])
    for spark, sy in ((-0.34, -0.18), (0.36, -0.08), (0.30, 0.22)):
        r = s * 0.018
        px = cx + s * spark
        py = cy + s * sy
        draw.ellipse([px - r, py - r, px + r, py + r], fill=colors["core"])


def render(size, top, bottom, colors, scale=0.92, rounded=0, transparent=False):
    if transparent:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        img = gradient(size, top, bottom)
    draw = ImageDraw.Draw(img)
    draw_glyph(draw, size, colors, scale)
    if rounded:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=rounded, fill=255)
        img.putalpha(mask)
    return img


def master(kind):
    # Draw large, then downscale so small icons stay smooth.
    size = 1024
    if kind == "normal":
        return render(
            size,
            (28, 16, 12),
            (92, 42, 22),
            {
                "ring": (255, 176, 64, 255),
                "ring_dim": (176, 96, 40, 255),
                "flame": (255, 78, 24, 255),
                "flame_mid": (255, 168, 32, 255),
                "core": (255, 236, 176, 255),
                "key": (240, 193, 74, 255),
                "hole": (42, 22, 14, 255),
            },
        )
    if kind == "dark":
        return render(
            size,
            (8, 5, 4),
            (32, 16, 10),
            {
                "ring": (232, 150, 54, 255),
                "ring_dim": (120, 64, 28, 255),
                "flame": (255, 96, 32, 255),
                "flame_mid": (255, 186, 64, 255),
                "core": (255, 244, 210, 255),
                "key": (255, 214, 120, 255),
                "hole": (12, 7, 5, 255),
            },
        )
    if kind == "fg":
        return render(
            size,
            (0, 0, 0),
            (0, 0, 0),
            {
                "ring": (255, 186, 80, 255),
                "ring_dim": (255, 140, 48, 255),
                "flame": (255, 90, 28, 255),
                "flame_mid": (255, 176, 40, 255),
                "core": (255, 240, 190, 255),
                "key": (255, 210, 96, 255),
                "hole": (0, 0, 0, 0),
            },
            scale=0.62,
            transparent=True,
        )
    if kind == "mono":
        white = (255, 255, 255, 255)
        return render(
            size,
            (0, 0, 0),
            (0, 0, 0),
            {
                "ring": white,
                "ring_dim": white,
                "flame": white,
                "flame_mid": white,
                "core": white,
                "key": white,
                "hole": (0, 0, 0, 0),
            },
            scale=0.62,
            transparent=True,
        )
    raise SystemExit(kind)


def save_resized(image, path, size):
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(path, "PNG")


def write_svg():
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <rect width="1024" height="1024" rx="224" fill="#24160F"/>
  <circle cx="512" cy="470" r="250" fill="none" stroke="#FFB040" stroke-width="36"/>
  <path d="M512 210 C560 300 620 340 600 430 C680 500 560 560 512 640 C464 560 344 500 424 430 C404 340 464 300 512 210 Z" fill="#FF5A1F"/>
  <path d="M512 300 C540 360 580 390 560 450 C610 490 540 530 512 580 C484 530 414 490 464 450 C444 390 484 360 512 300 Z" fill="#FFB020"/>
  <circle cx="390" cy="690" r="78" fill="#F0C14A"/>
  <circle cx="390" cy="690" r="34" fill="#2A160E"/>
  <rect x="450" y="662" width="250" height="56" rx="20" fill="#F0C14A"/>
  <rect x="620" y="700" width="36" height="70" fill="#F0C14A"/>
  <rect x="680" y="700" width="28" height="48" fill="#F0C14A"/>
</svg>
"""
    (ROOT / "icon.svg").write_text(svg)


def main():
    normal = master("normal")
    dark = master("dark")
    tinted = Image.merge("RGBA", (*normal.convert("RGB").convert("L").convert("RGB").split(), normal.getchannel("A")))
    fg = master("fg")
    mono = master("mono")
    bg = gradient(1024, (36, 18, 12), (120, 52, 24))
    for name, size in IOS_SIZES.items():
        save_resized(normal, IOS / f"{name}.png", size)
        save_resized(dark, IOS / f"{name}_dark.png", size)
        save_resized(tinted, IOS / f"{name}_tinted.png", size)
    save_resized(normal, ANDROID / "main_192.png", 192)
    save_resized(fg, ANDROID / "adaptive_foreground_432.png", 432)
    save_resized(bg, ANDROID / "adaptive_background_432.png", 432)
    save_resized(mono, ANDROID / "adaptive_monochrome_432.png", 432)
    menu = render(
        1024,
        (28, 16, 12),
        (92, 42, 22),
        {
            "ring": (255, 176, 64, 255),
            "ring_dim": (176, 96, 40, 255),
            "flame": (255, 78, 24, 255),
            "flame_mid": (255, 168, 32, 255),
            "core": (255, 236, 176, 255),
            "key": (240, 193, 74, 255),
            "hole": (42, 22, 14, 255),
        },
        rounded=224,
    )
    menu.save(ROOT / "icon.png", "PNG")
    write_svg()
    print(f"wrote icons under {ROOT}")


if __name__ == "__main__":
    main()
