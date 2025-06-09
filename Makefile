# Makefile for CodeSentinel-AI
# A collection of commands for development, testing, and deployment.

# ==============================================================================
#  Help
# ==============================================================================
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Usage: make <command>"
	@echo ""
	@echo "Commands:"
	@echo "  setup                Install all dependencies and setup pre-commit hooks."
	@echo "  install              Install production dependencies only."
	@echo "  test                 Run tests and generate coverage report (as configured in pyproject.toml)."
	@echo "  lint                 Run static analysis and code style checks."
	@echo "  format               Automatically format all project code."
	@echo "  security             Run security vulnerability checks and generate reports."
	@echo "  clean                Remove temporary files and build artifacts."
	@echo "  build                Build the distributable package."
	@echo "  docker-build         Build the Docker image for the application."
	@echo "  docker-up            Start services using Docker Compose."
	@echo "  docker-down          Stop services using Docker Compose."
	@echo "  docker-logs          Follow logs from Docker services."
	@echo "  pre-commit-install   Install pre-commit hooks into your .git/hooks directory."


# ==============================================================================
#  Development Workflow
# ==============================================================================
.PHONY: setup install dev-install pre-commit-install
setup: dev-install pre-commit-install
	@echo "✅ Project setup complete!"

install:
	@echo "📦 Installing production dependencies..."
	poetry install --no-dev --no-root

dev-install:
	@echo "📦 Installing all dependencies for development..."
	poetry install --no-root

pre-commit-install:
	@echo "🔧 Installing pre-commit hooks..."
	poetry run pre-commit install


# ==============================================================================
#  Quality Assurance
# ==============================================================================
.PHONY: test lint format security
test:
	@echo "🧪 Running tests (with coverage enabled by default)..."
	poetry run pytest

lint:
	@echo "🔍 Running linters and static analysis..."
	poetry run black --check .
	poetry run ruff check .
	poetry run mypy src/

format:
	@echo "🎨 Formatting code..."
	poetry run ruff check . --fix
	poetry run ruff format .
	poetry run black .

security:
	@echo "🔒 Running security checks..."
	mkdir -p reports
	poetry run bandit -r src/ -f json -o reports/bandit-report.json
	poetry run pip-audit --format=json --output=reports/pip-audit-report.json
	poetry run safety check --json --output reports/safety-report.json


# ==============================================================================
#  Build & Deployment
# ==============================================================================
.PHONY: clean build docker-build docker-up docker-down docker-logs
clean:
	@echo "🧹 Cleaning build artifacts and temporary files..."
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf build/ dist/ .coverage htmlcov/ reports/ .pytest_cache/ .mypy_cache/ .ruff_cache/ *.egg-info

build: clean
	@echo "🏗️ Building project package..."
	poetry build

docker-build:
	@echo "🐳 Building Docker image..."
	docker-compose build

docker-up:
	@echo "🚀 Starting services with Docker Compose..."
	docker-compose up -d

docker-down:
	@echo "🛑 Stopping services with Docker Compose..."
	docker-compose down

docker-logs:
	@echo "📋 Tailing logs from Docker services..."
	docker-compose logs -f

