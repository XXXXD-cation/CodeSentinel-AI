#!/bin/bash

# CodeSentinel-AI 项目初始化脚本
# 用于快速搭建开发环境

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# 检查Python版本
check_python_version() {
    python_version=$(python3 --version 2>&1 | awk '{print $2}')
    required_version="3.10"
    
    if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
        log_error "Python $required_version or higher is required. Current version: $python_version"
        exit 1
    fi
    
    log_success "Python version check passed: $python_version"
}

# 安装Poetry
install_poetry() {
    if ! command -v poetry &> /dev/null; then
        log_info "Installing Poetry..."
        curl -sSL https://install.python-poetry.org | python3 -
        export PATH="$HOME/.local/bin:$PATH"
        
        # 添加到shell配置文件
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        
        log_success "Poetry installed successfully"
    else
        log_info "Poetry is already installed"
    fi
}

# 创建项目目录结构
create_directories() {
    log_info "Creating project directories..."
    
    directories=(
        "src/codesentinel/agents"
        "src/codesentinel/tools"
        "src/codesentinel/core"
        "src/codesentinel/api"
        "src/codesentinel/tasks"
        "src/codesentinel/models"
        "src/codesentinel/utils"
        "tests/unit"
        "tests/integration"
        "tests/performance"
        "docs/api"
        "docs/user"
        "docs/dev"
        "data/chroma"
        "data/reports"
        "logs"
        "monitoring/prometheus"
        "monitoring/grafana/provisioning/dashboards"
        "monitoring/grafana/provisioning/datasources"
        "nginx"
        "scripts"
        "reports"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    done
    
    log_success "Project directories created"
}

# 创建初始文件
create_initial_files() {
    log_info "Creating initial files..."
    
    # 创建__init__.py文件
    find src tests -type d -exec touch {}/__init__.py \;
    
    # 创建基础配置文件
    if [ ! -f ".env" ]; then
        cp .env.example .env
        log_info "Created .env file from template"
    fi
    
    # 创建基础Python文件
    cat > src/codesentinel/main.py << 'EOF'
"""
CodeSentinel-AI 主应用入口
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="CodeSentinel-AI",
    description="AI-powered source code vulnerability scanning system",
    version="0.1.0"
)

# 添加CORS中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "CodeSentinel-AI is running!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "0.1.0"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    
    log_success "Initial files created"
}

# 安装依赖
install_dependencies() {
    log_info "Installing project dependencies..."
    
    # 配置Poetry
    poetry config virtualenvs.in-project true
    
    # 安装依赖
    poetry install
    
    log_success "Dependencies installed"
}

# 设置pre-commit钩子
setup_pre_commit() {
    log_info "Setting up pre-commit hooks..."
    
    poetry run pre-commit install
    
    log_success "Pre-commit hooks installed"
}

# 初始化git仓库（如果不存在）
init_git() {
    if [ ! -d ".git" ]; then
        log_info "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit: Project setup"
        log_success "Git repository initialized"
    else
        log_info "Git repository already exists"
    fi
}

# 创建Docker网络
setup_docker_network() {
    log_info "Setting up Docker network..."
    
    if ! docker network ls | grep -q codesentinel_network; then
        docker network create codesentinel_network
        log_success "Docker network created"
    else
        log_info "Docker network already exists"
    fi
}

# 创建监控配置文件
create_monitoring_config() {
    log_info "Creating monitoring configuration..."
    
    # Prometheus配置
    cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'codesentinel-api'
    static_configs:
      - targets: ['app:8001']
    scrape_interval: 5s
    metrics_path: '/metrics'
  
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
EOF
    
    # Grafana数据源配置
    cat > monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF
    
    log_success "Monitoring configuration created"
}

# 创建nginx配置
create_nginx_config() {
    log_info "Creating nginx configuration..."
    
    cat > nginx/nginx.conf << 'EOF'
upstream app {
    server app:8000;
}

server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /health {
        access_log off;
        proxy_pass http://app;
    }
}
EOF
    
    log_success "Nginx configuration created"
}

# 验证安装
verify_installation() {
    log_info "Verifying installation..."
    
    # 检查Poetry
    if poetry --version &> /dev/null; then
        log_success "Poetry is working"
    else
        log_error "Poetry verification failed"
        exit 1
    fi
    
    # 检查Python环境
    if poetry run python --version &> /dev/null; then
        log_success "Python environment is working"
    else
        log_error "Python environment verification failed"
        exit 1
    fi
    
    # 检查pre-commit
    if poetry run pre-commit --version &> /dev/null; then
        log_success "Pre-commit is working"
    else
        log_error "Pre-commit verification failed"
        exit 1
    fi
    
    log_success "Installation verification completed"
}

# 显示下一步提示
show_next_steps() {
    log_success "🎉 CodeSentinel-AI setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Copy .env.example to .env and configure your environment variables"
    echo "2. Run 'make dev' to start the development environment"
    echo "3. Visit http://localhost:8000/docs to see the API documentation"
    echo ""
    echo "Available commands:"
    echo "  make help          - Show all available commands"
    echo "  make dev           - Start development environment"
    echo "  make test          - Run tests"
    echo "  make lint          - Run code quality checks"
    echo "  make format        - Format code"
    echo ""
    echo "Happy coding! 🚀"
}

# 主函数
main() {
    log_info "Starting CodeSentinel-AI setup..."
    
    # 检查系统要求
    check_command "python3"
    check_command "git"
    check_command "docker"
    check_command "docker-compose"
    check_python_version
    
    # 安装和设置
    install_poetry
    create_directories
    create_initial_files
    install_dependencies
    setup_pre_commit
    init_git
    setup_docker_network
    create_monitoring_config
    create_nginx_config
    verify_installation
    show_next_steps
}

# 执行主函数
main "$@"