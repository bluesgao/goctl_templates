# 交互式 init_project.sh 使用指南

## 概述

`init_project.sh` 脚本现在支持交互式参数收集，用户可以通过问答的方式配置项目参数，无需记忆命令行参数。

## 使用方法

### 基本使用

直接运行脚本，按照提示输入参数：

```bash
./init_project.sh
```

### 交互式流程

1. **项目输出目录**
   ```
   请输入项目输出目录 (例如: ./user): ./myproject
   ```

2. **服务名称**
   ```
   请输入服务名称 (例如: user): userservice
   ```

3. **Proto 文件名**
   ```
   请输入 proto 文件名 (默认: userservice.proto): 
   ```

4. **确认信息**
   ```
   项目配置信息：
   ----------------------------------------
   输出目录: ./myproject
   服务名称: userservice
   Proto 文件: userservice.proto
   ----------------------------------------
   确认创建项目？(y/n): y
   ```

5. **高级选项配置**
   ```
   高级选项配置：
   是否创建示例代码？(y/n, 默认: y): y
   是否包含数据库配置？(y/n, 默认: y): y
   是否包含 Redis 配置？(y/n, 默认: y): y
   是否包含事件处理功能？(y/n, 默认: y): y
   ```

## 高级选项说明

### 1. 示例代码 (CREATE_EXAMPLES)

- **选择 y**: 生成 `errcode.go`、`utils.go` 和 `README.md` 示例文件
- **选择 n**: 只创建目录结构，不生成示例代码

### 2. 数据库配置 (INCLUDE_DB)

- **选择 y**: 在 ServiceContext 中包含数据库连接配置
- **选择 n**: 不包含数据库相关配置

### 3. Redis 配置 (INCLUDE_REDIS)

- **选择 y**: 在 ServiceContext 中包含 Redis 连接配置
- **选择 n**: 不包含 Redis 相关配置

### 4. 事件处理 (INCLUDE_EVENT)

- **选择 y**: 创建 `internal/event` 目录和相关模板文件
- **选择 n**: 不创建事件处理相关目录和文件

## 输入验证

### 服务名称验证

- 只能包含字母和数字
- 必须以字母开头
- 不能为空

示例：
```
✅ 有效: user, UserService, user123
❌ 无效: 123user, user-service, user@service
```

### 目录路径验证

- 不能为空
- 支持相对路径和绝对路径

示例：
```
✅ 有效: ./user, /home/user/project, ../myproject
❌ 无效: (空值)
```

## 自动化测试

### 使用预设输入

创建输入文件：

```bash
cat > test_input.txt << EOF
./test_project
user
user.proto
y
y
y
y
y
EOF

./init_project.sh < test_input.txt
```

### 运行测试脚本

```bash
./test_interactive.sh
```

## 生成的项目结构

根据用户选择，会生成以下结构：

```
myproject/
├── internal/
│   ├── logic/            # Logic 层
│   ├── service/          # Service 层
│   ├── repository/       # Repository 层
│   ├── model/           # Model 层
│   ├── event/           # Event 层 (可选)
│   ├── util/            # 工具类
│   ├── middleware/      # 中间件
│   ├── constants/       # 常量定义
│   ├── config/          # 配置结构
│   └── svc/             # 依赖注入
├── proto/               # Proto 文件目录
│   └── user.proto
├── etc/                 # 配置文件
├── docs/                # 文档
├── scripts/             # 脚本
└── user.go              # 主程序
```

## 示例会话

```
$ ./init_project.sh

[INFO] 欢迎使用 RPC 项目初始化脚本！

请输入项目输出目录 (例如: ./user): ./order-service
请输入服务名称 (例如: user): order
请输入 proto 文件名 (默认: order.proto): 

[INFO] 项目配置信息：
----------------------------------------
输出目录: ./order-service
服务名称: order
Proto 文件: order.proto
----------------------------------------
确认创建项目？(y/n): y

[INFO] 高级选项配置：
是否创建示例代码？(y/n, 默认: y): y
是否包含数据库配置？(y/n, 默认: y): y
是否包含 Redis 配置？(y/n, 默认: y): y
是否包含事件处理功能？(y/n, 默认: y): y

[INFO] 开始初始化 RPC 项目...
[INFO] 步骤 1: 生成默认的 proto 文件...
[INFO] Proto 文件已生成: ./order-service/proto/order.proto
[INFO] 步骤 2: 生成基础 RPC 服务结构...
[INFO] 步骤 3: 创建分层目录结构...
[INFO] 已创建 Event 目录
[INFO] 步骤 4: 生成 Util 工具类...
[INFO] 步骤 5: 生成基础工具函数...
[INFO] 步骤 6: 生成 README 文档...

[INFO] RPC 项目初始化完成！
[INFO] 输出目录: ./order-service
[INFO] Proto 文件: ./order-service/proto/order.proto
[INFO] 已生成示例代码文件
[INFO] 已包含事件处理功能
[INFO] 已包含数据库配置
[INFO] 已包含 Redis 配置
[WARN] 接下来可以使用以下脚本添加功能：
[WARN] 1. ./scripts/add_service.sh <service_name> <repo_name> - 添加新的 Service
[WARN] 2. ./scripts/add_repo.sh <repo_name> <model_name> - 添加新的 Repository
[WARN] 3. Event 层已创建，支持消息队列处理，包含以下文件：
[WARN]    - internal/event/event.go.tpl - 事件基础结构
[WARN]    - internal/event/mq_connector.go.tpl - MQ连接器
[WARN]    - internal/event/handler.go.tpl - 事件处理器示例
```

## 注意事项

1. **输入验证**: 脚本会验证所有输入，确保格式正确
2. **默认值**: 大部分选项都有合理的默认值，可以直接按回车使用
3. **取消操作**: 在确认阶段选择 'n' 可以取消项目创建
4. **错误处理**: 输入错误时会提示重新输入
5. **文件保存**: Proto 文件会保存在项目的 `proto/` 目录中

## 故障排除

### 1. 输入错误

如果输入了无效的服务名称，脚本会提示重新输入：

```
请输入服务名称 (例如: user): 123user
[ERROR] 服务名称只能包含字母和数字，且必须以字母开头
请输入服务名称 (例如: user): user123
```

### 2. 目录已存在

如果输出目录已存在，脚本会继续使用该目录，但会覆盖同名文件。

### 3. 权限问题

确保脚本有执行权限：

```bash
chmod +x init_project.sh
```

### 4. 依赖问题

确保已安装 `goctl` 工具：

```bash
go install github.com/zeromicro/go-zero/tools/goctl@latest
``` 