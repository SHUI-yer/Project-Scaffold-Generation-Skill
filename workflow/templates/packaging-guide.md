# {{PROJECT_NAME}} — 项目打包指南

> 生成时间：{{GENERATED_AT}}
> 本指南由 Project Build Skill Suite 自动生成，请根据实际环境补充。

---

## 一、环境要求清单

### 1.1 必装软件

| 软件 | 最低版本 | 推荐版本 | 用途 | 下载地址 |
|------|---------|---------|------|---------|
| {{LANGUAGE}} | {{MIN_VERSION}} | {{RECOMMEND_VERSION}} | 运行后端 | {{DOWNLOAD_URL}} |
| {{PACKAGE_MANAGER}} | - | latest | 依赖管理 | {{DOWNLOAD_URL}} |
| {{DATABASE}} | {{DB_MIN_VERSION}} | {{DB_RECOMMEND_VERSION}} | 数据存储 | {{DOWNLOAD_URL}} |
| Node.js（如有前端） | {{NODE_MIN}} | {{NODE_RECOMMEND}} | 运行前端 | https://nodejs.org |

### 1.2 可选软件

| 软件 | 用途 | 何时需要 |
|------|------|---------|
| Docker | 容器化部署 | 生产部署或不想手动装数据库时 |
| Git | 版本管理 | 克隆仓库时 |

### 1.3 环境变量

复制 `.env.example` 为 `.env`，按以下说明填写：

| 变量名 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
{{ENV_VARIABLES_TABLE}}

---

## 二、一键构建脚本

### 2.1 Windows（PowerShell）

```powershell
# 首次搭建（安装依赖 + 初始化数据库 + 启动）
./scripts/setup.ps1

# 仅启动
./scripts/build.ps1 start

# 仅构建
./scripts/build.ps1 build

# 环境检测（检查是否装齐了所有依赖）
./scripts/check-env.ps1
```

### 2.2 Linux / macOS（Shell）

```bash
# 首次搭建
chmod +x scripts/setup.sh
./scripts/setup.sh

# 仅启动
./scripts/build.sh start

# 环境检测
./scripts/check-env.sh
```

### 2.3 Makefile（如有）

```bash
make setup     # 首次搭建
make dev       # 开发模式启动
make build     # 生产构建
make test      # 运行测试
make docker-up # Docker 启动
```

---

## 三、部署步骤

### 3.1 本地开发

```text
1. 克隆仓库
2. 运行环境检测脚本，确认依赖齐全
3. 复制 .env.example 为 .env，填写数据库连接等配置
4. 运行 setup 脚本（自动安装依赖 + 初始化数据库 + 启动）
5. 访问 http://localhost:{{FRONTEND_PORT}} 查看前端
6. 访问 http://localhost:{{BACKEND_PORT}}/api-docs 查看接口文档
```

### 3.2 Docker 部署

```text
1. 确保已安装 Docker 和 Docker Compose
2. 复制 .env.example 为 .env
3. 运行：docker-compose -f deploy/docker-compose.yml up -d
4. 等待容器启动完成
5. 访问 http://localhost:{{FRONTEND_PORT}}
```

### 3.3 生产部署

```text
1. 准备服务器（推荐 Linux + 2C4G 以上配置）
2. 安装 Docker
3. 上传项目代码到服务器
4. 配置 .env（生产环境专用配置）
5. 运行 docker-compose -f deploy/docker-compose.prod.yml up -d
6. 配置域名和 SSL 证书（如需要）
7. 配置反向代理（Nginx，deploy/nginx.conf 已提供模板）
```

---

## 四、配置文件说明

### 4.1 主配置文件

| 文件 | 位置 | 说明 |
|------|------|------|
| .env | 项目根目录 | 环境变量（数据库连接、端口、密钥等） |
| application.yml | backend/src/main/resources/ | 后端主配置 |
| application-dev.yml | backend/src/main/resources/ | 开发环境专用配置 |
| application-prod.yml | backend/src/main/resources/ | 生产环境专用配置 |
| docker-compose.yml | deploy/ | Docker 服务编排 |

### 4.2 常见配置项

| 配置项 | 文件 | 说明 | 默认值 |
|--------|------|------|--------|
| 服务端口 | .env / application.yml | 后端监听端口 | {{BACKEND_PORT}} |
| 前端端口 | .env / vite.config | 开发服务器端口 | {{FRONTEND_PORT}} |
| 数据库地址 | .env | 数据库连接字符串 | {{DB_URL}} |
| JWT 密钥 | .env | Token 签名密钥 | （必须修改） |

### 4.3 安全提醒

- `.env` 文件已加入 `.gitignore`，不会被提交到版本库
- **生产环境必须修改 JWT 密钥**，不要使用默认值
- 数据库密码不要使用弱密码
- 如需对外暴露服务，请配置 HTTPS

---

> **使用说明**：
> 1. `{{变量}}` 需替换为实际值
> 2. 本指南针对当前项目生成，不同项目的脚本和配置可能不同
> 3. 遇到问题先运行 `check-env` 脚本排查环境问题
