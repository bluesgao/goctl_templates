package logic

import (
	"context"
	"encoding/json"
	"time"

	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/trace"
	"{{.pbImport}}"
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

func (l *{{.method}}Logic) {{.method}}(req *{{.pbPackage}}.{{.request}}) (*{{.pbPackage}}.{{.response}}, error) {
	start := time.Now()
	traceID := trace.TraceIDFromContext(l.ctx)
	
	l.Infof("[{{.method}}] 开始处理业务逻辑, traceID: %s, request: %+v", traceID, req)
	
	// 1. 参数验证（技术层面）
	if err := l.validateRequest(req); err != nil {
		l.Errorf("[{{.method}}] 参数验证失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewValidationError(err.Error())
	}
	
	// 2. 权限验证
	if err := l.validatePermission(req); err != nil {
		l.Errorf("[{{.method}}] 权限验证失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewPermissionError(err.Error())
	}
	
	// 3. 业务参数验证（业务层面）
	if err := l.validateBusinessRequest(req); err != nil {
		l.Errorf("[{{.method}}] 业务参数验证失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewValidationError(err.Error())
	}
	
	// 4. 调用 Service 层处理业务逻辑
	result, err := l.svcCtx.{{.serviceName}}Service.{{.method}}(l.ctx, req)
	if err != nil {
		l.Errorf("[{{.method}}] 业务逻辑处理失败, traceID: %s, error: %v", traceID, err)
		return nil, err
	}
	
	// 5. 构建响应
	response, err := l.buildResponse(result)
	if err != nil {
		l.Errorf("[{{.method}}] 构建响应失败, traceID: %s, error: %v", traceID, err)
		return nil, util.NewInternalError("构建响应失败")
	}
	
	duration := time.Since(start)
	l.Infof("[{{.method}}] 业务逻辑处理完成, traceID: %s, duration: %v", traceID, duration)
	
	return response, nil
}

// validateRequest 验证请求参数（技术层面）
func (l *{{.method}}Logic) validateRequest(req *{{.pbPackage}}.{{.request}}) error {
	if req == nil {
		return util.NewValidationError("请求参数不能为空")
	}
	
	// TODO: 根据实际业务需求添加技术层面的参数验证逻辑
	// 示例：
	// if req.GetId() <= 0 {
	//     return util.NewValidationError("ID必须大于0")
	// }
	// if req.GetName() == "" {
	//     return util.NewValidationError("名称不能为空")
	// }
	
	return nil
}

// validatePermission 验证权限
func (l *{{.method}}Logic) validatePermission(req *{{.pbPackage}}.{{.request}}) error {
	// TODO: 根据实际业务需求添加权限验证逻辑
	// 示例：
	// userID := l.ctx.Value("user_id")
	// if userID == nil {
	//     return util.NewPermissionError("用户未登录")
	// }
	// 
	// // 检查用户权限
	// if !hasPermission(userID, "{{.method}}") {
	//     return util.NewPermissionError("权限不足")
	// }
	// 
	// // 检查资源权限
	// if req.GetId() > 0 {
	//     if !canAccessResource(userID, req.GetId()) {
	//         return util.NewPermissionError("无权访问该资源")
	//     }
	// }
	
	return nil
}

// validateBusinessRequest 验证业务请求参数（业务层面）
func (l *{{.method}}Logic) validateBusinessRequest(req *{{.pbPackage}}.{{.request}}) error {
	// TODO: 根据实际业务需求添加业务参数验证逻辑
	// 示例：
	// if req.GetName() == "" {
	//     return util.NewValidationError("名称不能为空")
	// }
	// if len(req.GetName()) > 100 {
	//     return util.NewValidationError("名称长度不能超过100个字符")
	// }
	// if !util.IsValidEmail(req.GetEmail()) {
	//     return util.NewValidationError("邮箱格式不正确")
	// }
	// if !util.IsValidPhone(req.GetPhone()) {
	//     return util.NewValidationError("手机号格式不正确")
	// }
	// 
	// // 业务规则验证
	// if req.GetAge() < 18 {
	//     return util.NewValidationError("年龄必须大于18岁")
	// }
	// if req.GetAge() > 100 {
	//     return util.NewValidationError("年龄不能超过100岁")
	// }
	
	return nil
}

// buildResponse 构建响应
func (l *{{.method}}Logic) buildResponse(result interface{}) (*{{.pbPackage}}.{{.response}}, error) {
	// TODO: 根据实际业务需求构建响应
	response := &{{.pbPackage}}.{{.response}}{
		// 根据 result 填充响应字段
		// 示例：
		// if user, ok := result.(*model.User); ok {
		//     response.Id = user.ID
		//     response.Name = user.Name
		//     response.Email = user.Email
		//     response.Status = "success"
		//     response.CreatedAt = user.CreatedAt.Format("2006-01-02 15:04:05")
		// }
	}
	
	return response, nil
}

// 辅助方法：检查用户权限
func (l *{{.method}}Logic) hasPermission(userID interface{}, operation string) bool {
	// TODO: 实现权限检查逻辑
	// 示例：
	// userIDStr, ok := userID.(string)
	// if !ok {
	//     return false
	// }
	// 
	// // 从缓存或数据库获取用户权限
	// permissions := l.getUserPermissions(userIDStr)
	// 
	// for _, permission := range permissions {
	//     if permission == operation {
	//         return true
	//     }
	// }
	// 
	// return false
	
	return true // 临时返回true，实际需要实现权限检查
}

// 辅助方法：检查资源访问权限
func (l *{{.method}}Logic) canAccessResource(userID interface{}, resourceID int64) bool {
	// TODO: 实现资源访问权限检查逻辑
	// 示例：
	// userIDStr, ok := userID.(string)
	// if !ok {
	//     return false
	// }
	// 
	// // 检查用户是否有权限访问该资源
	// return l.checkResourcePermission(userIDStr, resourceID)
	
	return true // 临时返回true，实际需要实现权限检查
}

// 辅助方法：获取用户权限
func (l *{{.method}}Logic) getUserPermissions(userID string) []string {
	// TODO: 从缓存或数据库获取用户权限
	// 示例：
	// permissions, err := l.svcCtx.Redis.Get(l.ctx, fmt.Sprintf("user:permissions:%s", userID))
	// if err != nil {
	//     // 从数据库获取
	//     return l.getUserPermissionsFromDB(userID)
	// }
	// 
	// var perms []string
	// if err := json.Unmarshal([]byte(permissions), &perms); err != nil {
	//     return []string{}
	// }
	// 
	// return perms
	
	return []string{"read", "write", "delete"} // 临时返回默认权限
} 