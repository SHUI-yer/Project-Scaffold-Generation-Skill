# Orchestrator（工作流调度器）

## 这是什么

Orchestrator 是整个工作流系统的"大脑"。它定义了：
- 有哪些角色（Agent）
- 每个阶段该切换到哪个角色
- 角色之间如何通过 JSON 文件传递状态
- 什么条件下进入修正循环

所有平台（Trae / Claude Code / Codex / 通用 Agent）都通过读取本文件来理解工作流。

## 核心原则

- **伪多 Agent**：一个会话中按角色轮换执行，不是多个独立进程
- **状态驱动**：每个角色读取上一个角色的 JSON 输出，作为自己的输入
- **产出优先**：每个阶段结束必须输出 JSON 状态文件 + 文件清单 + 启动方式 + 验收点
- **可回溯**：所有中间状态保存在 `workspace/_workflow/` 目录

## 企业级项目目录规范（强制）

Builder 生成的所有项目必须遵循以下目录结构：

### 前后端分离项目

```text
workspace/<project-name>/
├─ apps/
│  ├─ frontend/                  <- 前端应用
│  │  ├─ src/
│  │  │  ├─ api/                 <- API 封装层
│  │  │  ├─ components/          <- 公共组件
│  │  │  ├─ pages/               <- 页面
│  │  │  ├─ types/               <- TypeScript 类型定义
│  │  │  ├─ utils/               <- 工具函数
│  │  │  ├─ styles/              <- 全局样式 + CSS 变量
│  │  │  └─ App.tsx              <- 入口
│  │  ├─ package.json
│  │  └─ tsconfig.json
│  └─ backend/                   <- 后端应用
│     ├─ src/
│     │  ├─ controller/          <- 接口层
│     │  ├─ service/             <- 业务逻辑层
│     │  ├─ repository/          <- 数据访问层
│     │  ├─ entity/              <- 实体/模型
│     │  ├─ dto/                 <- 请求/响应 DTO
│     │  ├─ config/              <- 配置类
│     │  ├─ exception/           <- 异常处理
│     │  └─ Application.java     <- 入口（按语言调整）
│     ├─ pom.xml / package.json / go.mod（按语言）
│     └─ src/main/resources/
│        ├─ application.yml      <- 主配置
│        ├─ application-dev.yml  <- 开发环境
│        └─ application-prod.yml <- 生产环境
├─ db/
│  ├─ migration/                 <- 数据库迁移脚本
│  ├─ seed/                      <- 初始数据
│  └─ schema.sql                 <- DDL 汇总
├─ deploy/
│  ├─ docker-compose.yml
│  ├─ Dockerfile.frontend
│  ├─ Dockerfile.backend
│  └─ nginx.conf                 <- 反向代理（如有前端）
├─ scripts/
│  ├─ setup.ps1                  <- Windows 一键环境搭建
│  ├─ setup.sh                   <- Linux/Mac 一键环境搭建
│  ├─ build.ps1                  <- 构建脚本
│  └─ check-env.ps1              <- 环境检测
├─ docs/
│  ├─ requirements.md            <- 需求文档
│  ├─ architecture.md            <- 架构说明
│  ├─ api.md                     <- API 接口文档
│  ├─ deployment.md              <- 部署指南
│  └─ defense-report.md          <- 答辩报告（如需要）
├─ tests/                        <- 测试目录
│  ├─ unit/                      <- 单元测试
│  └─ integration/               <- 集成测试
├─ .env.example                  <- 环境变量示例
├─ .gitignore
├─ README.md                     <- 项目说明
└─ _workflow/                    <- 工作流状态（不纳入版本控制）
```

### 纯后端 / API 服务项目

```text
workspace/<project-name>/
├─ src/
│  ├─ controller/
│  ├─ service/
│  ├─ repository/
│  ├─ entity/
│  ├─ dto/
│  ├─ config/
│  └─ exception/
├─ db/
├─ deploy/
├─ scripts/
├─ docs/
├─ tests/
├─ .env.example
├─ .gitignore
├─ README.md
└─ _workflow/
```

### CLI 工具项目

```text
workspace/<project-name>/
├─ src/
│  ├─ commands/                  <- 命令定义
│  ├─ utils/                     <- 工具函数
│  └─ main.py / main.go / ...   <- 入口
├─ docs/
├─ tests/
├─ scripts/
├─ .env.example
├─ .gitignore
├─ README.md
└─ _workflow/
```

### 目录生成规则

- Builder 在 Layer 1（骨架层）必须先创建完整目录结构（含空的占位文件）
- 每个目录必须有说明其用途的注释或 README
- `_workflow/` 目录必须写入 `.gitignore`
- `.env.example` 必须在 Layer 1 就创建，包含所有环境变量占位

## 状态目录

每个项目的工作流状态保存在：

```text
workspace/<project-name>/_workflow/
├─ requirements.json       <- Planner 输出
├─ architecture.json       <- Architect 输出
├─ build-report.json       <- Builder 输出
├─ quality-report.json     <- QA 输出
└─ fix-report.json         <- FixRouter/Specialist 输出
```

Schema 定义在 `workflow/schema/*.schema.json`。

## 阶段与角色映射

```text
Stage 0: 初始化
  │  创建 workspace/<project-name>/_workflow/ 目录
  │
Stage 1: 需求梳理 [Planner]
  │  读取：需求文档（如有）
  │  输出：requirements.json
  │
Stage 2: 架构设计 [Architect]
  │  读取：requirements.json
  │  输出：architecture.json
  │
Stage 3: 代码生成 [Builder]
  │  读取：architecture.json + requirements.json
  │  输出：build-report.json + 代码文件
  │
Stage 4: 质量检查 [QA]
  │  读取：requirements.json + architecture.json + build-report.json
  │  输出：quality-report.json
  │
Stage 5: 修正循环 [FixRouter → Specialist]（条件触发）
  │  读取：quality-report.json（仅当 overall_status != "pass"）
  │  路由：按 category 分流到专项 Skill
  │  输出：fix-report.json
  │
Stage 6: 收尾
     │  确认所有修正完成
     │  生成项目答辩准备报告 → workspace/<project>/docs/defense-report.md
     │  输出最终交付物清单
```

## 角色切换规则

### 进入下一个角色的条件

| 当前角色 | 切换条件 | 下一角色 |
|---------|---------|---------|
| Planner | 输出 requirements.json 完成 | Architect |
| Architect | 输出 architecture.json 完成 | Builder |
| Builder | 输出 build-report.json 完成 | QA |
 QA | 输出 quality-report.json 完成 | 见下表 |
| FixRouter | 输出问题路由结果 | Specialist |
| Specialist | 输出 fix-report.json | QA（回归检查） |

### QA 之后的分支

| quality-report.overall_status | 动作 |
|------------------------------|------|
| `pass` | 进入 Stage 6 收尾 |
| `fail` | 进入 Stage 5 修正循环 |
| `partial` | 询问用户是否继续修正 |

### 修正循环的终止条件

- quality-report.overall_status 变为 `pass`
- 用户明确说"停止修正"
- 达到最大修正轮数（默认 3 轮，可配置）

## 交互模式（全局生效）

**所有需要用户输入或确认的环节，必须使用 AskUserQuestion 工具以选项形式呈现**，包括但不限于：

- 需求确认问题
- 技术选型问题
- 功能模块选择
- 阶段间推进确认（如"要继续吗？"→ 提供"继续 / 返回修改 / 暂停"选项）
- 质量检查后的修正确认
- 任何其他需要用户决策的节点

规则：
- 用户点击选项回答，不需要手动打字
- 每轮最多 4 个问题
- 每个问题提供 2-4 个选项 + 推荐标记
- 可以开启 multiSelect 允许多选
- 术语解释写在选项的 description 字段里
- 阶段间确认至少提供"继续 / 返回修改 / 暂停"三个选项

## 小白模式（全局生效）

无论当前是哪个角色，以下规则始终生效：

- 术语首次出现必须解释"是什么 + 解决什么问题"
- 给技术选项时必须附：适用场景、优点、代价
- 给推荐方案时必须说明"为什么推荐"
- 每轮对话结束，用一句话总结"刚才做了什么、下一步要做什么"

## 产出约束（全局生效）

每个阶段结束，必须输出以下三样东西：

1. **文件清单**：新增/修改了哪些文件（路径 + 动作 + 简述）
2. **启动方式**：如何运行这一阶段的产物（命令/脚本）
3. **验收点**：用户应看到什么结果/如何判断这一阶段完成

## 角色定义文件

| 角色 | 定义文件 | 对应 Skill |
|------|---------|-----------|
| Planner | `workflow/roles/planner.md` | `project-scaffold-generator` |
| Architect | `workflow/roles/architect.md` | 内置（无独立 Skill） |
| Builder | `workflow/roles/builder.md` | `project-scaffold-generator`（Phase 5） |
| QA | `workflow/roles/qa.md` | `project-scaffold-generator`（Phase 6） |
| FixRouter | `workflow/roles/fix-router.md` | `project-fix-generator` |
| Specialist | `workflow/roles/specialist.md` | `frontend/backend/database/ui-style/engineering-fix-generator` |

## 平台适配

本文件不绑定任何平台。无论你用 Trae / Claude Code / Codex 还是其他 Agent，只要：

1. Agent 能读取本文件理解工作流
2. Agent 能读写 `workspace/_workflow/` 下的 JSON 文件
3. Agent 能按角色定义切换行为

就可以运行整个工作流。
