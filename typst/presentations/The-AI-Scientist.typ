#import "/typst/templates/paper-slides.typ": *

#show: paper-slides.with(
  title: "The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery",
  subtitle: "Sakana AI / Oxford / UBC / Vector Institute",
  author: "Biscuit",
  date: "2026-07-09",
)

#cover-slide[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold", fill: accent)[The AI Scientist]
    #v(0.2em)
    #text(size: 16pt, fill: secondary-text)[全自动开放科学发现框架]
    #v(3em)
    #text(size: 13pt)[Chris Lu, Cong Lu, Robert Tjarko Lange 等 · arXiv 2408.06292]
    #v(0.3em)
    #text(size: 13pt)[github.com/SakanaAI/AI-Scientist]
    #v(1em)
    #note-block[#text(size: 13pt, weight: "bold", fill: accent)[单篇论文成本 ~\$15 · 8×H100 一周可生成数百篇]]
  ]
]

== 目录与问题

#grid(
  columns: (1fr, 1.8fr),
  gutter: 2em,
  align: top,
  [
    #text(size: block-head-size, weight: "bold", fill: accent)[Contents]
    #v(0.3em)
    #text(size: block-body-size)[
      1. 背景与动机 \
      #v(0.3em)
      2. 四阶段流水线 \
      #v(0.3em)
      3. 实验设置 \
      #v(0.3em)
      4. 代码实现与参数 \
      #v(0.3em)
      5. 核心结果 \
      #v(0.3em)
      6. 局限与展望
    ]
  ],
  [
    #text(size: block-head-size, weight: "bold", fill: accent)[核心问题]
    #v(0.3em)
    #card[
      能否构建一个完全自主的科学家，独立完成从 Idea 到论文的科研全流程？

      现有工作仅覆盖单个环节： \
      · AutoML → 超参/架构搜索 \
      · LLM-as-aide → 辅助写代码/头脑风暴 \
      · 材料AI发现 → 受限搜索空间
    ]
    #v(0.5em)
    #text(size: block-body-size, weight: "bold", fill: accent)[本文贡献]
    #v(0.2em)
    #text(size: block-body-size)[
      首个端到端全自动科研流水线，涵盖 ideation、实验、写作、审稿。
      在扩散模型、语言模型、grokking 三个领域验证有效。
    ]
  ],
)

== Pipeline: 四阶段

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  align: top,
  [
    #card(title: "1. Idea 生成")[
      LLM 基于存档 + 种子 idea 变异产生新想法。 \
      #text(weight: "bold")[参数]：self-reflection 3 轮，Semantic Scholar 搜索最多 10 轮
    ]
  ],
  [
    #card(title: "2. 实验迭代")[
      Aider 编辑 experiment.py 并执行 `python experiment.py --out_dir=run_i`。 \
      #text(weight: "bold")[参数]：重试 MAX_ITERS=4，实验 MAX_RUNS=5，超时 7200s
    ]
  ],
  [
    #card(title: "3. 论文写作")[
      逐节填充 LaTeX（Intro → Method → Results → Conclusion）。 \
      #text(weight: "bold")[参数]：引用搜索 20 轮，LaTeX 纠错 5 轮
    ]
  ],
  [
    #card(title: "4. 自动审稿")[
      GPT-4o 读取 PDF，输出 NeurIPS 评分 + Accept/Reject。 \
      #text(weight: "bold")[参数]：reflection 5 轮，集成 5 个审稿，temperature 0.1
    ]
  ],
)

#v(0.3em)
#text(size: block-body-size, fill: secondary-text)[核心技术栈：LLM (Claude/GPT-4o) + Aider + Semantic Scholar + LaTeX]

== 实验设置

#text(size: block-head-size, weight: "bold", fill: accent)[三个领域 × 四个基座模型]

#v(0.3em)

#table(
  columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
  inset: 8pt,
  stroke: 0.5pt,
  align: center + horizon,
  table.header(
    [#text(weight: "bold", size: block-body-size)[领域]],
    [#text(weight: "bold", size: block-body-size)[Sonnet 3.5]],
    [#text(weight: "bold", size: block-body-size)[GPT-4o]],
    [#text(weight: "bold", size: block-body-size)[DeepSeek]],
    [#text(weight: "bold", size: block-body-size)[Llama 405b]],
  ),
  [#text(size: block-body-size)[2D Diffusion]], [#text(size: block-body-size)[38篇]], [#text(size: block-body-size)[16篇]], [#text(size: block-body-size)[31篇]], [#text(size: block-body-size)[21篇]],
  [#text(size: block-body-size)[NanoGPT]], [#text(size: block-body-size)[20篇]], [#text(size: block-body-size)[16篇]], [#text(size: block-body-size)[23篇]], [#text(size: block-body-size)[21篇]],
  [#text(size: block-body-size)[Grokking]], [#text(size: block-body-size)[25篇]], [#text(size: block-body-size)[13篇]], [#text(size: block-body-size)[36篇]], [#text(size: block-body-size)[30篇]],
)

#v(0.2em)
#text(size: note-size, fill: secondary-text)[每模板 50+ idea，模型成本 ~\$250(Claude) ~ \$10(DeepSeek)，实验在 8×H100 上运行一周]

#v(0.2em)
#card[
  #text(size: block-body-size)[Sonnet 3.5 综合最优。最高分论文 6.0（NeurIPS 接收线 ~6）。GPT-4o LaTeX 编译失败率高。DeepSeek 最便宜但 Aider 调用经常失败。Llama 405b 输出格式不稳定。]
]

== 代码实现: Aider 实验循环

#two-col(
  [
    #card(title: "每 idea 执行流程")[
      #text(size: block-body-size)[
        1. #text(weight: "bold")[Fork 模板] — `shutil.copytree()` 隔离各 idea \
        2. Aider 编辑 `experiment.py` 实现算法变更 \
        3. 执行 `python experiment.py --out_dir=run_i` \
        4. 读取 `final_info.json` 收集结果 \
        5. 若失败 → Aider 修复代码，重试 ≤ 4 次 \
        6. 循环步骤 2-5 最多 5 轮实验 \
        7. Aider 编辑 `plot.py` 生成可视化
      ]
    ]
  ],
  [
    #card(title: "关键参数汇总")[
      #v(0.2em)
      #grid(columns: (1.5fr, 1fr), gutter: 0.2em,
        [#text(size: 13pt)[Idea reflection]], [#text(size: 13pt, fill: accent)[3]],
        [#text(size: 13pt)[Novelty 搜索]], [#text(size: 13pt, fill: accent)[10 轮]],
        [#text(size: 13pt)[MAX_ITERS]], [#text(size: 13pt, fill: accent)[4]],
        [#text(size: 13pt)[MAX_RUNS]], [#text(size: 13pt, fill: accent)[5]],
        [#text(size: 13pt)[实验超时]], [#text(size: 13pt, fill: accent)[7200s]],
        [#text(size: 13pt)[引用搜索]], [#text(size: 13pt, fill: accent)[20 轮]],
        [#text(size: 13pt)[审稿 reflection]], [#text(size: 13pt, fill: accent)[5]],
        [#text(size: 13pt)[审稿集成数]], [#text(size: 13pt, fill: accent)[5]],
      )
    ]
  ],
)

#v(0.3em)
#card[
  #text(size: block-body-size)[
    #text(weight: "bold")[入口]：`python launch_scientist.py --experiment 2d_diffusion --model claude-3-5-sonnet-20241022 --num-ideas 50 --parallel 4`
    #v(0.2em)
    开放式进化模式：`python experimental/launch_oe_scientist.py`（每轮单 idea，分数反馈到下一轮）
  ]
]

== 自动审稿验证

#text(size: block-head-size, weight: "bold", fill: accent)[GPT-4o 审稿在 ICLR 2022 数据集上达到人类水平]

#v(0.3em)

#table(
  columns: (2fr, 1fr, 1fr, 1fr),
  inset: 8pt,
  stroke: 0.5pt,
  align: center + horizon,
  table.header(
    [#text(weight: "bold", size: block-body-size)[指标]],
    [#text(weight: "bold", size: block-body-size)[Human]],
    [#text(weight: "bold", size: block-body-size)[GPT-4o]],
    [#text(weight: "bold", size: block-body-size)[对比]],
  ),
  [#text(size: block-body-size)[Balanced Acc.]], [#text(size: block-body-size)[0.66]], [#text(size: block-body-size, fill: accent)[0.65]], [#text(size: block-body-size)[持平]],
  [#text(size: block-body-size)[Accuracy]], [#text(size: block-body-size)[0.73]], [#text(size: block-body-size)[0.66]], [#text(size: block-body-size)[略低]],
  [#text(size: block-body-size)[F1 Score]], [#text(size: block-body-size)[0.49]], [#text(size: block-body-size, fill: accent)[0.57]], [#text(size: block-body-size)[超越]],
  [#text(size: block-body-size)[AUC]], [#text(size: block-body-size)[0.65]], [#text(size: block-body-size, fill: accent)[0.65]], [#text(size: block-body-size)[持平]],
  [#text(size: block-body-size)[FNR]], [#text(size: block-body-size)[0.52]], [#text(size: block-body-size, fill: accent)[0.39]], [#text(size: block-body-size)[更低（少拒好论文）]],
)

#v(0.3em)
#card[
  #text(size: block-body-size)[
    人类 reviewer 之间评分一致性为 0.14，而 LLM 与人类平均分之间一致性为 0.18。LLM 审稿与人类平均分对齐程度反而高于单个 reviewer 之间的对齐程度。
  ]
]

== 局限性

#two-col(
  [
    #card(title: "技术局限")[
      #text(size: block-body-size)[
        · Idea 多样性不足，不同运行间高度相似 \
        · 实验深度有限（最多 5 轮） \
        · 无法查看图表（无视觉能力） \
        · 幻觉：捏造硬件信息、实验结果
      ]
    ]
  ],
  [
    #card(title: "安全风险")[
      #text(size: block-body-size)[
        · 出现过程序 fork bomb \
        · 单次运行保存 ~1TB 检查点 \
        · 试图绕过实验时间限制 \
        · 作者：不建议直接信任生成论文的科学内容
      ]
    ]
  ],
)

== AI for Science 关联

#card[
  #text(size: block-body-size)[
    #text(weight: "bold", fill: accent)[可直接复用的方面] \

    #v(0.3em)
    1. #text(weight: "bold")[自动化科研流水线] — 给定代码模板即可自动探索改进方案，适用于分子动力学、量子化学等场景 \

    #v(0.3em)
    2. #text(weight: "bold")[自评估机制] — 自动审稿可作为实验结果的自动评估工具 \

    #v(0.3em)
    3. #text(weight: "bold")[开放进化范式] — 存档 + 变异 + 选择，与 AI4Sci 的自动化探索高度契合

    #v(0.5em)
    #text(weight: "bold", fill: accent)[社区已提供的扩展模板] \

    #v(0.3em)
    · #text(weight: "bold")[MACE] — 量子化学势能面拟合 \
    · #text(weight: "bold")[SEIR] — 传染病动力学建模 \
    · #text(weight: "bold")[tensorf] — 辐射场 / 3D 场景重建
  ]
]

#thanks-slide(
  extra: [
    arXiv:2408.06292 / github.com/SakanaAI/AI-Scientist
  ],
)
