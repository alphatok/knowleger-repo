# AGENTS.md — 知识库协议

> 本文件是这个仓库的「宪法」。任何一个 AI agent（OpenCode / Claude Code / Cursor / 自建脚本）
> 在动手之前，**必须先读本文件**，并严格按下面的流程执行。
>
> 人类可以随时修改本文件来调整 AI 的行为——这是你控制 AI 的唯一开关。
>
> 设计遵循 [Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)：
> **原始素材不可变 → AI 增量编译成互链的 markdown 知识 → 三个操作：Ingest / Query / Lint。**

---

## 0. 一句话原则

**原始片段永不丢失；AI 只做「追加 + 新建」，不做「破坏性覆盖」；拿不准的交给人类。**

---

## 1. 三层结构（先建立心智模型）

| 层 | 目录 | 角色 | 谁能改 |
|---|---|---|---|
| **原文层** | `inbox/` | 人类随手扔的**原始**片段，零格式、可重复、可碎片 | 只增不改；整理后归档 |
| **原文层** | `inbox/archive/` | 已整理的原文，**永久留存，禁止删除** | 只读 |
| **知识层** | `knowledge/<分类>/` | 结构化知识：**一篇笔记 = 一个概念** | AI 负责新建/更新 |
| **索引层** | `maps/` | 主题地图 MOC，`kb index` 自动生成 | **禁止手改**，改内容后重跑 `kb index` |
| **配置层** | `meta/taxonomy.md` | 分类体系定义，AI 归类的依据 | 人类维护（AI 可建议） |
| **日志层** | `meta/ledger.jsonl` | 追溯台账：原始片段 ↔ 生成笔记 | AI 追加 |
| **仲裁层** | `review/` | 待人类裁决：重复、矛盾、歧义 | AI 写，人类裁决 |
| 生成物 | `docs/`、`templates/` | 静态站点 / 笔记模板 | 自动生成 / 人类维护 |

---

## 2. 分类体系

归类时**先读 `meta/taxonomy.md`**，严格使用其中定义的分类名。
若某概念确实不属于任何现有分类：优先选最接近的分类 + 精准 `tags`，同时在 `review/` 留「建议新增分类 X」，等人类确认。

分类名同时是目录名，必须与 frontmatter 的 `category` 完全一致（`kb lint` 会校验）。

---

## 3. 笔记规范

### 3.1 位置与命名
`knowledge/<分类>/<标题>.md`，文件名即标题。**一篇笔记只讲一个概念**；一条片段含 3 个概念就拆成 3 篇。

### 3.2 frontmatter（`kb lint` 会检查字段完整性）

```yaml
---
id: 20261018-093012
title: 什么是向量数据库
category: 技术
tags: [数据库, 向量检索, RAG]
status: seed
created: 2026-10-18
updated: 2026-10-18
sources: [inbox/2026-10-18.md]
related: [检索增强生成, 嵌入模型]
---
```

- `status`：`seed`（刚记下）→ `growing`（补过料、有链接）→ `evergreen`（成熟稳定）。
- `sources`：事实来源，指向 `inbox/` 或外部 URL。**必填**，保证可追溯。
- `related`：相关笔记标题（人可读）。真正的链接以正文 `[[ ]]` 为准。

### 3.3 正文结构（建议，别刻板套用）

```markdown
## 一句话
用一句话说清这个概念是什么。

## 要点
- 关键点……

## 细节 / 我的理解
展开，或记下自己的思考与疑问。引用其它笔记用 [[标题]]。

## 相关
- [[另一篇笔记]]
```

---

## 4. 三个操作

### 4.1 Ingest（摄入）— 把碎片编译成知识

被要求整理时，按顺序执行：

1. **读入**：`kb status` 看积压；逐个读取 `inbox/` 下的文件，按 `## ` 小节拆出片段清单。
2. **拆解为原子**：每条片段判断含几个独立概念；可产出 0..N 篇笔记。纯噪音不产出笔记，但**仍要归档**（台账标 `skip`）。
3. **去重与合并（关键）**：先 `kb find <关键词>` / 通读 `knowledge/` / 看 `maps/`，确认是否已有同一概念。
   - 已有 → **增量更新**（补要点、加 sources、改 `updated`、升 `status`），**不要新建重名笔记**。
   - 重复或矛盾 → **不要擅自合并**，写入 `review/`，台账标 `conflict`。
4. **落盘**：用 `kb new <分类> "<标题>"` 建骨架（统一格式），填写分类 / tags / sources。
5. **织网**：正文用 `[[标题]]` 链接相关笔记，**双向**（也去老笔记补一条指回来的链接）。
6. **记账**：向 `meta/ledger.jsonl` 追加记录：
   ```json
   {"ts":"2026-10-18T09:31:00+08:00","action":"create","note":"knowledge/技术/什么是向量数据库.md","from":["inbox/2026-10-18.md"],"agent":"opencode"}
   ```
   `action` 取值：`create` / `update` / `skip` / `conflict` / `archive`。
7. **收尾**：
   ```bash
   kb archive          # 归档已处理的原始片段（永不删除）
   kb index            # 重建 maps/ 主题地图
   kb lint             # 自检：断链 / 孤儿 / 缺字段
   kb build            # 重新生成静态站点
   git add -A && git commit -m "knowledge: 整理 inbox/<日期>（+N 篇，~M 篇）"
   ```

### 4.2 Query（问答）— 让探索也沉淀下来

人类提问时（`kb ask "<问题>"`）：

1. **先检索，再回答**：用 `kb find`（本地混合检索）或读 `maps/00-总览.md` 定位相关页，**不要凭空作答**。
2. **带着引用回答**：每个事实性结论都要能指回某篇笔记或某个 `sources`。
3. **知识库答不了就直说**：不要编造。可以提议"这需要新增一篇笔记 / 需要外部检索"。
4. **把有价值的答案回写成页（关键）**：
   - 一次对比、一段分析、一处新发现的关联——**不要让它消失在对话里**。
   - 用 `kb new` 落成新页（分类通常为 `方法论` 或原分类），或在已有页追加小节。
   - 台账标 `action: create|update`，`from` 写 `query:<问题摘要>`。
5. **收尾**：同 Ingest 的第 7 步（`index` / `lint` / `build` / `commit`）。

> 这条是 LLM Wiki 模式的精髓：**问答的产出直接变成知识资产**，而不只是聊天记录。

### 4.3 Lint（体检）— 定期健康检查

运行 `kb lint`，它检查：断链、孤儿笔记（无入链无出链）、frontmatter 缺字段、分类与目录不一致、收集箱积压、`review/` 待裁决项。

AI 主动体检时，除了跑 `kb lint`，还要**额外判断**（脚本查不出来的）：

- 页面之间是否有**矛盾**（新旧说法冲突）。
- 是否有**过时结论**已被新片段取代。
- 是否有**重要概念被提到却没有自己的页**（悬空概念）→ 建页。
- 是否有**缺失的交叉引用** → 补 `[[ ]]`。
- 是否有**知识缺口**值得去外部找资料 → 记入 `review/` 或建议人类补充。

体检结果写成 `review/YYYY-MM-DD-lint报告.md`，让人类过目。

---

## 5. 可用工具（本地优先，零 API 成本）

| 命令 | 作用 | 依赖 |
|---|---|---|
| `kb status` | 收集箱积压 / 规模 / 健康度 / 上次整理 | 无 |
| `kb find <关键词>` | **本地混合检索**（BM25+语义+重排）；无 QMD 时退化为全文匹配 | QMD（可选） |
| `kb ask "<问题>"` | 生成 Query 任务书（检索 → 引用作答 → 回写） | 无 |
| `kb process` | 生成 Ingest 任务书 | 无 |
| `kb process --run` | 交给 AI CLI 执行（默认 `opencode run`） | opencode 等 |
| `kb process --local` | 交给**本地模型**执行（Ollama），零 API 成本 | Ollama |
| `kb pattern <名字>` | 用 fabric 的 pattern 处理文本（如 `extract_wisdom`） | fabric（可选） |
| `kb lint` / `kb index` / `kb build` | 体检 / 重建地图 / 生成站点 | 无 |
| `kb doctor` | 检查本地工具链是否就绪 | 无 |

**成本策略**：初筛、打标签、判重等"读多写少"的步骤用**本地小模型**；只在"合成一篇新笔记"这类高价值步骤才调大模型。

---

## 6. 硬性红线（违反即失败）

1. ❌ 不删除、不覆盖 `inbox/` 与 `inbox/archive/` 里的任何原文。
2. ❌ 不手改 `maps/` 与 `docs/`（脚本生成）。
3. ❌ 不在证据不足时编造事实。不确定就写「存疑」并进 `review/`。
4. ❌ 不擅自合并有冲突的内容——交人类裁决。
5. ✅ 每次 Ingest / Query 结束必须 `git commit`，让改动成为可回滚的 diff。

---

## 7. 人类如何触发

```bash
kb process                 # Ingest：打印整理任务，贴给任意 AI
kb process --run           # Ingest：交给本机 AI CLI（opencode run）
kb process --local         # Ingest：交给本地 Ollama 模型，零成本
kb ask "RAG 和微调怎么选？"  # Query：检索 + 引用作答 + 回写
kb lint                    # Lint：体检
kb doctor                  # 检查工具链
```

定时自动整理见 `tools/install-schedule.sh`（默认关闭）。
