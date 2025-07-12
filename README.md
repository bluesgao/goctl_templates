# 🚀 goctl RPC 服务 - 分层架构

> 基于 go-zero 框架的 RPC 服务分层架构模板，采用 **Logic → Service → Repository → Model** 设计模式

## 🏗️ 分层架构设计

```
┌─────────────────┐
│     Logic       │  ← 业务编排层（gRPC 请求处理、错误处理、日志记录）
├─────────────────┤
│    Service      │  ← 业务逻辑层（业务规则验证、数据转换、核心业务逻辑）
├─────────────────┤
│  Repository     │  ← 数据访问层（数据库操作、缓存处理、数据转换）
├─────────────────┤
│     Model       │  ← 数据模型层（数据结构定义、ORM 映射、数据验证）
└─────────────────┘
```

## 🎯 分层职责

### 1. 🧠 Logic 层（业务编排层）

- **职责**: gRPC 请求处理、业务流程编排、错误处理、日志记录
- **特点**: 协调各个 Service 的调用，处理请求参数验证和响应格式化
- **依赖**: Service 层

### 2. ⚙️ Service 层（业务逻辑层）

- **职责**: 业务规则验证、数据转换、核心业务逻辑处理
- **特点**: 包含核心业务逻辑，不直接操作数据库，可被多个 Logic 调用
- **依赖**: Repository 层

### 3. 🗄️ Repository 层（数据访问层）

- **职责**: 数据库操作、缓存处理、数据转换、数据访问封装
- **特点**: 封装所有数据访问逻辑，提供统一接口，可被多个 Service 调用
- **依赖**: Model 层

### 4. 📊 Model 层（数据模型层）

- **职责**: 数据结构定义、ORM 映射、数据验证、表结构定义
- **特点**: 纯数据结构，不包含业务逻辑，支持 GORM 标签
- **依赖**: 无

## 📖 使用方法

#### 步骤 1: 生成默认 proto 文件

```bash
./scripts/init_proto.sh
# 输入服务名称: UserService
# 输入 proto 文件名: user.proto
# 输入包名: user
```

#### 步骤 2: 生成默认项目骨架

```bash
./scripts/init_rpc_project.sh
# 输入项目名称: user-service
# 输入服务名称: UserService
# 输入仓库名称: UserRepo
# 输入模型名称: User
```

#### 步骤 3: 生成 Repository 和 Model

```bash
./scripts/init_repo.sh
# 输入项目目录: ./user-service
# 输入仓库名称: UserRepo
# 输入模型名称: User
```

#### 步骤 4: 生成业务 Service

```bash
./scripts/init_service.sh
# 输入项目目录: ./user-service
# 输入服务名称: UserService
# 输入 Repository 依赖: UserRepo
```

### 📊 生成数据模型

```bash
# 生成单个表的模型
goctl model mysql datasource -t user -c -d --home ./templates

# 生成多个表的模型
goctl model mysql datasource -t "user,merchant,order" -c -d --home ./templates
```

## 🔧 脚本工具

### 📝 init_proto.sh - Proto 文件初始化脚本

**功能**: 创建和配置 protobuf 文件

```bash
./scripts/init_proto.sh
```

**特性**:

- 📄 生成标准的 proto 文件
- 🏷️ 自动配置服务和方法
- 📊 生成请求和响应消息
- 🔧 配置 gRPC 服务定义

### 🚀 init_rpc_project.sh - RPC 项目初始化脚本

**功能**: 创建完整的 RPC 项目结构和基础代码

```bash
./scripts/init_rpc_project.sh
```

**生成内容**:

- 📁 完整的项目目录结构
- 📄 配置文件 (etc/user-service.yaml)
- 🔧 依赖注入配置 (internal/svc/servicecontext.go)
- 📝 基础文档和 README
- 🏗️ 分层架构代码模板

**特性**:

- 🎯 交互式项目配置
- 📊 自动生成 Model 层
- 🗄️ 自动生成 Repository 层
- ⚙️ 自动生成 Service 层
- 🔗 自动配置依赖注入

### 📊 init_repo.sh - Repository 层初始化脚本

**功能**: 在现有项目中添加 Repository 层和 Model 层

```bash
./scripts/init_repo.sh
```

**特性**:

- 🎯 交互式配置仓库和模型名称
- 📊 自动生成 Model 结构体
- 🗄️ 生成数据访问层模板
- 🔗 自动配置依赖注入
- 📝 包含完整的 CRUD 操作模板

### 🔧 init_service.sh - Service 层初始化脚本

**功能**: 在现有项目中添加 Service 层

```bash
./scripts/init_service.sh
```

**特性**:

- 🎯 交互式配置服务名称
- 🔗 自动配置 Repository 依赖
- 📝 生成业务逻辑模板
- ⚙️ 高级选项配置
- 🔄 自动更新 ServiceContext

### 📦 install_google_protobuf.sh - 安装脚本

**功能**: 安装 Google protobuf 编译器

```bash
./scripts/install_google_protobuf.sh
```

**特性**:

- 🐧 支持 Linux/macOS 系统
- 📦 自动下载和安装 protobuf
- �� 配置环境变量
- ✅ 验证安装结果
