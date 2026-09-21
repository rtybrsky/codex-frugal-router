[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $projectRoot 'install.ps1'
$sourceSkill = Join-Path $projectRoot 'codex-frugal-router\SKILL.md'
$tempBase = [System.IO.Path]::GetTempPath()
$testRoot = Join-Path $tempBase ("codex-frugal-router-test-" + [guid]::NewGuid().ToString('N'))
$destination = Join-Path $testRoot 'skills'

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    $installer,
    [ref]$tokens,
    [ref]$parseErrors
) | Out-Null
if ($parseErrors.Count -ne 0) {
    throw "install.ps1 has parser errors: $($parseErrors[0].Message)"
}

New-Item -ItemType Directory -Path $testRoot | Out-Null
try {
    & $installer -DestinationRoot $destination -SkipMcp
    $installedSkill = Join-Path $destination 'codex-frugal-router\SKILL.md'
    if (-not (Test-Path -LiteralPath $installedSkill -PathType Leaf)) {
        throw 'The installed SKILL.md was not found.'
    }

    $sourceHash = (Get-FileHash -LiteralPath $sourceSkill -Algorithm SHA256).Hash
    $installedHash = (Get-FileHash -LiteralPath $installedSkill -Algorithm SHA256).Hash
    if ($sourceHash -ne $installedHash) {
        throw 'The installed SKILL.md does not match the source.'
    }
}
finally {
    $resolvedTemp = [System.IO.Path]::GetFullPath($tempBase)
    $resolvedTest = [System.IO.Path]::GetFullPath($testRoot)
    if (-not $resolvedTest.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean an unexpected path: $resolvedTest"
    }
    if (Test-Path -LiteralPath $resolvedTest) {
        Remove-Item -LiteralPath $resolvedTest -Recurse -Force
    }
}

Write-Host 'install-smoke: PASS'
