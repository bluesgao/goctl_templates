#!/bin/bash

# 简化版 Proto 文件生成脚本
# 不依赖 Google protobuf 导入，避免导入文件找不到的问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 交互式参数收集
print_info "欢迎使用简化版 Proto 文件生成脚本！"
echo ""

# 获取输出目录
while true; do
    read -p "请输入输出目录 (例如: ./proto): " OUTPUT_DIR
    if [ -n "$OUTPUT_DIR" ]; then
        break
    else
        print_error "输出目录不能为空，请重新输入"
    fi
done

# 获取服务名称
while true; do
    read -p "请输入服务名称 (例如: user): " SERVICE_NAME
    if [ -n "$SERVICE_NAME" ]; then
        # 检查服务名称格式
        if [[ "$SERVICE_NAME" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
            break
        else
            print_error "服务名称只能包含字母和数字，且必须以字母开头"
        fi
    else
        print_error "服务名称不能为空，请重新输入"
    fi
done

# 获取 proto 文件名
read -p "请输入 proto 文件名 (默认: ${SERVICE_NAME}.proto): " PROTO_FILE_INPUT
if [ -z "$PROTO_FILE_INPUT" ]; then
    PROTO_FILE="${SERVICE_NAME}.proto"
else
    PROTO_FILE="$PROTO_FILE_INPUT"
fi

# 确认信息
echo ""
print_info "Proto 文件配置信息："
echo "----------------------------------------"
echo "输出目录: $OUTPUT_DIR"
echo "服务名称: $SERVICE_NAME"
echo "Proto 文件: $PROTO_FILE"
echo "----------------------------------------"

# 确认是否继续
while true; do
    read -p "确认创建 Proto 文件？(y/n): " CONFIRM
    case $CONFIRM in
        [Yy]* ) break;;
        [Nn]* ) 
            print_info "已取消 Proto 文件创建"
            exit 0
            ;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 高级选项
echo ""
print_info "高级选项配置："

# 是否包含通用消息
while true; do
    read -p "是否包含通用消息 (Result, PageRequest 等)？(y/n, 默认: y): " INCLUDE_COMMON_MESSAGES
    case $INCLUDE_COMMON_MESSAGES in
        [Yy]* ) INCLUDE_COMMON_MESSAGES="true"; break;;
        [Nn]* ) INCLUDE_COMMON_MESSAGES="false"; break;;
        "" ) INCLUDE_COMMON_MESSAGES="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含示例服务方法
while true; do
    read -p "是否包含示例服务方法？(y/n, 默认: y): " INCLUDE_SERVICE_METHODS
    case $INCLUDE_SERVICE_METHODS in
        [Yy]* ) INCLUDE_SERVICE_METHODS="true"; break;;
        [Nn]* ) INCLUDE_SERVICE_METHODS="false"; break;;
        "" ) INCLUDE_SERVICE_METHODS="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含注释
while true; do
    read -p "是否包含详细注释？(y/n, 默认: y): " INCLUDE_COMMENTS
    case $INCLUDE_COMMENTS in
        [Yy]* ) INCLUDE_COMMENTS="true"; break;;
        [Nn]* ) INCLUDE_COMMENTS="false"; break;;
        "" ) INCLUDE_COMMENTS="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

print_info "开始创建 Proto 文件..."
print_info "输出目录: $OUTPUT_DIR"
print_info "服务名称: $SERVICE_NAME"
print_info "Proto 文件: $PROTO_FILE"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 生成 proto 文件
print_info "步骤 1: 生成 Proto 文件..."

# 生成通用消息（简化版，不依赖 Google protobuf）
COMMON_MESSAGES=""
if [ "$INCLUDE_COMMON_MESSAGES" = "true" ]; then
    COMMON_MESSAGES="// 通用响应结果
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

// 时间戳（简化版，使用字符串）
message Timestamp {
  string created_at = 1;    // 创建时间
  string updated_at = 2;    // 更新时间
}

// 基础实体信息
message BaseEntity {
  int64 id = 1;             // 实体ID
  string name = 2;          // 实体名称
  string description = 3;   // 实体描述
  Timestamp timestamp = 4;  // 时间戳
}

// 文件信息
message FileInfo {
  string filename = 1;      // 文件名
  string path = 2;          // 文件路径
  int64 size = 3;           // 文件大小
  string mime_type = 4;     // MIME类型
  string created_at = 5;    // 创建时间
}

// 用户信息
message UserInfo {
  int64 id = 1;             // 用户ID
  string username = 2;      // 用户名
  string email = 3;         // 邮箱
  string phone = 4;         // 手机号
  string avatar = 5;        // 头像
  int32 status = 6;         // 状态：1-正常，0-禁用
  string created_at = 7;    // 创建时间
  string updated_at = 8;    // 更新时间
}

"
fi

# 生成服务方法
SERVICE_METHODS=""
if [ "$INCLUDE_SERVICE_METHODS" = "true" ]; then
    SERVICE_METHODS="  // Hello 方法
  rpc Hello(HelloRequest) returns (HelloResponse);
"
fi

# 生成请求响应消息
REQUEST_RESPONSE_MESSAGES=""
if [ "$INCLUDE_SERVICE_METHODS" = "true" ]; then
    REQUEST_RESPONSE_MESSAGES="// Hello 请求
message HelloRequest {
  string name = 1;          // 名字
}

// Hello 响应
message HelloResponse {
  Result result = 1;        // 响应结果
  string message = 2;       // 问候消息
  string timestamp = 3;     // 当前时间（字符串格式）
}

"
fi

# 生成注释
COMMENTS=""
if [ "$INCLUDE_COMMENTS" = "true" ]; then
    COMMENTS="/*
 * ${SERVICE_NAME} Service Proto 文件
 * 
 * 此文件定义了 ${SERVICE_NAME} 服务的 gRPC 接口
 * 包含服务方法定义、请求响应消息等
 * 
 * 生成时间: $(date)
 * 服务名称: ${SERVICE_NAME}
 * 文件路径: ${OUTPUT_DIR}/${PROTO_FILE}
 */

"
fi

cat > "$OUTPUT_DIR/$PROTO_FILE" << EOF
${COMMENTS}syntax = "proto3";

package $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]');

option go_package = ".";

${COMMON_MESSAGES}// ${SERVICE_NAME} 服务
service ${SERVICE_NAME}Service {
${SERVICE_METHODS}}

${REQUEST_RESPONSE_MESSAGES}
EOF

print_info "Proto 文件已生成: $OUTPUT_DIR/$PROTO_FILE"

# 生成 README 文档
if [ "$INCLUDE_COMMENTS" = "true" ]; then
    print_info "步骤 2: 生成 README 文档..."
    cat > "$OUTPUT_DIR/README.md" << EOF
# ${SERVICE_NAME} Service Proto 文件

## 概述

此文件定义了 ${SERVICE_NAME} 服务的 gRPC 接口，包含服务方法定义、请求响应消息等。

## 文件结构

\`\`\`
${PROTO_FILE}
├── 通用消息定义
│   ├── Result              # 通用响应结果
│   ├── PageRequest         # 分页请求
│   ├── PageResponse        # 分页响应
│   ├── Sort               # 排序参数
│   ├── Timestamp          # 时间戳（字符串格式）
│   ├── BaseEntity         # 基础实体信息
│   ├── FileInfo           # 文件信息
│   └── UserInfo           # 用户信息
├── 服务定义
│   └── ${SERVICE_NAME}Service  # ${SERVICE_NAME} 服务
└── 请求响应消息
    ├── HelloRequest/Response
\`\`\`

## 服务方法

### Hello
简单的问候方法，输入名字，返回问候消息和当前时间

## 通用消息说明

### Result
通用响应结果，包含响应码、消息和数据。

### PageRequest/PageResponse
分页请求和响应，支持页码、大小、关键词搜索、过滤条件和排序。

### Timestamp
时间戳（简化版），使用字符串格式存储时间，避免 Google protobuf 依赖。

### BaseEntity
基础实体信息，包含 ID、名称、描述和时间戳。

### FileInfo
文件信息，包含文件名、路径、大小、MIME类型和创建时间。

### UserInfo
用户信息，包含用户ID、用户名、邮箱、手机号、头像、状态和时间戳。

## 使用方法

1. 将此 proto 文件添加到项目中
2. 使用 protoc 编译生成 Go 代码
3. 在服务中实现对应的 gRPC 方法

## 编译命令

\`\`\`bash
# 生成 Go 代码
protoc --go_out=. --go-grpc_out=. ${PROTO_FILE}

# 或使用 goctl
goctl rpc protoc ${PROTO_FILE} --go_out=./types --go-grpc_out=./types --zrpc_out=.
\`\`\`

## 注意事项

1. 确保已安装 protoc 编译器
2. 确保已安装 Go protobuf 插件
3. 根据实际业务需求修改消息定义
4. 添加适当的字段验证和错误处理
5. 此版本使用字符串格式的时间戳，避免 Google protobuf 依赖问题
EOF
    print_info "README 文档已生成: $OUTPUT_DIR/README.md"
fi

# 生成编译脚本
print_info "步骤 3: 生成编译脚本..."
cat > "$OUTPUT_DIR/compile.sh" << EOF
#!/bin/bash

# ${SERVICE_NAME} Service Proto 编译脚本

set -e

echo "开始编译 ${PROTO_FILE}..."

# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装，请先安装 protoc"
    exit 1
fi

# 检查 Go protobuf 插件是否安装
if ! command -v protoc-gen-go &> /dev/null; then
    echo "安装 protoc-gen-go..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo "安装 protoc-gen-go-grpc..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# 创建输出目录
mkdir -p types

# 编译 proto 文件
echo "编译 ${PROTO_FILE}..."
protoc --go_out=types --go-grpc_out=types ${PROTO_FILE}

echo "编译完成！"
echo "生成的文件："
echo "- types/$(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]')_grpc.pb.go"
echo "- types/$(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]').pb.go"
EOF

chmod +x "$OUTPUT_DIR/compile.sh"
print_info "编译脚本已生成: $OUTPUT_DIR/compile.sh"

# 根据用户选择显示不同的信息
if [ "$INCLUDE_COMMON_MESSAGES" = "true" ]; then
    print_info "已包含通用消息定义"
fi

if [ "$INCLUDE_SERVICE_METHODS" = "true" ]; then
    print_info "已包含示例服务方法"
fi

if [ "$INCLUDE_COMMENTS" = "true" ]; then
    print_info "已包含详细注释"
fi

print_info "Proto 文件创建完成！"
print_info "输出目录: $OUTPUT_DIR"
print_info "Proto 文件: $OUTPUT_DIR/$PROTO_FILE"

print_warn "接下来可以："
print_warn "1. 使用 compile.sh 编译 proto 文件"
print_warn "2. 根据实际业务需求修改消息定义"
print_warn "3. 在服务中实现对应的 gRPC 方法"
print_warn "4. 如果遇到 Google protobuf 导入问题，可以运行 ./fix_protobuf_imports.sh" 