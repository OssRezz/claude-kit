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
