package service

import (
	"context"
	"encoding/json"

	"github.com/zeromicro/go-zero/core/logx"
	"{{.pbImport}}"
	"{{.package}}/internal/repository"
	"{{.package}}/internal/util"
)

type {{.serviceName}}Service struct {
	{{.repoName}}Repo repository.{{.repoName}}Repository
	logx.Logger
}

func New{{.serviceName}}Service({{.repoName}}Repo repository.{{.repoName}}Repository) *{{.serviceName}}Service {
	return &{{.serviceName}}Service{
		{{.repoName}}Repo: {{.repoName}}Repo,
		Logger:            logx.WithContext(context.Background()),
	}
}

// {{.method}} 处理{{.method}}业务逻辑
func (s *{{.serviceName}}Service) {{.method}}(ctx context.Context, req *{{.pbPackage}}.{{.request}}) (*{{.pbPackage}}.{{.response}}, error) {
	s.Infof("{{.serviceName}}Service.{{.method}} called with request: %+v", req)
	
	// 1. 业务规则验证
	if err := s.validateBusinessRules(ctx, req); err != nil {
		s.Errorf("业务规则验证失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 2. 数据转换和准备
	data, err := s.prepareData(ctx, req)
	if err != nil {
		s.Errorf("数据准备失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 3. 调用 Repository 层进行数据操作
	result, err := s.{{.repoName}}Repo.{{.method}}(ctx, data)
	if err != nil {
		s.Errorf("数据操作失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 4. 构建响应
	response := &{{.pbPackage}}.{{.response}}{
		// TODO: 根据实际业务需求填充响应字段
	}
	
	s.Infof("{{.serviceName}}Service.{{.method}} completed successfully")
	return response, nil
}

// validateBusinessRules 验证业务规则
func (s *{{.serviceName}}Service) validateBusinessRules(ctx context.Context, req *{{.pbPackage}}.{{.request}}) error {
	// TODO: 根据实际业务需求添加业务规则验证逻辑
	return nil
}

// prepareData 准备数据
func (s *{{.serviceName}}Service) prepareData(ctx context.Context, req *{{.pbPackage}}.{{.request}}) (interface{}, error) {
	// TODO: 根据实际业务需求准备数据
	return nil, nil
} 