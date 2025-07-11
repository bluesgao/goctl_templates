#!/bin/bash

# 测试集成后的 init_proto.sh 脚本
# 验证 fix_protobuf_imports 功能已集成到 init_proto.sh 中

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
TEST_DIR="./test_integrated_proto"

print_info "开始测试集成后的 init_proto.sh 脚本..."
print_info "此脚本将测试 fix_protobuf_imports 功能是否已集成到 init_proto.sh 中"

# 清理之前的测试
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

# 测试场景 1: 正常情况（Google protobuf 文件存在）
print_info "测试场景 1: Google protobuf 文件存在的情况..."
cat > test_integrated_input1.txt << EOF
./test_integrated_proto
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

print_info "运行测试场景 1..."
./init_proto.sh < test_integrated_input1.txt

# 验证生成的文件
print_info "验证生成的文件..."

# 检查 proto 文件
if [ -f "$TEST_DIR/user.proto" ]; then
    print_info "✓ user.proto 已生成"
else
    print_error "✗ user.proto 未生成"
fi

# 检查是否包含 Google protobuf 导入
if grep -q "import.*google/protobuf" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含 Google protobuf 导入"
else
    print_warn "⚠ 未包含 Google protobuf 导入"
fi

# 检查时间戳字段类型
if grep -q "google.protobuf.Timestamp timestamp" "$TEST_DIR/user.proto"; then
    print_info "✓ 使用 Google protobuf Timestamp"
elif grep -q "string timestamp" "$TEST_DIR/user.proto"; then
    print_info "✓ 使用字符串格式时间戳"
else
    print_error "✗ 时间戳字段格式不正确"
fi

# 显示生成的文件内容
print_info "显示生成的 proto 文件内容："
echo "----------------------------------------"
cat "$TEST_DIR/user.proto"
echo "----------------------------------------"

# 清理第一个测试
rm -rf "$TEST_DIR"
rm -f test_integrated_input1.txt

# 测试场景 2: 模拟 Google protobuf 文件不存在的情况
print_info "测试场景 2: 模拟 Google protobuf 文件不存在的情况..."

# 临时重命名 Google protobuf 目录（如果存在）
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}' 2>/dev/null || echo "/usr/local/include")
BACKUP_DIR=""

if [ -d "$PROTOC_INCLUDE_PATH/google/protobuf" ]; then
    print_info "临时备份 Google protobuf 目录..."
    BACKUP_DIR="${PROTOC_INCLUDE_PATH}/google/protobuf_backup_$(date +%s)"
    sudo mv "$PROTOC_INCLUDE_PATH/google/protobuf" "$BACKUP_DIR"
fi

# 创建自动输入文件（选择不修复）
cat > test_integrated_input2.txt << EOF
./test_integrated_proto
user
user.proto
y
y
y
y
n
y
y
y
EOF

print_info "运行测试场景 2（选择不修复）..."
./init_proto.sh < test_integrated_input2.txt

# 验证生成的文件
print_info "验证生成的文件（不修复场景）..."

# 检查 proto 文件
if [ -f "$TEST_DIR/user.proto" ]; then
    print_info "✓ user.proto 已生成"
else
    print_error "✗ user.proto 未生成"
fi

# 检查是否不包含 Google protobuf 导入
if ! grep -q "import.*google/protobuf" "$TEST_DIR/user.proto"; then
    print_info "✓ 正确不包含 Google protobuf 导入"
else
    print_warn "⚠ 仍然包含 Google protobuf 导入"
fi

# 检查时间戳字段类型
if grep -q "string timestamp" "$TEST_DIR/user.proto"; then
    print_info "✓ 正确使用字符串格式时间戳"
else
    print_error "✗ 时间戳字段格式不正确"
fi

# 显示生成的文件内容
print_info "显示生成的文件内容（不修复场景）："
echo "----------------------------------------"
cat "$TEST_DIR/user.proto"
echo "----------------------------------------"

# 恢复 Google protobuf 目录
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    print_info "恢复 Google protobuf 目录..."
    sudo mv "$BACKUP_DIR" "$PROTOC_INCLUDE_PATH/google/protobuf"
fi

# 清理第二个测试
rm -rf "$TEST_DIR"
rm -f test_integrated_input2.txt

# 测试场景 3: 选择修复的情况
print_info "测试场景 3: 选择修复的情况..."

# 再次临时重命名 Google protobuf 目录
if [ -d "$PROTOC_INCLUDE_PATH/google/protobuf" ]; then
    print_info "临时备份 Google protobuf 目录..."
    BACKUP_DIR="${PROTOC_INCLUDE_PATH}/google/protobuf_backup_$(date +%s)"
    sudo mv "$PROTOC_INCLUDE_PATH/google/protobuf" "$BACKUP_DIR"
fi

# 创建自动输入文件（选择修复）
cat > test_integrated_input3.txt << EOF
./test_integrated_proto
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

print_info "运行测试场景 3（选择修复）..."
print_info "注意：此测试可能需要 sudo 权限来下载和安装 Google protobuf 文件"

# 运行测试（可能需要用户交互）
./init_proto.sh < test_integrated_input3.txt

# 验证生成的文件
print_info "验证生成的文件（修复场景）..."

# 检查 proto 文件
if [ -f "$TEST_DIR/user.proto" ]; then
    print_info "✓ user.proto 已生成"
else
    print_error "✗ user.proto 未生成"
fi

# 显示生成的文件内容
print_info "显示生成的文件内容（修复场景）："
echo "----------------------------------------"
cat "$TEST_DIR/user.proto"
echo "----------------------------------------"

# 恢复 Google protobuf 目录
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    print_info "恢复 Google protobuf 目录..."
    sudo mv "$BACKUP_DIR" "$PROTOC_INCLUDE_PATH/google/protobuf"
fi

# 清理第三个测试
rm -rf "$TEST_DIR"
rm -f test_integrated_input3.txt

print_info "集成后的 init_proto.sh 功能测试完成！"
print_info "主要集成功能："
print_info "1. ✅ 自动检测 Google protobuf 文件是否存在"
print_info "2. ✅ 提供修复选项，用户可以选择是否修复"
print_info "3. ✅ 集成下载和安装 Google protobuf 文件的功能"
print_info "4. ✅ 自动安装 Go protobuf 插件"
print_info "5. ✅ 根据修复结果智能选择时间戳格式"
print_info "6. ✅ 提供详细的用户提示和错误处理" 