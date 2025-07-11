#!/bin/bash

# 修复 protobuf 导入文件找不到的问题
# 用于解决 google/protobuf/timestamp.proto 和 google/protobuf/empty.proto 找不到的问题

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

print_info "开始修复 protobuf 导入问题..."

# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    print_error "protoc 未安装，请先安装 protoc"
    print_info "安装方法："
    print_info "  macOS: brew install protobuf"
    print_info "  Ubuntu: sudo apt-get install protobuf-compiler"
    print_info "  CentOS: sudo yum install protobuf-compiler"
    exit 1
fi

# 获取 protoc 的包含路径
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}')
if [ -z "$PROTOC_INCLUDE_PATH" ]; then
    # 尝试常见的安装路径
    PROTOC_INCLUDE_PATH="/usr/local/include"
    if [ ! -d "$PROTOC_INCLUDE_PATH/google/protobuf" ]; then
        PROTOC_INCLUDE_PATH="/usr/include"
    fi
fi

print_info "protoc 包含路径: $PROTOC_INCLUDE_PATH"

# 检查 Google protobuf 文件是否存在
if [ ! -f "$PROTOC_INCLUDE_PATH/google/protobuf/timestamp.proto" ]; then
    print_warn "Google protobuf 文件不存在，尝试下载..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # 下载 protobuf 源码
    print_info "下载 protobuf 源码..."
    if command -v git &> /dev/null; then
        git clone --depth 1 https://github.com/protocolbuffers/protobuf.git
        cd protobuf/src/google/protobuf
        
        # 复制文件到系统目录
        if [ -w "$PROTOC_INCLUDE_PATH" ]; then
            sudo mkdir -p "$PROTOC_INCLUDE_PATH/google/protobuf"
            sudo cp *.proto "$PROTOC_INCLUDE_PATH/google/protobuf/"
            print_info "已复制 Google protobuf 文件到 $PROTOC_INCLUDE_PATH/google/protobuf/"
        else
            print_warn "无法写入系统目录，请手动复制文件"
            print_info "请将以下文件复制到 $PROTOC_INCLUDE_PATH/google/protobuf/："
            ls -la *.proto
        fi
    else
        print_error "git 未安装，无法下载 protobuf 源码"
        print_info "请手动下载并安装 protobuf"
    fi
    
    # 清理临时目录
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
else
    print_info "Google protobuf 文件已存在"
fi

# 检查 Go 插件是否安装
print_info "检查 Go protobuf 插件..."

if ! command -v protoc-gen-go &> /dev/null; then
    print_warn "安装 protoc-gen-go..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
else
    print_info "protoc-gen-go 已安装"
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    print_warn "安装 protoc-gen-go-grpc..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
else
    print_info "protoc-gen-go-grpc 已安装"
fi

# 创建测试 proto 文件来验证修复
print_info "创建测试文件验证修复..."
TEST_PROTO="test_fix.proto"

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

# 测试编译
print_info "测试编译..."
if protoc --go_out=. --go-grpc_out=. "$TEST_PROTO" 2>/dev/null; then
    print_info "✅ 编译成功！protobuf 导入问题已修复"
    
    # 检查生成的文件
    if [ -f "test.pb.go" ] && [ -f "test_grpc.pb.go" ]; then
        print_info "✅ 生成了 Go 代码文件"
    fi
else
    print_error "❌ 编译失败，请检查 protobuf 安装"
    print_info "可能的解决方案："
    print_info "1. 重新安装 protoc: brew reinstall protobuf"
    print_info "2. 手动下载 Google protobuf 文件"
    print_info "3. 使用 -I 参数指定包含路径"
fi

# 清理测试文件
rm -f "$TEST_PROTO" test.pb.go test_grpc.pb.go

print_info "修复完成！"
print_info "现在可以正常使用包含 google/protobuf 导入的 proto 文件了" 