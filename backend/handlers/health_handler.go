package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"demo-backend/models"
)

/**
 * 健康检查接口
 * @route GET /api/health
 * @returns {ApiResponse} 服务状态响应
 */
func HealthCheck(c *gin.Context) {
	response := models.ApiResponse{
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