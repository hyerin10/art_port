"""Process ArtPort icon: remove text, center symbol at 80% of canvas."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "assets" / "branding" / "art_port_icon_source.png"
ICON_PATH = ROOT / "assets" / "branding" / "art_port_icon.png"
FOREGROUND_PATH = ROOT / "assets" / "branding" / "art_port_icon_foreground.png"

CANVAS_SIZE = 1024
BG_COLOR = (253, 251, 247, 255)
# Sized for comfortable padding inside circular launcher icons.
SYMBOL_SCALE = 0.55


def _content_mask(img: Image.Image) -> np.ndarray:
    arr = np.array(img.convert("RGBA"))
    bg = np.array([253, 251, 247])
    return np.abs(arr[:, :, :3].astype(int) - bg).sum(axis=2) > 30


def _detect_symbol_box(img: Image.Image) -> tuple[int, int, int, int]:
    """Crop symbol only by splitting from bottom text via vertical gap."""
    mask = _content_mask(img)
    row_density = mask.sum(axis=1)

    gap_start = None
    symbol_bottom = mask.shape[0] - 1
    for y in range(520, 760):
        if row_density[y] < 15:
            gap_start = y
        elif gap_start is not None and row_density[y] > 60:
            symbol_bottom = gap_start
            break
        elif row_density[y] > 40 and y < 650:
            symbol_bottom = y

    symbol_mask = mask[: symbol_bottom + 1]
    cols = np.where(symbol_mask.any(axis=0))[0]
    rows = np.where(symbol_mask.any(axis=1))[0]
    pad = 8
    return (
        max(0, int(cols[0]) - pad),
        max(0, int(rows[0]) - pad),
        min(mask.shape[1], int(cols[-1]) + pad + 1),
        min(mask.shape[0], int(rows[-1]) + pad + 1),
    )


def _trim_background(symbol: Image.Image) -> Image.Image:
    rgba = symbol.convert("RGBA")
    mask = np.array(_content_mask(symbol))
    rows = np.where(mask.any(axis=1))[0]
    cols = np.where(mask.any(axis=0))[0]
    return rgba.crop((int(cols[0]), int(rows[0]), int(cols[-1]) + 1, int(rows[-1]) + 1))


def _scale_to_fit(symbol: Image.Image, target: int) -> Image.Image:
    width, height = symbol.size
    ratio = min(target / width, target / height)
    new_size = (max(1, int(width * ratio)), max(1, int(height * ratio)))
    return symbol.resize(new_size, Image.Resampling.LANCZOS)


def _center_on_canvas(
    symbol: Image.Image,
    *,
    background: tuple[int, int, int, int],
    scale: float = SYMBOL_SCALE,
) -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), background)
    target = int(CANVAS_SIZE * scale)
    scaled = _scale_to_fit(symbol, target)

    x = (CANVAS_SIZE - scaled.width) // 2
    y = (CANVAS_SIZE - scaled.height) // 2
    canvas.paste(scaled, (x, y), scaled)
    return canvas


def _make_foreground(symbol: Image.Image) -> Image.Image:
    rgba = symbol.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            if r > 240 and g > 238 and b > 232:
                pixels[x, y] = (r, g, b, 0)
    return _center_on_canvas(rgba, background=(0, 0, 0, 0))


def _report_bounds(path: Path, label: str) -> None:
    img = Image.open(path).convert("RGBA")
    arr = np.array(img)
    if "foreground" in path.name:
        mask = arr[:, :, 3] > 10
    else:
        mask = _content_mask(img)
    ys, xs = np.where(mask)
    print(
        f"{label}: bounds=({xs.min()}, {ys.min()})-({xs.max()}, {ys.max()}), "
        f"center=({(xs.min() + xs.max()) / 2:.0f}, {(ys.min() + ys.max()) / 2:.0f})"
    )


def main() -> None:
    source = Image.open(SOURCE_PATH).convert("RGBA")
    symbol_box = _detect_symbol_box(source)
    symbol = _trim_background(source.crop(symbol_box))

    icon = _center_on_canvas(symbol, background=BG_COLOR)
    icon.convert("RGB").save(ICON_PATH, "PNG")
    print(f"Saved icon: {ICON_PATH}")

    foreground = _make_foreground(symbol)
    foreground.save(FOREGROUND_PATH, "PNG")
    print(f"Saved foreground: {FOREGROUND_PATH}")

    _report_bounds(ICON_PATH, "icon")
    _report_bounds(FOREGROUND_PATH, "foreground")


if __name__ == "__main__":
    main()
