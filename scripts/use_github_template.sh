#!/bin/bash

# 使用 GitHub 上的 goctl 模板脚本
# 支持多种方式使用 GitHub 模板

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# =============================================================================
# 方法一：直接使用 GitHub URL
# =============================================================================

use_github_url() {
    print_step "方法一：直接使用 GitHub URL"

    local github_url="https://github.com/your-username/goctl-templates"
    local api_file="user.api"
    local output_dir="./user-service"

    print_info "使用 GitHub 模板生成 API 服务"
    print_info "GitHub URL: $github_url"
    print_info "API 文件: $api_file"
    print_info "输出目录: $output_dir"

    # 创建输出目录
    mkdir -p "$output_dir"

    # 生成 API 服务
    goctl api go \
        -api "$api_file" \
        -dir "$output_dir" \
        --style goZero \
        --home "$github_url"

    print_info "✅ API 服务生成完成！"
}

# =============================================================================
# 方法二：克隆 GitHub 仓库到本地
# =============================================================================

clone_github_repo() {
    print_step "方法二：克隆 GitHub 仓库到本地"

    local github_repo="https://github.com/your-username/goctl-templates"
    local local_dir="./templates-from-github"
    local api_file="user.api"
    local output_dir="./user-service"

    print_info "克隆 GitHub 仓库"
    print_info "仓库地址: $github_repo"
    print_info "本地目录: $local_dir"

    # 克隆仓库
    if [ -d "$local_dir" ]; then
        print_warn "本地目录已存在，正在更新..."
        cd "$local_dir"
        git pull origin main
        cd ..
    else
        git clone "$github_repo" "$local_dir"
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    # 使用本地模板生成代码
    goctl api go \
        -api "$api_file" \
        -dir "$output_dir" \
        --style goZero \
        --home "$local_dir"

    print_info "✅ 使用本地 GitHub 模板生成完成！"
}

# =============================================================================
# 方法三：使用特定分支或标签
# =============================================================================

use_specific_branch() {
    print_step "方法三：使用特定分支或标签"

    local github_repo="https://github.com/your-username/goctl-templates"
    local branch="feature/layered-architecture"
    local local_dir="./templates-branch"
    local api_file="user.api"
    local output_dir="./user-service"

    print_info "克隆特定分支"
    print_info "仓库地址: $github_repo"
    print_info "分支: $branch"
    print_info "本地目录: $local_dir"

    # 克隆特定分支
    if [ -d "$local_dir" ]; then
        print_warn "本地目录已存在，正在更新..."
        cd "$local_dir"
        git fetch origin
        git checkout "$branch"
        git pull origin "$branch"
        cd ..
    else
        git clone -b "$branch" "$github_repo" "$local_dir"
    fi

    # 创建输出目录
    mkdir -p "$output_dir"

    # 使用本地模板生成代码
    goctl api go \
        -api "$api_file" \
        -dir "$output_dir" \
        --style goZero \
        --home "$local_dir"

    print_info "✅ 使用特定分支模板生成完成！"
}

# =============================================================================
# 方法四：使用 GitHub Raw 内容
# =============================================================================

use_github_raw() {
    print_step "方法四：使用 GitHub Raw 内容"

    local raw_url="https://raw.githubusercontent.com/your-username/goctl-templates/main"
    local api_file="user.api"
    local output_dir="./user-service"

    print_info "使用 GitHub Raw 内容"
    print_info "Raw URL: $raw_url"
    print_info "API 文件: $api_file"
    print_info "输出目录: $output_dir"

    # 创建输出目录
    mkdir -p "$output_dir"

    # 生成 API 服务（注意：这种方式可能不适用于所有模板）
    goctl api go \
        -api "$api_file" \
        -dir "$output_dir" \
        --style goZero \
        --home "$raw_url"

    print_info "✅ 使用 GitHub Raw 模板生成完成！"
}

# =============================================================================
# 方法五：使用 GitHub Release
# =============================================================================

use_github_release() {
    print_step "方法五：使用 GitHub Release"

    local release_url="https://github.com/your-username/goctl-templates/releases/latest/download"
    local local_dir="./templates-release"
    local api_file="user.api"
    local output_dir="./user-service"

    print_info "下载 GitHub Release"
    print_info "Release URL: $release_url"
    print_info "本地目录: $local_dir"

    # 创建临时目录
    mkdir -p "$local_dir"
    cd "$local_dir"

    # 下载 release 文件（假设是 zip 格式）
    curl -L -o templates.zip "$release_url/templates.zip"
    unzip templates.zip
    rm templates.zip

    cd ..

    # 创建输出目录
    mkdir -p "$output_dir"

    # 使用本地模板生成代码
    goctl api go \
        -api "$api_file" \
        -dir "$output_dir" \
        --style goZero \
        --home "$local_dir"

    print_info "✅ 使用 GitHub Release 模板生成完成！"
}

# =============================================================================
# RPC 服务生成示例
# =============================================================================

generate_rpc_with_github_template() {
    print_step "使用 GitHub 模板生成 RPC 服务"

    local github_url="https://github.com/your-username/goctl-templates"
    local proto_file="user.proto"
    local output_dir="./user-rpc"

    print_info "使用 GitHub 模板生成 RPC 服务"
    print_info "GitHub URL: $github_url"
    print_info "Proto 文件: $proto_file"
    print_info "输出目录: $output_dir"

    # 创建输出目录
    mkdir -p "$output_dir"

    # 生成 RPC 服务
    goctl rpc protoc "$proto_file" \
        --go_out="$output_dir/types" \
        --go-grpc_out="$output_dir/types" \
        --zrpc_out="$output_dir" \
        --style goZero \
        --home "$github_url"

    print_info "✅ RPC 服务生成完成！"
}

# =============================================================================
# 数据模型生成示例
# =============================================================================

generate_model_with_github_template() {
    print_step "使用 GitHub 模板生成数据模型"

    local github_url="https://github.com/your-username/goctl-templates"
    local table_name="user"
    local output_dir="./models"

    print_info "使用 GitHub 模板生成数据模型"
    print_info "GitHub URL: $github_url"
    print_info "表名: $table_name"
    print_info "输出目录: $output_dir"

    # 创建输出目录
    mkdir -p "$output_dir"

    # 生成数据模型
    goctl model mysql datasource \
        -t "$table_name" \
        -c -d \
        --home "$github_url" \
        --dir "$output_dir"

    print_info "✅ 数据模型生成完成！"
}

# =============================================================================
# 验证 GitHub 模板
# =============================================================================

validate_github_template() {
    print_step "验证 GitHub 模板"

    local github_url="$1"

    if [ -z "$github_url" ]; then
        print_error "请提供 GitHub URL"
        return 1
    fi

    print_info "验证 GitHub 模板: $github_url"

    # 检查 URL 是否可访问
    if curl -s --head "$github_url" | head -n 1 | grep "HTTP/[1-2].[0-9] [23].." >/dev/null; then
        print_info "✅ GitHub URL 可访问"
    else
        print_error "❌ GitHub URL 不可访问"
        return 1
    fi

    # 检查是否包含必要的模板文件
    local required_files=("api/handler.tpl" "api/logic.tpl" "rpc/logic.tpl" "model/model.tpl")

    for file in "${required_files[@]}"; do
        local file_url="$github_url/$file"
        if curl -s --head "$file_url" | head -n 1 | grep "HTTP/[1-2].[0-9] [23].." >/dev/null; then
            print_info "✅ 找到模板文件: $file"
        else
            print_warn "⚠️  未找到模板文件: $file"
        fi
    done

    print_info "✅ GitHub 模板验证完成"
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    print_info "goctl GitHub 模板使用指南"
    print_info "=========================="

    echo
    print_info "可用的方法："
    echo "1. 直接使用 GitHub URL"
    echo "2. 克隆 GitHub 仓库到本地"
    echo "3. 使用特定分支或标签"
    echo "4. 使用 GitHub Raw 内容"
    echo "5. 使用 GitHub Release"
    echo "6. 生成 RPC 服务"
    echo "7. 生成数据模型"
    echo "8. 验证 GitHub 模板"
    echo

    read -p "请选择方法 (1-8): " choice

    case $choice in
    1)
        use_github_url
        ;;
    2)
        clone_github_repo
        ;;
    3)
        use_specific_branch
        ;;
    4)
        use_github_raw
        ;;
    5)
        use_github_release
        ;;
    6)
        generate_rpc_with_github_template
        ;;
    7)
        generate_model_with_github_template
        ;;
    8)
        read -p "请输入 GitHub URL: " github_url
        validate_github_template "$github_url"
        ;;
    *)
        print_error "无效的选择"
        exit 1
        ;;
    esac
}

# 执行主函数
main "$@"
