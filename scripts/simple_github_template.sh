#!/bin/bash

# 简化版 GitHub 模板使用脚本
# 基于 init_gozero_rpc_project.sh 结构

set -e

# 全局变量
GITHUB_URL=""
TEMPLATE_TYPE=""
PROTO_FILE="user.proto"
API_FILE="user.api"
PROJECT_DIR="./output"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# 工具函数
# =============================================================================

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# =============================================================================
# 验证函数
# =============================================================================

# 验证依赖
validate_dependencies() {
    print_info "验证依赖..."

    # 检查 goctl 是否安装
    if ! command -v goctl &>/dev/null; then
        print_error "goctl 未安装，请先安装 goctl"
        print_info "安装方法："
        print_info "  go install github.com/zeromicro/go-zero/tools/goctl@latest"
        exit 1
    fi

    print_info "依赖验证通过"
}

# 验证 GitHub URL
validate_github_url() {
    print_info "验证 GitHub URL..."

    if [ -z "$GITHUB_URL" ]; then
        print_error "GitHub URL 不能为空"
        exit 1
    fi

    # 检查 URL 格式
    if [[ ! "$GITHUB_URL" =~ ^https://github\.com/ ]]; then
        print_error "无效的 GitHub URL 格式"
        exit 1
    fi

    # 检查 URL 可访问性
    if ! curl -s --head "$GITHUB_URL" | head -n 1 | grep -q "HTTP/[1-2].[0-9] [23].."; then
        print_warn "GitHub URL 可能无法访问，但继续执行..."
    fi

    print_info "GitHub URL 验证通过"
}

# =============================================================================
# 代码生成函数
# =============================================================================

# 生成 API 服务
generate_api() {
    print_step "生成 API 服务"

    # 创建输出目录
    mkdir -p "$PROJECT_DIR"

    # 构建 goctl 命令
    local cmd="goctl api go"
    cmd="$cmd -api $API_FILE"
    cmd="$cmd -dir $PROJECT_DIR"
    cmd="$cmd --style goZero"
    cmd="$cmd --home $GITHUB_URL"

    print_info "执行命令: $cmd"

    # 执行命令
    if eval "$cmd"; then
        print_info "✅ API 服务生成成功！"
    else
        print_error "❌ API 服务生成失败"
        exit 1
    fi
}

# 生成 RPC 服务
generate_rpc() {
    print_step "生成 RPC 服务"

    # 创建输出目录
    mkdir -p "$PROJECT_DIR"

    # 构建 goctl 命令
    local cmd="goctl rpc protoc $PROTO_FILE"
    cmd="$cmd --proto_path=."

    # 添加 Google protobuf 路径
    local user_include_path="$HOME/.local/include"
    if [ -d "$user_include_path/google/protobuf" ]; then
        cmd="$cmd --proto_path=$user_include_path"
    else
        local system_include_path="/usr/local/include"
        if [ -d "$system_include_path/google/protobuf" ]; then
            cmd="$cmd --proto_path=$system_include_path"
        fi
    fi

    cmd="$cmd --go_out=$PROJECT_DIR/types"
    cmd="$cmd --go-grpc_out=$PROJECT_DIR/types"
    cmd="$cmd --zrpc_out=$PROJECT_DIR"
    cmd="$cmd --style goZero"
    cmd="$cmd --home $GITHUB_URL"

    print_info "执行命令: $cmd"

    # 执行命令
    if eval "$cmd"; then
        print_info "✅ RPC 服务生成成功！"
    else
        print_error "❌ RPC 服务生成失败"
        exit 1
    fi
}

# 生成数据模型
generate_model() {
    print_step "生成数据模型"

    # 创建输出目录
    mkdir -p "$PROJECT_DIR"

    # 构建 goctl 命令
    local cmd="goctl model mysql datasource"
    cmd="$cmd -t user"
    cmd="$cmd -c -d"
    cmd="$cmd --home $GITHUB_URL"
    cmd="$cmd --dir $PROJECT_DIR"

    print_info "执行命令: $cmd"

    # 执行命令
    if eval "$cmd"; then
        print_info "✅ 数据模型生成成功！"
    else
        print_error "❌ 数据模型生成失败"
        exit 1
    fi
}

# =============================================================================
# 结果展示函数
# =============================================================================

# 显示生成结果
show_results() {
    print_info "代码生成完成！"
    print_info "生成的文件："

    # 检查生成的文件
    if [ -d "$PROJECT_DIR" ]; then
        find "$PROJECT_DIR" -type f -name "*.go" | head -10 | while read -r file; do
            print_info "  - $file"
        done
    fi

    print_warn "请根据实际业务需求完善以下内容："
    print_warn "1. 实现具体的业务逻辑"
    print_warn "2. 配置数据库和Redis连接"
    print_warn "3. 配置服务参数"
    print_warn "4. 运行 go mod tidy 整理依赖"
    print_warn "5. 运行 go run . 启动服务"
}

# =============================================================================
# 交互式选择函数
# =============================================================================

# 选择模板类型
select_template_type() {
    print_step "选择模板类型"

    echo "请选择要生成的代码类型："
    echo "1. API 服务"
    echo "2. RPC 服务"
    echo "3. 数据模型"
    echo "4. 全部生成"
    echo

    read -p "请选择 (1-4): " choice

    case $choice in
    1)
        TEMPLATE_TYPE="api"
        ;;
    2)
        TEMPLATE_TYPE="rpc"
        ;;
    3)
        TEMPLATE_TYPE="model"
        ;;
    4)
        TEMPLATE_TYPE="all"
        ;;
    *)
        print_error "无效的选择"
        exit 1
        ;;
    esac
}

# 输入 GitHub URL
input_github_url() {
    print_step "输入 GitHub URL"

    echo "请输入 GitHub 模板 URL："
    echo "示例："
    echo "  https://github.com/username/repo"
    echo "  https://github.com/username/repo/tree/v1.0.0"
    echo "  https://github.com/username/repo/tree/feature-branch"
    echo

    read -p "GitHub URL: " GITHUB_URL

    if [ -z "$GITHUB_URL" ]; then
        print_error "GitHub URL 不能为空"
        exit 1
    fi
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    print_info "简化版 GitHub 模板使用脚本"
    print_info "=========================="

    # 交互式输入
    input_github_url
    select_template_type

    print_info "配置信息："
    print_info "  GitHub URL: $GITHUB_URL"
    print_info "  模板类型: $TEMPLATE_TYPE"
    print_info "  输出目录: $PROJECT_DIR"

    # 验证
    validate_dependencies
    validate_github_url

    # 生成代码
    case $TEMPLATE_TYPE in
    "api")
        generate_api
        ;;
    "rpc")
        generate_rpc
        ;;
    "model")
        generate_model
        ;;
    "all")
        generate_api
        generate_rpc
        generate_model
        ;;
    *)
        print_error "无效的模板类型"
        exit 1
        ;;
    esac

    # 显示结果
    show_results
}

# 执行主函数
main "$@"
