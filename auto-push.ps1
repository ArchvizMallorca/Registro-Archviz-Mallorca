# auto-push.ps1 - Sube automaticamente los cambios del repo a GitHub
# Se ejecuta desde la tarea programada de Windows (ver instalar-autopush.bat)

# Situarse en la carpeta del repo (la del propio script)
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $dir

$log = Join-Path $dir "auto-push.log"
function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File -FilePath $log -Append -Encoding utf8 }

# Comprobar que git esta disponible
$git = (Get-Command git -ErrorAction SilentlyContinue)
if (-not $git) { Log "ERROR: git no esta en el PATH"; exit 1 }

# Candado huerfano: si quedo de una operacion interrumpida (lleva mas de 60s sin tocarse),
# lo borramos. Si es reciente, hay una operacion en curso (GitHub Desktop u otra) y esperamos.
$lock = Join-Path $dir ".git\index.lock"
if (Test-Path $lock) {
    $age = (Get-Date) - (Get-Item $lock).LastWriteTime
    if ($age.TotalSeconds -gt 60) {
        Remove-Item $lock -Force -ErrorAction SilentlyContinue
        Log "Candado huerfano .git/index.lock eliminado."
    } else {
        Log "Operacion git en curso, se omite esta vuelta."
        exit 0
    }
}

# Identidad local (por si no estuviera configurada)
git config --local user.name  "Archviz Mallorca" 2>$null
git config --local user.email "archvizmallorca@gmail.com" 2>$null

# Hay cambios?
$changes = git status --porcelain
if (-not $changes) { Log "Sin cambios."; exit 0 }

git add -A 2>&1 | Out-Null
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Auto-push $stamp" 2>&1 | Out-Null

# Subir a la rama actual
$branch = (git rev-parse --abbrev-ref HEAD).Trim()

# Traer primero los cambios del remoto (rebase) para evitar rechazos non-fast-forward
git pull --rebase origin $branch 2>&1 | Out-Null

$push = git push origin $branch 2>&1
if ($LASTEXITCODE -eq 0) {
    Log "OK: subido a origin/$branch"
} else {
    Log "ERROR al hacer push: $push"
    exit 1
}
