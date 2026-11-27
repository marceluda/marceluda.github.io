#!/usr/bin/env bash
#
# Installer of the Red Pitaya Apps of marceluda (Linux).
#
#   bash <(curl -fsSL https://marceluda.github.io/redpitaya/install_rp_apps.sh) [options]
#   ./install_rp_apps.sh [options]
#
# Options:
#   --rp ADDRESS   Red Pitaya address: rp-xxxxxx.local, an IP, or a browser URL (http://rp-xxxxxx.local/)
#   --all          install all the published Apps (no selection menu)
#   --force        replace the Apps that already exist on the Red Pitaya
#   --only-new     install only the Apps that do not exist on the Red Pitaya
#   --port N       SSH port (default 22)
#   --no-restart   do not restart the web server of the Red Pitaya at the end
#   -h, --help     this help
#
# What it does:
#   1. Reads the list of the last stable versions (last_stables.txt) of the web page.
#   2. Lets the user choose the Apps (all selected by default) and the Red Pitaya address.
#   3. Downloads the .tar.gz of each App to ./Apps_marceluda_temp/ (skipped if already there).
#   4. Connects by SSH (offers to create / copy an SSH key so the password is typed only once).
#   5. Uploads each package, unpacks it on the Red Pitaya in /opt/redpitaya/www/apps/<App>/.
#   6. Restarts the web server of the Red Pitaya if an App's nginx.conf is new or changed.
#   7. Lists the installed Apps.
#
# Only standard tools are needed: bash, ssh, scp (OpenSSH) and curl or wget.

set -u

STABLES_URL="https://marceluda.github.io/redpitaya/downloads/last_stables.txt"
DL_DIR="Apps_marceluda_temp"
APPS_DIR="/opt/redpitaya/www/apps"
REMOTE_TMP="/tmp/marceluda_installer"

# ---- Messages: Spanish when LANG is es_*, English otherwise -----------------------------------
L=0
[[ "${LANG:-}" == es* || "${LC_ALL:-}" == es* ]] && L=1
t() { if [ $L -eq 1 ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }
say() { printf '%b\n' "$(t "$1" "$2")"; }
die() { printf '\n\033[31m%b\033[0m\n\n' "$(t "$1" "$2")" >&2; cleanup; exit 1; }

B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; C=$'\033[36m'; N=$'\033[0m'
[ -t 1 ] || { B=; G=; Y=; C=; N=; }

usage() {
  sed -n '2,24p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//' || true
}

# ---- Arguments ----------------------------------------------------------------------------------
RP_ADDR=""; OPT_ALL=0; OPT_FORCE=0; OPT_ONLYNEW=0; PORT=22; NO_RESTART=0; ANY_ARG=0
while [ $# -gt 0 ]; do
  ANY_ARG=1
  case "$1" in
    --rp)        RP_ADDR="${2:-}"; shift ;;
    --rp=*)      RP_ADDR="${1#--rp=}" ;;
    --all)       OPT_ALL=1 ;;
    --force)     OPT_FORCE=1 ;;
    --only-new)  OPT_ONLYNEW=1 ;;
    --port)      PORT="${2:-22}"; shift ;;
    --port=*)    PORT="${1#--port=}" ;;
    --no-restart) NO_RESTART=1 ;;
    -h|--help)   usage; exit 0 ;;
    *) printf '%s: %s\n' "$(t "Unknown option" "Opción desconocida")" "$1"; usage; exit 1 ;;
  esac
  shift
done
if [ $OPT_FORCE -eq 1 ] && [ $OPT_ONLYNEW -eq 1 ]; then
  say "--force and --only-new cannot be used together." "--force y --only-new no se pueden usar juntos."
  exit 1
fi

# ---- Address: host name, IP or URL copied from the browser -------------------------------------
parse_address() {
  local a="$1"
  a="${a#"${a%%[![:space:]]*}"}"; a="${a%"${a##*[![:space:]]}"}"   # trim
  a="${a#*://}"            # http://, https://
  a="${a%%/*}"             # path
  a="${a%%\?*}"; a="${a%%#*}"
  a="${a##*@}"             # user@
  if [[ "$a" == \[*\]* ]]; then a="${a#[}"; a="${a%%]*}"     # [IPv6]:port
  elif [[ "$a" == *:*:* ]]; then :                            # bare IPv6
  else a="${a%%:*}"; fi                                       # host:port (web port, not SSH)
  printf '%s' "$a"
}

# ---- Temporary files and the shared SSH connection ---------------------------------------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/rpinst.XXXXXX")"
CTRL="$WORK/cm-%C"
cleanup() {
  if [ -n "${RP:-}" ]; then ssh -o ControlPath="$CTRL" -O exit "root@$RP" >/dev/null 2>&1 || true; fi
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'printf "\n"; exit 130' INT

# ---- Required tools ----------------------------------------------------------------------------
install_hint() {
  local pkgs="$1"
  if   command -v apt-get >/dev/null; then echo "  sudo apt install $pkgs"
  elif command -v dnf     >/dev/null; then echo "  sudo dnf install ${pkgs/openssh-client/openssh-clients}"
  elif command -v yum     >/dev/null; then echo "  sudo yum install ${pkgs/openssh-client/openssh-clients}"
  elif command -v pacman  >/dev/null; then echo "  sudo pacman -S ${pkgs/openssh-client/openssh}"
  elif command -v zypper  >/dev/null; then echo "  sudo zypper install ${pkgs/openssh-client/openssh-clients}"
  else echo "  ($pkgs)"; fi
}
missing=""
command -v ssh >/dev/null && command -v scp >/dev/null || missing="openssh-client"
if command -v curl >/dev/null; then DL=curl
elif command -v wget >/dev/null; then DL=wget
else missing="$missing curl"; fi
if [ -n "$missing" ]; then
  say "Missing tools. Install them with:" "Faltan herramientas. Instalalas con:"
  install_hint "${missing# }"
  exit 1
fi

fetch_text() { if [ $DL = curl ]; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }
fetch_file() {  # url dest   (progress bar of curl / wget)
  if [ $DL = curl ]; then curl -fL --progress-bar -o "$2" "$1"
  else wget -q --show-progress -O "$2" "$1"; fi
}

# ---- Progress bar (over all the Apps) ----------------------------------------------------------
bar() {   # done total label
  local d=$1 n=$2 w=40 p f
  [ "$n" -gt 0 ] || n=1
  p=$(( d * 100 / n )); f=$(( d * w / n ))
  printf '\r  [%s%s] %3d%%  %-40.40s' \
    "$(printf '%*s' "$f" '' | tr ' ' '#')" "$(printf '%*s' $((w - f)) '' | tr ' ' '.')" "$p" "$3"
}

echo
printf '%s\n' "${B}Red Pitaya Apps - marceluda${N}"
echo

# ---- 1. Published Apps -------------------------------------------------------------------------
say "Reading the list of Apps from $STABLES_URL ..." "Leyendo la lista de Apps de $STABLES_URL ..."
LIST="$(fetch_text "$STABLES_URL")" || die "Could not read the list of Apps (no internet?)." \
                                           "No se pudo leer la lista de Apps (¿sin internet?)."
NAMES=(); VERS=(); FILES=(); URLS=()
while IFS=$'\t ' read -r file url _; do
  [[ "$file" == *.tar.gz ]] || continue
  base="${file%.tar.gz}"
  if [[ "$base" =~ ^(.+)-([0-9][^-]*-[0-9]+)(-devbuild)?$ ]]; then
    NAMES+=("${BASH_REMATCH[1]}"); VERS+=("${BASH_REMATCH[2]}")
  else
    NAMES+=("$base"); VERS+=("?")
  fi
  FILES+=("$file"); URLS+=("$url")
done <<< "$LIST"
NA=${#NAMES[@]}
[ "$NA" -gt 0 ] || die "The list of Apps is empty." "La lista de Apps está vacía."

SEL=(); for ((i = 0; i < NA; i++)); do SEL+=(1); done

# ---- 2. Selection menu and address (when no option was given) ---------------------------------
read_tty() { local __v; IFS= read -r __v < /dev/tty || __v=""; printf '%s' "$__v"; }

if [ $OPT_ALL -eq 0 ]; then
  while true; do
    echo
    say "${B}Available Apps${N} (all selected by default):" "${B}Apps disponibles${N} (todas seleccionadas por defecto):"
    for ((i = 0; i < NA; i++)); do
      if [ "${SEL[$i]}" -eq 1 ]; then m="${G}[x]${N}"; else m="[ ]"; fi
      printf '  %2d) %b %-28s %s\n' $((i + 1)) "$m" "${NAMES[$i]}" "${VERS[$i]}"
    done
    echo
    printf '%s' "$(t "Numbers to select/unselect (e.g. 1 3), a = all, n = none, Enter = next: " \
                     "Números para marcar/desmarcar (ej. 1 3), a = todas, n = ninguna, Enter = siguiente: ")"
    ans="$(read_tty)"
    case "$ans" in
      "") break ;;
      a|A) for ((i = 0; i < NA; i++)); do SEL[$i]=1; done ;;
      n|N) for ((i = 0; i < NA; i++)); do SEL[$i]=0; done ;;
      *) for k in ${ans//,/ }; do
           if [[ "$k" =~ ^[0-9]+$ ]] && [ "$k" -ge 1 ] && [ "$k" -le "$NA" ]; then
             SEL[$((k - 1))]=$(( 1 - SEL[k - 1] ))
           fi
         done ;;
    esac
  done
fi

IDX=(); for ((i = 0; i < NA; i++)); do [ "${SEL[$i]}" -eq 1 ] && IDX+=("$i"); done
[ ${#IDX[@]} -gt 0 ] || { say "No App selected. Nothing to do." "Ninguna App seleccionada. Nada para hacer."; exit 0; }

while [ -z "$RP_ADDR" ]; do
  echo
  printf '%s' "$(t "Red Pitaya address (e.g. rp-f00a3b.local, 192.168.1.100 or http://rp-f00a3b.local/): " \
                   "Dirección de la Red Pitaya (ej. rp-f00a3b.local, 192.168.1.100 o http://rp-f00a3b.local/): ")"
  RP_ADDR="$(read_tty)"
done
RP="$(parse_address "$RP_ADDR")"
[ -n "$RP" ] || die "Invalid address: $RP_ADDR" "Dirección inválida: $RP_ADDR"
echo
say "Red Pitaya: ${B}$RP${N}" "Red Pitaya: ${B}$RP${N}"

# ---- 3. Downloads ------------------------------------------------------------------------------
mkdir -p "$DL_DIR" || die "Cannot create $DL_DIR" "No se puede crear $DL_DIR"
echo
say "${B}Downloading${N} to ./$DL_DIR/" "${B}Descargando${N} en ./$DL_DIR/"
for i in "${IDX[@]}"; do
  f="$DL_DIR/${FILES[$i]}"
  if [ -s "$f" ]; then
    printf '  %-45s %s\n' "${FILES[$i]}" "$(t "already downloaded" "ya descargado")"
    continue
  fi
  printf '  %s\n' "${FILES[$i]}"
  fetch_file "${URLS[$i]}" "$f.part" && mv "$f.part" "$f" || {
    rm -f "$f.part"; die "Download failed: ${URLS[$i]}" "Falló la descarga: ${URLS[$i]}"; }
done

# ---- 4. SSH connection (one password at most) --------------------------------------------------
SSHO=(-p "$PORT" -o ControlMaster=auto -o ControlPath="$CTRL" -o ControlPersist=300
      -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10)
SCPO=(-P "$PORT" -o ControlMaster=auto -o ControlPath="$CTRL" -o ControlPersist=300
      -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10)
rssh() { ssh "${SSHO[@]}" "root@$RP" "$@"; }

echo
say "${B}SSH connection${N} to root@$RP" "${B}Conexión SSH${N} a root@$RP"
if ssh -p "$PORT" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
       "root@$RP" true 2>/dev/null; then
  say "  SSH key already accepted by the Red Pitaya." "  La Red Pitaya ya acepta tu llave SSH."
else
  KEY=""
  for k in id_ed25519 id_ecdsa id_rsa; do [ -f "$HOME/.ssh/$k.pub" ] && { KEY="$HOME/.ssh/$k"; break; }; done
  if [ -z "$KEY" ]; then
    printf '%s' "$(t "  You have no SSH key. Create one so that the password is not asked again? [Y/n] " \
                     "  No tenés una llave SSH. ¿Crear una para no tener que tipear la clave de nuevo? [S/n] ")"
    a="$(read_tty)"
    if [[ ! "$a" =~ ^[nN] ]]; then
      mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
      ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" && KEY="$HOME/.ssh/id_ed25519"
    fi
  fi
  if [ -n "$KEY" ] && command -v ssh-copy-id >/dev/null; then
    say "  Copying your SSH key to the Red Pitaya (password of root; by default it is ${B}root${N}):" \
        "  Copiando tu llave SSH a la Red Pitaya (clave de root; por defecto es ${B}root${N}):"
    ssh-copy-id -p "$PORT" -o StrictHostKeyChecking=accept-new -i "$KEY.pub" "root@$RP" >/dev/null 2>&1 </dev/tty \
      || ssh-copy-id -p "$PORT" -i "$KEY.pub" "root@$RP" </dev/tty \
      || say "  ${Y}Could not copy the key; the password will be asked once.${N}" \
             "  ${Y}No se pudo copiar la llave; se pedirá la clave una vez.${N}"
  else
    say "  The password of root will be asked once (by default it is ${B}root${N})." \
        "  Se pedirá la clave de root una vez (por defecto es ${B}root${N})."
  fi
fi
# Open the shared connection (the only point where a password may be asked)
rssh true </dev/tty || die "Cannot connect to root@$RP by SSH." "No se puede conectar por SSH a root@$RP."

# Apps already on the board: folder<TAB>version
EXIST="$(rssh "cd $APPS_DIR 2>/dev/null && for d in */; do d=\${d%/}; [ -f \"\$d/info/info.json\" ] || continue; \
  v=\$(grep -o '\"version\"[^,}]*' \"\$d/info/info.json\" | head -1 | sed 's/.*: *\"//; s/\".*//'); printf '%s\t%s\n' \"\$d\" \"\$v\"; done")" \
  || die "Cannot read $APPS_DIR on the Red Pitaya." "No se puede leer $APPS_DIR en la Red Pitaya."
existing_version() { printf '%s\n' "$EXIST" | awk -F'\t' -v a="$1" '$1 == a { print $2; f = 1 } END { if (!f) exit 1 }'; }

# ---- 5. Replace or skip the Apps that already exist --------------------------------------------
TODO=(); REPLACE_ALL=$OPT_FORCE
for i in "${IDX[@]}"; do
  name="${NAMES[$i]}"
  if old="$(existing_version "$name")"; then
    if [ $OPT_ONLYNEW -eq 1 ]; then
      printf '  %-28s %s\n' "$name" "$(t "exists ($old): skipped (--only-new)" "existe ($old): se omite (--only-new)")"
      continue
    fi
    if [ $REPLACE_ALL -eq 0 ]; then
      while true; do
        printf '  %s' "$(t "${B}$name${N} already exists (installed $old, new ${VERS[$i]}). Replace? [y]es / [n]o / replace [a]ll: " \
                           "${B}$name${N} ya existe (instalada $old, nueva ${VERS[$i]}). ¿Reemplazar? [s]í / [n]o / reemplazar [t]odas: ")"
        a="$(read_tty)"
        case "$a" in
          y|Y|s|S|yes|si|sí) break ;;
          a|A|t|T|all|todas) REPLACE_ALL=1; break ;;
          n|N|no) a=skip; break ;;
        esac
      done
      [ "$a" = skip ] && continue
    fi
  fi
  TODO+=("$i")
done
[ ${#TODO[@]} -gt 0 ] || { echo; say "Nothing to install." "Nada para instalar."; exit 0; }

# ---- 6. Upload and install ---------------------------------------------------------------------
# Remote part of one App: unpack the package next to the Apps folder, swap the folders, report
# whether nginx.conf is new or changed (then the web server must be restarted).
REMOTE_INSTALL='
set -e
f="$1"; T='"$REMOTE_TMP"'; A='"$APPS_DIR"'
top=$(tar tzf "$f" | grep -m1 -E "^[^/]+/info/info\.json$" | cut -d/ -f1)
[ -n "$top" ] || { echo "ERR no App folder in $f"; exit 1; }
old=$(md5sum "$A/$top/nginx.conf" 2>/dev/null | cut -d" " -f1 || true)
rm -rf "$A/.inst_$top"; mkdir -p "$A/.inst_$top"
tar xzf "$f" --no-same-owner --no-same-permissions -C "$A/.inst_$top" "$top" 2>/dev/null \
  || tar xzf "$f" -C "$A/.inst_$top" "$top"
rm -rf "$A/$top"; mv "$A/.inst_$top/$top" "$A/$top"; rm -rf "$A/.inst_$top"
chmod 755 "$A/$top/fpga.sh" 2>/dev/null || true
new=$(md5sum "$A/$top/nginx.conf" 2>/dev/null | cut -d" " -f1 || true)
v=$(grep -o "\"version\"[^,}]*" "$A/$top/info/info.json" | head -1 | sed "s/.*: *\"//; s/\".*//")
if [ "$old" != "$new" ]; then echo "OK $top $v NGINX"; else echo "OK $top $v"; fi
rm -f "$f"
sync
'

echo
say "${B}Installing${N} ${#TODO[@]} App(s) on $RP" "${B}Instalando${N} ${#TODO[@]} App(s) en $RP"
rssh "export PATH_REDPITAYA=/opt/redpitaya; if [ -x /opt/redpitaya/sbin/rw ]; then /opt/redpitaya/sbin/rw; else /boot/sbin/rw; fi >/dev/null 2>&1; mkdir -p $REMOTE_TMP" \
  || die "Cannot make the file system of the Red Pitaya writable." "No se puede habilitar la escritura en la Red Pitaya."

TOTAL=0; for i in "${TODO[@]}"; do s=$(stat -c %s "$DL_DIR/${FILES[$i]}"); TOTAL=$((TOTAL + s)); done
DONE=0; NGINX=0; INSTALLED=(); FAILED=()
for i in "${TODO[@]}"; do
  name="${NAMES[$i]}"; f="${FILES[$i]}"; s=$(stat -c %s "$DL_DIR/$f")
  bar "$DONE" "$TOTAL" "$name: $(t upload subiendo)"
  if scp -q "${SCPO[@]}" "$DL_DIR/$f" "root@$RP:$REMOTE_TMP/$f" </dev/null; then
    DONE=$((DONE + s / 2)); bar "$DONE" "$TOTAL" "$name: $(t install instalando)"
    out="$(rssh "bash -s -- '$REMOTE_TMP/$f'" <<< "$REMOTE_INSTALL" 2>&1)"
    DONE=$((DONE + s - s / 2))
    line="$(printf '%s\n' "$out" | grep '^OK ' | tail -1)"
    if [ -n "$line" ]; then
      set -- $line; INSTALLED+=("$2 $3"); [ "${4:-}" = NGINX ] && NGINX=1
    else
      FAILED+=("$name"); printf '\n  %s %s: %s\n' "$(t "ERROR installing" "ERROR instalando")" "$name" "$out"
    fi
  else
    DONE=$((DONE + s)); FAILED+=("$name")
    printf '\n  %s %s\n' "$(t "ERROR uploading" "ERROR subiendo")" "$name"
  fi
  bar "$DONE" "$TOTAL" "$name"
done
bar "$TOTAL" "$TOTAL" "$(t done listo)"; echo
rssh "rm -rf $REMOTE_TMP" || true

# ---- 7. Web server restart (new or changed nginx.conf) -----------------------------------------
if [ $NGINX -eq 1 ]; then
  if [ $NO_RESTART -eq 1 ]; then
    say "\n${Y}An App brings a new web server configuration: restart the Red Pitaya (or its web server) before using it.${N}" \
        "\n${Y}Una App trae configuración nueva del servidor web: reiniciá la Red Pitaya (o su servidor web) antes de usarla.${N}"
  else
    say "\nRestarting the web server of the Red Pitaya (an App brings a new nginx.conf) ..." \
        "\nReiniciando el servidor web de la Red Pitaya (una App trae un nginx.conf nuevo) ..."
    rssh "systemctl restart redpitaya_nginx" || say "  ${Y}Restart failed: reboot the Red Pitaya.${N}" \
                                                     "  ${Y}Falló el reinicio: reiniciá la Red Pitaya.${N}"
  fi
fi

# ---- 8. Summary --------------------------------------------------------------------------------
echo
say "${B}Installed now:${N}" "${B}Instaladas ahora:${N}"
for x in "${INSTALLED[@]}"; do set -- $x; printf '  %b %-28s %-22s http://%s/%s/\n' "${G}✔${N}" "$1" "$2" "$RP" "$1"; done
if [ ${#FAILED[@]} -gt 0 ]; then
  say "${Y}Failed:${N}" "${Y}Fallaron:${N}"
  for x in "${FAILED[@]}"; do printf '  ✘ %s\n' "$x"; done
fi
echo
say "${B}Apps of marceluda on the Red Pitaya:${N}" "${B}Apps de marceluda en la Red Pitaya:${N}"
EXIST="$(rssh "cd $APPS_DIR && for d in */; do d=\${d%/}; [ -f \"\$d/info/info.json\" ] || continue; \
  v=\$(grep -o '\"version\"[^,}]*' \"\$d/info/info.json\" | head -1 | sed 's/.*: *\"//; s/\".*//'); printf '%s\t%s\n' \"\$d\" \"\$v\"; done" 2>/dev/null)"
for ((i = 0; i < NA; i++)); do
  if v="$(existing_version "${NAMES[$i]}")"; then printf '  %-28s %s\n' "${NAMES[$i]}" "$v"; fi
done
echo
say "Open ${C}http://$RP/${N} in the browser to use them." "Abrí ${C}http://$RP/${N} en el navegador para usarlas."
echo
[ ${#FAILED[@]} -eq 0 ]
