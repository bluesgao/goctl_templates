package constants

// 系统常量
const (
	// 应用信息
	AppName    = "{{.serviceName}}"
	AppVersion = "1.0.0"
	AppEnv     = "production"
	
	// 时间格式
	TimeFormat      = "2006-01-02 15:04:05"
	DateFormat      = "2006-01-02"
	TimeFormatShort = "01-02 15:04"
	
	// 分页默认值
	DefaultPageSize = 20
	MaxPageSize     = 100
	
	// 缓存相关
	DefaultCacheTTL = 3600 // 1小时
	MaxCacheTTL     = 86400 // 24小时
	
	// 文件上传
	MaxFileSize     = 10 * 1024 * 1024 // 10MB
	AllowedImageTypes = "jpg,jpeg,png,gif"
	AllowedDocTypes  = "pdf,doc,docx,xls,xlsx"
	
	// 密码相关
	MinPasswordLength = 6
	MaxPasswordLength = 20
	
	// 用户名相关
	MinUsernameLength = 3
	MaxUsernameLength = 20
	
	// 手机号相关
	PhoneLength = 11
	
	// 身份证号相关
	IDCardLength = 18
)

// 状态常量
const (
	// 通用状态
	StatusActive   = 1
	StatusInactive = 0
	StatusDeleted  = -1
	
	// 用户状态
	UserStatusNormal    = 1
	UserStatusDisabled  = 0
	UserStatusDeleted   = -1
	
	// 订单状态
	OrderStatusPending   = 1
	OrderStatusPaid      = 2
	OrderStatusShipped   = 3
	OrderStatusDelivered = 4
	OrderStatusCancelled = 5
	OrderStatusRefunded  = 6
	
	// 支付状态
	PaymentStatusPending = 1
	PaymentStatusSuccess = 2
	PaymentStatusFailed  = 3
	PaymentStatusRefund  = 4
)

// 角色常量
const (
	// 用户角色
	RoleAdmin    = "admin"
	RoleUser     = "user"
	RoleGuest    = "guest"
	RoleModerator = "moderator"
	
	// 权限级别
	PermissionLevelNone   = 0
	PermissionLevelRead   = 1
	PermissionLevelWrite  = 2
	PermissionLevelAdmin  = 3
)

// 业务常量
const (
	// 验证码相关
	VerifyCodeLength = 6
	VerifyCodeExpire = 300 // 5分钟
	
	// Token相关
	TokenExpireHours = 24
	RefreshTokenExpireHours = 168 // 7天
	
	// 限流相关
	RateLimitDefault = 100
	RateLimitBurst   = 200
	
	// 超时相关
	DefaultTimeout = 30 // 30秒
	ShortTimeout   = 5  // 5秒
	LongTimeout    = 300 // 5分钟
)

// 错误消息常量
const (
	// 通用错误消息
	ErrMsgSuccess           = "操作成功"
	ErrMsgParamInvalid     = "参数无效"
	ErrMsgUnauthorized     = "未授权访问"
	ErrMsgForbidden        = "禁止访问"
	ErrMsgNotFound         = "资源不存在"
	ErrMsgInternalError    = "内部服务器错误"
	ErrMsgServiceUnavailable = "服务不可用"
	
	// 用户相关错误消息
	ErrMsgUserNotFound     = "用户不存在"
	ErrMsgUserExists       = "用户已存在"
	ErrMsgPasswordInvalid  = "密码错误"
	ErrMsgTokenInvalid     = "令牌无效"
	ErrMsgTokenExpired     = "令牌已过期"
	ErrMsgUserDisabled     = "用户已被禁用"
	
	// 业务相关错误消息
	ErrMsgOrderNotFound    = "订单不存在"
	ErrMsgOrderCancelled   = "订单已取消"
	ErrMsgPaymentFailed    = "支付失败"
	ErrMsgInsufficientBalance = "余额不足"
	ErrMsgResourceNotFound = "资源不存在"
	ErrMsgResourceExists   = "资源已存在"
	ErrMsgOperationFailed  = "操作失败"
)

// 缓存键前缀
const (
	// 用户相关缓存
	CacheKeyUser     = "user"
	CacheKeyUserInfo = "user:info"
	CacheKeyUserToken = "user:token"
	
	// 业务相关缓存
	CacheKeyOrder    = "order"
	CacheKeyProduct  = "product"
	CacheKeyCategory = "category"
	
	// 系统相关缓存
	CacheKeyConfig   = "config"
	CacheKeyDict     = "dict"
	CacheKeyMenu     = "menu"
)

// 数据库相关常量
const (
	// 数据库表名
	TableUser     = "users"
	TableOrder    = "orders"
	TableProduct  = "products"
	TableCategory = "categories"
	TableConfig   = "configs"
	TableDict     = "dicts"
	TableMenu     = "menus"
	
	// 数据库字段
	FieldID        = "id"
	FieldCreatedAt = "created_at"
	FieldUpdatedAt = "updated_at"
	FieldDeletedAt = "deleted_at"
	FieldStatus    = "status"
	FieldUserID    = "user_id"
	FieldOrderID   = "order_id"
	FieldProductID = "product_id"
)

// 日志相关常量
const (
	// 日志级别
	LogLevelDebug = "debug"
	LogLevelInfo  = "info"
	LogLevelWarn  = "warn"
	LogLevelError = "error"
	LogLevelFatal = "fatal"
	
	// 日志字段
	LogFieldTraceID = "trace_id"
	LogFieldUserID  = "user_id"
	LogFieldMethod  = "method"
	LogFieldDuration = "duration"
	LogFieldError   = "error"
)

// 监控相关常量
const (
	// 指标名称
	MetricRequestTotal   = "request_total"
	MetricRequestDuration = "request_duration"
	MetricErrorTotal     = "error_total"
	MetricActiveUsers    = "active_users"
	
	// 标签名称
	LabelMethod = "method"
	LabelStatus = "status"
	LabelError  = "error"
	LabelUserID = "user_id"
)

// 通知相关常量
const (
	// 通知类型
	NotifyTypeEmail = "email"
	NotifyTypeSMS   = "sms"
	NotifyTypePush  = "push"
	NotifyTypeWebhook = "webhook"
	
	// 通知模板
	NotifyTemplateWelcome = "welcome"
	NotifyTemplateResetPassword = "reset_password"
	NotifyTemplateOrderConfirm = "order_confirm"
	NotifyTemplatePaymentSuccess = "payment_success"
)

// 文件相关常量
const (
	// 文件类型
	FileTypeImage = "image"
	FileTypeDoc   = "document"
	FileTypeVideo = "video"
	FileTypeAudio = "audio"
	
	// 文件路径
	FilePathUpload = "./uploads"
	FilePathTemp   = "./temp"
	FilePathLog    = "./logs"
	
	// 文件扩展名
	FileExtJPG  = ".jpg"
	FileExtJPEG = ".jpeg"
	FileExtPNG  = ".png"
	FileExtGIF  = ".gif"
	FileExtPDF  = ".pdf"
	FileExtDOC  = ".doc"
	FileExtDOCX = ".docx"
) 