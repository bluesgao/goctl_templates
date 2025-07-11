package middleware

import (
	"context"
	"time"

	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// LoggingInterceptor 日志中间件
func LoggingInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()
		traceID := trace.TraceIDFromContext(ctx)
		
		logx.Infof("[%s] 开始处理请求, traceID: %s, method: %s", info.FullMethod, traceID, info.FullMethod)
		
		resp, err := handler(ctx, req)
		
		duration := time.Since(start)
		
		if err != nil {
			logx.Errorf("[%s] 处理失败, traceID: %s, duration: %v, error: %v", info.FullMethod, traceID, duration, err)
		} else {
			logx.Infof("[%s] 处理成功, traceID: %s, duration: %v", info.FullMethod, traceID, duration)
		}
		
		return resp, err
	}
}

// ErrorInterceptor 错误处理中间件
func ErrorInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		resp, err := handler(ctx, req)
		
		if err != nil {
			// 转换自定义错误为 gRPC 错误
			if st, ok := status.FromError(err); !ok {
				// 如果不是 gRPC 错误，转换为内部错误
				return nil, status.Error(codes.Internal, err.Error())
			} else {
				return nil, status.Error(st.Code(), st.Message())
			}
		}
		
		return resp, nil
	}
}

// RateLimitInterceptor 限流中间件
func RateLimitInterceptor(rate, burst int) grpc.UnaryServerInterceptor {
	// TODO: 实现限流逻辑
	// 可以使用 go-zero 的限流组件
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 限流检查
		// if !limiter.Allow() {
		//     return nil, status.Error(codes.ResourceExhausted, "请求过于频繁")
		// }
		
		return handler(ctx, req)
	}
}

// CircuitBreakerInterceptor 熔断器中间件
func CircuitBreakerInterceptor() grpc.UnaryServerInterceptor {
	// TODO: 实现熔断器逻辑
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 熔断器检查
		// if breaker.Ready() {
		//     return handler(ctx, req)
		// } else {
		//     return nil, status.Error(codes.Unavailable, "服务暂时不可用")
		// }
		
		return handler(ctx, req)
	}
}

// TimeoutInterceptor 超时中间件
func TimeoutInterceptor(timeout time.Duration) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		ctx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel()
		
		return handler(ctx, req)
	}
}

// AuthInterceptor 认证中间件
func AuthInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// TODO: 实现认证逻辑
		// 1. 从请求中提取 token
		// 2. 验证 token 有效性
		// 3. 设置用户信息到上下文
		
		// 示例：
		// token := extractToken(ctx)
		// if token == "" {
		//     return nil, status.Error(codes.Unauthenticated, "缺少认证信息")
		// }
		// 
		// userID, err := validateToken(token)
		// if err != nil {
		//     return nil, status.Error(codes.Unauthenticated, "认证失败")
		// }
		// 
		// ctx = context.WithValue(ctx, "user_id", userID)
		
		return handler(ctx, req)
	}
}

// MetricsInterceptor 指标收集中间件
func MetricsInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()
		
		resp, err := handler(ctx, req)
		
		duration := time.Since(start)
		
		// TODO: 收集指标
		// 1. 请求计数
		// 2. 响应时间
		// 3. 错误计数
		// 4. 成功率
		
		// 示例：
		// metrics.RequestCounter.WithLabelValues(info.FullMethod).Inc()
		// metrics.ResponseTime.WithLabelValues(info.FullMethod).Observe(duration.Seconds())
		// if err != nil {
		//     metrics.ErrorCounter.WithLabelValues(info.FullMethod).Inc()
		// }
		
		return resp, err
	}
}

// RecoveryInterceptor 恢复中间件
func RecoveryInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		defer func() {
			if r := recover(); r != nil {
				logx.Errorf("[%s] 发生 panic: %v", info.FullMethod, r)
				// 可以在这里添加告警通知
			}
		}()
		
		return handler(ctx, req)
	}
}

// Chain 中间件链
func Chain(interceptors ...grpc.UnaryServerInterceptor) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		chain := handler
		for i := len(interceptors) - 1; i >= 0; i-- {
			chain = func(interceptor grpc.UnaryServerInterceptor, next grpc.UnaryHandler) grpc.UnaryHandler {
				return func(ctx context.Context, req interface{}) (interface{}, error) {
					return interceptor(ctx, req, info, next)
				}
			}(interceptors[i], chain)
		}
		return chain(ctx, req)
	}
} 