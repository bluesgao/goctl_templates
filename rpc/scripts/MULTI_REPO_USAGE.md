# 多 Repository 支持使用指南

## 概述

`add_service.sh` 脚本现在支持为一个 Service 依赖多个 Repository，这使得复杂的业务逻辑可以更好地组织和管理。

## 使用方法

### 基本语法

```bash
./add_service.sh <project_dir> <service_name> <repo_name1> [repo_name2] [repo_name3] ...
```

### 示例

#### 1. 单个 Repository（原有功能）

```bash
./add_service.sh ./user UserService UserRepo
```

#### 2. 多个 Repository

```bash
# 订单服务依赖订单、产品和用户仓库
./add_service.sh ./order OrderService OrderRepo ProductRepo UserRepo

# 支付服务依赖支付、订单和用户仓库
./add_service.sh ./payment PaymentService PaymentRepo OrderRepo UserRepo

# 库存服务依赖产品、仓库和订单仓库
./add_service.sh ./inventory InventoryService ProductRepo WarehouseRepo OrderRepo
```

## 生成的文件结构

### 1. Service 文件 (OrderService.go)

```go
type OrderService struct {
	OrderRepo   repository.OrderRepoRepository
	ProductRepo repository.ProductRepoRepository
	UserRepo    repository.UserRepoRepository
	logx.Logger
}

func NewOrderService(orderRepo repository.OrderRepoRepository, 
                    productRepo repository.ProductRepoRepository, 
                    userRepo repository.UserRepoRepository) *OrderService {
	return &OrderService{
		OrderRepo:   orderRepo,
		ProductRepo: productRepo,
		UserRepo:    userRepo,
		Logger:      logx.WithContext(context.Background()),
	}
}
```

### 2. 测试文件 (OrderService_test.go)

```go
// MockOrderRepoRepository 模拟 Repository
type MockOrderRepoRepository struct {
	mock.Mock
}

// MockProductRepoRepository 模拟 Repository
type MockProductRepoRepository struct {
	mock.Mock
}

// MockUserRepoRepository 模拟 Repository
type MockUserRepoRepository struct {
	mock.Mock
}

func TestNewOrderService(t *testing.T) {
	mockOrderRepo := &MockOrderRepoRepository{}
	mockProductRepo := &MockProductRepoRepository{}
	mockUserRepo := &MockUserRepoRepository{}
	
	service := NewOrderService(mockOrderRepo, mockProductRepo, mockUserRepo)
	
	assert.NotNil(t, service)
	assert.Equal(t, mockOrderRepo, service.OrderRepo)
	assert.Equal(t, mockProductRepo, service.ProductRepo)
	assert.Equal(t, mockUserRepo, service.UserRepo)
}
```

### 3. ServiceContext 文件

```go
type ServiceContext struct {
	Config config.Config
	DB     *gorm.DB
	Redis  redis.Redis
	
	// Repository 层
	OrderRepo   repository.OrderRepoRepository
	ProductRepo repository.ProductRepoRepository
	UserRepo    repository.UserRepoRepository
	
	// Service 层
	OrderService *service.OrderService
}

func NewServiceContext(c config.Config) *ServiceContext {
	db := initDB(c)
	redisClient := initRedis(c)
	
	// 初始化 Repository 层
	orderRepo := repository.NewOrderRepoRepository(db)
	productRepo := repository.NewProductRepoRepository(db)
	userRepo := repository.NewUserRepoRepository(db)
	
	// 初始化 Service 层
	orderService := service.NewOrderService(orderRepo, productRepo, userRepo)
	
	return &ServiceContext{
		Config:        c,
		DB:            db,
		Redis:         redisClient,
		OrderRepo:     orderRepo,
		ProductRepo:   productRepo,
		UserRepo:      userRepo,
		OrderService:  orderService,
	}
}
```

## 最佳实践

### 1. Repository 命名规范

- 使用描述性的名称，如 `UserRepo`、`ProductRepo`、`OrderRepo`
- 避免使用缩写，保持代码可读性
- 确保 Repository 名称与业务领域相关

### 2. Service 职责划分

- 每个 Service 应该专注于特定的业务领域
- 避免在一个 Service 中依赖过多的 Repository（建议不超过 5 个）
- 如果依赖过多，考虑拆分为多个 Service

### 3. 依赖顺序

- 按照业务逻辑的重要性排列 Repository 依赖
- 主要依赖放在前面，辅助依赖放在后面

### 4. 测试策略

- 为每个 Repository 创建独立的 Mock 对象
- 测试不同的 Repository 组合场景
- 确保所有依赖都被正确注入

## 常见场景示例

### 1. 订单处理服务

```bash
./add_service.sh ./order OrderService OrderRepo ProductRepo UserRepo PaymentRepo
```

适用于需要处理订单、检查产品库存、验证用户信息、处理支付的场景。

### 2. 库存管理服务

```bash
./add_service.sh ./inventory InventoryService ProductRepo WarehouseRepo SupplierRepo
```

适用于需要管理产品库存、仓库信息和供应商信息的场景。

### 3. 用户管理服务

```bash
./add_service.sh ./user UserService UserRepo RoleRepo PermissionRepo
```

适用于需要管理用户、角色和权限的场景。

## 注意事项

1. **Repository 必须存在**：确保所有依赖的 Repository 都已经通过 `add_repo.sh` 创建
2. **命名冲突**：避免 Repository 名称与 Service 名称冲突
3. **循环依赖**：避免 Service 之间的循环依赖
4. **性能考虑**：过多的 Repository 依赖可能影响性能，需要合理设计

## 故障排除

### 1. Repository 不存在错误

```
[ERROR] Repository 文件不存在: UserRepo
```

**解决方案**：先使用 `add_repo.sh` 创建所需的 Repository

```bash
./add_repo.sh ./project UserRepo User
./add_service.sh ./project UserService UserRepo
```

### 2. 编译错误

如果生成的代码有编译错误，检查：
- Repository 接口是否正确定义
- 导入路径是否正确
- 类型名称是否匹配

### 3. 测试失败

如果测试失败，检查：
- Mock 对象是否正确创建
- 依赖注入是否正确
- 断言条件是否合理

## 测试多 Repository 功能

运行测试脚本验证功能：

```bash
./test_multi_repo.sh
```

这个脚本会：
1. 创建测试项目
2. 创建多个 Repository
3. 创建依赖多个 Repository 的 Service
4. 验证生成的文件
5. 清理测试环境 