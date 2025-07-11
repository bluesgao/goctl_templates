package event

import (
	"context"
	"fmt"
	"log"
	"time"

	"{{.PackagePrefix}}/internal/util"
)

// BaseEventHandler 基础事件处理器
type BaseEventHandler struct {
	name string
}

// NewBaseEventHandler 创建基础事件处理器
func NewBaseEventHandler(name string) *BaseEventHandler {
	return &BaseEventHandler{
		name: name,
	}
}

// GetName 获取处理器名称
func (h *BaseEventHandler) GetName() string {
	return h.name
}

// UserEventHandler 用户事件处理器
type UserEventHandler struct {
	*BaseEventHandler
}

// NewUserEventHandler 创建用户事件处理器
func NewUserEventHandler() *UserEventHandler {
	return &UserEventHandler{
		BaseEventHandler: NewBaseEventHandler("UserEventHandler"),
	}
}

// Handle 处理用户事件
func (h *UserEventHandler) Handle(ctx context.Context, event *Event) error {
	log.Printf("[%s] Processing user event: %s", h.name, event.Type)

	switch event.Type {
	case EventTypeUserCreated:
		return h.handleUserCreated(ctx, event)
	case EventTypeUserUpdated:
		return h.handleUserUpdated(ctx, event)
	case EventTypeUserDeleted:
		return h.handleUserDeleted(ctx, event)
	default:
		return fmt.Errorf("unsupported user event type: %s", event.Type)
	}
}

// GetEventType 获取支持的事件类型
func (h *UserEventHandler) GetEventType() EventType {
	// 这里返回一个通用类型，实际使用时应该根据具体事件类型处理
	return EventTypeUserCreated
}

// handleUserCreated 处理用户创建事件
func (h *UserEventHandler) handleUserCreated(ctx context.Context, event *Event) error {
	log.Printf("[%s] User created: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：发送欢迎邮件、创建用户档案等
	
	// 模拟处理时间
	time.Sleep(100 * time.Millisecond)
	
	log.Printf("[%s] User created event processed successfully", h.name)
	return nil
}

// handleUserUpdated 处理用户更新事件
func (h *UserEventHandler) handleUserUpdated(ctx context.Context, event *Event) error {
	log.Printf("[%s] User updated: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：更新缓存、同步数据等
	
	// 模拟处理时间
	time.Sleep(50 * time.Millisecond)
	
	log.Printf("[%s] User updated event processed successfully", h.name)
	return nil
}

// handleUserDeleted 处理用户删除事件
func (h *UserEventHandler) handleUserDeleted(ctx context.Context, event *Event) error {
	log.Printf("[%s] User deleted: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：清理缓存、删除相关数据等
	
	// 模拟处理时间
	time.Sleep(200 * time.Millisecond)
	
	log.Printf("[%s] User deleted event processed successfully", h.name)
	return nil
}

// OrderEventHandler 订单事件处理器
type OrderEventHandler struct {
	*BaseEventHandler
}

// NewOrderEventHandler 创建订单事件处理器
func NewOrderEventHandler() *OrderEventHandler {
	return &OrderEventHandler{
		BaseEventHandler: NewBaseEventHandler("OrderEventHandler"),
	}
}

// Handle 处理订单事件
func (h *OrderEventHandler) Handle(ctx context.Context, event *Event) error {
	log.Printf("[%s] Processing order event: %s", h.name, event.Type)

	switch event.Type {
	case EventTypeOrderCreated:
		return h.handleOrderCreated(ctx, event)
	case EventTypeOrderPaid:
		return h.handleOrderPaid(ctx, event)
	case EventTypeOrderShipped:
		return h.handleOrderShipped(ctx, event)
	case EventTypeOrderDelivered:
		return h.handleOrderDelivered(ctx, event)
	default:
		return fmt.Errorf("unsupported order event type: %s", event.Type)
	}
}

// GetEventType 获取支持的事件类型
func (h *OrderEventHandler) GetEventType() EventType {
	return EventTypeOrderCreated
}

// handleOrderCreated 处理订单创建事件
func (h *OrderEventHandler) handleOrderCreated(ctx context.Context, event *Event) error {
	log.Printf("[%s] Order created: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：发送订单确认邮件、更新库存等
	
	// 模拟处理时间
	time.Sleep(150 * time.Millisecond)
	
	log.Printf("[%s] Order created event processed successfully", h.name)
	return nil
}

// handleOrderPaid 处理订单支付事件
func (h *OrderEventHandler) handleOrderPaid(ctx context.Context, event *Event) error {
	log.Printf("[%s] Order paid: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：更新订单状态、发送支付确认等
	
	// 模拟处理时间
	time.Sleep(100 * time.Millisecond)
	
	log.Printf("[%s] Order paid event processed successfully", h.name)
	return nil
}

// handleOrderShipped 处理订单发货事件
func (h *OrderEventHandler) handleOrderShipped(ctx context.Context, event *Event) error {
	log.Printf("[%s] Order shipped: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：发送发货通知、更新物流信息等
	
	// 模拟处理时间
	time.Sleep(80 * time.Millisecond)
	
	log.Printf("[%s] Order shipped event processed successfully", h.name)
	return nil
}

// handleOrderDelivered 处理订单送达事件
func (h *OrderEventHandler) handleOrderDelivered(ctx context.Context, event *Event) error {
	log.Printf("[%s] Order delivered: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：发送送达确认、请求评价等
	
	// 模拟处理时间
	time.Sleep(120 * time.Millisecond)
	
	log.Printf("[%s] Order delivered event processed successfully", h.name)
	return nil
}

// SystemEventHandler 系统事件处理器
type SystemEventHandler struct {
	*BaseEventHandler
}

// NewSystemEventHandler 创建系统事件处理器
func NewSystemEventHandler() *SystemEventHandler {
	return &SystemEventHandler{
		BaseEventHandler: NewBaseEventHandler("SystemEventHandler"),
	}
}

// Handle 处理系统事件
func (h *SystemEventHandler) Handle(ctx context.Context, event *Event) error {
	log.Printf("[%s] Processing system event: %s", h.name, event.Type)

	switch event.Type {
	case EventTypeSystemError:
		return h.handleSystemError(ctx, event)
	case EventTypeSystemWarning:
		return h.handleSystemWarning(ctx, event)
	default:
		return fmt.Errorf("unsupported system event type: %s", event.Type)
	}
}

// GetEventType 获取支持的事件类型
func (h *SystemEventHandler) GetEventType() EventType {
	return EventTypeSystemError
}

// handleSystemError 处理系统错误事件
func (h *SystemEventHandler) handleSystemError(ctx context.Context, event *Event) error {
	log.Printf("[%s] System error: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：发送告警通知、记录错误日志等
	
	// 模拟处理时间
	time.Sleep(200 * time.Millisecond)
	
	log.Printf("[%s] System error event processed successfully", h.name)
	return nil
}

// handleSystemWarning 处理系统警告事件
func (h *SystemEventHandler) handleSystemWarning(ctx context.Context, event *Event) error {
	log.Printf("[%s] System warning: %s", h.name, event.ID)
	
	// 这里可以添加具体的业务逻辑
	// 例如：记录警告日志、发送通知等
	
	// 模拟处理时间
	time.Sleep(100 * time.Millisecond)
	
	log.Printf("[%s] System warning event processed successfully", h.name)
	return nil
} 