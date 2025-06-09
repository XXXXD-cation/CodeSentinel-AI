# CodeSentinel-AI Makefile
.PHONY: help install dev-install test lint format clean build docker-build docker-up docker-down

# 默认目标
help:
	@echo "CodeSentinel-AI Development Commands"
	@echo "====================================="
	@echo "setup           - Initial project setup"
	@echo "install         - Install dependencies"
	@echo "dev-install     - Install development dependencies"
	@echo "test            - Run tests"
	@echo "test-cov        - Run tests with coverage"
	@echo "lint            - Run linting checks"
	@echo "format          - Format code"
	@echo "security        - Run security checks"
	@echo "clean           - Clean build artifacts"
	@echo "build           - Build the project"
	@echo "docker-build    - Build Docker image"
	@echo "docker-up       - Start Docker services"
	@echo "docker-down     - Stop Docker services"
	@echo "docker-logs     - View Docker logs"
	@echo "pre-commit      - Setup pre-commit hooks"

# 项目初始化
setup: install pre-commit
	@echo "✅ Project setup complete!"

# 安装依赖
install:
	@echo "📦 Installing dependencies..."
	poetry install --no-dev

# 安装开发依赖
dev-install:
	@echo "📦 Installing development dependencies..."
	poetry install

# 运行测试
test:
	@echo "🧪 Running tests..."
	poetry run pytest

# 运行测试并生成覆盖率报告
test-cov:
	@echo "🧪 Running tests with coverage..."
	poetry run pytest --cov=src/codesentinel --cov-report=html --cov-report=term-missing

# 代码质量检查
lint:
	@echo "🔍 Running linting checks..."
	poetry run black --check .
	poetry run isort --check-only .
	poetry run ruff check .
	poetry run mypy src/

# 代码格式化
format:
	@echo "🎨 Formatting code..."
	poetry run black .
	poetry run isort .
	poetry run ruff --fix .

# 安全检查
security:
	@echo "🔒 Running security checks..."
	poetry run bandit -r src/ -f json -o reports/bandit-report.json
	poetry run pip-audit --format=json --output=reports/pip-audit-report.json
	poetry run safety check

# 清理构建产物
clean:
	@echo "🧹 Cleaning build artifacts..."
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf build/ dist/ .coverage htmlcov/ .pytest_cache/ .mypy_cache/ .ruff_cache/

# 构建项目
build: clean
	@echo "🏗️ Building project..."
	poetry build

# 构建Docker镜像
docker-build:
	@echo "🐳 Building Docker image..."
	docker-compose build

# 启动Docker服务
docker-up:
	@echo "🚀 Starting Docker services..."
	docker-compose up -d

# 停止Docker服务
docker-down:
	@echo "🛑 Stopping Docker services..."
	docker-compose down

# 查看Docker日志
docker-logs:
	@echo "📋 Viewing Docker logs..."
	docker-compose logs -f

# 设置pre-commit钩子
pre-commit:
	@echo "🔧 Setting up pre-commit hooks..."
	poetry run pre-commit install

# 运行pre-commit检查
pre-commit-run:
	@echo "🔧 Running pre-commit checks..."
	poetry run pre-commit run --all-files

# 开发环境启动
dev: docker-up
	@echo "🚀 Development environment started!"
	@echo "   - API: http://localhost:8000"
	@echo "   - Docs: http://localhost:8000/docs"
	@echo "   - Flower: http://localhost:5555"
	@echo "   - Grafana: http://localhost:3000"
	@echo "   - Prometheus: http://localhost:9090"

# 生产环境构建
prod-build:
	@echo "🏭 Building for production..."
	docker build --target production -t codesentinel-ai:latest .

# 创建必要的目录
create-dirs:
	@echo "📁 Creating necessary directories..."
	mkdir -p src/codesentinel/{agents,tools,core,api,tasks,models,utils}
	mkdir -p tests/{unit,integration,performance}
	mkdir -p docs/{api,user,dev}
	mkdir -p data/{chroma,reports}
	mkdir -p logs
	mkdir -p monitoring/{prometheus,grafana}
	mkdir -p nginx
	mkdir -p scripts

# 完整的项目初始化
init: create-dirs dev-install pre-commit
	@echo "🎉 Project initialization complete!"

# 健康检查
health:
	@echo "🏥 Running health checks..."
	@curl -f http://localhost:8000/health || echo "❌ API is not running"
	@docker-compose ps

# 运行性能测试
perf-test:
	@echo "⚡ Running performance tests..."
	poetry run pytest tests/performance/ -v --benchmark-json=reports/benchmark.json

# 生成报告
report: test-cov security
	@echo "📊 Generating reports..."
	@echo "Coverage report: htmlcov/index.html"
	@echo "Security report: reports/bandit-report.json"
	@echo "Dependency audit: reports/pip-audit-report.json"