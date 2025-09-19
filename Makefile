# Vue + Go/Gin + Rust Demo Project Makefile

.PHONY: help install build run clean dev test

# 默认目标
help:
	@echo "Vue + Go/Gin + Rust Demo Project"
	@echo ""
	@echo "Available commands:"
	@echo "  install    - 安装所有依赖"
	@echo "  build      - 构建所有项目"
	@echo "  run        - 运行后端服务"
	@echo "  dev        - 开发模式运行"
	@echo "  test       - 运行测试"
	@echo "  clean      - 清理构建文件"

# 安装依赖
install:
	@echo "Installing dependencies..."
	cd frontend && npm install
	cd backend && go mod tidy
	cd tools && cargo build

# 构建所有项目
build: build-frontend build-backend build-tools

build-frontend:
	@echo "Building Vue frontend..."
	cd frontend && npm run build

build-backend:
	@echo "Building Go backend..."
	cd backend && go build -o bin/server .

build-tools:
	@echo "Building Rust tools..."
	cd tools && cargo build --release

# 运行后端服务
run:
	cd backend && go run .

# 开发模式
dev:
	@echo "Starting development servers..."
	@echo "Frontend: http://localhost:5173"
	@echo "Backend: http://localhost:8080"
	cd frontend && npm run dev &
	cd backend && go run .

# 运行测试
test:
	cd backend && go test ./...
	cd tools && cargo test

# 清理构建文件
clean:
	rm -rf frontend/dist
	rm -rf backend/bin
	rm -rf tools/target