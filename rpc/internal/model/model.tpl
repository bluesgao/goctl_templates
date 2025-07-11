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
	CreatedAt time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`
}

// TableName 指定表名
func ({{.model}}) TableName() string {
	return "{{.table}}"
}

// BeforeCreate 创建前的钩子
func (m *{{.model}}) BeforeCreate(tx *gorm.DB) error {
	// TODO: 在创建前添加自定义逻辑
	return nil
}

// BeforeUpdate 更新前的钩子
func (m *{{.model}}) BeforeUpdate(tx *gorm.DB) error {
	// TODO: 在更新前添加自定义逻辑
	return nil
}

// BeforeDelete 删除前的钩子
func (m *{{.model}}) BeforeDelete(tx *gorm.DB) error {
	// TODO: 在删除前添加自定义逻辑
	return nil
}

// AfterCreate 创建后的钩子
func (m *{{.model}}) AfterCreate(tx *gorm.DB) error {
	// TODO: 在创建后添加自定义逻辑
	return nil
}

// AfterUpdate 更新后的钩子
func (m *{{.model}}) AfterUpdate(tx *gorm.DB) error {
	// TODO: 在更新后添加自定义逻辑
	return nil
}

// AfterDelete 删除后的钩子
func (m *{{.model}}) AfterDelete(tx *gorm.DB) error {
	// TODO: 在删除后添加自定义逻辑
	return nil
} 