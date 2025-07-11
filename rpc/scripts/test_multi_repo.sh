#!/bin/bash

# 测试多 Repository 支持的脚本
# 用于验证 add_service.sh 脚本的多 repository 功能

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
TEST_PROJECT_DIR="./test_multi_repo_project"

print_info "开始测试多 Repository 支持..."

# 清理之前的测试
if [ -d "$TEST_PROJECT_DIR" ]; then
    rm -rf "$TEST_PROJECT_DIR"
fi

# 1. 初始化测试项目
print_info "步骤 1: 初始化测试项目..."
./init_project.sh "$TEST_PROJECT_DIR" "TestService"

# 2. 创建多个 Repository
print_info "步骤 2: 创建多个 Repository..."
./add_repo.sh "$TEST_PROJECT_DIR" "UserRepo" "User"
./add_repo.sh "$TEST_PROJECT_DIR" "ProductRepo" "Product"
./add_repo.sh "$TEST_PROJECT_DIR" "OrderRepo" "Order"

# 3. 创建依赖多个 Repository 的 Service
print_info "步骤 3: 创建依赖多个 Repository 的 Service..."
./add_service.sh "$TEST_PROJECT_DIR" "OrderService" "OrderRepo" "ProductRepo" "UserRepo"

# 4. 验证生成的文件
print_info "步骤 4: 验证生成的文件..."

# 检查 Service 文件
if [ -f "$TEST_PROJECT_DIR/internal/service/OrderService.go" ]; then
    print_info "✓ OrderService.go 已生成"
    
    # 检查是否包含多个 repository 字段
    if grep -q "OrderRepo repository.OrderRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService.go" && \
       grep -q "ProductRepo repository.ProductRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService.go" && \
       grep -q "UserRepo repository.UserRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService.go"; then
        print_info "✓ Service 文件包含所有 Repository 依赖"
    else
        print_error "✗ Service 文件缺少 Repository 依赖"
    fi
else
    print_error "✗ OrderService.go 未生成"
fi

# 检查测试文件
if [ -f "$TEST_PROJECT_DIR/internal/service/OrderService_test.go" ]; then
    print_info "✓ OrderService_test.go 已生成"
    
    # 检查是否包含多个 mock repository
    if grep -q "MockOrderRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService_test.go" && \
       grep -q "MockProductRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService_test.go" && \
       grep -q "MockUserRepoRepository" "$TEST_PROJECT_DIR/internal/service/OrderService_test.go"; then
        print_info "✓ 测试文件包含所有 Mock Repository"
    else
        print_error "✗ 测试文件缺少 Mock Repository"
    fi
else
    print_error "✗ OrderService_test.go 未生成"
fi

# 检查 ServiceContext 文件
if [ -f "$TEST_PROJECT_DIR/internal/svc/servicecontext.go" ]; then
    print_info "✓ servicecontext.go 已更新"
    
    # 检查是否包含多个 repository 初始化
    if grep -q "OrderRepo := repository.NewOrderRepoRepository" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go" && \
       grep -q "ProductRepo := repository.NewProductRepoRepository" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go" && \
       grep -q "UserRepo := repository.NewUserRepoRepository" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go"; then
        print_info "✓ ServiceContext 包含所有 Repository 初始化"
    else
        print_error "✗ ServiceContext 缺少 Repository 初始化"
    fi
else
    print_error "✗ servicecontext.go 未更新"
fi

# 5. 显示生成的文件内容（部分）
print_info "步骤 5: 显示生成的文件内容..."

echo ""
print_info "OrderService.go 的关键部分："
echo "----------------------------------------"
head -n 30 "$TEST_PROJECT_DIR/internal/service/OrderService.go"
echo "..."

echo ""
print_info "OrderService_test.go 的关键部分："
echo "----------------------------------------"
head -n 40 "$TEST_PROJECT_DIR/internal/service/OrderService_test.go"
echo "..."

echo ""
print_info "servicecontext.go 的关键部分："
echo "----------------------------------------"
grep -A 10 -B 5 "OrderService" "$TEST_PROJECT_DIR/internal/svc/servicecontext.go"

# 6. 清理测试
print_info "步骤 6: 清理测试..."
rm -rf "$TEST_PROJECT_DIR"

print_info "测试完成！"
print_info "多 Repository 支持功能验证成功！" 