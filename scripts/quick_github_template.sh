#!/bin/bash

# 快速 GitHub 模板使用脚本
# 支持命令行参数，无需交互

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "快速 GitHub 模板使用脚本"
    echo ""
    echo "用法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -u, --url URL          GitHub 模板 URL (必需)"
    echo "  -t, --type TYPE        模板类型: api|rpc|model|all (默认: api)"
    echo "  -o, --output DIR       输出目录 (默认: ./output)"
    echo "  -a, --api FILE         API 文件 (默认: user.api)"
    echo "  -p, --proto FILE       Proto 文件 (默认: user.proto)"
    echo "  -h, --help            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -u https://github.com/username/repo -t api"
    echo "  $0 -u https://github.com/username/repo -t rpc -o ./my-service"
    echo "  $0 -u https://github.com/username/repo -t all"
    echo ""
    echo "支持的 URL 格式:"
    echo "  https://github.com/username/repo"
    echo "  https://github.com/username/repo/tree/v1.0.0"
    echo "  https://github.com/username/repo/tree/feature-branch"
}

# 解析命令行参数
parse_args() {
    GITHUB_URL=""
    TEMPLATE_TYPE="api"
    OUTPUT_DIR="./output"
    API_FILE="user.api"
    PROTO_FILE="user.proto"

    while [[ $# -gt 0 ]]; do
        case $1 in
        -u | --url)
            GITHUB_URL="$2"
            shift 2
            ;;
        -t | --type)
            TEMPLATE_TYPE="$2"
            shift 2
            ;;
        -o | --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -a | --api)
            API_FILE="$2"
            shift 2
            ;;
        -p | --proto)
            PROTO_FILE="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
        esac
    done

    # 验证必需参数
    if [ -z "$GITHUB_URL" ]; then
        print_error "GitHub URL 是必需的"
        show_help
        exit 1
    fi

    # 验证模板类型
    case $TEMPLATE_TYPE in
    api | rpc | model | all) ;;
    *)
        print_error "无效的模板类型: $TEMPLATE_TYPE"
        print_error "支持的类型: api, rpc, model, all"
        exit 1
        ;;
    esac
}

# 验证依赖
validate_dependencies() {
    if ! command -v goctl &>/dev/null; then
        print_error "goctl 未安装，请先安装 goctl"
        print_info "安装方法：go install github.com/zeromicro/go-zero/tools/goctl@latest"
        exit 1
    fi
}

# 验证 GitHub URL
validate_github_url() {
    if [[ ! "$GITHUB_URL" =~ ^https://github\.com/ ]]; then
        print_error "无效的 GitHub URL 格式"
        exit 1
    fi
}

# 生成 API 服务
generate_api() {
    print_info "生成 API 服务..."

    mkdir -p "$OUTPUT_DIR"

    local cmd="goctl api go -api $API_FILE -dir $OUTPUT_DIR --style goZero --home $GITHUB_URL"
    print_info "执行: $cmd"

    if eval "$cmd"; then
        print_info "✅ API 服务生成成功"
    else
        print_error "❌ API 服务生成失败"
        exit 1
    fi
}

# 生成 RPC 服务
generate_rpc() {
    print_info "生成 RPC 服务..."

    mkdir -p "$OUTPUT_DIR"

    local cmd="goctl rpc protoc $PROTO_FILE"
    cmd="$cmd --proto_path=."

    # 添加 protobuf 路径
    local user_include_path="$HOME/.local/include"
    if [ -d "$user_include_path/google/protobuf" ]; then
        cmd="$cmd --proto_path=$user_include_path"
    else
        local system_include_path="/usr/local/include"
        if [ -d "$system_include_path/google/protobuf" ]; then
            cmd="$cmd --proto_path=$system_include_path"
        fi
    fi

    cmd="$cmd --go_out=$OUTPUT_DIR/types"
    cmd="$cmd --go-grpc_out=$OUTPUT_DIR/types"
    cmd="$cmd --zrpc_out=$OUTPUT_DIR"
    cmd="$cmd --style goZero"
    cmd="$cmd --home $GITHUB_URL"

    print_info "执行: $cmd"

    if eval "$cmd"; then
        print_info "✅ RPC 服务生成成功"
    else
        print_error "❌ RPC 服务生成失败"
        exit 1
    fi
}

# 生成数据模型
generate_model() {
    print_info "生成数据模型..."

    mkdir -p "$OUTPUT_DIR"

    local cmd="goctl model mysql datasource -t user -c -d --home $GITHUB_URL --dir $OUTPUT_DIR"
    print_info "执行: $cmd"

    if eval "$cmd"; then
        print_info "✅ 数据模型生成成功"
    else
        print_error "❌ 数据模型生成失败"
        exit 1
    fi
}

# 显示结果
show_results() {
    print_info "代码生成完成！"
    print_info "输出目录: $OUTPUT_DIR"

    if [ -d "$OUTPUT_DIR" ]; then
        local file_count=$(find "$OUTPUT_DIR" -type f -name "*.go" | wc -l)
        print_info "生成的文件数量: $file_count"

        if [ "$file_count" -gt 0 ]; then
            print_info "生成的文件:"
            find "$OUTPUT_DIR" -type f -name "*.go" | head -5 | while read -r file; do
                print_info "  - $file"
            done

            if [ "$file_count" -gt 5 ]; then
                print_info "  ... 还有 $((file_count - 5)) 个文件"
            fi
        fi
    fi

    print_warn "下一步："
    print_warn "1. 实现具体的业务逻辑"
    print_warn "2. 配置数据库和Redis连接"
    print_warn "3. 运行 go mod tidy 整理依赖"
    print_warn "4. 运行 go run . 启动服务"
}

# 主函数
main() {
    print_info "快速 GitHub 模板使用脚本"
    print_info "========================"

    # 解析参数
    parse_args "$@"

    # 显示配置
    print_info "配置信息："
    print_info "  GitHub URL: $GITHUB_URL"
    print_info "  模板类型: $TEMPLATE_TYPE"
    print_info "  输出目录: $OUTPUT_DIR"

    # 验证
    validate_dependencies
    validate_github_url

    # 生成代码
    case $TEMPLATE_TYPE in
    api)
        generate_api
        ;;
    rpc)
        generate_rpc
        ;;
    model)
        generate_model
        ;;
    all)
        generate_api
        generate_rpc
        generate_model
        ;;
    esac

    # 显示结果
    show_results
}

# 执行主函数
main "$@"
