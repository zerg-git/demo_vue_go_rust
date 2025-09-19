<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import UserList from './components/UserList.vue'
import UserForm from './components/UserForm.vue'

// API基础URL
const API_BASE_URL = 'http://localhost:8080/api'

// 响应式数据
const users = ref([])
const loading = ref(false)
const error = ref('')
const showForm = ref(false)

/**
 * 获取用户列表
 * 从后端API获取所有用户数据
 */
const fetchUserList = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await axios.get(`${API_BASE_URL}/users`)
    if (response.data.code === 200) {
      users.value = response.data.data
    } else {
      error.value = response.data.message || '获取用户列表失败'
    }
  } catch (err) {
    error.value = '网络请求失败，请检查后端服务是否启动'
    console.error('获取用户列表失败:', err)
  } finally {
    loading.value = false
  }
}

/**
 * 创建新用户
 * @param {Object} userData - 用户数据
 */
const createUser = async (userData) => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await axios.post(`${API_BASE_URL}/users`, userData)
    if (response.data.code === 201) {
      // 创建成功，刷新用户列表
      await fetchUserList()
      showForm.value = false
    } else {
      error.value = response.data.message || '创建用户失败'
    }
  } catch (err) {
    error.value = '创建用户失败，请检查输入数据'
    console.error('创建用户失败:', err)
  } finally {
    loading.value = false
  }
}

/**
 * 显示/隐藏用户表单
 */
const toggleUserForm = () => {
  showForm.value = !showForm.value
  error.value = ''
}

// 组件挂载时获取用户列表
onMounted(() => {
  fetchUserList()
})
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

    <!-- 主要内容 -->
    <main class="app-main">
      <div class="container">
        <!-- 操作栏 -->
        <div class="action-bar">
          <button 
            @click="toggleUserForm" 
            class="btn btn-primary"
            :disabled="loading"
          >
            {{ showForm ? '取消' : '添加用户' }}
          </button>
          
          <button 
            @click="fetchUserList" 
            class="btn btn-secondary"
            :disabled="loading"
          >
            {{ loading ? '刷新中...' : '刷新列表' }}
          </button>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="error-message">
          ❌ {{ error }}
        </div>

        <!-- 用户表单 -->
        <UserForm 
          v-if="showForm" 
          @submit="createUser"
          @cancel="toggleUserForm"
          :loading="loading"
        />

        <!-- 用户列表 -->
        <UserList 
          :users="users" 
          :loading="loading"
        />
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

/* 主要内容样式 */
.app-main {
  flex: 1;
  padding: 40px 20px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

/* 操作栏样式 */
.action-bar {
  padding: 30px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #5a67d8;
  transform: translateY(-2px);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-2px);
}

/* 错误提示样式 */
.error-message {
  margin: 20px 30px;
  padding: 15px;
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  font-weight: 500;
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
  
  .action-bar {
    padding: 20px;
  }
  
  .btn {
    flex: 1;
    min-width: 120px;
  }
}
</style>
