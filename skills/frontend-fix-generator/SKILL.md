---
name: "frontend-fix-generator"
description: "前端专项修改生成器：定位页面、交互、路由、类型与联调问题并细致追问。用户要求修复前端问题时调用。"
---

# frontend-fix-generator

## 触发条件

- 页面缺失/页面不对/交互不顺/路由跳转异常/前端报错/接口联调不通
- `project-fix-generator` 将主归类判定为前端问题

## 小白模式

- 术语首次出现必须解释：
  - 路由 = 页面跳转规则（输入 URL 显示哪个页面）
  - 联调 = 前后端对接（前端发请求，后端返回数据）
  - TypeScript 类型 = 数据结构说明（告诉代码这个数据长什么样）
  - 拦截器 = 统一处理器（每个请求/响应都经过它处理）
  - 状态管理 = 全局数据仓库（多个页面共享数据）
  - 组件 = 可复用的 UI 积木（按钮、表格、弹窗等）
- 给方案时说明"改哪里、影响什么、如何验收"

## 框架识别

**修改前必须先识别项目使用的前端框架**（读 package.json 或目录结构）：

| 框架 | 关键文件 | 关键特征 |
|------|---------|---------|
| Vue 3 | `src/main.ts`、`*.vue` | `createApp`、`<template>`、`<script setup>` |
| React | `src/main.tsx`、`*.tsx` | `ReactDOM.createRoot`、`useState`、`JSX` |
| SvelteKit | `src/routes/+page.svelte` | `{#each}`、`{#if}`、`$:` |
| Next.js | `src/app/` 或 `pages/` | `use client`、`getServerSideProps` |

**识别后必须使用对应框架的代码模式修复，不得混用其他框架语法。**

## 问题分类（6 大类）

### 1. 页面结构问题
- 缺失页面（路由存在但组件文件不存在）
- 布局错误（侧边栏/顶栏/内容区显示异常）
- 组件拆分不合理（单文件过大、重复代码）

**Vue 3 修复模式：**
- 缺页面 → 创建 `views/Xxx.vue`，在 router 中添加路由
- 布局错 → 检查 Layout.vue 的 `<el-container>` / `<el-aside>` / `<el-main>` 结构
- 重复代码 → 提取到 `components/` 或 `composables/`

**React 修复模式：**
- 缺页面 → 创建 `pages/Xxx.tsx`，在 router 中添加 `<Route>`
- 布局错 → 检查 Layout.tsx 的 `<Layout.Sider>` / `<Layout.Content>` 结构
- 重复代码 → 提取到 `components/` 或 `hooks/`

### 2. 交互流程问题
- 表单提交失败（验证不通过、提交后无响应）
- 弹窗不显示/不关闭
- 加载状态不消失（loading 卡住）
- 错误提示不友好（用户看不懂的报错）

**Vue 3 修复模式：**
- 表单验证 → 检查 `rules` 对象和 `<el-form-item prop="xxx">` 绑定
- 弹窗 → 检查 `v-model="dialogVisible"` 绑定
- loading → 确保 `finally` 中 `loading.value = false`
- 错误提示 → 检查 `ElMessage.error()` 是否正确调用

**React 修复模式：**
- 表单验证 → 检查 antd `<Form>` 的 `rules` 和 `<Form.Item name="xxx">`
- 弹窗 → 检查 `useState` 控制 `open`/`visible`
- loading → 确保 `finally` 中 `setLoading(false)`
- 错误提示 → 检查 `message.error()` 是否正确调用

### 3. 路由导航问题
- 刷新页面 404（路由未配置 history 模式）
- 路由守卫不生效（Token 检查逻辑错误）
- 菜单与路由不对应（menu item 的 index 与 path 不一致）
- 登录后不跳转首页

**通用修复模式：**
- 刷新 404 → 检查 Vite proxy 或后端 history 模式 fallback
- 守卫失效 → 检查 `beforeEach` / `ProtectedRoute` 逻辑
- 菜单不对应 → 检查 `el-menu` 的 `:default-active="route.path"`
- 登录不跳转 → 检查 `router.push('/')` 是否在登录成功后调用

### 4. 类型与接口联调问题
- 请求报错 400/422（请求参数类型不匹配）
- 响应数据 undefined（字段名不一致）
- TypeScript 编译错误（类型不匹配）
- `any` 类型泛滥（失去类型保护）

**修复模式：**
- 请求参数类型不匹配 → 对比后端 Controller 参数类型和前端 API 调用参数
- 字段名不一致 → 对比后端 JSON 响应字段和前端 TypeScript 接口定义
- TypeScript 错误 → 读取 IDE 错误信息，修正类型定义
- any 泛滥 → 逐步替换为具体类型（`any` → `Student`、`PageResult<Student>`）

### 5. 状态与性能问题
- 登录状态丢失（刷新后 Token 消失）
- 重复请求（同一接口调用多次）
- 页面卡顿（大量数据未分页）

**修复模式：**
- Token 丢失 → 检查 localStorage 读写逻辑，确保 `onMounted` 时恢复
- 重复请求 → 检查 `onMounted` / `useEffect` 是否重复调用 API
- 卡顿 → 确保分页参数 `page`/`size` 正确传递

### 6. 样式与 UI 问题
- 主题色不一致（部分组件颜色不对）
- 响应式布局失效（移动端显示异常）
- 组件样式被覆盖（scoped 样式失效）

**Vue 3 修复模式：**
- 主题色 → 检查 CSS 变量 `--primary-color` 和 Element Plus 主题配置
- 响应式 → 检查 `<el-row>` / `<el-col>` 的 `:span` 和 `:xs` 属性
- scoped 失效 → 检查 `<style scoped>` 是否存在，避免全局样式污染

**React 修复模式：**
- 主题色 → 检查 antd `ConfigProvider` 或 MUI `createTheme` 配置
- 响应式 → 检查 antd `<Row>` `<Col>` 或 MUI `Grid` 的断点配置
- 样式冲突 → 检查 CSS Modules 或 styled-components 使用是否正确

## 修复流程

### Step 1: 读取上下文
- 读取 `requirements.json` 获取项目范围和功能列表
- 读取 `quality-report.json` 获取 QA 发现的前端问题清单
- 识别前端框架类型

### Step 2: 问题定位
- 读取相关源码文件
- 对比 QA 检查项定位具体违规
- 如信息不足，使用 AskUserQuestion 追问（最多 4 题）

### Step 3: 输出修改方案
- 目标文件清单（含修改行号范围）
- 修改内容概要
- 影响范围评估
- 验收点

### Step 4: 执行修复
- 修改文件（必须符合 builder.md 对应框架的强制清单）
- 修复后立即自检（对比 qa.md 检查项）

### Step 5: 交付
- 文件清单
- 启动方式（dev server / build）
- 验收点（页面路径、操作步骤、期望结果）

## 代码质量底线

- 禁止 `any` 类型（TypeScript 项目）
- 禁止直接操作 DOM（使用框架响应式 API）
- API 请求必须有错误处理（try/catch + 用户提示）
- 所有交互必须有 loading 状态和错误状态
- 删除操作必须有二次确认
