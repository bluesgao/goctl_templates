package repository

import (
	"context"
	"encoding/json"

	"github.com/zeromicro/go-zero/core/logx"
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
	logx.Logger
}

// New{{.repoName}}Repository 创建 Repository 实例
func New{{.repoName}}Repository(db *gorm.DB) {{.repoName}}Repository {
	return &{{.repoName}}RepositoryImpl{
		db:     db,
		Logger: logx.WithContext(context.Background()),
	}
}

// {{.method}} 实现{{.method}}数据访问逻辑
func (r *{{.repoName}}RepositoryImpl) {{.method}}(ctx context.Context, data interface{}) (interface{}, error) {
	r.Infof("{{.repoName}}Repository.{{.method}} called with data: %+v", data)
	
	// 1. 数据验证
	if err := r.validateData(data); err != nil {
		r.Errorf("数据验证失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 2. 数据转换
	model, err := r.convertToModel(data)
	if err != nil {
		r.Errorf("数据转换失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 3. 执行数据库操作
	result, err := r.executeDatabaseOperation(ctx, model)
	if err != nil {
		r.Errorf("数据库操作失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 4. 结果转换
	response, err := r.convertToResponse(result)
	if err != nil {
		r.Errorf("结果转换失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	r.Infof("{{.repoName}}Repository.{{.method}} completed successfully")
	return response, nil
}

// validateData 验证数据
func (r *{{.repoName}}RepositoryImpl) validateData(data interface{}) error {
	// TODO: 根据实际业务需求添加数据验证逻辑
	return nil
}

// convertToModel 转换为模型
func (r *{{.repoName}}RepositoryImpl) convertToModel(data interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据转换逻辑
	return nil, nil
}

// executeDatabaseOperation 执行数据库操作
func (r *{{.repoName}}RepositoryImpl) executeDatabaseOperation(ctx context.Context, model interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现数据库操作逻辑
	return nil, nil
}

// convertToResponse 转换为响应
func (r *{{.repoName}}RepositoryImpl) convertToResponse(result interface{}) (interface{}, error) {
	// TODO: 根据实际业务需求实现响应转换逻辑
	return nil, nil
} 