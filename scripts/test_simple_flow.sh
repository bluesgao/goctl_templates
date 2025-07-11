#!/bin/bash

# 测试简化流程脚本
# 验证 GitHub 模板使用功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# 测试交互式脚本
test_interactive_script() {
    print_info "测试交互式脚本..."

    if [ -f "./scripts/simple_github_template.sh" ]; then
        print_info "✅ 交互式脚本存在"
        chmod +x ./scripts/simple_github_template.sh
    else
        print_error "❌ 交互式脚本不存在"
        return 1
    fi
}

# 测试命令行脚本
test_command_line_script() {
    print_info "测试命令行脚本..."

    if [ -f "./scripts/quick_github_template.sh" ]; then
        print_info "✅ 命令行脚本存在"
        chmod +x ./scripts/quick_github_template.sh

        # 测试帮助信息
        if ./scripts/quick_github_template.sh --help &>/dev/null; then
            print_info "✅ 帮助信息正常"
        else
            print_warn "⚠️  帮助信息可能有问题"
        fi
    else
        print_error "❌ 命令行脚本不存在"
        return 1
    fi
}

# 测试文档
test_documentation() {
    print_info "测试文档..."

    local docs=(
        "SIMPLE_USAGE.md"
        "GITHUB_TEMPLATE_USAGE.md"
        "QUICK_REFERENCE.md"
        "SUMMARY.md"
    )

    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            print_info "✅ $doc 存在"
        else
            print_warn "⚠️  $doc 不存在"
        fi
    done
}

# 测试示例文件
test_example_files() {
    print_info "测试示例文件..."

    # 创建测试 API 文件
    cat >test-user.api <<'EOF'
syntax = "v1"

type (
    CreateUserRequest {
        Name  string `json:"name"`
        Email string `json:"email"`
    }
    
    CreateUserResponse {
        Id    string `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
    }
)

service user-api {
    @handler CreateUser
    post /users (CreateUserRequest) returns (CreateUserResponse)
}
EOF

    # 创建测试 Proto 文件
    cat >test-user.proto <<'EOF'
syntax = "proto3";

package user;

option go_package = "./types";

service UserService {
    rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
}

message CreateUserRequest {
    string name = 1;
    string email = 2;
}

message CreateUserResponse {
    string id = 1;
    string name = 2;
    string email = 3;
}
EOF

    print_info "✅ 测试文件创建完成"
}

# 测试 goctl 命令
test_goctl_commands() {
    print_info "测试 goctl 命令..."

    # 检查 goctl 是否安装
    if command -v goctl &>/dev/null; then
        print_info "✅ goctl 已安装"

        # 测试 goctl 版本
        local version=$(goctl --version 2>/dev/null || echo "unknown")
        print_info "  goctl 版本: $version"
    else
        print_warn "⚠️  goctl 未安装"
        print_info "  安装命令: go install github.com/zeromicro/go-zero/tools/goctl@latest"
    fi
}

# 清理测试文件
cleanup_test_files() {
    print_info "清理测试文件..."

    rm -f test-user.api test-user.proto
    rm -rf ./test-output

    print_info "✅ 清理完成"
}

# 显示使用示例
show_usage_examples() {
    print_info "使用示例："
    echo ""
    echo "1. 交互式使用："
    echo "   ./scripts/simple_github_template.sh"
    echo ""
    echo "2. 命令行使用："
    echo "   ./scripts/quick_github_template.sh -u https://github.com/username/repo -t api"
    echo "   ./scripts/quick_github_template.sh -u https://github.com/username/repo -t rpc"
    echo "   ./scripts/quick_github_template.sh -u https://github.com/username/repo -t model"
    echo ""
    echo "3. 查看帮助："
    echo "   ./scripts/quick_github_template.sh --help"
    echo ""
    echo "4. 查看文档："
    echo "   cat SIMPLE_USAGE.md"
    echo ""
}

# 主函数
main() {
    print_info "开始测试简化流程..."
    print_info "===================="

    # 测试各个组件
    test_interactive_script
    test_command_line_script
    test_documentation
    test_example_files
    test_goctl_commands

    # 显示使用示例
    show_usage_examples

    # 清理
    cleanup_test_files

    print_info "✅ 测试完成！"
    print_info "现在您可以使用简化流程来生成代码了。"
}

# 执行主函数
main "$@"
