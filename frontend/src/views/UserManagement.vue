<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import UserList from '../components/UserList.vue'
import UserForm from '../components/UserForm.vue'

// API基础URL
const API_BASE_URL = 'http://localhost:8080/api'

// 响应式数据
const users = ref([])
const loading = ref(false)
const error = ref('')
const showForm = ref(false)
const editingUser = ref(null)

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
 * 更新用户信息
 * @param {Object} userData - 用户数据
 */
const updateUser = async (userData) => {
  console.log('🔄 updateUser 被调用')
  console.log('📊 接收到的用户数据:', userData)
  console.log('👤 当前编辑用户:', editingUser.value)
  
  if (!editingUser.value) {
    console.log('❌ 没有编辑用户，退出')
    return
  }
  
  loading.value = true
  error.value = ''
  
  try {
    console.log('🌐 发送PUT请求到:', `${API_BASE_URL}/users/${editingUser.value.id}`)
    const response = await axios.put(`${API_BASE_URL}/users/${editingUser.value.id}`, userData)
    console.log('📥 服务器响应:', response.data)
    
    if (response.data.code === 200) {
      console.log('✅ 更新成功')
      // 更新成功，刷新用户列表
      await fetchUserList()
      showForm.value = false
      editingUser.value = null
    } else {
      console.log('❌ 更新失败:', response.data.message)
      error.value = response.data.message || '更新用户失败'
    }
  } catch (err) {
    console.error('💥 更新用户异常:', err)
    error.value = '更新用户失败，请检查网络连接'
  } finally {
    loading.value = false
  }
}

/**
 * 删除用户
 * @param {number} userId - 用户ID
 */
const deleteUser = async (userId) => {
  if (!confirm('确定要删除这个用户吗？此操作不可撤销。')) {
    return
  }
  
  loading.value = true
  error.value = ''
  
  try {
    const response = await axios.delete(`${API_BASE_URL}/users/${userId}`)
    if (response.data.code === 200) {
      // 删除成功，刷新用户列表
      await fetchUserList()
    } else {
      error.value = response.data.message || '删除用户失败'
    }
  } catch (err) {
    error.value = '删除用户失败，请稍后重试'
    console.error('删除用户失败:', err)
  } finally {
    loading.value = false
  }
}

/**
 * 开始编辑用户
 * @param {Object} user - 要编辑的用户对象
 */
const startEditUser = (user) => {
  console.log('🖊️ 开始编辑用户:', user)
  editingUser.value = { ...user }
  console.log('📝 设置editingUser:', editingUser.value)
  showForm.value = true
  console.log('📋 显示表单，isEditing应该为true')
  error.value = ''
}

/**
 * 显示/隐藏用户表单
 */
const toggleUserForm = () => {
  showForm.value = !showForm.value
  if (!showForm.value) {
    // 只有在隐藏表单时才重置editingUser
    editingUser.value = null
  }
  error.value = ''
}

/**
 * 取消表单编辑
 */
const cancelForm = () => {
  console.log('❌ 取消表单编辑')
  showForm.value = false
  editingUser.value = null
  error.value = ''
}
onMounted(() => {
  fetchUserList()
})
</script>

<template>
  <div class="user-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>👥 用户管理</h2>
      <p>管理系统用户信息，支持添加、查看用户数据</p>
    </div>

    <!-- 主要内容 -->
    <div class="page-content">
      <!-- 操作栏 -->
      <div class="action-bar">
        <button 
          @click="toggleUserForm" 
          class="btn btn-primary"
          :disabled="loading"
        >
          {{ showForm ? '取消' : (editingUser ? '编辑用户' : '添加用户') }}
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
        @submit="(userData) => {
          console.log('🎯 UserManagement接收到submit事件:', userData)
          console.log('🔄 editingUser状态:', editingUser)
          if (editingUser) {
            console.log('📝 调用updateUser')
            updateUser(userData)
          } else {
            console.log('➕ 调用createUser')
            createUser(userData)
          }
        }"
        @cancel="cancelForm"
        :loading="loading"
        :user="editingUser"
        :is-editing="!!editingUser"
      />

      <!-- 用户列表 -->
      <UserList 
        :users="users" 
        :loading="loading"
        @edit="startEditUser"
        @delete="deleteUser"
      />
    </div>
  </div>
</template>

<style scoped>
.user-management {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

/* 页面头部样式 */
.page-header {
  margin-bottom: 30px;
  text-align: center;
}

.page-header h2 {
  margin: 0 0 10px 0;
  font-size: 2rem;
  color: #2c3e50;
  font-weight: 700;
}

.page-header p {
  margin: 0;
  color: #6c757d;
  font-size: 1.1rem;
}

/* 页面内容样式 */
.page-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
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

/* 响应式设计 */
@media (max-width: 768px) {
  .user-management {
    padding: 10px;
  }
  
  .page-header h2 {
    font-size: 1.5rem;
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