#!/bin/bash

# 初始化 Proto 文件脚本
# 用于创建基础的 proto 文件

set -e

# 全局变量
OUTPUT_DIR=""
SERVICE_NAME=""
PROTO_FILE=""
GO_PACKAGE_PATH=""
INCLUDE_COMMON_MESSAGES="true"
INCLUDE_SERVICE_METHODS="true"
INCLUDE_COMMENTS="true"
INCLUDE_IMPORTS="true"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# 工具函数
# =============================================================================

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

# 验证服务名称格式
validate_service_name() {
    local name="$1"
    if [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        return 0
    else
        return 1
    fi
}

# 获取用户输入
get_user_input() {
    local prompt="$1"
    local default_value="$2"
    local validation_func="$3"
    
    while true; do
        if [ -n "$default_value" ]; then
            read -p "$prompt (默认: $default_value): " input
            if [ -z "$input" ]; then
                input="$default_value"
            fi
        else
            read -p "$prompt: " input
        fi
        
        if [ -n "$input" ]; then
            if [ -n "$validation_func" ]; then
                if $validation_func "$input"; then
                    echo "$input"
                    return 0
                else
                    print_error "输入格式不正确，请重新输入"
                fi
            else
                echo "$input"
                return 0
            fi
        else
            print_error "输入不能为空，请重新输入"
        fi
    done
}

# 获取用户确认
get_user_confirmation() {
    local prompt="$1"
    local default="$2"
    
    while true; do
        read -p "$prompt (y/n, 默认: $default): " confirm
        case $confirm in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) 
                if [ "$default" = "y" ]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "请输入 y 或 n";;
        esac
    done
}

# =============================================================================
# 参数收集函数
# =============================================================================

# 收集基础参数
collect_basic_params() {
    print_info "欢迎使用 Proto 文件生成脚本！"
    echo ""
    
    # 获取输出目录
    OUTPUT_DIR=$(get_user_input "请输入输出目录" "./proto")
    
    # 获取服务名称
    SERVICE_NAME=$(get_user_input "请输入服务名称" "user" "validate_service_name")
    
    # 获取 proto 文件名
    PROTO_FILE=$(get_user_input "请输入 proto 文件名" "${SERVICE_NAME}.proto")
    
    # 获取 go_package 路径
    GO_PACKAGE_PATH=$(get_user_input "请输入 go_package 路径" "github.com/example/${SERVICE_NAME}/types")
}

# 显示配置信息
show_config_info() {
    echo ""
    print_info "Proto 文件配置信息："
    echo "----------------------------------------"
    echo "输出目录: $OUTPUT_DIR"
    echo "服务名称: $SERVICE_NAME"
    echo "Proto 文件: $PROTO_FILE"
    echo "Go Package: $GO_PACKAGE_PATH"
    echo "----------------------------------------"
}

# 确认创建
confirm_creation() {
    if ! get_user_confirmation "确认创建 Proto 文件？" "y"; then
        print_info "已取消 Proto 文件创建"
        exit 0
    fi
}

# 收集高级选项
collect_advanced_options() {
    echo ""
    print_info "高级选项配置："
    
    # 是否包含通用消息
    if get_user_confirmation "是否包含通用消息 (Result, PageRequest 等)？" "y"; then
        INCLUDE_COMMON_MESSAGES="true"
    else
        INCLUDE_COMMON_MESSAGES="false"
    fi
    
    # 是否包含示例服务方法
    if get_user_confirmation "是否包含示例服务方法？" "y"; then
        INCLUDE_SERVICE_METHODS="true"
    else
        INCLUDE_SERVICE_METHODS="false"
    fi
    
    # 是否包含注释
    if get_user_confirmation "是否包含详细注释？" "y"; then
        INCLUDE_COMMENTS="true"
    else
        INCLUDE_COMMENTS="false"
    fi
    
    # 是否包含导入语句
    if get_user_confirmation "是否包含常用导入语句？" "y"; then
        INCLUDE_IMPORTS="true"
    else
        INCLUDE_IMPORTS="false"
    fi
}

# =============================================================================
# 内容处理函数
# =============================================================================

# 处理导入语句
handle_imports() {
    local imports=""
    
    if [ "$INCLUDE_IMPORTS" = "true" ]; then
        imports="import \"google/protobuf/timestamp.proto\";
import \"google/protobuf/empty.proto\";
"
    fi
    
    echo "${imports:-}"
}

# =============================================================================
# 内容生成函数
# =============================================================================

# 生成通用消息
generate_common_messages() {
    if [ "$INCLUDE_COMMON_MESSAGES" = "true" ]; then
        cat << 'EOF'
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

EOF
    else
        # 返回空字符串，避免语法错误
        echo ""
    fi
}

# 生成服务方法
generate_service_methods() {
    if [ "$INCLUDE_SERVICE_METHODS" = "true" ]; then
        cat << 'EOF'
  // Hello 方法
  rpc Hello(HelloRequest) returns (HelloResponse);
EOF
    else
        # 返回空字符串，避免语法错误
        echo ""
    fi
}

# 生成请求响应消息
generate_request_response_messages() {
    if [ "$INCLUDE_SERVICE_METHODS" = "true" ]; then
        # 根据用户选择决定时间戳格式
        local timestamp_field
        if [ "$INCLUDE_IMPORTS" = "true" ]; then
            timestamp_field="  google.protobuf.Timestamp timestamp = 3;  // 当前时间"
        else
            timestamp_field="  string timestamp = 3;     // 当前时间（字符串格式）"
        fi
        
        cat << EOF
// Hello 请求
message HelloRequest {
  string name = 1;          // 名字
}

// Hello 响应
message HelloResponse {
  Result result = 1;        // 响应结果
  string message = 2;       // 问候消息
${timestamp_field}
}

EOF
    else
        # 返回空字符串，避免语法错误
        echo ""
    fi
}

# 生成注释
generate_comments() {
    if [ "$INCLUDE_COMMENTS" = "true" ]; then
        cat << EOF
/*
 * ${SERVICE_NAME} Service Proto 文件
 * 
 * 此文件定义了 ${SERVICE_NAME} 服务的 gRPC 接口
 * 包含服务方法定义、请求响应消息等
 * 
 * 生成时间: $(date)
 * 服务名称: ${SERVICE_NAME}
 * 文件路径: ${OUTPUT_DIR}/${PROTO_FILE}
 */

EOF
    else
        # 返回空字符串，避免语法错误
        echo ""
    fi
}

# 生成 proto 文件
generate_proto_file() {
    local imports="$1"
    local common_messages="$2"
    local service_methods="$3"
    local request_response_messages="$4"
    local comments="$5"
    
    # 确保变量不为空，避免语法错误
    local safe_imports="${imports:-}"
    local safe_common_messages="${common_messages:-}"
    local safe_service_methods="${service_methods:-}"
    local safe_request_response_messages="${request_response_messages:-}"
    local safe_comments="${comments:-}"
    
    cat > "$OUTPUT_DIR/$PROTO_FILE" << EOF
${safe_comments}syntax = "proto3";

package $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]');

option go_package = "${GO_PACKAGE_PATH}";

${safe_imports}${safe_common_messages}// ${SERVICE_NAME} 服务
service ${SERVICE_NAME}Service {
${safe_service_methods}}

${safe_request_response_messages}
EOF
}

# =============================================================================
# 文档生成函数
# =============================================================================

# 生成 README 文档
generate_readme() {
    if [ "$INCLUDE_COMMENTS" = "true" ]; then
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
├── 服务定义
│   └── ${SERVICE_NAME}Service  # ${SERVICE_NAME} 服务
└── 请求响应消息
    ├── HelloRequest/Response
\`\`\`

## 服务方法

### Hello
简单的问候方法，输入名字，返回问候消息和当前时间（字符串格式）

## 通用消息说明

### Result
通用响应结果，包含响应码、消息和数据。

### PageRequest/PageResponse
分页请求和响应，支持页码、大小、关键词搜索、过滤条件和排序。

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
5. 如需使用 Google protobuf 类型，请确保相关文件已正确安装
EOF
    fi
}



# =============================================================================
# 主流程函数
# =============================================================================

# 收集参数
collect_params() {
    collect_basic_params
    show_config_info
    confirm_creation
    collect_advanced_options
}

# 创建文件
create_files() {
    print_info "开始创建 Proto 文件..."
    print_info "输出目录: $OUTPUT_DIR"
    print_info "服务名称: $SERVICE_NAME"
    print_info "Proto 文件: $PROTO_FILE"

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"

    # 生成 proto 文件
    print_info "步骤 1: 生成 Proto 文件..."
    
    local imports=$(handle_imports)
    local common_messages=$(generate_common_messages)
    local service_methods=$(generate_service_methods)
    local request_response_messages=$(generate_request_response_messages)
    local comments=$(generate_comments)
    
    generate_proto_file "$imports" "$common_messages" "$service_methods" "$request_response_messages" "$comments"
    
    print_info "Proto 文件已生成: $OUTPUT_DIR/$PROTO_FILE"
}

# 生成文档
generate_documents() {
    # 生成 README 文档
    if [ "$INCLUDE_COMMENTS" = "true" ]; then
        print_info "步骤 2: 生成 README 文档..."
        generate_readme
        print_info "README 文档已生成: $OUTPUT_DIR/README.md"
    fi
}

# 显示结果
show_results() {
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

    if [ "$INCLUDE_IMPORTS" = "true" ]; then
        print_info "已包含常用导入语句（Google protobuf）"
    else
        print_info "未包含 Google protobuf 导入"
    fi

    print_info "Proto 文件创建完成！"
    print_info "输出目录: $OUTPUT_DIR"
    print_info "Proto 文件: $OUTPUT_DIR/$PROTO_FILE"

    print_warn "接下来可以："
print_warn "1. 根据实际业务需求修改消息定义"
print_warn "2. 在服务中实现对应的 gRPC 方法"
print_warn "3. 使用 protoc 或 goctl 编译 proto 文件"
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    collect_params
    create_files
    generate_documents
    show_results
}

# 执行主函数
main "$@" 