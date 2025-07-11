#!/bin/bash

# user Service Proto 编译脚本

set -e

echo "开始编译 user.proto..."

# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装，请先安装 protoc"
    exit 1
fi

# 检查 Go protobuf 插件是否安装
if ! command -v protoc-gen-go &> /dev/null; then
    echo "安装 protoc-gen-go..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo "安装 protoc-gen-go-grpc..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# 创建输出目录
mkdir -p types

# 编译 proto 文件
echo "编译 user.proto..."
protoc --go_out=types --go-grpc_out=types user.proto

echo "编译完成！"
echo "生成的文件："
echo "- types/user_grpc.pb.go"
echo "- types/user.pb.go"
