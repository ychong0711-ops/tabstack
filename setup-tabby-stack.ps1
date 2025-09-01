#!/usr/bin/env pwsh
# setup-tabby-stack.ps1  v1.4  (오류 수정)
param(
    [switch]$NoDevPod,
    [switch]$NoGPU
)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = 'Stop'

function Write-Info  { Write-Host "[INFO]  $($args -join ' ')" -ForegroundColor Cyan }

# winget 확인 (오류 수정)
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[WARN] winget 없음 → Microsoft Store 에서 'App Installer' 설치 후 재실행"
    exit 1
}

# Git & GitHub CLI
winget install --id Git.Git -e --silent --accept-source-agreements
winget install --id GitHub.cli -e --silent --accept-source-agreements

# DevPod 선택 설치
if (-not $NoDevPod) { winget install --id LoftLabs.DevPod -e --silent }

# SkyServe 선택 설치
if (-not $NoGPU) { winget install --id SkyPilot.SkyServe -e --silent }

# Python & Aider
$py = (Get-Command python -ErrorAction SilentlyContinue) ? "python" : "py"
& $py -m pip install --user --upgrade pip
& $py -m pip install --user aider-chat

# .devcontainer
$dcPath = ".devcontainer"
if (-not (Test-Path $dcPath)) { New-Item -ItemType Directory -Path $dcPath | Out-Null }
@'
{
  "name": "tabby-stack",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
  },
  "postCreateCommand": "python -m pip install aider-chat && npm i -g @google/generative-ai-cli",
  "customizations": {
    "vscode": {
      "extensions": ["tabbyml.vscode-tabby"],
      "settings": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" }
      }
    }
  }
}
'@ | Out-File "$dcPath/devcontainer.json" -Encoding utf8

# package.json + Husky
@'
{
  "name": "tabby-stack",
  "version": "1.0.0",
  "scripts": { "lint": "lint-staged" },
  "lint-staged": { "*.{js,ts,json,md}": ["prettier --write"] },
  "devDependencies": { "husky": "^8.0.3", "lint-staged": "^15.0.0", "prettier": "^3.0.0" }
}
'@ | Set-Content package.json -Encoding utf8

npm install -D husky lint-staged prettier --silent 2>$null
npx husky init 2>$null
Set-Content .husky/pre-commit "npx lint-staged" -NoNewline

Write-Host "✅ 설치 완료! devpod up .  또는  sky launch -c tabby-gpu tabby.yaml"
