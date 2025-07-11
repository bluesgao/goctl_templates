#!/bin/bash

# 初始化 go-zero RPC 项目脚本
# 使用 goctl 根据 proto 文件生成 RPC 代码

set -e

# 全局变量
PROTO_FILE="user.proto"
PROJECT_DIR="./user"

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

    # 检查 protoc 是否安装
    if ! command -v protoc &>/dev/null; then
        print_error "protoc 未安装，请先安装 protoc"
        print_info "安装方法："
        print_info "  macOS: brew install protobuf"
        print_info "  Ubuntu: sudo apt-get install protobuf-compiler"
        print_info "  CentOS: sudo yum install protoc"
        exit 1
    fi

    # 检查 Go 插件是否安装
    if ! command -v protoc-gen-go &>/dev/null; then
        print_warn "protoc-gen-go 未安装，正在安装..."
        go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    fi

    if ! command -v protoc-gen-go-grpc &>/dev/null; then
        print_warn "protoc-gen-go-grpc 未安装，正在安装..."
        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    fi

    print_info "依赖验证通过"
}

# 验证项目结构
validate_project_structure() {
    print_info "验证项目结构..."

    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        print_info "请先运行 init_project.sh 初始化项目"
        exit 1
    fi

    if [ ! -f "$PROJECT_DIR/$PROTO_FILE" ]; then
        print_error "Proto 文件不存在: $PROJECT_DIR/$PROTO_FILE"
        print_info "请先运行 init_proto.sh 创建 proto 文件"
        exit 1
    fi

    print_info "项目结构验证通过"
}

# =============================================================================
# 代码生成函数
# =============================================================================

# 生成代码
generate_code() {
    print_info "开始生成代码..."

    # 切换到项目目录
    cd "$PROJECT_DIR"

    # 构建 goctl 命令
    local cmd="goctl rpc protoc $PROTO_FILE"
    cmd="$cmd --proto_path=."

    # 添加 Google protobuf 路径
    local user_include_path="$HOME/.local/include"
    if [ -d "$user_include_path/google/protobuf" ]; then
        cmd="$cmd --proto_path=$user_include_path"
        print_info "使用用户安装的 Google protobuf: $user_include_path"
    else
        # 尝试系统路径
        local system_include_path="/usr/local/include"
        if [ -d "$system_include_path/google/protobuf" ]; then
            cmd="$cmd --proto_path=$system_include_path"
            print_info "使用系统安装的 Google protobuf: $system_include_path"
        else
            print_warn "未找到 Google protobuf 安装路径，可能影响导入"
        fi
    fi

    cmd="$cmd --go_out=."
    cmd="$cmd --go-grpc_out=."
    cmd="$cmd --zrpc_out=."
    cmd="$cmd --style=go_zero"
    cmd="$cmd --home=--home https://github.com/username/repo/tree/v1.0.0"
    print_info "执行命令: $cmd"

    # 执行命令
    if eval "$cmd"; then
        print_info "✅ 代码生成成功！"
    else
        print_error "❌ 代码生成失败"
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
    local generated_files=()

    # 检查 types 目录
    if [ -d "$PROJECT_DIR/types" ]; then
        generated_files+=("types/ 目录")
    fi

    # 检查 etc 目录
    if [ -d "$PROJECT_DIR/etc" ]; then
        generated_files+=("etc/ 目录")
    fi

    # 检查 internal 目录
    if [ -d "$PROJECT_DIR/internal" ]; then
        generated_files+=("internal/ 目录")
    fi

    # 检查 go.mod 和 go.sum
    if [ -f "$PROJECT_DIR/go.mod" ]; then
        generated_files+=("go.mod")
    fi

    if [ -f "$PROJECT_DIR/go.sum" ]; then
        generated_files+=("go.sum")
    fi

    # 显示生成的文件
    for file in "${generated_files[@]}"; do
        print_info "  - $file"
    done

    print_warn "请根据实际业务需求完善以下内容："
    print_warn "1. 在 internal/logic 中实现具体的业务逻辑"
    print_warn "2. 在 internal/svc 中配置数据库和Redis连接"
    print_warn "3. 在 etc 中配置服务参数"
    print_warn "4. 运行 go mod tidy 整理依赖"
    print_warn "5. 运行 go run . 启动服务"
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    print_info "开始初始化 go-zero RPC 项目..."
    print_info "项目目录: $PROJECT_DIR"
    print_info "Proto 文件: $PROTO_FILE"

    validate_dependencies
    validate_project_structure
    generate_code
    show_results
}

# 执行主函数
main "$@"
