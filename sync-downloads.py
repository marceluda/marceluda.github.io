#!/usr/bin/env python3
"""Arma el índice de paquetes de Red Pitaya publicados en redpitaya/downloads/.

Uso:  python3 sync-downloads.py

Genera:
  _data/downloads.json                    -> tabla de https://marceluda.github.io/redpitaya/downloads/
                                             (una entrada por App y versión, con sus archivos y md5sum)
  redpitaya/downloads/last_stables.txt    -> la versión más nueva de cada App: "archivo<TAB>url" por fila

Nombre esperado: <app>-<X.Y.Z>-<build>-devbuild.{zip,tar.gz}. Los archivos sin "-devbuild"
(rp_dummy.zip) quedan con su nombre como App y sin versión. Se ignoran _DEBUG y _RELOAD.
Orden: App alfabética (prefijo del archivo); dentro de cada App, versión numérica de la más nueva
a la más vieja (X, Y, Z y build como números).
Correrlo cada vez que se agregan o borran paquetes de redpitaya/downloads/.
"""
import hashlib
import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent
DIR = REPO / "redpitaya/downloads"
URL = "https://marceluda.github.io/redpitaya/downloads/"
PATRON = re.compile(r"^(?P<app>.+)-(?P<ver>\d+(?:\.\d+)*)-(?P<build>\d+)-devbuild\.(?P<ext>zip|tar\.gz)$")


def md5(path):
    h = hashlib.md5()
    with path.open("rb") as f:
        for bloque in iter(lambda: f.read(1 << 20), b""):
            h.update(bloque)
    return h.hexdigest()


def main():
    versiones = {}
    for p in sorted(DIR.iterdir()):
        if not p.is_file() or not p.name.endswith((".zip", ".tar.gz")):
            continue
        if "_DEBUG" in p.name or "_RELOAD" in p.name:
            continue
        m = PATRON.match(p.name)
        if m:
            app, ver, build = m["app"], m["ver"], int(m["build"])
            clave = (app, tuple(int(n) for n in ver.split(".")), build)
            version = f"{ver}-{build}"
        else:
            app = p.name.removesuffix(".tar.gz").removesuffix(".zip")
            clave, version = (app, (), 0), ""
        v = versiones.setdefault(clave, {"name": app, "version": version, "files": []})
        v["files"].append({"file": p.name, "md5": md5(p)})

    # tar.gz antes que zip dentro de cada versión, como en los badges de la web.
    for v in versiones.values():
        v["files"].sort(key=lambda f: (not f["file"].endswith(".tar.gz"), f["file"]))

    # Primero (versión, build) de mayor a menor, comparando tuplas de enteros (2.2.18 > 2.2.9);
    # después por App, que como el orden es estable conserva el de las versiones dentro de cada App.
    orden = sorted(versiones, key=lambda c: (c[1], c[2]), reverse=True)
    orden = sorted(orden, key=lambda c: c[0])
    tabla = [versiones[c] for c in orden]

    (REPO / "_data/downloads.json").write_text(
        json.dumps(tabla, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    ultimas, vistas = [], set()
    for v in tabla:
        if v["name"] in vistas:
            continue
        vistas.add(v["name"])
        ultimas += [f"{f['file']}\t{URL}{f['file']}" for f in v["files"]]
    (DIR / "last_stables.txt").write_text("\n".join(ultimas) + "\n", encoding="utf-8")

    print(f"{len(tabla)} versiones de {len(vistas)} Apps; last_stables.txt con {len(ultimas)} archivos")


if __name__ == "__main__":
    main()
