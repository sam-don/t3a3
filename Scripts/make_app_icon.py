"""Regenerates IdleDelve/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png.

A dark-gradient dungeon backdrop behind a flat-style glowing sword emblem,
rendered at 4x and downsampled for anti-aliased edges. Requires `numpy` and
`Pillow` (`pip install numpy pillow`). Run from anywhere; the output path is
resolved relative to this script.

    python3 Scripts/make_app_icon.py
"""

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SS = 3  # supersample factor for anti-aliasing
SIZE = 1024 * SS


def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


# ---------------------------------------------------------------------------
# Background: diagonal gradient (deep indigo -> near black) + radial glow
# ---------------------------------------------------------------------------
top_left = np.array(hex_to_rgb('271340'), dtype=np.float32)
bottom_right = np.array(hex_to_rgb('07050c'), dtype=np.float32)

yy, xx = np.mgrid[0:SIZE, 0:SIZE].astype(np.float32)
t = np.clip((xx + yy) / (2 * SIZE), 0, 1)

bg = (top_left[None, None, :] * (1 - t[:, :, None]) + bottom_right[None, None, :] * t[:, :, None])

glow_color = np.array(hex_to_rgb('b23a95'), dtype=np.float32)
cx, cy = SIZE * 0.5, SIZE * 0.46
dist = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / (SIZE * 0.55)
glow_strength = np.clip(1.0 - dist, 0, 1) ** 2.0 * 0.6
bg = bg + glow_color[None, None, :] * glow_strength[:, :, None]

vdist = np.sqrt((xx - SIZE / 2) ** 2 + (yy - SIZE / 2) ** 2) / (SIZE * 0.75)
vignette = 1.0 - np.clip(vdist - 0.55, 0, 1) * 0.9
bg = bg * vignette[:, :, None]

bg = np.clip(bg, 0, 255).astype(np.uint8)
img = Image.fromarray(bg, mode='RGB').convert('RGBA')
draw = ImageDraw.Draw(img, 'RGBA')


def P(x, y):
    return (x * SS, y * SS)


def poly(points, fill):
    draw.polygon([P(*p) for p in points], fill=fill)


def rounded_rect(x0, y0, x1, y1, radius, fill):
    draw.rounded_rectangle([P(x0, y0), P(x1, y1)], radius=radius * SS, fill=fill)


# ---------------------------------------------------------------------------
# Soft drop shadow beneath the emblem.
# ---------------------------------------------------------------------------
shadow_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
shadow_draw = ImageDraw.Draw(shadow_layer)
shadow_draw.ellipse([P(360, 845), P(664, 915)], fill=(0, 0, 0, 150))
shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(22 * SS))
img = Image.alpha_composite(img, shadow_layer)
draw = ImageDraw.Draw(img, 'RGBA')

# ---------------------------------------------------------------------------
# Sword emblem: blade, crossguard, glowing gem, grip, pommel.
# Large scale, filling most of the safe area, bold enough to read at 60pt.
# ---------------------------------------------------------------------------
STEEL = (232, 238, 245, 255)
STEEL_EDGE = (146, 160, 179, 255)
STEEL_SHADE = (176, 188, 204, 255)

GOLD = (223, 168, 78, 255)
GOLD_DARK = (140, 90, 34, 255)
GOLD_HILITE = (255, 226, 172, 150)

GRIP = (59, 36, 21, 255)
GRIP_LIGHT = (95, 61, 35, 255)

GEM_CORE = (238, 104, 206, 255)
GEM_EDGE = (150, 40, 130, 255)

CX = 512

# Outer glow behind the gem.
gem_glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
gem_glow_draw = ImageDraw.Draw(gem_glow)
gem_glow_draw.ellipse([P(CX - 130, 496 - 130), P(CX + 130, 496 + 130)], fill=(238, 104, 206, 210))
gem_glow = gem_glow.filter(ImageFilter.GaussianBlur(26 * SS))
img = Image.alpha_composite(img, gem_glow)
draw = ImageDraw.Draw(img, 'RGBA')

# Blade: outline first for a crisp dark edge, then two inner facets for shading.
blade_outline = [(CX, 84), (CX + 84, 328), (CX + 64, 478), (CX - 64, 478), (CX - 84, 328)]
poly(blade_outline, STEEL_EDGE)

blade_left_facet = [(CX, 104), (CX, 462), (CX - 56, 470), (CX - 74, 328)]
poly(blade_left_facet, STEEL_SHADE)

blade_right_facet = [(CX, 104), (CX, 462), (CX + 56, 470), (CX + 74, 328)]
poly(blade_right_facet, STEEL)

# Center ridge highlight running down the blade.
draw.line([P(CX, 130), P(CX, 460)], fill=(255, 255, 255, 130), width=int(9 * SS))

# Crossguard.
rounded_rect(CX - 140, 470, CX + 140, 524, 18, GOLD_DARK)
rounded_rect(CX - 140, 466, CX + 140, 512, 18, GOLD)
draw.line([P(CX - 118, 476), P(CX + 118, 476)], fill=GOLD_HILITE, width=int(7 * SS))

# Gem (rotated square / diamond) at the crossguard center.
gem_r = 52
gem_pts = [(CX, 496 - gem_r), (CX + gem_r, 496), (CX, 496 + gem_r), (CX - gem_r, 496)]
poly(gem_pts, GEM_EDGE)
gem_r_inner = 39
gem_inner = [(CX, 496 - gem_r_inner), (CX + gem_r_inner, 496), (CX, 496 + gem_r_inner), (CX - gem_r_inner, 496)]
poly(gem_inner, GEM_CORE)
draw.polygon(
    [P(CX, 496 - 20), P(CX + 13, 496), P(CX, 496 + 5), P(CX - 13, 496)],
    fill=(255, 255, 255, 200),
)

# Grip.
rounded_rect(CX - 26, 518, CX + 26, 762, 14, GRIP)
for wrap_y in (560, 610, 660, 710):
    draw.line([P(CX - 22, wrap_y), P(CX + 22, wrap_y)], fill=GRIP_LIGHT, width=int(9 * SS))

# Pommel.
draw.ellipse([P(CX - 48, 810 - 48), P(CX + 48, 810 + 48)], fill=GOLD_DARK)
draw.ellipse([P(CX - 37, 810 - 37), P(CX + 37, 810 + 37)], fill=GOLD)
draw.ellipse([P(CX - 14, 796 - 14), P(CX + 14, 796 + 14)], fill=(255, 255, 255, 120))

# ---------------------------------------------------------------------------
# Downsample for crisp anti-aliased edges, flatten onto opaque background.
# ---------------------------------------------------------------------------
final = img.resize((1024, 1024), Image.LANCZOS)
flat_bg = Image.new('RGBA', (1024, 1024), (7, 5, 12, 255))
final = Image.alpha_composite(flat_bg, final).convert('RGB')

repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out_path = os.path.join(repo_root, 'IdleDelve', 'Resources', 'Assets.xcassets', 'AppIcon.appiconset', 'AppIcon.png')
final.save(out_path, 'PNG')
print('saved', out_path, final.size)
