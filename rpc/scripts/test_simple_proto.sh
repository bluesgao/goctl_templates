#!/bin/bash

# 简化的 proto 语法测试
# 避免用户交互，直接测试核心功能

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

# 创建测试目录
TEST_DIR="./test_simple_proto"

print_info "开始简化测试..."

# 清理之前的测试
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

# 创建测试输入文件
cat > test_simple_input.txt << EOF
./test_simple_proto
user
user.proto
github.com/example/user/types
y
y
y
y
y
y
y
y
EOF

print_info "运行简化测试..."
./init_proto.sh < test_simple_input.txt

# 验证生成的文件
print_info "验证生成的文件..."

if [ -f "$TEST_DIR/user.proto" ]; then
    print_info "✓ user.proto 已生成"
    
    # 显示生成的 proto 文件内容
    print_info "生成的 proto 文件内容："
    echo "----------------------------------------"
    cat "$TEST_DIR/user.proto"
    echo "----------------------------------------"
    
    # 检查语法错误
    print_info "检查 proto 文件语法..."
    if protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/user.proto" 2>/dev/null; then
        print_info "✓ proto 文件语法正确"
    else
        print_error "✗ proto 文件有语法错误"
        protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/user.proto"
    fi
else
    print_error "✗ user.proto 未生成"
fi

# 清理测试
rm -rf "$TEST_DIR"
rm -f test_simple_input.txt

print_info "简化测试完成！" 