# Project Build Skill Suite（Agent 指令）

你在一个"多 Agent 工作流系统"里工作。这里的目标是让你用一套固定路线图完成：

- 从零生成项目脚手架（6 个角色按阶段轮换）
- 生成后偏差修正（FixRouter 分流 + Specialist 深问）
- 分阶段产出（每阶段都可验收）
- 跨平台适配（不绑定单一 IDE）

## 核心架构

本系统是**伪多 Agent 工作流**：一个会话中按角色轮换执行，通过 JSON 状态文件传递上下文。

### 工作流定义

- 调度器：`workflow/orchestrator.md`（必须首先读取）
- 角色定义：`workflow/roles/<role>.md`
- JSON Schema：`workflow/schema/*.schema.json`

### 工作流阶段

```text
Stage 0: 初始化 → 创建 workspace/<project>/_workflow/
Stage 1: Planner（需求梳理） → requirements.json
Stage 2: Architect（架构设计） → architecture.json
Stage 3: Builder（代码生成） → build-report.json + 代码
Stage 4: QA（质量检查） → quality-report.json
Stage 5: FixRouter → Specialist（修正循环，条件触发）
Stage 6: 收尾
```

### 状态文件

所有中间状态保存在 `workspace/<project-name>/_workflow/`：

```text
├─ requirements.json       <- Planner 输出
├─ architecture.json       <- Architect 输出
├─ build-report.json       <- Builder 输出
├─ quality-report.json     <- QA 输出
└─ fix-report.json         <- Specialist 输出
```

## 重要约束（必须遵守）

- **先读 orchestrator.md**：每次开始新工作流前，必须先读取 `workflow/orchestrator.md`
- **产出优先**：每个阶段结束必须输出 文件清单 + 启动方式 + 验收点
- **状态驱动**：每个角色必须读取上一个角色的 JSON 输出作为输入
- **工作区隔离**：生成的项目输出到 `workspace/<project-name>/`，不得散落仓库根目录
- **按需加载**：优先使用 `skills/` 精简版；只有需要更细追问时才读取 `docs/skills/` 下的附录

## 角色与 Skill 映射

| 角色 | 对应 Skill | 定义文件 |
|------|-----------|---------|
| Planner | `project-scaffold-generator` | `workflow/roles/planner.md` |
| Architect | 内置（无独立 Skill） | `workflow/roles/architect.md` |
| Builder | `project-scaffold-generator`（Phase 5） | `workflow/roles/builder.md` |
| QA | `project-scaffold-generator`（Phase 6） | `workflow/roles/qa.md` |
| FixRouter | `project-fix-generator` | `workflow/roles/fix-router.md` |
| Specialist | 前端/后端/数据库/UI/工程化专项 Skill | `workflow/roles/specialist.md` |

## 平台桥接

- Trae：使用 `.trae/skills/<name>/SKILL.md`（按 `docs/platform-bridge.md` 指南创建）
- Claude Code：使用 `.claude/skills/<name>/SKILL.md`（同上）
- Codex：使用本 `AGENTS.md`，并按需读取 `skills/<name>/SKILL.md`
- 所有平台共用：`workflow/orchestrator.md`（工作流定义）+ `skills/`（精简版 Skill）

## 小白模式（全局生效）

- 术语首次出现必须解释"是什么 + 解决什么问题"
- 给选项时必须附：适用场景、优点、代价
- 给推荐时必须说明"为什么推荐"
- 每阶段结束用一句话总结"刚才做了什么、下一步要做什么"
