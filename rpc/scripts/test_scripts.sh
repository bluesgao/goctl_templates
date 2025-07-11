#!/bin/bash

# 测试脚本功能
# 用于验证 init_project.sh、add_service.sh、add_repo.sh 的功能

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

# 创建测试目录
TEST_DIR="./test_project"
PROTO_FILE="./test.proto"

print_info "开始测试脚本功能..."

# 1. 创建测试 proto 文件
print_info "步骤 1: 创建测试 proto 文件..."
cat > "$PROTO_FILE" << 'EOF'
syntax = "proto3";

package test;

option go_package = "./types";

service TestService {
  rpc CreateTest(CreateTestRequest) returns (CreateTestResponse);
  rpc GetTest(GetTestRequest) returns (GetTestResponse);
}

message CreateTestRequest {
  string name = 1;
  string description = 2;
}

message CreateTestResponse {
  string id = 1;
  string status = 2;
}

message GetTestRequest {
  string id = 1;
}

message GetTestResponse {
  string id = 1;
  string name = 2;
  string description = 3;
}
EOF

# 2. 清理之前的测试目录
if [ -d "$TEST_DIR" ]; then
    print_warn "清理之前的测试目录..."
    rm -rf "$TEST_DIR"
fi

# 3. 测试 init_project.sh
print_info "步骤 2: 测试 init_project.sh..."
if [ -f "./scripts/init_project.sh" ]; then
    ./scripts/init_project.sh "$TEST_DIR" "Test"
    print_info "✅ init_project.sh 执行成功"
else
    print_error "❌ scripts/init_project.sh 文件不存在"
    exit 1
fi

# 4. 检查生成的文件
print_info "步骤 3: 检查生成的文件..."
if [ -d "$TEST_DIR" ]; then
    print_info "✅ 测试目录创建成功"
    
    # 检查目录结构
    if [ -d "$TEST_DIR/internal" ]; then
        print_info "✅ internal 目录创建成功"
        
        # 检查各个分层目录
        if [ -d "$TEST_DIR/internal/logic" ]; then
            print_info "✅ logic 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/internal/service" ]; then
            print_info "✅ service 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/internal/repository" ]; then
            print_info "✅ repository 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/internal/model" ]; then
            print_info "✅ model 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/internal/util" ]; then
            print_info "✅ util 目录创建成功"
            if [ -f "$TEST_DIR/internal/util/errcode.go" ]; then
                print_info "✅ errcode.go 文件生成成功"
            fi
            if [ -f "$TEST_DIR/internal/util/utils.go" ]; then
                print_info "✅ utils.go 文件生成成功"
            fi
        fi
        
        if [ -d "$TEST_DIR/internal/svc" ]; then
            print_info "✅ svc 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/internal/types" ]; then
            print_info "✅ types 目录创建成功"
        fi
        
        if [ -d "$TEST_DIR/etc" ]; then
            print_info "✅ etc 目录创建成功"
        fi
        
        if [ -f "$TEST_DIR/README.md" ]; then
            print_info "✅ README.md 文件生成成功"
        fi
        
    else
        print_warn "❌ internal 目录创建失败"
    fi
    
    # 显示目录结构
    print_info "生成的目录结构："
    tree "$TEST_DIR" -I "*.go" 2>/dev/null || ls -la "$TEST_DIR"
    
else
    print_warn "❌ 测试目录创建失败"
fi

# 5. 测试 add_repo.sh
print_info "步骤 4: 测试 add_repo.sh..."
if [ -f "./scripts/add_repo.sh" ]; then
    ./scripts/add_repo.sh "$TEST_DIR" "TestRepo" "Test"
    print_info "✅ add_repo.sh 执行成功"
    
    # 检查生成的文件
    if [ -f "$TEST_DIR/internal/repository/TestRepo.go" ]; then
        print_info "✅ TestRepo.go 文件生成成功"
    fi
    
    if [ -f "$TEST_DIR/internal/repository/TestRepo_test.go" ]; then
        print_info "✅ TestRepo_test.go 文件生成成功"
    fi
    
    if [ -f "$TEST_DIR/internal/model/Test.go" ]; then
        print_info "✅ Test.go 文件生成成功"
    fi
    
    if [ -f "$TEST_DIR/internal/model/Test_test.go" ]; then
        print_info "✅ Test_test.go 文件生成成功"
    fi
    
else
    print_error "❌ scripts/add_repo.sh 文件不存在"
fi

# 6. 测试 add_service.sh
print_info "步骤 5: 测试 add_service.sh..."
if [ -f "./scripts/add_service.sh" ]; then
    ./scripts/add_service.sh "$TEST_DIR" "TestService" "TestRepo"
    print_info "✅ add_service.sh 执行成功"
    
    # 检查生成的文件
    if [ -f "$TEST_DIR/internal/service/TestService.go" ]; then
        print_info "✅ TestService.go 文件生成成功"
    fi
    
    if [ -f "$TEST_DIR/internal/service/TestService_test.go" ]; then
        print_info "✅ TestService_test.go 文件生成成功"
    fi
    
else
    print_error "❌ scripts/add_service.sh 文件不存在"
fi

# 7. 最终检查
print_info "步骤 6: 最终检查..."
if [ -d "$TEST_DIR" ]; then
    print_info "✅ 所有脚本测试通过"
    print_info "生成的文件列表："
    find "$TEST_DIR" -name "*.go" -o -name "*.md" -o -name "*.yaml" | head -20
    
    print_info "项目结构："
    tree "$TEST_DIR" -I "*.go" 2>/dev/null || ls -la "$TEST_DIR"
else
    print_error "❌ 测试失败"
fi

# 8. 清理测试文件
print_info "步骤 7: 清理测试文件..."
rm -f "$PROTO_FILE"

print_info "测试完成！"
print_info "测试项目位于: $TEST_DIR"
print_warn "请检查生成的文件是否符合预期，并根据实际需求进行调整。" 