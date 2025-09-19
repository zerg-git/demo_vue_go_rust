#!/bin/bash

# 项目部署脚本
# 用于部署Vue + Go + Rust技术栈的demo项目

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

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -e, --env ENV        部署环境 (dev|staging|prod) [默认: dev]"
    echo "  -d, --docker         使用Docker部署"
    echo "  -b, --build          部署前先构建项目"
    echo "  -c, --clean          清理旧的部署文件"
    echo "  -h, --help           显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --env prod --docker --build    # 构建并使用Docker部署到生产环境"
    echo "  $0 --env dev                       # 部署到开发环境"
    echo "  $0 --clean                         # 清理部署文件"
}

# 默认参数
ENVIRONMENT="dev"
USE_DOCKER=false
BUILD_FIRST=false
CLEAN_DEPLOY=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -d|--docker)
            USE_DOCKER=true
            shift
            ;;
        -b|--build)
            BUILD_FIRST=true
            shift
            ;;
        -c|--clean)
            CLEAN_DEPLOY=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 验证环境参数
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    log_error "无效的环境: $ENVIRONMENT (支持: dev, staging, prod)"
    exit 1
fi

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_info "开始部署项目..."
log_info "项目根目录: $PROJECT_ROOT"
log_info "部署环境: $ENVIRONMENT"
log_info "使用Docker: $USE_DOCKER"

# 清理部署文件
if [ "$CLEAN_DEPLOY" = true ]; then
    log_info "清理部署文件..."
    
    # 停止Docker容器
    if [ "$USE_DOCKER" = true ]; then
        docker-compose down --remove-orphans 2>/dev/null || true
        docker system prune -f 2>/dev/null || true
    fi
    
    # 清理构建文件
    rm -rf backend/bin/
    rm -rf frontend/dist/
    rm -rf tools/target/
    rm -f build-info.json
    
    log_success "清理完成"
    exit 0
fi

# 构建项目
if [ "$BUILD_FIRST" = true ]; then
    log_info "执行项目构建..."
    ./scripts/build.sh
fi

# 检查构建文件是否存在
check_build_files() {
    local missing_files=()
    
    if [ ! -f "backend/bin/demo-backend" ] && [ "$USE_DOCKER" = false ]; then
        missing_files+=("backend/bin/demo-backend")
    fi
    
    if [ ! -d "frontend/dist" ] && [ "$USE_DOCKER" = false ]; then
        missing_files+=("frontend/dist")
    fi
    
    if [ ! -f "tools/target/release/demo-tools" ] && [ "$USE_DOCKER" = false ]; then
        missing_files+=("tools/target/release/demo-tools")
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "缺少构建文件:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        log_error "请先运行构建: ./scripts/build.sh 或使用 --build 参数"
        exit 1
    fi
}

# Docker部署
deploy_with_docker() {
    log_info "使用Docker部署..."
    
    # 检查Docker是否可用
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装或不可用"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装或不可用"
        exit 1
    fi
    
    # 设置环境变量
    export ENVIRONMENT="$ENVIRONMENT"
    
    # 停止现有容器
    log_info "停止现有容器..."
    docker-compose down --remove-orphans || true
    
    # 构建并启动容器
    log_info "构建Docker镜像..."
    docker-compose build
    
    log_info "启动服务容器..."
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    log_info "检查服务状态..."
    docker-compose ps
    
    # 健康检查
    log_info "执行健康检查..."
    for i in {1..30}; do
        if curl -s http://localhost:8080/health > /dev/null 2>&1; then
            log_success "后端服务健康检查通过"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "后端服务健康检查超时"
        fi
        sleep 2
    done
    
    for i in {1..30}; do
        if curl -s http://localhost:80 > /dev/null 2>&1; then
            log_success "前端服务健康检查通过"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "前端服务健康检查超时"
        fi
        sleep 2
    done
    
    log_success "Docker部署完成"
    log_info "服务访问地址:"
    echo "  🌐 前端服务: http://localhost"
    echo "  🔗 后端API: http://localhost:8080"
    echo "  📊 健康检查: http://localhost:8080/health"
}

# 本地部署
deploy_locally() {
    log_info "本地部署..."
    
    check_build_files
    
    # 创建部署目录
    DEPLOY_DIR="deploy/$ENVIRONMENT"
    mkdir -p "$DEPLOY_DIR"
    
    # 复制后端文件
    log_info "部署后端服务..."
    cp backend/bin/demo-backend "$DEPLOY_DIR/"
    cp -r backend/templates "$DEPLOY_DIR/" 2>/dev/null || true
    cp -r backend/static "$DEPLOY_DIR/" 2>/dev/null || true
    
    # 复制前端文件
    log_info "部署前端文件..."
    mkdir -p "$DEPLOY_DIR/web"
    cp -r frontend/dist/* "$DEPLOY_DIR/web/"
    
    # 复制工具程序
    log_info "部署工具程序..."
    cp tools/target/release/demo-tools "$DEPLOY_DIR/"
    
    # 创建启动脚本
    cat > "$DEPLOY_DIR/start.sh" << 'EOF'
#!/bin/bash

# 启动脚本
echo "启动Demo项目服务..."

# 启动后端服务
echo "启动后端服务..."
export GIN_MODE=release
export PORT=8080
./demo-backend &
BACKEND_PID=$!

# 启动简单的HTTP服务器提供前端文件
echo "启动前端服务..."
cd web
python3 -m http.server 3000 &
FRONTEND_PID=$!

echo "服务已启动:"
echo "  后端API: http://localhost:8080"
echo "  前端页面: http://localhost:3000"
echo "  PID: 后端=$BACKEND_PID, 前端=$FRONTEND_PID"

# 等待信号
trap 'kill $BACKEND_PID $FRONTEND_PID; exit' SIGINT SIGTERM

wait
EOF
    
    chmod +x "$DEPLOY_DIR/start.sh"
    
    # 创建停止脚本
    cat > "$DEPLOY_DIR/stop.sh" << 'EOF'
#!/bin/bash

echo "停止Demo项目服务..."
pkill -f demo-backend || true
pkill -f "python3 -m http.server 3000" || true
echo "服务已停止"
EOF
    
    chmod +x "$DEPLOY_DIR/stop.sh"
    
    log_success "本地部署完成"
    log_info "部署目录: $DEPLOY_DIR"
    log_info "启动服务: cd $DEPLOY_DIR && ./start.sh"
    log_info "停止服务: cd $DEPLOY_DIR && ./stop.sh"
}

# 执行部署
if [ "$USE_DOCKER" = true ]; then
    deploy_with_docker
else
    deploy_locally
fi

# 生成部署报告
DEPLOY_REPORT="deploy-report-$ENVIRONMENT-$(date +%Y%m%d-%H%M%S).json"
cat > "$DEPLOY_REPORT" << EOF
{
  "deployment": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "environment": "$ENVIRONMENT",
    "method": "$([ "$USE_DOCKER" = true ] && echo "docker" || echo "local")",
    "version": "$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")",
    "status": "success"
  },
  "services": {
    "backend": {
      "port": 8080,
      "health_check": "/health"
    },
    "frontend": {
      "port": "$([ "$USE_DOCKER" = true ] && echo "80" || echo "3000")"
    },
    "tools": {
      "binary": "demo-tools"
    }
  }
}
EOF

log_success "部署完成！"
log_info "部署报告: $DEPLOY_REPORT"