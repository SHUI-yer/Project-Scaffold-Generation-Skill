# Project Build Skill Suite

一个面向多平台 Code Agent 的**伪多 Agent 工作流系统**。把"从零生成项目"到"后期偏差修正"做成一套可复用的、基于 JSON 状态传递的多角色工作流。

> 许可证：MIT License | 作者：SHUIYE

## 30 秒上手

1. 在你的 Code Agent 平台中打开本仓库
2. 把需求文档放到 `input/` 目录（支持 `.md` / `.txt` / `.docx` / `.doc`）
3. 对 Agent 说"帮我从需求文档生成一个完整项目"
4. Agent 会用**点击选项**的方式引导你完成每个决策（无需手动打字）
5. 按工作流自动切换角色（Planner → Architect → Builder → QA）
6. QA 检查不通过？自动进入修正循环（FixRouter → Specialist）

## 工作流架构

```text
Stage 0: 初始化 → 创建 workspace/<project>/_workflow/
Stage 1: Planner（需求规划师） → requirements.json
Stage 2: Architect（架构师）    → architecture.json
Stage 3: Builder（构建师）      → build-report.json + 代码
Stage 4: QA（质量检查员）       → quality-report.json
Stage 5: FixRouter → Specialist（修正循环，条件触发）
Stage 6: 收尾
```

### QA 之后的分支

| quality-report.overall_status | 动作 |
|------------------------------|------|
| `pass` | 进入 Stage 6 收尾 |
| `fail` | 进入 Stage 5 修正循环 |
| `partial` | 询问用户是否继续修正 |

### 修正循环终止条件

- quality-report 变为 `pass`
- 用户明确说"停止修正"
- 达到最大修正轮数（默认 3 轮）

## 交互模式（全局生效）

**所有需要用户输入或确认的环节，Agent 必须使用 AskUserQuestion 工具以选项形式呈现**：

- 技术选型问题 → 提供 2-4 个选项 + 推荐标签
- 功能模块选择 → 多选模式
- 阶段间推进确认 → "继续 / 返回修改 / 暂停"选项
- 质量检查后的修正确认
- 任何其他需要用户决策的节点

用户点击选项回答，不需要手动打字。每轮最多 4 个问题。

## 6 个角色

| 角色 | 职责 | 对应 Skill | 输出 |
|------|------|-----------|------|
| Planner | 把模糊需求变成结构化 requirements.json | `project-scaffold-generator` | requirements.json |
| Architect | 技术选型 + 分层 + 接口契约 + 目录结构 | 内置 | architecture.json |
| Builder | 按 5 个 Layer 生成可运行代码，每层可验收 | `project-scaffold-generator` | build-report.json + 代码 |
| QA | 对照需求逐项检查，不改代码 | 内置 | quality-report.json |
| FixRouter | 归类问题并路由到专项 Skill | `project-fix-generator` | 问题归类卡 + 路由决策 |
| Specialist | 按路由进入专项 Skill 深问并修改 | 前端/后端/数据库/UI/工程化 | fix-report.json + 代码 |

### Builder 的 5 个 Layer

| Layer | 内容 | 可验收点 |
|-------|------|---------|
| Layer 1 | 项目骨架（入口、配置、目录结构） | 项目可被识别，配置可读取 |
| Layer 2 | 数据模型 + 数据库 DDL | 表结构正确，外键完整 |
| Layer 3 | DAO + Service 层 | CRUD 可执行，业务逻辑正确 |
| Layer 4 | GUI / 前端界面 | 界面可显示，导航正常 |
| Layer 5 | 脚本 + 文档 + 测试 | 环境检测通过，文档完整 |

## 7 个精简版 Skill

```text
skills/
├─ project-scaffold-generator/SKILL.md    <- 从零生成项目（Planner + Builder 使用）
├─ project-fix-generator/SKILL.md         <- 修正总入口（FixRouter 使用）
├─ frontend-fix-generator/SKILL.md        <- 前端专项修复
├─ backend-fix-generator/SKILL.md         <- 后端专项修复
├─ database-fix-generator/SKILL.md        <- 数据库专项修复
├─ ui-style-fix-generator/SKILL.md        <- UI 风格专项修复
└─ engineering-fix-generator/SKILL.md     <- 工程化专项修复
```

每个 Skill 只保留"触发条件 + 最短流程 + 产出模板"，详细题库按需加载 `docs/skills/` 附录。

## 本仓库目录结构

```text
Project-build-SKILL/
├─ AGENTS.md                          <- Codex / 通用 Agent 指令入口
├─ README.md                          <- 本文件
├─ LICENSE                            <- MIT License
├─ .gitattributes                     <- Git 属性配置
│
├─ input/                             <- 需求文档输入目录
│  └─ .gitkeep                        <- 放 .md / .txt / .docx / .doc 文件
│
├─ scripts/                           <- 工具脚本
│  ├─ doc2docx.py                     <- .doc → .docx 转换（依赖 pywin32 + Word/WPS）
│  └─ docx2md.py                      <- .docx → .md 转换（依赖 python-docx）
│
├─ workflow/                          <- 工作流定义（所有平台共用）
│  ├─ orchestrator.md                 <- 调度器 + 企业级目录规范 + 交互模式
│  ├─ roles/                          <- 6 个角色定义
│  │  ├─ planner.md                   <- 需求规划师（5轮问答）
│  │  ├─ architect.md                 <- 架构师
│  │  ├─ builder.md                   <- 构建师（5 Layer 规则）
│  │  ├─ qa.md                        <- 质量检查员（7 维度检查）
│  │  ├─ fix-router.md                <- 偏差分流器
│  │  └─ specialist.md                <- 专项修复师
│  ├─ schema/                         <- JSON Schema（状态文件格式）
│  │  ├─ requirements.schema.json     <- Planner 输出格式
│  │  ├─ architecture.schema.json     <- Architect 输出格式
│  │  ├─ build-report.schema.json     <- Builder 输出格式
│  │  ├─ quality-report.schema.json   <- QA 输出格式
│  │  ├─ fix-report.schema.json       <- Specialist 输出格式
│  │  └─ defense-report.schema.json   <- 答辩报告模板 schema
│  └─ templates/                      <- 交付文档模板
│     ├─ defense-report.md            <- 答辩准备报告模板（含15个常见问题）
│     ├─ packaging-guide.md           <- 项目打包指南模板
│     └─ project-summary.md           <- 项目总结介绍模板
│
├─ skills/                            <- 7 个精简版 Skill（角色执行时读取）
│
├─ docs/
│  ├─ platform-bridge.md              <- 跨平台适配指南（含一键创建脚本）
│  └─ skills/
│     └─ project-scaffold-generator/
│        └─ appendix.md               <- 追问题库附录（按需加载）
│
└─ workspace/                         <- 生成项目输出目录（强制隔离）
   └─ <project-name>/                 <- 每个项目独立子目录
      └─ _workflow/                   <- 运行时状态 JSON
         ├─ requirements.json
         ├─ architecture.json
         ├─ build-report.json
         ├─ quality-report.json
         └─ fix-report.json
```

## 文档转换链

支持 `.doc` / `.docx` / `.md` 三种格式的需求文档输入：

```text
.doc（旧版 Word）
  │  scripts/doc2docx.py（pywin32 调用 Word/WPS COM 接口）
  ▼
.docx（新版 Word）
  │  scripts/docx2md.py（python-docx 解析标题/列表/表格）
  ▼
.md（Markdown，Agent 可直接读取）
```

使用方式：
```bash
# .doc → .docx
python scripts/doc2docx.py input/需求文档.doc

# .docx → .md
python scripts/docx2md.py input/需求文档.docx
```

## 生成项目的企业级目录结构

Builder 生成的每个项目都遵循企业级规范（详见 [workflow/orchestrator.md](workflow/orchestrator.md)）。以桌面应用为例：

```text
workspace/<project-name>/
├─ main.py                  <- 程序入口
├─ .env.example             <- 环境变量模板
├─ .gitignore
├─ requirements.txt
├─ README.md
├─ config/                  <- 配置模块
├─ views/                   <- 界面层（GUI / 前端页面）
├─ services/                <- 业务逻辑层
├─ dao/                     <- 数据访问层
├─ models/                  <- 数据模型
├─ utils/                   <- 工具函数
├─ styles/                  <- 主题样式
├─ db/                      <- 数据库脚本（schema.sql + init_data.sql）
├─ scripts/                 <- 环境搭建脚本
├─ docs/                    <- 项目文档
│  ├─ requirements.md       <- 需求文档
│  ├─ architecture.md       <- 架构说明
│  ├─ deployment.md         <- 部署指南
│  ├─ api.md                <- 接口说明
│  └─ defense_report.md     <- 答辩准备报告
├─ tests/                   <- 单元测试
└─ _workflow/               <- 运行时状态 JSON（不纳入版本控制）
```

前后端分离项目会使用 `apps/frontend/` + `apps/backend/` 结构，详见 orchestrator.md。

## 跨平台适配

详见 [docs/platform-bridge.md](docs/platform-bridge.md)

| 平台 | 入口 | 说明 |
|------|------|------|
| Trae | `.trae/skills/<name>/SKILL.md` | 按平台桥接指南自行创建 |
| Claude Code | `.claude/skills/<name>/SKILL.md` | 按平台桥接指南自行创建 |
| Codex | `AGENTS.md`（根目录） | 已就绪，直接可用 |
| 其他 Agent | `skills/<name>/SKILL.md` | 直接读取精简版 Skill |

所有平台共用：`workflow/orchestrator.md`（工作流定义）+ `skills/`（精简版 Skill）

## 核心约束

- **先读 orchestrator.md**：每次开始新工作流前必须先读取
- **产出优先**：每轮结束必须输出 文件清单 + 启动方式 + 验收点
- **状态驱动**：角色之间通过 JSON 文件传递上下文，不依赖对话记忆
- **工作区隔离**：生成项目输出到 `workspace/<project-name>/`，不得散落仓库根目录
- **按需加载**：优先使用 `skills/` 精简版；只有需要更细追问时才读取 `docs/skills/` 附录
- **小白友好**：术语首次出现必须解释"是什么 + 解决什么问题"，给推荐时必须说明理由
- **点击交互**：所有决策节点使用 AskUserQuestion 选项形式，用户点击回答

## 详细文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 工作流调度器 | [workflow/orchestrator.md](workflow/orchestrator.md) | 完整阶段定义 + 企业级目录规范 |
| 角色定义 | `workflow/roles/` 目录 | 6 个角色的详细行为约束 |
| JSON Schema | `workflow/schema/` 目录 | 6 个状态文件的格式定义 |
| 交付文档模板 | `workflow/templates/` 目录 | 答辩报告 / 打包指南 / 项目总结 |
| 跨平台适配 | [docs/platform-bridge.md](docs/platform-bridge.md) | Trae / Claude Code / Codex 接入指南 |
| Agent 指令 | [AGENTS.md](AGENTS.md) | Codex / 通用 Agent 的入口文件 |
| 追问题库 | `docs/skills/project-scaffold-generator/appendix.md` | Planner 深问时按需加载 |
