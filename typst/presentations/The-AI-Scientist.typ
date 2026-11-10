#import "/typst/templates/paper-slides.typ": *

// 紧凑排版用字号
#let body-s = 14pt
#let head-s = 17pt

#show: paper-slides.with(
  title: "The AI Scientist v1 → v2: 全自动科研框架演进",
  subtitle: "从线性流水线到 Agentic Tree Search",
  author: "Biscuit",
  date: "2026-07-09",
)

#cover-slide[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold", fill: accent)[The AI Scientist]
    #v(0.3em)
    #text(size: 20pt, fill: accent)[v1 → v2: 全自动科研框架的演进]
    #v(2em)
    #text(size: 14pt, fill: secondary-text)[Sakana AI · Oxford · UBC · Vector Institute]
    #v(0.3em)
    #text(size: 13pt, fill: secondary-text)[arXiv 2408.06292 (v1) · arXiv 2504.08066 (v2)]
    #v(0.5em)
    #text(size: 13pt, fill: secondary-text)[github.com/SakanaAI/AI-Scientist]
    #v(1em)
    #note-block[
      #text(size: 13pt, weight: "bold", fill: accent)[里程碑：首篇 AI 全自动论文通过 Workshop 同行评审（ICLR 2025 ICBINB, 评分 6.33, top 45%）]
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
      [#text(size: 22pt, weight: "bold", fill: accent)[1]], [#text(size: body-s)[v1 → v2 对比总览 \  #text(fill: secondary-text, size: 12pt)[10 维度演进一览]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[2]], [#text(size: body-s)[v1 流水线 + v2 改进 \  #text(fill: secondary-text, size: 12pt)[四阶段优缺点分析]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[3]], [#text(size: body-s)[Tree Search 原理 \  #text(fill: secondary-text, size: 12pt)[节点模型、搜索策略、参数]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[4]], [#text(size: body-s)[实验进度管理器 \  #text(fill: secondary-text, size: 12pt)[四阶段分配与传播]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[5]], [#text(size: body-s)[Workshop 验证 \  #text(fill: secondary-text, size: 12pt)[ICLR 2025 盲审实验]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[6]], [#text(size: body-s)[整体架构设计 \  #text(fill: secondary-text, size: 12pt)[树图 + 四大组件]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[7]], [#text(size: body-s)[AI4Sci 框架启示 \  #text(fill: secondary-text, size: 12pt)[复用模块、规避陷阱、局限与展望]]],
    )
  ],
  [
    #card[
      #text(size: body-s, weight: "bold", fill: accent)[核心命题]
      #v(0.3em)
      #text(size: body-s, fill: secondary-text)[能否构建一个全自动 AI 科学家，从 Idea 到论文不依赖人类介入？]
      #v(0.5em)
      #text(size: body-s, weight: "bold", fill: accent)[两个版本的回答]
      #v(0.2em)
      #table(
        columns: (1fr, 1fr),
        inset: 4pt,
        stroke: 0.4pt,
        align: (center, center),
        [#text(size: 12pt, weight: "bold")[v1]], [#text(size: 12pt, weight: "bold")[v2]],
        [#text(size: 12pt)[需人工模板]], [#text(size: 12pt)[零模板通用]],
        [#text(size: 12pt)[线性浅层]], [#text(size: 12pt)[树搜索并行]],
        [#text(size: 12pt)[未提交审稿]], [#text(size: 12pt)[Workshop 接收]],
      )
    ]
    #v(0.3em)
    #text(size: 12pt, fill: secondary-text)[v1: arXiv 2408.06292 · v2: arXiv 2504.08066 · github.com/SakanaAI/AI-Scientist]
  ],
)

== v1 → v2 对比总览

#text(size: head-s, weight: "bold", fill: accent)[10 个关键维度的演进]

#table(
  columns: (2.2fr, 2.2fr, 2.6fr),
  inset: 4pt,
  stroke: 0.4pt,
  align: (left, center, center),
  table.header(
    [#text(size: body-s, weight: "bold")[维度]],
    [#text(size: body-s, weight: "bold")[v1]],
    [#text(size: body-s, weight: "bold")[v2]],
  ),
  [#text(size: 13pt)[代码模板]], [#text(size: 13pt, fill: accent)[需人工编写]], [#text(size: 13pt, fill: accent)[完全自动生成]],
  [#text(size: 13pt)[实验范式]], [#text(size: 13pt)[线性编辑 → 运行]], [#text(size: 13pt)[Tree Search + 并行节点]],
  [#text(size: 13pt)[进度管理]], [#text(size: 13pt)[MAX_ITERS=4, RUNS=5]], [#text(size: 13pt)[4 阶段（预研→调参→议程→消融）]],
  [#text(size: 13pt)[视觉反馈]], [#text(size: 13pt)[无]], [#text(size: 13pt)[VLM 审图（GPT-4o JSON）]],
  [#text(size: 13pt)[论文写作]], [#text(size: 13pt)[Aider 逐节+chktex]], [#text(size: 13pt)[单次+o1 反思+VLM 图注]],
  [#text(size: 13pt)[审稿机制]], [#text(size: 13pt)[单一 GPT-4o]], [#text(size: 13pt)[5 集成+AC 聚合]],
  [#text(size: 13pt)[并行能力]], [#text(size: 13pt)[无]], [#text(size: 13pt)[节点并行执行]],
  [#text(size: 13pt)[LLM 支持]], [#text(size: 13pt)[~10 个 API]], [#text(size: 13pt)[~30 API（o1, Gemini 2.5）]],
  [#text(size: 13pt)[人体验证]], [#text(size: 13pt)[未提交审稿]], [#text(size: 13pt)[Workshop 接收 6.33/10]],
  [#text(size: 13pt)[耗时/成本]], [#text(size: 13pt)[1-2h, ~15-250 USD]], [#text(size: 13pt)[15h左右, API 费用更高]],
)

== v1 流水线 + v2 改进

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "Idea 生成")[
      #text(size: body-s)[
        #text(weight: "bold")[v1]：模板变异，reflection 3 轮，Semantic Scholar 10 轮 \
        #text(weight: "bold")[局限]：Idea 相似度高 \
        #text(weight: "bold", fill: accent)[v2]：广义 Idea 生成，开放探索
      ]
    ]
    #card(title: "实验迭代")[
      #text(size: body-s)[
        #text(weight: "bold")[v1]：Aider 编辑 → 运行，MAX_ITERS=4 \
        #text(weight: "bold")[局限]：线性无并行，深度浅 \
        #text(weight: "bold", fill: accent)[v2]：Tree Search + 4 阶段 + 并行
      ]
    ]
  ],
  [
    #card(title: "论文写作")[
      #text(size: body-s)[
        #text(weight: "bold")[v1]：Aider 逐节，引用 20 轮，chktex 5 轮 \
        #text(weight: "bold")[局限]：无视觉验证 \
        #text(weight: "bold", fill: accent)[v2]：+ o1 反思 + VLM 图注审查
      ]
    ]
    #card(title: "自动审稿")[
      #text(size: body-s)[
        #text(weight: "bold")[v1]：GPT-4o, 5 reflection, 5 集成 \
        #text(weight: "bold")[结果]：F1 0.57 (vs Human 0.49) \
        #text(weight: "bold", fill: accent)[v2]：+ AC 聚合, Workshop 验证
      ]
    ]
  ],
)

== v2 核心: Agentic Tree Search

#two-col(
  ratio: (1.2fr, 1fr),
  [
    #figure-img("/typst/presentations/figures/experiment_tree.pdf", width: 100%)
  ],
  [
    #card(title: "搜索策略")[
      #text(size: body-s)[
        #text(weight: "bold")[节点选择]：概率 p 选 Buggy 修复，否则 Non-buggy。Best-First Search。 \
        #v(0.15em)
        #text(weight: "bold")[6 种节点]：Buggy / Non-buggy / Debug(≤3) / Refine / Hyperparameter / Ablation / Replication / Aggregation \
        #v(0.15em)
        #text(weight: "bold")[执行循环]：Plan → Code → Execute → Plot → VLM → Buggy/Non-buggy
      ]
    ]
    #v(0.25em)
    #card(title: "关键参数")[
      #text(size: body-s)[
        Claude 3.5 Sonnet (v2) 代码 · GPT-4o 反馈 · T=0.5 · 单节点超时 1h · 总耗时数h~15h
      ]
    ]
  ],
)

== v2 实验进度管理器

#text(size: head-s, weight: "bold", fill: accent)[四阶段 + 节点分配 + 阶段间传播]

#table(
  columns: (1.8fr, 1fr, 1.8fr, 2.2fr),
  inset: 4pt,
  stroke: 0.4pt,
  align: (left, center, center, left),
  table.header(
    [#text(size: body-s, weight: "bold")[阶段]],
    [#text(size: body-s, weight: "bold")[节点数]],
    [#text(size: body-s, weight: "bold")[输入]],
    [#text(size: body-s, weight: "bold")[终止条件]],
  ),
  [#text(size: 13pt)[1. 预研]], [#text(size: 13pt)[21]], [#text(size: 13pt)[Idea]], [#text(size: 13pt)[最小原型成功执行]],
  [#text(size: 13pt)[2. 调参]], [#text(size: 13pt)[12]], [#text(size: 13pt)[最佳原型]], [#text(size: 13pt)[曲线收敛 + ≥2 数据集]],
  [#text(size: 13pt)[3. 议程]], [#text(size: 13pt)[12]], [#text(size: 13pt)[调优基线]], [#text(size: 13pt)[预算耗尽/自动增复杂度]],
  [#text(size: 13pt)[4. 消融]], [#text(size: 13pt)[12]], [#text(size: 13pt)[最终节点]], [#text(size: 13pt)[复制取统计→聚合出图]],
)

#v(0.3em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "阶段间传播")[
      #text(size: body-s)[
        LLM 评估器选择最佳节点 → 传给下阶段为根节点。每阶段末尾启动复制节点（多 seeds）提供统计量用于最终图表。
      ]
    ]
  ],
  [
    #card(title: "节点生命周期")[
      #text(size: body-s)[
        节点 = Plan + Code + Error + Runtime + Metrics + LLM 反馈 + VLM 反馈 + Status。Aggregation 节点不执行实验，仅汇总复制结果。
      ]
    ]
  ],
)

== v2 Workshop 验证

#text(size: head-s, weight: "bold", fill: accent)[ICLR 2025 ICBINB Workshop · 43 篇投稿 · 盲审]

#table(
  columns: (2.5fr, 1fr, 1fr, 2.2fr),
  inset: 4pt,
  stroke: 0.4pt,
  align: (left, center, center, left),
  table.header(
    [#text(size: body-s, weight: "bold")[论文]],
    [#text(size: body-s, weight: "bold")[结果]],
    [#text(size: body-s, weight: "bold")[评分]],
    [#text(size: body-s, weight: "bold")[内部审查发现问题]],
  ),
  [#text(size: 12.5pt)[Compositional Regularization (LSTM)]], [#text(size: 12.5pt, fill: accent)[Accepted]], [#text(size: 12.5pt)[6.33]], [#text(size: 12pt)[57% 数据重叠, 图注错, 漏引用]],
  [#text(size: 12.5pt)[Label Noise on Calibration]], [#text(size: 12.5pt)[Rejected]], [#text(size: 12.5pt)[N/A]], [#text(size: 12pt)[温度缩放写未跑, 文字图不符]],
  [#text(size: 12.5pt)[Pest Detection Failures]], [#text(size: 12.5pt)[Rejected]], [#text(size: 12.5pt)[N/A]], [#text(size: 12pt)[DA 未跑通, mislead 描述]],
)

#v(0.15em)

#two-col(
  ratio: (1.3fr, 1fr),
  [
    #card(title: "被接收论文分析")[
      #text(size: body-s)[
        #text(weight: "bold")[假设]：LSTM embedding 正则化 → 组合泛化 \
        #text(weight: "bold")[发现]：未改进，有时损害。展示负面结果获认可 \
        #text(weight: "bold")[生成流程]：~40 Idea → 选 3 → 多 seeds 全自动运行 → 选最优 → 撤回
      ]
    ]
  ],
  [
    #figure-img("/typst/presentations/figures/workshop_paper.png", width: 90%)
  ],
)

== 架构设计

#text(size: head-s, weight: "bold", fill: accent)[Agentic Tree Search 驱动的全自动科研框架]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #figure-img("/typst/presentations/figures/experiment_tree.pdf", width: 100%)
  ],
  [
    #card(title: "框架组件")[
      #text(size: body-s)[
        #text(weight: "bold")[Exp. Manager]：4 阶段进度管理 \
        #text(weight: "bold")[Template Contract]：`experiment.py` + JSON 解耦 \
        #text(weight: "bold")[VLM Reviewer]：GPT-4o 审图 → Debug/Refine \
        #text(weight: "bold")[LLM Adapter]：Claude / GPT-4o / o1
      ]
    ]
    #card(title: "核心机制")[
      #text(size: body-s)[
        并行节点 → Buggy/Non-buggy → Debug/Refine → Best-First。 \
        #text(fill: accent)[v1]：线性，重试 ≤4，5轮 \
        #text(fill: accent)[v2]：并行探索，最佳传播
      ]
    ]
  ],
)

== AI4Sci 框架启示

#grid(
  columns: (1fr, 1fr),
  gutter: 0.5em,
  align: top,
  [
    #card(title: "可复用 + 需规避")[
      #text(size: body-s)[
        #text(weight: "bold")[可复用]：模板契约（`experiment.py` 解耦）、Tree Search（并行+4阶段）、VLM→物理检查（分子构型/光谱峰）、开放进化（存档+变异+分数反馈） \
        #text(weight: "bold")[陷阱]：数据泄露(57%)→隔离检查点 · 未执行代码→log签名 · 假阳性→baseline+复杂度 · 沙箱逃逸→Docker+cgroups
      ]
    ]
  ],
  [
    #card(title: "局限与展望")[
      #text(size: body-s)[
        #text(weight: "bold")[v1]：Idea 多样性不足 · 深度浅 · 无法看图 · 幻觉 · 沙箱逃逸 \
        #text(weight: "bold")[v2]：Workshop 非主会 · 1/3 通过 · 数据泄露 · 未执行代码 \
        #text(weight: "bold", fill: accent)[未来]：VLM 集成 · 自驱动实验室 · 开放进化 · 伦理规范
      ]
    ]
  ],
)

#v(0.3em)
#text(size: body-s, weight: "bold", fill: accent)[v1: AI 可自动完成科研闭环 → v2: AI 论文通过同行评审。每一步都是 AI4Sci 框架的设计参考。]

== Q&A

#v(3em)
#align(center, text(size: 18pt, weight: "bold", fill: accent)[谢谢！Q & A])
#v(0.5em)
#align(center, text(size: 11pt, fill: secondary-text)[v1: arXiv 2408.06292 / v2: arXiv 2504.08066 · Code: github.com/SakanaAI/AI-Scientist])
