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
     │  自动打包可分发 zip（排除 target/、node_modules/、.tools/、.idea/、_workflow/）
     │  生成项目答辩准备报告 → workspace/<project>/docs/defense-report.md
     │  输出最终交付物清单（含 zip 路径和大小）
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

### 强制规则

**所有需要用户输入或确认的环节，必须且只能使用 AskUserQuestion 工具以选项形式呈现。严禁要求用户手动打字输入任何内容。**

### 适用范围（穷举）

以下所有环节必须使用 AskUserQuestion，不得遗漏：

| 阶段 | 交互点 | 选项示例 |
|------|--------|---------|
| Stage 1 | 项目类型选择 | "Web 全栈 / 桌面应用 / CLI 工具 / 库/SDK" |
| Stage 1 | 技术栈选择 | "Java+Spring / Python+FastAPI / ..." |
| Stage 1 | 功能模块选择 | 多选模式，列出所有可选模块 |
| Stage 1 | UI 风格选择 | 从 ui-style-library.json 中选 4 个推荐 + 用户自定义 |
| Stage 1 | 安全等级选择 | "个人级 / 开源级 / 企业级" |
| Stage 1 | 构建顺序选择 | "数据优先 / 后端优先 / 契约驱动 / 最小可运行" |
| Stage 2 | 架构确认 | "确认架构 / 调整某项 / 重新设计" |
| Stage 3 | 每个 Layer 完成确认 | "继续下一层 / 小改当前层 / 重做当前层 / 暂停" |
| Stage 4 | QA 结果确认 | "接受并收尾 / 进入修正循环 / 重新检查" |
| Stage 5 | 修正方案确认 | "确认修改 / 跳过此项 / 调整方案" |
| Stage 6 | 最终确认 | "完成 / 还有问题 / 导出报告" |

### 选项格式规范

- 每轮最多 4 个问题
- 每个问题提供 2-4 个选项 + 推荐标记（如"推荐"标签）
- 可以开启 multiSelect 允许多选
- 术语解释写在选项的 description 字段里
- 阶段间确认至少提供"继续 / 返回修改 / 暂停"三个选项
- 必要时最后一个选项设为"其他（我来补充）"作为兜底

## UI 风格多样性规则（全局生效）

### 核心原则

**每个生成的项目必须在视觉上有明显区别**，避免所有项目看起来千篇一律。这是业务需求——客户会注意到项目间的相似性。

### 风格预设库

所有可用风格定义在 `workflow/ui-style-library.json`，共 10+ 种预设：

| 预设 ID | 名称 | 色系 | 适用场景 |
|---------|------|------|---------|
| aurora-blue | 极光蓝 | 蓝色系 | 管理系统、SaaS |
| sunset-orange | 日落橙 | 橙色系 | 教育、培训、社区 |
| forest-green | 森林绿 | 绿色系 | 医疗、环保、农业 |
| royal-purple | 皇家紫 | 紫色系 | 奢侈品、设计、创意 |
| ocean-teal | 海洋青 | 青色系 | 金融、银行、保险 |
| cherry-red | 樱桃红 | 红色系 | 餐饮、电商、娱乐 |
| midnight-dark | 午夜黑 | 深色系 | 开发者工具、技术平台 |
| blossom-pink | 樱花粉 | 粉色系 | 女性社区、健康、社交 |
| slate-corporate | 石墨灰 | 灰色系 | 企业后台、ERP、OA |
| golden-amber | 琥珀金 | 金色系 | 酒店、旅游、高端服务 |
| lime-fresh | 青柠绿 | 黄绿色系 | 年轻化产品、运动、社交 |

### 风格选择规则

**Stage 1（Planner）** 必须在 AskUserQuestion 中呈现风格选择：

1. 从 `ui-style-library.json` 读取所有预设
2. 以 AskUserQuestion 选项形式呈现（最多 4 个选项 + 推荐标记）
3. 推荐逻辑：根据项目类型自动推荐最匹配的风格（参考 profiles 的 category 字段）
4. 用户选定后，将 `style_profile` 写入 `requirements.json`

### 风格强制执行规则

**Stage 3（Builder）** 生成 UI 代码时必须：

1. 读取 `requirements.json` 中的 `style_profile` 字段
2. 从 `ui-style-library.json` 加载对应的完整 tokens（colors、typography、components、layout）
3. **所有 CSS 变量 / 主题配置必须严格使用 tokens 中的值**，不得自行编造颜色或字体
4. 组件样式（按钮圆角、卡片阴影、表格样式等）必须匹配 tokens 中的 `components` 配置
5. 布局参数（侧边栏宽度、内边距、间距）必须匹配 `layout` 配置

### QA 检查规则

**Stage 4（QA）** 必须增加一个检查项：

- `ui_consistency`：检查生成的 UI 代码是否严格遵循 `style_profile` 的 tokens
- 发现不一致时 severity 不得低于 major

### 禁止行为

- 禁止忽略 `style_profile` 使用默认样式
- 禁止在 tokens 之外自行定义颜色值
- 禁止不同项目使用相同风格（除非用户明确指定）

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
