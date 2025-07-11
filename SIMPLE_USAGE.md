# goctl GitHub 模板简化使用指南

## 🚀 快速开始

### 方法一：交互式脚本（推荐新手）

```bash
# 运行交互式脚本
./scripts/simple_github_template.sh
```

脚本会引导您：
1. 输入 GitHub 模板 URL
2. 选择要生成的代码类型
3. 自动生成代码

### 方法二：命令行脚本（推荐熟练用户）

```bash
# 生成 API 服务
./scripts/quick_github_template.sh -u https://github.com/username/repo -t api

# 生成 RPC 服务
./scripts/quick_github_template.sh -u https://github.com/username/repo -t rpc

# 生成数据模型
./scripts/quick_github_template.sh -u https://github.com/username/repo -t model

# 生成全部
./scripts/quick_github_template.sh -u https://github.com/username/repo -t all -o ./my-project
```

## 📋 支持的 URL 格式

| 格式 | 示例 | 说明 |
|------|------|------|
| 主分支 | `https://github.com/username/repo` | 使用默认分支 |
| 特定分支 | `https://github.com/username/repo/tree/feature-branch` | 使用指定分支 |
| 特定版本 | `https://github.com/username/repo/tree/v1.0.0` | 使用指定标签 |

## 🔧 命令行参数

### 快速脚本参数

```bash
./scripts/quick_github_template.sh [选项]

选项:
  -u, --url URL          GitHub 模板 URL (必需)
  -t, --type TYPE        模板类型: api|rpc|model|all (默认: api)
  -o, --output DIR       输出目录 (默认: ./output)
  -a, --api FILE         API 文件 (默认: user.api)
  -p, --proto FILE       Proto 文件 (默认: user.proto)
  -h, --help            显示帮助信息
```

### 使用示例

```bash
# 基本用法
./scripts/quick_github_template.sh -u https://github.com/username/repo -t api

# 指定输出目录
./scripts/quick_github_template.sh -u https://github.com/username/repo -t rpc -o ./my-service

# 指定文件
./scripts/quick_github_template.sh -u https://github.com/username/repo -t api -a my-api.api

# 生成全部
./scripts/quick_github_template.sh -u https://github.com/username/repo -t all -o ./my-project
```

## 📁 输出结构

### API 服务
```
output/
├── etc/
│   └── user-api.yaml
├── internal/
│   ├── handler/
│   ├── logic/
│   ├── svc/
│   └── types/
├── user-api.go
└── go.mod
```

### RPC 服务
```
output/
├── etc/
│   └── user.yaml
├── internal/
│   ├── logic/
│   ├── svc/
│   └── types/
├── types/
│   ├── user.pb.go
│   └── user_grpc.pb.go
├── user.go
└── go.mod
```

### 数据模型
```
output/
├── user.go
└── vars.go
```

## 🛠️ 常见问题

### 1. goctl 未安装
```bash
# 安装 goctl
go install github.com/zeromicro/go-zero/tools/goctl@latest
```

### 2. 网络连接问题
```bash
# 使用代理
export GOPROXY=https://goproxy.cn,direct

# 或者克隆到本地使用
git clone https://github.com/username/repo ./templates
./scripts/quick_github_template.sh -u ./templates -t api
```

### 3. 模板文件不存在
```bash
# 检查模板结构
curl -s https://raw.githubusercontent.com/username/repo/main/api/handler.tpl

# 使用备用模板
./scripts/quick_github_template.sh -u https://github.com/backup-username/repo -t api
```

## 📚 完整文档

- [详细使用指南](GITHUB_TEMPLATE_USAGE.md) - 完整的使用说明
- [快速参考](QUICK_REFERENCE.md) - 常用命令和格式
- [项目总结](SUMMARY.md) - 完整解决方案概述

## 🎯 最佳实践

1. **使用语义化版本** - 确保模板版本稳定
2. **本地缓存模板** - 提高生成速度
3. **验证模板质量** - 检查生成的代码
4. **定期更新模板** - 获取最新功能

## 🚀 一键使用

```bash
# 克隆模板仓库
git clone https://github.com/username/repo ./templates

# 生成 API 服务
./scripts/quick_github_template.sh -u ./templates -t api -o ./my-api

# 生成 RPC 服务
./scripts/quick_github_template.sh -u ./templates -t rpc -o ./my-rpc

# 生成数据模型
./scripts/quick_github_template.sh -u ./templates -t model -o ./my-models
```

通过这个简化的流程，您可以快速使用 GitHub 上的 goctl 模板生成代码，提高开发效率。 