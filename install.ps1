param(
    [string]$Version = $env:CONTHUNT_VERSION,
    [string]$Channel = $env:CONTHUNT_CHANNEL,
    [string]$InstallDir = $env:CONTHUNT_INSTALL_DIR
)

$ErrorActionPreference = "Stop"
$Repo = "Synthenova/conthunt-cli"
$TimeoutSec = 120

if (-not $Channel) { $Channel = "stable" }
if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\ContHunt" }
if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne "X64") {
    throw "The ContHunt Windows beta currently supports x64 only."
}

if (-not $Version) {
    switch ($Channel) {
        "stable" { $VersionUrl = "https://raw.githubusercontent.com/$Repo/main/VERSION" }
        "dev" { $VersionUrl = "https://raw.githubusercontent.com/$Repo/dev/VERSION" }
        default { throw "CONTHUNT_CHANNEL must be stable or dev." }
    }
    try { $Version = Invoke-RestMethod $VersionUrl -TimeoutSec $TimeoutSec }
    catch { throw "Could not read the ContHunt $Channel release pointer: $($_.Exception.Message)" }
}

$Version = ([string]$Version).Trim()
if ($Version -notmatch '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$') {
    $DisplayVersion = if ($Version) { $Version } else { "<empty>" }
    throw "Invalid ContHunt release tag: $DisplayVersion."
}

$Archive = "conthunt_windows_x86_64.zip"
$BaseUrl = "https://github.com/$Repo/releases/download/$Version"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("conthunt-" + [guid]::NewGuid())

try {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
    $ArchivePath = Join-Path $TempDir $Archive
    $ChecksumsPath = Join-Path $TempDir "checksums.txt"
    Invoke-WebRequest "$BaseUrl/$Archive" -OutFile $ArchivePath -TimeoutSec $TimeoutSec
    Invoke-WebRequest "$BaseUrl/checksums.txt" -OutFile $ChecksumsPath -TimeoutSec $TimeoutSec

    $ChecksumLine = Get-Content $ChecksumsPath | Where-Object { $_ -match "  $([regex]::Escape($Archive))$" } | Select-Object -First 1
    $Expected = ($ChecksumLine -split "\s+")[0]
    if (-not $Expected) { throw "Release checksum is missing for $Archive." }
    $Actual = (Get-FileHash $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($Actual -ne $Expected.ToLowerInvariant()) { throw "Checksum verification failed for $Archive." }

    Expand-Archive $ArchivePath -DestinationPath $TempDir -Force
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item (Join-Path $TempDir "conthunt.exe") (Join-Path $InstallDir "conthunt.exe") -Force

    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (($UserPath -split ";") -notcontains $InstallDir) {
        [Environment]::SetEnvironmentVariable("Path", "$InstallDir;$UserPath", "User")
    }
    if (($env:Path -split ";") -notcontains $InstallDir) { $env:Path = "$InstallDir;$env:Path" }

    & (Join-Path $InstallDir "conthunt.exe") --version
    Write-Host "Installed ContHunt to $InstallDir\conthunt.exe"
} finally {
    if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
}
