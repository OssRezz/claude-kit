$Kit = $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

foreach ($dir in @('agents','commands','skills')) {
    $link   = Join-Path $ClaudeDir $dir
    $target = Join-Path $Kit $dir
    if (Test-Path $link) { Remove-Item $link -Recurse -Force }
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    Write-Host "linked $dir -> $target"
}

# Junctions only work for directories, so the global CLAUDE.md is
# hard-linked instead. Requires kit and profile on the same volume.
$mdLink   = Join-Path $ClaudeDir 'CLAUDE.md'
$mdTarget = Join-Path $Kit 'CLAUDE.md'
if (Test-Path $mdTarget) {
    if (Test-Path $mdLink) { Remove-Item $mdLink -Force }
    try {
        New-Item -ItemType HardLink -Path $mdLink -Target $mdTarget | Out-Null
        Write-Host "linked CLAUDE.md -> $mdTarget"
    } catch {
        Copy-Item $mdTarget $mdLink -Force
        Write-Host "copied CLAUDE.md (hard link unavailable, re-run install after edits)"
    }
}