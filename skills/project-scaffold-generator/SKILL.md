---
name: "project-scaffold-generator"
description: "通用项目脚手架生成器：从需求文档或结构化问答提取需求，确认技术栈后按阶段生成可运行项目与交付文档。用户要求从零生成新项目时调用。"
---

# project-scaffold-generator

## 一句话目标

把“需求”变成“可运行项目”，并让用户每个阶段都能看到产出与验收点。

## 触发条件（何时用）

- 用户要从零生成项目脚手架/模板/初始化工程
- 用户提供需求文档，希望自动提取模块并生成工程
- 用户没有文档，希望用结构化问答快速梳理需求

## 小白模式（必须支持）

- 若用户不理解术语，术语首次出现必须解释“是什么 + 解决什么问题”
- 给选项时必须附：适用场景、优点、代价/缺点、不推荐场景
- 给推荐方案时必须说明“为什么推荐、为什么不是另一个”

## 工作区隔离（强制）

生成项目不得把文件散落到仓库根目录，必须输出到一个新目录：

- 默认：`workspace/<project-name>/`
- 企业级分区建议（按需使用）：
  - `apps/frontend/`
  - `services/backend/`
  - `db/`
  - `deploy/`
  - `docs/`
  - `scripts/`

如果用户不同意目录结构，先给 2–4 个选项让用户选一个，再开始生成。

## 路线图（强约束调用链）

- 从零生成：必须走本 Skill
- 生成后不满意：必须切换到 `project-fix-generator`
- 遇到专项问题：由 `project-fix-generator` 分流到前端/后端/数据库/UI/工程化专项 Skill

## 最短流程（7 Phase，精简版）

### Phase 1：需求获取

- 扫描 `input/` 目录下的需求文档，自动执行三步转换链：
  1. `.doc` → `.docx`：运行 `python scripts/doc2docx.py input/`（需 pywin32 + Word/WPS）
  2. `.docx` → `.md`：运行 `python scripts/docx2md.py input/ md`（需 python-docx）
  3. `.md/.txt`：直接读取
- 若无文档或转换失败：进入结构化问答（每轮最多 4 题，**必须使用 AskUserQuestion 工具以选项形式呈现**，用户点击选择）

### Phase 2：需求分析

输出一张 Markdown 需求表：项目类型/功能模块/用户角色/数据模型/技术栈/部署/安全，并标注“已确定/待确认”。

### Phase 3：细节追问（最多 5 轮）

目标：把“待确认项”补齐到可生成。

要求：
- 每轮最多 4 题
- 只问缺失项
- 选项式优先，必要时允许“其他（我来补充）”

### Phase 4：UI 风格选择

确认设计规范、主题模式、配色方案、动画风格、字体方案、布局模式，并生成全局 CSS 变量与暗黑模式适配。

### Phase 5：按阶段生成（产出优先）

先让用户选择构建顺序（给 2–4 个科学选项，如：数据库->后端->前端、契约驱动、最小可运行等），然后按顺序逐段生成。

每一段（每一层）生成后必须输出：
- 文件清单（新增/修改了哪些文件）
- 启动方式（如何运行这一段）
- 验收点（用户应看到什么结果/如何判断这一段完成）
- 用户确认选项（确认/小改/重做/跳过）

### Phase 6：Quality Gate

输出需求对照表：需求项 | 是否实现 | 实现位置 | 备注。对未实现项主动询问是否补齐。

### Phase 7：交付物

输出 docs/ 下的交付文档（基于模板生成，Markdown）：
- 打包指南（模板：`workflow/templates/packaging-guide.md`）
- 项目总结介绍（模板：`workflow/templates/project-summary.md`）
- 答辩准备报告（模板：`workflow/templates/defense-report.md`）

## 可选加载（追问题库）

需要更细追问题库时，按需读取：

- docs/skills/project-scaffold-generator/appendix.md
