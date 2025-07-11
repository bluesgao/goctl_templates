# goctl 使用 GitHub 上的指定模板

## 概述

goctl 支持使用 GitHub 上的自定义模板来生成代码。这允许您使用社区维护的模板，或者在不同项目间共享自定义模板。

## 支持的 GitHub 模板格式

### 1. 直接使用 GitHub URL

```bash
# 使用 GitHub 仓库作为模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo

# 使用 GitHub 仓库的特定分支
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/feature-branch

# 使用 GitHub 仓库的特定标签
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/v1.0.0
```

### 2. 使用 GitHub Raw 内容

```bash
# 使用 GitHub Raw 内容
goctl api go -api user.api -dir . --style goZero --home https://raw.githubusercontent.com/username/repo/main
```

### 3. 克隆到本地使用

```bash
# 克隆 GitHub 仓库到本地
git clone https://github.com/username/repo ./templates

# 使用本地模板
goctl api go -api user.api -dir . --style goZero --home ./templates
```

## 实际使用示例

### 示例 1：使用本项目的模板

```bash
# 使用当前项目的模板生成 API 服务
goctl api go -api user.api -dir . --style goZero --home https://github.com/your-username/goctl_templates

# 使用当前项目的模板生成 RPC 服务
goctl rpc protoc user.proto --go_out=./types --go-grpc_out=./types --zrpc_out=. --style goZero --home https://github.com/your-username/goctl_templates

# 使用当前项目的模板生成数据模型
goctl model mysql datasource -t user -c -d --home https://github.com/your-username/goctl_templates
```

### 示例 2：使用社区模板

```bash
# 使用 go-zero 官方模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/zeromicro/go-zero/tree/master/tools/goctl/api/gogen

# 使用社区维护的分层架构模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/community-user/layered-architecture-templates
```

### 示例 3：使用特定版本

```bash
# 使用特定版本的模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/v2.0.0

# 使用特定分支的模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/feature/layered-arch
```

## 模板目录结构要求

GitHub 上的模板仓库需要遵循特定的目录结构：

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

## 高级用法

### 1. 使用脚本自动化

```bash
# 运行提供的脚本
chmod +x scripts/use_github_template.sh
./scripts/use_github_template.sh
```

### 2. 验证模板可用性

```bash
# 验证 GitHub 模板是否可用
curl -s --head https://github.com/username/repo/tree/main | head -n 1

# 检查特定模板文件是否存在
curl -s --head https://raw.githubusercontent.com/username/repo/main/api/handler.tpl
```

### 3. 使用环境变量

```bash
# 设置模板 URL 环境变量
export GOTEMPLATE_HOME="https://github.com/username/repo"

# 使用环境变量
goctl api go -api user.api -dir . --style goZero --home $GOTEMPLATE_HOME
```

## 常见问题解决

### 问题 1：网络连接问题

```bash
# 解决方案：使用代理或镜像
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=sum.golang.google.cn

# 或者使用本地模板
git clone https://github.com/username/repo ./templates
goctl api go -api user.api -dir . --style goZero --home ./templates
```

### 问题 2：模板文件不存在

```bash
# 检查模板文件结构
curl -s https://raw.githubusercontent.com/username/repo/main/api/handler.tpl

# 使用备用模板
goctl api go -api user.api -dir . --style goZero --home https://github.com/backup-username/repo
```

### 问题 3：版本兼容性问题

```bash
# 使用特定版本的 goctl
go install github.com/zeromicro/go-zero/tools/goctl@v1.4.0

# 使用兼容的模板版本
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/v1.4.0
```

## 最佳实践

### 1. 模板版本管理

```bash
# 使用语义化版本标签
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/v1.2.3

# 使用稳定分支
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/repo/tree/stable
```

### 2. 模板缓存

```bash
# 克隆模板到本地缓存
git clone https://github.com/username/repo ~/.goctl-templates/username-repo

# 使用本地缓存
goctl api go -api user.api -dir . --style goZero --home ~/.goctl-templates/username-repo
```

### 3. 模板验证

```bash
# 创建验证脚本
cat > validate_template.sh << 'EOF'
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
EOF

chmod +x validate_template.sh
./validate_template.sh https://github.com/username/repo
```

## 模板开发指南

### 1. 创建自己的模板仓库

```bash
# 创建模板仓库
mkdir my-goctl-templates
cd my-goctl-templates

# 复制现有模板
cp -r /path/to/existing/templates/* .

# 推送到 GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/my-goctl-templates
git push -u origin main
```

### 2. 发布模板版本

```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# 创建 GitHub Release
# 在 GitHub 网页上创建 Release 并上传模板文件
```

### 3. 模板文档

```markdown
# 在模板仓库中添加 README.md

## 使用方法

```bash
goctl api go -api user.api -dir . --style goZero --home https://github.com/username/my-goctl-templates
```

## 特性

- 分层架构支持
- 错误处理增强
- 日志记录优化
- 缓存支持
```

## 总结

使用 GitHub 上的 goctl 模板可以：

1. **提高开发效率** - 使用社区维护的成熟模板
2. **保持一致性** - 在团队中统一代码风格
3. **版本管理** - 通过 Git 标签管理模板版本
4. **易于分享** - 将自定义模板分享给社区
5. **持续更新** - 模板可以持续改进和更新

通过合理使用 GitHub 模板，您可以大大提升 goctl 的使用体验和代码生成质量。 