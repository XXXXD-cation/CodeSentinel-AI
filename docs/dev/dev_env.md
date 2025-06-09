# CodeSentinel-AI 开发环境配置指南

## 项目结构

```
CodeSentinel-AI/
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI/CD配置
├── src/
│   └── codesentinel/
│       ├── __init__.py
│       ├── main.py               # FastAPI应用入口
│       ├── agents/               # 智能体模块
│       ├── tools/                # 工具集模块
│       ├── core/                 # 核心组件
│       ├── api/                  # API路由
│       ├── tasks/                # Celery任务
│       ├── models/               # 数据模型
│       └── utils/                # 工具函数
├── tests/
│   ├── unit/                     # 单元测试
│   ├── integration/              # 集成测试
│   └── performance/              # 性能测试
├── docs/
│   ├── api/                      # API文档
│   ├── user/                     # 用户手册
│   └── dev/                      # 开发文档
├── data/
│   ├── chroma/                   # ChromaDB数据
│   └── reports/                  # 扫描报告
├── logs/                         # 日志文件
├── monitoring/
│   ├── prometheus/               # Prometheus配置
│   └── grafana/                  # Grafana仪表板
├── nginx/                        # Nginx配置
├── scripts/                      # 部署脚本
├── pyproject.toml               # 项目配置
├── .pre-commit-config.yaml      # Pre-commit配置
├── Dockerfile                   # Docker配置
├── docker-compose.yml           # Docker Compose配置
├── Makefile                     # 开发命令
└── README.md                    # 项目说明
```

## 快速开始

### 1. 环境准备

确保系统已安装：
- Python 3.10+
- Poetry 1.7.0+
- Docker & Docker Compose
- Git

### 2. 项目初始化

```bash
# 克隆仓库
git clone https://github.com/XXXXD-cation/CodeSentinel-AI.git
cd CodeSentinel-AI

# 初始化项目（创建目录结构、安装依赖、设置pre-commit）
make init

# 或者手动执行
make create-dirs
make dev-install
make pre-commit
```

### 3. 开发环境启动

```bash
# 启动开发环境（包含所有服务）
make dev

# 或者单独启动服务
make docker-up
```

服务访问地址：
- API文档: http://localhost:8000/docs
- 主应用: http://localhost:8000
- Celery监控: http://localhost:5555
- Grafana: http://localhost:3000 (admin/admin123)
- Prometheus: http://localhost:9090

### 4. 开发工作流

```bash
# 代码格式化
make format

# 运行测试
make test-cov

# 代码质量检查
make lint

# 安全检查
make security

# 运行所有检查
make pre-commit-run
```

## 环境变量配置

创建 `.env` 文件：

```env
# 基础配置
ENV=development
DEBUG=True
SECRET_KEY=your-secret-key-here

# 数据库配置
DATABASE_URL=sqlite:///./data/codesentinel.db
CHROMA_PERSIST_DIR=./data/chroma

# Redis配置
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=redis123

# LLM配置
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key

# 监控配置
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123

# Docker Hub配置（CI/CD用）
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password
```

## 代码质量标准

项目采用严格的代码质量标准：

### 代码格式化
- **Black**: 代码格式化，行长度88字符
- **isort**: 导入语句排序
- **Ruff**: 快速linting工具

### 类型检查
- **MyPy**: 严格类型检查
- 要求所有函数都有类型注解

### 测试要求
- 测试覆盖率 ≥ 80%
- 单元测试、集成测试、性能测试
- 使用pytest框架

### 安全检查
- **Bandit**: Python安全漏洞扫描
- **pip-audit**: 依赖包安全扫描
- **Safety**: 已知安全漏洞检查

## 开发命令速查

| 命令 | 功能 |
|------|------|
| `make help` | 显示所有可用命令 |
| `make init` | 初始化项目 |
| `make dev` | 启动开发环境 |
| `make test` | 运行测试 |
| `make test-cov` | 运行测试并生成覆盖率报告 |
| `make lint` | 代码质量检查 |
| `make format` | 代码格式化 |
| `make security` | 安全检查 |
| `make clean` | 清理构建产物 |
| `make docker-build` | 构建Docker镜像 |
| `make docker-up` | 启动Docker服务 |
| `make docker-down` | 停止Docker服务 |

## CI/CD 流程

GitHub Actions自动执行：

1. **代码质量检查**
   - 格式化检查 (Black, isort)
   - Linting (Ruff)
   - 类型检查 (MyPy)

2. **安全扫描**
   - 代码安全扫描 (Bandit)
   - 依赖安全扫描 (pip-audit)
   - 容器安全扫描 (Trivy)

3. **测试执行**
   - 单元测试
   - 集成测试
   - 覆盖率报告上传到Codecov

4. **构建部署**
   - Docker镜像构建
   - 推送到Docker Hub
   - 性能基准测试

## Pre-commit Hooks

每次提交代码前自动执行：
- 代码格式化
- 导入排序
- 语法检查
- 类型检查
- 安全扫描
- 测试运行

## 开发环境组件

### 核心服务
- **FastAPI**: Web框架和API服务
- **Celery**: 分布式任务队列
- **Redis**: 消息代理和缓存
- **ChromaDB**: 向量数据库

### 监控服务
- **Prometheus**: 指标收集
- **Grafana**: 可视化仪表板
- **Flower**: Celery任务监控

### 开发工具
- **Poetry**: 依赖管理
- **Pre-commit**: Git钩子管理
- **Docker Compose**: 本地开发环境

## 故障排除

### 常见问题

1. **Poetry安装失败**
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. **Docker服务启动失败**
   ```bash
   make docker-down
   make clean
   make docker-build
   make docker-up
   ```

3. **Pre-commit检查失败**
   ```bash
   make format
   make pre-commit-run
   ```

4. **测试覆盖率不足**
   ```bash
   make test-cov
   # 查看 htmlcov/index.html 了解未覆盖的代码
   ```

## 下一步

完成环境搭建后，可以开始：

1. **Phase 1.2**: 核心框架集成 (LangChain, LangGraph)
2. **Phase 1.3**: 数据存储层搭建 (ChromaDB, SQLite)
3. **Phase 2.1**: 代码分析引擎开发

参考任务书继续后续开发工作。