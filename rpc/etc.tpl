Name: {{.serviceName}}
Host: 0.0.0.0
Port: {{.port}}
Timeout: 30000

# 数据库配置
DataSource:
  Host: localhost
  Port: 3306
  Username: root
  Password: password
  Database: {{.serviceName}}
  Charset: utf8mb4
  ParseTime: true
  Loc: Local
  MaxIdleConns: 10
  MaxOpenConns: 100
  ConnMaxLifetime: 3600
  # 连接池配置
  PoolSize: 10
  MinIdleConns: 5
  # 慢查询配置
  SlowThreshold: 1000
  # 日志配置
  LogLevel: info
  IgnoreRecordNotFoundError: true

# Redis 配置
Redis:
  Host: localhost
  Port: 6379
  Password: ""
  Database: 0
  PoolSize: 10
  MinIdleConns: 5
  # 连接超时配置
  DialTimeout: 5000
  ReadTimeout: 3000
  WriteTimeout: 3000
  # 重试配置
  MaxRetries: 3
  MinRetryBackoff: 8
  MaxRetryBackoff: 512

# 日志配置
Log:
  Level: info
  Mode: console
  Path: logs
  Compress: false
  KeepDays: 7
  StackCooldownMillis: 100
  # 日志格式配置
  TimeFormat: "2006-01-02 15:04:05"
  # 日志轮转配置
  MaxSize: 100
  MaxBackups: 10
  MaxAge: 30

# 链路追踪配置
Telemetry:
  Endpoint: http://localhost:14268/api/traces
  Sampler: 1.0
  Batcher: jaeger
  # 采样配置
  SampleRate: 1.0
  # 服务名称
  ServiceName: "{{.serviceName}}"

# 监控配置
Prometheus:
  Host: 0.0.0.0
  Port: 9090
  Path: /metrics
  # 指标配置
  EnableMetrics: true
  # 健康检查配置
  HealthCheckPath: /health

# 健康检查配置
Health:
  Host: 0.0.0.0
  Port: 8080
  Path: /health
  # 检查间隔
  CheckInterval: 30s
  # 超时时间
  Timeout: 5s

# 中间件配置
Middleware:
  # 限流配置
  RateLimit:
    Enabled: true
    Rate: 100
    Burst: 200
  # 熔断配置
  CircuitBreaker:
    Enabled: true
    Threshold: 5
    Timeout: 60s
  # 重试配置
  Retry:
    Enabled: true
    MaxAttempts: 3
    Backoff: 100ms

# 缓存配置
Cache:
  # 本地缓存配置
  Local:
    Enabled: true
    Size: 1000
    TTL: 300s
  # 分布式缓存配置
  Distributed:
    Enabled: true
    TTL: 3600s

# 安全配置
Security:
  # JWT 配置
  JWT:
    Secret: "your-jwt-secret"
    ExpireHours: 24
  # CORS 配置
  CORS:
    Enabled: true
    AllowOrigins: ["*"]
    AllowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    AllowHeaders: ["*"]

# 业务配置
Business:
  # 分页配置
  Pagination:
    DefaultPageSize: 20
    MaxPageSize: 100
  # 文件上传配置
  Upload:
    MaxSize: 10MB
    AllowedTypes: ["jpg", "jpeg", "png", "gif"]
    UploadPath: "./uploads"
  # 通知配置
  Notification:
    Email:
      Enabled: true
      SMTPHost: "smtp.gmail.com"
      SMTPPort: 587
      Username: "your-email@gmail.com"
      Password: "your-password"
    SMS:
      Enabled: false
      Provider: "twilio"
      AccountSid: ""
      AuthToken: "" 