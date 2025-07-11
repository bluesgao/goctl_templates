# init_proto.sh 修复版使用指南

## 修复内容

### 1. 自动检测 Google protobuf 文件

脚本现在会自动检测系统中是否存在 Google protobuf 文件：

```bash
# 检查 Google protobuf 文件是否存在
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}' 2>/dev/null || echo "/usr/local/include")

if [ ! -f "$PROTOC_INCLUDE_PATH/google/protobuf/timestamp.proto" ]; then
    print_warn "Google protobuf 文件不存在，将使用字符串格式的时间戳"
    INCLUDE_IMPORTS="false"
fi
```

### 2. 智能时间戳处理

- **如果 Google protobuf 文件存在**：使用 `google.protobuf.Timestamp`
- **如果 Google protobuf 文件不存在**：使用 `string timestamp`

```protobuf
// Hello 响应
message HelloResponse {
  Result result = 1;        // 响应结果
  string message = 2;       // 问候消息
  string timestamp = 3;     // 当前时间（字符串格式）
}
```

### 3. 增强的错误处理

- 自动检测依赖文件
- 提供清晰的错误提示
- 建议修复方案

### 4. 改进的用户提示

```bash
if [ "$INCLUDE_IMPORTS" = "true" ]; then
    print_info "已包含常用导入语句"
else
    print_warn "未包含 Google protobuf 导入，使用字符串格式的时间戳"
fi
```

## 使用方法

### 基本使用

```bash
./init_proto.sh
```

### 交互式流程

1. **输出目录**
   ```
   请输入输出目录 (例如: ./proto): ./myproto
   ```

2. **服务名称**
   ```
   请输入服务名称 (例如: user): user
   ```

3. **Proto 文件名**
   ```
   请输入 proto 文件名 (默认: user.proto): 
   ```

4. **确认信息**
   ```
   Proto 文件配置信息：
   ----------------------------------------
   输出目录: ./myproto
   服务名称: user
   Proto 文件: user.proto
   ----------------------------------------
   确认创建 Proto 文件？(y/n): y
   ```

5. **高级选项配置**
   ```
   高级选项配置：
   是否包含通用消息 (Result, PageRequest 等)？(y/n, 默认: y): y
   是否包含示例服务方法？(y/n, 默认: y): y
   是否包含详细注释？(y/n, 默认: y): y
   是否包含常用导入语句？(y/n, 默认: y): y
   ```

## 智能导入处理

### 自动检测逻辑

```bash
# 检查 Google protobuf 文件是否存在
PROTOC_INCLUDE_PATH=$(protoc --print_free_field_numbers 2>&1 | grep "include" | head -1 | awk '{print $2}' 2>/dev/null || echo "/usr/local/include")

if [ ! -f "$PROTOC_INCLUDE_PATH/google/protobuf/timestamp.proto" ]; then
    print_warn "Google protobuf 文件不存在，将使用字符串格式的时间戳"
    INCLUDE_IMPORTS="false"
else
    IMPORTS="import \"google/protobuf/timestamp.proto\";
import \"google/protobuf/empty.proto\";
"
fi
```

### 生成的文件差异

**包含 Google protobuf 导入的版本：**
```protobuf
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

message HelloResponse {
  Result result = 1;
  string message = 2;
  google.protobuf.Timestamp timestamp = 3;
}
```

**不包含 Google protobuf 导入的版本：**
```protobuf
message HelloResponse {
  Result result = 1;
  string message = 2;
  string timestamp = 3;  // 字符串格式
}
```

## 故障排除

### 1. Google protobuf 文件不存在

如果遇到以下错误：
```
google/protobuf/timestamp.proto: File not found.
```

**解决方案：**

1. **运行修复脚本**
   ```bash
   ./fix_protobuf_imports.sh
   ```

2. **手动安装**
   ```bash
   # macOS
   brew install protobuf
   
   # Ubuntu
   sudo apt-get install protobuf-compiler
   ```

3. **使用简化版本**
   ```bash
   ./init_proto_simple.sh
   ```

### 2. 编译失败

如果编译失败，检查：

```bash
# 检查 protoc 是否安装
which protoc

# 检查 Go 插件是否安装
which protoc-gen-go
which protoc-gen-go-grpc

# 安装缺失的插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### 3. 权限问题

```bash
# 确保脚本有执行权限
chmod +x init_proto.sh
chmod +x fix_protobuf_imports.sh
chmod +x init_proto_simple.sh
```

## 测试脚本

### 运行测试

```bash
# 测试修复后的功能
./test_init_proto_fixed.sh

# 测试简化版本
./test_init_proto.sh
```

### 测试内容

1. **文件生成测试**
   - 检查 proto 文件是否生成
   - 检查 README 文件是否生成
   - 检查编译脚本是否生成

2. **内容验证测试**
   - 检查是否包含 Hello 方法
   - 检查是否包含 HelloRequest/Response
   - 检查时间戳字段类型

3. **编译测试**
   - 测试 protoc 编译功能
   - 检查生成的 Go 代码文件

## 版本对比

| 功能 | 原版本 | 修复版本 | 简化版本 |
|------|--------|----------|----------|
| Google protobuf 导入 | 强制使用 | 智能检测 | 不使用 |
| 时间戳格式 | Timestamp | 智能选择 | String |
| 错误处理 | 基础 | 增强 | 基础 |
| 用户提示 | 基础 | 详细 | 基础 |
| 兼容性 | 低 | 高 | 最高 |

## 推荐使用场景

### 修复版本 (init_proto.sh)
- 需要 Google protobuf 功能
- 希望自动处理依赖问题
- 需要详细的错误提示

### 简化版本 (init_proto_simple.sh)
- 快速原型开发
- 避免依赖问题
- 简单的项目结构

### 修复脚本 (fix_protobuf_imports.sh)
- 解决 Google protobuf 导入问题
- 安装缺失的依赖文件
- 验证编译环境

## 示例输出

### 成功场景
```
[INFO] 开始创建 Proto 文件...
[INFO] 输出目录: ./myproto
[INFO] 服务名称: user
[INFO] Proto 文件: user.proto
[INFO] 步骤 1: 生成 Proto 文件...
[INFO] Proto 文件已生成: ./myproto/user.proto
[INFO] 步骤 2: 生成 README 文档...
[INFO] README 文档已生成: ./myproto/README.md
[INFO] 步骤 3: 生成编译脚本...
[INFO] 编译脚本已生成: ./myproto/compile.sh
[INFO] 已包含通用消息定义
[INFO] 已包含示例服务方法
[INFO] 已包含详细注释
[INFO] 已包含常用导入语句
[INFO] Proto 文件创建完成！
```

### 警告场景
```
[WARN] Google protobuf 文件不存在，将使用字符串格式的时间戳
[WARN] 未包含 Google protobuf 导入，使用字符串格式的时间戳
[WARN] 接下来可以：
[WARN] 1. 使用 compile.sh 编译 proto 文件
[WARN] 2. 根据实际业务需求修改消息定义
[WARN] 3. 在服务中实现对应的 gRPC 方法
[WARN] 4. 如果遇到 Google protobuf 导入问题，可以运行 ./fix_protobuf_imports.sh
```

## 注意事项

1. **自动检测**：脚本会自动检测 Google protobuf 文件是否存在
2. **智能降级**：如果文件不存在，会自动使用字符串格式的时间戳
3. **用户友好**：提供清晰的提示信息和修复建议
4. **向后兼容**：保持原有的功能和接口不变
5. **错误处理**：增强了错误处理和用户提示 