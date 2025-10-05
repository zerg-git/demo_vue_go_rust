package handlers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"demo-backend/models"
)

// 模拟用户数据
var users = []models.User{
	{ID: 1, Name: "张三", Email: "zhangsan@example.com", CreateAt: "2024-01-01"},
	{ID: 2, Name: "李四", Email: "lisi@example.com", CreateAt: "2024-01-02"},
	{ID: 3, Name: "王五", Email: "wangwu@example.com", CreateAt: "2024-01-03"},
}

/**
 * 获取所有用户列表
 * @route GET /api/users
 * @returns {ApiResponse} 用户列表响应
 */
func GetUserList(c *gin.Context) {
	response := models.ApiResponse{
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
func GetUserById(c *gin.Context) {
	id := c.Param("id")
	
	// 查找用户（简化实现）
	for _, user := range users {
		if fmt.Sprintf("%d", user.ID) == id {
			response := models.ApiResponse{
				Code:    200,
				Message: "获取用户信息成功",
				Data:    user,
			}
			c.JSON(http.StatusOK, response)
			return
		}
	}
	
	response := models.ApiResponse{
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
func CreateUser(c *gin.Context) {
	var newUser models.User
	
	if err := c.ShouldBindJSON(&newUser); err != nil {
		response := models.ApiResponse{
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
	
	response := models.ApiResponse{
		Code:    201,
		Message: "用户创建成功",
		Data:    newUser,
	}
	c.JSON(http.StatusCreated, response)
}

/**
 * 更新用户信息
 * @route PUT /api/users/:id
 * @param {string} id - 用户ID
 * @body {User} user - 更新的用户信息
 * @returns {ApiResponse} 更新结果响应
 */
func UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var updatedUser models.User
	
	if err := c.ShouldBindJSON(&updatedUser); err != nil {
		response := models.ApiResponse{
			Code:    400,
			Message: "请求参数错误: " + err.Error(),
			Data:    nil,
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}
	
	// 查找并更新用户
	for i, user := range users {
		if fmt.Sprintf("%d", user.ID) == id {
			// 保持原有ID和创建时间，只更新名称和邮箱
			users[i].Name = updatedUser.Name
			users[i].Email = updatedUser.Email
			
			response := models.ApiResponse{
				Code:    200,
				Message: "用户信息更新成功",
				Data:    users[i],
			}
			c.JSON(http.StatusOK, response)
			return
		}
	}
	
	response := models.ApiResponse{
		Code:    404,
		Message: "用户不存在",
		Data:    nil,
	}
	c.JSON(http.StatusNotFound, response)
}

/**
 * 删除用户
 * @route DELETE /api/users/:id
 * @param {string} id - 用户ID
 * @returns {ApiResponse} 删除结果响应
 */
func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	
	// 查找并删除用户
	for i, user := range users {
		if fmt.Sprintf("%d", user.ID) == id {
			// 从切片中删除用户
			users = append(users[:i], users[i+1:]...)
			
			response := models.ApiResponse{
				Code:    200,
				Message: "用户删除成功",
				Data: gin.H{
					"deleted_user_id": user.ID,
					"deleted_user_name": user.Name,
				},
			}
			c.JSON(http.StatusOK, response)
			return
		}
	}
	
	response := models.ApiResponse{
		Code:    404,
		Message: "用户不存在",
		Data:    nil,
	}
	c.JSON(http.StatusNotFound, response)
}