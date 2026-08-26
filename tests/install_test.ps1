$ErrorActionPreference = "Stop"
$Script = Join-Path (Split-Path $PSScriptRoot -Parent) "install.ps1"
[void][scriptblock]::Create((Get-Content $Script -Raw))

$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("conthunt-test-" + [guid]::NewGuid())
$Archive = Join-Path $Fixture "conthunt_windows_x86_64.zip"
$Checksums = Join-Path $Fixture "checksums.txt"
$Calls = [System.Collections.Generic.List[string]]::new()
$OriginalUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

try {
    New-Item -ItemType Directory -Path (Join-Path $Fixture "archive") | Out-Null
    Add-Type -TypeDefinition 'public class Program { public static void Main() { System.Console.WriteLine("conthunt version 1.2.3"); } }' `
        -OutputAssembly (Join-Path $Fixture "archive\conthunt.exe") -OutputType ConsoleApplication
    Compress-Archive (Join-Path $Fixture "archive\conthunt.exe") $Archive
    "$(Get-FileHash $Archive -Algorithm SHA256 | Select-Object -ExpandProperty Hash)  conthunt_windows_x86_64.zip" |
        Set-Content $Checksums

    function Invoke-RestMethod {
        param([string]$Uri)
        $Calls.Add($Uri)
        if ($Uri.EndsWith("/latest")) { return [pscustomobject]@{ tag_name = "v2.0.0" } }
        return @(
            [pscustomobject]@{ tag_name = "v9.9.9-draft"; draft = $true; prerelease = $true },
            [pscustomobject]@{ tag_name = "v2.1.0-beta.2"; draft = $false; prerelease = $true },
            [pscustomobject]@{ tag_name = "v2.0.0"; draft = $false; prerelease = $false }
        )
    }

    function Invoke-WebRequest {
        param([string]$Uri, [string]$OutFile)
        $Calls.Add($Uri)
        if ($Uri.EndsWith("checksums.txt")) { Copy-Item $Checksums $OutFile }
        else { Copy-Item $Archive $OutFile }
    }

    $InstallDir = Join-Path $Fixture "install"

    $Calls.Clear()
    . $Script -Channel stable -InstallDir $InstallDir
    if (-not ($Calls -contains "https://github.com/Synthenova/conthunt-cli/releases/download/v2.0.0/conthunt_windows_x86_64.zip")) {
        throw "stable channel did not select v2.0.0"
    }

    $Calls.Clear()
    . $Script -Channel dev -InstallDir $InstallDir
    if (-not ($Calls -contains "https://github.com/Synthenova/conthunt-cli/releases/download/v2.1.0-beta.2/conthunt_windows_x86_64.zip")) {
        throw "dev channel did not select the latest prerelease"
    }

    $Calls.Clear()
    . $Script -Version v1.2.3 -Channel dev -InstallDir $InstallDir
    if ($Calls | Where-Object { $_ -like "https://api.github.com/*" }) {
        throw "exact version unexpectedly queried releases API"
    }

    "$('0' * 64)  conthunt_windows_x86_64.zip" | Set-Content $Checksums
    try {
        . $Script -Version v1.2.3 -InstallDir $InstallDir
        throw "installer accepted a bad checksum"
    } catch {
        if ($_.Exception.Message -notlike "Checksum verification failed*") { throw }
    }

    Write-Host "PowerShell installer tests passed"
} finally {
    [Environment]::SetEnvironmentVariable("Path", $OriginalUserPath, "User")
    if (Test-Path $Fixture) { Remove-Item -Recurse -Force $Fixture }
}
