#!/bin/bash

# 项目构建脚本
# 用于构建Vue + Go + Rust技术栈的demo项目

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
        log_error "$1 命令未找到，请先安装 $1"
        exit 1
    fi
}

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_info "开始构建项目..."
log_info "项目根目录: $PROJECT_ROOT"

# 检查必要的命令
log_info "检查构建环境..."
check_command "go"
check_command "node"
check_command "npm"
check_command "cargo"

# 构建后端服务
log_info "构建Go后端服务..."
cd backend
if [ ! -f "go.mod" ]; then
    log_error "未找到go.mod文件"
    exit 1
fi

log_info "下载Go依赖..."
go mod download

log_info "运行Go测试..."
go test ./... || log_warning "Go测试失败，但继续构建"

log_info "构建Go二进制文件..."
go build -o bin/demo-backend .
log_success "Go后端构建完成"

# 构建前端项目
log_info "构建Vue前端项目..."
cd ../frontend
if [ ! -f "package.json" ]; then
    log_error "未找到package.json文件"
    exit 1
fi

log_info "安装npm依赖..."
npm install

log_info "运行前端测试..."
npm run test 2>/dev/null || log_warning "前端测试跳过或失败"

log_info "构建前端生产版本..."
npm run build
log_success "Vue前端构建完成"

# 构建Rust工具程序
log_info "构建Rust工具程序..."
cd ../tools
if [ ! -f "Cargo.toml" ]; then
    log_error "未找到Cargo.toml文件"
    exit 1
fi

log_info "构建Rust项目..."
cargo build --release

log_info "运行Rust测试..."
cargo test || log_warning "Rust测试失败，但继续构建"

log_success "Rust工具程序构建完成"

# 创建构建信息文件
cd "$PROJECT_ROOT"
BUILD_INFO_FILE="build-info.json"
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

log_info "生成构建信息..."
cat > "$BUILD_INFO_FILE" << EOF
{
  "build_time": "$BUILD_TIME",
  "build_version": "$BUILD_VERSION",
  "components": {
    "backend": {
      "language": "Go",
      "framework": "Gin",
      "binary": "backend/bin/demo-backend"
    },
    "frontend": {
      "language": "JavaScript",
      "framework": "Vue.js",
      "build_dir": "frontend/dist"
    },
    "tools": {
      "language": "Rust",
      "binary": "tools/target/release/demo-tools"
    }
  },
  "docker": {
    "compose_file": "docker-compose.yml",
    "dockerfiles": [
      "docker/Dockerfile.backend",
      "docker/Dockerfile.frontend",
      "docker/Dockerfile.tools"
    ]
  }
}
EOF

log_success "构建信息已保存到 $BUILD_INFO_FILE"

# 显示构建结果
log_info "构建结果摘要:"
echo "  📦 后端二进制文件: backend/bin/demo-backend"
echo "  🌐 前端构建目录: frontend/dist"
echo "  🔧 Rust工具程序: tools/target/release/demo-tools"
echo "  📋 构建信息: $BUILD_INFO_FILE"

log_success "项目构建完成！"
log_info "使用以下命令启动服务:"
echo "  make run        # 启动所有服务"
echo "  make dev        # 开发模式启动"
echo "  make docker     # Docker容器启动"