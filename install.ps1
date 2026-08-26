param(
    [string]$Version = $env:CONTHUNT_VERSION,
    [string]$Channel = $env:CONTHUNT_CHANNEL,
    [string]$InstallDir = $env:CONTHUNT_INSTALL_DIR
)

$ErrorActionPreference = "Stop"
$Repo = "Synthenova/conthunt-cli"

if (-not $Channel) { $Channel = "stable" }
if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\ContHunt" }
if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne "X64") {
    throw "The ContHunt Windows beta currently supports x64 only."
}

if (-not $Version) {
    switch ($Channel) {
        "stable" { $Version = (Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest").tag_name }
        "dev" {
            $Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases?per_page=100" |
                Where-Object { $_.prerelease -and -not $_.draft } |
                Select-Object -First 1
            $Version = $Release.tag_name
        }
        default { throw "CONTHUNT_CHANNEL must be stable or dev." }
    }
    if (-not $Version) { throw "Could not resolve the latest ContHunt $Channel release." }
}

$Archive = "conthunt_windows_x86_64.zip"
$BaseUrl = "https://github.com/$Repo/releases/download/$Version"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("conthunt-" + [guid]::NewGuid())

try {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
    $ArchivePath = Join-Path $TempDir $Archive
    $ChecksumsPath = Join-Path $TempDir "checksums.txt"
    Invoke-WebRequest "$BaseUrl/$Archive" -OutFile $ArchivePath
    Invoke-WebRequest "$BaseUrl/checksums.txt" -OutFile $ChecksumsPath

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
