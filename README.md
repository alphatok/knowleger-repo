# knowleger-repo

把零星的知识片段，交给 AI 定期整理成**分门别类的结构化知识**。

核心思路：**把知识库当代码仓库来经营**。

| 动作 | 类比 | 说明 |
|---|---|---|
| 采集 | `commit` | 随手把碎片扔进 `inbox/`，零格式、零负担 |
| 整理 | `build / refactor` | AI 定期把片段"编译"成结构化笔记 |
| 问答 | REPL | 向知识库提问，**答案也回写成新笔记** |
| git | 审计日志 | 每次整理都是一次可 review、可回滚的 diff |

> 原始片段**永不丢失**；AI 只做「追加 + 新建」，不覆盖；拿不准的交给你裁决。
> 完整规则见 [`AGENTS.md`](AGENTS.md)——那是这个仓库的「宪法」，也是你控制 AI 的唯一开关。

---

## 快速开始

```bash
# 采集一条碎片（支持中文，随便写）
tools/kb add "今天学到：向量数据库是按相似度查，不是按相等查"
tools/kb add -s "某个播客" "收藏夹不会改变你，只有被用过的笔记才会"
echo "从管道来的内容" | tools/kb add

# 看看现状 / 检查环境
tools/kb status
tools/kb doctor

# 本地检索（不用联网、不用 API）
tools/kb find "召回质量"          # BM25 关键词，最快
tools/kb find "怎么减少大模型胡编" --semantic   # 语义检索
tools/kb find "RAG 怎么提升效果" --deep         # 混合检索 + 重排，质量最好

# 让 AI 整理一轮
tools/kb process            # 打印整理任务，贴给任意 AI（OpenCode / Claude / Cursor…）
tools/kb process --run      # 直接调用本机 AI CLI 自动跑完（默认 opencode run）
tools/kb process --local    # 交给本地 Ollama 小模型（零 API 成本，产出草稿）

# 向知识库提问（答案会被回写成新笔记）
tools/kb ask "RAG 和微调怎么选？"
tools/kb ask "RAG 和微调怎么选？" --run

# 整理后收尾
tools/kb index              # 重建主题地图 maps/ + 刷新本地检索索引
tools/kb build --open       # 生成静态站点并在浏览器打开
```

`kb` 是零依赖的 Python 脚本（只需 Python 3.9+），`Makefile` 提供了等价快捷方式：
`make add T="…"`、`make status`、`make find Q="…"`、`make process RUN=1`、`make build OPEN=1`。

---

## 目录结构

```
knowleger-repo/
├── AGENTS.md            ★ AI 整理协议（Ingest / Query / Lint，先读它）
├── inbox/               收集箱：随手扔的原始片段
│   └── archive/         已整理的原文，永久留存
├── knowledge/<分类>/    结构化知识：一篇笔记 = 一个概念
├── maps/                主题地图 MOC（kb index 生成，勿手改）
├── review/              待你裁决：重复 / 矛盾 / 模糊分类
├── meta/
│   ├── taxonomy.md      分类体系定义（AI 归类的依据）
│   └── ledger.jsonl     追溯台账：原始片段 ↔ 生成笔记
├── templates/           笔记模板（note.md = 知识笔记，capture.md = 收集箱）
├── tools/kb             命令行工具（零依赖）
├── tools/install-schedule.sh  定时自动整理（默认关闭）
├── .kbconfig.json       AI 命令 / 本地模型名等配置
├── .obsidian/           Obsidian 保险库配置（已预调好）
├── .qmd/                QMD 本地检索索引（gitignore，可重建）
└── docs/                静态站点（kb build 生成，默认 gitignore）
```

---

## 命令一览

| 命令 | 作用 |
|---|---|
| `kb add <文本>` | 采集碎片到 `inbox/`（`-f` 从文件，`-s` 标来源，或走 stdin） |
| `kb new <分类> <标题>` | 新建一篇结构化笔记 |
| `kb status` | 收集箱积压 / 笔记规模 / 待裁决 / 健康度 / 上次整理 |
| `kb doctor` | 检查本地工具链（ollama / qmd / fabric / AI CLI） |
| `kb process [--run\|--local]` | 生成 Ingest 整理任务；`--run` 交 AI CLI，`--local` 交本地模型 |
| `kb ask <问题> [--run\|--local]` | 生成 Query 问答任务：自动检索 + 引用作答 + 回写 |
| `kb find <关键词>` | 本地检索：`--deep` 混合检索+重排 · `--semantic` 纯语义 · `--grep` 全文 · `-a` 含归档 |
| `kb pattern <名字>` | 用 fabric 的 pattern 处理文本（`-l` 列出全部 265 个） |
| `kb archive [文件…]` | 归档已整理的片段（**永不删除**） |
| `kb index [--embed]` | 重建 `maps/` 与标签索引，并刷新 QMD 检索索引 |
| `kb lint` | 知识体检：断链 / 孤儿笔记 / 缺字段 / 分类不一致 / 积压 |
| `kb build [--open]` | 生成静态站点（含搜索 + 知识图谱） |
| `kb log [-n N]` | 查看整理台账 |

---

## 本地工具链（可选，但装了会显著提效）

三个工具**全部可选**，缺失时 `kb` 会自动降级，不会报错。装齐后：

- `kb find` 从"字符串匹配"升级为**本地混合检索**（BM25 + 向量 + LLM 重排），中文友好。
- `kb process --local` / `kb ask --local` 可在**零 API 成本**下跑初筛、打标、判重。
- `kb pattern` 直接调用 [fabric](https://github.com/danielmiessler/fabric) 的 265 个 pattern。

```bash
# 1) 本地检索：QMD（Tobi Lütke 出品，MIT）
npm install -g @tobilu/qmd
cd knowleger-repo
qmd init && qmd collection add . && qmd embed   # 首次会下载约 2GB 本地模型

# 2) 本地模型：Ollama
brew install ollama
brew services start ollama
ollama pull qwen3:8b          # 建议 7B~14B；只做初筛的话 1.7b 也够

# 3) 提示词模式库：fabric（MIT）
#    brew tap 已失效，从 GitHub Releases 下载对应平台二进制放到 PATH
#    https://github.com/danielmiessler/fabric/releases
fabric --updatepatterns
cat > ~/.config/fabric/.env <<'EOF'
OLLAMA_API_URL=http://localhost:11434
DEFAULT_VENDOR=Ollama
DEFAULT_MODEL=qwen3:8b
EOF

# 然后看看状态
tools/kb doctor
```

调整配置：编辑 `.kbconfig.json`

```json
{
  "agent_cmd": "opencode run",
  "local_model": "qwen3:8b",
  "local_agent_cmd": "ollama run {model}"
}
```

也可以临时用环境变量覆盖：`KB_AGENT_CMD`、`KB_LOCAL_CMD`。

**成本策略**：初筛、打标签、判重等"读多写少"的步骤用**本地小模型**；
只在"合成一篇新笔记"这类高价值步骤才调大模型。

> 注意：`kb process --local` 走的是 `ollama run`，本地模型**没有文件工具**，
> 产出的是**草稿**（存在 `.kb-out/`），需要你或大模型再应用进 `knowledge/`。
> 想让本地模型真正落盘，把 `agent_cmd` 改成 `opencode run --model ollama/qwen3:8b`。

---

## 用 Obsidian 打开（零成本，强烈推荐）

仓库根目录**已经是一个 Obsidian 保险库**，直接打开即可：

1. Obsidian → `Open folder as vault` → 选中 `knowleger-repo` 根目录。
2. `docs/`、`tools/` 已在 `.obsidian/app.json` 里被排除，文件面板不会被生成物干扰。
3. 新建笔记会默认落在 `inbox/`——正好是"随手记"的位置，之后交给 `kb process`。
4. `[[双链]]` 与 frontmatter 原生可用，图谱视图直接看到知识结构。
5. （可选）开启核心插件 **Templates**，模板目录已指向 `templates/`，
   用 `capture.md` 快速记碎片、`note.md` 建知识笔记。

---

## 它是怎么"超预期"的

1. **追溯台账**：每篇笔记都能顺着 `meta/ledger.jsonl` 回溯到原始片段，反之亦然。AI 整理不是黑盒。
2. **幂等 + 增量**：只处理 `inbox/` 里的新片段，不重排已有知识；重复运行结果一致。
3. **冲突不覆盖**：AI 遇到重复或矛盾，**不擅自合并**，写进 `review/` 等你拍板。
4. **问答即沉淀**：`kb ask` 的答案不会消失在对话里——有复用价值就回写成新笔记。
5. **知识体检**：`kb lint` 像编译器一样报错——断链、孤儿笔记、字段缺失、分类漂移、收集箱积压。
6. **本地优先**：检索与初筛都能在本地跑完，一方 API 费不花，数据不出机器。
7. **始终可降级**：没装 QMD/Ollama/fabric 也一切照常，`kb` 自动退回内置能力。
8. **可回滚**：每次整理都是一个 commit，整理坏了 `git revert` 即可，原文还在 `inbox/archive/`。

---

## 分类体系

初始分类见 [`meta/taxonomy.md`](meta/taxonomy.md)：`技术 / 产品 / 商业 / 方法论 / 工具 / 人物 / 阅读 / 灵感`。
**随时可改**——增删目录 + 同步 taxonomy 即可。分类之外的细分用 `tags`，不要无限加目录。

---

## 定时自动整理（可选，默认关闭）

```bash
tools/install-schedule.sh install 21   # 每天 21:00 自动整理
tools/install-schedule.sh status
tools/install-schedule.sh remove
```

脚本使用 `kb process --run`，可用环境变量 `KB_AGENT_CMD` 指定你的 AI CLI。

---

## 发布为网站（可选）

`docs/` 默认被 gitignore。想用 GitHub Pages 发布：删掉 `.gitignore` 里的 `docs/` 行，
提交后到仓库 Settings → Pages 选择 `main` 分支的 `/docs` 目录即可。
