# 交互式 add_repo.sh 使用指南

## 概述

`add_repo.sh` 脚本现在支持交互式参数收集，用户可以通过问答的方式配置 Repository 和 Model 参数，无需记忆命令行参数。

## 使用方法

### 基本使用

直接运行脚本，按照提示输入参数：

```bash
./add_repo.sh
```

### 交互式流程

1. **项目目录**
   ```
   请输入项目目录 (例如: ./user): ./myproject
   ```

2. **仓库名称**
   ```
   请输入仓库名称 (例如: UserRepo): UserRepo
   ```

3. **模型名称**
   ```
   请输入模型名称 (例如: User): User
   ```

4. **确认信息**
   ```
   Repository 配置信息：
   ----------------------------------------
   项目目录: ./myproject
   仓库名称: UserRepo
   模型名称: User
   ----------------------------------------
   确认添加 Repository？(y/n): y
   ```

5. **高级选项配置**
   ```
   高级选项配置：
   是否生成测试文件？(y/n, 默认: y): y
   是否包含数据库操作示例？(y/n, 默认: y): y
   是否包含模型字段示例？(y/n, 默认: y): y
   是否更新 ServiceContext？(y/n, 默认: y): y
   ```

## 高级选项说明

### 1. 测试文件 (CREATE_TESTS)

- **选择 y**: 生成 `UserRepo_test.go` 和 `User_test.go` 测试文件
- **选择 n**: 只生成 Repository 和 Model 文件，不生成测试文件

### 2. 数据库操作示例 (INCLUDE_DB_EXAMPLES)

- **选择 y**: 在 Repository 中包含数据库操作示例代码
- **选择 n**: 只生成基础框架，不包含示例代码

### 3. 模型字段示例 (INCLUDE_MODEL_EXAMPLES)

- **选择 y**: 在 Model 中包含字段示例
- **选择 n**: 只生成基础 Model 结构，不包含字段示例

### 4. ServiceContext 更新 (UPDATE_SERVICE_CONTEXT)

- **选择 y**: 自动更新 ServiceContext 文件，添加新的 Repository
- **选择 n**: 不更新 ServiceContext 文件

## 输入验证

### 仓库名称验证

- 必须以大写字母开头
- 只能包含字母和数字
- 不能为空

示例：
```
✅ 有效: UserRepo, ProductRepo, OrderRepo
❌ 无效: userRepo, 123Repo, User-Repo
```

### 模型名称验证

- 必须以大写字母开头
- 只能包含字母和数字
- 不能为空

示例：
```
✅ 有效: User, Product, Order
❌ 无效: user, 123User, User-Model
```

### 项目目录验证

- 不能为空
- 如果目录不存在，会提示用户是否继续

## 生成的文件结构

根据用户选择，会生成以下文件：

```
myproject/
├── internal/
│   ├── repository/
│   │   ├── UserRepo.go          # Repository 接口和实现
│   │   └── UserRepo_test.go     # Repository 测试文件 (可选)
│   ├── model/
│   │   ├── User.go              # Model 定义
│   │   └── User_test.go         # Model 测试文件 (可选)
│   └── svc/
│       └── servicecontext.go    # ServiceContext (可选更新)
```

## 示例会话

```
$ ./add_repo.sh

[INFO] 欢迎使用 Repository 添加脚本！

请输入项目目录 (例如: ./user): ./order-service
请输入仓库名称 (例如: UserRepo): OrderRepo
请输入模型名称 (例如: User): Order

[INFO] Repository 配置信息：
----------------------------------------
项目目录: ./order-service
仓库名称: OrderRepo
模型名称: Order
----------------------------------------
确认添加 Repository？(y/n): y

[INFO] 高级选项配置：
是否生成测试文件？(y/n, 默认: y): y
是否包含数据库操作示例？(y/n, 默认: y): y
是否包含模型字段示例？(y/n, 默认: y): y
是否更新 ServiceContext？(y/n, 默认: y): y

[INFO] 开始添加新的 Repository...
[INFO] 项目目录: ./order-service
[INFO] 仓库名称: OrderRepo
[INFO] 模型名称: Order
[INFO] 步骤 1: 生成 Repository 层...
[INFO] 步骤 2: 生成 Repository 测试文件...
[INFO] 步骤 3: 生成 Model 层...
[INFO] 步骤 4: 生成 Model 测试文件...
[INFO] 步骤 5: 更新 ServiceContext...

[INFO] Repository 添加完成！
[INFO] 生成的文件：
[INFO] 1. ./order-service/internal/repository/OrderRepo.go
[INFO] 2. ./order-service/internal/model/Order.go
[INFO] 3. ./order-service/internal/repository/OrderRepo_test.go
[INFO] 4. ./order-service/internal/model/Order_test.go
[INFO] 5. ./order-service/internal/svc/servicecontext.go (已更新)
[INFO] 已生成测试文件
[INFO] 已包含数据库操作示例
[INFO] 已包含模型字段示例
[WARN] 请根据实际业务需求完善以下内容：
[WARN] 1. 在 OrderRepo.go 中实现具体的数据库操作方法
[WARN] 2. 在 Order.go 中添加具体的字段定义
[WARN] 3. 在 OrderRepo_test.go 和 Order_test.go 中添加测试用例
[WARN] 4. 在 servicecontext.go 中配置数据库连接
[WARN] 5. 使用 add_service.sh 添加对应的 Service
```

## 错误处理示例

### 1. 无效的仓库名称

```
请输入仓库名称 (例如: UserRepo): 123Repo
[ERROR] 仓库名称必须以大写字母开头，只能包含字母和数字
请输入仓库名称 (例如: UserRepo): UserRepo
```

### 2. 无效的模型名称

```
请输入模型名称 (例如: User): 123User
[ERROR] 模型名称必须以大写字母开头，只能包含字母和数字
请输入模型名称 (例如: User): User
```

### 3. 项目目录不存在

```
请输入项目目录 (例如: ./user): ./nonexistent
[ERROR] 项目目录不存在: ./nonexistent
是否继续？(y/n): n
[INFO] 已取消 Repository 添加
```

## 自动化测试

### 使用预设输入

创建输入文件：

```bash
cat > test_input.txt << EOF
./myproject
UserRepo
User
y
y
y
y
y
y
y
y
EOF

./add_repo.sh < test_input.txt
```

### 运行测试脚本

```bash
./test_add_repo_interactive.sh
```

## 最佳实践

### 1. 命名规范

- **Repository 名称**: 使用 `EntityRepo` 格式，如 `UserRepo`、`ProductRepo`
- **Model 名称**: 使用单数形式，如 `User`、`Product`
- **项目目录**: 使用描述性名称，如 `user-service`、`order-service`

### 2. 文件组织

- 每个 Repository 对应一个 Model
- Repository 和 Model 使用相同的命名前缀
- 测试文件与源文件放在同一目录

### 3. 测试策略

- 为每个 Repository 创建完整的测试用例
- 测试数据库操作的各个场景
- 验证 Model 的生命周期钩子

## 注意事项

1. **输入验证**: 脚本会验证所有输入，确保格式正确
2. **默认值**: 大部分选项都有合理的默认值，可以直接按回车使用
3. **取消操作**: 在确认阶段选择 'n' 可以取消 Repository 添加
4. **错误处理**: 输入错误时会提示重新输入
5. **文件覆盖**: 如果文件已存在，会覆盖同名文件

## 故障排除

### 1. 输入错误

如果输入了无效的名称，脚本会提示重新输入：

```
请输入仓库名称 (例如: UserRepo): 123Repo
[ERROR] 仓库名称必须以大写字母开头，只能包含字母和数字
请输入仓库名称 (例如: UserRepo): UserRepo
```

### 2. 项目目录不存在

如果项目目录不存在，脚本会提示是否继续：

```
请输入项目目录 (例如: ./user): ./nonexistent
[ERROR] 项目目录不存在: ./nonexistent
是否继续？(y/n): y
```

### 3. 权限问题

确保脚本有执行权限：

```bash
chmod +x add_repo.sh
```

### 4. 依赖问题

确保项目已经通过 `init_project.sh` 初始化：

```bash
./init_project.sh
``` 