/*
 * @Author: zerg zhoujiale.zerg@gmail.com
 * @Date: 2025-09-28 13:12:35
 * @LastEditors: zerg zhoujiale.zerg@gmail.com
 * @LastEditTime: 2025-09-28 13:18:37
 * @FilePath: \demo_vue_go_rust\frontend\src\router\index.js
 * @Description: 
 */
import { createRouter, createWebHistory } from 'vue-router'

/**
 * 路由配置
 * 定义应用的页面路由规则
 * 使用动态导入实现代码分割和懒加载
 */
const routes = [
    {
        path: '/',
        name: 'Home',
        component: () => import('../views/Home.vue'),
        meta: {
            title: '首页',
            description: 'Vue + Go + Rust 演示项目首页'
        }
    },
    {
        path: '/users',
        name: 'UserManagement',
        component: () => import('../views/UserManagement.vue'),
        meta: {
            title: '用户管理',
            description: '管理系统用户信息'
        }
    }
]

/**
 * 创建路由实例
 */
const router = createRouter({
    history: createWebHistory(),
    routes
})

/**
 * 路由守卫 - 设置页面标题
 */
router.beforeEach((to, from, next) => {
    if (to.meta.title) {
        document.title = `${to.meta.title} - Vue + Go + Rust Demo`
    }
    next()
})

export default router