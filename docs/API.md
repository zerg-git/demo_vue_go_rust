# API接口文档

## 概述

本文档描述了Demo项目的RESTful API接口规范，包括请求格式、响应格式、错误处理等详细信息。

## 基础信息

- **Base URL**: `http://localhost:8080`
- **API版本**: v1
- **数据格式**: JSON
- **字符编码**: UTF-8
- **时间格式**: ISO 8601 (RFC3339)

## 通用规范

### 请求头

```http
Content-Type: application/json
Accept: application/json
User-Agent: Demo-Client/1.0
```

### 响应格式

#### 成功响应
```json
{
  "success": true,
  "data": {},
  "message": "操作成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 错误响应
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "输入数据验证失败",
    "details": ["邮箱格式不正确"]
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### HTTP状态码

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| 200 | OK | 请求成功 |
| 201 | Created | 资源创建成功 |
| 400 | Bad Request | 请求参数错误 |
| 404 | Not Found | 资源不存在 |
| 500 | Internal Server Error | 服务器内部错误 |

## 系统接口

### 健康检查

检查服务运行状态。

**请求**
```http
GET /health
```

**响应**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00Z",
  "version": "1.0.0",
  "uptime": "2h30m15s"
}
```

**示例**
```bash
curl -X GET http://localhost:8080/health
```

## 用户管理接口

### 获取用户列表

获取所有用户信息。

**请求**
```http
GET /api/users
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 | 默认值 |
|------|------|------|------|--------|
| page | int | 否 | 页码 | 1 |
| limit | int | 否 | 每页数量 | 10 |
| search | string | 否 | 搜索关键词 | - |

**响应**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "name": "张三",
        "email": "zhangsan@example.com",
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 1,
      "pages": 1
    }
  },
  "message": "获取用户列表成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**示例**
```bash
# 获取第一页用户
curl -X GET "http://localhost:8080/api/users?page=1&limit=10"

# 搜索用户
curl -X GET "http://localhost:8080/api/users?search=张三"
```

### 获取单个用户

根据用户ID获取用户详细信息。

**请求**
```http
GET /api/users/{id}
```

**路径参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | int | 是 | 用户ID |

**响应**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "张三",
    "email": "zhangsan@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "message": "获取用户信息成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**错误响应**
```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "用户不存在",
    "details": ["用户ID: 999 不存在"]
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**示例**
```bash
curl -X GET http://localhost:8080/api/users/1
```

### 创建用户

创建新用户。

**请求**
```http
POST /api/users
Content-Type: application/json

{
  "name": "李四",
  "email": "lisi@example.com"
}
```

**请求体参数**
| 参数 | 类型 | 必填 | 说明 | 验证规则 |
|------|------|------|------|----------|
| name | string | 是 | 用户姓名 | 长度2-50字符 |
| email | string | 是 | 邮箱地址 | 有效邮箱格式 |

**响应**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "李四",
    "email": "lisi@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "message": "用户创建成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**验证错误响应**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "输入数据验证失败",
    "details": [
      "姓名不能为空",
      "邮箱格式不正确"
    ]
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**示例**
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "李四",
    "email": "lisi@example.com"
  }'
```

### 更新用户

更新现有用户信息。

**请求**
```http
PUT /api/users/{id}
Content-Type: application/json

{
  "name": "王五",
  "email": "wangwu@example.com"
}
```

**路径参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | int | 是 | 用户ID |

**请求体参数**
| 参数 | 类型 | 必填 | 说明 | 验证规则 |
|------|------|------|------|----------|
| name | string | 否 | 用户姓名 | 长度2-50字符 |
| email | string | 否 | 邮箱地址 | 有效邮箱格式 |

**响应**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "王五",
    "email": "wangwu@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T01:00:00Z"
  },
  "message": "用户更新成功",
  "timestamp": "2024-01-01T01:00:00Z"
}
```

**示例**
```bash
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "王五",
    "email": "wangwu@example.com"
  }'
```

### 删除用户

删除指定用户。

**请求**
```http
DELETE /api/users/{id}
```

**路径参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | int | 是 | 用户ID |

**响应**
```json
{
  "success": true,
  "data": null,
  "message": "用户删除成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**示例**
```bash
curl -X DELETE http://localhost:8080/api/users/1
```

## 错误码说明

### 系统错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| INTERNAL_ERROR | 500 | 服务器内部错误 |
| INVALID_REQUEST | 400 | 请求格式错误 |
| VALIDATION_ERROR | 400 | 数据验证失败 |
| NOT_FOUND | 404 | 资源不存在 |

### 业务错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| USER_NOT_FOUND | 404 | 用户不存在 |
| USER_ALREADY_EXISTS | 400 | 用户已存在 |
| INVALID_USER_DATA | 400 | 用户数据无效 |

## 数据模型

### User 用户模型

```json
{
  "id": 1,
  "name": "张三",
  "email": "zhangsan@example.com",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

**字段说明**
| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | int | 用户唯一标识 | 自增主键 |
| name | string | 用户姓名 | 2-50字符 |
| email | string | 邮箱地址 | 唯一，有效邮箱格式 |
| created_at | string | 创建时间 | ISO 8601格式 |
| updated_at | string | 更新时间 | ISO 8601格式 |

### Pagination 分页模型

```json
{
  "page": 1,
  "limit": 10,
  "total": 100,
  "pages": 10
}
```

**字段说明**
| 字段 | 类型 | 说明 |
|------|------|------|
| page | int | 当前页码 |
| limit | int | 每页数量 |
| total | int | 总记录数 |
| pages | int | 总页数 |

## 测试用例

### 使用cURL测试

```bash
# 健康检查
curl -X GET http://localhost:8080/health

# 获取用户列表
curl -X GET http://localhost:8080/api/users

# 创建用户
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "测试用户", "email": "test@example.com"}'

# 获取用户详情
curl -X GET http://localhost:8080/api/users/1

# 更新用户
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "更新用户", "email": "updated@example.com"}'

# 删除用户
curl -X DELETE http://localhost:8080/api/users/1
```

### 使用Rust工具测试

```bash
# 健康检查
./tools/target/release/demo-tools api health-check --url http://localhost:8080

# 测试用户接口
./tools/target/release/demo-tools api test-users --url http://localhost:8080
```

## 性能指标

### 响应时间

| 接口 | 平均响应时间 | 95%响应时间 |
|------|--------------|-------------|
| GET /health | < 10ms | < 20ms |
| GET /api/users | < 50ms | < 100ms |
| POST /api/users | < 100ms | < 200ms |
| PUT /api/users/{id} | < 100ms | < 200ms |
| DELETE /api/users/{id} | < 50ms | < 100ms |

### 并发能力

- **最大并发**: 1000 req/s
- **平均吞吐量**: 500 req/s
- **错误率**: < 0.1%

## 版本历史

| 版本 | 发布日期 | 变更说明 |
|------|----------|----------|
| v1.0.0 | 2024-01-01 | 初始版本，包含基础用户管理功能 |

---

本API文档将随着功能迭代持续更新。如有疑问，请联系开发团队。