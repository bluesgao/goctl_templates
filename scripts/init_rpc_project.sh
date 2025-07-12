#!/bin/bash

# =============================================================================
# 初始化 go-zero RPC 项目脚本
# =============================================================================
# 功能：使用 goctl 根据 proto 文件生成 RPC 代码
# 支持交互式配置项目名称、proto 文件名和分层结构
# 分层架构：Logic -> Service -> Repository -> Model
# 
# 作者：AI Assistant
# 版本：1.0.0
# 日期：2024
# =============================================================================

set -e

# =============================================================================
# 全局变量定义
# =============================================================================
PROTO_FILE=""      # Proto 文件名
PROJECT_DIR=""     # 项目目录路径
PROJECT_NAME=""    # 项目名称

# 脚本配置
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="go-zero RPC 项目初始化脚本"

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
# 交互式输入函数 - 用户配置
# =============================================================================

# 获取用户输入 - 项目名称和 proto 文件名
get_user_input() {
    print_separator
    print_highlight "🎯 项目配置"
    print_separator
    
    # 获取项目名称（必填）
    while [ -z "$PROJECT_NAME" ]; do
        read -p "📝 请输入项目名称（必填）: " input
        PROJECT_NAME="$input"
        if [ -z "$PROJECT_NAME" ]; then
            print_error "❌ 项目名称不能为空，请重新输入"
        fi
    done
    
    # 获取 proto 文件名（必填）
    while [ -z "$PROTO_FILE" ]; do
        read -p "📄 请输入 proto 文件名（必填）: " input
        PROTO_FILE="$input"
        if [ -z "$PROTO_FILE" ]; then
            print_error "❌ Proto 文件名不能为空，请重新输入"
        fi
    done
    
    # 设置项目目录
    PROJECT_DIR="./${PROJECT_NAME}"
    
    print_separator
    print_highlight "📋 配置信息汇总"
    print_info "  🏷️  项目名称: $PROJECT_NAME"
    print_info "  📁 项目目录: $PROJECT_DIR"
    print_info "  📄 Proto 文件: $PROTO_FILE"
    print_separator
    
    # 确认配置
    read -p "✅ 确认使用以上配置？(y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_warn "🔄 重新配置..."
        PROJECT_NAME=""
        PROTO_FILE=""
        PROJECT_DIR=""
        get_user_input
    fi
}



# =============================================================================
# 验证函数 - 环境检查
# =============================================================================

# 验证依赖 - 检查必要的工具是否安装
validate_dependencies() {
    print_separator
    print_highlight "🔍 环境依赖检查"
    print_separator

    # 检查 goctl 是否安装
    if ! command -v goctl &>/dev/null; then
        print_error "❌ goctl 未安装，请先安装 goctl"
        print_info "📦 安装方法："
        print_info "  go install github.com/zeromicro/go-zero/tools/goctl@latest"
        exit 1
    fi

    # 检查 protoc 是否安装
    if ! command -v protoc &>/dev/null; then
        print_error "❌ protoc 未安装，请先安装 protoc"
        print_info "📦 安装方法："
        print_info "  🍎 macOS: brew install protobuf"
        print_info "  🐧 Ubuntu: sudo apt-get install protobuf-compiler"
        print_info "  🔴 CentOS: sudo yum install protoc"
        exit 1
    fi

    # 检查 Go 插件是否安装
    if ! command -v protoc-gen-go &>/dev/null; then
        print_warn "⚠️  protoc-gen-go 未安装，正在安装..."
        go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    fi

    if ! command -v protoc-gen-go-grpc &>/dev/null; then
        print_warn "⚠️  protoc-gen-go-grpc 未安装，正在安装..."
        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    fi

    print_info "✅ 依赖验证通过"
}



# =============================================================================
# 代码生成函数 - 项目结构创建
# =============================================================================

# 创建分层结构 - 交互式创建各层目录和 demo 文件
create_layer_structure() {
    print_separator
    print_highlight "🏗️  创建项目分层结构"
    print_separator
    
    # 定义所有可用的分层
    local available_layers=("service" "repository" "model")
    
    for layer in "${available_layers[@]}"; do
        read -p "🔨 是否创建 ${layer} 层？(y/N): " create_layer
        if [[ "$create_layer" =~ ^[Yy]$ ]]; then
            local layer_dir="internal/${layer}"
            print_step "📁 创建目录: $layer_dir"
            mkdir -p "$layer_dir"
            
            # 询问是否创建该层的 demo
            read -p "📝 是否为 ${layer} 层创建 demo 文件？(y/N): " create_demo
            if [[ "$create_demo" =~ ^[Yy]$ ]]; then
                create_layer_demo "$layer" "$layer_dir"
            else
                print_info "⏭️  跳过 ${layer} 层 demo 创建"
            fi
        else
            print_info "⏭️  跳过 ${layer} 层创建"
        fi
    done
    
    print_info "✅ 项目分层结构创建完成"
}

# 为每一层创建 demo - 根据分层类型创建对应的示例代码
create_layer_demo() {
    local layer_name="$1"    # 分层名称
    local layer_dir="$2"     # 分层目录路径
    
    case "$layer_name" in
        "service")
            create_service_demo "$layer_dir"
            ;;
        "repository")
            create_repository_demo "$layer_dir"
            ;;
        "model")
            create_model_demo "$layer_dir"
            ;;
        *)
            print_warn "未知的分层类型: $layer_name"
            ;;
    esac
}





# 创建 repository demo - 数据访问层示例代码
create_repository_demo() {
    local layer_dir="$1"     # 分层目录路径
    local file_path="$layer_dir/demo_repository.go"
    
    cat > "$file_path" << EOF
package repository

import (
	"context"
	"${PROJECT_NAME}/internal/model"
	"${PROJECT_NAME}/internal/svc"

	"github.com/zeromicro/go-zero/core/logx"
)

type DemoRepository struct {
	logx.Logger
	svcCtx *svc.ServiceContext
}

func NewDemoRepository(svcCtx *svc.ServiceContext) *DemoRepository {
	return &DemoRepository{
		Logger: logx.WithContext(context.Background()),
		svcCtx: svcCtx,
	}
}

func (r *DemoRepository) GetDemoData(ctx context.Context, id int64) (*model.DemoModel, error) {
	// Repository 层：数据访问层
	// 这里可以连接数据库、Redis、外部API等
	// 示例：从数据库查询数据
	return &model.DemoModel{
		Id:   id,
		Name: "demo_name",
		Data: "demo_data",
	}, nil
}
EOF
    
    print_step "📝 创建 repository demo: $file_path"
}

# 创建 service demo - 业务服务层示例代码
create_service_demo() {
    local layer_dir="$1"     # 分层目录路径
    local file_path="$layer_dir/demo_service.go"
    
    cat > "$file_path" << EOF
package service

import (
	"context"
	"${PROJECT_NAME}/internal/repository"
	"${PROJECT_NAME}/internal/svc"
	"${PROJECT_NAME}/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type DemoService struct {
	logx.Logger
	svcCtx *svc.ServiceContext
	repo   *repository.DemoRepository
}

func NewDemoService(svcCtx *svc.ServiceContext) *DemoService {
	return &DemoService{
		Logger: logx.WithContext(context.Background()),
		svcCtx: svcCtx,
		repo:   repository.NewDemoRepository(svcCtx),
	}
}

func (s *DemoService) ProcessDemoData(ctx context.Context, id int64) (*types.DemoData, error) {
	// Service 层：业务服务处理
	// 调用 Repository 层获取数据
	model, err := s.repo.GetDemoData(ctx, id)
	if err != nil {
		return nil, err
	}
	
	// 业务逻辑处理
	processedData := &types.DemoData{
		Id:   model.Id,
		Name: "processed_" + model.Name,
		Data: "enhanced_" + model.Data,
	}
	
	return processedData, nil
}
EOF
    
    print_step "📝 创建 service demo: $file_path"
}

# 生成 go-zero RPC 项目骨架 - 使用 goctl 根据现有 proto 文件生成项目骨架
create_gozero_rpc_base_skeleton() {
    print_separator
    print_highlight "🚀 生成 go-zero RPC 项目骨架"
    print_separator

    # 检查项目目录是否存在，如果不存在则创建
    if [ ! -d "$PROJECT_DIR" ]; then
        print_step "📁 创建项目目录: $PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
    fi

    # 检查 proto 文件是否存在
    if [ ! -f "$PROJECT_DIR/$PROTO_FILE" ]; then
        print_error "❌ Proto文件不存在: $PROJECT_DIR/$PROTO_FILE"
        print_info "💡 请确保proto文件在执行脚本前已创建"
        exit 1
    fi

    # 切换到项目目录
    cd "$PROJECT_DIR"
    
    # 构建 goctl 命令
    local cmd="goctl rpc protoc $PROTO_FILE"    

    # 添加 proto 文件路径
    cmd="$cmd --proto_path=. "

    # 添加 Google protobuf 路径
    local user_include_path="$HOME/.local/include"
    if [ -d "$user_include_path/google/protobuf" ]; then
        cmd="$cmd --proto_path=$user_include_path"
        print_info "🔧 使用用户安装的 Google protobuf: $user_include_path"
    else
        # 尝试系统路径
        local system_include_path="/usr/local/include"
        if [ -d "$system_include_path/google/protobuf" ]; then
            cmd="$cmd --proto_path=$system_include_path"
            print_info "🔧 使用系统安装的 Google protobuf: $system_include_path"
        else
            print_warn "⚠️  未找到 Google protobuf 安装路径，可能影响导入"
        fi
    fi

    cmd="$cmd --go_out=."
    cmd="$cmd --go-grpc_out=."
    cmd="$cmd --zrpc_out=."
    cmd="$cmd --style=go_zero"
    print_step "⚙️  goctl项目骨架生成命令: $cmd"

    # 执行命令
    if eval "$cmd"; then
        print_info "✅ goctl项目骨架生成成功！"
    else
        print_error "❌ goctl项目骨架生成失败"
        exit 1
    fi
}

# 创建 model demo - 数据模型层示例代码
create_model_demo() {
    local layer_dir="$1"     # 分层目录路径
    local file_path="$layer_dir/demo_model.go"
    
    cat > "$file_path" << EOF
package model

// DemoModel 示例数据模型
// Model 层：数据模型定义
type DemoModel struct {
	Id   int64  \`json:"id"\`
	Name string \`json:"name"\`
	Data string \`json:"data"\`
}
EOF
    
    print_step "📝 创建 model demo: $file_path"
}

# 创建 types demo - 类型定义示例代码
create_types_demo() {
    local types_dir="internal/types"    # 类型定义目录
    local file_path="$types_dir/demo_types.go"
    
    mkdir -p "$types_dir"
    
    cat > "$file_path" << EOF
package types

// DemoReq 示例请求结构
type DemoReq struct {
	Id int64 \`json:"id"\`
}

// DemoResp 示例响应结构
type DemoResp struct {
	Id   int64  \`json:"id"\`
	Name string \`json:"name"\`
	Data string \`json:"data"\`
}

// DemoData 内部数据结构
type DemoData struct {
	Id   int64  \`json:"id"\`
	Name string \`json:"name"\`
	Data string \`json:"data"\`
}
EOF
    
    print_step "📝 创建 types demo: $file_path"
}

# =============================================================================
# 结果展示函数 - 输出总结
# =============================================================================

# 显示生成结果 - 展示创建的文件和后续步骤
show_results() {
    print_separator
    print_highlight "🎉 项目初始化完成！"
    print_separator
    
    print_info "📦 生成的文件："

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
        print_info "  📄 $file"
    done

    print_info "🏗️  分层结构："
    print_info "  📁 已创建的分层目录在 internal/ 下"

    print_separator
    print_highlight "📋 后续步骤"
    print_separator
    
    print_warn "🔧 请根据实际业务需求完善以下内容："
    print_warn "1. 📝 在 internal/logic 中实现具体的业务逻辑"
    print_warn "2. 🔗 在 internal/svc 中配置数据库和Redis连接"
    print_warn "3. ⚙️  在 etc 中配置服务参数"
    print_warn "4. 📦 运行 go mod tidy 整理依赖"
    print_warn "5. 🚀 运行 go run . 启动服务"
    print_warn "6. 📚 参考 demo 文件了解分层架构：Logic -> Service -> Repository -> Model"
    
    print_separator
    print_highlight "🎯 项目路径: $PROJECT_DIR"
    print_separator
}

# =============================================================================
# 主函数 - 脚本执行入口
# =============================================================================

# 主函数 - 协调整个初始化流程
main() {
    print_separator
    print_highlight "🚀 开始初始化 go-zero RPC 项目"
    print_separator
    
    get_user_input
    validate_dependencies
    create_gozero_rpc_base_skeleton
    create_layer_structure
    create_types_demo
    show_results
}

# 执行主函数 - 脚本入口点
main "$@"

