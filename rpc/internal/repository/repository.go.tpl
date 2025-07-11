package repository

import (
	"context"
	"encoding/json"
	"time"

	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/stores/redis"
	"github.com/zeromicro/go-zero/core/trace"
	"{{.package}}/internal/model"
	"{{.package}}/internal/util"
	"gorm.io/gorm"
)

// {{.repoName}}Repository 定义数据访问接口
type {{.repoName}}Repository interface {
	{{.method}}(ctx context.Context, data interface{}) (interface{}, error)
	// TODO: 添加其他数据访问方法
}

// {{.repoName}}RepositoryImpl 实现数据访问接口
type {{.repoName}}RepositoryImpl struct {
	db     *gorm.DB
	redis  redis.Redis
	logx.Logger
}

// New{{.repoName}}Repository 创建 Repository 实例
func New{{.repoName}}Repository(db *gorm.DB, redis redis.Redis) {{.repoName}}Repository {
	return &{{.repoName}}RepositoryImpl{
		db:     db,
		redis:  redis,
		Logger: logx.WithContext(context.Background()),
	}
}

// {{.method}} 实现{{.method}}数据访问逻辑
func (r *{{.repoName}}RepositoryImpl) {{.method}}(ctx context.Context, data interface{}) (interface{}, error) {
	start := time.Now()
	traceID := trace.TraceIDFromContext(ctx)
	
	r.Infof("[{{.repoName}}Repository.{{.method}}] 开始数据访问, traceID: %s, data: %+v", traceID, data)
	
	// 1. 数据验证
	if err := r.validateData(data); err != nil {
		r.Errorf("[{{.repoName}}Repository.{{.method}}] 数据验证失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewValidationError(err.Error())
	}
	
	// 2. 尝试从缓存获取数据
	if cached, err := r.getFromCache(ctx, data); err == nil && cached != nil {
		r.Infof("[{{.repoName}}Repository.{{.method}}] 从缓存获取数据成功, traceID: %s", traceID)
		return cached, nil
	}
	
	// 3. 数据转换
	model, err := r.convertToModel(data)
	if err != nil {
		r.Errorf("[{{.repoName}}Repository.{{.method}}] 数据转换失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewInternalError("数据转换失败")
	}
	
	// 4. 执行数据库操作
	result, err := r.executeDatabaseOperation(ctx, model)
	if err != nil {
		r.Errorf("[{{.repoName}}Repository.{{.method}}] 数据库操作失败, traceID: %s, error: %v", traceID, err)
		return nil, err
	}
	
	// 5. 结果转换
	response, err := r.convertToResponse(result)
	if err != nil {
		r.Errorf("[{{.repoName}}Repository.{{.method}}] 结果转换失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewInternalError("结果转换失败")
	}
	
	// 6. 更新缓存
	if err := r.updateCache(ctx, data, response); err != nil {
		r.Warnf("[{{.repoName}}Repository.{{.method}}] 更新缓存失败, traceID: %s, error: %v", traceID, err)
		// 缓存更新失败不影响主流程
	}
	
	duration := time.Since(start)
	r.Infof("[{{.repoName}}Repository.{{.method}}] 数据访问完成, traceID: %s, duration: %v", traceID, duration)
	
	return response, nil
}

// validateData 验证数据
func (r *{{.repoName}}RepositoryImpl) validateData(data interface{}) error {
	if data == nil {
		return util.NewValidationError("数据不能为空")
	}
	
	// TODO: 根据实际业务需求添加数据验证逻辑
	// 示例：
	// if user, ok := data.(*model.User); ok {
	//     if user.Name == "" {
	//         return util.NewValidationError("用户名不能为空")
	//     }
	// }
	
	return nil
}

// getFromCache 从缓存获取数据
func (r *{{.repoName}}RepositoryImpl) getFromCache(ctx context.Context, key interface{}) (interface{}, error) {
	if r.redis == nil {
		return nil, util.NewInternalError("Redis未初始化")
	}
	
	// TODO: 根据实际业务需求实现缓存逻辑
	// 示例：
	// cacheKey := fmt.Sprintf("{{.repoName}}:%v", key)
	// data, err := r.redis.Get(ctx, cacheKey)
	// if err != nil {
	//     return nil, err
	// }
	// 
	// var result interface{}
	// if err := json.Unmarshal([]byte(data), &result); err != nil {
	//     return nil, err
	// }
	// 
	// return result, nil
	
	return nil, util.NewInternalError("缓存未命中")
}

// updateCache 更新缓存
func (r *{{.repoName}}RepositoryImpl) updateCache(ctx context.Context, key interface{}, value interface{}) error {
	if r.redis == nil {
		return nil
	}
	
	// TODO: 根据实际业务需求实现缓存更新逻辑
	// 示例：
	// cacheKey := fmt.Sprintf("{{.repoName}}:%v", key)
	// data, err := json.Marshal(value)
	// if err != nil {
	//     return err
	// }
	// 
	// return r.redis.Setex(ctx, cacheKey, string(data), 3600) // 1小时过期
	
	return nil
}

// convertToModel 转换为模型
func (r *{{.repoName}}RepositoryImpl) convertToModel(data interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据转换逻辑
	// 示例：
	// if req, ok := data.(*types.CreateUserRequest); ok {
	//     return &model.User{
	//         Name:  req.Name,
	//         Email: req.Email,
	//     }, nil
	// }
	
	return data, nil
}

// executeDatabaseOperation 执行数据库操作
func (r *{{.repoName}}RepositoryImpl) executeDatabaseOperation(ctx context.Context, model interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据库操作逻辑
	// 示例：
	// if user, ok := model.(*model.User); ok {
	//     if err := r.db.WithContext(ctx).Create(user).Error; err != nil {
	//         return nil, err
	//     }
	//     return user, nil
	// }
	
	return model, nil
}

// convertToResponse 转换为响应
func (r *{{.repoName}}RepositoryImpl) convertToResponse(result interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现响应转换逻辑
	// 示例：
	// if user, ok := result.(*model.User); ok {
	//     return &types.CreateUserResponse{
	//         Id:   user.ID,
	//         Name: user.Name,
	//     }, nil
	// }
	
	return result, nil
} 