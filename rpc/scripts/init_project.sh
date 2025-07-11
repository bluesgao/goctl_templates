#!/bin/bash

# 初始化 RPC 项目脚本
# 用于创建基础的分层架构项目结构

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# 交互式参数收集
print_info "欢迎使用 RPC 项目初始化脚本！"
echo ""

# 获取输出目录
while true; do
    read -p "请输入项目输出目录 (例如: ./user): " OUTPUT_DIR
    if [ -n "$OUTPUT_DIR" ]; then
        break
    else
        print_error "输出目录不能为空，请重新输入"
    fi
done

# 获取服务名称
while true; do
    read -p "请输入服务名称 (例如: user): " SERVICE_NAME
    if [ -n "$SERVICE_NAME" ]; then
        # 检查服务名称格式
        if [[ "$SERVICE_NAME" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
            break
        else
            print_error "服务名称只能包含字母和数字，且必须以字母开头"
        fi
    else
        print_error "服务名称不能为空，请重新输入"
    fi
done

# 获取 proto 文件名
read -p "请输入 proto 文件名 (默认: ${SERVICE_NAME}.proto): " PROTO_FILE_INPUT
if [ -z "$PROTO_FILE_INPUT" ]; then
    PROTO_FILE="${SERVICE_NAME}.proto"
else
    PROTO_FILE="$PROTO_FILE_INPUT"
fi

# 确认信息
echo ""
print_info "项目配置信息："
echo "----------------------------------------"
echo "输出目录: $OUTPUT_DIR"
echo "服务名称: $SERVICE_NAME"
echo "Proto 文件: $PROTO_FILE"
echo "----------------------------------------"

# 确认是否继续
while true; do
    read -p "确认创建项目？(y/n): " CONFIRM
    case $CONFIRM in
        [Yy]* ) break;;
        [Nn]* ) 
            print_info "已取消项目创建"
            exit 0
            ;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 高级选项
echo ""
print_info "高级选项配置："

# 是否创建示例代码
while true; do
    read -p "是否创建示例代码？(y/n, 默认: y): " CREATE_EXAMPLES
    case $CREATE_EXAMPLES in
        [Yy]* ) CREATE_EXAMPLES="true"; break;;
        [Nn]* ) CREATE_EXAMPLES="false"; break;;
        "" ) CREATE_EXAMPLES="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含数据库配置
while true; do
    read -p "是否包含数据库配置？(y/n, 默认: y): " INCLUDE_DB
    case $INCLUDE_DB in
        [Yy]* ) INCLUDE_DB="true"; break;;
        [Nn]* ) INCLUDE_DB="false"; break;;
        "" ) INCLUDE_DB="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含 Redis 配置
while true; do
    read -p "是否包含 Redis 配置？(y/n, 默认: y): " INCLUDE_REDIS
    case $INCLUDE_REDIS in
        [Yy]* ) INCLUDE_REDIS="true"; break;;
        [Nn]* ) INCLUDE_REDIS="false"; break;;
        "" ) INCLUDE_REDIS="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

# 是否包含事件处理
while true; do
    read -p "是否包含消息队列功能？(y/n, 默认: y): " INCLUDE_EVENT
    case $INCLUDE_EVENT in
        [Yy]* ) INCLUDE_EVENT="true"; break;;
        [Nn]* ) INCLUDE_EVENT="false"; break;;
        "" ) INCLUDE_EVENT="true"; break;;
        * ) echo "请输入 y 或 n";;
    esac
done

print_info "开始初始化 RPC 项目..."
print_info "输出目录: $OUTPUT_DIR"
print_info "服务名称: $SERVICE_NAME"
print_info "Proto 文件: $PROTO_FILE"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/proto"

# 1. 生成默认的 proto 文件
print_info "步骤 1: 生成默认的 proto 文件..."
cat > "$OUTPUT_DIR/proto/$PROTO_FILE" << EOF
syntax = "proto3";

package $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]');

option go_package = ".";

// 通用响应结果
message Result {
  int32 code = 1;           // 响应码
  string message = 2;        // 响应消息
  string data = 3;          // 响应数据（JSON字符串）
}

// 分页请求
message PageRequest {
  int32 page = 1;           // 页码，从1开始
  int32 size = 2;           // 每页大小
  string keyword = 3;       // 搜索关键词
  map<string, string> filters = 4;  // 过滤条件
  repeated Sort sorts = 5;  // 排序参数
}

// 分页响应
message PageResponse {
  int32 page = 1;           // 当前页码
  int32 size = 2;           // 每页大小
  int64 total = 3;          // 总记录数
  int32 pages = 4;          // 总页数
  repeated string data = 5;  // 数据列表（JSON字符串数组）
}

// 排序
message Sort {
  string field = 1;         // 排序字段
  string order = 2;         // 排序方向：asc/desc
}


// ${SERVICE_NAME} 服务
service ${SERVICE_NAME} {

  // hello
  rpc Hello(HelloRequest) returns (HelloResponse);
  }


// hello请求
message HelloRequest {
  string name = 1;            // 名字
}

// hello响应
message HelloResponse {
  Result result = 1;        // 响应结果
}

EOF

print_info "Proto 文件已生成: $PROTO_FILE"

# 2. 生成基础的 RPC 服务结构
print_info "步骤 2: 生成基础 RPC 服务结构..."
goctl -v -c=false rpc protoc "$OUTPUT_DIR/proto/$PROTO_FILE" \
    --go_out="$OUTPUT_DIR/types/shared" \
    --go-grpc_out="$OUTPUT_DIR/types/shared" \
    --zrpc_out="$OUTPUT_DIR" \
    --style go_zero \
    --home ../templates

# 3. 创建分层目录结构
print_info "步骤 3: 创建分层目录结构..."
mkdir -p "$OUTPUT_DIR/internal/logic"
mkdir -p "$OUTPUT_DIR/internal/service"
mkdir -p "$OUTPUT_DIR/internal/repository"
mkdir -p "$OUTPUT_DIR/internal/model"
mkdir -p "$OUTPUT_DIR/internal/util"
mkdir -p "$OUTPUT_DIR/internal/middleware"
mkdir -p "$OUTPUT_DIR/internal/constants"
mkdir -p "$OUTPUT_DIR/internal/config"
mkdir -p "$OUTPUT_DIR/docs"
mkdir -p "$OUTPUT_DIR/scripts"

# 根据用户选择创建可选目录
if [ "$INCLUDE_EVENT" = "true" ]; then
    mkdir -p "$OUTPUT_DIR/internal/event"
    print_info "已创建 Event 目录"
fi

# 4. 生成 Util 工具类
print_info "步骤 4: 生成 Util 工具类..."
if [ "$CREATE_EXAMPLES" = "true" ]; then
    cat > "$OUTPUT_DIR/internal/util/errcode.go" << EOF
package util

import (
	"errors"
	"fmt"
)

// 错误码定义
const (
	// 通用错误码
	ErrCodeSuccess        = 0
	ErrCodeParamInvalid   = 400
	ErrCodeUnauthorized   = 401
	ErrCodeForbidden      = 403
	ErrCodeNotFound       = 404
	ErrCodeInternalError  = 500
	ErrCodeServiceUnavailable = 503
	
	// 业务错误码 (1000-1999)
	ErrCodeUserNotFound      = 1001
	ErrCodeUserAlreadyExists = 1002
	ErrCodePasswordInvalid   = 1003
	ErrCodeTokenInvalid      = 1004
	ErrCodeTokenExpired      = 1005
	
	// 数据库错误码 (2000-2999)
	ErrCodeDBConnectionFailed = 2001
	ErrCodeDBQueryFailed      = 2002
	ErrCodeDBInsertFailed     = 2003
	ErrCodeDBUpdateFailed     = 2004
	ErrCodeDBDeleteFailed     = 2005
)

// 错误信息映射
var errMsgMap = map[int]string{
	ErrCodeSuccess:              "成功",
	ErrCodeParamInvalid:         "参数无效",
	ErrCodeUnauthorized:         "未授权",
	ErrCodeForbidden:            "禁止访问",
	ErrCodeNotFound:             "资源不存在",
	ErrCodeInternalError:        "内部服务器错误",
	ErrCodeServiceUnavailable:   "服务不可用",
	ErrCodeUserNotFound:         "用户不存在",
	ErrCodeUserAlreadyExists:    "用户已存在",
	ErrCodePasswordInvalid:      "密码无效",
	ErrCodeTokenInvalid:         "令牌无效",
	ErrCodeTokenExpired:         "令牌已过期",
	ErrCodeDBConnectionFailed:   "数据库连接失败",
	ErrCodeDBQueryFailed:        "数据库查询失败",
	ErrCodeDBInsertFailed:       "数据库插入失败",
	ErrCodeDBUpdateFailed:       "数据库更新失败",
	ErrCodeDBDeleteFailed:       "数据库删除失败",
}

// NewError 创建新的错误
func NewError(message string) error {
	return errors.New(message)
}

// NewErrorWithCode 创建带错误码的错误
func NewErrorWithCode(code int) error {
	msg, ok := errMsgMap[code]
	if !ok {
		msg = "未知错误"
	}
	return errors.New(fmt.Sprintf("[%d] %s", code, msg))
}

// NewErrorWithCodeAndMsg 创建带错误码和自定义消息的错误
func NewErrorWithCodeAndMsg(code int, message string) error {
	return errors.New(fmt.Sprintf("[%d] %s", code, message))
}

// GetErrorMsg 获取错误码对应的错误信息
func GetErrorMsg(code int) string {
	msg, ok := errMsgMap[code]
	if !ok {
		return "未知错误"
	}
	return msg
}
EOF

# 5. 生成基础工具函数
print_info "步骤 5: 生成基础工具函数..."
if [ "$CREATE_EXAMPLES" = "true" ]; then
    cat > "$OUTPUT_DIR/internal/util/utils.go" << EOF
package util

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"
)

// StringToMD5 字符串转MD5
func StringToMD5(str string) string {
	h := md5.New()
	h.Write([]byte(str))
	return hex.EncodeToString(h.Sum(nil))
}

// StructToJSON 结构体转JSON字符串
func StructToJSON(v interface{}) string {
	bytes, err := json.Marshal(v)
	if err != nil {
		return ""
	}
	return string(bytes)
}

// JSONToStruct JSON字符串转结构体
func JSONToStruct(jsonStr string, v interface{}) error {
	return json.Unmarshal([]byte(jsonStr), v)
}

// FormatTime 格式化时间
func FormatTime(t time.Time) string {
	return t.Format("2006-01-02 15:04:05")
}

// ParseTime 解析时间字符串
func ParseTime(timeStr string) (time.Time, error) {
	return time.Parse("2006-01-02 15:04:05", timeStr)
}

// GenerateID 生成ID
func GenerateID() string {
	return fmt.Sprintf("%d", time.Now().UnixNano())
}
EOF
fi

# 6. 生成 README 文档
print_info "步骤 6: 生成 README 文档..."
if [ "$CREATE_EXAMPLES" = "true" ]; then
    cat > "$OUTPUT_DIR/README.md" << EOF
# ${SERVICE_NAME} Service

这是一个使用分层架构的 RPC 服务，采用 Logic -> Service -> Repository -> Model 的分层设计（已移除Handler层）。

## 项目结构

\`\`\`
${OUTPUT_DIR}/
├── internal/
│   ├── logic/            # Logic 层（请求入口和业务逻辑）
│   ├── service/          # Service 层
│   ├── repository/       # Repository 层
│   ├── model/           # Model 层
│   ├── event/           # Event 层（消息队列处理）
│   ├── svc/             # 依赖注入
│   ├── types/           # 类型定义
│   ├── util/            # 工具类
│   ├── middleware/      # 中间件
│   ├── constants/       # 常量定义
│   └── config/          # 配置结构
├── proto/               # Proto 文件目录
│   └── $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]').proto
├── etc/
│   └── $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]').yaml
├── docs/                # 文档
├── scripts/             # 脚本
└── $(echo ${SERVICE_NAME} | tr '[:upper:]' '[:lower:]').go
\`\`\`

## 分层架构

1. **Logic 层**: 请求入口、参数验证、权限验证、业务逻辑处理
2. **Service 层**: 业务规则验证、数据转换、业务逻辑处理
3. **Repository 层**: 数据库操作、缓存处理、数据转换
4. **Model 层**: 数据结构定义、ORM 映射、数据验证
5. **Event 层**: 消息队列处理、事件发布、事件订阅、异步任务处理

## 使用方法

1. 使用 \`scripts/add_service.sh\` 添加新的 Service
2. 使用 \`scripts/add_repo.sh\` 添加新的 Repository
3. 根据 proto 文件中的方法，在 Logic 层实现请求入口和业务逻辑
4. 在 Service 层实现业务规则和事务管理
5. 在 Repository 层实现数据访问逻辑
6. 在 Model 层定义数据结构
7. 在 Event 层处理消息队列、事件发布和订阅

## 注意事项

- 严格遵循分层调用规则：Logic → Service → Repository → Model
- Event 层可以独立处理消息队列事件，也可以被其他层调用
- 每一层都有明确的职责，避免跨层调用
- 使用统一的错误处理和日志记录
- 在 ServiceContext 中统一管理依赖注入
- Event 层支持多种消息队列系统（Kafka、RabbitMQ、Redis、Nats）

## Proto 文件说明

生成的 proto 文件包含以下通用 message：

- **Result**: 通用响应结果
- **PageRequest/PageResponse**: 分页请求和响应
- **Sort**: 排序参数
- **BaseEntity**: 基础实体信息
- **FileInfo**: 文件信息
- **UserInfo**: 用户信息

这些通用 message 可以在多个服务中复用。
EOF
fi

print_info "RPC 项目初始化完成！"
print_info "输出目录: $OUTPUT_DIR"
print_info "Proto 文件: $OUTPUT_DIR/proto/$PROTO_FILE"

# 根据用户选择显示不同的信息
if [ "$CREATE_EXAMPLES" = "true" ]; then
    print_info "已生成示例代码文件"
fi

if [ "$INCLUDE_EVENT" = "true" ]; then
    print_info "已包含事件处理功能"
fi

if [ "$INCLUDE_DB" = "true" ]; then
    print_info "已包含数据库配置"
fi

if [ "$INCLUDE_REDIS" = "true" ]; then
    print_info "已包含 Redis 配置"
fi

print_warn "接下来可以使用以下脚本添加功能："
print_warn "1. ./scripts/add_service.sh <service_name> <repo_name> - 添加新的 Service"
print_warn "2. ./scripts/add_repo.sh <repo_name> <model_name> - 添加新的 Repository"

if [ "$INCLUDE_EVENT" = "true" ]; then
    print_warn "3. Event 层已创建，支持消息队列处理，包含以下文件："
    print_warn "   - internal/event/event.go.tpl - 事件基础结构"
    print_warn "   - internal/event/mq_connector.go.tpl - MQ连接器"
    print_warn "   - internal/event/handler.go.tpl - 事件处理器示例"
fi
fi 