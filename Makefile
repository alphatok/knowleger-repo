# knowleger-repo 快捷入口（make 只是薄封装，等价于 kb 命令）
.PHONY: help add status doctor process ask lint index build log archive find

help:
	@echo "make add      采集片段： make add T=\"要记的内容\""
	@echo "make status   查看知识库状态"
	@echo "make doctor   检查本地工具链（ollama / qmd / fabric）"
	@echo "make process  AI 整理： make process RUN=1 交 AI CLI，LOCAL=1 交本地模型"
	@echo "make ask      向知识库提问： make ask Q=\"RAG 和微调怎么选？\"，可加 RUN=1"
	@echo "make find     本地检索： make find Q=关键词，可加 DEEP=1 / SEMANTIC=1 / GREP=1"
	@echo "make lint     知识体检"
	@echo "make index    重建主题地图并刷新检索索引"
	@echo "make build    生成静态站点并打开： make build OPEN=1"
	@echo "make log      查看整理台账"
	@echo "make archive  归档已整理的收集箱文件"

add:
	@[ -n "$(T)" ] || (echo "用法：make add T=\"要记的内容\""; exit 1)
	@python3 tools/kb add "$(T)"

status:
	@python3 tools/kb status

doctor:
	@python3 tools/kb doctor

process:
	@python3 tools/kb process $(if $(RUN),--run,$(if $(LOCAL),--local,))

ask:
	@[ -n "$(Q)" ] || (echo "用法：make ask Q=\"你的问题\""; exit 1)
	@python3 tools/kb ask "$(Q)" $(if $(RUN),--run,$(if $(LOCAL),--local,))

lint:
	@python3 tools/kb lint

find:
	@[ -n "$(Q)" ] || (echo "用法：make find Q=\"关键词\""; exit 1)
	@python3 tools/kb find "$(Q)" $(if $(DEEP),--deep,$(if $(SEMANTIC),--semantic,$(if $(GREP),--grep,)))

index:
	@python3 tools/kb index

build:
	@python3 tools/kb build $(if $(OPEN),--open,)

log:
	@python3 tools/kb log

archive:
	@python3 tools/kb archive
