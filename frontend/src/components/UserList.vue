<script setup>
import { defineProps } from 'vue'

// 定义组件属性
const props = defineProps({
  users: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

/**
 * 格式化日期显示
 * @param {string} dateString - 日期字符串
 * @returns {string} 格式化后的日期
 */
const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('zh-CN')
}
</script>

<template>
  <div class="user-list">
    <!-- 加载状态 -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>正在加载用户数据...</p>
    </div>

    <!-- 空状态 -->
    <div v-else-if="!users || users.length === 0" class="empty-state">
      <div class="empty-icon">👥</div>
      <h3>暂无用户数据</h3>
      <p>点击"添加用户"按钮创建第一个用户</p>
    </div>

    <!-- 用户列表 -->
    <div v-else class="user-grid">
      <div 
        v-for="user in users" 
        :key="user.id" 
        class="user-card"
      >
        <div class="user-avatar">
          {{ user.name.charAt(0) }}
        </div>
        
        <div class="user-info">
          <h3 class="user-name">{{ user.name }}</h3>
          <p class="user-email">{{ user.email }}</p>
          <div class="user-meta">
            <span class="user-id">ID: {{ user.id }}</span>
            <span class="user-date">{{ formatDate(user.create_at) }}</span>
          </div>
        </div>
        
        <div class="user-actions">
          <button class="action-btn view-btn" title="查看详情">
            👁️
          </button>
          <button class="action-btn edit-btn" title="编辑用户">
            ✏️
          </button>
        </div>
      </div>
    </div>

    <!-- 用户统计 -->
    <div v-if="users && users.length > 0" class="user-stats">
      <p>共 <strong>{{ users.length }}</strong> 个用户</p>
    </div>
  </div>
</template>

<style scoped>
.user-list {
  padding: 30px;
}

/* 加载状态样式 */
.loading-state {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 空状态样式 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #495057;
}

.empty-state p {
  margin: 0;
  font-size: 0.95rem;
}

/* 用户网格样式 */
.user-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

/* 用户卡片样式 */
.user-card {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  transition: all 0.3s ease;
  position: relative;
}

.user-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #667eea;
}

/* 用户头像样式 */
.user-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.2rem;
  flex-shrink: 0;
}

/* 用户信息样式 */
.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  margin: 0 0 5px 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #212529;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-email {
  margin: 0 0 10px 0;
  color: #6c757d;
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-meta {
  display: flex;
  gap: 15px;
  font-size: 0.8rem;
  color: #868e96;
}

.user-id {
  font-weight: 600;
}

/* 用户操作按钮样式 */
.user-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex-shrink: 0;
}

.action-btn {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.view-btn {
  background: #e3f2fd;
  color: #1976d2;
}

.view-btn:hover {
  background: #bbdefb;
  transform: scale(1.1);
}

.edit-btn {
  background: #fff3e0;
  color: #f57c00;
}

.edit-btn:hover {
  background: #ffe0b2;
  transform: scale(1.1);
}

/* 用户统计样式 */
.user-stats {
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  color: #495057;
  font-size: 0.95rem;
}

.user-stats strong {
  color: #667eea;
  font-weight: 700;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-grid {
    grid-template-columns: 1fr;
  }
  
  .user-card {
    padding: 15px;
  }
  
  .user-actions {
    flex-direction: row;
  }
  
  .user-meta {
    flex-direction: column;
    gap: 5px;
  }
}

@media (max-width: 480px) {
  .user-list {
    padding: 20px;
  }
  
  .user-card {
    flex-direction: column;
    text-align: center;
    gap: 10px;
  }
  
  .user-info {
    width: 100%;
  }
  
  .user-actions {
    justify-content: center;
  }
}
</style>