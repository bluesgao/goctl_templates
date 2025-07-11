# user Service Proto 文件

## 概述

此文件定义了 user 服务的 gRPC 接口，包含服务方法定义、请求响应消息等。

## 文件结构

```
user.proto
├── 通用消息定义
│   ├── Result              # 通用响应结果
│   ├── PageRequest         # 分页请求
│   ├── PageResponse        # 分页响应
│   ├── Sort               # 排序参数
│   ├── BaseEntity         # 基础实体信息
│   ├── FileInfo           # 文件信息
│   └── UserInfo           # 用户信息
├── 服务定义
│   └── userService  # user 服务
└── 请求响应消息
    ├── HelloRequest/Response
```

## 服务方法

### Hello
简单的问候方法，输入名字，返回问候消息和当前时间（字符串格式）

## 通用消息说明

### Result
通用响应结果，包含响应码、消息和数据。

### PageRequest/PageResponse
分页请求和响应，支持页码、大小、关键词搜索、过滤条件和排序。

### BaseEntity
基础实体信息，包含 ID、名称、描述、创建时间和更新时间。

### FileInfo
文件信息，包含文件名、路径、大小、MIME类型和创建时间。

### UserInfo
用户信息，包含用户ID、用户名、邮箱、手机号、头像、状态和时间戳。

## 使用方法

1. 将此 proto 文件添加到项目中
2. 使用 protoc 编译生成 Go 代码
3. 在服务中实现对应的 gRPC 方法

## 编译命令

```bash
# 生成 Go 代码
protoc --go_out=. --go-grpc_out=. user.proto

# 或使用 goctl
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=.
```

## 注意事项

1. 确保已安装 protoc 编译器
2. 确保已安装 Go protobuf 插件
3. 根据实际业务需求修改消息定义
4. 添加适当的字段验证和错误处理
5. 脚本会自动检测并修复 Google protobuf 导入问题
6. 如果修复失败，会自动使用字符串格式的时间戳
