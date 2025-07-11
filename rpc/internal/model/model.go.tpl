package model

import (
	"time"
	"gorm.io/gorm"
)

{{.comment}}
type {{.model}} struct {
	{{range .fields}}
	{{.name}} {{.type}} `json:"{{.json}}" gorm:"{{.gorm}}"` // {{.comment}}
	{{end}}
	CreatedAt time.Time      `json:"created_at" gorm:"autoCreateTime;index"`
	UpdatedAt time.Time      `json:"updated_at" gorm:"autoUpdateTime;index"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`
}

// TableName 指定表名
func ({{.model}}) TableName() string {
	return "{{.table}}"
}

// BeforeCreate 创建前的钩子
func (m *{{.model}}) BeforeCreate(tx *gorm.DB) error {
	// TODO: 在创建前添加自定义逻辑
	// 示例：
	// 1. 数据验证
	// 2. 字段默认值设置
	// 3. 业务规则检查
	
	return nil
}

// BeforeUpdate 更新前的钩子
func (m *{{.model}}) BeforeUpdate(tx *gorm.DB) error {
	// TODO: 在更新前添加自定义逻辑
	// 示例：
	// 1. 数据验证
	// 2. 字段更新检查
	// 3. 业务规则检查
	
	return nil
}

// BeforeDelete 删除前的钩子
func (m *{{.model}}) BeforeDelete(tx *gorm.DB) error {
	// TODO: 在删除前添加自定义逻辑
	// 示例：
	// 1. 检查是否可以删除
	// 2. 记录删除日志
	// 3. 清理关联数据
	
	return nil
}

// AfterCreate 创建后的钩子
func (m *{{.model}}) AfterCreate(tx *gorm.DB) error {
	// TODO: 在创建后添加自定义逻辑
	// 示例：
	// 1. 发送通知
	// 2. 更新缓存
	// 3. 记录审计日志
	
	return nil
}

// AfterUpdate 更新后的钩子
func (m *{{.model}}) AfterUpdate(tx *gorm.DB) error {
	// TODO: 在更新后添加自定义逻辑
	// 示例：
	// 1. 发送通知
	// 2. 更新缓存
	// 3. 记录审计日志
	
	return nil
}

// AfterDelete 删除后的钩子
func (m *{{.model}}) AfterDelete(tx *gorm.DB) error {
	// TODO: 在删除后添加自定义逻辑
	// 示例：
	// 1. 清理缓存
	// 2. 记录审计日志
	// 3. 发送通知
	
	return nil
}

// Validate 数据验证
func (m *{{.model}}) Validate() error {
	// TODO: 根据实际业务需求添加数据验证逻辑
	// 示例：
	// if m.Name == "" {
	//     return errors.New("名称不能为空")
	// }
	// if len(m.Name) > 100 {
	//     return errors.New("名称长度不能超过100个字符")
	// }
	
	return nil
}

// IsDeleted 检查是否已删除
func (m *{{.model}}) IsDeleted() bool {
	return m.DeletedAt.Valid
}

// SoftDelete 软删除
func (m *{{.model}}) SoftDelete(tx *gorm.DB) error {
	return tx.Delete(m).Error
}

// Restore 恢复软删除的记录
func (m *{{.model}}) Restore(tx *gorm.DB) error {
	return tx.Unscoped().Model(m).Update("deleted_at", nil).Error
} 