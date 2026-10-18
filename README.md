# knowleger-repo

把零星的知识片段，交给 AI 定期整理成**分门别类的结构化知识**。

核心思路：**把知识库当代码仓库来经营**。

| 动作 | 类比 | 说明 |
|---|---|---|
| 采集 | `commit` | 你随手把碎片扔进 `inbox/`，零格式、零负担 |
| 整理 | `build / refactor` | AI 定期把片段"编译"成结构化笔记 |
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

# 看看现状
tools/kb status

# 让 AI 整理一轮
tools/kb process            # 打印整理任务，贴给任意 AI（OpenCode / Claude / Cursor…）
tools/kb process --run      # 直接调用本机 AI CLI 自动跑完（默认 opencode run）

# 整理后收尾
tools/kb index              # 重建主题地图 maps/
tools/kb build --open       # 生成静态站点并在浏览器打开
```

`kb` 是零依赖的 Python 脚本（只需 Python 3.9+），`Makefile` 提供了等价快捷方式：
`make add T="…"`、`make status`、`make process RUN=1`、`make build OPEN=1`。

---

## 目录结构

```
knowleger-repo/
├── AGENTS.md            ★ AI 整理协议（先读它）
├── inbox/               收集箱：随手扔的原始片段
│   └── archive/         已整理的原文，永久留存
├── knowledge/<分类>/    结构化知识：一篇笔记 = 一个概念
├── maps/                主题地图 MOC（kb index 生成，勿手改）
├── review/              待你裁决：重复 / 矛盾 / 模糊分类
├── meta/
│   ├── taxonomy.md      分类体系定义（AI 归类的依据）
│   └── ledger.jsonl     追溯台账：原始片段 ↔ 生成笔记
├── templates/note.md    笔记模板
├── tools/kb             命令行工具
├── tools/install-schedule.sh  定时自动整理（默认关闭）
└── docs/                静态站点（kb build 生成，默认 gitignore）
```

---

## 命令一览

| 命令 | 作用 |
|---|---|
| `kb add <文本>` | 采集碎片到 `inbox/`（`-f` 从文件，`-s` 标来源，或走 stdin） |
| `kb new <分类> <标题>` | 新建一篇结构化笔记 |
| `kb status` | 收集箱积压 / 笔记规模 / 待裁决 / 健康度 / 上次整理 |
| `kb process [--run]` | 生成 AI 整理任务；`--run` 直接执行 |
| `kb archive [文件…]` | 归档已整理的片段（**永不删除**） |
| `kb index` | 重建 `maps/` 主题地图与标签索引 |
| `kb lint` | 知识体检：断链 / 孤儿笔记 / 缺字段 / 分类不一致 / 积压 |
| `kb find <关键词>` | 全文搜索收集箱 + 知识库 + review（`-a` 连归档一起搜） |
| `kb build [--open]` | 生成静态站点（含搜索 + 知识图谱） |
| `kb log [-n N]` | 查看整理台账 |

---

## 它是怎么"超预期"的

1. **追溯台账**：每篇笔记都能顺着 `meta/ledger.jsonl` 回溯到原始片段，反之亦然。AI 整理不是黑盒。
2. **幂等 + 增量**：只处理 `inbox/` 里的新片段，不重排已有知识；重复运行结果一致。
3. **冲突不覆盖**：AI 遇到重复或矛盾，**不擅自合并**，写进 `review/` 等你拍板。
4. **知识体检**：`kb lint` 像编译器一样报错——断链、孤儿笔记、字段缺失、分类漂移、收集箱积压。
5. **可视化**：`kb build` 生成带全文搜索与力导向知识图谱的静态站点（零依赖、可发布 GitHub Pages）。
6. **可回滚**：每次整理都是一个 commit，整理坏了 `git revert` 即可，原文还在 `inbox/archive/`。

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

用环境变量 `KB_AGENT_CMD` 指定你的 AI CLI，默认 `opencode run`。

---

## 发布为网站（可选）

`docs/` 默认被 gitignore。想用 GitHub Pages 发布：删掉 `.gitignore` 里的 `docs/` 行，
提交后到仓库 Settings → Pages 选择 `main` 分支的 `/docs` 目录即可。
