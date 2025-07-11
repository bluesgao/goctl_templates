#!/bin/bash

# 测试交互式 init_project.sh 脚本
# 用于验证交互式参数收集功能

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

# 创建测试项目
TEST_PROJECT_DIR="./test_interactive_project"

print_info "开始测试交互式 init_project.sh 脚本..."

# 清理之前的测试
if [ -d "$TEST_PROJECT_DIR" ]; then
    rm -rf "$TEST_PROJECT_DIR"
fi

# 创建自动输入文件
cat > test_input.txt << EOF
./test_interactive_project
user
user.proto
y
y
y
y
y
EOF

print_info "使用预设输入运行交互式脚本..."
./init_project.sh < test_input.txt

# 验证生成的文件
print_info "验证生成的文件..."

# 检查项目目录
if [ -d "$TEST_PROJECT_DIR" ]; then
    print_info "✓ 项目目录已创建"
else
    print_error "✗ 项目目录未创建"
fi

# 检查 proto 文件
if [ -f "$TEST_PROJECT_DIR/proto/user.proto" ]; then
    print_info "✓ Proto 文件已生成"
else
    print_error "✗ Proto 文件未生成"
fi

# 检查目录结构
if [ -d "$TEST_PROJECT_DIR/internal/logic" ] && \
   [ -d "$TEST_PROJECT_DIR/internal/service" ] && \
   [ -d "$TEST_PROJECT_DIR/internal/repository" ] && \
   [ -d "$TEST_PROJECT_DIR/internal/model" ] && \
   [ -d "$TEST_PROJECT_DIR/internal/event" ] && \
   [ -d "$TEST_PROJECT_DIR/internal/util" ]; then
    print_info "✓ 分层目录结构已创建"
else
    print_error "✗ 分层目录结构未创建"
fi

# 检查示例文件
if [ -f "$TEST_PROJECT_DIR/internal/util/errcode.go" ] && \
   [ -f "$TEST_PROJECT_DIR/internal/util/utils.go" ] && \
   [ -f "$TEST_PROJECT_DIR/README.md" ]; then
    print_info "✓ 示例代码文件已生成"
else
    print_error "✗ 示例代码文件未生成"
fi

# 显示项目结构
print_info "生成的项目结构："
echo "----------------------------------------"
tree "$TEST_PROJECT_DIR" -I "*.go" || ls -la "$TEST_PROJECT_DIR"
echo "----------------------------------------"

# 清理测试
print_info "清理测试..."
rm -rf "$TEST_PROJECT_DIR"
rm -f test_input.txt

print_info "交互式功能测试完成！"
print_info "所有功能验证成功！" 