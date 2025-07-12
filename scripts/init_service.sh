#!/bin/bash

# =============================================================================
# 初始化 Service 脚本
# =============================================================================
# 功能：用于在现有 RPC 项目中添加新的 Service 层
# 支持交互式配置服务名称、Repository 依赖和高级选项
# 可生成包含依赖注入、业务逻辑的完整 Service 层代码
# 
# 作者：AI Assistant
# 版本：1.0.0
# 日期：2024
# =============================================================================

set -e

# =============================================================================
# 全局变量定义
# =============================================================================
PROJECT_DIR=""                    # 项目目录
SERVICE_NAME=""                   # 服务名称
REPO_NAMES=()                     # Repository 依赖列表
UPDATE_SERVICE_CONTEXT="true"     # 是否更新 ServiceContext

# 脚本配置
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Service 层初始化脚本"

# =============================================================================
# 颜色定义 - 用于美化输出
# =============================================================================
RED='\033[0;31m'      # 红色 - 错误信息
GREEN='\033[0;32m'    # 绿色 - 成功信息
YELLOW='\033[1;33m'   # 黄色 - 警告信息
BLUE='\033[0;34m'     # 蓝色 - 信息提示
CYAN='\033[0;36m'     # 青色 - 强调信息
NC='\033[0m'          # 无颜色 - 重置颜色

# =============================================================================
# 工具函数 - 输出格式化
# =============================================================================

# 打印信息消息（绿色）
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# 打印警告消息（黄色）
print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1 \n"
}

# 打印错误消息（红色）
print_error() {
    echo -e "${RED}[ERROR]${NC} $1 \n"
}

# 打印强调信息（青色）
print_highlight() {
    echo -e "${CYAN}[HIGHLIGHT]${NC} $1 \n"
}

# 打印步骤信息（蓝色）
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1 \n"
}

# 打印分隔线
print_separator() {
    echo -e "${CYAN}========================================${NC} \n"
}

# =============================================================================
# 验证函数 - 输入验证
# =============================================================================

# 验证名称格式 - 确保符合 Go 命名规范
validate_name() {
    local name="$1"
    if [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# 交互函数 - 用户输入
# =============================================================================

# 获取用户输入 - 支持默认值和验证
get_user_input() {
    local prompt="$1"
    local default_value="$2"
    local validation_func="$3"

    while true; do
        if [ -n "$default_value" ]; then
            read -p "📝 $prompt (默认: $default_value): " input
            if [ -z "$input" ]; then
                input="$default_value"
            fi
        else
            read -p "📝 $prompt: " input
        fi

        if [ -n "$input" ]; then
            if [ -n "$validation_func" ]; then
                if $validation_func "$input"; then
                    echo "$input"
                    return 0
                else
                    print_error "❌ 输入格式不正确，请重新输入"
                fi
            else
                echo "$input"
                return 0
            fi
        else
            print_error "❌ 输入不能为空，请重新输入"
        fi
    done
}

# 获取用户确认 - 支持默认值
get_user_confirmation() {
    local prompt="$1"
    local default="$2"

    while true; do
        read -p "✅ $prompt (y/n, 默认: $default): " confirm
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
        *) print_error "❌ 请输入 y 或 n" ;;
        esac
    done
}

# =============================================================================
# 参数收集函数 - 用户配置
# =============================================================================

# 收集基础参数 - 获取用户输入的基本配置
collect_basic_params() {
    print_separator
    print_highlight "🎯 Service 层配置"
    print_separator

    # 获取项目目录
    while true; do
        PROJECT_DIR=$(get_user_input "请输入项目目录" "./user")
        if [ -d "$PROJECT_DIR" ]; then
            break
        else
            print_error "❌ 项目目录不存在: $PROJECT_DIR"
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

# 收集 Repository 依赖 - 配置依赖关系
collect_repository_dependencies() {
    print_separator
    print_highlight "🔗 Repository 依赖配置"
    print_separator

    REPO_NAMES=()
    while true; do
        repo_name=$(get_user_input "请输入 Repository 名称（输入空值结束）" "" "validate_name")
        if [ -z "$repo_name" ]; then
            break
        fi

        # 检查是否已添加
        for existing_repo in "${REPO_NAMES[@]}"; do
            if [ "$existing_repo" = "$repo_name" ]; then
                print_error "❌ Repository 已存在: $repo_name"
                continue 2
            fi
        done

        REPO_NAMES+=("$repo_name")
        print_info "✅ 已添加 Repository: $repo_name"
    done

    if [ ${#REPO_NAMES[@]} -eq 0 ]; then
        print_warn "⚠️  未添加任何 Repository 依赖"
    else
        print_info "📋 Repository 依赖列表: ${REPO_NAMES[*]}"
    fi
}

# 显示配置信息 - 展示用户配置汇总
show_config_info() {
    print_separator
    print_highlight "📋 配置信息汇总"
    print_info "  📁 项目目录: $PROJECT_DIR"
    print_info "  🏷️  服务名称: $SERVICE_NAME"
    print_info "  🔗 Repository 依赖: ${REPO_NAMES[*]}"
    print_separator
}

# 确认创建 - 用户确认是否继续
confirm_creation() {
    if ! get_user_confirmation "确认添加 Service？" "y"; then
        print_warn "🔄 已取消 Service 添加"
        exit 0
    fi
}

# 收集高级选项 - 配置生成选项
collect_advanced_options() {
    print_separator
    print_highlight "⚙️  高级选项配置"
    print_separator

    # 是否更新 ServiceContext
    if get_user_confirmation "是否更新 ServiceContext？" "y"; then
        UPDATE_SERVICE_CONTEXT="true"
    else
        UPDATE_SERVICE_CONTEXT="false"
    fi
}

# =============================================================================
# 验证函数 - 环境检查
# =============================================================================

# 验证项目结构 - 检查必要的目录和文件
validate_project_structure() {
    print_separator
    print_highlight "🔍 项目结构验证"
    print_separator

    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "❌ 项目目录不存在: $PROJECT_DIR"
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR/internal/service" ]; then
        print_error "❌ Service 目录不存在，请先运行 init_project.sh 初始化项目"
        exit 1
    fi

    print_info "✅ 项目结构验证通过"
}

# =============================================================================
# 文件生成函数 - 代码生成
# =============================================================================

# 生成 Service 层 - 创建业务逻辑层代码
generate_service() {
    print_separator
    print_highlight "🚀 生成 Service 层"
    print_separator

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
	"$(basename $PROJECT_DIR)/internal/repository"
)

// ${SERVICE_NAME} 业务逻辑层
type ${SERVICE_NAME} struct {
	logx.Logger
${repo_fields}}

// New${SERVICE_NAME} 创建 Service 实例
func New${SERVICE_NAME}(${ctor_params}) *${SERVICE_NAME} {
	return &${SERVICE_NAME}{
		Logger: logx.WithContext(context.Background()),
${ctor_assignments}}
}

// ProcessData 处理业务逻辑
func (s *${SERVICE_NAME}) ProcessData(ctx context.Context, data interface{}) (interface{}, error) {
	s.Infof("${SERVICE_NAME}.ProcessData called with data: %v", data)
	
	// TODO: 实现业务逻辑
	// 1. 参数验证
	// 2. 调用 Repository 层获取数据
	// 3. 业务规则处理
	// 4. 数据转换
	// 5. 返回结果
	
	return nil, nil
}
EOF

    print_step "📝 创建 Service 文件: $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"
}

# 更新 ServiceContext - 配置依赖注入
update_service_context() {
    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_step "🔧 更新 ServiceContext..."
        
        # 这里可以添加更新 ServiceContext 的逻辑
        # 例如：在 svc/servicecontext.go 中添加新的 Service 字段
        
        print_info "✅ ServiceContext 更新完成"
    else
        print_info "⏭️  跳过 ServiceContext 更新"
    fi
}

# =============================================================================
# 主流程函数 - 协调整个生成流程
# =============================================================================

# 收集参数 - 获取用户配置
collect_params() {
    collect_basic_params
    show_config_info
    confirm_creation
    collect_advanced_options
}

# 创建文件 - 生成 Service 文件和更新配置
create_files() {
    print_separator
    print_highlight "🚀 开始创建 Service 层"
    print_separator

    print_info "📁 项目目录: $PROJECT_DIR"
    print_info "🏷️  服务名称: $SERVICE_NAME"
    print_info "🔗 Repository 依赖: ${REPO_NAMES[*]}"

    # 生成 Service 层
    generate_service
    
    # 更新 ServiceContext
    update_service_context
}

# 显示结果 - 展示生成结果和后续步骤
show_results() {
    print_separator
    print_highlight "🎉 Service 层创建完成！"
    print_separator

    print_info "📦 生成内容："
    print_info "  ✅ Service 文件: $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"
    
    if [ "$UPDATE_SERVICE_CONTEXT" = "true" ]; then
        print_info "  ✅ ServiceContext 已更新"
    fi

    print_info "📁 项目目录: $PROJECT_DIR"
    print_info "🏷️  服务名称: $SERVICE_NAME"

    print_separator
    print_highlight "📋 后续步骤"
    print_separator

    print_warn "🔧 接下来可以："
    print_warn "1. 📝 在 Service 中实现具体的业务逻辑"
    print_warn "2. 🔗 在 Logic 层中调用 Service"
    print_warn "3. ⚙️  在 ServiceContext 中配置依赖注入"
    print_warn "4. 🧪 编写单元测试验证业务逻辑"

    print_separator
    print_highlight "🎯 文件路径: $PROJECT_DIR/internal/service/${SERVICE_NAME}.go"
    print_separator
}

# =============================================================================
# 主函数 - 脚本执行入口
# =============================================================================

# 主函数 - 协调整个 Service 层生成流程
main() {
    collect_params
    validate_project_structure
    create_files
    show_results
}

# 执行主函数 - 脚本入口点
main "$@"
