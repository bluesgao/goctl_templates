#!/bin/bash

# 测试修复后的 init_proto.sh 脚本
# 用于验证修复后的功能

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
TEST_DIR="./test_proto_fixed"

print_info "开始测试修复后的 init_proto.sh 脚本..."

# 清理之前的测试
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

# 创建自动输入文件
cat > test_proto_fixed_input.txt << EOF
./test_proto_fixed
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

print_info "使用预设输入运行 init_proto.sh 脚本..."
./init_proto.sh < test_proto_fixed_input.txt

# 验证生成的文件
print_info "验证生成的文件..."

# 检查 proto 文件
if [ -f "$TEST_DIR/user.proto" ]; then
    print_info "✓ user.proto 已生成"
else
    print_error "✗ user.proto 未生成"
fi

# 检查 README 文件
if [ -f "$TEST_DIR/README.md" ]; then
    print_info "✓ README.md 已生成"
else
    print_error "✗ README.md 未生成"
fi

# 检查编译脚本
if [ -f "$TEST_DIR/compile.sh" ]; then
    print_info "✓ compile.sh 已生成"
else
    print_error "✗ compile.sh 未生成"
fi

# 验证 proto 文件内容
print_info "验证 proto 文件内容..."

# 检查是否包含 Hello 方法
if grep -q "rpc Hello" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含 Hello 方法"
else
    print_error "✗ 缺少 Hello 方法"
fi

# 检查是否包含 HelloRequest
if grep -q "message HelloRequest" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含 HelloRequest 消息"
else
    print_error "✗ 缺少 HelloRequest 消息"
fi

# 检查是否包含 HelloResponse
if grep -q "message HelloResponse" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含 HelloResponse 消息"
else
    print_error "✗ 缺少 HelloResponse 消息"
fi

# 检查时间戳字段类型
if grep -q "string timestamp" "$TEST_DIR/user.proto"; then
    print_info "✓ 使用字符串格式的时间戳"
else
    print_error "✗ 时间戳格式不正确"
fi

# 检查是否包含 Google protobuf 导入
if grep -q "import.*google/protobuf" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含 Google protobuf 导入"
else
    print_warn "⚠ 未包含 Google protobuf 导入（这是正常的，如果文件不存在）"
fi

# 显示生成的文件内容
print_info "显示生成的 proto 文件内容："
echo "----------------------------------------"
cat "$TEST_DIR/user.proto"
echo "----------------------------------------"

# 测试编译功能
print_info "测试编译功能..."
cd "$TEST_DIR"

# 检查 protoc 是否可用
if command -v protoc &> /dev/null; then
    print_info "protoc 已安装，测试编译..."
    
    # 安装 Go 插件（如果需要）
    if ! command -v protoc-gen-go &> /dev/null; then
        print_warn "安装 protoc-gen-go..."
        go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    fi
    
    if ! command -v protoc-gen-go-grpc &> /dev/null; then
        print_warn "安装 protoc-gen-go-grpc..."
        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    fi
    
    # 运行编译脚本
    if ./compile.sh; then
        print_info "✓ 编译成功"
        
        # 检查生成的文件
        if [ -f "types/user.pb.go" ]; then
            print_info "✓ 生成了 user.pb.go"
        fi
        
        if [ -f "types/user_grpc.pb.go" ]; then
            print_info "✓ 生成了 user_grpc.pb.go"
        fi
    else
        print_error "✗ 编译失败"
        print_info "这可能是因为缺少 Google protobuf 文件"
        print_info "可以运行 ./fix_protobuf_imports.sh 来修复"
    fi
else
    print_warn "protoc 未安装，跳过编译测试"
fi

cd ..

# 清理测试
print_info "清理测试..."
rm -rf "$TEST_DIR"
rm -f test_proto_fixed_input.txt

print_info "修复后的 init_proto.sh 功能测试完成！"
print_info "主要修复内容："
print_info "1. 自动检测 Google protobuf 文件是否存在"
print_info "2. 如果不存在，自动使用字符串格式的时间戳"
print_info "3. 提供修复脚本的提示信息"
print_info "4. 增强了错误处理和用户提示" 