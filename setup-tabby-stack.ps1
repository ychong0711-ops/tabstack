#!/usr/bin/env pwsh
# setup-tabby-stack.ps1  (v1.3)
# Windows 전용 : Tabby + DevPod + Aider + CodeRabbit + Husky + SkyServe
# MIT License 2024-09-01
# --------------------------------------------------
# 사용법:
#   iwr -useb https://raw.githubusercontent.com/<YOUR_GITHUB_ID>/tabstack/main/setup-tabby-stack.ps1 | iex
# --------------------------------------------------

[CmdletBinding()]
param(
    [switch]$NoDevPod,
    [switch]$NoGPU
)

# 0. 기본 설정
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = 'Stop'

# 1. 색상
function Write-Info  { Write-Host "[INFO]  $($args -join ' ')" -ForegroundColor Cyan }
function Write-Warn  { Write-Host "[WARN]  $($args -join ' ')" -ForegroundColor Yellow }

# 2. winget 확인
if (-not (Get-Command winget -ErrorAction SilentlyComplete)) {
    Write-Warn "winget 없음 → Microsoft Store 에서 'App Installer' 설치 후 재실행"
    exit 1
}

# 3. 공통 필수
Write-Info "Git 설치 확인 ..."
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements

Write-Info "GitHub CLI 설치 확인 ..."
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements

# 4. DevPod (선택)
if (-not $NoDevPod) {
    Write-Info "DevPod 설치 확인 ..."
    winget install --id LoftLabs.DevPod -e --silent --accept-source-agreements --accept-package-agreements
}

# 5. SkyServe (선택)
if (-not $NoGPU) {
    Write-Info "SkyServe 설치 확인 ..."
    winget install --id SkyPilot.SkyServe -e --silent --accept-source-agreements --accept-package-agreements
}

# 6. Python & Aider
$py = (Get-Command python -ErrorAction SilentlyContinue) ? "python" : "py"
& $py -m pip install --user --upgrade pip
& $py -m pip install --user aider-chat

# 7. .devcontainer
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

# 8. package.json + Husky (오류 없음)
@'
{
  "name": "tabby-stack",
  "version": "1.0.0",
  "private": true,
  "scripts": { "lint": "lint-staged" },
  "lint-staged": {
    "*.{js,ts,json,md}": ["prettier --write"]
  },
  "devDependencies": {
    "husky": "^8.0.3",
    "lint-staged": "^15.0.0",
    "prettier": "^3.0.0"
}
'@ | Set-Content package.json -Encoding utf8

# 9. Git Hook
npm install -D husky lint-staged prettier --silent 2>$null
npx husky init 2>$null
Set-Content .husky/pre-commit "npx lint-staged" -NoNewline

# 10. 안내
Write-Host @'
┌────────────────────────────────────────────┐
│  설치 완료! 다음 단계:                    │
│   devpod up .                             │
│   sky launch -c tabby-gpu tabby.yaml      │
│   aider src/                              │
│  GitHub App 설치:                         │
│   • CodeRabbit: https://github.com/apps/coderabbit │
│   • Sweep:      https://github.com/apps/sweep-ai   │
└────────────────────────────────────────────┘
'@ -ForegroundColor Green



 

