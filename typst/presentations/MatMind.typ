#import "/typst/templates/paper-slides.typ": *

#let body-s = 14pt
#let head-s = 17pt

#show: paper-slides.with(
  title: "MatMind: structure-activity knowledge-driven generative foundation model for materials science",
  subtitle: "材料科学基座模型：构效关系 + 双头架构 + 物理强化学习",
  author: "Biscuit",
  date: "2026-07-12",
)

#cover-slide[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold", fill: accent)[MatMind]
    #v(0.3em)
    #text(size: 18pt, fill: accent)[Structure-Activity Knowledge-Driven Generative Foundation Model for Materials Science]
    #v(2em)
    #text(size: 13pt, fill: secondary-text)[arXiv 2606.07712 · Springer Nature 审稿中]
    #v(0.5em)
    #text(size: 13pt, fill: secondary-text)[基于S1-Base 8B（Qwen3-8B）· Alexandria + MP-20 数据库]
    #v(1.5em)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 1.5em,
      [#note-block[#text(size: body-s, fill: accent, weight: "bold")[E_hull MAE 0.0109] #text(size: 12pt, fill: secondary-text)[超越 CGCNN/M3GNet]]],
      [#note-block[#text(size: body-s, fill: accent, weight: "bold")[S.U.N. 65.3%] #text(size: 12pt, fill: secondary-text)[无条件生成超越 MatterGen]]],
      [#note-block[#text(size: body-s, fill: accent, weight: "bold")[4.3× 提升] #text(size: 12pt, fill: secondary-text)[极稀疏条件生成 (21/600k)]]],
    )
  ]
]

== Outline

#grid(
  columns: (1fr, 2fr),
  gutter: 2em,
  align: top,
  [
    #table(
      columns: (0.5fr, 4fr),
      inset: 6pt,
      stroke: none,
      align: (center, left),
      [#text(size: 22pt, weight: "bold", fill: accent)[1]], [#text(size: body-s)[三阶段渐进式训练 \ #text(fill: secondary-text, size: 12pt)[pretrain → SAR + 双头 → GRPO RL]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[2]], [#text(size: body-s)[双头架构设计 \ #text(fill: secondary-text, size: 12pt)[语言头 + 回归头 + warm-up]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[3]], [#text(size: body-s)[GRPO 多目标物理 RL \ #text(fill: secondary-text, size: 12pt)[组内相对优势 + 4 种奖励]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[4]], [#text(size: body-s)[评价指标 \ #text(fill: secondary-text, size: 12pt)[MAE + S.U.N. + 评价管线]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[5]], [#text(size: body-s)[实验结果 \ #text(fill: secondary-text, size: 12pt)[性质预测 / 无条件生成 / 条件迁移]]],
      [#text(size: 22pt, weight: "bold", fill: accent)[6]], [#text(size: body-s)[局限与思考 \ #text(fill: secondary-text, size: 12pt)[计算成本 / 消融待补 / 代码未开源]]],
    )
  ],
  [
    #card[
      #text(size: body-s, weight: "bold", fill: accent)[核心问题]
      #v(0.3em)
      #text(size: body-s, fill: secondary-text)[材料 AI 被"窄架构"分割：GNN 做预测，扩散模型做生成。能否用一个 LLM 统一承载结构表示、定量预测、构效推理？]
      #v(0.5em)
      #text(size: body-s, weight: "bold", fill: accent)[MatMind 的回答]
      #v(0.2em)
      #text(size: body-s)[三阶段渐进式训练框架，协同激活领域知识与物理反馈]
      #v(0.3em)
      #table(
        columns: (1fr, 1fr, 1fr),
        inset: 3pt,
        stroke: 0.4pt,
        align: (center, center, center),
        [#text(size: 11pt, weight: "bold")[构效知识注入]], [#text(size: 11pt, weight: "bold")[双头架构]], [#text(size: 11pt, weight: "bold")[物理 RL]],
        [#text(size: 11pt)[随机交错CIF+物性+文本]], [#text(size: 11pt)[语言推理+数值回归互增强]], [#text(size: 11pt)[稳定性/新颖性/多样性协调]],
      )
    ]
  ],
)

== Three-stage training

#align(center)[#text(size: head-s, weight: "bold", fill: accent)[三阶段分工明确：基座 → 预测 → 生成]]
#v(0.2em)

#table(
  columns: (1.2fr, 1.5fr, 1.5fr, 2.2fr),
  inset: 4pt,
  stroke: 0.4pt,
  align: (left, center, center, left),
  table.header(
    [#text(size: body-s, weight: "bold")[Stage]],
    [#text(size: body-s, weight: "bold")[输入]],
    [#text(size: body-s, weight: "bold")[输出]],
    [#text(size: body-s, weight: "bold")[核心能力]],
  ),
  [#text(size: 12pt)[1 基座构建]], [#text(size: 12pt)[CIF+数值+文本]], [#text(size: 12pt)[更好的 LLM]], [#text(size: 12pt)[建立材料科学先验]],
  [#text(size: 12pt)[2 SAR+双头]], [#text(size: 12pt)[CIF + 问题]], [#text(size: 12pt)[CoT推理 + 数值]], [#text(size: 12pt)[正向：结构 → 性质]],
  [#text(size: 12pt)[3 GRPO RL]], [#text(size: 12pt)[指令]], [#text(size: 12pt)[Wyckoff 序列]], [#text(size: 12pt)[反向：性质 → 结构]],
)

#v(0.3em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.6em,
  align: top,
  [
    #card(title: "Stage 1: 随机交错预训练")[
      #text(size: body-s)[
        基于 S1-Base 8B（Qwen3-8B）\
        Alexandria 数据库稳定子集\
        CIF + DFT 物性 + 文本随机交错\
        同一结构中三者轮流出现 \
        → 跨模态关联自然建立
      ]
    ]
  ],
  [
    #card(title: "Stage 2: SAR + 双头预测")[
      #text(size: body-s)[
        30K 专家标注 SAR 数据\
        语言头：CoT 推理，交叉熵 loss\
        回归头：MeanPool→Linear(1)，MSE\
        Warm-up：先冻 backbone 训回归头→再联合
      ]
    ]
  ],
  [
    #card(title: "Stage 3: GRPO 物理 RL")[
      #text(size: body-s)[
        Wyckoff SFT → 语法合格\
        GRPO：组内 G 个候选 → MLIP 弛豫\
        → 4 种奖励 → 组内归一化 → 策略更新\
        RL 贡献 S.U.N. +23.2pp
      ]
    ]
  ],
)

== Dual-head architecture

#two-col(
  ratio: (1fr, 1fr),
  [
    #card(title: "回归头设计")[
      #text(size: body-s)[
        最后一层所有 token hidden state 做 mean pooling，经线性变换输出标量：\
        $hat(y) = W_("reg") dot 1/L sum_(i=1)^L h_i + b_("reg") $\
        $W_"reg" in bb(R)^(1 times d)$ 线性投影 \
        MSE 损失：$cal(L)_"pre" = 1/N sum (hat(y)_n - y_n)^2$
      ]
    ]
    #card(title: "语言头（SAR SFT）")[
      #text(size: body-s)[
        标准自回归 next-token prediction \
        CoT 推理链：排序/区间判断/目标筛选 \
        损失 $cal(L)_"kno" = -1/T sum log p_theta (x|x_(<t))$
      ]
    ]
  ],
  [
    #card(title: "联合损失 + Warm-up")[
      #text(size: body-s)[
        $ cal(L)_("all") = alpha cal(L)_("kno") + beta cal(L)_("pre") $
      ]
      #text(size: body-s, weight: "bold")[$alpha$, $beta$：Pareto 前沿确定]

      #text(size: body-s, weight: "bold", fill: accent)[两步热身warm-up]
      #text(size: body-s)[

        回归头参数随机初始化，backbone 36 层已充分训练。直接联合导致随机梯度噪声破坏 backbone 表征。解决：
        1. 冻结 backbone，只训回归头 \
        2. 解冻所有参数联合优化
      ]
      #text(size: body-s)[
        - $cal(L)_"pre"$ 梯度穿过backbone36层约束输出 \
        - $cal(L)_"kno"$ 梯度约束语言推理 \
        → hidden state 朝双向优化调整
      ]
    ]
  ],
)

== Grpo multi-objective rl

#two-col(
  ratio: (1fr, 1fr),
  [
    #card(title: "GRPO 迭代流程")[
      #text(size: body-s)[
        1. 策略 $pi_theta$ 生成 G 个 Wyckoff 序列 (e.g. G=12)\
        2. 每个序列 → CIF → MLIP 弛豫 → 算奖励 \
        3. 门控 $V(C)$：间距≥0.5Å + 电中性 + 弛豫收敛 \
        4. 组内归一化：$A_i = frac(R(C_i) - mu_R, sigma_R + epsilon)$ \
        5. 优势函数 $A_i$ 更新 $theta$
      ]
    ]
    #v(0.3em)
    #align(right)[
      #text(size: 12pt)[$ cal(L)_("GRPO") = - bb(E) [ 1/G sum_(i=1)^G min( frac(pi_theta(C_i), pi_("old")(C_i)) A_i, "clip"( dots.c ) A_i ) ] + beta dot D_("KL") $]
    ]
  ],
  [
    #card(title: "4 种奖励")[
      #text(size: body-s, weight: "bold")[$R_S$ 稳定性]
      #text(size: body-s)[
        基于 $E_"hull"$ 凸衰减映射 \
        $E_"hull" <= 0.1 arrow.r 1$ \
        $E_"hull" >= 0.2 arrow.r 0$ \
        凸指数 $gamma=2$ 聚焦近稳定结构\
      ]
      #text(size: body-s, weight: "bold")[$R_N$ 新颖性]
      #text(size: body-s)[StructureMatcher 硬门控 + 指纹距离软打分\
      ]
      #text(size: body-s, weight: "bold")[$R_U$ 多样性]
      #text(size: body-s)[组内指纹距离 → Shannon 熵 → 归一化\
      ]
      #text(size: body-s, weight: "bold")[$R_P$ 条件匹配]
      #text(size: body-s)[条件生成时属性一致性]
    ]
  ],
)

== Metrics

#two-col(
  
  ratio: (1fr, 1fr),
  [
    #card(title: "性质预测：MAE")[
      #text(size: body-s, weight: "bold")[三个物理维度各异的属性]
      #v(0.2em)
      #text(size: body-s)[
        #text(weight: "bold")[$E_"hull"$] (eV/atom)：热力学稳定性 \
        #text(weight: "bold")[体模量] (GPa)：力学功能属性 \
        #text(weight: "bold")[带隙] (eV)：电子功能属性
      ]
    ]
    #card(title: "性质预测结果")[
      #table(
        columns: (2.2fr, 1.3fr, 1fr, 1fr, 1.3fr),
        inset: 3pt,
        stroke: 0.4pt,
        align: (left, center, center, center, center),
        table.header(
          [#text(size: 11pt, weight: "bold")[任务]], [#text(size: 11pt, weight: "bold")[MatMind]], [#text(size: 11pt, weight: "bold")[CGCNN]], [#text(size: 11pt, weight: "bold")[M3GNet]], [#text(size: 11pt, weight: "bold")[LLM-Prop]],
        ),
        [#text(size: 11pt)[$E_"hull"$]], [#text(size: 11pt, fill: accent, weight: "bold")[0.0109]], [#text(size: 11pt)[0.0123]], [#text(size: 11pt)[0.0130]], [#text(size: 11pt)[0.0138]],
        [#text(size: 11pt)[体模量]], [#text(size: 11pt, fill: accent, weight: "bold")[5.36]], [#text(size: 11pt)[5.55]], [#text(size: 11pt)[5.57]], [#text(size: 11pt)[6.14]],
        [#text(size: 11pt)[带隙]], [#text(size: 11pt, fill: accent, weight: "bold")[0.197]], [#text(size: 11pt)[0.244]], [#text(size: 11pt)[0.209]], [#text(size: 11pt)[0.346]],
      )
      #v(0.2em)
      #text(size: 12pt, fill: secondary-text)[首次以 LLM 范式超越专用 GNN]
    ]
  ],
  [
    #card(title: "晶体生成：S.U.N. 率")[
      #text(size: body-s)[
        三重筛选的复合指标：
      ]
      #v(0.1em)
      #text(size: body-s)[
        #text(weight: "bold")[S]table — $E_"hull" <= 0$，热力学可合成 \
        #text(weight: "bold")[U]nique — 组内 $N$ 个结构两两不等价 \
        #text(weight: "bold")[N]ovel — 不匹配 MP-20 + Alexandria 训练集
      ]
    ]
    #v(0.3em)
    #card(title: "无条件生成 S.U.N.")[
      #table(
        columns: (2.5fr, 1.5fr),
        inset: 3pt,
        stroke: 0.4pt,
        align: (left, center),
        table.header(
          [#text(size: 11pt, weight: "bold")[方法]], [#text(size: 11pt, weight: "bold")[S.U.N. 率]],
        ),
        [#text(size: 11pt, fill: accent, weight: "bold")[MatMind CIF RL]], [#text(size: 11pt, fill: accent, weight: "bold")[65.3%]],
        [#text(size: 11pt)[MatterGen]], [#text(size: 11pt)[44.3%]],
        [#text(size: 11pt)[DiffCSP]], [#text(size: 11pt)[40.2%]],
        [#text(size: 11pt)[MatMind SFT (无 RL)]], [#text(size: 11pt)[42.1%]],
      )
      #v(0.2em)
      #text(size: 12pt, fill: accent, weight: "bold")[RL 贡献 +23.2pp]
      #text(size: 12pt, fill: secondary-text)[，SFT 仅与扩散基线持平]
    ]
  ],
)

== Conditional generation and limitations

#two-col(
  ratio: (1.2fr, 1fr),
  [
    #card(title: "条件生成：极稀疏迁移")[
      #text(size: body-s, weight: "bold")[输入条件：磁化密度 $>= 0.2 mu_B$/Å^3
        （正样本仅 #text(fill: accent, weight: "bold")[21 个]（60 万中））\
        RL阶段前后的生成质量对比：\
        Pre-RL 1.2% → Post-RL 5.2%\
      ]
      #text(size: body-s, weight: "bold")[其他条件任务\
      ]
      #table(
        columns: (2fr, 1.5fr, 1.5fr),
        inset: 3pt,
        stroke: 0.4pt,
        align: (left, center, center),
        table.header(
          [#text(size: 11pt, weight: "bold")[条件]], [#text(size: 11pt, weight: "bold")[Pre-RL]], [#text(size: 11pt, weight: "bold")[Post-RL]],
        ),
        [#text(size: 11pt)[带隙 >5eV]], [#text(size: 11pt)[18.0%]], [#text(size: 11pt)[34.8%]],
        [#text(size: 11pt)[体模量 ~300GPa]], [#text(size: 11pt)[12.8%]], [#text(size: 11pt)[26.8%]],
      )

        生成的 Gd₂FeIr 和 Gd₂MnCo₃ 在化学上合理 —— \
        模型学到了 #text(fill: accent, weight: "bold")[真正的构效关系]，而非插值。
    ]
  ],
  [
    #card(title: "局限性")[
      #text(size: body-s, weight: "bold", fill: accent)[论文层面\
      ]
      #text(size: body-s)[
        · 参考文献大量 TODO_xxx 占位符 \
        · 消融实验未完成 \
        · 注意力分析未完成\
      ]
      #text(size: body-s, weight: "bold", fill: accent)[工程层面\
      ]
      #text(size: body-s)[
        · 8B 三阶段计算成本未披露 \
        · 完全依赖 DFT/MLIP，未验证实验一致性 \
        · 代码未开源，复现门槛高 \
        · 依赖链长（NequIP / eSEN / MP 凸包）
      ]
    ]
  ],
)

== Q&A

#v(4em)
#align(center, text(size: 22pt, weight: "bold", fill: accent)[谢谢！Q & A])
#v(1em)
#align(center, text(size: 12pt, fill: secondary-text)[arXiv: 2606.07712 · 代码暂未开源 · biscuit0613.github.io])
