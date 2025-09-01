#!/usr/bin/env pwsh
# setup-tabby-stack.ps1
# --------------------------------------------------
# Windows 전용 : Tabby + DevPod + Aider + CodeRabbit + Husky + SkyServe
# MIT License 2024-09-01  v1.2
# --------------------------------------------------
# 사용법:
#   iwr -useb https://raw.githubusercontent.com/<YOUR_GITHUB_ID>/tabstack/main/setup-tabby-stack.ps1 | iex
# --------------------------------------------------

[CmdletBinding()]
param(
    [switch]$NoDevPod,   # DevPod 설치 생략
    [switch]$NoGPU       # SkyServe(GPU 서버) 설치 생략
)

# 0. 기본 설정
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = 'Stop'

# 1. 색상 함수
function Write-Info  { Write-Host "[INFO]  $($args -join ' ')" -ForegroundColor Cyan }
function Write-Warn  { Write-Host "[WARN]  $($args -join ' ')" -ForegroundColor Yellow }
function Write-Err   { Write-Host "[ERROR] $($args -join ' ')" -ForegroundColor Red }

# 2. Winget 확인
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warn "winget 을 찾을 수 없습니다. Microsoft Store 에서 'App Installer' 를 설치해 주세요."
    exit 1
}

# 3. 공통 필수 패키지
Write-Info "Git 설치 확인 ..."
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements

Write-Info "GitHub CLI 설치 확인 ..."
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements

# 4. DevPod (선택)
if (-not $NoDevPod) {
    Write-Info "DevPod 설치 확인 ..."
    winget install --id LoftLabs.DevPod -e --silent --accept-source-agreements --accept-package-agreements
}

# 5. SkyServe (GPU 서버 선택)
if (-not $NoGPU) {
    Write-Info "SkyServe 설치 확인 ..."
    winget install --id SkyPilot.SkyServe -e --silent --accept-source-agreements --accept-package-agreements
}

# 6. Python & Aider
$py = (Get-Command python -ErrorAction SilentlyContinue) ? "python" : "py"
& $py -m pip install --user --upgrade pip
& $py -m pip install --user aider-chat

# 7. .devcontainer (공용 DevContainer)
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

# 8. Husky (Git Hook)
npm init -y 2>$null
npm install -D husky lint-staged prettier --silent
npx husky init 2>$null
Set-Content .husky/pre-commit "npx lint-staged" -NoNewline
$pkg = Get-Content package.json -Raw | ConvertFrom-Json
$pkg | Add-Member -NotePropertyName "lint-staged" -NotePropertyValue @{
    "*.{js,ts,json,md}" = @("prettier --write")
} -Force
$pkg | ConvertTo-Json -Depth 4 | Set-Content package.json -Encoding utf8

# 9. GitHub App 안내
Write-Host @'
┌────────────────────────────────────────────┐
│  설치 완료! GitHub App 활성화:            │
│   • CodeRabbit: https://github.com/apps/coderabbit │
│   • Sweep:      https://github.com/apps/sweep-ai   │
└────────────────────────────────────────────┘
'@ -ForegroundColor Green

# 10. 다음 단계
Write-Host @'
┌────────────────────────────────────────────┐
│  다음 명령으로 바로 시작:                 │
│   devpod up .                             │
│   sky launch -c tabby-gpu tabby.yaml      │
│   aider src/                              │
└────────────────────────────────────────────┘
'@ -ForegroundColor Cyan
