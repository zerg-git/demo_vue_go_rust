# 部署指南

## 概述

本文档详细介绍了Vue + Go + Rust全栈项目的部署方案，包括本地开发环境、Docker容器化部署和生产环境部署。

## 环境要求

### 基础环境

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Go | 1.21+ | 后端服务开发语言 |
| Node.js | 18+ | 前端构建工具 |
| Rust | 1.75+ | 工具程序开发语言 |
| Docker | 20.10+ | 容器化部署（可选） |
| Docker Compose | 2.0+ | 容器编排（可选） |

### 系统要求

**最低配置**
- CPU: 2核心
- 内存: 4GB
- 磁盘: 10GB可用空间
- 网络: 100Mbps

**推荐配置**
- CPU: 4核心
- 内存: 8GB
- 磁盘: 50GB SSD
- 网络: 1Gbps

## 本地开发部署

### 1. 环境准备

```bash
# 检查Go版本
go version

# 检查Node.js版本
node --version
npm --version

# 检查Rust版本
rustc --version
cargo --version
```

### 2. 项目构建

```bash
# 克隆项目
git clone <repository-url>
cd demo_vue_go_rust

# 执行构建脚本
./scripts/build.sh
```

构建脚本会自动完成：
- Go后端服务编译
- Vue前端项目打包
- Rust工具程序编译

### 3. 启动服务

#### 方式一：分别启动

```bash
# 启动后端服务
cd backend
go run main.go
# 服务运行在 http://localhost:8080

# 启动前端开发服务器（新终端）
cd frontend
npm run dev
# 服务运行在 http://localhost:5173
```

#### 方式二：使用部署脚本

```bash
# 本地部署
./scripts/deploy.sh --env dev

# 启动服务
cd deploy/dev
./start.sh
```

### 4. 验证部署

```bash
# 检查后端健康状态
curl http://localhost:8080/health

# 检查前端页面
curl http://localhost:5173

# 测试API接口
curl http://localhost:8080/api/users
```

## Docker容器化部署

### 1. 构建Docker镜像

```bash
# 构建所有镜像
docker-compose build

# 或分别构建
docker build -f docker/Dockerfile.backend -t demo-backend .
docker build -f docker/Dockerfile.frontend -t demo-frontend .
docker build -f docker/Dockerfile.tools -t demo-tools .
```

### 2. 启动容器服务

```bash
# 使用Docker Compose启动
docker-compose up -d

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 3. 使用部署脚本

```bash
# Docker部署（推荐）
./scripts/deploy.sh --docker --build --env prod

# 检查部署状态
docker-compose ps
```

### 4. 服务访问

- **前端页面**: http://localhost
- **后端API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health

### 5. 容器管理

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看资源使用
docker stats

# 清理容器和镜像
docker-compose down --rmi all
docker system prune -a
```

## 生产环境部署

### 1. 服务器准备

#### 系统配置
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 配置防火墙
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw enable
```

#### 目录结构
```bash
# 创建部署目录
sudo mkdir -p /opt/demo-app
sudo chown $USER:$USER /opt/demo-app
cd /opt/demo-app

# 创建数据目录
mkdir -p data logs config
```

### 2. 环境变量配置

创建生产环境配置文件：

```bash
# 创建 .env 文件
cat > .env << EOF
# 环境配置
ENVIRONMENT=production
GIN_MODE=release

# 服务端口
BACKEND_PORT=8080
FRONTEND_PORT=80

# 数据库配置（如需要）
DB_HOST=localhost
DB_PORT=5432
DB_NAME=demo_app
DB_USER=demo_user
DB_PASSWORD=secure_password

# 日志配置
LOG_LEVEL=info
LOG_FILE=/app/logs/app.log

# 安全配置
JWT_SECRET=your-super-secret-jwt-key
CORS_ORIGINS=https://yourdomain.com
EOF
```

### 3. 生产环境Docker Compose

创建生产环境的docker-compose配置：

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "8080:8080"
    environment:
      - GIN_MODE=release
      - PORT=8080
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  tools:
    build:
      context: .
      dockerfile: docker/Dockerfile.tools
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    restart: "no"
    profiles: ["tools"]

networks:
  default:
    driver: bridge
```

### 4. SSL证书配置

```bash
# 使用Let's Encrypt获取SSL证书
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d yourdomain.com

# 自动续期
sudo crontab -e
# 添加以下行
0 12 * * * /usr/bin/certbot renew --quiet
```

### 5. 生产环境部署

```bash
# 部署到生产环境
./scripts/deploy.sh --env prod --docker --build

# 或使用生产配置文件
docker-compose -f docker-compose.prod.yml up -d
```

### 6. 监控和日志

#### 日志管理
```bash
# 查看应用日志
docker-compose logs -f backend
docker-compose logs -f frontend

# 日志轮转配置
sudo cat > /etc/logrotate.d/demo-app << EOF
/opt/demo-app/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        docker-compose restart backend frontend
    endscript
}
EOF
```

#### 系统监控
```bash
# 安装监控工具
sudo apt install htop iotop nethogs

# 监控容器资源
docker stats

# 监控磁盘使用
df -h
du -sh /opt/demo-app/*
```

## 高可用部署

### 1. 负载均衡配置

使用Nginx作为负载均衡器：

```nginx
# /etc/nginx/sites-available/demo-app
upstream backend_servers {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}

server {
    listen 80;
    server_name yourdomain.com;
    
    location /api/ {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location / {
        root /var/www/demo-app;
        try_files $uri $uri/ /index.html;
    }
}
```

### 2. 数据库集群

如果使用数据库，配置主从复制：

```yaml
# docker-compose.ha.yml
services:
  postgres-master:
    image: postgres:15
    environment:
      POSTGRES_DB: demo_app
      POSTGRES_USER: demo_user
      POSTGRES_PASSWORD: secure_password
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: repl_password
    volumes:
      - postgres_master_data:/var/lib/postgresql/data
      - ./config/postgresql.conf:/etc/postgresql/postgresql.conf
    command: postgres -c config_file=/etc/postgresql/postgresql.conf

  postgres-slave:
    image: postgres:15
    environment:
      PGUSER: postgres
      POSTGRES_PASSWORD: secure_password
      POSTGRES_MASTER_SERVICE: postgres-master
    depends_on:
      - postgres-master
    volumes:
      - postgres_slave_data:/var/lib/postgresql/data
```

## 性能优化

### 1. 前端优化

```bash
# 启用Gzip压缩
# 在nginx.conf中添加
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

# 启用缓存
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 2. 后端优化

```go
// 在main.go中添加性能优化配置
func main() {
    // 设置GOMAXPROCS
    runtime.GOMAXPROCS(runtime.NumCPU())
    
    // 配置Gin
    gin.SetMode(gin.ReleaseMode)
    r := gin.New()
    
    // 添加中间件
    r.Use(gin.Recovery())
    r.Use(cors.Default())
    
    // 启动服务
    r.Run(":8080")
}
```

### 3. 数据库优化

```sql
-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 配置连接池
-- 在应用中设置
db.SetMaxOpenConns(25)
db.SetMaxIdleConns(25)
db.SetConnMaxLifetime(5 * time.Minute)
```

## 备份和恢复

### 1. 数据备份

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份应用数据
tar -czf $BACKUP_DIR/app_data_$DATE.tar.gz /opt/demo-app/data

# 备份数据库（如果使用）
docker exec postgres-master pg_dump -U demo_user demo_app > $BACKUP_DIR/database_$DATE.sql

# 清理旧备份（保留30天）
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
```

### 2. 自动备份

```bash
# 添加到crontab
crontab -e

# 每天凌晨2点备份
0 2 * * * /opt/demo-app/scripts/backup.sh
```

### 3. 恢复数据

```bash
#!/bin/bash
# restore.sh

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# 停止服务
docker-compose down

# 恢复数据
tar -xzf $BACKUP_FILE -C /

# 重启服务
docker-compose up -d
```

## 故障排查

### 1. 常见问题

#### 服务无法启动
```bash
# 检查端口占用
sudo netstat -tlnp | grep :8080

# 检查Docker状态
docker-compose ps
docker-compose logs backend

# 检查磁盘空间
df -h
```

#### 性能问题
```bash
# 检查系统资源
top
htop
iotop

# 检查容器资源
docker stats

# 检查网络连接
netstat -an | grep :8080
```

#### 数据库连接问题
```bash
# 检查数据库状态
docker-compose exec postgres-master psql -U demo_user -d demo_app -c "SELECT 1;"

# 检查连接数
docker-compose exec postgres-master psql -U demo_user -d demo_app -c "SELECT count(*) FROM pg_stat_activity;"
```

### 2. 日志分析

```bash
# 应用日志
tail -f /opt/demo-app/logs/app.log

# 系统日志
sudo journalctl -u docker -f

# Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 安全加固

### 1. 系统安全

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 配置防火墙
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# 禁用root登录
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### 2. 应用安全

```bash
# 设置文件权限
sudo chown -R www-data:www-data /opt/demo-app
sudo chmod -R 755 /opt/demo-app
sudo chmod 600 /opt/demo-app/.env

# 配置SELinux（如果启用）
sudo setsebool -P httpd_can_network_connect 1
```

### 3. 容器安全

```dockerfile
# 在Dockerfile中使用非root用户
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

USER appuser
```

---

本部署指南涵盖了从开发环境到生产环境的完整部署流程。根据实际需求选择合适的部署方案。