package handler

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"{{.package}}/internal/logic"
	"{{.package}}/internal/svc"
	"{{.package}}/internal/types"
)

func {{.method}}Handler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.{{.request}}
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := logic.New{{.method}}Logic(r.Context(), svcCtx)
		resp, err := l.{{.method}}(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
} 