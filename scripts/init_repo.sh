#!/bin/bash

# 初始化 Repository 脚本
# 用于在现有 RPC 项目中添加新的 Repository 层和 Model 层

set -e

# 全局变量
PROJECT_DIR=""
REPO_NAME=""
MODEL_NAME=""
UPDATE_SERVICE_CONTEXT="true"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# 工具函数
# =============================================================================

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

# 验证名称格式
validate_name() {
    local name="$1"
    if [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
        return 0
    else
        return 1
    fi
}

# 获取用户输入
get_user_input() {
    local prompt="$1"
    local default_value="$2"
    local validation_func="$3"

    while true; do
        if [ -n "$default_value" ]; then
            read -p "$prompt (默认: $default_value): " input
            if [ -z "$input" ]; then
                input="$default_value"
            fi
        else
            read -p "$prompt: " input
        fi

        if [ -n "$input" ]; then
            if [ -n "$validation_func" ]; then
                if $validation_func "$input"; then
                    echo "$input"
                    return 0
                else
                    print_error "输入格式不正确，请重新输入"
                fi
            else
                echo "$input"
                return 0
            fi
        else
            print_error "输入不能为空，请重新输入"
        fi
    done
}

# 获取用户确认
get_user_confirmation() {
    local prompt="$1"
    local default="$2"

    while true; do
        read -p "$prompt (y/n, 默认: $default): " confirm
        case $confirm in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        "")
            if [ "$default" = "y" ]; then
                return 0
            else
                return 1
            fi
            ;;
        *) echo "请输入 y 或 n" ;;
        esac
    done
}

# =============================================================================
# 参数收集函数
# =============================================================================

# 收集基础参数
collect_basic_params() {
    print_info "欢迎使用 Repository 初始化脚本！"
    echo ""

    # 获取项目目录
    while true; do
        PROJECT_DIR=$(get_user_input "请输入项目目录" "./user")
        if [ -d "$PROJECT_DIR" ]; then
            break
        else
            print_error "项目目录不存在: $PROJECT_DIR"
            if ! get_user_confirmation "是否继续？" "n"; then
                exit 1
            fi
        fi
    done

    # 获取仓库名称
    REPO_NAME=$(get_user_input "请输入仓库名称" "UserRepo" "validate_name")

    # 获取模型名称
    MODEL_NAME=$(get_user_input "请输入模型名称" "User" "validate_name")
}

# 显示配置信息
show_config_info() {
    echo ""
    print_info "Repository 配置信息："
    echo "----------------------------------------"
    echo "项目目录: $PROJECT_DIR"
    echo "仓库名称: $REPO_NAME"
    echo "模型名称: $MODEL_NAME"
    echo "----------------------------------------"
}

# 确认创建
confirm_creation() {
    if ! get_user_confirmation "确认添加 Repository？" "y"; then
        print_info "已取消 Repository 添加"
        exit 0
    fi
}

# 收集高级选项
collect_advanced_options() {
    echo ""
    print_info "高级选项配置："

    # 是否更新 ServiceContext
    if get_user_confirmation "是否更新 ServiceContext？" "y"; then
        UPDATE_SERVICE_CONTEXT="true"
    else
        UPDATE_SERVICE_CONTEXT="false"
    fi
}

# =============================================================================
# 验证函数
# =============================================================================

# 验证项目结构
validate_project_structure() {
    print_info "验证项目结构..."

    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR/internal/repository" ]; then
        print_error "Repository 目录不存在，请先运行 init_project.sh 初始化项目"
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR/internal/model" ]; then
        print_error "Model 目录不存在，请先运行 init_project.sh 初始化项目"
        exit 1
    fi

    print_info "项目结构验证通过"
}

# =============================================================================
# 文件生成函数
# =============================================================================

# 生成 Repository 层
generate_repository() {
    print_info "步骤 1: 生成 Repository 层..."

    cat >"$PROJECT_DIR/internal/repository/${REPO_NAME}.go" <<EOF
package repository

import (
	"context"

	"github.com/zeromicro/go-zero/core/logx"
	"$(basename $PROJECT_DIR)/internal/model"
	"$(basename $PROJECT_DIR)/internal/util"
	"gorm.io/gorm"
)

// ${REPO_NAME}Repository 数据访问层
type ${REPO_NAME}Repository struct {
	db     *gorm.DB
	logx.Logger
}

// New${REPO_NAME}Repository 创建 Repository 实例
func New${REPO_NAME}Repository(db *gorm.DB) *${REPO_NAME}Repository {
	return &${REPO_NAME}Repository{
		db:     db,
		Logger: logx.WithContext(context.Background()),
	}
}



// Get 实现获取数据访问逻辑
func (r *${REPO_NAME}Repository) Get(ctx context.Context, id string) (interface{}, error) {
	r.Infof("${REPO_NAME}Repository.Get called with id: %s", id)
	
	// TODO: 实现获取逻辑
	// 1. 参数验证
	// 2. 从数据库查询
	// 3. 结果转换
	// 4. 返回结果
	
	return nil, nil
}






EOF

    print_info "Repository 文件已生成: $PROJECT_DIR/internal/repository/${REPO_NAME}.go"
}

# 生成 Model 层
generate_model() {
    print_info "步骤 2: 生成 Model 层..."

    cat >"$PROJECT_DIR/internal/model/${MODEL_NAME}.go" <<EOF
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

    print_info "Model 文件已生成: $PROJECT_DIR/internal/model/${MODEL_NAME}.go"
}

# 更新 ServiceContext
update_service_context() {
    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ] && [ -f "$PROJECT_DIR/internal/svc/servicecontext.go" ]; then
        print_info "步骤 3: 更新 ServiceContext..."

        # 备份原文件
        cp "$PROJECT_DIR/internal/svc/servicecontext.go" "$PROJECT_DIR/internal/svc/servicecontext.go.bak"

        # 读取原文件内容并添加新的Repository
        cat >"$PROJECT_DIR/internal/svc/servicecontext.go" <<EOF
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
	${REPO_NAME}Repo *repository.${REPO_NAME}Repository
	
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

        print_info "ServiceContext 已更新: $PROJECT_DIR/internal/svc/servicecontext.go"
    else
        print_warn "ServiceContext 文件不存在，跳过更新"
    fi
}

# =============================================================================
# 结果展示函数
# =============================================================================

# 显示生成结果
show_results() {
    print_info "Repository 初始化完成！"
    print_info "生成的文件："
    print_info "1. $PROJECT_DIR/internal/repository/${REPO_NAME}.go"
    print_info "2. $PROJECT_DIR/internal/model/${MODEL_NAME}.go"

    # 显示选项信息

    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_info "已更新 ServiceContext"
    fi

    print_warn "请根据实际业务需求完善以下内容："
    print_warn "1. 在 ${REPO_NAME}.go 中实现具体的数据库操作方法"
    print_warn "2. 在 ${MODEL_NAME}.go 中添加具体的字段定义"

    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_warn "3. 在 servicecontext.go 中配置数据库连接"
    fi

    print_warn "4. 使用 init_service.sh 添加对应的 Service"
}

# =============================================================================
# 主流程函数
# =============================================================================

# 收集参数
collect_params() {
    collect_basic_params
    show_config_info
    confirm_creation
    collect_advanced_options
}

# 创建文件
create_files() {
    print_info "开始创建 Repository 文件..."
    print_info "项目目录: $PROJECT_DIR"
    print_info "仓库名称: $REPO_NAME"
    print_info "模型名称: $MODEL_NAME"

    validate_project_structure
    generate_repository
    generate_model
    update_service_context
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    collect_params
    create_files
    show_results
}

# 执行主函数
main "$@"
