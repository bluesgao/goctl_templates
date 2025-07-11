#!/bin/bash

# 新增 Service 脚本
# 用于在现有 RPC 项目中添加新的 Service 层

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

# 检查参数
if [ $# -lt 3 ]; then
    print_error "用法: $0 <project_dir> <service_name> <repo_name1> [repo_name2] [repo_name3] ..."
    echo "示例: $0 ./user UserService UserRepo"
    echo "示例: $0 ./user OrderService OrderRepo ProductRepo UserRepo"
    exit 1
fi

PROJECT_DIR=$1
SERVICE_NAME=$2
shift 2  # 移除前两个参数，剩下的都是 repo_names

# 收集所有的 repository 名称
REPO_NAMES=("$@")
REPO_COUNT=${#REPO_NAMES[@]}

print_info "开始添加新的 Service..."
print_info "项目目录: $PROJECT_DIR"
print_info "服务名称: $SERVICE_NAME"
print_info "依赖的 Repository 数量: $REPO_COUNT"
print_info "Repository 列表: ${REPO_NAMES[*]}"

print_info "开始添加新的 Service..."
print_info "项目目录: $PROJECT_DIR"
print_info "服务名称: $SERVICE_NAME"
print_info "仓库名称: $REPO_NAME"

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

# 检查service目录是否存在
if [ ! -d "$PROJECT_DIR/internal/service" ]; then
    print_error "Service 目录不存在，请先运行 init_project.sh 初始化项目"
    exit 1
fi

# 1. 生成 Service 层
print_info "步骤 1: 生成 Service 层..."

# 生成 repository 字段
REPO_FIELDS=""
for repo_name in "${REPO_NAMES[@]}"; do
    REPO_FIELDS="${REPO_FIELDS}\t${repo_name}Repo repository.${repo_name}Repository\n"
done

# 生成构造函数参数
CTOR_PARAMS=""
for repo_name in "${REPO_NAMES[@]}"; do
    if [ -n "$CTOR_PARAMS" ]; then
        CTOR_PARAMS="${CTOR_PARAMS}, "
    fi
    CTOR_PARAMS="${CTOR_PARAMS}${repo_name}Repo repository.${repo_name}Repository"
done

# 生成构造函数赋值
CTOR_ASSIGNMENTS=""
for repo_name in "${REPO_NAMES[@]}"; do
    CTOR_ASSIGNMENTS="${CTOR_ASSIGNMENTS}\t\t${repo_name}Repo: ${repo_name}Repo,\n"
done

cat > "$PROJECT_DIR/internal/service/${SERVICE_NAME}.go" << EOF
package service

import (
	"context"
	"encoding/json"

	"github.com/zeromicro/go-zero/core/logx"
	"$(basename $PROJECT_DIR)/types"
	"$(basename $PROJECT_DIR)/internal/repository"
	"$(basename $PROJECT_DIR)/internal/util"
)

type ${SERVICE_NAME} struct {
${REPO_FIELDS}	logx.Logger
}

func New${SERVICE_NAME}(${CTOR_PARAMS}) *${SERVICE_NAME} {
	return &${SERVICE_NAME}{
${CTOR_ASSIGNMENTS}		Logger: logx.WithContext(context.Background()),
	}
}

// validateBusinessRules 验证业务规则
func (s *${SERVICE_NAME}) validateBusinessRules(ctx context.Context, req interface{}) error {
	// TODO: 根据实际业务需求添加业务规则验证逻辑
	return nil
}

// prepareData 准备数据
func (s *${SERVICE_NAME}) prepareData(ctx context.Context, req interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据准备逻辑
	return nil, nil
}
EOF

# 2. 生成 Service 测试文件
print_info "步骤 2: 生成 Service 测试文件..."

# 生成 Mock Repository 定义
MOCK_REPO_DEFINITIONS=""
for repo_name in "${REPO_NAMES[@]}"; do
    MOCK_REPO_DEFINITIONS="${MOCK_REPO_DEFINITIONS}
// Mock${repo_name}Repository 模拟 Repository
type Mock${repo_name}Repository struct {
	mock.Mock
}

func (m *Mock${repo_name}Repository) Create(ctx context.Context, data interface{}) (interface{}, error) {
	args := m.Called(ctx, data)
	return args.Get(0), args.Error(1)
}

func (m *Mock${repo_name}Repository) Get(ctx context.Context, id string) (interface{}, error) {
	args := m.Called(ctx, id)
	return args.Get(0), args.Error(1)
}

func (m *Mock${repo_name}Repository) Update(ctx context.Context, data interface{}) error {
	args := m.Called(ctx, data)
	return args.Error(0)
}

func (m *Mock${repo_name}Repository) Delete(ctx context.Context, id string) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}
"
done

# 生成测试构造函数参数
TEST_CTOR_PARAMS=""
for repo_name in "${REPO_NAMES[@]}"; do
    if [ -n "$TEST_CTOR_PARAMS" ]; then
        TEST_CTOR_PARAMS="${TEST_CTOR_PARAMS}, "
    fi
    TEST_CTOR_PARAMS="${TEST_CTOR_PARAMS}mock${repo_name}Repo"
done

# 生成测试断言
TEST_ASSERTIONS=""
for repo_name in "${REPO_NAMES[@]}"; do
    TEST_ASSERTIONS="${TEST_ASSERTIONS}\tassert.Equal(t, mock${repo_name}Repo, service.${repo_name}Repo)\n"
done

cat > "$PROJECT_DIR/internal/service/${SERVICE_NAME}_test.go" << EOF
package service

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"$(basename $PROJECT_DIR)/internal/repository"
)

${MOCK_REPO_DEFINITIONS}
func TestNew${SERVICE_NAME}(t *testing.T) {
$(for repo_name in "${REPO_NAMES[@]}"; do echo -e "\tmock${repo_name}Repo := &Mock${repo_name}Repository{}"; done)
	service := New${SERVICE_NAME}(${TEST_CTOR_PARAMS})
	
	assert.NotNil(t, service)
${TEST_ASSERTIONS}
}

// TODO: 添加更多测试用例
// func Test${SERVICE_NAME}_CreateUser(t *testing.T) {
$(for repo_name in "${REPO_NAMES[@]}"; do echo -e "//     mock${repo_name}Repo := &Mock${repo_name}Repository{}"; done)
//     service := New${SERVICE_NAME}(${TEST_CTOR_PARAMS})
//     
//     // 设置模拟行为
$(for repo_name in "${REPO_NAMES[@]}"; do echo -e "//     mock${repo_name}Repo.On(\"Create\", mock.Anything, mock.Anything).Return(nil, nil)"; done)
//     
//     // 执行测试
//     // result, err := service.CreateUser(context.Background(), &types.CreateUserRequest{})
//     
//     // 验证结果
//     // assert.NoError(t, err)
//     // assert.NotNil(t, result)
$(for repo_name in "${REPO_NAMES[@]}"; do echo -e "//     mock${repo_name}Repo.AssertExpectations(t)"; done)
// }
EOF

# 3. 更新 ServiceContext（如果存在）
print_info "步骤 3: 更新 ServiceContext..."
if [ -f "$PROJECT_DIR/internal/svc/servicecontext.go" ]; then
    # 备份原文件
    cp "$PROJECT_DIR/internal/svc/servicecontext.go" "$PROJECT_DIR/internal/svc/servicecontext.go.bak"
    
    # 生成 Repository 字段
    SC_REPO_FIELDS=""
    for repo_name in "${REPO_NAMES[@]}"; do
        SC_REPO_FIELDS="${SC_REPO_FIELDS}\t${repo_name}Repo repository.${repo_name}Repository\n"
    done
    
    # 生成 Repository 初始化
    SC_REPO_INIT=""
    for repo_name in "${REPO_NAMES[@]}"; do
        SC_REPO_INIT="${SC_REPO_INIT}\t${repo_name}Repo := repository.New${repo_name}Repository(db)\n"
    done
    
    # 生成 Service 构造函数参数
    SC_SERVICE_CTOR_PARAMS=""
    for repo_name in "${REPO_NAMES[@]}"; do
        if [ -n "$SC_SERVICE_CTOR_PARAMS" ]; then
            SC_SERVICE_CTOR_PARAMS="${SC_SERVICE_CTOR_PARAMS}, "
        fi
        SC_SERVICE_CTOR_PARAMS="${SC_SERVICE_CTOR_PARAMS}${repo_name}Repo"
    done
    
    # 生成 ServiceContext 字段赋值
    SC_FIELD_ASSIGNMENTS=""
    for repo_name in "${REPO_NAMES[@]}"; do
        SC_FIELD_ASSIGNMENTS="${SC_FIELD_ASSIGNMENTS}\t\t${repo_name}Repo: ${repo_name}Repo,\n"
    done
    
    # 读取原文件内容并添加新的Service
    cat > "$PROJECT_DIR/internal/svc/servicecontext.go" << EOF
package svc

import (
	"$(basename $PROJECT_DIR)/internal/config"
	"$(basename $PROJECT_DIR)/internal/repository"
	"$(basename $PROJECT_DIR)/internal/service"
	"github.com/zeromicro/go-zero/core/stores/redis"
	"gorm.io/gorm"
)

type ServiceContext struct {
	Config config.Config
	// 数据库连接
	DB *gorm.DB
	// Redis 连接
	Redis redis.Redis
	
	// Repository 层
${SC_REPO_FIELDS}
	// Service 层
	${SERVICE_NAME} *service.${SERVICE_NAME}
}

func NewServiceContext(c config.Config) *ServiceContext {
	// 初始化数据库连接
	db := initDB(c)
	
	// 初始化 Redis 连接
	redisClient := initRedis(c)
	
	// 初始化 Repository 层
${SC_REPO_INIT}
	
	// 初始化 Service 层
	${SERVICE_NAME} := service.New${SERVICE_NAME}(${SC_SERVICE_CTOR_PARAMS})
	
	return &ServiceContext{
		Config:      c,
		DB:          db,
		Redis:       redisClient,
${SC_FIELD_ASSIGNMENTS}		${SERVICE_NAME}: ${SERVICE_NAME},
	}
}

// initDB 初始化数据库连接
func initDB(c config.Config) *gorm.DB {
	// TODO: 根据实际配置初始化数据库连接
	return nil
}

// initRedis 初始化 Redis 连接
func initRedis(c config.Config) redis.Redis {
	// TODO: 根据实际配置初始化 Redis 连接
	return nil
}
EOF
    print_info "ServiceContext 已更新"
else
    print_warn "ServiceContext 文件不存在，跳过更新"
fi

print_info "Service 添加完成！"
print_info "生成的文件："
print_info "1. $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"
print_info "2. $PROJECT_DIR/internal/service/${SERVICE_NAME}_test.go"
print_info "3. $PROJECT_DIR/internal/svc/servicecontext.go (已更新)"

print_info "依赖的 Repository："
for repo_name in "${REPO_NAMES[@]}"; do
    print_info "   - ${repo_name}Repository"
done

print_warn "请根据实际业务需求完善以下内容："
print_warn "1. 在 ${SERVICE_NAME}.go 中实现具体的业务逻辑方法"
print_warn "2. 在 ${SERVICE_NAME}_test.go 中添加测试用例"
print_warn "3. 在 servicecontext.go 中配置数据库和Redis连接"
print_warn "4. 确保所有依赖的 Repository 都已创建" 