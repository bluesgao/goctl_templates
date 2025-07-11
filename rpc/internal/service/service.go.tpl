package service

import (
	"context"
	"encoding/json"
	"time"

	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/trace"
	"{{.pbImport}}"
	"{{.package}}/internal/repository"
	"{{.package}}/internal/util"
	"gorm.io/gorm"
)

type {{.serviceName}}Service struct {
	{{.repoName}}Repo repository.{{.repoName}}Repository
	db               *gorm.DB
	logx.Logger
}

func New{{.serviceName}}Service({{.repoName}}Repo repository.{{.repoName}}Repository, db *gorm.DB) *{{.serviceName}}Service {
	return &{{.serviceName}}Service{
		{{.repoName}}Repo: {{.repoName}}Repo,
		db:               db,
		Logger:           logx.WithContext(context.Background()),
	}
}

// {{.method}} 处理{{.method}}业务逻辑
func (s *{{.serviceName}}Service) {{.method}}(ctx context.Context, req *{{.pbPackage}}.{{.request}}) (*{{.pbPackage}}.{{.response}}, error) {
	start := time.Now()
	traceID := trace.TraceIDFromContext(ctx)
	
	s.Infof("[{{.serviceName}}Service.{{.method}}] 开始处理业务逻辑, traceID: %s, request: %+v", traceID, req)
	
	// 1. 业务规则验证
	if err := s.validateBusinessRules(ctx, req); err != nil {
		s.Errorf("[{{.serviceName}}Service.{{.method}}] 业务规则验证失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewValidationError(err.Error())
	}
	
	// 2. 数据转换和准备
	data, err := s.prepareData(ctx, req)
	if err != nil {
		s.Errorf("[{{.serviceName}}Service.{{.method}}] 数据准备失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewInternalError("数据准备失败")
	}
	
	// 3. 执行业务逻辑（支持事务）
	var result interface{}
	err = s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 在事务中执行数据操作
		result, err = s.{{.repoName}}Repo.{{.method}}(ctx, data)
		if err != nil {
			return err
		}
		
		// 执行其他业务逻辑
		if err := s.executeBusinessLogic(ctx, req, result); err != nil {
			return err
		}
		
		return nil
	})
	
	if err != nil {
		s.Errorf("[{{.serviceName}}Service.{{.method}}] 业务逻辑执行失败, traceID: %s, error: %v", traceID, err)
		return nil, err
	}
	
	// 4. 构建响应
	response, err := s.buildResponse(ctx, result)
	if err != nil {
		s.Errorf("[{{.serviceName}}Service.{{.method}}] 构建响应失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewInternalError("构建响应失败")
	}
	
	duration := time.Since(start)
	s.Infof("[{{.serviceName}}Service.{{.method}}] 业务逻辑处理完成, traceID: %s, duration: %v", traceID, duration)
	
	return response, nil
}

// validateBusinessRules 验证业务规则
func (s *{{.serviceName}}Service) validateBusinessRules(ctx context.Context, req *{{.pbPackage}}.{{.request}}) error {
	// TODO: 根据实际业务需求添加业务规则验证逻辑
	// 示例：
	// 1. 检查业务状态
	// 2. 验证业务约束
	// 3. 检查业务权限
	
	return nil
}

// prepareData 准备数据
func (s *{{.serviceName}}Service) prepareData(ctx context.Context, req *{{.pbPackage}}.{{.request}}) (interface{}, error) {
	// TODO: 根据实际业务需求准备数据
	// 示例：
	// 1. 数据格式转换
	// 2. 数据验证
	// 3. 数据补充
	
	return req, nil
}

// executeBusinessLogic 执行业务逻辑
func (s *{{.serviceName}}Service) executeBusinessLogic(ctx context.Context, req *{{.pbPackage}}.{{.request}}, result interface{}) error {
	// TODO: 根据实际业务需求执行额外的业务逻辑
	// 示例：
	// 1. 发送通知
	// 2. 更新缓存
	// 3. 记录审计日志
	
	return nil
}

// buildResponse 构建响应
func (s *{{.serviceName}}Service) buildResponse(ctx context.Context, result interface{}) (*{{.pbPackage}}.{{.response}}, error) {
	// TODO: 根据实际业务需求构建响应
	response := &{{.pbPackage}}.{{.response}}{
		// 根据 result 填充响应字段
	}
	
	return response, nil
} 