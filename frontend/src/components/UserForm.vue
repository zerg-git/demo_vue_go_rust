<script setup>
import { ref, defineEmits, defineProps, watch, onMounted } from 'vue'

// 定义组件属性
const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  },
  user: {
    type: Object,
    default: null
  },
  isEditing: {
    type: Boolean,
    default: false
  }
})

// 定义组件事件
const emit = defineEmits(['submit', 'cancel'])

// 表单数据
const formData = ref({
  name: '',
  email: ''
})

// 表单验证错误
const errors = ref({})

/**
 * 初始化表单数据
 */
const initializeForm = () => {
  console.log('🔄 初始化表单数据')
  console.log('📊 props.isEditing:', props.isEditing)
  console.log('👤 props.user:', props.user)
  
  if (props.isEditing && props.user) {
    formData.value = {
      name: props.user.name || '',
      email: props.user.email || ''
    }
    console.log('✏️ 编辑模式 - 设置表单数据:', formData.value)
  } else {
    formData.value = {
      name: '',
      email: ''
    }
    console.log('➕ 新增模式 - 清空表单数据')
  }
  errors.value = {}
}

// 监听编辑状态变化
watch(() => [props.isEditing, props.user], () => {
  initializeForm()
}, { immediate: true })

// 组件挂载时初始化
onMounted(() => {
  initializeForm()
})

/**
 * 验证表单数据
 * @returns {boolean} 验证是否通过
 */
const validateForm = () => {
  errors.value = {}
  
  // 验证姓名
  if (!formData.value.name.trim()) {
    errors.value.name = '请输入用户姓名'
  } else if (formData.value.name.trim().length < 2) {
    errors.value.name = '姓名至少需要2个字符'
  } else if (formData.value.name.trim().length > 20) {
    errors.value.name = '姓名不能超过20个字符'
  }
  
  // 验证邮箱
  if (!formData.value.email.trim()) {
    errors.value.email = '请输入邮箱地址'
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.value.email.trim())) {
      errors.value.email = '请输入有效的邮箱地址'
    }
  }
  
  return Object.keys(errors.value).length === 0
}

/**
 * 提交表单
 */
const handleSubmit = () => {
  console.log('🚀 handleSubmit 被调用')
  console.log('📝 当前表单数据:', formData.value)
  console.log('🔍 验证状态:', validateForm())
  
  if (!validateForm()) {
    console.log('❌ 表单验证失败')
    return
  }
  
  // 清理数据并提交
  const userData = {
    name: formData.value.name.trim(),
    email: formData.value.email.trim().toLowerCase()
  }
  
  console.log('✅ 准备提交数据:', userData)
  emit('submit', userData)
  console.log('📤 已发送submit事件')
}

/**
 * 取消表单
 */
const handleCancel = () => {
  // 重置表单
  initializeForm()
  
  emit('cancel')
}

/**
 * 清除字段错误
 * @param {string} field - 字段名
 */
const clearFieldError = (field) => {
  if (errors.value[field]) {
    delete errors.value[field]
  }
}
</script>

<template>
  <div class="user-form">
    <div class="form-header">
      <h3>{{ isEditing ? '✏️ 编辑用户' : '📝 添加新用户' }}</h3>
      <p>{{ isEditing ? '修改用户的基本信息' : '请填写用户的基本信息' }}</p>
    </div>
    
    <form @submit.prevent="handleSubmit" class="form-content">
      <!-- 姓名输入 -->
      <div class="form-group">
        <label for="name" class="form-label">
          用户姓名 <span class="required">*</span>
        </label>
        <input
          id="name"
          v-model="formData.name"
          type="text"
          class="form-input"
          :class="{ 'error': errors.name }"
          placeholder="请输入用户姓名"
          maxlength="20"
          @input="clearFieldError('name')"
          :disabled="loading"
        />
        <div v-if="errors.name" class="error-text">
          {{ errors.name }}
        </div>
        <div class="input-hint">
          2-20个字符，支持中英文
        </div>
      </div>

      <!-- 邮箱输入 -->
      <div class="form-group">
        <label for="email" class="form-label">
          邮箱地址 <span class="required">*</span>
        </label>
        <input
          id="email"
          v-model="formData.email"
          type="email"
          class="form-input"
          :class="{ 'error': errors.email }"
          placeholder="请输入邮箱地址"
          @input="clearFieldError('email')"
          :disabled="loading"
        />
        <div v-if="errors.email" class="error-text">
          {{ errors.email }}
        </div>
        <div class="input-hint">
          请输入有效的邮箱地址，如：user@example.com
        </div>
      </div>

      <!-- 表单操作按钮 -->
      <div class="form-actions">
        <button
          type="button"
          @click="handleCancel"
          class="btn btn-cancel"
          :disabled="loading"
        >
          取消
        </button>
        
        <button
          type="submit"
          class="btn btn-submit"
          :disabled="loading"
        >
          <span v-if="loading" class="loading-text">
            <span class="loading-dot"></span>
            {{ isEditing ? '更新中...' : '创建中...' }}
          </span>
          <span v-else>
            {{ isEditing ? '✅ 更新用户' : '✅ 创建用户' }}
          </span>
        </button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.user-form {
  margin: 20px 30px;
  background: #ffffff;
  border: 1px solid #e9ecef;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 表单头部样式 */
.form-header {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 25px 30px;
  text-align: center;
}

.form-header h3 {
  margin: 0 0 8px 0;
  font-size: 1.3rem;
  font-weight: 600;
}

.form-header p {
  margin: 0;
  opacity: 0.9;
  font-size: 0.95rem;
}

/* 表单内容样式 */
.form-content {
  padding: 30px;
}

.form-group {
  margin-bottom: 25px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #495057;
  font-size: 0.95rem;
}

.required {
  color: #dc3545;
  font-weight: 700;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #ffffff;
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input.error {
  border-color: #dc3545;
  background: #fff5f5;
}

.form-input.error:focus {
  box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1);
}

.form-input:disabled {
  background: #f8f9fa;
  color: #6c757d;
  cursor: not-allowed;
}

.error-text {
  margin-top: 6px;
  color: #dc3545;
  font-size: 0.85rem;
  font-weight: 500;
}

.input-hint {
  margin-top: 6px;
  color: #6c757d;
  font-size: 0.8rem;
}

/* 表单操作按钮样式 */
.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
  padding-top: 25px;
  border-top: 1px solid #e9ecef;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-cancel {
  background: #6c757d;
  color: white;
}

.btn-cancel:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-submit {
  background: #28a745;
  color: white;
  min-width: 120px;
  justify-content: center;
}

.btn-submit:hover:not(:disabled) {
  background: #218838;
  transform: translateY(-1px);
}

/* 加载状态样式 */
.loading-text {
  display: flex;
  align-items: center;
  gap: 8px;
}

.loading-dot {
  width: 12px;
  height: 12px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-form {
    margin: 20px 15px;
  }
  
  .form-header {
    padding: 20px;
  }
  
  .form-content {
    padding: 20px;
  }
  
  .form-actions {
    flex-direction: column-reverse;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .form-header h3 {
    font-size: 1.1rem;
  }
  
  .form-input {
    padding: 10px 12px;
  }
  
  .btn {
    padding: 10px 20px;
  }
}
</style>