#!/bin/bash

# 初始化 Service 脚本
# 用于在现有 RPC 项目中添加新的 Service 层

set -e

# 全局变量
PROJECT_DIR=""
SERVICE_NAME=""
REPO_NAMES=()
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
    print_info "欢迎使用 Service 初始化脚本！"
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

    # 获取服务名称
    SERVICE_NAME=$(get_user_input "请输入服务名称" "UserService" "validate_name")

    # 获取 Repository 依赖
    collect_repository_dependencies
}

# 收集 Repository 依赖
collect_repository_dependencies() {
    echo ""
    print_info "Repository 依赖配置："

    REPO_NAMES=()
    while true; do
        repo_name=$(get_user_input "请输入 Repository 名称（输入空值结束）" "" "validate_name")
        if [ -z "$repo_name" ]; then
            break
        fi

        # 检查是否已添加
        for existing_repo in "${REPO_NAMES[@]}"; do
            if [ "$existing_repo" = "$repo_name" ]; then
                print_error "Repository 已存在: $repo_name"
                continue 2
            fi
        done

        REPO_NAMES+=("$repo_name")
        print_info "已添加 Repository: $repo_name"
    done

    if [ ${#REPO_NAMES[@]} -eq 0 ]; then
        print_warn "未添加任何 Repository 依赖"
    else
        print_info "Repository 依赖列表: ${REPO_NAMES[*]}"
    fi
}

# 显示配置信息
show_config_info() {
    echo ""
    print_info "Service 配置信息："
    echo "----------------------------------------"
    echo "项目目录: $PROJECT_DIR"
    echo "服务名称: $SERVICE_NAME"
    echo "Repository 依赖: ${REPO_NAMES[*]}"
    echo "----------------------------------------"
}

# 确认创建
confirm_creation() {
    if ! get_user_confirmation "确认添加 Service？" "y"; then
        print_info "已取消 Service 添加"
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

    if [ ! -d "$PROJECT_DIR/internal/service" ]; then
        print_error "Service 目录不存在，请先运行 init_project.sh 初始化项目"
        exit 1
    fi

    print_info "项目结构验证通过"
}

# =============================================================================
# 文件生成函数
# =============================================================================

# 生成 Service 层
generate_service() {
    print_info "步骤 1: 生成 Service 层..."

    # 生成 repository 字段
    local repo_fields=""
    for repo_name in "${REPO_NAMES[@]}"; do
        repo_fields="${repo_fields}\t${repo_name}Repo *repository.${repo_name}Repository\n"
    done

    # 生成构造函数参数
    local ctor_params=""
    for repo_name in "${REPO_NAMES[@]}"; do
        if [ -n "$ctor_params" ]; then
            ctor_params="${ctor_params}, "
        fi
        ctor_params="${ctor_params}${repo_name}Repo *repository.${repo_name}Repository"
    done

    # 生成构造函数赋值
    local ctor_assignments=""
    for repo_name in "${REPO_NAMES[@]}"; do
        ctor_assignments="${ctor_assignments}\t\t${repo_name}Repo: ${repo_name}Repo,\n"
    done

    cat >"$PROJECT_DIR/internal/service/${SERVICE_NAME}.go" <<EOF
package service

import (
	"context"

	"github.com/zeromicro/go-zero/core/logx"
	"$(basename $PROJECT_DIR)/types"
	"$(basename $PROJECT_DIR)/internal/repository"
	"$(basename $PROJECT_DIR)/internal/util"
)

type ${SERVICE_NAME} struct {
${repo_fields}	logx.Logger
}

func New${SERVICE_NAME}(${ctor_params}) *${SERVICE_NAME} {
	return &${SERVICE_NAME}{
${ctor_assignments}		Logger: logx.WithContext(context.Background()),
	}
}

// Get 实现获取业务逻辑
func (s *${SERVICE_NAME}) Get(ctx context.Context, id string) (interface{}, error) {
	s.Infof("${SERVICE_NAME}.Get called with id: %s", id)
	
	// TODO: 实现获取逻辑
	// 1. 参数验证
	// 2. 业务规则验证
	// 3. 调用 Repository
	// 4. 结果转换
	// 5. 返回结果
	
	return nil, nil
}
EOF

    print_info "Service 文件已生成: $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"
}

# 更新 ServiceContext
update_service_context() {
    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ] && [ -f "$PROJECT_DIR/internal/svc/servicecontext.go" ]; then
        print_info "步骤 2: 更新 ServiceContext..."

        # 备份原文件
        cp "$PROJECT_DIR/internal/svc/servicecontext.go" "$PROJECT_DIR/internal/svc/servicecontext.go.bak"

        # 生成 Repository 字段
        local sc_repo_fields=""
        for repo_name in "${REPO_NAMES[@]}"; do
            sc_repo_fields="${sc_repo_fields}\t${repo_name}Repo *repository.${repo_name}Repository\n"
        done

        # 生成 Repository 初始化
        local sc_repo_init=""
        for repo_name in "${REPO_NAMES[@]}"; do
            sc_repo_init="${sc_repo_init}\t${repo_name}Repo := repository.New${repo_name}Repository(db)\n"
        done

        # 生成 Service 构造函数参数
        local sc_service_ctor_params=""
        for repo_name in "${REPO_NAMES[@]}"; do
            if [ -n "$sc_service_ctor_params" ]; then
                sc_service_ctor_params="${sc_service_ctor_params}, "
            fi
            sc_service_ctor_params="${sc_service_ctor_params}${repo_name}Repo"
        done

        # 生成 ServiceContext 字段赋值
        local sc_field_assignments=""
        for repo_name in "${REPO_NAMES[@]}"; do
            sc_field_assignments="${sc_field_assignments}\t\t${repo_name}Repo: ${repo_name}Repo,\n"
        done

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
${sc_repo_fields}
	// Service 层
	${SERVICE_NAME} *service.${SERVICE_NAME}
}

func NewServiceContext(c config.Config) *ServiceContext {
	// 初始化数据库连接
	db := initDB(c)
	
	// 初始化 Redis 连接
	redisClient := initRedis(c)
	
	// 初始化 Repository 层
${sc_repo_init}
	
	// 初始化 Service 层
	${SERVICE_NAME} := service.New${SERVICE_NAME}(${sc_service_ctor_params})
	
	return &ServiceContext{
		Config:      c,
		DB:          db,
		Redis:       redisClient,
${sc_field_assignments}		${SERVICE_NAME}: ${SERVICE_NAME},
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
    print_info "Service 初始化完成！"
    print_info "生成的文件："
    print_info "1. $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"

    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_info "2. $PROJECT_DIR/internal/svc/servicecontext.go (已更新)"
    fi

    if [ ${#REPO_NAMES[@]} -gt 0 ]; then
        print_info "依赖的 Repository："
        for repo_name in "${REPO_NAMES[@]}"; do
            print_info "   - ${repo_name}Repository"
        done
    fi

    # 显示选项信息
    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_info "已更新 ServiceContext"
    fi

    print_warn "请根据实际业务需求完善以下内容："
    print_warn "1. 在 ${SERVICE_NAME}.go 中实现具体的业务逻辑方法"

    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_warn "2. 在 servicecontext.go 中配置数据库和Redis连接"
    fi

    if [ ${#REPO_NAMES[@]} -gt 0 ]; then
        print_warn "3. 确保所有依赖的 Repository 都已创建"
    fi
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
    print_info "开始创建 Service 文件..."
    print_info "项目目录: $PROJECT_DIR"
    print_info "服务名称: $SERVICE_NAME"
    print_info "Repository 依赖: ${REPO_NAMES[*]}"

    validate_project_structure
    generate_service
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
