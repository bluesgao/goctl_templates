package event

import (
	"context"
	"fmt"
	"time"

	"github.com/Shopify/sarama"
	"github.com/streadway/amqp"
	"google.golang.org/grpc"
)

// MQType 消息队列类型
type MQType string

const (
	MQTypeKafka  MQType = "kafka"
	MQTypeRabbitMQ MQType = "rabbitmq"
	MQTypeRedis  MQType = "redis"
	MQTypeNats   MQType = "nats"
)

// MQConfig MQ配置
type MQConfig struct {
	Type     MQType   `json:"type"`
	Hosts    []string `json:"hosts"`
	Port     int      `json:"port"`
	Username string   `json:"username"`
	Password string   `json:"password"`
	VHost    string   `json:"vhost"`
	Topic    string   `json:"topic"`
	Queue    string   `json:"queue"`
	GroupID  string   `json:"group_id"`
}

// MQConnector MQ连接器接口
type MQConnector interface {
	Connect(ctx context.Context) error
	Disconnect() error
	IsConnected() bool
	GetConfig() *MQConfig
}

// KafkaConnector Kafka连接器
type KafkaConnector struct {
	config    *MQConfig
	producer  sarama.SyncProducer
	consumer  sarama.Consumer
	connected bool
}

// NewKafkaConnector 创建Kafka连接器
func NewKafkaConnector(config *MQConfig) *KafkaConnector {
	return &KafkaConnector{
		config:    config,
		connected: false,
	}
}

// Connect 连接Kafka
func (kc *KafkaConnector) Connect(ctx context.Context) error {
	config := sarama.NewConfig()
	config.Producer.Return.Successes = true
	config.Producer.RequiredAcks = sarama.WaitForAll
	config.Producer.Retry.Max = 5
	config.Producer.Retry.Backoff = time.Millisecond * 100

	// 构建broker地址
	var brokers []string
	for _, host := range kc.config.Hosts {
		brokers = append(brokers, fmt.Sprintf("%s:%d", host, kc.config.Port))
	}

	// 创建生产者
	producer, err := sarama.NewSyncProducer(brokers, config)
	if err != nil {
		return fmt.Errorf("failed to create kafka producer: %w", err)
	}

	// 创建消费者
	consumer, err := sarama.NewConsumer(brokers, config)
	if err != nil {
		return fmt.Errorf("failed to create kafka consumer: %w", err)
	}

	kc.producer = producer
	kc.consumer = consumer
	kc.connected = true

	return nil
}

// Disconnect 断开Kafka连接
func (kc *KafkaConnector) Disconnect() error {
	if kc.producer != nil {
		if err := kc.producer.Close(); err != nil {
			return fmt.Errorf("failed to close kafka producer: %w", err)
		}
	}

	if kc.consumer != nil {
		if err := kc.consumer.Close(); err != nil {
			return fmt.Errorf("failed to close kafka consumer: %w", err)
		}
	}

	kc.connected = false
	return nil
}

// IsConnected 检查是否已连接
func (kc *KafkaConnector) IsConnected() bool {
	return kc.connected
}

// GetConfig 获取配置
func (kc *KafkaConnector) GetConfig() *MQConfig {
	return kc.config
}

// PublishMessage 发布消息到Kafka
func (kc *KafkaConnector) PublishMessage(topic string, message []byte) error {
	if !kc.connected {
		return fmt.Errorf("kafka not connected")
	}

	msg := &sarama.ProducerMessage{
		Topic: topic,
		Value: sarama.ByteEncoder(message),
	}

	partition, offset, err := kc.producer.SendMessage(msg)
	if err != nil {
		return fmt.Errorf("failed to send message to kafka: %w", err)
	}

	fmt.Printf("Message sent to partition %d at offset %d\n", partition, offset)
	return nil
}

// RabbitMQConnector RabbitMQ连接器
type RabbitMQConnector struct {
	config    *MQConfig
	conn      *amqp.Connection
	channel   *amqp.Channel
	connected bool
}

// NewRabbitMQConnector 创建RabbitMQ连接器
func NewRabbitMQConnector(config *MQConfig) *RabbitMQConnector {
	return &RabbitMQConnector{
		config:    config,
		connected: false,
	}
}

// Connect 连接RabbitMQ
func (rc *RabbitMQConnector) Connect(ctx context.Context) error {
	// 构建连接URL
	url := fmt.Sprintf("amqp://%s:%s@%s:%d/%s",
		rc.config.Username,
		rc.config.Password,
		rc.config.Hosts[0],
		rc.config.Port,
		rc.config.VHost,
	)

	conn, err := amqp.Dial(url)
	if err != nil {
		return fmt.Errorf("failed to connect to rabbitmq: %w", err)
	}

	channel, err := conn.Channel()
	if err != nil {
		return fmt.Errorf("failed to open channel: %w", err)
	}

	rc.conn = conn
	rc.channel = channel
	rc.connected = true

	return nil
}

// Disconnect 断开RabbitMQ连接
func (rc *RabbitMQConnector) Disconnect() error {
	if rc.channel != nil {
		if err := rc.channel.Close(); err != nil {
			return fmt.Errorf("failed to close channel: %w", err)
		}
	}

	if rc.conn != nil {
		if err := rc.conn.Close(); err != nil {
			return fmt.Errorf("failed to close connection: %w", err)
		}
	}

	rc.connected = false
	return nil
}

// IsConnected 检查是否已连接
func (rc *RabbitMQConnector) IsConnected() bool {
	return rc.connected
}

// GetConfig 获取配置
func (rc *RabbitMQConnector) GetConfig() *MQConfig {
	return rc.config
}

// PublishMessage 发布消息到RabbitMQ
func (rc *RabbitMQConnector) PublishMessage(queue string, message []byte) error {
	if !rc.connected {
		return fmt.Errorf("rabbitmq not connected")
	}

	err := rc.channel.Publish(
		"",     // exchange
		queue,  // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        message,
		},
	)

	if err != nil {
		return fmt.Errorf("failed to publish message to rabbitmq: %w", err)
	}

	return nil
}

// MQFactory MQ工厂
type MQFactory struct{}

// NewMQFactory 创建MQ工厂
func NewMQFactory() *MQFactory {
	return &MQFactory{}
}

// CreateConnector 创建MQ连接器
func (mf *MQFactory) CreateConnector(config *MQConfig) (MQConnector, error) {
	switch config.Type {
	case MQTypeKafka:
		return NewKafkaConnector(config), nil
	case MQTypeRabbitMQ:
		return NewRabbitMQConnector(config), nil
	default:
		return nil, fmt.Errorf("unsupported mq type: %s", config.Type)
	}
} 