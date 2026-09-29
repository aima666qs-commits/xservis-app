#!/usr/bin/env python3
"""Generate XFreedom iOS AppIcon PNGs without external Python packages."""

from __future__ import annotations

import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"

SIZES = {
    "AppIcon-20@1x.png": 20,
    "AppIcon-20@2x.png": 40,
    "AppIcon-20@3x.png": 60,
    "AppIcon-29@1x.png": 29,
    "AppIcon-29@2x.png": 58,
    "AppIcon-29@3x.png": 87,
    "AppIcon-40@1x.png": 40,
    "AppIcon-40@2x.png": 80,
    "AppIcon-40@3x.png": 120,
    "AppIcon-60@2x.png": 120,
    "AppIcon-60@3x.png": 180,
    "AppIcon-76@1x.png": 76,
    "AppIcon-76@2x.png": 152,
    "AppIcon-83.5@2x.png": 167,
    "AppIcon-1024.png": 1024,
}


def _chunk(tag: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + tag
        + payload
        + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)
    )


def _png_rgb(width: int, height: int, pixels: bytes) -> bytes:
    rows = bytearray()
    stride = width * 3
    for y in range(height):
        rows.append(0)  # PNG filter: None
        start = y * stride
        rows.extend(pixels[start : start + stride])
    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", header)
        + _chunk(b"IDAT", zlib.compress(bytes(rows), 9))
        + _chunk(b"IEND", b"")
    )


def _mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return tuple(round(a[i] * (1.0 - t) + b[i] * t) for i in range(3))


def render(size: int) -> bytes:
    bg0 = (2, 7, 11)
    bg1 = (5, 20, 27)
    cyan0 = (0, 221, 235)
    cyan1 = (76, 244, 255)

    px = bytearray(size * size * 3)
    half = (size - 1) / 2.0
    thick = max(1.8, size * 0.105)
    glow = max(2.0, size * 0.040)

    for y in range(size):
        ny = (y - half) / max(1.0, half)
        for x in range(size):
            nx = (x - half) / max(1.0, half)
            r = math.sqrt(nx * nx + ny * ny)
            base_t = max(0.0, min(1.0, 0.75 - r * 0.55))
            color = _mix(bg0, bg1, base_t)

            # Two diagonal strokes form the X. Distances are in pixel space.
            d1 = abs((x - half) - (y - half)) / math.sqrt(2.0)
            d2 = abs((x - half) + (y - half)) / math.sqrt(2.0)
            d = min(d1, d2)

            # Keep some breathing room near the icon edges.
            edge = max(abs(nx), abs(ny))
            edge_fade = max(0.0, min(1.0, (0.93 - edge) / 0.10))

            if d <= thick:
                t = (1.0 - d / thick) * edge_fade
                hi = _mix(cyan0, cyan1, max(0.0, 0.55 - r * 0.25))
                color = _mix(color, hi, 0.82 + 0.18 * t)
            elif d <= thick + glow:
                t = (1.0 - (d - thick) / glow) * edge_fade
                color = _mix(color, cyan0, 0.18 * t)

            i = (y * size + x) * 3
            px[i : i + 3] = bytes(color)

    return _png_rgb(size, size, bytes(px))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, size in SIZES.items():
        (OUT / name).write_bytes(render(size))
    print(f"Generated {len(SIZES)} XFreedom iOS app icons in {OUT}")


if __name__ == "__main__":
    main()
