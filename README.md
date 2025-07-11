# goctl 自定义模板 - 分层架构

本目录包含 goctl 的自定义模板文件，采用分层架构设计：**Logic -> Service -> Repository -> Model**

## 分层架构设计

```
┌─────────────────┐
│     Handler     │  ← 请求处理层（参数验证、响应格式化）
├─────────────────┤
│     Logic       │  ← 业务编排层（调用 Service、错误处理）
├─────────────────┤
│    Service      │  ← 业务逻辑层（业务规则、数据转换）
├─────────────────┤
│  Repository     │  ← 数据访问层（数据库操作、缓存）
├─────────────────┤
│     Model       │  ← 数据模型层（数据结构、ORM 映射）
└─────────────────┘
```

## 目录结构

```
templates/
├── api/                    # API 服务模板
│   ├── handler.tpl        # 处理器模板
│   ├── logic.tpl          # 业务编排层模板
│   ├── service.tpl        # 业务逻辑层模板
│   ├── repository.tpl     # 数据访问层模板
│   ├── svc.tpl            # 服务上下文模板
│   ├── types.tpl          # 类型定义模板
│   └── model.tpl          # 数据模型模板
├── rpc/                    # RPC 服务模板
│   ├── internal/
│   │   ├── handler/
│   │   │   └── handler.tpl
│   │   ├── logic/
│   │   │   └── logic.tpl
│   │   ├── service/
│   │   │   └── service.go.tpl
│   │   ├── repository/
│   │   │   └── repository.go.tpl
│   │   ├── model/
│   │   │   └── model.go.tpl
│   │   ├── svc/
│   │   │   └── servicecontext.tpl
│   │   └── types/
│   │       └── types.tpl
│   ├── etc.tpl            # 配置文件模板
│   ├── goctl.yaml         # goctl 配置文件
│   ├── generate_layered_rpc.sh  # 分层架构生成脚本
│   ├── test_example.sh    # 测试示例脚本
│   └── USAGE.md           # 使用说明文档
├── model/                  # 数据模型模板
│   └── model.tpl          # 模型模板
├── util/                   # 工具类模板
│   └── errcode.tpl        # 错误码模板
└── example/                # 使用示例
    ├── README.md          # 完整使用指南
    └── layered_architecture.md  # 分层架构详细示例
```

## 分层职责

### 1. Handler 层（请求处理层）

- **职责**: 参数验证、请求解析、响应格式化
- **特点**: 轻量级，只负责 HTTP/gRPC 层面的处理
- **依赖**: Logic 层

### 2. Logic 层（业务编排层）

- **职责**: 业务流程编排、错误处理、日志记录
- **特点**: 协调各个 Service 的调用
- **依赖**: Service 层

### 3. Service 层（业务逻辑层）

- **职责**: 业务规则验证、数据转换、业务逻辑处理
- **特点**: 包含核心业务逻辑，不直接操作数据库
- **依赖**: Repository 层

### 4. Repository 层（数据访问层）

- **职责**: 数据库操作、缓存处理、数据转换
- **特点**: 封装所有数据访问逻辑，提供统一接口
- **依赖**: Model 层

### 5. Model 层（数据模型层）

- **职责**: 数据结构定义、ORM 映射、数据验证
- **特点**: 纯数据结构，不包含业务逻辑
- **依赖**: 无

## 使用方法

### 1. 使用自定义脚本生成 RPC 服务（推荐）

由于标准的 goctl 模板只会生成 handler 和 logic 文件，我们提供了自定义脚本 `generate_layered_rpc.sh` 来生成完整的分层架构。

```bash
# 基本用法
./templates/rpc/generate_layered_rpc.sh <proto_file> <output_dir>

# 完整用法
./templates/rpc/generate_layered_rpc.sh <proto_file> <output_dir> <service_name> <repo_name> <model_name>

# 示例
./templates/rpc/generate_layered_rpc.sh user.proto ./user user UserRepo User
```

#### 脚本功能

1. **生成基础 RPC 结构** - 使用 goctl 生成标准的 handler 和 logic
2. **创建分层目录** - 自动创建 service、repository、model 目录
3. **生成 Service 层** - 创建业务逻辑层代码
4. **生成 Repository 层** - 创建数据访问层代码
5. **生成 Model 层** - 创建数据模型层代码
6. **生成工具类** - 创建错误处理等工具类
7. **更新 ServiceContext** - 配置依赖注入
8. **生成文档** - 创建 README 说明文档

### 2. 测试脚本功能

```bash
# 运行测试示例
./templates/rpc/test_example.sh
```

### 3. 使用自定义模板生成 API 服务

```bash
# 创建新的 API 服务
goctl api new apigateway --home ./templates

# 生成 API 代码
goctl api go -api apigateway.api -dir . --style goZero --home ./templates
```

### 4. 使用自定义模板生成数据模型

```bash
# 生成单个表的模型
goctl model mysql datasource -t user -c -d --home ./templates

# 生成多个表的模型
goctl model mysql datasource -t "user,merchant,order" -c -d --home ./templates
```

## 模板变量说明

### 通用变量

- `{{.package}}` - 包名
- `{{.imports}}` - 导入语句
- `{{.comment}}` - 注释

### RPC 服务变量

- `{{.pbImport}}` - protobuf 导入路径
- `{{.pbPackage}}` - protobuf 包名
- `{{.method}}` - 方法名
- `{{.request}}` - 请求类型
- `{{.response}}` - 响应类型
- `{{.serviceName}}` - 服务名
- `{{.repoName}}` - 仓库名

### API 服务变量

- `{{.method}}` - 方法名
- `{{.request}}` - 请求类型
- `{{.response}}` - 响应类型
- `{{.serviceName}}` - 服务名
- `{{.repoName}}` - 仓库名

### 数据模型变量

- `{{.model}}` - 模型名
- `{{.table}}` - 表名
- `{{.comment}}` - 注释
- `{{.fields}}` - 字段列表

## 分层架构优势

### 1. 职责分离

- 每一层都有明确的职责
- 降低代码耦合度
- 提高代码可维护性

### 2. 可测试性

- 每一层都可以独立测试
- 便于单元测试和集成测试
- 提高代码质量

### 3. 可扩展性

- 易于添加新功能
- 便于重构和优化
- 支持团队协作开发

### 4. 代码复用

- Service 层可以被多个 Logic 调用
- Repository 层可以被多个 Service 调用
- 减少重复代码

## 自定义规范

1. **错误处理**: 统一使用 `util.NewError()` 返回错误
2. **日志记录**: 使用 `logx.WithContext(ctx)` 记录日志
3. **参数验证**: 在 Handler 层进行参数验证
4. **业务逻辑**: 在 Service 层实现具体业务逻辑
5. **数据访问**: 在 Repository 层进行数据库操作
6. **数据模型**: 在 Model 层定义数据结构

## 最佳实践

### 1. 依赖注入

```go
// 在 ServiceContext 中注入依赖
type ServiceContext struct {
    Config config.Config
    DB     *gorm.DB
    Redis  redis.Redis
  
    // Repository 层
    UserRepo repository.UserRepository
  
    // Service 层
    UserService *service.UserService
}
```

### 2. 接口定义

```go
// 定义 Repository 接口
type UserRepository interface {
    Create(ctx context.Context, user *model.User) error
    Get(ctx context.Context, id string) (*model.User, error)
    Update(ctx context.Context, user *model.User) error
    Delete(ctx context.Context, id string) error
}
```

### 3. 错误处理

```go
// 统一错误处理
if err != nil {
    return nil, util.NewErrorWithCode(util.ErrCodeUserNotFound)
}
```

### 4. 日志记录

```go
// 结构化日志
l.Infof("处理用户请求: userId=%s, action=%s", userId, action)
```

## 使用 GitHub 模板

### 基本用法

```bash
# 使用 GitHub URL 生成 API 服务
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo

# 使用 GitHub URL 生成 RPC 服务
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home https://github.com/username/repo

# 使用 GitHub URL 生成数据模型
goctl model mysql datasource -t user -c -d --home https://github.com/username/repo
```

### 支持的 URL 格式

- **GitHub 仓库**: `https://github.com/username/repo`
- **特定分支**: `https://github.com/username/repo/tree/feature-branch`
- **特定标签**: `https://github.com/username/repo/tree/v1.0.0`
- **Raw 内容**: `https://raw.githubusercontent.com/username/repo/main`

### 高级用法

```bash
# 克隆到本地使用
git clone https://github.com/username/repo ./templates
goctl api go -api user.api -dir . --style goZero --home ./templates

# 使用环境变量
export GOTEMPLATE_HOME="https://github.com/username/repo"
goctl api go -api user.api -dir . --style goZero --home $GOTEMPLATE_HOME
```

### 验证模板

```bash
# 检查模板可用性
curl -s --head https://github.com/username/repo | head -n 1

# 使用验证脚本
./scripts/use_github_template.sh
```

详细说明请参考：[简化使用指南](SIMPLE_USAGE.md)、[详细使用指南](GITHUB_TEMPLATE_USAGE.md) 和 [快速参考](QUICK_REFERENCE.md)

## 注意事项

1. **模板路径**: 确保使用正确的 `--home` 参数指向模板目录
2. **包名一致性**: 确保生成的代码包名与项目结构一致
3. **依赖管理**: 确保所有必要的依赖都已正确导入
4. **配置更新**: 根据实际需求调整配置文件模板
5. **代码审查**: 生成代码后需要进行代码审查和测试
6. **分层调用**: 严格遵循分层调用规则，避免跨层调用
7. **RPC 服务**: 使用 `generate_layered_rpc.sh` 脚本生成完整的分层架构
8. **GitHub 模板**: 确保 GitHub 仓库包含正确的模板目录结构

## 问题解决

### Q: 为什么标准的 goctl 模板不会生成 Service、Repository、Model 层？

A: 标准的 goctl 模板只专注于生成基础的 handler 和 logic 文件。为了解决这个问题，我们提供了自定义的 `generate_layered_rpc.sh` 脚本，可以生成完整的分层架构。

### Q: 如何使用自定义脚本？

A: 参考 `templates/rpc/USAGE.md` 文档，或者运行测试示例：

```bash
./templates/rpc/test_example.sh
```

### Q: 生成的代码需要手动调整吗？

A: 脚本生成的代码提供了基础框架，您需要根据实际业务需求完善具体的业务逻辑实现。




生成proto

1, 安装 google protobuf

install_google_protobuf.sh

2，生成服务proto

init_proto.sh

3，执行goctl生成代码

goctl rpc protoc user.proto
  --proto_path=.
  --proto_path=/Users/gocode/.local/include   -- google protobuf 安装路径
  --go_out=.
  --go-grpc_out=.
  --zrpc_out=.
  --style go_zero
