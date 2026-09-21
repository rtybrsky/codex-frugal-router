[CmdletBinding()]
param(
    [string]$DestinationRoot = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex\skills'),
    [string]$StatsProjectRoot = '',
    [switch]$SkipMcp,
    [switch]$ReplaceMcp
)

$ErrorActionPreference = 'Stop'
$systemName = 'AI Agent Quality-First Frugal System'
$source = Join-Path $PSScriptRoot 'codex-frugal-router'
$destination = Join-Path $DestinationRoot 'codex-frugal-router'

if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md'))) {
    throw "Skill source is incomplete: $source"
}

New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null

if (Test-Path -LiteralPath $destination) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path (Split-Path -Parent $DestinationRoot) 'skill-backups'
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    $backup = Join-Path $backupRoot "codex-frugal-router-$stamp"
    Move-Item -LiteralPath $destination -Destination $backup
    Write-Host "Existing skill backed up to: $backup"
}

Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
Write-Host "$systemName installed: $destination"

if (-not $SkipMcp) {
    $resolvedStatsRoot = $null

    if ($StatsProjectRoot) {
        $candidate = Resolve-Path -LiteralPath $StatsProjectRoot -ErrorAction Stop
        $resolvedStatsRoot = $candidate.Path
    }
    else {
        $parentRoot = Split-Path -Parent $PSScriptRoot
        $matches = @(
            Get-ChildItem -LiteralPath $parentRoot -Directory | Where-Object {
                (Test-Path -LiteralPath (Join-Path $_.FullName 'install-mcp.ps1')) -and
                (Test-Path -LiteralPath (Join-Path $_.FullName 'mcp-server\server.mjs'))
            }
        )

        if ($matches.Count -eq 1) {
            $resolvedStatsRoot = $matches[0].FullName
        }
        elseif ($matches.Count -eq 0) {
            Write-Warning 'Stats project was not found. The core skill is installed, but measurement mode is unavailable. Use -StatsProjectRoot later to add it.'
        }
        else {
            throw 'Multiple stats projects were found. Use -StatsProjectRoot to select one.'
        }
    }

    if ($resolvedStatsRoot) {
        $mcpInstaller = Join-Path $resolvedStatsRoot 'install-mcp.ps1'
        $mcpServer = Join-Path $resolvedStatsRoot 'mcp-server\server.mjs'
        if (-not (Test-Path -LiteralPath $mcpInstaller) -or -not (Test-Path -LiteralPath $mcpServer)) {
            throw "Stats project is incomplete: $resolvedStatsRoot"
        }

        & $mcpInstaller -Replace:$ReplaceMcp
    }
}

Write-Host 'Restart Codex or create a new task, then invoke $codex-frugal-router.'
