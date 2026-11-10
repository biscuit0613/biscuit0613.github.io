#import "/typst/templates/paper-slides.typ": *

#let body-s = 15pt
#let body-m = 16pt
#let head-s = 18pt

#show: paper-slides.with(
  title: "AISci-v2: 双模式全自动科研实验框架",
  subtitle: "Classic Pipeline + Evolution Swarm",
  author: "Biscuit",
  date: "2026-08-01",
)

#cover-slide[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold", fill: accent)[AISci-v2]
    #v(0.3em)
    #text(size: 20pt, fill: accent)[Classic + Evolution 双模式科研实验框架]
    #v(2em)
    #text(size: 14pt, fill: secondary-text)[基于 SakanaAI/AI-Scientist-v2 · 扩展 Evolution Swarm 模式]
    #v(0.3em)
    #text(size: 13pt, fill: secondary-text)[Python 3.11 · OmegaConf · React Dashboard · FastAPI]
    #v(1em)
    #note-block[
      #text(size: 13pt, weight: "bold", fill: accent)[核心创新：统一 Node/Journal 数据模型 + 双模式（Classic 树搜索 / Evolution 种群演化） + 实时 Dashboard]
    ]
  ]
]

== 目录

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  align: top,
  [
    #table(
      columns: (0.5fr, 4fr),
      inset: 6pt,
      stroke: none,
      align: (center, left),
      [#text(size: 22pt, weight: "bold", fill: accent)[1]], [#text(size: body-s)[项目总览 \  #text(fill: secondary-text, size: 12pt)[双模式框架 + 统一数据模型]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[2]], [#text(size: body-s)[Classic 模式 \  #text(fill: secondary-text, size: 12pt)[四阶段流水线 + 最优优先树搜索]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[3]], [#text(size: body-s)[Evolution 模式 \  #text(fill: secondary-text, size: 12pt)[种群演化 + Swarm Orchestrator]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[4]], [#text(size: body-s)[核心组件 \  #text(fill: secondary-text, size: 12pt)[MinimalAgent · Journal · Node · Event System]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[5]], [#text(size: body-s)[Evolution 插件 \  #text(fill: secondary-text, size: 12pt)[负知识库 · 审计追踪 · Centaur HPO · Git 隔离]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[6]], [#text(size: body-s)[Dashboard + 事件流 \  #text(fill: secondary-text, size: 12pt)[实时监控 · WORKBENCH_EVENT 消费链路]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[7]], [#text(size: body-s)[架构总览 \  #text(fill: secondary-text, size: 12pt)[数据流 · 论文写作 · 自动评审]]],
    )
  ],
  [
    #card[
      #text(size: body-s, weight: "bold", fill: accent)[核心命题]
      #v(0.3em)
      #text(size: body-s, fill: secondary-text)[能否构建一个实验框架，同时支持确定性流水线和探索性种群演化两种科研范式？]
      #v(0.5em)
      #text(size: body-s, weight: "bold", fill: accent)[两种模式]
      #v(0.2em)
      #table(
        columns: (1fr, 1fr),
        inset: 4pt,
        stroke: 0.4pt,
        align: (center, center),
        [#text(size: 12pt, weight: "bold")[Classic]], [#text(size: 12pt, weight: "bold")[Evolution]],
        [#text(size: 12pt)[4 阶段流水线]], [#text(size: 12pt)[种群演化循环]],
        [#text(size: 12pt)[最优优先搜索]], [#text(size: 12pt)[SAGA 风格]],
        [#text(size: 12pt)[确定性探索]], [#text(size: 12pt)[开放性发现]],
      )
    ]
    #v(0.3em)
    #text(size: 12pt, fill: secondary-text)[基于 SakanaAI/AI-Scientist-v2 · Apache 2.0 / MIT]
  ],
)

== 项目总览：Classic + Evolution 双模式

#text(size: head-s, weight: "bold", fill: accent)[同一套数据模型驱动两种科研范式]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "Classic 模式")[
      #text(size: body-s)[
        #text(weight: "bold")[入口]：`launch_scientist_bfts.py` | 4 阶段线性流水线 \
        初始实现 → 基线调优 → 创新研究 → 消融实验 \
        每阶段最优优先树搜索，适合目标明确的实验
      ]
    ]
  ],
  [
    #card(title: "Evolution 模式")[
      #text(size: body-s)[
        #text(weight: "bold")[入口]：`launch_scientist_evolution.py` | 种群演化循环 (SAGA-style) \
        Selection → Execution → Absorption → Evolution → Analysis \
        多假设并行 · 失败知识积累 · 自动审计，适合探索性研究
      ]
    ]
  ],
)

== 统一共享层 + Dashboard

#text(size: head-s, weight: "bold", fill: accent)[Node / Journal / MinimalAgent 统一抽象 + 实时 Dashboard]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "统一共享层")[
      #text(size: body-s)[
        #text(weight: "bold")[Node]：实验快照（代码 + 执行结果 + 指标 + 反馈）\
        #text(weight: "bold")[Journal]：实验日志（树结构 + 草案 + 节点选择）\
        #text(weight: "bold")[MinimalAgent]：Plan → Code → Execute → Review \
        #text(weight: "bold")[Writeup + Review]：论文写作 + LLM/VLM 自动评审
      ]
    ]
  ],
  [
    #card(title: "Dashboard")[
      #text(size: body-s)[
        #text(weight: "bold")[前端]：React + TypeScript + Vite \
        #text(weight: "bold")[后端]：FastAPI + SQLite + Scanner \
        #text(weight: "bold")[实时]：`@WORKBENCH_EVENT@` stdout 事件流 \
        #text(weight: "bold")[Workbench]：ProcessRunner 子进程管理
      ]
    ]
  ],
)

== Classic 模式：四阶段流水线

#text(size: head-s, weight: "bold", fill: accent)[每阶段内部执行最优优先树搜索，阶段间传播最佳节点]

#table(
  columns: (1.5fr, 1fr, 1.5fr, 2fr),
  inset: 5pt,
  stroke: 0.4pt,
  align: (left, center, center, left),
  table.header(
    [#text(size: body-s, weight: "bold")[阶段]],
    [#text(size: body-s, weight: "bold")[Max Iters]],
    [#text(size: body-s, weight: "bold")[输入]],
    [#text(size: body-s, weight: "bold")[核心目标]],
  ),
  [#text(size: 13pt)[1. 初始实现]], [#text(size: 13pt)[3]], [#text(size: 13pt)[Idea]], [#text(size: 13pt)[基础代码跑通，最小原型可执行]],
  [#text(size: 13pt)[2. 基线调优]], [#text(size: 13pt)[2]], [#text(size: 13pt)[最佳原型]], [#text(size: 13pt)[超参数调优，曲线收敛，多数据集验证]],
  [#text(size: 13pt)[3. 创新研究]], [#text(size: 13pt)[2]], [#text(size: 13pt)[调优基线]], [#text(size: 13pt)[议程驱动探索，自动增加实验复杂度]],
  [#text(size: 13pt)[4. 消融实验]], [#text(size: 13pt)[3]], [#text(size: 13pt)[最终节点]], [#text(size: 13pt)[复制取统计显著性，聚合出图]],
)

== Classic 模式：树搜索与阶段传播

#text(size: head-s, weight: "bold", fill: accent)[最优优先树搜索 + 阶段间最佳节点传播]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "树搜索策略")[
      #text(size: body-s)[
        #text(weight: "bold")[节点类型]：Buggy → Debug(≤3) / Non-buggy → Refine / Hyperparameter / Ablation \
        #text(weight: "bold")[选择策略]：概率 p 选 Buggy 修复，否则选 Non-buggy 改进。最优优先。 \
        #text(weight: "bold")[执行循环]：Plan → Code → Execute → Plot → VLM Review → Buggy/Non-buggy
      ]
    ]
  ],
  [
    #card(title: "阶段间传播")[
      #text(size: body-s)[
        LLM 评估器选择每阶段最佳节点 → 作为下阶段根节点。每阶段末尾启动复制节点（多 seeds）提供统计量。
      ]
    ]
  ],
)

== Evolution 模式：种群演化引擎

#text(size: head-s, weight: "bold", fill: accent)[SwarmOrchestrator 驱动种群演化循环]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "演化循环")[
      #text(size: body-s)[
        #text(weight: "bold")[Selection → Execution → Absorption → Evolution → Analysis] \
        按 productivity/novelty/coverage 选父代 · 并行执行 · 成功传播 / 失败入库 · 精英保留变异
      ]
    ]
    #v(0.3em)
    #card(title: "关键设计")[
      #text(size: body-s)[
        #text(weight: "bold")[PopulationManager] 管理 hypothesis trees | #text(weight: "bold")[NegativeKnowledgeBank] 记录失败 | #text(weight: "bold")[AuditTrail] 防泄露
      ]
    ]
  ],
  [
    #card(title: "与 SAGA 的对比")[
      #text(size: body-s)[
        #text(weight: "bold")[相似]：种群演化循环 · 自演化 · 精英选择 \
        #text(weight: "bold")[差异]：ML 实验（代码生成 + 执行 + 评估）· 负知识库 · 审计追踪 · Git 隔离 · Centaur HPO
      ]
    ]
  ],
)

== 核心组件：MinimalAgent + Journal + Node

#text(size: head-s, weight: "bold", fill: accent)[统一的三层实验模型]

#table(
  columns: (1.5fr, 2.5fr, 2fr),
  inset: 5pt,
  stroke: 0.4pt,
  align: (left, left, left),
  table.header(
    [#text(size: body-s, weight: "bold")[组件]],
    [#text(size: body-s, weight: "bold")[职责]],
    [#text(size: body-s, weight: "bold")[关键属性]],
  ),
  [#text(size: 13pt, weight: "bold")[MinimalAgent]], [#text(size: 13pt)[Plan → Code → Execute → Plot → VLM → Buggy/Non-buggy]], [#text(size: 13pt)[`_draft_node()` · `_execute_node()` · `_review_node()`]],
  [#text(size: 13pt, weight: "bold")[Journal]], [#text(size: 13pt)[管理节点树、草案、选择策略、阶段检查]], [#text(size: 13pt)[`nodes` · `draft_nodes` · `generate_summary()` · `check_stage_completion()`]],
  [#text(size: 13pt, weight: "bold")[Node]], [#text(size: 13pt)[实验快照：代码 + 执行结果 + 指标 + 反馈]], [#text(size: 13pt)[`code/plan` · `metric` · `is_buggy` · `plots` · `vlm_feedback` · `children/parent`]],
)

== 核心组件：生命周期与事件系统

#text(size: head-s, weight: "bold", fill: accent)[节点生命周期 + Event System 事件发射与消费]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "节点生命周期")[
      #text(size: body-s)[
        Draft → Execute → Plot → VLM Review → Buggy? → Debug(≤3) / Non-buggy → Refine → Best → Propagate
      ]
    ]
  ],
  [
    #card(title: "Event System")[
      #text(size: body-s)[
        `emit("classic.node.completed", node_id=..., metric=...)` \
        `@WORKBENCH_EVENT@\{...\}` → stdout → Dashboard 实时消费
      ]
    ]
  ],
)

== Evolution 插件系统

#text(size: head-s, weight: "bold", fill: accent)[模块化插件，YAML 配置可切换]

#table(
  columns: (1.5fr, 2.5fr, 2fr),
  inset: 5pt,
  stroke: 0.4pt,
  align: (left, left, left),
  table.header(
    [#text(size: body-s, weight: "bold")[插件]],
    [#text(size: body-s, weight: "bold")[功能]],
    [#text(size: body-s, weight: "bold")[机制]],
  ),
  [#text(size: 13pt, weight: "bold")[NegativeKnowledge]], [#text(size: 13pt)[记录失败模式，避免重复错误]], [#text(size: 13pt)[失败 → 模式提取 → 向量化 → 检索 → 注入 prompt]],
  [#text(size: 13pt, weight: "bold")[AuditTrail]], [#text(size: 13pt)[防止数据泄露、幻觉、偏差]], [#text(size: 13pt)[检查训练/测试重叠 · 记录实验变更 · 签名验证]],
  [#text(size: 13pt, weight: "bold")[Centaur HPO]], [#text(size: 13pt)[CMA-ES + LLM 混合超参优化]], [#text(size: 13pt)[CMA-ES 探索连续空间 · LLM 建议离散/结构选择]],
  [#text(size: 13pt, weight: "bold")[Git Isolation]], [#text(size: 13pt)[每个实验独立 Git 分支]], [#text(size: 13pt)[`git checkout -b exp_<id>` · 隔离代码变更 · 可复现]],
  [#text(size: 13pt, weight: "bold")[Simulation]], [#text(size: 13pt)[离线测试（无 API key）]], [#text(size: 13pt)[模拟 LLM 响应 · 模拟 VLM · 模拟执行结果]],
)

== Evolution 插件配置

#text(size: head-s, weight: "bold", fill: accent)[YAML 配置切换 · 插件模块化组合]

#v(0.5em)

#card(title: "OmegaConf 配置")[
  #text(size: body-s)[
    所有插件通过 `evolution:` 段控制：`negative_knowledge.enabled: true` · `audit_trail.enabled: true` · `centaur.enabled: false` · `git_isolation.enabled: true`
  ]
]

#v(0.3em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "核心插件")[
      #text(size: body-s)[
        #text(weight: "bold")[NegativeKnowledge]：失败模式提取 → 向量化 → 检索 → 注入 prompt \
        #text(weight: "bold")[AuditTrail]：训练/测试重叠检查 · 实验变更记录 · 签名验证
      ]
    ]
  ],
  [
    #card(title: "辅助插件")[
      #text(size: body-s)[
        #text(weight: "bold")[Centaur HPO]：CMA-ES 探索连续空间 + LLM 建议离散结构 \
        #text(weight: "bold")[Git Isolation]：`git checkout -b exp_<id>` · 隔离代码变更 · 可复现
      ]
    ]
  ],
)

== Dashboard：双通道数据消费

#text(size: head-s, weight: "bold", fill: accent)[Workbench 实时推送 + Scanner 文件扫描]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "Workbench 通道（实时）")[
      #text(size: body-s)[
        #text(weight: "bold")[启动]：Dashboard 内一键启动，ProcessRunner 管理子进程 \
        #text(weight: "bold")[消费]：逐行读取 stdout → 正则匹配 `@WORKBENCH_EVENT@` → 解析 JSON → SQLite \
        #text(weight: "bold")[事件类型]：`classic.started` · `stage.*` · `node.*` · `step.*` · `swarm.*` · `iteration.*` \
        #text(weight: "bold")[前端]：2.5s 轮询 `GET /api/projects/{id}/workspace` → 展示 Timeline
      ]
    ]
  ],
  [
    #card(title: "Scanner 通道（文件扫描）")[
      #text(size: body-s)[
        #text(weight: "bold")[触发]：每 3s 扫描 `experiments/` 目录 \
        #text(weight: "bold")[数据]：`journal.json` · `stage_progress.json` · `checkpoint.pkl` · `experiment.log` \
        #text(weight: "bold")[层次]：Session → Proposal → Run → Attempt → Stage → Artifact \
        #text(weight: "bold")[局限]：不消费 `@WORKBENCH_EVENT@`，只能看到文件级别的粗粒度进度
      ]
    ]
  ],
)

== Dashboard：事件消费链路与技术栈

#text(size: head-s, weight: "bold", fill: accent)[`@WORKBENCH_EVENT@` 从发射到展示的完整链路]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "事件消费链路")[
      #text(size: body-s)[
        #text(weight: "bold", fill: accent)[Emit] `events.py` → Parse `ProcessRunner._consume()` → Store `WorkbenchService` → SQLite \
        #text(weight: "bold", fill: accent)[Serve] `GET /api/runs/{id}/events` (SSE) / `/workspace` (REST) → Display 前端 2.5s 轮询 → Timeline
      ]
    ]
  ],
  [
    #card(title: "技术栈")[
      #text(size: body-s)[
        #text(weight: "bold")[前端]：React 19 + TypeScript + Vite \
        #text(weight: "bold")[后端]：FastAPI + SQLite + SSE \
        #text(weight: "bold")[子进程]：`subprocess.Popen` + async stdout 消费 \
        #text(weight: "bold")[安全]：路径 containment 检查
      ]
    ]
  ],
)

== 端到端数据流

#table(
  columns: (1.5fr, 2.5fr, 2fr),
  inset: 5pt,
  stroke: 0.4pt,
  align: (left, left, left),
  table.header(
    [#text(size: body-s, weight: "bold")[阶段]],
    [#text(size: body-s, weight: "bold")[Classic]],
    [#text(size: body-s, weight: "bold")[Evolution]],
  ),
  [#text(size: 13pt)[1. Idea 输入]], [#text(size: 13pt)[JSON 文件（Name / Title / Hypothesis / Experiments）]], [#text(size: 13pt)[同左]],
  [#text(size: 13pt)[2. 实验执行]], [#text(size: 13pt)[ClassicPipeline 4 阶段 · 最优优先树搜索]], [#text(size: 13pt)[SwarmOrchestrator 种群演化循环]],
  [#text(size: 13pt)[3. 图表聚合]], [#text(size: 13pt)[`aggregate_plots()` 汇总多节点图表]], [#text(size: 13pt)[同左]],
  [#text(size: 13pt)[4. 论文写作]], [#text(size: 13pt)[ICML 8 页 / ICLR 4 页 · LaTeX 模板 · o1 反思]], [#text(size: 13pt)[同左]],
  [#text(size: 13pt)[5. 自动评审]], [#text(size: 13pt)[LLM 文本评审 + VLM 图表/图注审查]], [#text(size: 13pt)[同左]],
  [#text(size: 13pt)[6. 输出]], [#text(size: 13pt)[PDF 论文 + 实验数据 + 评审报告]], [#text(size: 13pt)[同左 + 种群演化轨迹]],
)

== 论文写作与配置

#text(size: head-s, weight: "bold", fill: accent)[自动论文生成 + 灵活配置系统]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "论文写作")[
      #text(size: body-s)[
        #text(weight: "bold")[ICML 模式]：8 页，LaTeX 模板，适合主会投稿 \
        #text(weight: "bold")[ICLR ICBINB 模式]：4 页短文，适合 Workshop \
        #text(weight: "bold")[增强]：o1 反思 + VLM 图注审查 + 引用自动检索 \
        #text(weight: "bold")[跳过]：`--skip_writeup --skip_review`
      ]
    ]
  ],
  [
    #card(title: "配置系统")[
      #text(size: body-s)[
        #text(weight: "bold")[OmegaConf]：YAML 配置 + CLI 覆盖 + 默认值合并 \
        #text(weight: "bold")[模型]：code / feedback / vlm_feedback / report / review 独立配置 \
        #text(weight: "bold")[环境变量]：`AI_SCIENTIST_*` 覆盖 + `AI_SCIENTIST_SKIP_VLM` 跳过视觉
      ]
    ]
  ],
)

#v(0.3em)
#text(size: body-s, weight: "bold", fill: accent)[Classic 确定性探索 → Evolution 开放性发现。同一套 Node/Journal/Agent 抽象，两种科研范式。]

== Q&A

#v(3em)
#align(center, text(size: 18pt, weight: "bold", fill: accent)[谢谢！Q & A])
#v(0.5em)
#align(center, text(size: 11pt, fill: secondary-text)[基于 SakanaAI/AI-Scientist-v2 · github.com/SakanaAI/AI-Scientist · 汇报人: Biscuit])