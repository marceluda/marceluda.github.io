# Installer of the Red Pitaya Apps of marceluda (Windows, PowerShell 5.1 or 7).
#
#   irm https://marceluda.github.io/redpitaya/install_rp_apps.ps1 | iex
#
# With options:
#   & ([scriptblock]::Create((irm https://marceluda.github.io/redpitaya/install_rp_apps.ps1))) --rp rp-xxxxxx.local --all
#   powershell -ExecutionPolicy Bypass -File install_rp_apps.ps1 --rp rp-xxxxxx.local --all
#
# Options:
#   --rp ADDRESS   Red Pitaya address: rp-xxxxxx.local, an IP, or a browser URL (http://rp-xxxxxx.local/)
#   --all          install all the published Apps (no selection menu)
#   --force        replace the Apps that already exist on the Red Pitaya
#   --only-new     install only the Apps that do not exist on the Red Pitaya
#   --port N       SSH port (default 22)
#   --no-restart   do not restart the web server of the Red Pitaya at the end
#   --help         this help
#
# Needs only what Windows 10 (1809+) / 11 already brings: the OpenSSH client (ssh, scp, ssh-keygen)
# and curl.exe. The packages (.tar.gz) are unpacked on the Red Pitaya, so nothing is unpacked on
# the PC.

function Install-RPApps {
  $StablesUrl = 'https://marceluda.github.io/redpitaya/downloads/last_stables.txt'
  $DlDir      = Join-Path (Get-Location) 'Apps_marceluda_temp'
  $AppsDir    = '/opt/redpitaya/www/apps'
  $RemoteTmp  = '/tmp/marceluda_installer'

  # ---- Messages: Spanish when Windows is in Spanish ----------------------------------------------
  $UseEs = ((Get-Culture).TwoLetterISOLanguageName -eq 'es')
  function T([string]$en, [string]$es) { if ($UseEs) { $es } else { $en } }
  function Say([string]$en, [string]$es, [string]$color = '') {
    if ($color) { Write-Host (T $en $es) -ForegroundColor $color } else { Write-Host (T $en $es) }
  }

  # ---- Arguments -----------------------------------------------------------------------------------
  $RpAddr = ''; $All = $false; $Force = $false; $OnlyNew = $false; $Port = 22; $NoRestart = $false
  for ($i = 0; $i -lt $args.Count; $i++) {
    $a = [string]$args[$i]
    switch -Regex ($a) {
      '^--rp=(.*)$'      { $RpAddr = $Matches[1]; break }
      '^--rp$'           { $i++; $RpAddr = [string]$args[$i]; break }
      '^--all$'          { $All = $true; break }
      '^--force$'        { $Force = $true; break }
      '^--only-new$'     { $OnlyNew = $true; break }
      '^--port=(.*)$'    { $Port = [int]$Matches[1]; break }
      '^--port$'         { $i++; $Port = [int]$args[$i]; break }
      '^--no-restart$'   { $NoRestart = $true; break }
      '^(-h|--help|-\?)$' {
        Write-Host 'Options: --rp ADDRESS  --all  --force  --only-new  --port N  --no-restart'
        return }
      default { Write-Host ((T 'Unknown option: ' 'Opción desconocida: ') + $a) -ForegroundColor Red; return }
    }
  }
  if ($Force -and $OnlyNew) { Say '--force and --only-new cannot be used together.' '--force y --only-new no se pueden usar juntos.' Red; return }

  # ---- Address: host name, IP or URL copied from the browser -------------------------------------
  function Parse-Address([string]$a) {
    $a = $a.Trim()
    $a = $a -replace '^[a-zA-Z][a-zA-Z0-9+.-]*://', ''
    $a = ($a -split '[/?#]')[0]
    $a = ($a -split '@')[-1]
    if ($a -match '^\[(.*)\]') { return $Matches[1] }        # [IPv6]:port
    if (($a.ToCharArray() | Where-Object { $_ -eq ':' }).Count -eq 1) { $a = ($a -split ':')[0] }  # host:port
    return $a
  }

  # ---- Required tools ------------------------------------------------------------------------------
  $ssh = Get-Command ssh.exe -ErrorAction SilentlyContinue
  $scp = Get-Command scp.exe -ErrorAction SilentlyContinue
  if (-not $ssh -or -not $scp) {
    Say 'The OpenSSH client of Windows is missing. Install it in one of these ways:' `
        'Falta el cliente OpenSSH de Windows. Instalalo de una de estas formas:' Yellow
    Say '  - Settings > System > Optional features > Add a feature > "OpenSSH Client"' `
        '  - Configuración > Sistema > Características opcionales > Agregar > "Cliente OpenSSH"'
    Say '  - or, in a PowerShell opened as Administrator:' '  - o, en un PowerShell abierto como Administrador:'
    Write-Host '      Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0'
    return
  }
  $curl = Get-Command curl.exe -ErrorAction SilentlyContinue

  # ---- Progress bar (over all the Apps) ----------------------------------------------------------
  function Bar([double]$done, [double]$total, [string]$label) {
    if ($total -le 0) { $total = 1 }
    $w = 40; $f = [int][math]::Floor($done * $w / $total); $p = [int][math]::Floor($done * 100 / $total)
    $txt = '  [' + ('#' * $f) + ('.' * ($w - $f)) + '] ' + ('{0,3}' -f $p) + '%  ' + $label
    Write-Host ("`r" + $txt.PadRight(100).Substring(0, 100)) -NoNewline
  }

  function Read-Line([string]$prompt) { Write-Host $prompt -NoNewline; return [Console]::ReadLine() }

  Write-Host ''
  Write-Host 'Red Pitaya Apps - marceluda' -ForegroundColor White
  Write-Host ''

  # ---- 1. Published Apps -------------------------------------------------------------------------
  Say "Reading the list of Apps from $StablesUrl ..." "Leyendo la lista de Apps de $StablesUrl ..."
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $list = (Invoke-WebRequest -Uri $StablesUrl -UseBasicParsing).Content
  } catch {
    Say 'Could not read the list of Apps (no internet?).' 'No se pudo leer la lista de Apps (¿sin internet?).' Red; return
  }
  if ($list -is [byte[]]) { $list = [Text.Encoding]::UTF8.GetString($list) }
  $apps = @()
  foreach ($line in ($list -split "`r?`n")) {
    $parts = $line.Trim() -split '\s+'
    if ($parts.Count -lt 2 -or -not $parts[0].EndsWith('.tar.gz')) { continue }
    $base = $parts[0].Substring(0, $parts[0].Length - 7)
    if ($base -match '^(.+)-([0-9][^-]*-[0-9]+)(-devbuild)?$') { $name = $Matches[1]; $ver = $Matches[2] }
    else { $name = $base; $ver = '?' }
    $apps += [pscustomobject]@{ Name = $name; Ver = $ver; File = $parts[0]; Url = $parts[1]; Sel = $true }
  }
  if ($apps.Count -eq 0) { Say 'The list of Apps is empty.' 'La lista de Apps está vacía.' Red; return }

  # ---- 2. Selection menu and address ---------------------------------------------------------------
  if (-not $All) {
    while ($true) {
      Write-Host ''
      Say 'Available Apps (all selected by default):' 'Apps disponibles (todas seleccionadas por defecto):' White
      for ($k = 0; $k -lt $apps.Count; $k++) {
        $m = if ($apps[$k].Sel) { '[x]' } else { '[ ]' }
        $c = if ($apps[$k].Sel) { 'Green' } else { 'Gray' }
        Write-Host ('  {0,2}) {1} {2,-28} {3}' -f ($k + 1), $m, $apps[$k].Name, $apps[$k].Ver) -ForegroundColor $c
      }
      Write-Host ''
      $ans = Read-Line (T 'Numbers to select/unselect (e.g. 1 3), a = all, n = none, Enter = next: ' `
                          'Números para marcar/desmarcar (ej. 1 3), a = todas, n = ninguna, Enter = siguiente: ')
      if ([string]::IsNullOrWhiteSpace($ans)) { break }
      if ($ans -match '^\s*[aA]\s*$') { $apps | ForEach-Object { $_.Sel = $true }; continue }
      if ($ans -match '^\s*[nN]\s*$') { $apps | ForEach-Object { $_.Sel = $false }; continue }
      foreach ($tok in ($ans -split '[\s,]+')) {
        $n = 0
        if ([int]::TryParse($tok, [ref]$n) -and $n -ge 1 -and $n -le $apps.Count) { $apps[$n - 1].Sel = -not $apps[$n - 1].Sel }
      }
    }
  }
  $sel = @($apps | Where-Object { $_.Sel })
  if ($sel.Count -eq 0) { Say 'No App selected. Nothing to do.' 'Ninguna App seleccionada. Nada para hacer.'; return }

  while ([string]::IsNullOrWhiteSpace($RpAddr)) {
    Write-Host ''
    $RpAddr = Read-Line (T 'Red Pitaya address (e.g. rp-f00a3b.local, 192.168.1.100 or http://rp-f00a3b.local/): ' `
                           'Dirección de la Red Pitaya (ej. rp-f00a3b.local, 192.168.1.100 o http://rp-f00a3b.local/): ')
  }
  $RP = Parse-Address $RpAddr
  if (-not $RP) { Say "Invalid address: $RpAddr" "Dirección inválida: $RpAddr" Red; return }
  Write-Host ''
  Write-Host "Red Pitaya: $RP" -ForegroundColor White

  # ---- 3. Downloads ------------------------------------------------------------------------------
  New-Item -ItemType Directory -Force -Path $DlDir | Out-Null
  Write-Host ''
  Say "Downloading to $DlDir" "Descargando en $DlDir" White
  foreach ($app in $sel) {
    $f = Join-Path $DlDir $app.File
    if ((Test-Path $f) -and ((Get-Item $f).Length -gt 0)) {
      Write-Host ('  {0,-45} {1}' -f $app.File, (T 'already downloaded' 'ya descargado')); continue
    }
    Write-Host "  $($app.File)"
    $part = "$f.part"
    $ok = $false
    if ($curl) {
      & $curl.Source -fL --progress-bar -o $part $app.Url
      $ok = ($LASTEXITCODE -eq 0)
    } else {
      try { $ProgressPreference = 'Continue'; Invoke-WebRequest -Uri $app.Url -OutFile $part -UseBasicParsing; $ok = $true } catch { $ok = $false }
    }
    if ($ok) { Move-Item -Force $part $f }
    else { Remove-Item -Force $part -ErrorAction SilentlyContinue; Say "Download failed: $($app.Url)" "Falló la descarga: $($app.Url)" Red; return }
  }

  # ---- 4. SSH connection -------------------------------------------------------------------------
  $SshOpt = @('-p', "$Port", '-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=10')
  $ScpOpt = @('-P', "$Port", '-o', 'StrictHostKeyChecking=accept-new', '-o', 'ConnectTimeout=10')
  $Target = "root@$RP"
  function RSsh([string]$cmd) { & $ssh.Source @SshOpt $Target $cmd }

  Write-Host ''
  Say "SSH connection to $Target" "Conexión SSH a $Target" White
  & $ssh.Source @SshOpt -o BatchMode=yes $Target true 2>$null
  $KeyOk = ($LASTEXITCODE -eq 0)
  if ($KeyOk) {
    Say '  SSH key already accepted by the Red Pitaya.' '  La Red Pitaya ya acepta tu llave SSH.'
  } else {
    $sshDir = Join-Path $env:USERPROFILE '.ssh'
    $key = $null
    foreach ($k in 'id_ed25519', 'id_ecdsa', 'id_rsa') { if (Test-Path (Join-Path $sshDir "$k.pub")) { $key = Join-Path $sshDir $k; break } }
    if (-not $key) {
      $a = Read-Line (T '  You have no SSH key. Create one so that the password is asked only once? [Y/n] ' `
                        '  No tenés una llave SSH. ¿Crear una para tipear la clave una sola vez? [S/n] ')
      if ($a -notmatch '^[nN]') {
        New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
        $key = Join-Path $sshDir 'id_ed25519'
        # empty passphrase: PowerShell < 7.3 drops a bare '' argument, so it needs '""'
        $empty = if ($PSVersionTable.PSVersion -ge [version]'7.3') { '' } else { '""' }
        & (Get-Command ssh-keygen.exe).Source -q -t ed25519 -N $empty -f $key
        if (-not (Test-Path "$key.pub")) { $key = $null }
      }
    }
    if ($key) {
      # Equivalent of ssh-copy-id (not included in Windows)
      $pub = (Get-Content "$key.pub" -Raw).Trim()
      Say '  Copying your SSH key to the Red Pitaya (password of root; by default it is "root"):' `
          '  Copiando tu llave SSH a la Red Pitaya (clave de root; por defecto es "root"):'
      RSsh "umask 077; mkdir -p ~/.ssh; grep -qxF '$pub' ~/.ssh/authorized_keys 2>/dev/null || echo '$pub' >> ~/.ssh/authorized_keys"
      & $ssh.Source @SshOpt -o BatchMode=yes $Target true 2>$null
      $KeyOk = ($LASTEXITCODE -eq 0)
    }
    if (-not $KeyOk) {
      Say '  The password of root will be asked 3 more times (by default it is "root").' `
          '  Se pedirá la clave de root 3 veces más (por defecto es "root").' Yellow
    }
  }

  # Apps already on the board
  $existing = @{}
  $lines = RSsh "grep -H version $AppsDir/*/info/info.json 2>/dev/null; true"
  if ($LASTEXITCODE -ne 0) { Say "Cannot connect to $Target by SSH." "No se puede conectar por SSH a $Target." Red; return }
  foreach ($l in $lines) {
    if ($l -match '/apps/([^/]+)/info/info\.json:.*"version"\s*:\s*"([^"]*)"') { $existing[$Matches[1]] = $Matches[2] }
  }

  # ---- 5. Replace or skip the Apps that already exist ----------------------------------------------
  $todo = @(); $replaceAll = $Force
  foreach ($app in $sel) {
    if ($existing.ContainsKey($app.Name)) {
      $old = $existing[$app.Name]
      if ($OnlyNew) { Write-Host ('  {0,-28} {1}' -f $app.Name, (T "exists ($old): skipped (--only-new)" "existe ($old): se omite (--only-new)")); continue }
      if (-not $replaceAll) {
        $skip = $false
        while ($true) {
          $a = Read-Line (T "  $($app.Name) already exists (installed $old, new $($app.Ver)). Replace? [y]es / [n]o / replace [a]ll: " `
                            "  $($app.Name) ya existe (instalada $old, nueva $($app.Ver)). ¿Reemplazar? [s]í / [n]o / reemplazar [t]odas: ")
          if ($a -match '^(y|s|yes|si|sí)$')   { break }
          if ($a -match '^(a|t|all|todas)$')   { $replaceAll = $true; break }
          if ($a -match '^(n|no)$')            { $skip = $true; break }
        }
        if ($skip) { continue }
      }
    }
    $todo += $app
  }
  if ($todo.Count -eq 0) { Write-Host ''; Say 'Nothing to install.' 'Nada para instalar.'; return }

  # ---- 6. Upload and install ---------------------------------------------------------------------
  # Remote script (LF line ends): unpacks each package next to the Apps folder, swaps the folders,
  # prints "OK <App> <version> [NGINX]" per App and restarts the web server when an nginx.conf is
  # new or changed (unless --no-restart).
  $remote = @'
A=/opt/redpitaya/www/apps; T=/tmp/marceluda_installer; RESTART=$1; shift
export PATH_REDPITAYA=/opt/redpitaya
if [ -x /opt/redpitaya/sbin/rw ]; then /opt/redpitaya/sbin/rw; else /boot/sbin/rw; fi >/dev/null 2>&1
NG=0
for f in "$@"; do
  f="$T/$f"
  top=$(tar tzf "$f" | grep -m1 -E '^[^/]+/info/info\.json$' | cut -d/ -f1)
  if [ -z "$top" ]; then echo "ERR $f"; continue; fi
  old=$(md5sum "$A/$top/nginx.conf" 2>/dev/null | cut -d' ' -f1)
  rm -rf "$A/.inst_$top"; mkdir -p "$A/.inst_$top"
  tar xzf "$f" --no-same-owner --no-same-permissions -C "$A/.inst_$top" "$top" 2>/dev/null || tar xzf "$f" -C "$A/.inst_$top" "$top"
  if [ ! -f "$A/.inst_$top/$top/info/info.json" ]; then echo "ERR $top"; rm -rf "$A/.inst_$top"; continue; fi
  rm -rf "$A/$top"; mv "$A/.inst_$top/$top" "$A/$top"; rm -rf "$A/.inst_$top"
  chmod 755 "$A/$top/fpga.sh" 2>/dev/null
  new=$(md5sum "$A/$top/nginx.conf" 2>/dev/null | cut -d' ' -f1)
  v=$(grep -o '"version"[^,}]*' "$A/$top/info/info.json" | head -1 | sed 's/.*: *"//; s/".*//')
  if [ "$old" != "$new" ]; then NG=1; echo "OK $top $v NGINX"; else echo "OK $top $v"; fi
  rm -f "$f"; sync
done
if [ $NG -eq 1 ] && [ "$RESTART" = 1 ]; then systemctl restart redpitaya_nginx && echo "RESTARTED"; fi
'@
  $remoteFile = Join-Path $DlDir 'marceluda_remote_install.sh'
  [IO.File]::WriteAllText($remoteFile, ($remote -replace "`r`n", "`n"), (New-Object Text.UTF8Encoding $false))
  $restart = if ($NoRestart) { '0' } else { '1' }

  Write-Host ''
  Say "Installing $($todo.Count) App(s) on $RP" "Instalando $($todo.Count) App(s) en $RP" White
  $total = 0; foreach ($app in $todo) { $total += (Get-Item (Join-Path $DlDir $app.File)).Length }
  $done = 0; $installed = @(); $failed = @(); $nginx = $false; $restarted = $false

  function Parse-Out($out, $app) {
    $hit = $false
    foreach ($l in @($out)) {
      $s = [string]$l
      if ($s -match '^OK (\S+) (\S+)( NGINX)?') { $script:installedTmp += , @($Matches[1], $Matches[2]); if ($Matches[3]) { $script:ngTmp = $true }; $hit = $true }
      elseif ($s -eq 'RESTARTED') { $script:rsTmp = $true }
    }
    return $hit
  }
  $script:installedTmp = @(); $script:ngTmp = $false; $script:rsTmp = $false

  if ($KeyOk) {
    # One App at a time (no password): the bar follows the copy of each App
    & $scp.Source -q @ScpOpt $remoteFile "${Target}:/tmp/marceluda_remote_install.sh"
    RSsh "mkdir -p $RemoteTmp" | Out-Null
    foreach ($app in $todo) {
      $s = (Get-Item (Join-Path $DlDir $app.File)).Length
      Bar $done $total "$($app.Name): $(T 'upload' 'subiendo')"
      & $scp.Source -q @ScpOpt (Join-Path $DlDir $app.File) "${Target}:$RemoteTmp/$($app.File)"
      if ($LASTEXITCODE -ne 0) { $failed += $app.Name; $done += $s; continue }
      $done += [math]::Floor($s / 2); Bar $done $total "$($app.Name): $(T 'install' 'instalando')"
      $out = RSsh "bash /tmp/marceluda_remote_install.sh 0 '$($app.File)'"
      $done += $s - [math]::Floor($s / 2)
      if (-not (Parse-Out $out $app)) { $failed += $app.Name }
      Bar $done $total $app.Name
    }
    if ($script:ngTmp -and -not $NoRestart) {
      $out = RSsh "systemctl restart redpitaya_nginx && echo RESTARTED"; [void](Parse-Out $out $null)
    }
    RSsh "rm -rf $RemoteTmp /tmp/marceluda_remote_install.sh" | Out-Null
  } else {
    # Without a key: one copy of everything and one install session (2 passwords)
    Bar 0 $total (T 'upload (all the Apps)' 'subiendo (todas las Apps)'); Write-Host ''
    $files = @($remoteFile) + @($todo | ForEach-Object { Join-Path $DlDir $_.File })
    & $ssh.Source @SshOpt $Target "mkdir -p $RemoteTmp" | Out-Null
    & $scp.Source @ScpOpt @files "${Target}:$RemoteTmp/"
    if ($LASTEXITCODE -ne 0) { Say 'Upload failed.' 'Falló la subida.' Red; return }
    $done = $total / 2
    $names = ($todo | ForEach-Object { "'" + $_.File + "'" }) -join ' '
    $per = ($total / 2) / $todo.Count
    & $ssh.Source @SshOpt $Target "bash $RemoteTmp/marceluda_remote_install.sh $restart $names; rm -rf $RemoteTmp" | ForEach-Object {
      if (Parse-Out $_ $null) { $done += $per; Bar $done $total (($_ -split ' ')[1]) }
    }
    foreach ($app in $todo) { if (-not ($script:installedTmp | Where-Object { $_[0] -eq $app.Name })) { $failed += $app.Name } }
  }
  Bar $total $total (T 'done' 'listo'); Write-Host ''
  $installed = $script:installedTmp; $nginx = $script:ngTmp; $restarted = $script:rsTmp
  Remove-Item -Force $remoteFile -ErrorAction SilentlyContinue

  # ---- 7. Web server ----------------------------------------------------------------------------
  if ($nginx -and -not $restarted) {
    Say 'An App brings a new web server configuration: restart the Red Pitaya before using it.' `
        'Una App trae configuración nueva del servidor web: reiniciá la Red Pitaya antes de usarla.' Yellow
  } elseif ($restarted) {
    Say 'The web server of the Red Pitaya was restarted (an App brings a new nginx.conf).' `
        'Se reinició el servidor web de la Red Pitaya (una App trae un nginx.conf nuevo).'
  }

  # ---- 8. Summary --------------------------------------------------------------------------------
  Write-Host ''
  Say 'Installed now:' 'Instaladas ahora:' White
  foreach ($x in $installed) { Write-Host ('  OK {0,-28} {1,-22} http://{2}/{0}/' -f $x[0], $x[1], $RP) -ForegroundColor Green }
  if ($failed.Count -gt 0) {
    Say 'Failed:' 'Fallaron:' Yellow
    foreach ($x in $failed) { Write-Host "  X $x" -ForegroundColor Yellow }
  }
  Write-Host ''
  Say 'Apps of marceluda on the Red Pitaya (versions before this installation for the ones not installed now):' `
      'Apps de marceluda en la Red Pitaya (las no instaladas ahora, con la versión que ya tenían):' White
  $now = @{}; foreach ($x in $installed) { $now[$x[0]] = $x[1] }
  foreach ($app in $apps) {
    if ($now.ContainsKey($app.Name)) { Write-Host ('  {0,-28} {1}' -f $app.Name, $now[$app.Name]) }
    elseif ($existing.ContainsKey($app.Name)) { Write-Host ('  {0,-28} {1}' -f $app.Name, $existing[$app.Name]) }
  }
  Write-Host ''
  Say "Open http://$RP/ in the browser to use them." "Abrí http://$RP/ en el navegador para usarlas."
  Write-Host ''
}

Install-RPApps @args
