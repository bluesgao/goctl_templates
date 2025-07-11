# RPC 模板脚本使用指南

本目录包含了用于生成分层架构 RPC 服务的三个独立脚本，每个脚本都有特定的功能。

## 脚本概览

### 1. `init_project.sh` - 初始化项目
用于创建新的 RPC 项目，生成基础的项目结构和工具类。

### 2. `add_service.sh` - 新增 Service
用于在现有项目中添加新的 Service 层。

### 3. `add_repo.sh` - 新增 Repository
用于在现有项目中添加新的 Repository 层和 Model 层。

## 使用方法

### 1. 初始化项目

```bash
# 基本用法
./scripts/init_project.sh <output_dir> <service_name> [proto_file]

# 示例
./scripts/init_project.sh ./user user
./scripts/init_project.sh ./user user user.proto
```

**功能说明：**
- 自动生成包含通用message的proto文件（Result、分页、排序等）
- 生成基础的 RPC 服务结构
- 创建分层目录结构（logic, service, repository, model, util 等）
- 生成工具类（错误处理、工具函数）
- 生成 README 文档

**生成的文件：**
```
user/
├── internal/
│   ├── logic/            # Logic 层（由 goctl 自动生成）
│   ├── service/          # Service 层
│   ├── repository/       # Repository 层
│   ├── model/           # Model 层
│   ├── svc/             # 依赖注入
│   ├── types/           # 类型定义
│   ├── util/            # 工具类
│   ├── middleware/      # 中间件
│   ├── constants/       # 常量定义
│   └── config/          # 配置结构
├── etc/
│   └── user.yaml
├── docs/                # 文档
├── scripts/             # 脚本
└── user.go
```

### 2. 新增 Service

```bash
# 基本用法
./scripts/add_service.sh <project_dir> <service_name> <repo_name>

# 示例
./scripts/add_service.sh ./user UserService UserRepo
```

**功能说明：**
- 生成新的 Service 层文件
- 生成对应的测试文件
- 更新 ServiceContext 配置

**生成的文件：**
- `internal/service/UserService.go`
- `internal/service/UserService_test.go`
- `internal/svc/servicecontext.go` (更新)

### 3. 新增 Repository

```bash
# 基本用法
./scripts/add_repo.sh <project_dir> <repo_name> <model_name>

# 示例
./scripts/add_repo.sh ./user UserRepo User
```

**功能说明：**
- 生成新的 Repository 层文件
- 生成对应的 Model 层文件
- 生成测试文件
- 更新 ServiceContext 配置

**生成的文件：**
- `internal/repository/UserRepo.go`
- `internal/repository/UserRepo_test.go`
- `internal/model/User.go`
- `internal/model/User_test.go`
- `internal/svc/servicecontext.go` (更新)

## 完整工作流程

### 1. 创建新项目

```bash
# 1. 初始化项目
./scripts/init_project.sh ./user user

# 2. 添加 Repository
./scripts/add_repo.sh ./user UserRepo User

# 3. 添加 Service
./scripts/add_service.sh ./user UserService UserRepo
```

### 2. 在现有项目中添加功能

```bash
# 假设已有项目 ./user

# 添加新的 Repository
./scripts/add_repo.sh ./user OrderRepo Order

# 添加对应的 Service
./scripts/add_service.sh ./user OrderService OrderRepo
```

## 脚本特点

### 1. 错误处理
- 参数验证
- 目录存在性检查
- 文件备份机制

### 2. 颜色输出
- 绿色：信息消息
- 黄色：警告消息
- 红色：错误消息

### 3. 模板化生成
- 统一的代码风格
- 完整的测试文件
- 详细的 TODO 注释

### 4. 依赖管理
- 自动更新 ServiceContext
- 正确的导入路径
- 依赖注入配置

## 注意事项

### 1. 执行顺序
建议按照以下顺序使用脚本：
1. `scripts/init_project.sh` - 初始化项目
2. `scripts/add_repo.sh` - 添加 Repository
3. `scripts/add_service.sh` - 添加 Service

### 2. 命名规范
- Service 名称：建议使用 `XxxService` 格式
- Repository 名称：建议使用 `XxxRepo` 格式
- Model 名称：建议使用 `Xxx` 格式

### 3. 文件备份
脚本会自动备份修改的文件（如 ServiceContext），备份文件以 `.bak` 结尾。

### 4. 自定义开发
生成的代码包含详细的 TODO 注释，开发者需要根据实际业务需求：
- 实现具体的业务逻辑
- 添加字段定义
- 完善测试用例
- 配置数据库连接

## 示例项目结构

```
user/
├── internal/
│   ├── logic/
│   │   ├── createuserlogic.go
│   │   └── createuserlogic_test.go
│   ├── service/
│   │   ├── UserService.go
│   │   └── UserService_test.go
│   ├── repository/
│   │   ├── UserRepo.go
│   │   └── UserRepo_test.go
│   ├── model/
│   │   ├── User.go
│   │   └── User_test.go
│   ├── svc/
│   │   └── servicecontext.go
│   ├── types/
│   │   ├── user.pb.go
│   │   └── user_grpc.pb.go
│   └── util/
│       ├── errcode.go
│       └── utils.go
├── etc/
│   └── user.yaml
└── user.go
```

## 故障排除

### 1. 权限问题
```bash
chmod +x scripts/init_project.sh scripts/add_service.sh scripts/add_repo.sh
```

### 2. 目录不存在
确保在正确的目录下运行脚本，或者检查项目路径是否正确。

### 3. 文件冲突
如果文件已存在，脚本会覆盖文件。建议在运行前备份重要文件。

### 4. 依赖问题
确保已安装 goctl 和相关依赖：
```bash
go install github.com/zeromicro/go-zero/tools/goctl@latest
``` 