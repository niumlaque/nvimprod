$ErrorActionPreference = "Stop"

$sourceDir = (Resolve-Path (Join-Path $PSScriptRoot "nvim")).Path
$configDir = Join-Path $env:LOCALAPPDATA "nvim"
$plugPath = Join-Path $env:LOCALAPPDATA "nvim-data\site\autoload\plug.vim"

if (Test-Path $configDir) {
    $config = Get-Item $configDir

    if ($config.LinkType -ne "Junction" -or
        (Resolve-Path $config.Target).Path -ne $sourceDir) {
        throw "$configDir already exists and does not point to $sourceDir."
    }
} else {
    New-Item -ItemType Junction -Path $configDir -Target $sourceDir | Out-Null
}

if (-not (Test-Path $plugPath)) {
    $plugDir = Split-Path $plugPath -Parent
    New-Item -ItemType Directory -Force -Path $plugDir | Out-Null

    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" `
        -OutFile $plugPath
}

Write-Host "Neovim configuration installed."
Write-Host "Run :PlugInstall in Neovim."
