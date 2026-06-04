# 跨平台适配指南

本系统不绑定任何平台。以下是不同 Code Agent 的接入方式。

---

## Trae

**入口**：`.trae/skills/<name>/SKILL.md`

Trae 会自动发现 `.trae/skills/` 目录下的 Skill。你需要自己创建桥接文件：

```powershell
# 一键创建 Trae 桥接（PowerShell）
$skills = @("project-scaffold-generator","project-fix-generator","frontend-fix-generator","backend-fix-generator","database-fix-generator","ui-style-fix-generator","engineering-fix-generator")
foreach ($s in $skills) {
  New-Item -Path ".trae\skills\$s" -ItemType Directory -Force
  @"
---
name: "$s"
description: "见 skills/$s/SKILL.md"
---

# $s

完整内容见 `skills/$s/SKILL.md`（精简版）。
需要更细题库时读取 `docs/skills/$s/appendix.md`。
"@ | Out-File -Encoding utf8 ".trae\skills\$s\SKILL.md"
}
```

**使用**：打开仓库 → 直接说"用 project-scaffold-generator 生成项目"

---

## Claude Code

**入口**：`.claude/skills/<name>/SKILL.md`

Claude Code 支持从 `.claude/skills/` 加载技能（旧版 `.claude/commands/` 已不推荐）。

```powershell
# 一键创建 Claude Code 桥接（PowerShell）
$skills = @("project-scaffold-generator","project-fix-generator","frontend-fix-generator","backend-fix-generator","database-fix-generator","ui-style-fix-generator","engineering-fix-generator")
foreach ($s in $skills) {
  New-Item -Path ".claude\skills\$s" -ItemType Directory -Force
  @"
---
name: "$s"
description: "见 skills/$s/SKILL.md"
---

# $s

完整内容见 `skills/$s/SKILL.md`（精简版）。
需要更细题库时读取 `docs/skills/$s/appendix.md`。
"@ | Out-File -Encoding utf8 ".claude\skills\$s\SKILL.md"
}
```

**使用**：打开仓库 → `/project-scaffold-generator` 或自然语言触发

---

## Codex

**入口**：`AGENTS.md`（根目录已有，无需额外创建）

Codex 原生读取 `AGENTS.md`，不会自动发现 `.trae/` 或 `.claude/` 目录。

**使用**：
1. 打开仓库（Codex 自动读取 AGENTS.md）
2. 直接说"参考 skills/project-scaffold-generator/SKILL.md，生成项目"
3. 需要更细追问时，让 Codex 按需读取 `skills/<name>/SKILL.md`

---

## 其他 Agent

根据平台能力选择策略：

| 平台类型 | 策略 | 做法 |
|---------|------|------|
| 原生 Skill/Command 型 | 直接映射 | 把 `skills/<name>/SKILL.md` 复制到平台要求的目录 |
| 项目指令型 | AGENTS.md 桥接 | 用 `AGENTS.md` 做总入口，按需读取 `skills/` |
| 提示词模板型 | 手动粘贴 | 把 `skills/<name>/SKILL.md` 当模板手动贴给 Agent |

---

## 通用约定

无论哪个平台，核心文件都在：

```text
skills/                          <- 精简版主流程（所有平台共用）
workflow/                        <- 工作流定义（所有平台共用）
docs/skills/                     <- 追问题库（按需加载）
AGENTS.md                        <- Codex / 通用 Agent 入口
```

产出约束不变：每轮结束必须输出 文件清单 + 启动方式 + 验收点。
