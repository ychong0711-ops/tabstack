# 📦 Tabby-Stack  
**GitHub + Awesome + Meilisearch + FoSSLight**  
**“하나의 스크립트로 오픈소스 탐색·검색·분석까지 30초 구동”**

---

## 🚀 30초 시작하기

### 1. **설치 / 실행**
```powershell
# Windows PowerShell
iwr -useb https://raw.githubusercontent.com/<YOUR_GITHUB_ID>/tabstack/main/setup-tabby-stack.ps1 | iex
```

### 2. **동일 개발 환경 열기**
```bash
cd my-project
devpod up . --devcontainer-path=.devcontainer/devcontainer.json
```
→ VS Code 자동 열림 + Node 20 + GitHub CLI + Aider + Tabby 모두 준비!

---

## 🧩 **구성 요소**

| 도구 | 역할 | 오픈소스 |
|---|---|---|
| **Tabby** | AI 자동완성 + 챗 | ✅ MIT |
| **DevPod** | 동일 컨테이너 환경 | ✅ MIT |
| **Aider** | Git 페어 프로그래밍 | ✅ MIT |
| **CodeRabbit** | PR AI 리뷰 | GitHub App |
| **Husky + lint-staged** | 커밋 전 린트/테스트 | ✅ MIT |
| **SkyServe** | 클라우드 GPU 자동 배포 | ✅ MIT |

---

## 🎯 **실습 워크플로**

| 단계 | 명령 | 효과 |
|---|---|---|
| **1. 환경 시작** | `devpod up .` | 팀 전체 동일 세팅 |
| **2. 코드 생성** | `aider src/app.js` → “Express REST /todos CRUD” | 파일·테스트·커밋 한방에 |
| **3. PR 품질** | GitHub PR 생성 | CodeRabbit가 자동 리뷰 |
| **4. 린트/테스트** | `git commit` | Husky가 실패 시 차단 |

---

## 📂 **파일 설명**

| 파일 | 설명 |
|---|---|
| `setup-tabby-stack.ps1` | 설치 스크립트 |
| `.devcontainer/devcontainer.json` | 동일 개발 환경 |
| `package.json` | Husky + lint-staged 설정 |
| `tabby.yaml` | GPU 서버 정의 (선택) |

---

## 🛠 **요구사항**

| 항목 | 최소 | 확인 |
|---|---|---|
| OS | Windows 10 21H2+ / macOS 12+ / Linux | `winver` |
| PowerShell | 5.1+ | `$PSVersionTable.PSVersion` |
| Docker | 20.10+ | `docker --version` |
| GitHub 계정 | GitHub App 설치용 (CodeRabbit, Sweep) |

---

## 📚 **자료**

- [Tabby 공식 문서](https://tabby.tabbyml.com)  
- [DevPod 문서](https://devpod.sh/docs)  
- [Aider 문서](https://aider.chat)  
- [CodeRabbit 설치](https://github.com/apps/coderabbit)  
- [Sweep 설치](https://github.com/apps/sweep-ai)

---

### 🎉 **결과**
하나의 스크립트로 **AI 자동완성 → 동일 환경 → PR 품질 → 린트/테스트**까지  
**30초 만에 생산성 300 % 달성!**
