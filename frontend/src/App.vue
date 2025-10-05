<script setup>
import { ref } from 'vue'

/**
 * 检查后端服务状态
 */
const checkBackendStatus = async () => {
  try {
    const response = await fetch('http://localhost:8080/api/health')
    return response.ok
  } catch (error) {
    return false
  }
}

// 响应式数据
const backendStatus = ref(null)

/**
 * 检查服务状态
 */
const checkServiceStatus = async () => {
  backendStatus.value = await checkBackendStatus()
}

// 页面加载时检查服务状态
checkServiceStatus()
</script>

<template>
  <div id="app">
    <!-- 头部 -->
    <header class="app-header">
      <div class="header-content">
        <h1>🚀 Vue + Go + Rust Demo</h1>
        <p>现代化全栈开发技术栈演示项目</p>
        
        <div class="tech-badges">
          <span class="badge vue">Vue.js</span>
          <span class="badge go">Go + Gin</span>
          <span class="badge rust">Rust</span>
        </div>
      </div>
    </header>

    <!-- 导航菜单 -->
    <nav class="app-navigation">
      <div class="nav-container">
        <div class="nav-menu">
          <router-link 
            to="/" 
            class="nav-item"
          >
            🏠 首页
          </router-link>
          
          <router-link 
            to="/users" 
            class="nav-item"
          >
            👥 用户管理
          </router-link>
          
          <!-- 预留其他功能模块 -->
          <button class="nav-item disabled" disabled>
            📊 数据分析
          </button>
          
          <button class="nav-item disabled" disabled>
            ⚙️ 系统设置
          </button>
        </div>
        
        <!-- 服务状态指示器 -->
        <div class="status-indicator">
          <div class="status-item">
            <span class="status-label">后端服务:</span>
            <span 
              :class="['status-dot', backendStatus === true ? 'online' : backendStatus === false ? 'offline' : 'checking']"
            ></span>
            <span class="status-text">
              {{ backendStatus === true ? '在线' : backendStatus === false ? '离线' : '检查中...' }}
            </span>
          </div>
          
          <button @click="checkServiceStatus" class="refresh-btn">
            🔄 刷新状态
          </button>
        </div>
      </div>
    </nav>

    <!-- 主要内容区域 -->
    <main class="app-main">
      <div class="container">
        <!-- 路由视图 -->
        <router-view />
      </div>
    </main>

    <!-- 页脚 -->
    <footer class="app-footer">
      <p>
        后端API: <a href="http://localhost:8080/api/health" target="_blank" rel="noopener">localhost:8080</a> | 
        前端应用: <a href="http://localhost:5173" target="_blank" rel="noopener">localhost:5173</a>
      </p>
    </footer>
  </div>
</template>

<style scoped>
/* 全局样式 */
#app {
  min-height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 头部样式 */
.app-header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  padding: 40px 20px;
  text-align: center;
  color: white;
}

.header-content h1 {
  margin: 0 0 10px 0;
  font-size: 2.5rem;
  font-weight: 700;
}

.header-content p {
  margin: 0 0 20px 0;
  font-size: 1.1rem;
  opacity: 0.9;
}

.tech-badges {
  display: flex;
  justify-content: center;
  gap: 15px;
  flex-wrap: wrap;
}

.badge {
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.9rem;
  color: white;
}

.badge.vue { background: #4FC08D; }
.badge.go { background: #00ADD8; }
.badge.rust { background: #CE422B; }

/* 导航菜单样式 */
.app-navigation {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  padding: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.nav-menu {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.nav-item {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  backdrop-filter: blur(10px);
  text-decoration: none;
  display: inline-block;
}

.nav-item:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.nav-item.router-link-active {
  background: rgba(255, 255, 255, 0.4);
  box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
}

.nav-item.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 服务状态指示器样式 */
.status-indicator {
  display: flex;
  align-items: center;
  gap: 15px;
  color: white;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-label {
  font-size: 0.9rem;
  font-weight: 500;
}

.status-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}

.status-dot.online {
  background: #28a745;
  box-shadow: 0 0 8px rgba(40, 167, 69, 0.6);
}

.status-dot.offline {
  background: #dc3545;
  box-shadow: 0 0 8px rgba(220, 53, 69, 0.6);
}

.status-dot.checking {
  background: #ffc107;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.status-text {
  font-size: 0.9rem;
  font-weight: 500;
}

.refresh-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.85rem;
}

.refresh-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 主要内容样式 */
.app-main {
  flex: 1;
  padding: 40px 20px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
}

/* 页脚样式 */
.app-footer {
  background: rgba(0, 0, 0, 0.1);
  padding: 20px;
  text-align: center;
  color: white;
}

.app-footer a {
  color: #ffd700;
  text-decoration: none;
}

.app-footer a:hover {
  text-decoration: underline;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-content h1 {
    font-size: 2rem;
  }
  
  .tech-badges {
    justify-content: center;
  }
  
  .nav-container {
    flex-direction: column;
    align-items: stretch;
  }
  
  .nav-menu {
    justify-content: center;
  }
  
  .status-indicator {
    justify-content: center;
  }
  
  .nav-item {
    flex: 1;
    min-width: 120px;
    text-align: center;
  }
}
</style>
