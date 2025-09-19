# Vue + Go + Rust 全栈Demo项目

这是一个展示现代全栈开发技术的演示项目，集成了Vue.js前端、Go后端API服务和Rust工具程序。

## 🚀 项目特性

- **前端**: Vue 3 + Vite + 现代化UI组件
- **后端**: Go + Gin框架 + RESTful API
- **工具**: Rust命令行工具集
- **容器化**: Docker + Docker Compose
- **自动化**: 构建和部署脚本

## 📁 项目结构

```
demo_vue_go_rust/
├── backend/                 # Go后端服务
│   ├── main.go             # 主程序入口
│   ├── go.mod              # Go模块依赖
│   ├── templates/          # HTML模板
│   └── static/             # 静态资源
├── frontend/               # Vue前端项目
│   ├── src/                # 源代码
│   │   ├── App.vue         # 主应用组件
│   │   └── components/     # 组件目录
│   ├── package.json        # 前端依赖
│   └── vite.config.js      # Vite配置
├── tools/                  # Rust工具程序
│   ├── src/main.rs         # Rust主程序
│   └── Cargo.toml          # Rust依赖配置
├── docker/                 # Docker配置
│   ├── Dockerfile.backend  # 后端镜像
│   ├── Dockerfile.frontend # 前端镜像
│   ├── Dockerfile.tools    # 工具镜像
│   └── nginx.conf          # Nginx配置
├── scripts/                # 自动化脚本
│   ├── build.sh            # 构建脚本
│   └── deploy.sh           # 部署脚本
└── docker-compose.yml      # 容器编排
```

## 🛠️ 技术栈

### 前端技术
- **Vue 3**: 渐进式JavaScript框架
- **Vite**: 现代化构建工具
- **Axios**: HTTP客户端
- **现代CSS**: 响应式设计

### 后端技术
- **Go 1.21**: 高性能编程语言
- **Gin**: 轻量级Web框架
- **RESTful API**: 标准化接口设计
- **JSON**: 数据交换格式

### 工具技术
- **Rust**: 系统级编程语言
- **Clap**: 命令行参数解析
- **Tokio**: 异步运行时
- **Serde**: 序列化框架

### 部署技术
- **Docker**: 容器化技术
- **Docker Compose**: 多容器编排
- **Nginx**: 反向代理服务器

## 🚀 快速开始

### 环境要求

- **Go**: 1.21+
- **Node.js**: 18+
- **Rust**: 1.75+
- **Docker**: 20.10+ (可选)
- **Docker Compose**: 2.0+ (可选)

### 本地开发

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd demo_vue_go_rust
   ```

2. **构建项目**
   ```bash
   ./scripts/build.sh
   ```

3. **启动后端服务**
   ```bash
   cd backend
   go run main.go
   ```

4. **启动前端开发服务器**
   ```bash
   cd frontend
   npm run dev
   ```

5. **使用Rust工具**
   ```bash
   cd tools
   cargo run -- --help
   ```

### Docker部署

1. **使用Docker Compose一键部署**
   ```bash
   ./scripts/deploy.sh --docker --build
   ```

2. **访问服务**
   - 前端页面: http://localhost
   - 后端API: http://localhost:8080
   - 健康检查: http://localhost:8080/health

## 📖 API文档

### 用户管理接口

#### 获取所有用户
```http
GET /api/users
```

**响应示例:**
```json
{
  "users": [
    {
      "id": 1,
      "name": "张三",
      "email": "zhangsan@example.com",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### 创建用户
```http
POST /api/users
Content-Type: application/json

{
  "name": "李四",
  "email": "lisi@example.com"
}
```

#### 更新用户
```http
PUT /api/users/:id
Content-Type: application/json

{
  "name": "王五",
  "email": "wangwu@example.com"
}
```

#### 删除用户
```http
DELETE /api/users/:id
```

### 系统接口

#### 健康检查
```http
GET /health
```

**响应示例:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 🔧 Rust工具使用

### 数据处理工具

```bash
# 生成测试用户数据
./tools/target/release/demo-tools data generate-users --count 10

# 验证JSON格式
./tools/target/release/demo-tools data validate-json --file data.json
```

### 系统监控工具

```bash
# 查看系统信息
./tools/target/release/demo-tools monitor system-info

# 监控进程
./tools/target/release/demo-tools monitor processes
```

### API测试工具

```bash
# 健康检查
./tools/target/release/demo-tools api health-check --url http://localhost:8080

# 测试用户接口
./tools/target/release/demo-tools api test-users --url http://localhost:8080
```

## 🏗️ 构建和部署

### 构建脚本

```bash
# 构建所有组件
./scripts/build.sh

# 构建特定组件
./scripts/build.sh --backend-only
./scripts/build.sh --frontend-only
./scripts/build.sh --tools-only
```

### 部署脚本

```bash
# 开发环境部署
./scripts/deploy.sh --env dev

# 生产环境Docker部署
./scripts/deploy.sh --env prod --docker --build

# 清理部署文件
./scripts/deploy.sh --clean
```

## 🧪 测试

### 后端测试
```bash
cd backend
go test ./...
```

### 前端测试
```bash
cd frontend
npm test
```

### 工具测试
```bash
cd tools
cargo test
```

## 📊 性能监控

项目包含以下监控功能:

- **健康检查端点**: `/health`
- **系统资源监控**: Rust工具提供
- **API响应时间**: 内置中间件记录
- **容器状态监控**: Docker Compose健康检查

## 🔒 安全特性

- **CORS配置**: 跨域请求控制
- **输入验证**: 前后端数据验证
- **安全头设置**: Nginx安全配置
- **容器安全**: 最小权限原则

## 🤝 贡献指南

1. Fork项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📝 开发规范

请参考项目中的编码规范:
- 前端遵循Vue 3最佳实践
- 后端遵循Go标准项目布局
- Rust代码遵循官方风格指南
- 提交信息遵循Conventional Commits

## 🐛 问题排查

### 常见问题

1. **端口冲突**
   - 后端默认端口: 8080
   - 前端开发端口: 5173
   - 前端生产端口: 80

2. **依赖安装失败**
   ```bash
   # 清理缓存重新安装
   cd frontend && rm -rf node_modules package-lock.json && npm install
   cd backend && go mod tidy
   cd tools && cargo clean && cargo build
   ```

3. **Docker构建失败**
   ```bash
   # 清理Docker缓存
   docker system prune -a
   docker-compose build --no-cache
   ```

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👥 作者

- **项目维护者** - [Your Name](https://github.com/yourusername)

## 🙏 致谢

感谢以下开源项目:
- [Vue.js](https://vuejs.org/)
- [Go](https://golang.org/)
- [Rust](https://www.rust-lang.org/)
- [Gin](https://gin-gonic.com/)
- [Vite](https://vitejs.dev/)

---

**⭐ 如果这个项目对你有帮助，请给它一个星标！**