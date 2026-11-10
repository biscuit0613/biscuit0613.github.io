#import "/typst/templates/paper-slides.typ": *

#let body-s = 15pt
#let body-m = 16pt
#let head-s = 18pt

#show: paper-slides.with(
  title: "SAGA: Accelerating Scientific Discovery with Autonomous Goal-evolving Agents",
  subtitle: "arXiv 2512.21782 · 2025",
  author: "Biscuit",
  date: "2026-07-15",
)

#cover-slide[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold", fill: accent)[SAGA]
    #v(0.3em)
    #text(size: 20pt, fill: accent)[Autonomous Goal-evolving Agents for Scientific Discovery]
    #v(2em)
    #text(size: 14pt, fill: secondary-text)[Yuanqi Du, Botao Yu, et al. · Cornell, OSU, Yale, EPFL, UC Berkeley, Broad Institute, Deep Principle]
    #v(0.3em)
    #text(size: 13pt, fill: secondary-text)[arXiv 2512.21782 · github.com/btyu/SAGA (MIT)]
    #v(1em)
    #note-block[
      #text(size: 13pt, weight: "bold", fill: accent)[亮点：抗生素 + 纳米抗体获湿实验验证 · 横跨 5 个科学领域]
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
      [#text(size: 22pt, weight: "bold", fill: accent)[1]], [#text(size: body-s)[动机与核心思想 \  #text(fill: secondary-text, size: 12pt)[固定目标→自演化目标]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[2]], [#text(size: body-s)[SAGA 双层架构 \  #text(fill: secondary-text, size: 12pt)[Planner → Implementer → Optimizer → Analyzer]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[3]], [#text(size: body-s)[三种协作模式 \  #text(fill: secondary-text, size: 12pt)[Co-pilot / Semi-pilot / Autopilot]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[4]], [#text(size: body-s)[五领域实验全景 \  #text(fill: secondary-text, size: 12pt)[抗生素、纳米抗体、DNA、材料、化工]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[5]], [#text(size: body-s)[湿实验验证 \  #text(fill: secondary-text, size: 12pt)[抗生素 MIC + 纳米抗体 K_D]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[6]], [#text(size: body-s)[局限与展望 \  #text(fill: secondary-text, size: 12pt)[lab-in-the-loop 与设计空间自动发现]]],
    )
  ],
  [
    #card[
      #text(size: body-s, weight: "bold", fill: accent)[核心命题]
      #v(0.3em)
      #text(size: body-s, fill: secondary-text)[自动化目标函数设计，而非手动指定并优化固定目标 —— 这才是科学发现的瓶颈所在]
      #v(0.5em)
      #text(size: body-s, weight: "bold", fill: accent)[关键数据]
      #v(0.2em)
      #table(
        columns: (1fr, 1fr),
        inset: 4pt,
        stroke: 0.4pt,
        align: (center, center),
        [#text(size: 12pt, weight: "bold")[5 领域]], [#text(size: 12pt, weight: "bold")[3 模式]],
        [#text(size: 12pt)[2 湿实验]], [#text(size: 12pt)[4 个新 hit]],
        [#text(size: 12pt)[3 个 binder]], [#text(size: 12pt)[48% 提升]],
      )
    ]
    #v(0.3em)
    #text(size: 12pt, fill: secondary-text)[github.com/btyu/SAGA · MIT License · Python + Docker]
  ],
)

== 动机：固定目标的困境

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "问题")[
      #text(size: body-s)[
        现有科学发现 agent 假设目标函数已知且固定。但：\
        - 计算代理与实际实验相关性弱 \
        - 优化算法会 exploit 代理误差，产生"高分低质"解 \
        - 目标及其权重的搜索空间本身组合爆炸
      ]
    ]
    #v(0.3em)
    #card(title: "SAGA 的答案")[
      #text(size: body-s)[
        将目标函数设计本身变成自动发现过程：\
        外层循环探索目标空间，内层循环优化候选解。\
        模仿科学家"根据中间结果调整目标"的迭代范式。
      ]
    ]
  ],
  [
    #v(0.3em)
    #card(title: "思考快与慢")[
      #text(size: body-s)[
        #text(weight: "bold")[Inner Loop = 系统 1]：给定目标，快速搜索最优解 \
        #text(weight: "bold")[Outer Loop = 系统 2]：审视结果，反思并调整目标
      ]
    ]
  ],
)

== SAGA 双层架构

#text(size: head-s, weight: "bold", fill: accent)[外循环：目标演化 + 内循环：候选优化]
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "")[
      #text(size: body-m)[1. Planner（规划器）]
      #text(size: body-s)[分解科学目标 → 可计算 objectives（名称、描述、方向、权重）]
      #text(size: body-m)[2. Implementer（实现器）]
            #text(size: body-s)[自动实现评分函数（搜索 web → 写代码 → Docker 验证）· 不可实现则通知 Planner 重试]
      #text(size: body-m)[3. Optimizer（优化器）]
      #text(size: body-s)[默认 LLM 进化算法：生成候选 → 批量打分 → 选 top 更新池 · 可插拔替代]
      #text(size: body-m)[4. Analyzer（分析器）]
      #text(size: body-s)[统计分数趋势 + 深入结构分析 → 生成报告 → 触发下轮目标 · 可判定提前终止]
    ]
  ],
  [
    #card()[
      #text(size: body-s)[
        #text(weight: "bold")[输入]：自然语言目标 + 上下文 + 初始 objectives + 初始候选 \
        #text(weight: "bold")[循环]：Planner → Implementer → Optimizer → Analyzer → Planner \
        #text(weight: "bold")[输出]：跨迭代最优候选集
      ]
    ]
    #card()[
      #text(size: body-s)[
        - Implementer 可自动搜索 web 编写评分函数 \
        - Analyzer 写代码分析候选结构/性质 \
        - 所有评分函数在 Docker 中运行保证安全 \
        - 评估指标对优化过程不可见（hold-out）
      ]
    ]
  ],
)

== 三种协作模式

#text(size: head-s, weight: "bold", fill: accent)[从全人工干预到全自动，适合不同研究阶段]

#table(
  columns: (1.5fr, 2fr, 2.5fr, 1fr),
  inset: 6pt,
  stroke: 0.4pt,
  align: (left, left, left, center),
  table.header(
    [#text(size: body-s, weight: "bold")[模式]],
    [#text(size: body-s, weight: "bold")[人参与点]],
    [#text(size: body-s, weight: "bold")[自动化部分]],
    [#text(size: body-s, weight: "bold")[适用场景]],
  ),
  [#text(size: 13pt, weight: "bold")[Co-pilot]], [#text(size: 13pt)[Planner 提案 + Analyzer 报告均可修改]], [#text(size: 13pt)[Implementer + Optimizer 自动运行]], [#text(size: 13pt)[早期探索、高风险领域]],
  [#text(size: 13pt, weight: "bold")[Semi-pilot]], [#text(size: 13pt)[仅 Analyzer 输出由人评审]], [#text(size: 13pt)[Planner + Implementer + Optimizer 自动]], [#text(size: 13pt)[中期优化、有经验方向]],
  [#text(size: 13pt, weight: "bold")[Autopilot]], [#text(size: 13pt)[无人类干预]], [#text(size: 13pt)[全部四个模块自主运行]], [#text(size: 13pt)[成熟方向、大规模探索]],
)

#v(0.3em)

#card(title: "结果")[
  #text(size: body-s)[
    Autopilot 在多个任务中达到或超越 human-in-the-loop 水平。88.8% 的 objectives 由统计驱动，跨独立重复实验高度一致。
  ]
]

== 五领域实验全景

#text(size: head-s, weight: "bold", fill: accent)[横跨化学、生物、材料 · 优化目标均由 SAGA 自动演化]

#table(
  columns: (1fr, 1.2fr, 1.5fr, 1.5fr),
  inset: 5pt,
  stroke: 0.4pt,
  align: (left, left, left, center),
  table.header(
    [#text(size: body-s, weight: "bold")[领域]],
    [#text(size: body-s, weight: "bold")[任务]],
    [#text(size: body-s, weight: "bold")[核心结果]],
    [#text(size: body-s, weight: "bold")[验证方式]],
  ),
  [#text(size: 13pt, weight: "bold")[抗生素设计]], [#text(size: 13pt)[E. coli 抗菌小分子]], [#text(size: 13pt)[4 个 hit · MIC 16 μg/mL]], [#text(size: 13pt, fill: accent)[湿实验]],
  [#text(size: 13pt, weight: "bold")[纳米抗体设计]], [#text(size: 13pt)[PD-L1 结合剂]], [#text(size: 13pt)[3 个 binder · K_D 300-400nM]], [#text(size: 13pt, fill: accent)[湿实验 (BLI)]],
  [#text(size: 13pt, weight: "bold")[功能 DNA 设计]], [#text(size: 13pt)[HepG2 增强子]], [#text(size: 13pt)[特异性 +48% · motif +48%]], [#text(size: 13pt)[计算 (MPRA)]],
  [#text(size: 13pt, weight: "bold")[无机材料设计]], [#text(size: 13pt)[永磁体 + 超硬材料]], [#text(size: 13pt)[>90% 含轻元素 · >75% 碳氮硼化物]], [#text(size: 13pt)[DFT 计算]],
  [#text(size: 13pt, weight: "bold")[化工过程设计]], [#text(size: 13pt)[丁醇/水共沸分离]], [#text(size: 13pt)[消除无效单元操作 · 平衡成本/纯度]], [#text(size: 13pt)[short-cut 模拟]],
)

#v(0.2em)
#text(size: 12pt, fill: secondary-text)[SAGA 自演化出的 objectives 还能迁移到其他方法（REINVENT4、TextGrad），提升其性能。]

== 湿实验验证亮点

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "抗生素：化合物 8")[
      #text(size: body-s)[
        #text(weight: "bold")[MIC]：16 μg/mL (E. coli) \
        #text(weight: "bold")[结构新颖性]：Tanimoto 距离 0.28，远低于 0.4 阈值 \
        #text(weight: "bold")[安全性]：HEK293 + HepG2 细胞系无细胞毒性 \
        #text(weight: "bold")[筛选]：28 个化合物中 4 个抑制率 >80%
      ]
    ]
    #card(title: "关键")[
      #text(size: body-s)[
        #text(weight: "bold")[总筛选]：28 个 SAGA 设计的化合物 → 4 个 hit → 1 个最好的（化合物 8）\
        #text(weight: "bold")[机制]：SAGA 自动引入代谢稳定性 + 药物相似性目标，避免 reward hacking
      ]
    ]
  ],
  [
    #card(title: "纳米抗体：3 个 PD-L1 Binder")[
      #text(size: body-s)[
        #text(weight: "bold")[K_D]：300-400 nM (BLI 实验) \
        #text(weight: "bold")[结构新颖性]：CDR3 与已知抗体 $lt$20% 序列相似性 \
        #text(weight: "bold")[独特结构]：A2 的 CDR3 形成非经典 α-helix \
        #text(weight: "bold")[统计显著性]：复合评分函数 p = 0.03，任何单指标 p > 0.05
      ]
    ]
    #card(title: "关键")[
      #text(size: body-s, style: "italic")[SAGA 自动构建的复合目标显著区分了 binder 和 non-binder（p = 0.03），而任何单一 in silico 指标都无法做到。]
      #v(0.1em)
    ]
  ],
)

== 局限与展望

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  [
    #card(title: "技术局限")[
      #text(size: body-s)[
        #text(weight: "bold")[计算依赖]：仅适用于可计算验证的目标，无法接入真实实验反馈\
        #text(weight: "bold")[设计空间预定义]：需人为指定搜索空间（如"小分子"），无法自动决定模态\
        #text(weight: "bold")[模型开销]：依赖 GPT-5 级别模型，API 费用高\
        #text(weight: "bold")[代码不完整]
      ]
    ]
  ],
  [
    #card(title: "可借鉴之处")[
      #text(size: body-s)[
        - 双层架构可迁移到任何科学优化任务\
        - 自演化目标函数解决 reward hacking 和代理偏差\
        - Co-pilot 模式提供实用的 human-in-the-loop 方案\
      ]
    ]
  ],
)

== Q&A

#v(3em)
#align(center, text(size: 18pt, weight: "bold", fill: accent)[谢谢！Q & A])
#v(0.5em)
#align(center, text(size: 11pt, fill: secondary-text)[arXiv 2512.21782 · Code: github.com/btyu/SAGA · 汇报人: Biscuit])