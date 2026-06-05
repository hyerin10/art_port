"""로그인 화면용 ArtPort 로고 — 콘텐츠 기준 대칭 여백으로 재정렬."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "assets" / "branding" / "art_port_icon_source.png"
OUTPUT_PATH = ROOT / "assets" / "branding" / "art_port_auth_logo.png"


def _content_mask(img: Image.Image) -> np.ndarray:
    arr = np.array(img.convert("RGBA"))
    alpha = arr[:, :, 3] > 20
    bg = np.array([253, 251, 247])
    non_bg = np.abs(arr[:, :, :3].astype(int) - bg).sum(axis=2) > 30
    return alpha | non_bg


def _center_content(img: Image.Image, *, padding_ratio: float = 0.08) -> Image.Image:
    mask = _content_mask(img)
    rows = np.where(mask.any(axis=1))[0]
    cols = np.where(mask.any(axis=0))[0]
    cropped = img.crop((int(cols[0]), int(rows[0]), int(cols[-1]) + 1, int(rows[-1]) + 1))

    pad = max(int(max(cropped.size) * padding_ratio), 24)
    canvas = Image.new(
        "RGBA",
        (cropped.width + pad * 2, cropped.height + pad * 2),
        (255, 255, 255, 0),
    )
    canvas.paste(cropped, (pad, pad), cropped)
    return canvas


def main() -> None:
    source = Image.open(SOURCE_PATH).convert("RGBA")
    centered = _center_content(source)

    arr = np.array(centered)
    mask = arr[:, :, 3] > 20
    ys, xs = np.where(mask)
    content_cx = (xs.min() + xs.max()) / 2
    canvas_cx = centered.width / 2
    print(f"Saved: {OUTPUT_PATH}")
    print(f"size={centered.size}, content_center_x={content_cx:.1f}, canvas_center_x={canvas_cx:.1f}")

    centered.save(OUTPUT_PATH, "PNG")


if __name__ == "__main__":
    main()
