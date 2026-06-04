# Project Build Skill Suite

一个面向多平台 Code Agent 的**伪多 Agent 工作流系统**。把"从零生成项目"到"后期偏差修正"做成一套可复用的、基于 JSON 状态传递的多角色工作流。

## 30 秒上手

1. 在你的 Code Agent 平台中打开本仓库
2. 直接说"帮我从需求文档生成一个完整项目"
3. Agent 会按工作流自动切换角色（Planner → Architect → Builder → QA）
4. 每一轮结束你都会看到：文件清单 + 启动方式 + 验收点
5. QA 检查不通过？自动进入修正循环（FixRouter → Specialist）

## 工作流架构

```text
Stage 0: 初始化
Stage 1: Planner（需求规划师） → requirements.json
Stage 2: Architect（架构师）    → architecture.json
Stage 3: Builder（构建师）      → build-report.json + 代码
Stage 4: QA（质量检查员）       → quality-report.json
Stage 5: FixRouter → Specialist（修正循环，条件触发）
Stage 6: 收尾
```

## 6 个角色

| 角色 | 职责 | 输出 |
|------|------|------|
| Planner | 把模糊需求变成结构化 requirements.json | requirements.json |
| Architect | 技术选型 + 分层 + 接口契约 + 目录结构 | architecture.json |
| Builder | 按阶段生成可运行代码，每层可验收 | build-report.json + 代码 |
| QA | 对照需求逐项检查，不改代码 | quality-report.json |
| FixRouter | 归类问题并路由到专项 | 问题归类卡 + 路由决策 |
| Specialist | 按路由进入专项 Skill 深问并修改 | fix-report.json + 代码 |

## 本仓库目录结构

```text
Project-build-SKILL/
├─ AGENTS.md                          <- Codex / 通用 Agent 指令入口
├─ README.md                          <- 本文件
├─ input/                             <- 需求文档输入目录（放 .md/.txt/.docx）
├─ scripts/
│  └─ docx2md.py                      <- .docx 转 Markdown 工具（依赖 python-docx）
│
├─ workflow/                          <- 工作流定义（所有平台共用）
│  ├─ orchestrator.md                 <- 调度器 + 企业级目录规范
│  ├─ roles/                          <- 6 个角色定义
│  ├─ schema/                         <- JSON Schema（状态文件格式）
│  └─ templates/                      <- 交付文档模板
│     ├─ packaging-guide.md           <- 项目打包指南模板
│     ├─ project-summary.md           <- 项目总结介绍模板
│     └─ defense-report.md            <- 答辩准备报告模板
│
├─ skills/                            <- 7 个精简版 Skill（角色执行时读取）
│
├─ docs/
│  ├─ platform-bridge.md              <- 跨平台适配指南
│  └─ skills/                         <- 追问题库附录
│
└─ workspace/                         <- 生成项目输出目录（强制隔离）
```

## 生成项目的企业级目录结构

Builder 生成的每个项目都遵循企业级规范（详见 [workflow/orchestrator.md](workflow/orchestrator.md)）：

```text
workspace/<project-name>/
├─ apps/
│  ├─ frontend/src/{api,components,pages,types,utils,styles}
│  └─ backend/src/{controller,service,repository,entity,dto,config,exception}
├─ db/{migration,seed,schema.sql}
├─ deploy/{docker-compose.yml,Dockerfile.*,nginx.conf}
├─ scripts/{setup.ps1,setup.sh,build.ps1,check-env.ps1}
├─ docs/{requirements.md,architecture.md,api.md,deployment.md}
├─ tests/{unit,integration}
├─ .env.example
├─ .gitignore
├─ README.md
└─ _workflow/                         <- 运行时状态 JSON（不纳入版本控制）
```

## 跨平台适配

详见 [docs/platform-bridge.md](docs/platform-bridge.md)

| 平台 | 入口 |
|------|------|
| Trae | `.trae/skills/<name>/SKILL.md`（按指南自行创建） |
| Claude Code | `.claude/skills/<name>/SKILL.md`（按指南自行创建） |
| Codex | `AGENTS.md`（根目录已有） |
| 其他 Agent | 直接读 `skills/<name>/SKILL.md` |

## 核心约束

- **先读 orchestrator.md**：每次开始新工作流前必须先读取
- **产出优先**：每轮结束必须输出 文件清单 + 启动方式 + 验收点
- **状态驱动**：角色之间通过 JSON 文件传递上下文，不依赖对话记忆
- **工作区隔离**：生成项目输出到 `workspace/<project-name>/`
- **小白友好**：术语首次出现必须解释，给推荐时必须说明理由

## 详细文档

- 工作流调度器：[workflow/orchestrator.md](workflow/orchestrator.md)
- 角色定义：`workflow/roles/` 目录
- JSON Schema：`workflow/schema/` 目录
- 跨平台适配：[docs/platform-bridge.md](docs/platform-bridge.md)
