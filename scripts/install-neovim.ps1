$ErrorActionPreference = "Stop"

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is required."
    }

    winget install --exact --id Neovim.Neovim `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Neovim."
    }
}

$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")

$nvim = Get-Command nvim -ErrorAction SilentlyContinue

if (-not $nvim) {
    throw "nvim was installed but is not available in PATH."
}

$profileDir = Split-Path $PROFILE -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$aliasCommand = "Set-Alias vi nvim"

if (-not (Select-String -Path $PROFILE -SimpleMatch $aliasCommand -Quiet)) {
    Add-Content -Path $PROFILE -Value $aliasCommand
}

Set-Alias vi nvim -Scope Global

nvim --version
