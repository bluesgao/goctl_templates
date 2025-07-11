# goctl 自定义模板使用指南

## 1. 使用自定义模板生成 RPC 服务

### 生成新的 RPC 服务

```bash
# 创建新的 RPC 服务
goctl rpc new user --home ./templates

# 生成 protobuf 代码
goctl rpc protoc user.proto --go_out=. --go-grpc_out=. --zrpc_out=. --style goZero --home ./templates
```

### 生成现有服务的代码

```bash
# 在 user 目录下生成代码
cd user
goctl rpc protoc proto/user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home ../templates
```

## 2. 使用自定义模板生成 API 服务

### 生成新的 API 服务

```bash
# 创建新的 API 服务
goctl api new apigateway --home ./templates

# 生成 API 代码
goctl api go -api apigateway.api -dir . --style goZero --home ./templates
```

### 生成现有 API 的代码

```bash
# 在 apigw 目录下生成代码
cd apigw
goctl api go -api apigw.api -dir . --style goZero --home ../templates
```

## 3. 使用自定义模板生成数据模型

### 从数据库生成模型

```bash
# 生成单个表的模型
goctl model mysql datasource -t user -c -d --home ./templates

# 生成多个表的模型
goctl model mysql datasource -t "user,merchant,order" -c -d --home ./templates
```

### 从 SQL 文件生成模型

```bash
# 从 SQL 文件生成模型
goctl model mysql ddl -src schema.sql -dir . --home ./templates
```

## 4. 模板自定义说明

### RPC 服务模板特点

- 统一的错误处理机制
- 标准的日志记录格式
- 完整的依赖注入结构
- 规范的代码注释

### API 服务模板特点

- 统一的响应格式
- 标准的参数验证
- 完整的错误处理
- 规范的日志记录

### 数据模型模板特点

- 自动添加时间戳字段
- 软删除支持
- GORM 钩子函数
- 完整的 JSON 标签

## 5. 自定义模板变量

### RPC 服务变量

- `{{.package}}` - 包名
- `{{.pbImport}}` - protobuf 导入路径
- `{{.pbPackage}}` - protobuf 包名
- `{{.method}}` - 方法名
- `{{.request}}` - 请求类型
- `{{.response}}` - 响应类型

### API 服务变量

- `{{.package}}` - 包名
- `{{.method}}` - 方法名
- `{{.request}}` - 请求类型
- `{{.response}}` - 响应类型

### 数据模型变量

- `{{.model}}` - 模型名
- `{{.table}}` - 表名
- `{{.comment}}` - 注释
- `{{.fields}}` - 字段列表

## 6. 最佳实践

### 1. 错误处理

```go
// 使用统一的错误处理
if err != nil {
    return nil, util.NewErrorWithCode(util.ErrCodeUserNotFound)
}
```

### 2. 日志记录

```go
// 使用结构化日志
l.Infof("处理用户请求: userId=%s, action=%s", userId, action)
```

### 3. 参数验证

```go
// 在 handler 层进行参数验证
if req.UserId == "" {
    return nil, util.NewErrorWithCode(util.ErrCodeParamInvalid)
}
```

### 4. 业务逻辑

```go
// 在 logic 层实现业务逻辑
func (l *UserLogic) GetUser(req *types.GetUserRequest) (*types.GetUserResponse, error) {
    // 1. 参数验证
    // 2. 业务逻辑处理
    // 3. 返回结果
}
```

## 7. 注意事项

1. **模板路径**: 确保使用正确的 `--home` 参数指向模板目录
2. **包名一致性**: 确保生成的代码包名与项目结构一致
3. **依赖管理**: 确保所有必要的依赖都已正确导入
4. **配置更新**: 根据实际需求调整配置文件模板
5. **代码审查**: 生成代码后需要进行代码审查和测试
