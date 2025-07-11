# 优化后的分层架构 RPC 模板使用指南

## 概述

这是一个经过优化的 goctl RPC 模板，提供了完整的分层架构支持。**最新版本已移除Handler层**，简化了架构复杂度：

- **Logic 层**：请求入口、参数验证、权限验证、业务逻辑、调用Service层
- **Service 层**：业务服务和事务管理
- **Repository 层**：数据访问和缓存支持
- **Model 层**：数据模型和验证
- **中间件**：日志、错误处理、限流等
- **工具类**：错误处理、工具函数等

## 架构优化说明

### 移除Handler层的原因

1. **减少层级复杂度**：从5层架构简化为4层架构
2. **职责更清晰**：Logic层直接处理请求入口和业务逻辑
3. **提高开发效率**：减少不必要的代码跳转
4. **便于维护**：更简洁的代码结构

### 新的架构流程

```
Client Request → Logic → Service → Repository → Model
```

| 层级 | 职责 | 主要功能 |
|------|------|----------|
| Logic | 请求入口和业务逻辑 | 请求入口、参数验证、权限验证、业务逻辑 |
| Service | 业务服务 | 业务规则、事务管理 |
| Repository | 数据访问 | 数据库操作、缓存处理 |
| Model | 数据模型 | 数据结构、验证规则 |

## 主要优化特性

### 1. 增强的错误处理
- 支持多种错误类型（验证、权限、业务等）
- 统一的错误码管理
- gRPC 错误转换支持

### 2. 完善的日志记录
- 结构化日志格式
- 链路追踪支持
- 性能监控

### 3. 缓存支持
- Redis 缓存集成
- 缓存键管理
- 缓存失效策略

### 4. 事务管理
- 数据库事务支持
- 分布式事务准备

### 5. 中间件支持
- 日志中间件
- 错误处理中间件
- 限流中间件
- 熔断器中间件
- 认证中间件
- 指标收集中间件

### 6. 工具函数
- 数据验证工具
- 字符串处理工具
- 时间处理工具
- 加密工具

## 使用方法

### 方案一：使用优化后的模板（推荐）

```bash
# 基本用法
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style=go_zero --home=./templates

# 指定服务名称
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style=go_zero --home=./templates --service_name=User --repo_name=UserRepo --model_name=User
```

### 方案二：使用自定义脚本

```bash
# 使用优化后的生成脚本
./generate_layered_rpc.sh user.proto ./user user UserRepo User
```

## 目录结构

```
user/
├── etc/
│   └── user.yaml              # 配置文件
├── internal/
│   ├── config/
│   │   └── config.go          # 配置结构
│   ├── constants/
│   │   └── constants.go       # 常量定义
│   ├── logic/
│   │   ├── createuserlogic.go
│   │   └── createuserlogic_test.go
│   ├── middleware/
│   │   └── middleware.go      # 中间件
│   ├── model/
│   │   ├── user.go
│   │   └── user_test.go
│   ├── repository/
│   │   ├── userrepository.go
│   │   └── userrepository_test.go
│   ├── service/
│   │   ├── userservice.go
│   │   └── userservice_test.go
│   ├── svc/
│   │   └── servicecontext.go  # 服务上下文
│   └── util/
│       ├── errcode.go         # 错误处理
│       └── utils.go           # 工具函数
├── types/
│   ├── user.pb.go
│   └── user_grpc.pb.go
├── user.go                    # 主程序
└── user_test.go
```

## 核心功能说明

### 1. Logic 层（增强版本）

```go
// 主要功能：
// - 请求入口和性能监控
// - 参数验证（技术层面和业务层面）
// - 权限验证
// - 业务逻辑处理
// - 调用Service层
// - 构建响应

func (l *CreateUserLogic) CreateUser(req *types.CreateUserRequest) (*types.CreateUserResponse, error) {
    start := time.Now()
    traceID := trace.TraceIDFromContext(l.ctx)
    
    l.Infof("[CreateUser] 开始处理请求, traceID: %s, request: %+v", traceID, req)
    
    // 1. 参数验证（技术层面）
    if err := l.validateRequest(req); err != nil {
        l.Errorf("[CreateUser] 参数验证失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewValidationError(err.Error())
    }
    
    // 2. 权限验证
    if err := l.validatePermission(req); err != nil {
        l.Errorf("[CreateUser] 权限验证失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewPermissionError(err.Error())
    }
    
    // 3. 业务参数验证（业务层面）
    if err := l.validateBusinessRequest(req); err != nil {
        l.Errorf("[CreateUser] 业务参数验证失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewValidationError(err.Error())
    }
    
    // 4. 调用 Service 层处理业务逻辑
    result, err := l.svcCtx.UserService.CreateUser(l.ctx, req)
    if err != nil {
        l.Errorf("[CreateUser] 业务逻辑处理失败, traceID: %s, error: %v", traceID, err)
        return nil, err
    }
    
    // 5. 构建响应
    response, err := l.buildResponse(result)
    if err != nil {
        l.Errorf("[CreateUser] 构建响应失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewInternalError("构建响应失败")
    }
    
    duration := time.Since(start)
    l.Infof("[CreateUser] 请求处理完成, traceID: %s, duration: %v", traceID, duration)
    
    return response, nil
}
```

### 2. Service 层

```go
// 主要功能：
// - 业务规则验证
// - 事务管理
// - 调用 Repository 层
// - 业务逻辑处理

func (s *UserService) CreateUser(ctx context.Context, req *types.CreateUserRequest) (*types.CreateUserResponse, error) {
    start := time.Now()
    traceID := trace.TraceIDFromContext(ctx)
    
    s.Infof("[UserService.CreateUser] 开始处理业务逻辑, traceID: %s, request: %+v", traceID, req)
    
    // 1. 业务规则验证
    if err := s.validateBusinessRules(ctx, req); err != nil {
        s.Errorf("[UserService.CreateUser] 业务规则验证失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewValidationError(err.Error())
    }
    
    // 2. 数据转换和准备
    data, err := s.prepareData(ctx, req)
    if err != nil {
        s.Errorf("[UserService.CreateUser] 数据准备失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewInternalError("数据准备失败")
    }
    
    // 3. 执行业务逻辑（支持事务）
    var result interface{}
    err = s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // 在事务中执行数据操作
        result, err = s.userRepo.Create(ctx, data)
        if err != nil {
            return err
        }
        
        // 执行其他业务逻辑
        if err := s.executeBusinessLogic(ctx, req, result); err != nil {
            return err
        }
        
        return nil
    })
    
    if err != nil {
        s.Errorf("[UserService.CreateUser] 业务逻辑执行失败, traceID: %s, error: %v", traceID, err)
        return nil, err
    }
    
    // 4. 构建响应
    response, err := s.buildResponse(ctx, result)
    if err != nil {
        s.Errorf("[UserService.CreateUser] 构建响应失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewInternalError("构建响应失败")
    }
    
    duration := time.Since(start)
    s.Infof("[UserService.CreateUser] 业务逻辑处理完成, traceID: %s, duration: %v", traceID, duration)
    
    return response, nil
}
```

### 3. Repository 层

```go
// 主要功能：
// - 数据验证
// - 缓存处理
// - 数据库操作
// - 数据转换

func (r *UserRepositoryImpl) Create(ctx context.Context, data interface{}) (interface{}, error) {
    start := time.Now()
    traceID := trace.TraceIDFromContext(ctx)
    
    r.Infof("[UserRepository.Create] 开始数据访问, traceID: %s, data: %+v", traceID, data)
    
    // 1. 数据验证
    if err := r.validateData(data); err != nil {
        r.Errorf("[UserRepository.Create] 数据验证失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewValidationError(err.Error())
    }
    
    // 2. 尝试从缓存获取数据
    if cached, err := r.getFromCache(ctx, data); err == nil && cached != nil {
        r.Infof("[UserRepository.Create] 从缓存获取数据成功, traceID: %s", traceID)
        return cached, nil
    }
    
    // 3. 数据转换
    model, err := r.convertToModel(data)
    if err != nil {
        r.Errorf("[UserRepository.Create] 数据转换失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewInternalError("数据转换失败")
    }
    
    // 4. 执行数据库操作
    result, err := r.executeDatabaseOperation(ctx, model)
    if err != nil {
        r.Errorf("[UserRepository.Create] 数据库操作失败, traceID: %s, error: %v", traceID, err)
        return nil, err
    }
    
    // 5. 结果转换
    response, err := r.convertToResponse(result)
    if err != nil {
        r.Errorf("[UserRepository.Create] 结果转换失败, traceID: %s, error: %v", traceID, err)
        return nil, util.NewInternalError("结果转换失败")
    }
    
    // 6. 更新缓存
    if err := r.updateCache(ctx, data, response); err != nil {
        r.Warnf("[UserRepository.Create] 更新缓存失败, traceID: %s, error: %v", traceID, err)
        // 缓存更新失败不影响主流程
    }
    
    duration := time.Since(start)
    r.Infof("[UserRepository.Create] 数据访问完成, traceID: %s, duration: %v", traceID, duration)
    
    return response, nil
}
```

### 4. 错误处理

```go
// 支持多种错误类型
err := util.NewValidationError("参数无效")
err := util.NewPermissionError("权限不足")
err := util.NewNotFoundError("资源不存在")
err := util.NewInternalError("内部错误")

// 错误转换
grpcErr := util.ConvertToGRPCError(err)
customErr := util.ConvertFromGRPCError(grpcErr)
```

### 5. 中间件使用

```go
// 在 main.go 中注册中间件
server := grpc.NewServer(
    grpc.UnaryInterceptor(
        middleware.Chain(
            middleware.LoggingInterceptor(),
            middleware.ErrorInterceptor(),
            middleware.RateLimitInterceptor(100, 200),
            middleware.TimeoutInterceptor(30*time.Second),
            middleware.AuthInterceptor(),
        ),
    ),
)
```

## 配置说明

### 1. 数据库配置

```yaml
DataSource:
  Host: localhost
  Port: 3306
  Username: root
  Password: password
  Database: user
  Charset: utf8mb4
  ParseTime: true
  Loc: Local
  MaxIdleConns: 10
  MaxOpenConns: 100
  ConnMaxLifetime: 3600
```

### 2. Redis 配置

```yaml
Redis:
  Host: localhost
  Port: 6379
  Password: ""
  Database: 0
  PoolSize: 10
  MinIdleConns: 5
  DialTimeout: 5000
  ReadTimeout: 3000
  WriteTimeout: 3000
```

### 3. 中间件配置

```yaml
Middleware:
  RateLimit:
    Enabled: true
    Rate: 100
    Burst: 200
  CircuitBreaker:
    Enabled: true
    Threshold: 5
    Timeout: 60s
```

## 测试

### 1. 单元测试

```bash
# 运行所有测试
go test ./...

# 运行特定测试
go test ./internal/handler
go test ./internal/logic

# 生成测试覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### 2. 性能测试

```bash
# 运行基准测试
go test -bench=. ./internal/handler
go test -bench=. ./internal/logic

# 运行压力测试
go test -bench=BenchmarkCreateUserHandler_CreateUser -benchtime=10s
go test -bench=BenchmarkCreateUserLogic_CreateUser -benchtime=10s
```

## 部署

### 1. 构建

```bash
# 构建可执行文件
go build -o user user.go

# 交叉编译
GOOS=linux GOARCH=amd64 go build -o user user.go
```

### 2. 运行

```bash
# 直接运行
./user -f etc/user.yaml

# 后台运行
nohup ./user -f etc/user.yaml > user.log 2>&1 &
```

## 监控和日志

### 1. 日志配置

```yaml
Log:
  Level: info
  Mode: console
  Path: logs
  Compress: false
  KeepDays: 7
  StackCooldownMillis: 100
  TimeFormat: "2006-01-02 15:04:05"
```

### 2. 监控配置

```yaml
Prometheus:
  Host: 0.0.0.0
  Port: 9090
  Path: /metrics
  EnableMetrics: true
```

## 最佳实践

### 1. 错误处理
- 使用统一的错误类型
- 提供有意义的错误消息
- 记录详细的错误日志

### 2. 性能优化
- 合理使用缓存
- 优化数据库查询
- 使用连接池
- 监控性能指标

### 3. 安全考虑
- 参数验证
- 权限检查
- 数据脱敏
- 防止 SQL 注入

### 4. 可维护性
- 清晰的代码结构
- 完整的测试覆盖
- 详细的文档说明
- 统一的编码规范

## 常见问题

### 1. 如何处理数据库连接失败？
模板中已经包含了数据库连接失败的处理逻辑，会自动重试并记录错误日志。

### 2. 如何添加新的中间件？
在 `internal/middleware/middleware.go` 中添加新的中间件函数，然后在 main.go 中注册。

### 3. 如何自定义错误处理？
在 `internal/util/errcode.go` 中添加新的错误类型和错误码。

### 4. 如何优化缓存策略？
在 Repository 层中根据业务需求调整缓存键和过期时间。

### 5. Handler和Logic层的区别是什么？
- **Handler层**：技术层面，负责请求入口、性能监控、调用Logic层
- **Logic层**：业务层面，负责参数验证、权限验证、业务逻辑处理

## 总结

这个优化后的 RPC 模板提供了：

1. **简化的分层架构**：Handler -> Logic -> Service -> Repository -> Model
2. **强大的错误处理**：支持多种错误类型和统一处理
3. **完善的日志系统**：结构化日志和链路追踪
4. **缓存支持**：Redis 缓存集成
5. **中间件系统**：可扩展的中间件架构
6. **测试支持**：完整的测试模板
7. **监控集成**：Prometheus 指标收集
8. **工具函数**：丰富的工具函数库

使用这个模板可以快速构建高质量、可维护的 RPC 服务，同时保持架构的简洁性和可扩展性。 