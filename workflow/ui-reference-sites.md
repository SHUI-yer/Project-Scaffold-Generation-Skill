# Agent UI 设计参考网站清单

> 当 Agent 在构建前端 UI 时遇到设计不确定的情况，按照本清单中的网站进行参考和模仿。
> 设计不是凭空想象，而是站在巨人肩膀上。

---

## 一、UI 视觉灵感网站（找设计方向）

| 网站 | URL | 用途 | 搜索建议 |
|------|-----|------|----------|
| **Dribbble** | https://dribbble.com | UI 视觉灵感、配色方案、组件概念图 | 搜索 `{项目类型} dashboard`、`{风格名} ui design` |
| **Mobbin** | https://mobbin.com | 真实 App UI 截图库，按平台/组件类型筛选 | 搜索 `login page`、`navigation`、`settings`、`onboarding` |
| **Godly** | https://godly.website | 高质量网站设计，偏创意和艺术方向 | 按类别浏览：e-commerce、portfolio、saas |
| **Lapa.ninja** | https://lapa.ninja | Landing page 和营销页面设计参考 | 搜索行业关键词获取同类型设计 |
| **Refero** | https://refero.design | 真实产品 UI 截图，按组件筛选 | 筛选 `data table`、`modal`、`navigation` |
| **Page Flows** | https://pageflows.com | 完整用户流程录屏 | 搜索 `onboarding`、`checkout`、`signup` |
| **UI Patterns** | https://www.ui-patterns.com | 常见交互模式文档和解决方案 | 搜索具体交互问题 |
| **CollectUI** | https://collectui.com | 170+ 类别的组件设计参考 | 按组件类别搜索 |

## 二、大厂设计系统文档（找规范标准）

| 设计系统 | URL | 适用场景 |
|----------|-----|----------|
| **Material Design 3** | https://m3.material.io | Android/Web 全平台，现代设计标准 |
| **Apple HIG** | https://developer.apple.com/design/human-interface-guidelines | iOS/macOS 应用，高端感设计 |
| **Ant Design** | https://ant.design | 企业级管理系统，中国开发者首选 |
| **Semi Design** | https://semi.design | 字节系产品风格，主题定制灵活 |
| **Chakra UI** | https://chakra-ui.com | React 项目，无障碍设计 |
| **Shopify Polaris** | https://polaris.shopify.com | 电商/SaaS 产品设计 |
| **Carbon Design** | https://carbondesignsystem.com | IBM 风格，数据密集型应用 |
| **Atlassian Design** | https://atlassian.design | 项目管理/协作工具风格 |

## 三、前端组件库参考（找实现方式）

| 组件库 | URL | 适用框架 | 设计特点 |
|--------|-----|----------|----------|
| **Element Plus** | https://element-plus.org | Vue 3 | 经典企业级，信息密度高 |
| **Ant Design Vue** | https://www.antdv.com | Vue 3 | 蚂蚁设计，全面企业方案 |
| **Naive UI** | https://www.naiveui.com | Vue 3 | 现代感，深色主题友好 |
| **Arco Design** | https://arco.design | Vue 3 / React | 字节跳动，简洁现代 |
| **shadcn/ui** | https://ui.shadcn.com | React | 极简美学，代码可控 |
| **MUI (Material UI)** | https://mui.com | React | Google Material Design 实现 |
| **Ant Design** | https://ant.design | React | 企业级全面解决方案 |
| **Chakra UI** | https://chakra-ui.com | React | 灵活组合，无障碍优先 |
| **Flowbite** | https://flowbite.com | Tailwind CSS | 免费组件，快速搭建 |
| **daisyUI** | https://daisyui.com | Tailwind CSS | 组件类名，极速开发 |

## 四、配色和字体工具

| 工具 | URL | 用途 |
|------|-----|------|
| **Coolors** | https://coolors.co | 配色方案生成器 |
| **Color Hunt** | https://colorhunt.co | 热门配色方案集合 |
| **Adobe Color** | https://color.adobe.com | 专业配色工具（色轮、对比度检查） |
| **Google Fonts** | https://fonts.google.com | 免费 Web 字体 |
| **Font Pair** | https://fontpair.co | 字体搭配建议 |
| **Type Scale** | https://typescale.com | 排版比例计算器 |

## 五、图标资源

| 资源 | URL | 格式 | 说明 |
|------|-----|------|------|
| **Lucide Icons** | https://lucide.dev | SVG | shadcn/ui 默认图标库，简洁统一 |
| **Heroicons** | https://heroicons.com | SVG | Tailwind CSS 配套图标 |
| **Ant Design Icons** | https://ant.design/components/icon | SVG | Ant Design 图标 |
| **Material Icons** | https://fonts.google.com/icons | SVG/Web Font | Google Material 图标 |
| **Phosphor Icons** | https://phosphoricons.com | SVG | 多粗细变体，风格现代 |
| **Iconoir** | https://iconoir.com | SVG | 开源，风格统一 |
| **Remix Icon** | https://remixicon.com | SVG | 2000+ 图标，风格圆润 |

---

## 使用指南

### 当 Agent 不知道怎么设计时，按以下步骤操作：

1. **确定项目类型** → 在 `ui-style-library.json` 的 `business_templates` 中匹配
2. **选择设计系统** → 根据技术栈和目标用户选择 Google/Apple/社交风格
3. **找视觉灵感** → 根据项目类型在上面的灵感网站搜索同类型设计
4. **确定组件库** → 根据框架选择对应的组件库
5. **实施** → 参考设计系统文档的颜色/排版/间距规范进行编码

### 搜索模板

根据项目类型，在灵感网站搜索以下关键词：

| 项目类型 | 搜索关键词 |
|----------|-----------|
| 管理后台 | `{framework} admin dashboard`, `SaaS dashboard UI` |
| 电商 | `e-commerce product page`, `shopping cart UI design` |
| 社交 | `social media feed design`, `twitter clone UI` |
| 教育 | `LMS dashboard`, `online course platform` |
| 数据分析 | `analytics dashboard`, `data visualization UI` |
| 企业官网 | `corporate landing page`, `SaaS homepage` |
| 博客/CMS | `blog design`, `content management UI` |
| 移动端 | `mobile app {type} design iOS/Android` |
