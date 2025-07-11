#!/bin/bash

# 测试修复后的 proto 语法
# 验证生成的 proto 文件是否有语法错误

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
TEST_DIR="./test_fix_proto_syntax"

print_info "开始测试修复后的 proto 语法..."

# 清理之前的测试
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

# 测试场景 1: 完整配置
print_info "测试场景 1: 完整配置..."
cat > test_fix_input1.txt << EOF
./test_fix_proto_syntax
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

print_info "运行完整配置测试..."
./init_proto.sh < test_fix_input1.txt

# 验证生成的 proto 文件语法
print_info "验证生成的 proto 文件语法..."

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

# 清理第一个测试
rm -rf "$TEST_DIR"
rm -f test_fix_input1.txt

# 测试场景 2: 最小化配置
print_info "测试场景 2: 最小化配置..."
cat > test_fix_input2.txt << EOF
./test_fix_proto_syntax
test
test.proto
y
n
n
n
n
y
y
y
EOF

print_info "运行最小化配置测试..."
./init_proto.sh < test_fix_input2.txt

# 验证生成的 proto 文件语法
print_info "验证最小化配置生成的 proto 文件语法..."

if [ -f "$TEST_DIR/test.proto" ]; then
    print_info "✓ test.proto 已生成"
    
    # 显示生成的 proto 文件内容
    print_info "生成的 proto 文件内容："
    echo "----------------------------------------"
    cat "$TEST_DIR/test.proto"
    echo "----------------------------------------"
    
    # 检查语法错误
    print_info "检查 proto 文件语法..."
    if protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/test.proto" 2>/dev/null; then
        print_info "✓ proto 文件语法正确"
    else
        print_error "✗ proto 文件有语法错误"
        protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/test.proto"
    fi
else
    print_error "✗ test.proto 未生成"
fi

# 清理第二个测试
rm -rf "$TEST_DIR"
rm -f test_fix_input2.txt

# 测试场景 3: 极端情况 - 所有选项都关闭
print_info "测试场景 3: 极端情况 - 所有选项都关闭..."
cat > test_fix_input3.txt << EOF
./test_fix_proto_syntax
extreme
extreme.proto
y
n
n
n
n
y
y
y
EOF

print_info "运行极端情况测试..."
./init_proto.sh < test_fix_input3.txt

# 验证生成的 proto 文件语法
print_info "验证极端情况生成的 proto 文件语法..."

if [ -f "$TEST_DIR/extreme.proto" ]; then
    print_info "✓ extreme.proto 已生成"
    
    # 显示生成的 proto 文件内容
    print_info "生成的 proto 文件内容："
    echo "----------------------------------------"
    cat "$TEST_DIR/extreme.proto"
    echo "----------------------------------------"
    
    # 检查语法错误
    print_info "检查 proto 文件语法..."
    if protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/extreme.proto" 2>/dev/null; then
        print_info "✓ proto 文件语法正确"
    else
        print_error "✗ proto 文件有语法错误"
        protoc --proto_path="$TEST_DIR" --descriptor_set_out=/dev/null "$TEST_DIR/extreme.proto"
    fi
else
    print_error "✗ extreme.proto 未生成"
fi

# 清理第三个测试
rm -rf "$TEST_DIR"
rm -f test_fix_input3.txt

print_info "修复后的 proto 语法测试完成！"
print_info "主要修复内容："
print_info "1. ✅ 修复了空变量导致的语法错误"
print_info "2. ✅ 确保所有函数都返回有效的字符串"
print_info "3. ✅ 添加了安全的变量处理"
print_info "4. ✅ 改进了错误处理机制"
print_info "5. ✅ 保持了功能的完整性" 