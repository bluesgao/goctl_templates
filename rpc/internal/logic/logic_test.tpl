package logic

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"{{.pbImport}}"
	"{{.package}}/internal/svc"
	"{{.package}}/internal/util"
)

// MockServiceContext 模拟服务上下文
type MockServiceContext struct {
	mock.Mock
	*svc.ServiceContext
}

func Test{{.method}}Logic_{{.method}}(t *testing.T) {
	tests := []struct {
		name    string
		req     *{{.pbPackage}}.{{.request}}
		wantErr bool
		errType string
	}{
		{
			name: "正常请求",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充测试数据
			},
			wantErr: false,
		},
		{
			name:    "空请求",
			req:     nil,
			wantErr: true,
			errType: ErrorTypeValidation,
		},
		{
			name: "无效参数",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充无效的测试数据
			},
			wantErr: true,
			errType: ErrorTypeValidation,
		},
		{
			name: "权限不足",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充需要权限验证的测试数据
			},
			wantErr: true,
			errType: ErrorTypePermission,
		},
		{
			name: "业务参数验证失败",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充业务参数验证失败的测试数据
			},
			wantErr: true,
			errType: ErrorTypeValidation,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 创建模拟服务上下文
			mockSvc := &MockServiceContext{}
			
			// 创建逻辑处理器
			l := &{{.method}}Logic{
				Logger: logx.WithContext(context.Background()),
				ctx:    context.Background(),
				svcCtx: mockSvc.ServiceContext,
			}

			// 执行测试
			resp, err := l.{{.method}}(tt.req)

			// 验证结果
			if tt.wantErr {
				assert.Error(t, err)
				if tt.errType != "" {
					assert.Equal(t, tt.errType, util.GetErrorType(err))
				}
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, resp)
			}
		})
	}
}

func Test{{.method}}Logic_validateRequest(t *testing.T) {
	tests := []struct {
		name    string
		req     *{{.pbPackage}}.{{.request}}
		wantErr bool
	}{
		{
			name: "有效请求",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充有效的测试数据
			},
			wantErr: false,
		},
		{
			name:    "空请求",
			req:     nil,
			wantErr: true,
		},
		{
			name: "无效请求",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充无效的测试数据
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{}
			err := l.validateRequest(tt.req)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func Test{{.method}}Logic_validatePermission(t *testing.T) {
	tests := []struct {
		name    string
		req     *{{.pbPackage}}.{{.request}}
		wantErr bool
	}{
		{
			name: "有权限",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充有权限的测试数据
			},
			wantErr: false,
		},
		{
			name: "无权限",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充无权限的测试数据
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{
				ctx: context.Background(),
			}
			err := l.validatePermission(tt.req)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func Test{{.method}}Logic_validateBusinessRequest(t *testing.T) {
	tests := []struct {
		name    string
		req     *{{.pbPackage}}.{{.request}}
		wantErr bool
	}{
		{
			name: "有效业务参数",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充有效业务参数的测试数据
			},
			wantErr: false,
		},
		{
			name: "无效业务参数",
			req: &{{.pbPackage}}.{{.request}}{
				// TODO: 填充无效业务参数的测试数据
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{}
			err := l.validateBusinessRequest(tt.req)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func Test{{.method}}Logic_buildResponse(t *testing.T) {
	tests := []struct {
		name    string
		result  interface{}
		wantErr bool
	}{
		{
			name: "有效结果",
			result: &model.User{
				// TODO: 填充有效的模型数据
			},
			wantErr: false,
		},
		{
			name:    "空结果",
			result:  nil,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{}
			resp, err := l.buildResponse(tt.result)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, resp)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, resp)
			}
		})
	}
}

func Test{{.method}}Logic_hasPermission(t *testing.T) {
	tests := []struct {
		name       string
		userID     interface{}
		operation  string
		wantResult bool
	}{
		{
			name:       "有权限",
			userID:     "user123",
			operation:  "{{.method}}",
			wantResult: true,
		},
		{
			name:       "无权限",
			userID:     "user456",
			operation:  "{{.method}}",
			wantResult: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{}
			result := l.hasPermission(tt.userID, tt.operation)

			assert.Equal(t, tt.wantResult, result)
		})
	}
}

func Test{{.method}}Logic_canAccessResource(t *testing.T) {
	tests := []struct {
		name       string
		userID     interface{}
		resourceID int64
		wantResult bool
	}{
		{
			name:       "可以访问资源",
			userID:     "user123",
			resourceID: 1,
			wantResult: true,
		},
		{
			name:       "不能访问资源",
			userID:     "user456",
			resourceID: 2,
			wantResult: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			l := &{{.method}}Logic{}
			result := l.canAccessResource(tt.userID, tt.resourceID)

			assert.Equal(t, tt.wantResult, result)
		})
	}
}

// Benchmark{{.method}}Logic_{{.method}} 性能测试
func Benchmark{{.method}}Logic_{{.method}}(b *testing.B) {
	// 创建模拟服务上下文
	mockSvc := &MockServiceContext{}
	
	// 创建逻辑处理器
	l := &{{.method}}Logic{
		Logger: logx.WithContext(context.Background()),
		ctx:    context.Background(),
		svcCtx: mockSvc.ServiceContext,
	}

	// 准备测试数据
	req := &{{.pbPackage}}.{{.request}}{
		// TODO: 填充测试数据
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := l.{{.method}}(req)
		if err != nil {
			b.Fatal(err)
		}
	}
} 