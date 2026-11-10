<#
.SYNOPSIS
    Backs up or restores Claude Code, Codex, Rider and IdeaVim settings.
.EXAMPLE
    .\dotfiles.ps1 backup
    .\dotfiles.ps1 restore
#>
param(
    [Parameter(Mandatory)]
    [ValidateSet('backup', 'restore')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$jetBrainsRoot = Join-Path $env:APPDATA 'JetBrains'

# Restore targets the newest installed Rider so settings carry over after an upgrade.
$riderDir = Get-ChildItem $jetBrainsRoot -Directory -Filter 'Rider*' -ErrorAction SilentlyContinue |
    Where-Object Name -Match '^Rider\d{4}\.\d+$' |
    Sort-Object { [version]($_.Name -replace '^Rider') } |
    Select-Object -Last 1
if (-not $riderDir) { throw "No Rider config directory found in $jetBrainsRoot" }

# Machine-local state, usage stats and window layouts that should not travel between machines.
$riderOptionsExclude = @(
    '*.local.xml', 'vim_settings_local.xml', 'recentSolutions*.xml', 'window.state.xml', 'rider.perapp.window.state.v2.xml',
    '*usage.statistics.xml', 'actionSummary.xml', 'contributorSummary.xml', 'EventLogAllowedList.xml',
    'CommonFeedbackSurveyService.xml', 'DontShowAgainFeedbackService.xml', 'trace_license_storage.xml',
    'updates.xml', 'riderVersions.xml', 'trustedSolutions.xml', 'trusted-paths.xml', 'settingsSyncLocal.xml'
)

$entries = @(
    @{ Repo = 'claude'; Target = Join-Path $HOME '.claude'; Items = @(
        'settings.json', 'CLAUDE.md', 'keybindings.json', 'statusline.js', 'hooks') }
    @{ Repo = 'codex'; Target = Join-Path $HOME '.codex'; Items = @(
        'config.toml', 'AGENTS.md', 'hooks.json', 'review.config.toml',
        'permission-review.ps1', 'herdr-agent-state.ps1') }
    @{ Repo = 'rider'; Target = $riderDir.FullName; Items = @(
        'options', 'keymaps', 'codestyles', 'colors', 'Rider64.exe.vmoptions', 'disabled_plugins.txt',
        'resharper-host\GlobalSettingsStorage.DotSettings'); Exclude = $riderOptionsExclude }
    @{ Repo = '.'; Target = $HOME; Items = @('.ideavimrc') }
)

function Copy-Item-Mirrored([string]$from, [string]$to, [string[]]$exclude) {
    if (-not (Test-Path $from)) {
        Write-Warning "Missing: $from"
        return
    }
    New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
    if (Test-Path $from -PathType Container) {
        New-Item -ItemType Directory -Force $to | Out-Null
        Copy-Item (Join-Path $from '*') $to -Recurse -Force -Exclude $exclude
    } else {
        Copy-Item $from $to -Force
    }
    Write-Host "  $from -> $to"
}

if ($Action -eq 'restore' -and (Get-Process rider64 -ErrorAction SilentlyContinue)) {
    throw 'Close Rider before restoring: it overwrites its settings on exit.'
}

Write-Host "Rider config: $($riderDir.FullName)"
foreach ($entry in $entries) {
    foreach ($item in $entry.Items) {
        $repoPath = Join-Path (Join-Path $repo $entry.Repo) $item
        $targetPath = Join-Path $entry.Target $item
        if ($Action -eq 'backup') {
            # Drop stale files so deletions on the machine are reflected in the repo.
            if (Test-Path $repoPath -PathType Container) { Remove-Item $repoPath -Recurse -Force }
            Copy-Item-Mirrored $targetPath $repoPath $entry.Exclude
        } else {
            Copy-Item-Mirrored $repoPath $targetPath @()
        }
    }
}
