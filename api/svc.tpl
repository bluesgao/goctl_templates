package svc

import (
	"{{.package}}/internal/config"
	"{{.package}}/internal/repository"
	"{{.package}}/internal/service"
	"github.com/zeromicro/go-zero/core/stores/redis"
	"gorm.io/gorm"
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
	{{.repoName}}Repo := repository.New{{.repoName}}Repository(db)
	
	// 初始化 Service 层
	{{.serviceName}}Service := service.New{{.serviceName}}Service({{.repoName}}Repo)
	
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
	// TODO: 根据实际配置初始化数据库连接
	return nil
}

// initRedis 初始化 Redis 连接
func initRedis(c config.Config) redis.Redis {
	// TODO: 根据实际配置初始化 Redis 连接
	return nil
} 