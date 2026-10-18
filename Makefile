# knowleger-repo 快捷入口（make 只是薄封装，等价于 kb 命令）
.PHONY: help add status process lint index build log archive

help:
	@echo "make add      采集片段： make add T=\"要记的内容\""
	@echo "make status   查看知识库状态"
	@echo "make process  AI 整理（打印任务）： make process RUN=1 直接执行"
	@echo "make lint     知识体检"
	@echo "make index    重建主题地图 maps/"
	@echo "make build    生成静态站点并打开： make build OPEN=1"
	@echo "make log      查看整理台账"
	@echo "make archive  归档已整理的收集箱文件"

add:
	@[ -n "$(T)" ] || (echo "用法：make add T=\"要记的内容\""; exit 1)
	@python3 tools/kb add "$(T)"

status:
	@python3 tools/kb status

process:
	@python3 tools/kb process $(if $(RUN),--run,)

lint:
	@python3 tools/kb lint

index:
	@python3 tools/kb index

build:
	@python3 tools/kb build $(if $(OPEN),--open,)

log:
	@python3 tools/kb log

archive:
	@python3 tools/kb archive
