package routes

import (
	"github.com/gin-gonic/gin"
	"demo-backend/handlers"
)

/**
 * 设置路由
 * 配置所有API端点
 */
func SetupRoutes(r *gin.Engine) {
	// API路由组
	api := r.Group("/api")
	{
		// 健康检查
		api.GET("/health", handlers.HealthCheck)
		
		// 用户相关接口
		api.GET("/users", handlers.GetUserList)
		api.GET("/users/:id", handlers.GetUserById)
		api.POST("/users", handlers.CreateUser)
		api.PUT("/users/:id", handlers.UpdateUser)
		api.DELETE("/users/:id", handlers.DeleteUser)
	}
	
	// 静态文件服务（用于托管前端构建文件）
	r.Static("/assets", "../frontend/dist/assets")
	r.StaticFile("/vite.svg", "../frontend/dist/vite.svg")
	
	// 根路径重定向到前端应用
	r.GET("/", func(c *gin.Context) {
		c.File("../frontend/dist/index.html")
	})
}