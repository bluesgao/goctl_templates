#!/bin/bash

# 自动安装 Google protobuf 导入文件到用户家目录
# 解决 "google/protobuf/timestamp.proto" 文件找不到的问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 全局变量
USER_INCLUDE_DIR="$HOME/.local/include"
PROTOBUF_INCLUDE_DIR="$USER_INCLUDE_DIR/google/protobuf"
TEMP_DIR=""

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

# 检查依赖
check_dependencies() {
    if ! command -v protoc &> /dev/null; then
        print_error "protoc 未安装，请先安装 protoc"
        print_info "安装方法："
        print_info "  macOS: brew install protobuf"
        print_info "  Ubuntu: sudo apt-get install protobuf-compiler"
        print_info "  CentOS: sudo yum install protoc"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "git 未安装，无法下载 protobuf 源码"
        print_info "请手动下载并安装 protobuf"
        print_info "下载地址: https://github.com/protocolbuffers/protobuf"
        exit 1
    fi
}

# 检查是否已安装
check_existing_installation() {
    if [ -f "$PROTOBUF_INCLUDE_DIR/timestamp.proto" ]; then
        print_info "Google protobuf 文件已存在，无需安装"
        print_info "文件位置: $PROTOBUF_INCLUDE_DIR/timestamp.proto"
        exit 0
    fi
}

# 下载并安装 protobuf 文件
install_protobuf_files() {
    print_warn "Google protobuf 文件不存在，开始下载安装..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # 下载 protobuf 源码
    print_info "下载 protobuf 源码..."
    git clone --depth 1 https://github.com/protocolbuffers/protobuf.git
    cd protobuf/src/google/protobuf
    
    print_info "找到以下 proto 文件："
    ls -la *.proto
    
    # 创建用户目录
    print_info "创建用户目录: $PROTOBUF_INCLUDE_DIR"
    mkdir -p "$PROTOBUF_INCLUDE_DIR"
    
    # 复制文件到用户目录
    print_info "复制文件到用户目录..."
    cp *.proto "$PROTOBUF_INCLUDE_DIR/"
    print_info "✅ 已成功复制 Google protobuf 文件到用户目录"
    
    # 显示复制的文件
    print_info "已安装的文件："
    ls -la "$PROTOBUF_INCLUDE_DIR/"
    
    # 清理临时目录
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

# 验证安装
verify_installation() {
    if [ -f "$PROTOBUF_INCLUDE_DIR/timestamp.proto" ]; then
        print_info "✅ Google protobuf 文件安装成功！"
        print_info "文件位置: $PROTOBUF_INCLUDE_DIR/timestamp.proto"
        print_info "现在可以使用 google.protobuf.Timestamp 了"
        return 0
    else
        print_error "❌ 安装失败，请检查错误信息"
        print_info "检查路径: $PROTOBUF_INCLUDE_DIR/timestamp.proto"
        return 1
    fi
}

# 测试编译
test_compilation() {
    print_info "测试编译包含 google.protobuf.Timestamp 的 proto 文件..."
    
    cat > test_timestamp.proto << 'EOF'
syntax = "proto3";

package test;

option go_package = ".";

import "google/protobuf/timestamp.proto";

message TestMessage {
  string name = 1;
  google.protobuf.Timestamp created_at = 2;
}
EOF
    
    # 使用用户目录进行编译测试
    if protoc --proto_path="$USER_INCLUDE_DIR" --go_out=. test_timestamp.proto 2>/dev/null; then
        print_info "✅ 编译测试成功！"
    else
        print_warn "⚠️ 编译测试失败，但文件已安装"
    fi
    
    # 清理测试文件
    rm -f test_timestamp.proto test.pb.go
}

# 创建环境配置脚本
create_env_script() {
    print_info "创建环境配置脚本..."
    cat > "$HOME/.protobuf_env.sh" << EOF
# Google protobuf 环境配置
# 将此文件添加到 ~/.bashrc 或 ~/.zshrc 中

export PROTOBUF_INCLUDE_PATH="$USER_INCLUDE_DIR"
export PROTOBUF_LIBRARY_PATH="$USER_INCLUDE_DIR"

# 添加到 PATH（如果需要）
# export PATH="\$PATH:$USER_INCLUDE_DIR"
EOF
    
    print_info "环境配置脚本已创建: $HOME/.protobuf_env.sh"
    print_info "请将此文件添加到您的 shell 配置文件中："
    print_info "  echo 'source ~/.protobuf_env.sh' >> ~/.bashrc"
    print_info "  echo 'source ~/.protobuf_env.sh' >> ~/.zshrc"
}

# 主函数
main() {
    print_info "开始安装 Google protobuf 导入文件到用户家目录..."
    print_info "安装目录: $PROTOBUF_INCLUDE_DIR"
    
    check_dependencies
    check_existing_installation
    install_protobuf_files
    
    if verify_installation; then
        test_compilation
        create_env_script
        print_info "安装完成！"
    else
        exit 1
    fi
}

# 执行主函数
main "$@" 