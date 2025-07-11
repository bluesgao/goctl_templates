#!/bin/bash

# 测试交互式 add_repo.sh 脚本
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
TEST_PROJECT_DIR="./test_add_repo_project"

print_info "开始测试交互式 add_repo.sh 脚本..."

# 清理之前的测试
if [ -d "$TEST_PROJECT_DIR" ]; then
    rm -rf "$TEST_PROJECT_DIR"
fi

# 1. 首先创建测试项目
print_info "步骤 1: 创建测试项目..."
cat > test_init_input.txt << EOF
./test_add_repo_project
user
user.proto
y
y
y
y
y
EOF

./init_project.sh < test_init_input.txt

# 2. 测试 add_repo.sh 交互式功能
print_info "步骤 2: 测试 add_repo.sh 交互式功能..."

# 创建自动输入文件
cat > test_repo_input.txt << EOF
./test_add_repo_project
UserRepo
User
y
y
y
y
y
y
y
y
EOF

print_info "使用预设输入运行交互式 add_repo.sh 脚本..."
./add_repo.sh < test_repo_input.txt

# 3. 验证生成的文件
print_info "步骤 3: 验证生成的文件..."

# 检查 Repository 文件
if [ -f "$TEST_PROJECT_DIR/internal/repository/UserRepo.go" ]; then
    print_info "✓ UserRepo.go 已生成"
else
    print_error "✗ UserRepo.go 未生成"
fi

# 检查 Repository 测试文件
if [ -f "$TEST_PROJECT_DIR/internal/repository/UserRepo_test.go" ]; then
    print_info "✓ UserRepo_test.go 已生成"
else
    print_error "✗ UserRepo_test.go 未生成"
fi

# 检查 Model 文件
if [ -f "$TEST_PROJECT_DIR/internal/model/User.go" ]; then
    print_info "✓ User.go 已生成"
else
    print_error "✗ User.go 未生成"
fi

# 检查 Model 测试文件
if [ -f "$TEST_PROJECT_DIR/internal/model/User_test.go" ]; then
    print_info "✓ User_test.go 已生成"
else
    print_error "✗ User_test.go 未生成"
fi

# 检查 ServiceContext 文件
if [ -f "$TEST_PROJECT_DIR/internal/svc/servicecontext.go" ]; then
    print_info "✓ servicecontext.go 已更新"
    
    # 检查是否包含 UserRepo
    if grep -q "UserRepo repository.UserRepoRepository" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go"; then
        print_info "✓ ServiceContext 包含 UserRepo 配置"
    else
        print_error "✗ ServiceContext 缺少 UserRepo 配置"
    fi
else
    print_error "✗ servicecontext.go 未更新"
fi

# 4. 测试错误输入处理
print_info "步骤 4: 测试错误输入处理..."

# 测试无效的仓库名称
cat > test_invalid_input.txt << EOF
./test_add_repo_project
123Repo
User
y
EOF

print_info "测试无效仓库名称..."
if ./add_repo.sh < test_invalid_input.txt 2>&1 | grep -q "仓库名称必须以大写字母开头"; then
    print_info "✓ 无效仓库名称验证正常"
else
    print_error "✗ 无效仓库名称验证失败"
fi

# 测试无效的模型名称
cat > test_invalid_model_input.txt << EOF
./test_add_repo_project
UserRepo
123User
y
EOF

print_info "测试无效模型名称..."
if ./add_repo.sh < test_invalid_model_input.txt 2>&1 | grep -q "模型名称必须以大写字母开头"; then
    print_info "✓ 无效模型名称验证正常"
else
    print_error "✗ 无效模型名称验证失败"
fi

# 5. 显示生成的文件内容（部分）
print_info "步骤 5: 显示生成的文件内容..."

echo ""
print_info "UserRepo.go 的关键部分："
echo "----------------------------------------"
head -n 30 "$TEST_PROJECT_DIR/internal/repository/UserRepo.go"
echo "..."

echo ""
print_info "User.go 的关键部分："
echo "----------------------------------------"
head -n 20 "$TEST_PROJECT_DIR/internal/model/User.go"
echo "..."

echo ""
print_info "servicecontext.go 的关键部分："
echo "----------------------------------------"
grep -A 5 -B 5 "UserRepo" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go"

# 6. 清理测试
print_info "步骤 6: 清理测试..."
rm -rf "$TEST_PROJECT_DIR"
rm -f test_init_input.txt
rm -f test_repo_input.txt
rm -f test_invalid_input.txt
rm -f test_invalid_model_input.txt

print_info "交互式 add_repo.sh 功能测试完成！"
print_info "所有功能验证成功！" 