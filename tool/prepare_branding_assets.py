"""Generate cropped launcher icon and splash assets from art_port_logo.png."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art_port_logo.png"
OUT_DIR = ROOT / "assets" / "branding"
ADAPTIVE_ICON_XML = (
    ROOT / "android" / "app" / "src" / "main" / "res" / "mipmap-anydpi-v26" / "ic_launcher.xml"
)

CREAM = (253, 251, 247, 255)
WHITE = (255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)
ICON_SIZE = 1024
SPLASH_LOGO_MAX_RATIO = 0.63
ICON_LOGO_MAX_RATIO = 0.86
ADAPTIVE_FOREGROUND_RATIO = 0.86
ICON_CORNER_RADIUS_RATIO = 0.22
TRIM_THRESHOLD = 48
TRIM_PADDING_RATIO = 0.008
BACKGROUND_MATCH_THRESHOLD = 44
SQUARE_PADDING_RATIO = 0.03
ADAPTIVE_ICON_INSET = "2%"


def _color_distance(pixel: tuple[int, ...], target: tuple[int, int, int]) -> float:
    r, g, b = pixel[:3]
    tr, tg, tb = target
    return ((r - tr) ** 2 + (g - tg) ** 2 + (b - tb) ** 2) ** 0.5


def _estimate_background_color(img: Image.Image) -> tuple[int, int, int]:
    rgba = img.convert("RGBA")
    width, height = rgba.size
    samples = [
        rgba.getpixel((0, 0)),
        rgba.getpixel((width - 1, 0)),
        rgba.getpixel((0, height - 1)),
        rgba.getpixel((width - 1, height - 1)),
        rgba.getpixel((width // 2, 0)),
        rgba.getpixel((width // 2, height - 1)),
    ]
    return (
        sum(sample[0] for sample in samples) // len(samples),
        sum(sample[1] for sample in samples) // len(samples),
        sum(sample[2] for sample in samples) // len(samples),
    )


def _is_background_pixel(
    pixel: tuple[int, ...],
    bg_color: tuple[int, int, int],
    threshold: float = TRIM_THRESHOLD,
) -> bool:
    return (
        _color_distance(pixel, bg_color) <= threshold
        or _color_distance(pixel, CREAM[:3]) <= threshold
        or _color_distance(pixel, WHITE) <= threshold
    )


def _is_foreground_pixel(
    pixel: tuple[int, int, int, int],
    bg_color: tuple[int, int, int],
) -> bool:
    r, g, b, a = pixel
    if a < 24:
        return False
    if _is_background_pixel((r, g, b), bg_color, threshold=BACKGROUND_MATCH_THRESHOLD):
        return False
    return True


def _foreground_bbox(
    img: Image.Image,
) -> tuple[int, int, int, int] | None:
    rgba = img.convert("RGBA")
    bg_color = _estimate_background_color(rgba)
    pixels = rgba.load()
    left, top, right, bottom = rgba.width, rgba.height, 0, 0
    found = False

    for y in range(rgba.height):
        for x in range(rgba.width):
            if _is_foreground_pixel(pixels[x, y], bg_color):
                found = True
                left = min(left, x)
                top = min(top, y)
                right = max(right, x)
                bottom = max(bottom, y)

    if not found:
        return None
    return left, top, right, bottom


def _content_centroid(img: Image.Image) -> tuple[float, float] | None:
    rgba = img.convert("RGBA")
    bg_color = _estimate_background_color(rgba)
    pixels = rgba.load()
    sum_x = 0.0
    sum_y = 0.0
    sum_weight = 0.0

    for y in range(rgba.height):
        for x in range(rgba.width):
            pixel = pixels[x, y]
            if not _is_foreground_pixel(pixel, bg_color):
                continue
            weight = pixel[3] / 255.0
            sum_x += x * weight
            sum_y += y * weight
            sum_weight += weight

    if sum_weight == 0:
        return None
    return sum_x / sum_weight, sum_y / sum_weight


def trim_to_content(img: Image.Image) -> Image.Image:
    """Crop textured cream/white margins around the logo."""
    rgba = img.convert("RGBA")
    width, height = rgba.size
    bg_color = _estimate_background_color(rgba)
    pixels = rgba.load()

    left, top, right, bottom = width, height, 0, 0
    found = False
    for y in range(height):
        for x in range(width):
            if not _is_background_pixel(pixels[x, y], bg_color):
                found = True
                left = min(left, x)
                top = min(top, y)
                right = max(right, x)
                bottom = max(bottom, y)

    if not found:
        return rgba

    pad_x = int((right - left) * TRIM_PADDING_RATIO)
    pad_y = int((bottom - top) * TRIM_PADDING_RATIO)
    left = max(0, left - pad_x)
    top = max(0, top - pad_y)
    right = min(width - 1, right + pad_x)
    bottom = min(height - 1, bottom + pad_y)
    return rgba.crop((left, top, right + 1, bottom + 1))


def _alignment_point(img: Image.Image) -> tuple[float, float] | None:
    """Horizontal bbox center + vertical visual centroid for balanced centering."""
    centroid = _content_centroid(img)
    bbox = _foreground_bbox(img)
    if centroid is None or bbox is None:
        return None

    left, top, right, bottom = bbox
    align_x = (left + right) / 2
    align_y = centroid[1]
    return align_x, align_y


def recenter_on_square(
    img: Image.Image,
    background: tuple[int, int, int, int],
) -> Image.Image:
    """Place the logo so its alignment point sits on a square canvas center."""
    rgba = img.convert("RGBA")
    alignment = _alignment_point(rgba)
    bbox = _foreground_bbox(rgba)
    if alignment is None or bbox is None:
        return rgba

    left, top, right, bottom = bbox
    bbox_width = right - left + 1
    bbox_height = bottom - top + 1
    side = max(bbox_width, bbox_height)
    side = int(side * (1 + SQUARE_PADDING_RATIO))
    side = max(side, bbox_width, bbox_height)

    square = Image.new("RGBA", (side, side), background)
    offset_x = int(round((side / 2) - alignment[0]))
    offset_y = int(round((side / 2) - alignment[1]))
    square.paste(rgba, (offset_x, offset_y), rgba)
    return square


def _replace_background(
    img: Image.Image,
    fill: tuple[int, int, int, int],
    transparent: bool,
) -> Image.Image:
    """Normalize paper texture to a single background color or transparency."""
    rgba = img.convert("RGBA")
    pixels = rgba.load()

    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            is_bg = a < 24 or _is_background_pixel(
                (r, g, b),
                CREAM[:3],
                threshold=BACKGROUND_MATCH_THRESHOLD,
            )
            if is_bg:
                if transparent:
                    pixels[x, y] = (0, 0, 0, 0)
                else:
                    pixels[x, y] = fill
    return rgba


def _fit_on_canvas(
    content: Image.Image,
    canvas_size: int,
    max_ratio: float,
    background: tuple[int, int, int, int],
    *,
    center_geometrically: bool = False,
) -> Image.Image:
    canvas = Image.new("RGBA", (canvas_size, canvas_size), background)
    max_side = int(canvas_size * max_ratio)
    logo = content.copy()
    logo.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)

    if center_geometrically or content.width == content.height:
        offset = (
            (canvas_size - logo.width) // 2,
            (canvas_size - logo.height) // 2,
        )
    else:
        alignment = _alignment_point(logo)
        if alignment is None:
            offset = (
                (canvas_size - logo.width) // 2,
                (canvas_size - logo.height) // 2,
            )
        else:
            orig_w, orig_h = content.size
            scale = min(logo.width / orig_w, logo.height / orig_h)
            scaled_align_x = alignment[0] * scale
            scaled_align_y = alignment[1] * scale
            offset = (
                int(round((canvas_size / 2) - scaled_align_x)),
                int(round((canvas_size / 2) - scaled_align_y)),
            )

    canvas.paste(logo, offset, logo)
    return canvas


def _rounded_rectangle_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def create_launcher_icon(content: Image.Image) -> Image.Image:
    """Square icon with uniform cream background and rounded corners."""
    logo = _replace_background(content, TRANSPARENT, transparent=True)
    centered = recenter_on_square(logo, TRANSPARENT)
    normalized = _replace_background(centered, CREAM, transparent=False)
    base = _fit_on_canvas(
        normalized,
        ICON_SIZE,
        ICON_LOGO_MAX_RATIO,
        CREAM,
        center_geometrically=True,
    )
    radius = int(ICON_SIZE * ICON_CORNER_RADIUS_RATIO)
    mask = _rounded_rectangle_mask(ICON_SIZE, radius)
    rounded = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), CREAM)
    rounded.paste(base, (0, 0), mask)
    return rounded.convert("RGB")


def create_adaptive_foreground(content: Image.Image) -> Image.Image:
    """Transparent foreground for Android adaptive icons."""
    logo = _replace_background(content, TRANSPARENT, transparent=True)
    centered = recenter_on_square(logo, TRANSPARENT)
    return _fit_on_canvas(
        centered,
        ICON_SIZE,
        ADAPTIVE_FOREGROUND_RATIO,
        TRANSPARENT,
        center_geometrically=True,
    )


def create_splash_logo(content: Image.Image) -> Image.Image:
    """Centered logo with transparent background for seamless splash blending."""
    logo = _replace_background(content, TRANSPARENT, transparent=True)
    return _fit_on_canvas(
        logo,
        ICON_SIZE,
        SPLASH_LOGO_MAX_RATIO,
        TRANSPARENT,
    )


def patch_adaptive_icon_inset(inset: str = ADAPTIVE_ICON_INSET) -> None:
    """Reduce Android adaptive icon inset so the logo appears larger."""
    if not ADAPTIVE_ICON_XML.exists():
        print(f"Skip inset patch; file not found: {ADAPTIVE_ICON_XML}")
        return

    xml = ADAPTIVE_ICON_XML.read_text(encoding="utf-8")
    updated = re.sub(
        r'android:inset="[^"]*"',
        f'android:inset="{inset}"',
        xml,
        count=1,
    )
    ADAPTIVE_ICON_XML.write_text(updated, encoding="utf-8")
    print(f"Patched adaptive icon inset to {inset}")


def _report_alignment(path: Path, label: str) -> None:
    img = Image.open(path).convert("RGBA")
    alignment = _alignment_point(img)
    bbox = _foreground_bbox(img)
    if alignment is None or bbox is None:
        return
    center = img.width / 2, img.height / 2
    margin_left = bbox[0]
    margin_right = img.width - 1 - bbox[2]
    print(
        f"{label} align=({alignment[0]:.1f}, {alignment[1]:.1f}) "
        f"canvas_center=({center[0]:.1f}, {center[1]:.1f}) "
        f"delta=({alignment[0]-center[0]:+.1f}, {alignment[1]-center[1]:+.1f}) "
        f"margins(L/R)={margin_left}/{margin_right}"
    )


def generate_assets() -> None:
    if not SRC.exists():
        raise SystemExit(f"Source logo not found: {SRC}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SRC)
    cropped = trim_to_content(source)

    icon_path = OUT_DIR / "art_port_icon.png"
    foreground_path = OUT_DIR / "art_port_icon_foreground.png"
    splash_path = OUT_DIR / "art_port_splash_logo.png"

    create_launcher_icon(cropped).save(icon_path, optimize=True)
    create_adaptive_foreground(cropped).save(foreground_path, optimize=True)
    create_splash_logo(cropped).save(splash_path, optimize=True)

    print(f"Wrote {icon_path}")
    print(f"Wrote {foreground_path}")
    print(f"Wrote {splash_path}")
    print(
        "Crop ratios: "
        f"icon={ICON_LOGO_MAX_RATIO:.0%}, "
        f"adaptive={ADAPTIVE_FOREGROUND_RATIO:.0%}, "
        f"splash={SPLASH_LOGO_MAX_RATIO:.0%}"
    )
    _report_alignment(icon_path, "icon")
    _report_alignment(foreground_path, "adaptive_foreground")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--patch-adaptive-inset",
        action="store_true",
        help="Patch Android adaptive icon inset after flutter_launcher_icons runs.",
    )
    args = parser.parse_args()

    if args.patch_adaptive_inset:
        patch_adaptive_icon_inset()
        return

    generate_assets()


if __name__ == "__main__":
    main()
