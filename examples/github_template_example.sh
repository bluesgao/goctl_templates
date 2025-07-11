#!/bin/bash

# goctl GitHub 模板使用示例
# 演示如何使用 GitHub 上的模板生成代码

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 创建示例 API 文件
create_example_api() {
    print_info "创建示例 API 文件..."

    cat >user.api <<'EOF'
syntax = "v1"

type (
    CreateUserRequest {
        Name  string `json:"name"`
        Email string `json:"email"`
        Age   int    `json:"age"`
    }
    
    CreateUserResponse {
        Id    string `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
        Age   int    `json:"age"`
    }
    
    GetUserRequest {
        Id string `path:"id"`
    }
    
    GetUserResponse {
        Id    string `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
        Age   int    `json:"age"`
    }
)

service user-api {
    @handler CreateUser
    post /users (CreateUserRequest) returns (CreateUserResponse)
    
    @handler GetUser
    get /users/:id (GetUserRequest) returns (GetUserResponse)
}
EOF

    print_info "✅ API 文件创建完成"
}

# 创建示例 Proto 文件
create_example_proto() {
    print_info "创建示例 Proto 文件..."

    cat >user.proto <<'EOF'
syntax = "proto3";

package user;

option go_package = "./types";

service UserService {
    rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
    rpc GetUser(GetUserRequest) returns (GetUserResponse);
}

message CreateUserRequest {
    string name = 1;
    string email = 2;
    int32 age = 3;
}

message CreateUserResponse {
    string id = 1;
    string name = 2;
    string email = 3;
    int32 age = 4;
}

message GetUserRequest {
    string id = 1;
}

message GetUserResponse {
    string id = 1;
    string name = 2;
    string email = 3;
    int32 age = 4;
}
EOF

    print_info "✅ Proto 文件创建完成"
}

# 示例 1：使用本地模板生成 API 服务
example_local_api() {
    print_info "示例 1：使用本地模板生成 API 服务"

    # 创建输出目录
    mkdir -p ./examples/api-service

    # 生成 API 服务
    goctl api go \
        -api user.api \
        -dir ./examples/api-service \
        --style goZero \
        --home .

    print_info "✅ API 服务生成完成，位置: ./examples/api-service"
}

# 示例 2：使用本地模板生成 RPC 服务
example_local_rpc() {
    print_info "示例 2：使用本地模板生成 RPC 服务"

    # 创建输出目录
    mkdir -p ./examples/rpc-service

    # 生成 RPC 服务
    goctl rpc protoc user.proto \
        --go_out=./examples/rpc-service/types \
        --go-grpc_out=./examples/rpc-service/types \
        --zrpc_out=./examples/rpc-service \
        --style goZero \
        --home .

    print_info "✅ RPC 服务生成完成，位置: ./examples/rpc-service"
}

# 示例 3：使用本地模板生成数据模型
example_local_model() {
    print_info "示例 3：使用本地模板生成数据模型"

    # 创建输出目录
    mkdir -p ./examples/models

    # 生成数据模型（这里使用示例表结构）
    cat >user.sql <<'EOF'
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '用户名',
  `email` varchar(255) NOT NULL COMMENT '邮箱',
  `age` int(11) NOT NULL COMMENT '年龄',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
EOF

    # 生成模型
    goctl model mysql ddl \
        -src user.sql \
        -dir ./examples/models \
        --home .

    print_info "✅ 数据模型生成完成，位置: ./examples/models"
}

# 示例 4：演示 GitHub URL 使用（注释掉，因为需要实际的 GitHub 仓库）
example_github_url() {
    print_info "示例 4：使用 GitHub URL 生成代码"
    print_warn "注意：这个示例需要实际的 GitHub 仓库 URL"

    # 以下是使用 GitHub URL 的示例命令（需要替换为实际的仓库 URL）
    echo "# 使用 GitHub URL 生成 API 服务"
    echo "goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo"
    echo ""
    echo "# 使用 GitHub URL 生成 RPC 服务"
    echo "goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home https://github.com/username/repo"
    echo ""
    echo "# 使用 GitHub URL 生成数据模型"
    echo "goctl model mysql datasource -t user -c -d --home https://github.com/username/repo"
}

# 显示生成的文件
show_generated_files() {
    print_info "生成的文件结构："

    echo ""
    echo "📁 API 服务 (./examples/api-service):"
    if [ -d "./examples/api-service" ]; then
        find ./examples/api-service -type f -name "*.go" | head -10
    fi

    echo ""
    echo "📁 RPC 服务 (./examples/rpc-service):"
    if [ -d "./examples/rpc-service" ]; then
        find ./examples/rpc-service -type f -name "*.go" | head -10
    fi

    echo ""
    echo "📁 数据模型 (./examples/models):"
    if [ -d "./examples/models" ]; then
        find ./examples/models -type f -name "*.go" | head -5
    fi
}

# 清理示例文件
cleanup() {
    print_info "清理示例文件..."

    rm -f user.api user.proto user.sql
    rm -rf ./examples

    print_info "✅ 清理完成"
}

# 主函数
main() {
    print_info "goctl GitHub 模板使用示例"
    print_info "=========================="

    echo
    print_info "选择示例："
    echo "1. 创建示例文件"
    echo "2. 使用本地模板生成 API 服务"
    echo "3. 使用本地模板生成 RPC 服务"
    echo "4. 使用本地模板生成数据模型"
    echo "5. 显示 GitHub URL 使用示例"
    echo "6. 显示生成的文件"
    echo "7. 清理示例文件"
    echo "8. 运行所有示例"
    echo

    read -p "请选择 (1-8): " choice

    case $choice in
    1)
        create_example_api
        create_example_proto
        ;;
    2)
        example_local_api
        ;;
    3)
        example_local_rpc
        ;;
    4)
        example_local_model
        ;;
    5)
        example_github_url
        ;;
    6)
        show_generated_files
        ;;
    7)
        cleanup
        ;;
    8)
        create_example_api
        create_example_proto
        example_local_api
        example_local_rpc
        example_local_model
        show_generated_files
        ;;
    *)
        print_warn "无效的选择"
        exit 1
        ;;
    esac
}

# 执行主函数
main "$@"
