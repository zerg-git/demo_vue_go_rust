package main

import (
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// User 用户数据结构
type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	CreateAt string `json:"create_at"`
}

// ApiResponse 统一API响应结构
type ApiResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

// 模拟用户数据
var users = []User{
	{ID: 1, Name: "张三", Email: "zhangsan@example.com", CreateAt: "2024-01-01"},
	{ID: 2, Name: "李四", Email: "lisi@example.com", CreateAt: "2024-01-02"},
	{ID: 3, Name: "王五", Email: "wangwu@example.com", CreateAt: "2024-01-03"},
}

/**
 * 获取所有用户列表
 * @route GET /api/users
 * @returns {ApiResponse} 用户列表响应
 */
func getUserList(c *gin.Context) {
	response := ApiResponse{
		Code:    200,
		Message: "获取用户列表成功",
		Data:    users,
	}
	c.JSON(http.StatusOK, response)
}

/**
 * 根据ID获取用户信息
 * @route GET /api/users/:id
 * @param {string} id - 用户ID
 * @returns {ApiResponse} 用户信息响应
 */
func getUserById(c *gin.Context) {
	id := c.Param("id")
	
	// 查找用户（简化实现）
	for _, user := range users {
		if user.ID == 1 && id == "1" || user.ID == 2 && id == "2" || user.ID == 3 && id == "3" {
			response := ApiResponse{
				Code:    200,
				Message: "获取用户信息成功",
				Data:    user,
			}
			c.JSON(http.StatusOK, response)
			return
		}
	}
	
	response := ApiResponse{
		Code:    404,
		Message: "用户不存在",
		Data:    nil,
	}
	c.JSON(http.StatusNotFound, response)
}

/**
 * 创建新用户
 * @route POST /api/users
 * @body {User} user - 用户信息
 * @returns {ApiResponse} 创建结果响应
 */
func createUser(c *gin.Context) {
	var newUser User
	
	if err := c.ShouldBindJSON(&newUser); err != nil {
		response := ApiResponse{
			Code:    400,
			Message: "请求参数错误: " + err.Error(),
			Data:    nil,
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}
	
	// 生成新ID和创建时间
	newUser.ID = len(users) + 1
	newUser.CreateAt = time.Now().Format("2006-01-02")
	
	// 添加到用户列表
	users = append(users, newUser)
	
	response := ApiResponse{
		Code:    201,
		Message: "用户创建成功",
		Data:    newUser,
	}
	c.JSON(http.StatusCreated, response)
}

/**
 * 健康检查接口
 * @route GET /api/health
 * @returns {ApiResponse} 服务状态响应
 */
func healthCheck(c *gin.Context) {
	response := ApiResponse{
		Code:    200,
		Message: "服务运行正常",
		Data: gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Format("2006-01-02 15:04:05"),
			"version":   "1.0.0",
		},
	}
	c.JSON(http.StatusOK, response)
}

/**
 * 设置CORS中间件
 * 允许前端跨域访问API
 */
func setupCORS() gin.HandlerFunc {
	return cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:5173", "http://localhost:3000"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	})
}

/**
 * 设置路由
 * 配置所有API端点
 */
func setupRoutes(r *gin.Engine) {
	// API路由组
	api := r.Group("/api")
	{
		// 健康检查
		api.GET("/health", healthCheck)
		
		// 用户相关接口
		api.GET("/users", getUserList)
		api.GET("/users/:id", getUserById)
		api.POST("/users", createUser)
	}
	
	// 静态文件服务（用于托管前端构建文件）
	r.Static("/static", "./static")
	r.LoadHTMLGlob("templates/*")
	
	// 根路径重定向到前端应用
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{
			"title": "Vue + Go + Rust Demo",
		})
	})
}

func main() {
	// 设置Gin模式
	gin.SetMode(gin.ReleaseMode)
	
	// 创建Gin引擎
	r := gin.Default()
	
	// 设置CORS中间件
	r.Use(setupCORS())
	
	// 设置路由
	setupRoutes(r)
	
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