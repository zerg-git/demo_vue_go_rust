package main

import (
	"github.com/gin-gonic/gin"
	"demo-backend/middleware"
	"demo-backend/routes"
)

func main() {
	// 设置Gin模式
	gin.SetMode(gin.ReleaseMode)
	
	// 创建Gin引擎
	r := gin.Default()
	
	// 设置CORS中间件
	r.Use(middleware.SetupCORS())
	
	// 设置路由
	routes.SetupRoutes(r)
	
	// 启动服务器
	port := ":8080"
	println("🚀 服务器启动成功!")
	println("📍 API地址: http://localhost:8080/api")
	println("🏥 健康检查: http://localhost:8080/api/health")
	println("👥 用户列表: http://localhost:8080/api/users")
	
	if err := r.Run(port); err != nil {
		panic("服务器启动失败: " + err.Error())
	}
}