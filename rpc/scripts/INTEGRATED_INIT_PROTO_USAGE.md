# 集成版 init_proto.sh 使用指南

## 概述

`init_proto.sh` 现在已集成 `fix_protobuf_imports.sh` 的功能，提供一体化的 proto 文件生成和依赖修复解决方案。

## 主要集成功能

### 1. 自动检测和修复

脚本现在会自动检测 Google protobuf 文件是否存在，并提供修复选项：

```bash
[WARN] Google protobuf 文件不存在
是否尝试修复 protobuf 导入问题？(y/n, 默认: y): 
```

### 2. 智能时间戳处理

根据修复结果自动选择时间戳格式：

- **修复成功**：使用 `google.protobuf.Timestamp`
- **修复失败或用户选择不修复**：使用 `string timestamp`

### 3. 集成修复功能

修复功能包括：
- 下载 protobuf 源码
- 安装 Google protobuf 文件
- 安装 Go protobuf 插件
- 验证编译功能

## 使用流程

### 基本使用

```bash
./init_proto.sh
```

### 交互式流程

1. **基础配置**
   ```
   请输入输出目录 (例如: ./proto): ./myproto
   请输入服务名称 (例如: user): user
   请输入 proto 文件名 (默认: user.proto): 
   ```

2. **确认信息**
   ```
   Proto 文件配置信息：
   ----------------------------------------
   输出目录: ./myproto
   服务名称: user
   Proto 文件: user.proto
   ----------------------------------------
   确认创建 Proto 文件？(y/n): y
   ```

3. **高级选项配置**
   ```
   高级选项配置：
   是否包含通用消息 (Result, PageRequest 等)？(y/n, 默认: y): y
   是否包含示例服务方法？(y/n, 默认: y): y
   是否包含详细注释？(y/n, 默认: y): y
   是否包含常用导入语句？(y/n, 默认: y): y
   ```

4. **依赖修复（如果 Google protobuf 文件不存在）**
   ```
   [WARN] Google protobuf 文件不存在
   是否尝试修复 protobuf 导入问题？(y/n, 默认: y): y
   
   [INFO] 开始修复 protobuf 导入问题...
   [INFO] protoc 包含路径: /usr/local/include
   [WARN] Google protobuf 文件不存在，尝试下载...
   [INFO] 下载 protobuf 源码...
   [INFO] 已复制 Google protobuf 文件到 /usr/local/include/google/protobuf/
   [INFO] 检查 Go protobuf 插件...
   [INFO] protoc-gen-go 已安装
   [INFO] protoc-gen-go-grpc 已安装
   [INFO] 测试编译...
   [INFO] ✅ 编译成功！protobuf 导入问题已修复
   [INFO] 修复成功，将使用 Google protobuf 导入
   ```

## 智能处理逻辑

### 检测逻辑

```bash
# 检查 Google protobuf 文件是否存在
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}' 2>/dev/null || echo "/usr/local/include")

if [ ! -f "$PROTOC_INCLUDE_PATH/google/protobuf/timestamp.proto" ]; then
    # 文件不存在，提供修复选项
    print_warn "Google protobuf 文件不存在"
    print_info "是否尝试修复 protobuf 导入问题？(y/n, 默认: y): "
    read -p "" FIX_IMPORTS
    case $FIX_IMPORTS in
        [Nn]* ) 
            # 用户选择不修复
            INCLUDE_IMPORTS="false"
            ;;
        * )
            # 用户选择修复
            if fix_protobuf_imports; then
                # 修复成功
                INCLUDE_IMPORTS="true"
            else
                # 修复失败
                INCLUDE_IMPORTS="false"
            fi
            ;;
    esac
fi
```

### 时间戳格式选择

```bash
# 根据是否包含 Google protobuf 导入来决定时间戳格式
if [ "$INCLUDE_IMPORTS" = "true" ]; then
    TIMESTAMP_FIELD="  google.protobuf.Timestamp timestamp = 3;  // 当前时间"
else
    TIMESTAMP_FIELD="  string timestamp = 3;     // 当前时间（字符串格式）"
fi
```

## 修复功能详解

### 1. 环境检查

```bash
# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    print_error "protoc 未安装，请先安装 protoc"
    return 1
fi
```

### 2. 路径检测

```bash
# 获取 protoc 的包含路径
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}')
if [ -z "$PROTOC_INCLUDE_PATH" ]; then
    # 尝试常见的安装路径
    PROTOC_INCLUDE_PATH="/usr/local/include"
    if [ ! -d "$PROTOC_INCLUDE_PATH/google/protobuf" ]; then
        PROTOC_INCLUDE_PATH="/usr/include"
    fi
fi
```

### 3. 文件下载和安装

```bash
# 下载 protobuf 源码
if command -v git &> /dev/null; then
    git clone --depth 1 https://github.com/protocolbuffers/protobuf.git
    cd protobuf/src/google/protobuf
    
    # 复制文件到系统目录
    if [ -w "$PROTOC_INCLUDE_PATH" ]; then
        sudo mkdir -p "$PROTOC_INCLUDE_PATH/google/protobuf"
        sudo cp *.proto "$PROTOC_INCLUDE_PATH/google/protobuf/"
    fi
fi
```

### 4. 插件安装

```bash
# 检查并安装 Go protobuf 插件
if ! command -v protoc-gen-go &> /dev/null; then
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi
```

### 5. 验证编译

```bash
# 创建测试文件并验证编译
cat > "$TEST_PROTO" << 'EOF'
syntax = "proto3";
package test;
option go_package = ".";
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

message TestMessage {
  string name = 1;
  google.protobuf.Timestamp created_at = 2;
}

service TestService {
  rpc Test(google.protobuf.Empty) returns (TestMessage);
}
EOF

if protoc --go_out=. --go-grpc_out=. "$TEST_PROTO" 2>/dev/null; then
    print_info "✅ 编译成功！protobuf 导入问题已修复"
    return 0
else
    print_error "❌ 编译失败，请检查 protobuf 安装"
    return 1
fi
```

## 生成的文件示例

### 包含 Google protobuf 导入的版本

```protobuf
/*
 * User Service Proto 文件
 * 
 * 此文件定义了 User 服务的 gRPC 接口
 * 包含服务方法定义、请求响应消息等
 * 
 * 生成时间: 2024-01-01 12:00:00
 * 服务名称: user
 * 文件路径: ./myproto/user.proto
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

### 不包含 Google protobuf 导入的版本

```protobuf
/*
 * User Service Proto 文件
 * 
 * 此文件定义了 User 服务的 gRPC 接口
 * 包含服务方法定义、请求响应消息等
 * 
 * 生成时间: 2024-01-01 12:00:00
 * 服务名称: user
 * 文件路径: ./myproto/user.proto
 */

syntax = "proto3";

package user;

option go_package = ".";

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
  string timestamp = 3;     // 当前时间（字符串格式）
}
```

## 测试脚本

### 运行集成测试

```bash
# 测试集成后的功能
./test_integrated_init_proto.sh
```

### 测试内容

1. **正常场景测试**
   - Google protobuf 文件存在
   - 验证生成的 proto 文件内容

2. **修复场景测试**
   - 模拟 Google protobuf 文件不存在
   - 测试修复功能
   - 验证修复结果

3. **降级场景测试**
   - 用户选择不修复
   - 验证使用字符串格式时间戳

## 故障排除

### 1. 权限问题

如果遇到权限错误：

```bash
# 确保脚本有执行权限
chmod +x init_proto.sh

# 如果修复过程需要 sudo 权限
sudo ./init_proto.sh
```

### 2. 网络问题

如果下载失败：

```bash
# 检查网络连接
ping github.com

# 手动下载 protobuf 源码
git clone https://github.com/protocolbuffers/protobuf.git
```

### 3. 编译问题

如果编译失败：

```bash
# 检查 protoc 版本
protoc --version

# 重新安装 protoc
# macOS
brew reinstall protobuf

# Ubuntu
sudo apt-get install --reinstall protobuf-compiler
```

## 优势对比

| 功能 | 原版本 | 集成版本 |
|------|--------|----------|
| 依赖检测 | 手动 | 自动 |
| 修复功能 | 独立脚本 | 集成 |
| 用户交互 | 基础 | 智能 |
| 错误处理 | 简单 | 详细 |
| 时间戳处理 | 固定 | 智能选择 |
| 用户体验 | 一般 | 优秀 |

## 注意事项

1. **自动检测**：脚本会自动检测 Google protobuf 文件是否存在
2. **用户选择**：提供修复选项，用户可以选择是否修复
3. **智能降级**：如果修复失败，会自动使用字符串格式的时间戳
4. **权限要求**：修复过程可能需要 sudo 权限
5. **网络依赖**：修复过程需要网络连接下载源码
6. **向后兼容**：保持原有的功能和接口不变

## 使用建议

1. **首次使用**：建议选择修复，以获得完整的 Google protobuf 功能
2. **快速开发**：如果不需要 Google protobuf 功能，可以选择不修复
3. **生产环境**：建议在开发环境测试修复功能后再在生产环境使用
4. **团队协作**：统一团队的 protobuf 环境配置 