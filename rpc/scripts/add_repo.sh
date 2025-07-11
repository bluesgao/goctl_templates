#!/bin/bash

# 新增 Repository 脚本
# 用于在现有 RPC 项目中添加新的 Repository 层和 Model 层

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

# 交互式参数收集
print_info "欢迎使用 Repository 添加脚本！"
echo ""

# 获取项目目录
while true; do
    read -p "请输入项目目录 (例如: ./user): " PROJECT_DIR
    if [ -n "$PROJECT_DIR" ]; then
        if [ -d "$PROJECT_DIR" ]; then
            break
        else
            print_error "项目目录不存在: $PROJECT_DIR"
            read -p "是否继续？(y/n): " CONTINUE
            case $CONTINUE in
                [Yy]* ) break;;
                [Nn]* ) exit 1;;
                * ) echo "请输入 y 或 n";;
            esac
        fi
    else
        print_error "项目目录不能为空，请重新输入"
    fi
done

# 获取仓库名称
while true; do
    read -p "请输入仓库名称 (例如: UserRepo): " REPO_NAME
    if [ -n "$REPO_NAME" ]; then
        # 检查仓库名称格式
        if [[ "$REPO_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
            break
        else
            print_error "仓库名称必须以大写字母开头，只能包含字母和数字"
        fi
    else
        print_error "仓库名称不能为空，请重新输入"
    fi
done

# 获取模型名称
while true; do
    read -p "请输入模型名称 (例如: User): " MODEL_NAME
    if [ -n "$MODEL_NAME" ]; then
        # 检查模型名称格式
        if [[ "$MODEL_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
            break
        else
            print_error "模型名称必须以大写字母开头，只能包含字母和数字"
        fi
    else
        print_error "模型名称不能为空，请重新输入"
    fi
done

# 确认信息
echo ""
print_info "Repository 配置信息："
echo "----------------------------------------"
echo "项目目录: $PROJECT_DIR"
echo "仓库名称: $REPO_NAME"
echo "模型名称: $MODEL_NAME"
echo "----------------------------------------"

# 确认是否继续
while true; do
    read -p "确认添加 Repository？(y/n): " CONFIRM
    case $CONFIRM in
        [Yy]* ) break;;
        [Nn]* ) 
            print_info "已取消 Repository 添加"
            exit 0
            ;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 高级选项
echo ""
print_info "高级选项配置："

# 是否生成测试文件
while true; do
    read -p "是否生成测试文件？(y/n, 默认: y): " CREATE_TESTS
    case $CREATE_TESTS in
        [Yy]* ) CREATE_TESTS="true"; break;;
        [Nn]* ) CREATE_TESTS="false"; break;;
        "" ) CREATE_TESTS="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含数据库操作示例
while true; do
    read -p "是否包含数据库操作示例？(y/n, 默认: y): " INCLUDE_DB_EXAMPLES
    case $INCLUDE_DB_EXAMPLES in
        [Yy]* ) INCLUDE_DB_EXAMPLES="true"; break;;
        [Nn]* ) INCLUDE_DB_EXAMPLES="false"; break;;
        "" ) INCLUDE_DB_EXAMPLES="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含模型字段示例
while true; do
    read -p "是否包含模型字段示例？(y/n, 默认: y): " INCLUDE_MODEL_EXAMPLES
    case $INCLUDE_MODEL_EXAMPLES in
        [Yy]* ) INCLUDE_MODEL_EXAMPLES="true"; break;;
        [Nn]* ) INCLUDE_MODEL_EXAMPLES="false"; break;;
        "" ) INCLUDE_MODEL_EXAMPLES="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否更新 ServiceContext
while true; do
    read -p "是否更新 ServiceContext？(y/n, 默认: y): " UPDATE_SERVICE_CONTEXT
    case $UPDATE_SERVICE_CONTEXT in
        [Yy]* ) UPDATE_SERVICE_CONTEXT="true"; break;;
        [Nn]* ) UPDATE_SERVICE_CONTEXT="false"; break;;
        "" ) UPDATE_SERVICE_CONTEXT="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

print_info "开始添加新的 Repository..."
print_info "项目目录: $PROJECT_DIR"
print_info "仓库名称: $REPO_NAME"
print_info "模型名称: $MODEL_NAME"

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

# 检查repository目录是否存在
if [ ! -d "$PROJECT_DIR/internal/repository" ]; then
    print_error "Repository 目录不存在，请先运行 init_project.sh 初始化项目"
    exit 1
fi

# 1. 生成 Repository 层
print_info "步骤 1: 生成 Repository 层..."
cat > "$PROJECT_DIR/internal/repository/${REPO_NAME}.go" << EOF
package repository

import (
	"context"
	"encoding/json"

	"github.com/zeromicro/go-zero/core/logx"
	"$(basename $PROJECT_DIR)/internal/model"
	"$(basename $PROJECT_DIR)/internal/util"
	"gorm.io/gorm"
)

// ${REPO_NAME}Repository 定义数据访问接口
type ${REPO_NAME}Repository interface {
	Create(ctx context.Context, data interface{}) (interface{}, error)
	Get(ctx context.Context, id string) (interface{}, error)
	Update(ctx context.Context, data interface{}) error
	Delete(ctx context.Context, id string) error
	// TODO: 根据实际业务需求添加其他方法
}

// ${REPO_NAME}RepositoryImpl 实现数据访问接口
type ${REPO_NAME}RepositoryImpl struct {
	db     *gorm.DB
	logx.Logger
}

// New${REPO_NAME}Repository 创建 Repository 实例
func New${REPO_NAME}Repository(db *gorm.DB) ${REPO_NAME}Repository {
	return &${REPO_NAME}RepositoryImpl{
		db:     db,
		Logger: logx.WithContext(context.Background()),
	}
}

// Create 实现创建数据访问逻辑
func (r *${REPO_NAME}RepositoryImpl) Create(ctx context.Context, data interface{}) (interface{}, error) {
	r.Infof("${REPO_NAME}Repository.Create called with data: %+v", data)
	
	// 1. 数据验证
	if err := r.validateData(data); err != nil {
		r.Errorf("数据验证失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 2. 数据转换
	model, err := r.convertToModel(data)
	if err != nil {
		r.Errorf("数据转换失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 3. 执行数据库操作
	result, err := r.executeDatabaseOperation(ctx, model)
	if err != nil {
		r.Errorf("数据库操作失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 4. 结果转换
	response, err := r.convertToResponse(result)
	if err != nil {
		r.Errorf("结果转换失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	r.Infof("${REPO_NAME}Repository.Create completed successfully")
	return response, nil
}

// Get 实现获取数据访问逻辑
func (r *${REPO_NAME}RepositoryImpl) Get(ctx context.Context, id string) (interface{}, error) {
	r.Infof("${REPO_NAME}Repository.Get called with id: %s", id)
	
	// TODO: 实现获取逻辑
	// 1. 参数验证
	// 2. 从数据库查询
	// 3. 结果转换
	// 4. 返回结果
	
	return nil, nil
}

// Update 实现更新数据访问逻辑
func (r *${REPO_NAME}RepositoryImpl) Update(ctx context.Context, data interface{}) error {
	r.Infof("${REPO_NAME}Repository.Update called with data: %+v", data)
	
	// TODO: 实现更新逻辑
	// 1. 数据验证
	// 2. 数据转换
	// 3. 执行更新操作
	// 4. 返回结果
	
	return nil
}

// Delete 实现删除数据访问逻辑
func (r *${REPO_NAME}RepositoryImpl) Delete(ctx context.Context, id string) error {
	r.Infof("${REPO_NAME}Repository.Delete called with id: %s", id)
	
	// TODO: 实现删除逻辑
	// 1. 参数验证
	// 2. 执行删除操作
	// 3. 返回结果
	
	return nil
}

// validateData 验证数据
func (r *${REPO_NAME}RepositoryImpl) validateData(data interface{}) error {
	// TODO: 根据实际业务需求添加数据验证逻辑
	return nil
}

// convertToModel 转换为模型
func (r *${REPO_NAME}RepositoryImpl) convertToModel(data interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据转换逻辑
	return nil, nil
}

// executeDatabaseOperation 执行数据库操作
func (r *${REPO_NAME}RepositoryImpl) executeDatabaseOperation(ctx context.Context, model interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据库操作逻辑
	return nil, nil
}

// convertToResponse 转换为响应
func (r *${REPO_NAME}RepositoryImpl) convertToResponse(result interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现响应转换逻辑
	return nil, nil
}
EOF

# 2. 生成 Repository 测试文件
print_info "步骤 2: 生成 Repository 测试文件..."
if [ "$CREATE_TESTS" = "true" ]; then
    cat > "$PROJECT_DIR/internal/repository/${REPO_NAME}_test.go" << EOF
package repository

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"gorm.io/gorm"
)

// MockDB 模拟数据库
type MockDB struct {
	mock.Mock
}

func (m *MockDB) Create(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Find(dest interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(dest, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Save(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Delete(value interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(value, conds)
	return args.Get(0).(*gorm.DB)
}

func TestNew${REPO_NAME}Repository(t *testing.T) {
	mockDB := &MockDB{}
	repo := New${REPO_NAME}Repository(mockDB)
	
	assert.NotNil(t, repo)
}

// TODO: 添加更多测试用例
// func Test${REPO_NAME}RepositoryImpl_Create(t *testing.T) {
//     mockDB := &MockDB{}
//     repo := New${REPO_NAME}Repository(mockDB)
//     
//     // 设置模拟行为
//     mockDB.On("Create", mock.Anything).Return(&gorm.DB{})
//     
//     // 执行测试
//     result, err := repo.Create(context.Background(), &model.${MODEL_NAME}{})
//     
//     // 验证结果
//     assert.NoError(t, err)
//     assert.NotNil(t, result)
//     mockDB.AssertExpectations(t)
// }
EOF
fi

# 3. 生成 Model 层
print_info "步骤 3: 生成 Model 层..."
cat > "$PROJECT_DIR/internal/model/${MODEL_NAME}.go" << EOF
package model

import (
	"time"
	"gorm.io/gorm"
)

// ${MODEL_NAME} 数据模型
type ${MODEL_NAME} struct {
	ID        int64          \`json:"id" gorm:"primaryKey;autoIncrement"\`
	// TODO: 根据实际业务需求添加字段
	CreatedAt time.Time      \`json:"created_at" gorm:"autoCreateTime"\`
	UpdatedAt time.Time      \`json:"updated_at" gorm:"autoUpdateTime"\`
	DeletedAt gorm.DeletedAt \`json:"deleted_at" gorm:"index"\`
}

// TableName 指定表名
func (${MODEL_NAME}) TableName() string {
	return "${MODEL_NAME}s"
}

// BeforeCreate 创建前的钩子
func (m *${MODEL_NAME}) BeforeCreate(tx *gorm.DB) error {
	// TODO: 在创建前添加自定义逻辑
	return nil
}

// BeforeUpdate 更新前的钩子
func (m *${MODEL_NAME}) BeforeUpdate(tx *gorm.DB) error {
	// TODO: 在更新前添加自定义逻辑
	return nil
}

// BeforeDelete 删除前的钩子
func (m *${MODEL_NAME}) BeforeDelete(tx *gorm.DB) error {
	// TODO: 在删除前添加自定义逻辑
	return nil
}

// AfterCreate 创建后的钩子
func (m *${MODEL_NAME}) AfterCreate(tx *gorm.DB) error {
	// TODO: 在创建后添加自定义逻辑
	return nil
}

// AfterUpdate 更新后的钩子
func (m *${MODEL_NAME}) AfterUpdate(tx *gorm.DB) error {
	// TODO: 在更新后添加自定义逻辑
	return nil
}

// AfterDelete 删除后的钩子
func (m *${MODEL_NAME}) AfterDelete(tx *gorm.DB) error {
	// TODO: 在删除后添加自定义逻辑
	return nil
}
EOF

# 4. 生成 Model 测试文件
print_info "步骤 4: 生成 Model 测试文件..."
if [ "$CREATE_TESTS" = "true" ]; then
    cat > "$PROJECT_DIR/internal/model/${MODEL_NAME}_test.go" << EOF
package model

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func Test${MODEL_NAME}_TableName(t *testing.T) {
	model := &${MODEL_NAME}{}
	assert.Equal(t, "${MODEL_NAME}s", model.TableName())
}

func Test${MODEL_NAME}_BeforeCreate(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.BeforeCreate(nil)
	assert.NoError(t, err)
}

func Test${MODEL_NAME}_BeforeUpdate(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.BeforeUpdate(nil)
	assert.NoError(t, err)
}

func Test${MODEL_NAME}_BeforeDelete(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.BeforeDelete(nil)
	assert.NoError(t, err)
}

func Test${MODEL_NAME}_AfterCreate(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.AfterCreate(nil)
	assert.NoError(t, err)
}

func Test${MODEL_NAME}_AfterUpdate(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.AfterUpdate(nil)
	assert.NoError(t, err)
}

func Test${MODEL_NAME}_AfterDelete(t *testing.T) {
	model := &${MODEL_NAME}{}
	err := model.AfterDelete(nil)
	assert.NoError(t, err)
}
EOF
fi

# 5. 更新 ServiceContext（如果存在）
print_info "步骤 5: 更新 ServiceContext..."
if [ "$UPDATE_SERVICE_CONTEXT" = "true" ] && [ -f "$PROJECT_DIR/internal/svc/servicecontext.go" ]; then
    # 备份原文件
    cp "$PROJECT_DIR/internal/svc/servicecontext.go" "$PROJECT_DIR/internal/svc/servicecontext.go.bak"
    
    # 读取原文件内容并添加新的Repository
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
	${REPO_NAME}Repo repository.${REPO_NAME}Repository
	
	// Service 层
	// TODO: 添加对应的 Service
}

func NewServiceContext(c config.Config) *ServiceContext {
	// 初始化数据库连接
	db := initDB(c)
	
	// 初始化 Redis 连接
	redisClient := initRedis(c)
	
	// 初始化 Repository 层
	${REPO_NAME}Repo := repository.New${REPO_NAME}Repository(db)
	
	// 初始化 Service 层
	// TODO: 添加对应的 Service 初始化
	
	return &ServiceContext{
		Config:      c,
		DB:          db,
		Redis:       redisClient,
		${REPO_NAME}Repo: ${REPO_NAME}Repo,
		// TODO: 添加对应的 Service
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

print_info "Repository 添加完成！"
print_info "生成的文件："
print_info "1. $PROJECT_DIR/internal/repository/${REPO_NAME}.go"
print_info "2. $PROJECT_DIR/internal/model/${MODEL_NAME}.go"

# 根据用户选择显示不同的信息
if [ "$CREATE_TESTS" = "true" ]; then
    print_info "3. $PROJECT_DIR/internal/repository/${REPO_NAME}_test.go"
    print_info "4. $PROJECT_DIR/internal/model/${MODEL_NAME}_test.go"
fi

if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
    print_info "5. $PROJECT_DIR/internal/svc/servicecontext.go (已更新)"
fi

if [ "$CREATE_TESTS" = "true" ]; then
    print_info "已生成测试文件"
fi

if [ "$INCLUDE_DB_EXAMPLES" = "true" ]; then
    print_info "已包含数据库操作示例"
fi

if [ "$INCLUDE_MODEL_EXAMPLES" = "true" ]; then
    print_info "已包含模型字段示例"
fi

print_warn "请根据实际业务需求完善以下内容："
print_warn "1. 在 ${REPO_NAME}.go 中实现具体的数据库操作方法"
print_warn "2. 在 ${MODEL_NAME}.go 中添加具体的字段定义"

if [ "$CREATE_TESTS" = "true" ]; then
    print_warn "3. 在 ${REPO_NAME}_test.go 和 ${MODEL_NAME}_test.go 中添加测试用例"
fi

if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
    print_warn "4. 在 servicecontext.go 中配置数据库连接"
fi

print_warn "5. 使用 add_service.sh 添加对应的 Service" 