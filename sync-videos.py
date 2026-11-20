#!/usr/bin/env python3
"""Copia el catálogo de videos de divulgación al sitio.

Uso:  python3 sync-videos.py [CARPETA_DEL_CATALOGO]

Lee del catálogo (por defecto ~/Dropbox/marce/Archivo_Ciencia/Divulgación/videos):
  data/index.json         -> _data/videos.json
  Tags.md                 -> _data/video_tags.json (grupos y tags en uso, con su cantidad)
  data/<ID>/preview.png   -> apuntes/videos/img/<ID>.jpg (480x270, JPEG)
No copia video.mp4, subtítulos, descripcion.txt ni thumbnail.jpg (no se publican).
Borra de apuntes/videos/img/ las imágenes de videos que ya no están en el catálogo.
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parent
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else \
    Path.home() / "Dropbox/marce/Archivo_Ciencia/Divulgación/videos"
IMG = REPO / "apuntes/videos/img"
GRUPOS_EN = {"Áreas": "Areas", "Temas": "Topics", "Formato": "Format"}
CAMPOS = ["id", "title", "author", "date", "url", "language", "duration", "description", "tags"]


def leer_tags(path):
    """Devuelve [(grupo, [(es, en), ...]), ...] en el orden de Tags.md."""
    grupos = []
    for linea in path.read_text(encoding="utf-8").splitlines():
        if linea.startswith("## "):
            grupos.append((linea[3:].strip(), []))
            continue
        m = re.match(r"\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$", linea)
        if m and grupos and m.group(1) not in ("es",) and not set(m.group(1)) <= set("-"):
            grupos[-1][1].append((m.group(1), m.group(2)))
    return grupos


def main():
    videos = json.loads((SRC / "data/index.json").read_text(encoding="utf-8"))
    salida = []
    IMG.mkdir(parents=True, exist_ok=True)
    for v in videos:
        png = SRC / "data" / v["id"] / "preview.png"
        if not png.exists():
            sys.exit(f"Falta {png}")
        jpg = IMG / f"{v['id']}.jpg"
        if not jpg.exists() or jpg.stat().st_mtime < png.stat().st_mtime:
            Image.open(png).convert("RGB").save(jpg, "JPEG", quality=82, optimize=True, progressive=True)
        salida.append({k: v.get(k) for k in CAMPOS})

    ids = {v["id"] for v in videos}
    for jpg in IMG.glob("*.jpg"):
        if jpg.stem not in ids:
            jpg.unlink()
            print(f"Borrada {jpg.relative_to(REPO)} (ya no está en el catálogo)")

    cuenta = Counter(t for v in videos for t in v["tags"]["es"])
    grupos = []
    for nombre, tags in leer_tags(SRC / "Tags.md"):
        usados = [{"es": es, "en": en, "n": cuenta[es]} for es, en in tags if cuenta[es]]
        usados.sort(key=lambda t: (-t["n"], t["es"].lower()))
        if usados:
            grupos.append({"es": nombre, "en": GRUPOS_EN.get(nombre, nombre), "tags": usados})
    sin_grupo = set(cuenta) - {t["es"] for g in grupos for t in g["tags"]}
    if sin_grupo:
        sys.exit(f"Tags usados que no están en Tags.md: {sorted(sin_grupo)}")

    (REPO / "_data/videos.json").write_text(
        json.dumps(salida, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    (REPO / "_data/video_tags.json").write_text(
        json.dumps(grupos, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"{len(salida)} videos, {len(cuenta)} tags en {len(grupos)} grupos")


if __name__ == "__main__":
    main()
