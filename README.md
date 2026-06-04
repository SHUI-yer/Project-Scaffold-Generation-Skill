# Project Build Skill Suite

一个面向代码代理（Code Agent）的项目级 Skill 工程。

它的目标不是只解决“生成代码”这一件事，而是把一个完整项目从“需求梳理 -> 技术选型 -> 分阶段构建 -> 偏差修正 -> 专项追问 -> 文档交付”做成一套可复用的 Agent 工作流。

本仓库当前以 **Trae Skill 格式** 为主进行组织，同时兼容迁移到 **Claude Code**，也适合转换为 **Codex / AGENTS.md** 风格的项目指令与提示词模板。

## 项目定位

这个仓库适合下面几类场景：

- 你想让 Agent 根据需求文档自动生成项目骨架
- 你想让 Agent 在生成后支持“后期修正”和“专项深问”
- 你希望同一套规则可以复用到不同 Code Agent 平台
- 你希望 Agent 面向小白用户时，能解释术语、对比优劣、给出推荐，而不是只会堆技术名词

## 当前能力

本仓库已经包含 7 个 Skill：

- `project-scaffold-generator`
  - 通用项目脚手架生成器
  - 负责需求提取、结构化问答、技术栈推荐、UI 风格选择、分阶段构建、质量检查、交付文档生成
- `project-fix-generator`
  - 项目后期修改总入口
  - 负责先做问题归类，再把问题路由到更细的专项 Skill
- `frontend-fix-generator`
  - 前端专项修复
  - 处理页面、交互、路由、类型、联调、状态管理等问题
- `backend-fix-generator`
  - 后端专项修复
  - 处理 Controller、Service、Repository、异常、校验、鉴权等问题
- `database-fix-generator`
  - 数据库专项修复
  - 处理表结构、DDL、索引、迁移、事务、一致性与数据库安全问题
- `ui-style-fix-generator`
  - UI 风格专项修复
  - 处理设计规范、主题、配色、布局、字体、动效、暗黑模式
- `engineering-fix-generator`
  - 工程化专项修复
  - 处理构建、环境变量、Docker、CI/CD、测试、README 与交付文档

## 项目结构

当前目录结构如下：

```text
Project-build-SKILL/
├─ README.md
└─ .trae/
   └─ skills/
      ├─ project-scaffold-generator/
      │  └─ SKILL.md
      ├─ project-fix-generator/
      │  └─ SKILL.md
      ├─ frontend-fix-generator/
      │  └─ SKILL.md
      ├─ backend-fix-generator/
      │  └─ SKILL.md
      ├─ database-fix-generator/
      │  └─ SKILL.md
      ├─ ui-style-fix-generator/
      │  └─ SKILL.md
      └─ engineering-fix-generator/
         └─ SKILL.md
```

### 结构说明

- `.trae/skills/`
  - Trae 的 Skill 根目录
  - 每个子目录代表一个独立 Skill
- `<skill-name>/SKILL.md`
  - Skill 的核心定义文件
  - 一般包含：名称、描述、触发时机、交互规则、问题分类、提问模板、修改顺序、输出要求
- `README.md`
  - 面向人类读者的项目说明文档
  - 说明仓库做什么、怎么用、如何迁移到其他 Agent 平台

## 设计思路

这套 Skill 不是“一个大而全的长 Prompt”，而是拆成两层：

### 第一层：总入口 Skill

- `project-scaffold-generator`
  - 负责“从零开始生成”
- `project-fix-generator`
  - 负责“生成后修正”

### 第二层：专项 Skill

- `frontend-fix-generator`
- `backend-fix-generator`
- `database-fix-generator`
- `ui-style-fix-generator`
- `engineering-fix-generator`

这种结构的好处是：

- 角色清晰：先判断属于哪个问题域，再深挖
- 追问更细：前端问题不会用数据库那套问法
- 扩展更容易：以后可以继续加 `auth-security-fix-generator`、`api-contract-fix-generator`、`docs-fix-generator`
- 适配多平台更容易：总流程和专项流程可以拆开迁移

## 核心功能说明

### 1. 通用项目生成

`project-scaffold-generator` 支持：

- 读取需求文档：`.md` / `.txt` / `.docx`
- 在没有文档时，通过结构化问答梳理需求
- 推荐技术栈并解释推荐理由
- 支持后端语言、架构、数据库、前端框架、UI 风格、安全等级选择
- 支持分阶段构建顺序选择，例如：
  - 数据优先流
  - 后端优先流
  - 前后端契约驱动流
  - 最小可运行流
- 生成质量检查表和交付文档

### 2. 后期修改总入口

`project-fix-generator` 支持：

- 先判断“问题属于哪一类”
- 再决定走哪一个专项 Skill
- 支持需求偏差、技术偏差、功能偏差、UI 偏差、工程化偏差等分类
- 支持修改前确认、修改后回归检查

### 3. 专项深问与增量修复

专项 Skill 的作用是把问题问细，而不是“一上来就改代码”。

例如：

- 前端问题会继续细分成页面结构、交互流程、路由、联调、状态管理
- 后端问题会继续细分成接口入口、业务逻辑、数据访问、异常校验、鉴权权限
- 数据库问题会继续细分成模型设计、DDL、索引、迁移、事务一致性

### 4. 小白友好模式

这是本仓库一个很重要的特性。

所有 Skill 都已经加入“小白友好沟通规范”，包括：

- 术语首次出现时要解释
- 给技术选项时要说明适用场景
- 要做优劣对比，而不是只列名字
- 推荐方案时要解释“为什么推荐它”
- 尽量少用黑话和纯缩写

这意味着：

- 面向熟手时，Agent 可以直接进入细节
- 面向小白时，Agent 会先讲明白，再推进决策

## Skill 之间的协作关系

可以把它理解成一个“分诊系统”：

```text
用户需求 / 用户反馈
        │
        ├─ 从零生成 -> project-scaffold-generator
        │
        └─ 后期修改 -> project-fix-generator
                         │
                         ├─ 前端问题 -> frontend-fix-generator
                         ├─ 后端问题 -> backend-fix-generator
                         ├─ 数据库问题 -> database-fix-generator
                         ├─ UI 问题 -> ui-style-fix-generator
                         └─ 工程化问题 -> engineering-fix-generator
```

## 在 Trae 中使用

这是本仓库当前的原生使用方式。

### 目录要求

Trae 会从项目内的 `.trae/skills/<skill-name>/SKILL.md` 读取 Skill。

本仓库已经符合这一结构，不需要额外转换。

### 使用方式

把仓库作为工作目录打开后，可以直接向 Agent 发出类似请求：

```text
用 project-scaffold-generator 从需求文档生成一个完整项目
```

```text
用 project-fix-generator 修正这个项目，先判断属于哪一类问题
```

```text
用 frontend-fix-generator 修复这个页面的交互流程问题
```

### 适合 Trae 的原因

- 原生支持 `.trae/skills/.../SKILL.md`
- Skill 拆分结构清晰
- 很适合做“总入口 + 专项分流”

## 在 Claude Code 中使用

Claude Code 对 Skill 的支持和这个仓库最接近。

根据 Claude Code 官方文档，Claude 支持以 `.claude/skills/<name>/SKILL.md` 的形式加载技能，并且可以通过 `/skill-name` 直接调用；它也说明 `.claude/commands/` 是旧格式，推荐迁移到 `.claude/skills/<name>/SKILL.md`。[来源 1](https://code.claude.com/docs/en/slash-commands) [来源 2](https://platform.claude.com/docs/en/agent-sdk/slash-commands)

### 推荐迁移方式

把当前目录结构从：

```text
.trae/skills/<name>/SKILL.md
```

映射为：

```text
.claude/skills/<name>/SKILL.md
```

### 最小迁移步骤

1. 在项目根目录创建 `.claude/skills/`
2. 把每个 Skill 子目录复制过去
3. 保留目录名与 `SKILL.md` 文件名
4. 在 Claude Code 中通过 `/skill-name` 或自然语言触发

### 示例

```text
/project-scaffold-generator
从当前目录的需求文档生成项目脚手架
```

```text
/project-fix-generator
分析当前项目为什么不符合需求，并路由到对应专项技能
```

### Claude Code 的优点

- 原生支持 `SKILL.md`
- 可直接把本仓库的结构搬过去
- 适合这种“技能目录化”的组织方式

### Claude Code 的注意点

- 不同版本对前置字段、技能发现、命名空间细节可能有差异
- 如果你还在用旧的 `.claude/commands/` 体系，建议逐步迁移到 `.claude/skills/`

## 在 Codex 中使用

Codex 的思路和 Trae / Claude Code 不太一样。

根据 OpenAI Codex 官方文档，Codex 原生会读取 `AGENTS.md` 这类项目指令文件，而不是直接读取 `.trae/skills/.../SKILL.md` 目录结构。[来源 1](https://developers.openai.com/codex/guides/agents-md) [来源 2](https://learn.microsoft.com/en-my/azure/foundry/openai/how-to/codex?tabs=npm#persistent-guidance-with-agentsmd)

### 这意味着什么

简单说：

- **Trae / Claude Code**
  - 更像“技能目录”
  - 一项技能一个目录，一个 `SKILL.md`
- **Codex**
  - 更像“项目指令链”
  - 重点是 `AGENTS.md`、上下文分层、项目级说明

### 推荐适配方式

在 Codex 中，建议把本仓库当作“Skill 规范库”使用，而不是直接指望 Codex 原样识别 `.trae/skills/`。

最实用的方法是：

1. 在仓库根目录写一个 `AGENTS.md`
2. 在 `AGENTS.md` 中说明：
   - 本仓库有哪些 Skill
   - 每个 Skill 对应什么场景
   - 遇到什么问题时应该参考哪个 `SKILL.md`
3. 在与具体任务相关时，让 Codex 读取对应 `SKILL.md` 内容并执行

### 推荐的 Codex 目录搭配

```text
Project-build-SKILL/
├─ AGENTS.md
├─ README.md
└─ .trae/
   └─ skills/
      └─ ...
```

### Codex 中的实际用法示例

你可以这样对 Codex 说：

```text
请先阅读 AGENTS.md，再参考 .trae/skills/project-scaffold-generator/SKILL.md，
根据当前需求文档生成项目脚手架。
```

或者：

```text
请参考 .trae/skills/project-fix-generator/SKILL.md，
先判断当前问题属于前端、后端、数据库、UI 还是工程化，再提出修改方案。
```

### Codex 的优点

- 项目级规则加载机制清晰
- 适合仓库级统一规范
- 适合把 Skill 体系转成“项目工作协议”

### Codex 的局限

- 不像 Trae / Claude Code 那样天然以 `SKILL.md` 目录为中心
- 更适合“说明 Agent 应该如何工作”，而不是“直接注册一组技能命令”

### 给 Codex 用户的建议

如果你主要在 Codex 中使用本仓库，建议再补两层文件：

- `AGENTS.md`
  - 面向 Codex 的总说明
- `docs/skills/*.md`
  - 从各个 `SKILL.md` 抽取出的更短版本，方便按需加载

## 在其他主流 Code Agent 中使用

不同 Agent 的“技能系统”名字不一样，但大体可以分成三类：

### 第一类：原生 Skill / Command 型

特点：

- 支持把一个 Markdown 文件或技能目录当成可复用命令
- 更接近 Claude Code / Trae 的模式

适配方式：

- 直接保留每个 Skill 的独立文件
- 把 `SKILL.md` 迁移到目标平台要求的目录结构
- 保持“一个技能负责一类任务”

### 第二类：项目指令型

特点：

- 更偏向 `AGENTS.md` / 项目说明文件
- 没有明显的“技能注册目录”

适配方式：

- 把本仓库当作“Agent 行为规范库”
- 在项目根目录声明：
  - 有哪些技能
  - 遇到哪些问题看哪个文件
  - 默认流程是什么

### 第三类：提示词模板型

特点：

- 不一定支持自动发现技能
- 但支持保存工作流 Prompt、工作区说明或命令模板

适配方式：

- 把每个 `SKILL.md` 当作一份高质量模板
- 在需要时手动贴给 Agent
- 或拆成多个更短的模板文档，按场景调用

## 给主流 Agent 的通用迁移策略

如果你不确定某个平台是否支持 Trae Skill，可以按下面的策略处理。

### 策略 A：原生兼容优先

适合场景：

- 目标平台本身支持 `SKILL.md` 或接近的技能机制

做法：

- 直接迁移目录结构
- 只改根目录名和平台元信息

优点：

- 迁移成本低
- 能保留技能拆分结构

缺点：

- 依赖平台本身支持类似机制

### 策略 B：AGENTS.md 桥接

适合场景：

- 平台更偏项目说明和全局指令，不偏“技能目录”

做法：

- 写一个总入口 `AGENTS.md`
- 在里面声明技能清单、调用时机、默认流程
- 需要时再让 Agent 读取具体 `SKILL.md`

优点：

- 与 Codex 这类平台更匹配
- 适合仓库级统一说明

缺点：

- 不如原生 Skill 那样直接

### 策略 C：模板库方式

适合场景：

- 平台没有正式 Skill 机制
- 但支持保存工作模板、知识库或提示词片段

做法：

- 保留本仓库作为“技能模板库”
- 按需复制某个 `SKILL.md` 的内容给 Agent

优点：

- 几乎所有 Agent 都能用

缺点：

- 自动化程度最低

## 推荐使用方式

如果你问“哪种方式最省心”，建议如下：

### 如果你主要用 Trae

推荐：

- 直接使用当前仓库结构

原因：

- 本仓库本来就是为这个结构写的

### 如果你主要用 Claude Code

推荐：

- 把 `.trae/skills/` 复制到 `.claude/skills/`

原因：

- 结构最接近
- 迁移成本最低

### 如果你主要用 Codex

推荐：

- 以 `AGENTS.md + Skill 文档库` 的方式使用

原因：

- 更符合 Codex 的加载方式
- 更容易让 Codex 稳定遵守流程

### 如果你用的是其他 Agent

推荐：

- 先用“模板库方式”
- 再逐步判断要不要做平台专用适配

原因：

- 最稳
- 不容易因为平台机制差异而失效

## 如何扩展这个仓库

如果你后面要继续补 Skill，建议遵守以下原则：

### 1. 一个 Skill 只解决一类问题

不要把前端、后端、数据库、部署全塞进一个文件。

### 2. 先总入口，再专项分流

先让总入口判断“问题属于哪一类”，再进入专项深问。

### 3. 每轮问题不要太多

现在仓库里大多数 Skill 都遵循：

- 每轮最多 4 个问题
- 优先用选项，不用纯开放式提问

### 4. 默认支持小白模式

新增 Skill 时建议继续保留：

- 术语解释
- 优劣对比
- 推荐理由
- 少黑话

### 5. 把输出也模板化

一个好 Skill 不只要会问，还要会交付。

建议保持这些输出习惯：

- 问题归类卡
- 修改方案卡
- 修改对照表
- 回归检查表

## 适合谁使用

这个仓库特别适合以下人群：

- 想搭建自己 Agent 工作流的人
- 想给团队沉淀一套项目生成和修正规范的人
- 想把 AI 从“随便问问”升级成“稳定流程工具”的人
- 想让 Agent 既能服务熟手，也能服务小白用户的人

## 后续建议

如果你准备继续完善这个仓库，推荐下一步做这几件事：

### 1. 增加 `AGENTS.md`

这样对 Codex 会更友好。

### 2. 增加 `docs/`

例如：

```text
docs/
├─ platform/
│  ├─ trae.md
│  ├─ claude-code.md
│  ├─ codex.md
│  └─ generic-agent.md
└─ skills/
   ├─ scaffold.md
   ├─ project-fix.md
   ├─ frontend-fix.md
   ├─ backend-fix.md
   ├─ database-fix.md
   ├─ ui-style-fix.md
   └─ engineering-fix.md
```

### 3. 增加平台桥接文件

例如：

- `AGENTS.md`：给 Codex
- `.claude/skills/`：给 Claude Code
- `.trae/skills/`：给 Trae

### 4. 增加示例任务

比如：

- “从需求文档生成一个图书管理系统”
- “修复前端登录页联调失败”
- “补齐 Docker 和 README”

这样新用户上手更快。

## 许可证与说明

当前仓库更像一个 **Skill 工程模板 / Agent 工作流模板仓库**。

它不绑定某一个业务项目，而是服务于“如何让 Agent 更稳定、更结构化地完成项目生成与修改”这个目标。

如果你打算把它推广给团队使用，建议至少补齐：

- LICENSE
- CHANGELOG
- AGENTS.md
- 平台适配说明

## 参考资料

- OpenAI Codex `AGENTS.md` 官方说明：
  - [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- Azure 文档中对 Codex `AGENTS.md` 的说明：
  - [Codex with Azure OpenAI in Microsoft Foundry Models](https://learn.microsoft.com/en-my/azure/foundry/openai/how-to/codex?tabs=npm#persistent-guidance-with-agentsmd)
- Claude Code Skills / Slash Commands 官方说明：
  - [Extend Claude with skills](https://code.claude.com/docs/en/slash-commands)
  - [Slash Commands in the SDK](https://platform.claude.com/docs/en/agent-sdk/slash-commands)
