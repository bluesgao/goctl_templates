package event

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"{{.PackagePrefix}}/internal/util"
)

// EventType 事件类型
type EventType string

const (
	// 用户相关事件
	EventTypeUserCreated EventType = "user.created"
	EventTypeUserUpdated EventType = "user.updated"
	EventTypeUserDeleted EventType = "user.deleted"
	
	// 订单相关事件
	EventTypeOrderCreated EventType = "order.created"
	EventTypeOrderPaid    EventType = "order.paid"
	EventTypeOrderShipped EventType = "order.shipped"
	EventTypeOrderDelivered EventType = "order.delivered"
	
	// 系统相关事件
	EventTypeSystemError EventType = "system.error"
	EventTypeSystemWarning EventType = "system.warning"
)

// Event 事件结构
type Event struct {
	ID          string                 `json:"id"`
	Type        EventType              `json:"type"`
	Data        map[string]interface{} `json:"data"`
	Timestamp   time.Time              `json:"timestamp"`
	Source      string                 `json:"source"`
	Version     string                 `json:"version"`
	TraceID     string                 `json:"trace_id,omitempty"`
	UserID      string                 `json:"user_id,omitempty"`
}

// EventHandler 事件处理器接口
type EventHandler interface {
	Handle(ctx context.Context, event *Event) error
	GetEventType() EventType
}

// EventPublisher 事件发布器接口
type EventPublisher interface {
	Publish(ctx context.Context, event *Event) error
	PublishAsync(ctx context.Context, event *Event) error
}

// EventSubscriber 事件订阅器接口
type EventSubscriber interface {
	Subscribe(ctx context.Context, eventType EventType, handler EventHandler) error
	Unsubscribe(ctx context.Context, eventType EventType) error
}

// EventManager 事件管理器
type EventManager struct {
	publishers  map[string]EventPublisher
	subscribers map[string]EventSubscriber
	handlers    map[EventType][]EventHandler
}

// NewEventManager 创建事件管理器
func NewEventManager() *EventManager {
	return &EventManager{
		publishers:  make(map[string]EventPublisher),
		subscribers: make(map[string]EventSubscriber),
		handlers:    make(map[EventType][]EventHandler),
	}
}

// RegisterPublisher 注册发布器
func (em *EventManager) RegisterPublisher(name string, publisher EventPublisher) {
	em.publishers[name] = publisher
}

// RegisterSubscriber 注册订阅器
func (em *EventManager) RegisterSubscriber(name string, subscriber EventSubscriber) {
	em.subscribers[name] = subscriber
}

// RegisterHandler 注册事件处理器
func (em *EventManager) RegisterHandler(handler EventHandler) {
	eventType := handler.GetEventType()
	em.handlers[eventType] = append(em.handlers[eventType], handler)
}

// PublishEvent 发布事件
func (em *EventManager) PublishEvent(ctx context.Context, eventType EventType, data map[string]interface{}) error {
	event := &Event{
		ID:        util.GenerateID(),
		Type:      eventType,
		Data:      data,
		Timestamp: time.Now(),
		Source:    "{{.ServiceName}}",
		Version:   "1.0.0",
	}

	// 发布到所有注册的发布器
	for name, publisher := range em.publishers {
		if err := publisher.Publish(ctx, event); err != nil {
			return fmt.Errorf("failed to publish event to %s: %w", name, err)
		}
	}

	return nil
}

// PublishEventAsync 异步发布事件
func (em *EventManager) PublishEventAsync(ctx context.Context, eventType EventType, data map[string]interface{}) {
	go func() {
		if err := em.PublishEvent(ctx, eventType, data); err != nil {
			// 记录错误日志
			fmt.Printf("Failed to publish event async: %v\n", err)
		}
	}()
}

// CreateEvent 创建事件
func CreateEvent(eventType EventType, data map[string]interface{}) *Event {
	return &Event{
		ID:        util.GenerateID(),
		Type:      eventType,
		Data:      data,
		Timestamp: time.Now(),
		Source:    "{{.ServiceName}}",
		Version:   "1.0.0",
	}
}

// ToJSON 将事件转换为JSON字符串
func (e *Event) ToJSON() string {
	return util.StructToJSON(e)
}

// FromJSON 从JSON字符串创建事件
func FromJSON(jsonStr string) (*Event, error) {
	var event Event
	err := util.JSONToStruct(jsonStr, &event)
	if err != nil {
		return nil, err
	}
	return &event, nil
} 