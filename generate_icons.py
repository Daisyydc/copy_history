#!/usr/bin/env python3
"""
Generate pink-heart-with-wings icon PNGs for Ballet Clipboard app.
少女心风格：白色圆底 + 粉色爱心 + 翅膀
Uses only Python stdlib — no external dependencies.
"""

import zlib
import struct
import os
import math

# ── 色彩定义 ──
ROSE_PINK   = (0xD4, 0x78, 0x8F)   # 爱心主色：玫瑰粉 #D4788F
LIGHT_PINK  = (0xF2, 0xC4, 0xCE)   # 翅膀色：芭蕾粉 #F2C4CE
WING_PINK   = (0xF7, 0xD5, 0xDB)   # 翅膀高光：浅粉 #F7D5DB
WHITE_BG    = (0xFF, 0xFF, 0xFF)   # 纯白打底
SOFT_WHITE  = (0xFF, 0xF5, 0xF5)   # 柔和白（圆底）
BG_PINK     = (0xFF, 0xF0, 0xF3)   # 极浅粉背景


def create_png(width: int, height: int, pixels_func) -> bytes:
    signature = b'\x89PNG\r\n\x1a\n'
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'
        for x in range(width):
            r, g, b, a = pixels_func(x, y, width, height)
            raw_data += struct.pack('BBBB', r, g, b, a)

    ihdr = make_chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
    idat = make_chunk(b'IDAT', zlib.compress(raw_data))
    iend = make_chunk(b'IEND', b'')
    return signature + ihdr + idat + iend


def make_chunk(chunk_type: bytes, data: bytes) -> bytes:
    chunk = chunk_type + data
    crc = struct.pack('>I', zlib.crc32(chunk) & 0xFFFFFFFF)
    return struct.pack('>I', len(data)) + chunk + crc


def smoothstep(edge0: float, edge1: float, x: float) -> float:
    """Smooth Hermite interpolation for antialiasing."""
    t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def heart_sdf(hx: float, hy: float) -> float:
    """
    Signed distance-like function for heart shape.
    Negative = inside heart. Uses the standard heart curve.
    """
    # Heart equation: (x^2 + y^2 - 1)^3 - x^2 * y^3
    # Returns approximate signed distance
    x2 = hx * hx
    y2 = hy * hy
    y3 = y2 * abs(hy)
    return (x2 + y2 - 1.0) ** 3 - x2 * y3


def wing_sdf(wx: float, wy: float, side: int) -> float:
    """
    Wing shape using ellipses positioned on each side of the heart.
    side: -1 for left wing, 1 for right wing.
    Returns negative = inside wing.
    """
    # Position wing beside heart
    cx = side * 0.55   # wing center x
    cy = -0.08         # wing center y
    rx = 0.32          # wing radius x
    ry = 0.18          # wing radius y

    # Rotate wing slightly
    angle = -side * 0.35
    dx = wx - cx
    dy = wy - cy
    rx2 = dx * math.cos(angle) + dy * math.sin(angle)
    ry2 = -dx * math.sin(angle) + dy * math.cos(angle)

    return (rx2 * rx2) / (rx * rx) + (ry2 * ry2) / (ry * ry) - 1.0


def blend_color(c1: tuple, c2: tuple, t: float) -> tuple:
    """Linear blend between two RGBA colors."""
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(4))


def heart_with_wings_pixels(x: int, y: int, w: int, h: int) -> tuple:
    """
    少女心图标：白色圆底 + 粉色爱心 + 两侧翅膀
    """
    # 坐标归一化到 [-1.2, 1.2] 留边距
    scale = 1.15
    nx = (x / w - 0.5) * 2.0 * scale
    ny = (y / h - 0.5) * 2.0 * scale

    # ── 1. 纯白圆底（带柔和抗锯齿边缘）──
    circle_dist = math.sqrt(nx * nx + ny * ny) - 0.82
    circle_alpha = 1.0 - smoothstep(-0.04, 0.02, circle_dist)

    if circle_dist > 0.04:
        # 圆外：纯白背景
        return (255, 255, 255, 255)

    # ── 2. 翅膀（在爱心后面）──
    wing_scale = 1.0  # heart coords match normalized coords
    left_wing = wing_sdf(nx / wing_scale, ny / wing_scale, -1)
    right_wing = wing_sdf(nx / wing_scale, ny / wing_scale, 1)
    in_left_wing = left_wing < 0.02
    in_right_wing = right_wing < 0.02

    # ── 3. 爱心 ──
    # 稍微缩小爱心，放在中心偏上
    heart_scale = 0.65
    hx = nx / heart_scale
    hy = (ny + 0.02) / heart_scale  # 微调垂直位置
    heart_val = heart_sdf(hx, hy)
    in_heart = heart_val < 0.01

    # ── 4. 上色逻辑 ──
    # 默认：白色圆底内用柔和白
    r, g, b = SOFT_WHITE
    alpha = 255

    # 爱心边缘抗锯齿
    heart_edge_width = 0.008
    heart_soft = smoothstep(heart_edge_width, -heart_edge_width, heart_val)

    # 翅膀边缘抗锯齿
    wing_edge_width = 0.015

    if in_heart and heart_val < -0.001:
        # 爱心内部：玫瑰粉
        # 加一点渐变效果（中间稍亮）
        grad = 1.0 - 0.08 * (hx * hx + hy * hy)
        r = int(ROSE_PINK[0] * grad)
        g = int(ROSE_PINK[1] * grad)
        b = int(ROSE_PINK[2] * grad)
        alpha = 255

    elif heart_soft > 0 and not in_heart:
        # 爱心边缘过渡
        base_r, base_g, base_b = ROSE_PINK
        r = int(SOFT_WHITE[0] + (base_r - SOFT_WHITE[0]) * heart_soft)
        g = int(SOFT_WHITE[1] + (base_g - SOFT_WHITE[1]) * heart_soft)
        b = int(SOFT_WHITE[2] + (base_b - SOFT_WHITE[2]) * heart_soft)

    # 翅膀绘制（在爱心上面或旁边）
    def draw_wing(wing_dist, base_rgb):
        nonlocal r, g, b
        if wing_dist < -0.003:
            # 翅膀内部
            r, g, b = base_rgb
        elif wing_dist < 0.015:
            # 翅膀边缘过渡
            t = smoothstep(0.015, -0.015, wing_dist)
            r = int(r + (base_rgb[0] - r) * t)
            g = int(g + (base_rgb[1] - g) * t)
            b = int(b + (base_rgb[2] - b) * t)

    draw_wing(left_wing, LIGHT_PINK)
    draw_wing(right_wing, LIGHT_PINK)

    # 圆底边缘过渡
    if -0.04 < circle_dist < 0.02:
        bg_r, bg_g, bg_b = 255, 255, 255
        t = smoothstep(0.02, -0.04, circle_dist)
        r = int(bg_r + (r - bg_r) * t)
        g = int(bg_g + (g - bg_g) * t)
        b = int(bg_b + (b - bg_b) * t)

    return (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), alpha)


def main():
    sizes = {
        'icon_16.png': 16,
        'icon_32.png': 32,
        'icon_128.png': 128,
        'icon_256.png': 256,
        'icon_512.png': 512,
    }

    base_dir = os.path.dirname(os.path.abspath(__file__))
    icon_dir = os.path.join(base_dir, 'BalletClipboard', 'Assets.xcassets', 'AppIcon.appiconset')
    os.makedirs(icon_dir, exist_ok=True)

    for filename, size in sizes.items():
        png_data = create_png(size, size, heart_with_wings_pixels)
        filepath = os.path.join(icon_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f'✅ {filename} ({size}×{size})')

    for filename, size in list(sizes.items()):
        name, ext = filename.rsplit('.', 1)
        name_2x = f'{name}@2x.{ext}'
        png_data = create_png(size * 2, size * 2, heart_with_wings_pixels)
        filepath = os.path.join(icon_dir, name_2x)
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f'✅ {name_2x} ({size*2}×{size*2})')

    # Update Contents.json
    import json
    contents_path = os.path.join(icon_dir, 'Contents.json')
    contents = {
        "images": [
            {"idiom": "mac", "scale": "1x", "size": "16x16", "filename": "icon_16.png"},
            {"idiom": "mac", "scale": "2x", "size": "16x16", "filename": "icon_16@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "32x32", "filename": "icon_32.png"},
            {"idiom": "mac", "scale": "2x", "size": "32x32", "filename": "icon_32@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "128x128", "filename": "icon_128.png"},
            {"idiom": "mac", "scale": "2x", "size": "128x128", "filename": "icon_128@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "256x256", "filename": "icon_256.png"},
            {"idiom": "mac", "scale": "2x", "size": "256x256", "filename": "icon_256@2x.png"},
            {"idiom": "mac", "scale": "1x", "size": "512x512", "filename": "icon_512.png"},
            {"idiom": "mac", "scale": "2x", "size": "512x512", "filename": "icon_512@2x.png"},
        ],
        "info": {"author": "xcode", "version": 1}
    }
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    print('✅ Updated Contents.json')

    # MenuBarIcon
    menubar_dir = os.path.join(base_dir, 'BalletClipboard', 'Assets.xcassets', 'MenuBarIcon.imageset')
    os.makedirs(menubar_dir, exist_ok=True)
    for size, filename in [(18, 'ballet_shoes_18.png'), (36, 'ballet_shoes_36.png')]:
        png_data = create_png(size, size, heart_with_wings_pixels)
        filepath = os.path.join(menubar_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f'✅ menubar: {filename} ({size}×{size})')

    print('\n🩰💕 少女心爱心翅膀图标已生成！')


if __name__ == '__main__':
    main()
