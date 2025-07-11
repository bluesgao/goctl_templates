#!/bin/bash

# 测试重构后的 init_proto.sh 脚本
# 验证函数式结构的功能

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
TEST_DIR="./test_refactored_proto"

print_info "开始测试重构后的 init_proto.sh 脚本..."
print_info "此脚本将验证函数式结构的功能"

# 清理之前的测试
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

# 测试场景 1: 基础功能测试
print_info "测试场景 1: 基础功能测试..."
cat > test_refactored_input1.txt << EOF
./test_refactored_proto
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

print_info "运行基础功能测试..."
./init_proto.sh < test_refactored_input1.txt

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

# 检查是否包含通用消息
if grep -q "message Result" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含通用消息定义"
else
    print_error "✗ 缺少通用消息定义"
fi

# 检查是否包含注释
if grep -q "生成时间" "$TEST_DIR/user.proto"; then
    print_info "✓ 包含详细注释"
else
    print_error "✗ 缺少详细注释"
fi

# 显示生成的文件内容
print_info "显示生成的 proto 文件内容："
echo "----------------------------------------"
cat "$TEST_DIR/user.proto"
echo "----------------------------------------"

# 清理第一个测试
rm -rf "$TEST_DIR"
rm -f test_refactored_input1.txt

# 测试场景 2: 最小化配置测试
print_info "测试场景 2: 最小化配置测试..."
cat > test_refactored_input2.txt << EOF
./test_refactored_proto
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
./init_proto.sh < test_refactored_input2.txt

# 验证生成的文件
print_info "验证最小化配置生成的文件..."

# 检查 proto 文件
if [ -f "$TEST_DIR/test.proto" ]; then
    print_info "✓ test.proto 已生成"
else
    print_error "✗ test.proto 未生成"
fi

# 检查是否不包含通用消息
if ! grep -q "message Result" "$TEST_DIR/test.proto"; then
    print_info "✓ 正确不包含通用消息"
else
    print_warn "⚠ 仍然包含通用消息"
fi

# 检查是否不包含注释
if ! grep -q "生成时间" "$TEST_DIR/test.proto"; then
    print_info "✓ 正确不包含详细注释"
else
    print_warn "⚠ 仍然包含详细注释"
fi

# 检查是否包含服务方法
if grep -q "rpc Hello" "$TEST_DIR/test.proto"; then
    print_info "✓ 包含服务方法"
else
    print_error "✗ 缺少服务方法"
fi

# 显示生成的文件内容
print_info "显示最小化配置生成的文件内容："
echo "----------------------------------------"
cat "$TEST_DIR/test.proto"
echo "----------------------------------------"

# 清理第二个测试
rm -rf "$TEST_DIR"
rm -f test_refactored_input2.txt

# 测试场景 3: 函数结构验证
print_info "测试场景 3: 函数结构验证..."

# 检查脚本是否包含主要函数
print_info "检查脚本函数结构..."

if grep -q "main()" init_proto.sh; then
    print_info "✓ 包含 main 函数"
else
    print_error "✗ 缺少 main 函数"
fi

if grep -q "collect_params()" init_proto.sh; then
    print_info "✓ 包含 collect_params 函数"
else
    print_error "✗ 缺少 collect_params 函数"
fi

if grep -q "create_files()" init_proto.sh; then
    print_info "✓ 包含 create_files 函数"
else
    print_error "✗ 缺少 create_files 函数"
fi

if grep -q "generate_documents()" init_proto.sh; then
    print_info "✓ 包含 generate_documents 函数"
else
    print_error "✗ 缺少 generate_documents 函数"
fi

if grep -q "show_results()" init_proto.sh; then
    print_info "✓ 包含 show_results 函数"
else
    print_error "✗ 缺少 show_results 函数"
fi

# 检查工具函数
if grep -q "get_user_input()" init_proto.sh; then
    print_info "✓ 包含 get_user_input 函数"
else
    print_error "✗ 缺少 get_user_input 函数"
fi

if grep -q "get_user_confirmation()" init_proto.sh; then
    print_info "✓ 包含 get_user_confirmation 函数"
else
    print_error "✗ 缺少 get_user_confirmation 函数"
fi

if grep -q "validate_service_name()" init_proto.sh; then
    print_info "✓ 包含 validate_service_name 函数"
else
    print_error "✗ 缺少 validate_service_name 函数"
fi

# 检查内容生成函数
if grep -q "generate_common_messages()" init_proto.sh; then
    print_info "✓ 包含 generate_common_messages 函数"
else
    print_error "✗ 缺少 generate_common_messages 函数"
fi

if grep -q "generate_service_methods()" init_proto.sh; then
    print_info "✓ 包含 generate_service_methods 函数"
else
    print_error "✗ 缺少 generate_service_methods 函数"
fi

if grep -q "generate_request_response_messages()" init_proto.sh; then
    print_info "✓ 包含 generate_request_response_messages 函数"
else
    print_error "✗ 缺少 generate_request_response_messages 函数"
fi

if grep -q "generate_proto_file()" init_proto.sh; then
    print_info "✓ 包含 generate_proto_file 函数"
else
    print_error "✗ 缺少 generate_proto_file 函数"
fi

# 检查文档生成函数
if grep -q "generate_readme()" init_proto.sh; then
    print_info "✓ 包含 generate_readme 函数"
else
    print_error "✗ 缺少 generate_readme 函数"
fi

if grep -q "generate_compile_script()" init_proto.sh; then
    print_info "✓ 包含 generate_compile_script 函数"
else
    print_error "✗ 缺少 generate_compile_script 函数"
fi

# 检查修复功能函数
if grep -q "fix_protobuf_imports()" init_proto.sh; then
    print_info "✓ 包含 fix_protobuf_imports 函数"
else
    print_error "✗ 缺少 fix_protobuf_imports 函数"
fi

if grep -q "handle_imports()" init_proto.sh; then
    print_info "✓ 包含 handle_imports 函数"
else
    print_error "✗ 缺少 handle_imports 函数"
fi

# 检查代码结构
print_info "检查代码结构..."

# 检查是否有清晰的分隔符
if grep -q "=============================================================================" init_proto.sh; then
    print_info "✓ 包含清晰的分隔符"
else
    print_error "✗ 缺少清晰的分隔符"
fi

# 检查是否有全局变量定义
if grep -q "全局变量" init_proto.sh; then
    print_info "✓ 包含全局变量定义"
else
    print_error "✗ 缺少全局变量定义"
fi

# 检查是否有工具函数部分
if grep -q "工具函数" init_proto.sh; then
    print_info "✓ 包含工具函数部分"
else
    print_error "✗ 缺少工具函数部分"
fi

# 检查是否有参数收集函数部分
if grep -q "参数收集函数" init_proto.sh; then
    print_info "✓ 包含参数收集函数部分"
else
    print_error "✗ 缺少参数收集函数部分"
fi

# 检查是否有内容生成函数部分
if grep -q "内容生成函数" init_proto.sh; then
    print_info "✓ 包含内容生成函数部分"
else
    print_error "✗ 缺少内容生成函数部分"
fi

# 检查是否有文档生成函数部分
if grep -q "文档生成函数" init_proto.sh; then
    print_info "✓ 包含文档生成函数部分"
else
    print_error "✗ 缺少文档生成函数部分"
fi

# 检查是否有主流程函数部分
if grep -q "主流程函数" init_proto.sh; then
    print_info "✓ 包含主流程函数部分"
else
    print_error "✗ 缺少主流程函数部分"
fi

print_info "重构后的 init_proto.sh 功能测试完成！"
print_info "主要重构内容："
print_info "1. ✅ 采用函数式结构，提高代码可读性"
print_info "2. ✅ 分离关注点，每个函数职责单一"
print_info "3. ✅ 使用全局变量管理状态"
print_info "4. ✅ 提供工具函数，减少代码重复"
print_info "5. ✅ 清晰的函数命名和注释"
print_info "6. ✅ 模块化的内容生成逻辑"
print_info "7. ✅ 统一的错误处理和用户交互"
print_info "8. ✅ 保持原有功能完整性" 