<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// 当前时间
const currentTime = ref('')

/**
 * 更新当前时间
 */
const updateCurrentTime = () => {
  currentTime.value = new Date().toLocaleString()
}

// 每秒更新时间
setInterval(updateCurrentTime, 1000)
</script>

<template>
  <div class="home-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>Vue + Go + Rust 演示项目</h1>
      <p>现代化全栈开发技术栈展示</p>
      <div class="current-time">
        🕒 当前时间：{{ currentTime }}
      </div>
    </div>

    <!-- 主要内容 -->
    <div class="page-content">
      <!-- 项目介绍 -->
      <div class="intro-section">
        <h2>🚀 项目简介</h2>
        <div class="tech-stack">
          <div class="tech-item">
            <div class="tech-icon">🎨</div>
            <h3>前端技术</h3>
            <p>Vue 3 + Vite + Vue Router</p>
            <ul>
              <li>响应式设计</li>
              <li>组件化开发</li>
              <li>现代化构建工具</li>
            </ul>
          </div>
          
          <div class="tech-item">
            <div class="tech-icon">⚡</div>
            <h3>后端技术</h3>
            <p>Go + Gin 框架</p>
            <ul>
              <li>高性能 API 服务</li>
              <li>RESTful 接口设计</li>
              <li>并发处理能力</li>
            </ul>
          </div>
          
          <div class="tech-item">
            <div class="tech-icon">🦀</div>
            <h3>工具链</h3>
            <p>Rust 开发工具</p>
            <ul>
              <li>系统级性能</li>
              <li>内存安全</li>
              <li>现代化工具链</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- 功能导航 -->
      <div class="navigation-section">
        <h2>📋 功能模块</h2>
        <div class="feature-cards">
          <router-link to="/users" class="feature-card">
            <div class="card-icon">👥</div>
            <h3>用户管理</h3>
            <p>完整的用户 CRUD 操作</p>
            <div class="card-features">
              <span class="feature-tag">创建用户</span>
              <span class="feature-tag">查看列表</span>
              <span class="feature-tag">数据验证</span>
            </div>
            <button class="nav-button">进入模块 →</button>
          </router-link>
        </div>
      </div>

      <!-- 项目特性 -->
      <div class="features-section">
        <h2>✨ 项目特性</h2>
        <div class="features-grid">
          <div class="feature-item">
            <div class="feature-icon">🎯</div>
            <h4>现代化架构</h4>
            <p>采用最新的技术栈和最佳实践</p>
          </div>
          
          <div class="feature-item">
            <div class="feature-icon">📱</div>
            <h4>响应式设计</h4>
            <p>完美适配各种设备和屏幕尺寸</p>
          </div>
          
          <div class="feature-item">
            <div class="feature-icon">🔧</div>
            <h4>开发友好</h4>
            <p>完整的开发工具链和调试支持</p>
          </div>
          
          <div class="feature-item">
            <div class="feature-icon">🚀</div>
            <h4>高性能</h4>
            <p>优化的构建流程和运行时性能</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
  min-height: 100vh;
}

/* 页面头部样式 */
.page-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
}

.page-header h1 {
  margin: 0 0 15px 0;
  font-size: 2.5rem;
  font-weight: 700;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.page-header p {
  margin: 0 0 20px 0;
  font-size: 1.2rem;
  opacity: 0.9;
}

.current-time {
  background: rgba(255, 255, 255, 0.2);
  padding: 10px 20px;
  border-radius: 25px;
  display: inline-block;
  font-weight: 500;
  backdrop-filter: blur(10px);
}

/* 主要内容样式 */
.page-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* 介绍部分 */
.intro-section {
  padding: 40px;
  border-bottom: 1px solid #e9ecef;
}

.intro-section h2 {
  margin: 0 0 30px 0;
  font-size: 1.8rem;
  color: #2c3e50;
  text-align: center;
}

.tech-stack {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
  margin-top: 30px;
}

.tech-item {
  text-align: center;
  padding: 30px 20px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: transform 0.3s ease;
}

.tech-item:hover {
  transform: translateY(-5px);
}

.tech-icon {
  font-size: 3rem;
  margin-bottom: 15px;
}

.tech-item h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1.3rem;
}

.tech-item p {
  margin: 0 0 15px 0;
  color: #667eea;
  font-weight: 600;
}

.tech-item ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.tech-item li {
  padding: 5px 0;
  color: #6c757d;
}

/* 导航部分 */
.navigation-section {
  padding: 40px;
  border-bottom: 1px solid #e9ecef;
}

.navigation-section h2 {
  margin: 0 0 30px 0;
  font-size: 1.8rem;
  color: #2c3e50;
  text-align: center;
}

.feature-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 30px;
}

/* 功能卡片样式 */
.feature-card {
  background: white;
  border-radius: 15px;
  padding: 30px 25px;
  text-align: center;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 2px solid transparent;
  text-decoration: none;
  color: inherit;
  display: block;
}

.feature-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.card-icon {
  font-size: 3.5rem;
  margin-bottom: 20px;
}

.feature-card h3 {
  margin: 0 0 15px 0;
  color: #2c3e50;
  font-size: 1.4rem;
}

.feature-card p {
  margin: 0 0 20px 0;
  color: #6c757d;
  line-height: 1.6;
}

.card-features {
  margin-bottom: 25px;
}

.feature-tag {
  display: inline-block;
  background: #667eea;
  color: white;
  padding: 5px 12px;
  border-radius: 15px;
  font-size: 0.85rem;
  margin: 3px;
}

.nav-button {
  background: #667eea;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 25px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.nav-button:hover {
  background: #5a67d8;
  transform: translateY(-2px);
}

/* 特性部分 */
.features-section {
  padding: 40px;
}

.features-section h2 {
  margin: 0 0 30px 0;
  font-size: 1.8rem;
  color: #2c3e50;
  text-align: center;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 25px;
}

.feature-item {
  text-align: center;
  padding: 25px 15px;
}

.feature-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
}

.feature-item h4 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.feature-item p {
  margin: 0;
  color: #6c757d;
  line-height: 1.5;
  font-size: 0.95rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .home-page {
    padding: 10px;
  }
  
  .page-header {
    padding: 30px 15px;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .tech-stack {
    grid-template-columns: 1fr;
  }
  
  .feature-cards {
    grid-template-columns: 1fr;
  }
  
  .features-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
  
  .intro-section,
  .navigation-section,
  .features-section {
    padding: 25px 20px;
  }
}
</style>