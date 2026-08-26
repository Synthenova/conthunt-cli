$ErrorActionPreference = "Stop"
$Script = Join-Path (Split-Path $PSScriptRoot -Parent) "install.ps1"
[void][scriptblock]::Create((Get-Content $Script -Raw))

$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("conthunt-test-" + [guid]::NewGuid())
$Archive = Join-Path $Fixture "conthunt_windows_x86_64.zip"
$Checksums = Join-Path $Fixture "checksums.txt"
$Calls = [System.Collections.Generic.List[string]]::new()
$OriginalUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$StableVersion = "  v2.0.0  "
$DevVersion = "v2.1.0-beta.2"

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
        if ($Uri.EndsWith("/main/VERSION")) {
            if ($StableVersion -eq "__NETWORK_FAIL__") { throw "network failed" }
            return $StableVersion
        }
        if ($Uri.EndsWith("/dev/VERSION")) { return $DevVersion }
        throw "unexpected URI: $Uri"
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
    if ($Calls | Where-Object { $_ -like "https://raw.githubusercontent.com/*/VERSION" }) {
        throw "exact version unexpectedly queried a channel pointer"
    }

    $StableVersion = "not-a-tag"
    try {
        . $Script -Channel stable -InstallDir $InstallDir
        throw "installer accepted an invalid channel tag"
    } catch {
        if ($_.Exception.Message -notlike "Invalid ContHunt release tag*") { throw }
    }

    $StableVersion = ""
    try {
        . $Script -Channel stable -InstallDir $InstallDir
        throw "installer accepted an empty channel pointer"
    } catch {
        if ($_.Exception.Message -notlike "Invalid ContHunt release tag*") { throw }
    }

    $StableVersion = "__NETWORK_FAIL__"
    try {
        . $Script -Channel stable -InstallDir $InstallDir
        throw "installer ignored a channel pointer network failure"
    } catch {
        if ($_.Exception.Message -notlike "Could not read the ContHunt stable release pointer*") { throw }
    }

    $StableVersion = "bad`nv2.0.0"
    try {
        . $Script -Channel stable -InstallDir $InstallDir
        throw "installer accepted a multi-line channel pointer"
    } catch {
        if ($_.Exception.Message -notlike "Invalid ContHunt release tag*") { throw }
    }

    try {
        . $Script -Version '../../bad' -InstallDir $InstallDir
        throw "installer accepted an invalid exact tag"
    } catch {
        if ($_.Exception.Message -notlike "Invalid ContHunt release tag*") { throw }
    }

    $StableVersion = "v2.0.0"
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
