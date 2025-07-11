package types

import (
	"time"
)

type {{.request}} struct {
	// TODO: 根据实际业务需求添加请求字段
}

type {{.response}} struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
	Time    time.Time   `json:"time"`
}

// 通用响应结构
type BaseResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
	Time    time.Time   `json:"time"`
}

// 分页请求
type PageRequest struct {
	Page     int `json:"page" form:"page"`
	PageSize int `json:"page_size" form:"page_size"`
}

// 分页响应
type PageResponse struct {
	Total       int64       `json:"total"`
	Page        int         `json:"page"`
	PageSize    int         `json:"page_size"`
	TotalPages  int         `json:"total_pages"`
	List        interface{} `json:"list"`
} 