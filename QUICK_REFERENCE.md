# goctl GitHub 模板快速参考

## 🚀 基本用法

### API 服务生成
```bash
# 使用 GitHub URL
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo

# 使用本地模板
goctl api go -api user.api -dir . --style goZero --home ./templates
```

### RPC 服务生成
```bash
# 使用 GitHub URL
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home https://github.com/username/repo

# 使用本地模板
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home ./templates
```

### 数据模型生成
```bash
# 使用 GitHub URL
goctl model mysql datasource -t user -c -d --home https://github.com/username/repo

# 使用本地模板
goctl model mysql datasource -t user -c -d --home ./templates
```

## 📋 支持的 URL 格式

| 格式 | 示例 | 说明 |
|------|------|------|
| GitHub 仓库 | `https://github.com/username/repo` | 使用主分支 |
| 特定分支 | `https://github.com/username/repo/tree/feature-branch` | 使用指定分支 |
| 特定标签 | `https://github.com/username/repo/tree/v1.0.0` | 使用指定版本 |
| Raw 内容 | `https://raw.githubusercontent.com/username/repo/main` | 使用原始内容 |

## 🔧 高级用法

### 克隆到本地使用
```bash
# 克隆模板仓库
git clone https://github.com/username/repo ./templates

# 使用本地模板
goctl api go -api user.api -dir . --style goZero --home ./templates
```

### 使用环境变量
```bash
# 设置模板 URL
export GOTEMPLATE_HOME="https://github.com/username/repo"

# 使用环境变量
goctl api go -api user.api -dir . --style goZero --home $GOTEMPLATE_HOME
```

### 验证模板可用性
```bash
# 检查 URL 是否可访问
curl -s --head https://github.com/username/repo | head -n 1

# 检查特定模板文件
curl -s --head https://raw.githubusercontent.com/username/repo/main/api/handler.tpl
```

## 🛠️ 脚本工具

### 使用提供的脚本
```bash
# 运行 GitHub 模板脚本
./scripts/use_github_template.sh

# 运行示例脚本
./examples/github_template_example.sh
```

### 验证模板脚本
```bash
#!/bin/bash
TEMPLATE_URL="$1"
REQUIRED_FILES=("api/handler.tpl" "api/logic.tpl" "rpc/logic.tpl")

for file in "${REQUIRED_FILES[@]}"; do
    if curl -s --head "$TEMPLATE_URL/$file" | grep -q "200 OK"; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 不存在"
    fi
done
```

## 📁 模板目录结构

```
templates/
├── api/                    # API 服务模板
│   ├── handler.tpl        # 处理器模板
│   ├── logic.tpl          # 业务逻辑模板
│   ├── service.tpl        # 服务层模板
│   ├── repository.tpl     # 数据访问层模板
│   ├── svc.tpl            # 服务上下文模板
│   └── types.tpl          # 类型定义模板
├── rpc/                    # RPC 服务模板
│   ├── internal/
│   │   ├── logic/
│   │   │   └── logic.tpl
│   │   ├── service/
│   │   │   └── service.tpl
│   │   ├── repository/
│   │   │   └── repository.tpl
│   │   ├── model/
│   │   │   └── model.tpl
│   │   └── svc/
│   │       └── servicecontext.tpl
│   └── etc.tpl            # 配置文件模板
└── model/                  # 数据模型模板
    └── model.tpl          # 模型模板
```

## 🔍 常见问题

### 网络连接问题
```bash
# 使用代理
export GOPROXY=https://goproxy.cn,direct

# 使用本地模板
git clone https://github.com/username/repo ./templates
```

### 模板文件不存在
```bash
# 检查模板结构
curl -s https://raw.githubusercontent.com/username/repo/main/api/handler.tpl

# 使用备用模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/backup-username/repo
```

### 版本兼容性问题
```bash
# 使用特定版本的 goctl
go install github.com/zeromicro/go-zero/tools/goctl@v1.4.0

# 使用兼容的模板版本
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/v1.4.0
```

## 📚 相关文档

- [详细使用指南](GITHUB_TEMPLATE_USAGE.md)
- [项目 README](README.md)
- [使用说明](USAGE.md)
- [RPC 使用说明](rpc/USAGE.md)

## 🎯 最佳实践

1. **使用语义化版本标签** - 确保模板版本稳定
2. **本地缓存模板** - 提高生成速度
3. **验证模板可用性** - 避免生成失败
4. **使用环境变量** - 简化命令
5. **定期更新模板** - 获取最新功能

## 📞 快速开始

```bash
# 1. 克隆模板仓库
git clone https://github.com/username/repo ./templates

# 2. 生成 API 服务
goctl api go -api user.api -dir . --style goZero --home ./templates

# 3. 生成 RPC 服务
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home ./templates

# 4. 生成数据模型
goctl model mysql datasource -t user -c -d --home ./templates
``` 