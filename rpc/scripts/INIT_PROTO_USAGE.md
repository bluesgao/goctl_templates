# init_proto.sh 使用指南

## 概述

`init_proto.sh` 脚本用于创建基础的 proto 文件，包含一个简单的 Hello 方法示例。基于 `init_project.sh` 的交互式设计，支持用户友好的参数配置。

## 使用方法

### 基本使用

直接运行脚本，按照提示输入参数：

```bash
./init_proto.sh
```

### 交互式流程

1. **输出目录**
   ```
   请输入输出目录 (例如: ./proto): ./myproto
   ```

2. **服务名称**
   ```
   请输入服务名称 (例如: user): user
   ```

3. **Proto 文件名**
   ```
   请输入 proto 文件名 (默认: user.proto): 
   ```

4. **确认信息**
   ```
   Proto 文件配置信息：
   ----------------------------------------
   输出目录: ./myproto
   服务名称: user
   Proto 文件: user.proto
   ----------------------------------------
   确认创建 Proto 文件？(y/n): y
   ```

5. **高级选项配置**
   ```
   高级选项配置：
   是否包含通用消息 (Result, PageRequest 等)？(y/n, 默认: y): y
   是否包含示例服务方法？(y/n, 默认: y): y
   是否包含详细注释？(y/n, 默认: y): y
   是否包含常用导入语句？(y/n, 默认: y): y
   ```

## 高级选项说明

### 1. 通用消息 (INCLUDE_COMMON_MESSAGES)

- **选择 y**: 包含 Result、PageRequest、PageResponse、Sort、BaseEntity、FileInfo、UserInfo 等通用消息
- **选择 n**: 只包含基本的 Hello 方法相关消息

### 2. 示例服务方法 (INCLUDE_SERVICE_METHODS)

- **选择 y**: 包含 Hello 方法示例
- **选择 n**: 只生成服务定义，不包含具体方法

### 3. 详细注释 (INCLUDE_COMMENTS)

- **选择 y**: 包含详细的文件头注释和字段注释
- **选择 n**: 只包含基本的语法注释

### 4. 常用导入语句 (INCLUDE_IMPORTS)

- **选择 y**: 包含 google/protobuf/timestamp.proto 和 google/protobuf/empty.proto 导入
- **选择 n**: 不包含额外的导入语句

## 生成的 Hello 方法

### 服务定义

```protobuf
service UserService {
  // Hello 方法
  rpc Hello(HelloRequest) returns (HelloResponse);
}
```

### 请求消息

```protobuf
message HelloRequest {
  string name = 1;          // 名字
}
```

### 响应消息

```protobuf
message HelloResponse {
  Result result = 1;        // 响应结果
  string message = 2;       // 问候消息
  google.protobuf.Timestamp timestamp = 3;  // 当前时间
}
```

## 生成的文件结构

```
myproto/
├── user.proto              # Proto 文件
├── README.md               # 说明文档
└── compile.sh              # 编译脚本
```

## 示例会话

```
$ ./init_proto.sh

[INFO] 欢迎使用 Proto 文件生成脚本！

请输入输出目录 (例如: ./proto): ./user-service
请输入服务名称 (例如: user): user
请输入 proto 文件名 (默认: user.proto): 

[INFO] Proto 文件配置信息：
----------------------------------------
输出目录: ./user-service
服务名称: user
Proto 文件: user.proto
----------------------------------------
确认创建 Proto 文件？(y/n): y

[INFO] 高级选项配置：
是否包含通用消息 (Result, PageRequest 等)？(y/n, 默认: y): y
是否包含示例服务方法？(y/n, 默认: y): y
是否包含详细注释？(y/n, 默认: y): y
是否包含常用导入语句？(y/n, 默认: y): y

[INFO] 开始创建 Proto 文件...
[INFO] 输出目录: ./user-service
[INFO] 服务名称: user
[INFO] Proto 文件: user.proto
[INFO] 步骤 1: 生成 Proto 文件...
[INFO] Proto 文件已生成: ./user-service/user.proto
[INFO] 步骤 2: 生成 README 文档...
[INFO] README 文档已生成: ./user-service/README.md
[INFO] 步骤 3: 生成编译脚本...
[INFO] 编译脚本已生成: ./user-service/compile.sh
[INFO] 已包含通用消息定义
[INFO] 已包含示例服务方法
[INFO] 已包含详细注释
[INFO] 已包含常用导入语句
[INFO] Proto 文件创建完成！
[INFO] 输出目录: ./user-service
[INFO] Proto 文件: ./user-service/user.proto
[WARN] 接下来可以：
[WARN] 1. 使用 compile.sh 编译 proto 文件
[WARN] 2. 根据实际业务需求修改消息定义
[WARN] 3. 在服务中实现对应的 gRPC 方法
```

## 生成的 Proto 文件示例

```protobuf
/*
 * User Service Proto 文件
 * 
 * 此文件定义了 User 服务的 gRPC 接口
 * 包含服务方法定义、请求响应消息等
 * 
 * 生成时间: 2024-01-01 12:00:00
 * 服务名称: user
 * 文件路径: ./user-service/user.proto
 */

syntax = "proto3";

package user;

option go_package = ".";

import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

// 通用响应结果
message Result {
  int32 code = 1;           // 响应码
  string message = 2;        // 响应消息
  string data = 3;          // 响应数据（JSON字符串）
}

// 分页请求
message PageRequest {
  int32 page = 1;           // 页码，从1开始
  int32 size = 2;           // 每页大小
  string keyword = 3;       // 搜索关键词
  map<string, string> filters = 4;  // 过滤条件
  repeated Sort sorts = 5;  // 排序参数
}

// 分页响应
message PageResponse {
  int32 page = 1;           // 当前页码
  int32 size = 2;           // 每页大小
  int64 total = 3;          // 总记录数
  int32 pages = 4;          // 总页数
  repeated string data = 5;  // 数据列表（JSON字符串数组）
}

// 排序
message Sort {
  string field = 1;         // 排序字段
  string order = 2;         // 排序方向：asc/desc
}

// 基础实体信息
message BaseEntity {
  int64 id = 1;             // 实体ID
  string name = 2;          // 实体名称
  string description = 3;   // 实体描述
  google.protobuf.Timestamp created_at = 4;  // 创建时间
  google.protobuf.Timestamp updated_at = 5;  // 更新时间
}

// 文件信息
message FileInfo {
  string filename = 1;      // 文件名
  string path = 2;          // 文件路径
  int64 size = 3;           // 文件大小
  string mime_type = 4;     // MIME类型
  google.protobuf.Timestamp created_at = 5;  // 创建时间
}

// 用户信息
message UserInfo {
  int64 id = 1;             // 用户ID
  string username = 2;      // 用户名
  string email = 3;         // 邮箱
  string phone = 4;         // 手机号
  string avatar = 5;        // 头像
  int32 status = 6;         // 状态：1-正常，0-禁用
  google.protobuf.Timestamp created_at = 7;  // 创建时间
  google.protobuf.Timestamp updated_at = 8;  // 更新时间
}

// User 服务
service UserService {
  // Hello 方法
  rpc Hello(HelloRequest) returns (HelloResponse);
}

// Hello 请求
message HelloRequest {
  string name = 1;          // 名字
}

// Hello 响应
message HelloResponse {
  Result result = 1;        // 响应结果
  string message = 2;       // 问候消息
  google.protobuf.Timestamp timestamp = 3;  // 当前时间
}
```

## 编译和使用

### 1. 编译 Proto 文件

```bash
cd user-service
./compile.sh
```

### 2. 在 Go 服务中实现

```go
package main

import (
    "context"
    "fmt"
    "time"
    
    "google.golang.org/grpc"
    "google.golang.org/protobuf/types/known/timestamppb"
    
    pb "your-project/types"
)

type server struct {
    pb.UnimplementedUserServiceServer
}

func (s *server) Hello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
    name := req.Name
    message := fmt.Sprintf("Hello, %s!", name)
    timestamp := timestamppb.New(time.Now())
    
    return &pb.HelloResponse{
        Result: &pb.Result{
            Code:    0,
            Message: "success",
            Data:    "",
        },
        Message:   message,
        Timestamp: timestamp,
    }, nil
}
```

## 自动化测试

### 使用预设输入

```bash
cat > test_input.txt << EOF
./test_proto
user
user.proto
y
y
y
y
y
y
y
y
EOF

./init_proto.sh < test_input.txt
```

### 运行测试脚本

```bash
./test_init_proto.sh
```

## 注意事项

1. **输入验证**: 脚本会验证所有输入，确保格式正确
2. **默认值**: 大部分选项都有合理的默认值，可以直接按回车使用
3. **取消操作**: 在确认阶段选择 'n' 可以取消文件创建
4. **错误处理**: 输入错误时会提示重新输入
5. **文件覆盖**: 如果文件已存在，会覆盖同名文件

## 故障排除

### 1. 输入错误

如果输入了无效的服务名称，脚本会提示重新输入：

```
请输入服务名称 (例如: user): 123user
[ERROR] 服务名称只能包含字母和数字，且必须以字母开头
请输入服务名称 (例如: user): user
```

### 2. 编译错误

如果编译失败，检查：

```bash
# 安装 protoc
# macOS
brew install protobuf

# Ubuntu
sudo apt-get install protobuf-compiler

# 安装 Go 插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### 3. 权限问题

确保脚本有执行权限：

```bash
chmod +x init_proto.sh
``` 