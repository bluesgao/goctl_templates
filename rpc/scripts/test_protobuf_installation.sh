#!/bin/bash

# 测试 protobuf 安装功能
# 验证 Google protobuf 导入文件的安装和使用

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

print_info "开始测试 protobuf 安装功能..."

# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    print_error "protoc 未安装，请先安装 protoc"
    exit 1
fi

# 获取 protoc 的包含路径
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}' 2>/dev/null || echo "/usr/local/include")
if [ -z "$PROTOC_INCLUDE_PATH" ]; then
    PROTOC_INCLUDE_PATH="/usr/local/include"
    if [ ! -d "$PROTOC_INCLUDE_PATH/google/protobuf" ]; then
        PROTOC_INCLUDE_PATH="/usr/include"
    fi
fi

print_info "protoc 包含路径: $PROTOC_INCLUDE_PATH"

# 检查 Google protobuf 文件是否存在
if [ -f "$PROTOC_INCLUDE_PATH/google/protobuf/timestamp.proto" ]; then
    print_info "✅ Google protobuf 文件已存在"
    
    # 测试编译
    print_info "测试编译包含 google.protobuf.Timestamp 的 proto 文件..."
    
    cat > test_timestamp.proto << 'EOF'
syntax = "proto3";

package test;

option go_package = ".";

import "google/protobuf/timestamp.proto";

message TestMessage {
  string name = 1;
  google.protobuf.Timestamp created_at = 2;
}
EOF
    
    if protoc --go_out=. test_timestamp.proto 2>/dev/null; then
        print_info "✅ 编译成功！google.protobuf.Timestamp 可以正常使用"
    else
        print_error "❌ 编译失败"
        protoc --go_out=. test_timestamp.proto
    fi
    
    # 清理测试文件
    rm -f test_timestamp.proto test.pb.go
else
    print_warn "⚠️ Google protobuf 文件不存在"
    print_info "运行安装脚本..."
    
    if [ -f "./install_google_protobuf.sh" ]; then
        chmod +x ./install_google_protobuf.sh
        ./install_google_protobuf.sh
    else
        print_error "安装脚本不存在"
    fi
fi

print_info "测试完成！" 