package logic

import (
	"context"
	"encoding/json"

	"github.com/zeromicro/go-zero/core/logx"
	"{{.package}}/internal/svc"
	"{{.package}}/internal/types"
	"{{.package}}/internal/util"
)

type {{.method}}Logic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func New{{.method}}Logic(ctx context.Context, svcCtx *svc.ServiceContext) *{{.method}}Logic {
	return &{{.method}}Logic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *{{.method}}Logic) {{.method}}(req *types.{{.request}}) (resp *types.{{.response}}, err error) {
	l.Infof("{{.method}} called with request: %+v", req)
	
	// 1. 参数验证
	if err := l.validateRequest(req); err != nil {
		l.Errorf("参数验证失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 2. 调用 Service 层处理业务逻辑
	result, err := l.svcCtx.{{.serviceName}}Service.{{.method}}(l.ctx, req)
	if err != nil {
		l.Errorf("业务逻辑处理失败: %v", err)
		return nil, util.NewError(err.Error())
	}
	
	// 3. 构建响应
	response := &types.{{.response}}{
		// TODO: 根据实际业务需求填充响应字段
	}
	
	l.Infof("{{.method}} completed successfully")
	return response, nil
}

// validateRequest 验证请求参数
func (l *{{.method}}Logic) validateRequest(req *types.{{.request}}) error {
	// TODO: 根据实际业务需求添加参数验证逻辑
	return nil
} 