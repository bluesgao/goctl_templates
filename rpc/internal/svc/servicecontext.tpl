package svc

import (
	"context"
	"fmt"
	"time"

	"{{.package}}/internal/config"
	"{{.package}}/internal/repository"
	"{{.package}}/internal/service"
	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/stores/redis"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type ServiceContext struct {
	Config config.Config
	// 数据库连接
	DB *gorm.DB
	// Redis 连接
	Redis redis.Redis
	
	// Repository 层
	{{.repoName}}Repo repository.{{.repoName}}Repository
	
	// Service 层
	{{.serviceName}}Service *service.{{.serviceName}}Service
}

func NewServiceContext(c config.Config) *ServiceContext {
	// 初始化数据库连接
	db := initDB(c)
	
	// 初始化 Redis 连接
	redisClient := initRedis(c)
	
	// 初始化 Repository 层
	{{.repoName}}Repo := repository.New{{.repoName}}Repository(db, redisClient)
	
	// 初始化 Service 层
	{{.serviceName}}Service := service.New{{.serviceName}}Service({{.repoName}}Repo, db)
	
	return &ServiceContext{
		Config:      c,
		DB:          db,
		Redis:       redisClient,
		{{.repoName}}Repo: {{.repoName}}Repo,
		{{.serviceName}}Service: {{.serviceName}}Service,
	}
}

// initDB 初始化数据库连接
func initDB(c config.Config) *gorm.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=%s&parseTime=%t&loc=%s",
		c.DataSource.Username,
		c.DataSource.Password,
		c.DataSource.Host,
		c.DataSource.Port,
		c.DataSource.Database,
		c.DataSource.Charset,
		c.DataSource.ParseTime,
		c.DataSource.Loc,
	)
	
	// 配置 GORM 日志
	gormLogger := logger.New(
		logx.WithContext(context.Background()),
		logger.Config{
			SlowThreshold:             time.Second,
			LogLevel:                  logger.Info,
			IgnoreRecordNotFoundError: true,
			Colorful:                  false,
		},
	)
	
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: gormLogger,
	})
	
	if err != nil {
		logx.Errorf("数据库连接失败: %v", err)
		panic(fmt.Sprintf("数据库连接失败: %v", err))
	}
	
	// 配置连接池
	sqlDB, err := db.DB()
	if err != nil {
		logx.Errorf("获取数据库实例失败: %v", err)
		panic(fmt.Sprintf("获取数据库实例失败: %v", err))
	}
	
	// 设置连接池参数
	sqlDB.SetMaxIdleConns(c.DataSource.MaxIdleConns)
	sqlDB.SetMaxOpenConns(c.DataSource.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(c.DataSource.ConnMaxLifetime) * time.Second)
	
	// 测试连接
	if err := sqlDB.Ping(); err != nil {
		logx.Errorf("数据库连接测试失败: %v", err)
		panic(fmt.Sprintf("数据库连接测试失败: %v", err))
	}
	
	logx.Infof("数据库连接成功: %s:%d/%s", c.DataSource.Host, c.DataSource.Port, c.DataSource.Database)
	return db
}

// initRedis 初始化 Redis 连接
func initRedis(c config.Config) redis.Redis {
	redisConfig := redis.RedisConf{
		Host: c.Redis.Host,
		Type: "node",
		Pass: c.Redis.Password,
		Key:  "",
	}
	
	redisClient := redis.MustNewRedis(redisConfig)
	
	// 测试连接
	if err := redisClient.Ping(); err != nil {
		logx.Errorf("Redis连接失败: %v", err)
		panic(fmt.Sprintf("Redis连接失败: %v", err))
	}
	
	logx.Infof("Redis连接成功: %s:%d", c.Redis.Host, c.Redis.Port)
	return redisClient
}

// Close 关闭所有连接
func (sc *ServiceContext) Close() {
	if sc.DB != nil {
		if sqlDB, err := sc.DB.DB(); err == nil {
			sqlDB.Close()
		}
	}
	
	if sc.Redis != nil {
		sc.Redis.Close()
	}
	
	logx.Info("所有连接已关闭")
} 