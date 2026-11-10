---
title: '模型压缩：量化与蒸馏'
published: 2026-10-20
description: '用低精度表示权重和激活：均匀量化、粒度与 QAT/PTQ，以及 LLM.int8、GPTQ、SmoothQuant、AWQ 和知识蒸馏'
image: ''
tags: [NLP, LLM, Quantization, Distillation, Deployment]
category: '09-自然语言处理'
order: 1102
draft: false
lang: ''
---

## 为什么需要压缩

大模型部署受两类资源限制：

- **显存**：模型权重、KV Cache 和激活值要同时放进 GPU；
- **带宽与算力**：Decode 阶段每生成一个 token 都要读取大量权重，访存带宽常成为瓶颈。

压缩的目标是在尽量保持效果的前提下，减少存储和计算量。两种主要手段是**量化**（降低每个参数的位数）和**蒸馏**（把大模型的能力迁移到小模型）。

## 量化

量化把浮点数映射为低位整数,用更少的位数来表示模型的参数。一个量化方案通常要描述 量化对象，量化位宽和量化粒度。

### 量化对象

- **权重量化**：减少模型存储和加载带宽，是部署中最常见的做法；
- **激活值量化**：减少每层中间结果的存储和计算，难度更大，因为激活值中存在离群点。

最常用的方法是均匀量化：

$$
q = \operatorname{clip}\left(\operatorname{round}\left(\frac{r}{S}\right) + Z,\; q_{\min},\; q_{\max}\right)
$$

$$
r \approx S(q - Z)
$$

其中：

- $r$ 是量化前的浮点值；
- $S$ 是缩放因子，把浮点范围映射到整数范围；
- $Z$ 是零点，用于表示浮点零对应的整数，支持非对称范围；
- $S,Z$ 被称为 **量化参数**
- $q_{\min}, q_{\max}$ 是量化后的整数范围，例如 int8 为 $[-128, 127]$；
- $\operatorname{clip}$ 防止超出范围。

对称量化令 $Z=0$，常用于权重量化；非对称量化保留零点偏移，适合分布偏斜的激活值。

### 量化粒度

对于激活值和权重，量化粒度决定了每个张量使用多少组量化参数 $S,Z$。常见粒度有：

| 粒度 | 做法 | 特点 |
| --- | --- | --- |
| Per-tensor逐层量化 | 整个张量共用一组 $S, Z$ | 实现简单，精度较低 |
| Per-channel / per-token逐通道/逐token量化 | 每个通道(常见于权重)或每个 token （常见于激活值）单独量化 | 更精细，适合权重/激活分布差异大的情况 |
| Per-group逐组量化 | 把通道分成大小为 $g$ 的组，每组一组参数 | 在精度和开销之间折中 |

组越小，量化越精细、精度越高，但需要存储更多缩放因子。$g=1$ 退化为逐通道，$g$ 等于通道数时退化为逐张量。

### 方法：量化感知与训练后量化

- **QAT（quantization-aware training）**：训练时就模拟量化
  - 前向用伪量化值：在前向传播时，模型会将浮点数量化为整数，并在计算中使用这些量化值；
  - 反向仍用浮点梯度：在反向传播时，模型仍使用浮点梯度进行更新，让模型适应低精度；
- **QAF（quantization-aware fine-tuning）**：在微调阶段加入量化感知，兼顾压缩和效果；
- **PTQ（post-training quantization）**：直接对训练好的模型(权重&激活值)量化，**无需重新训练**，实现简单、成本低，但会带来精度损失。

大模型通常先用 PTQ；精度不够时再考虑 QAT/QAF。

## 常见 PTQ 方法

### LLM.int8()

观察：激活值中存在少量数值很大的离群特征，它们拉伸了量化范围，导致其他值有效位数不足。

方便推导下面用行向量表示一个token的激活值，假设输入的隐藏状态为：

$$
X\in\mathbb{R}^{T\times d_{model}},\quad W\in\mathbb{R}^{d_{model}\times d_{ffn}},\quad Y=XW
$$

$$
\boxed{
\begin{aligned}
&\textbf{Input: } \text{隐藏状态矩阵 } X,\ \text{权重矩阵 } W,\ \text{离群检测阈值 } \tau
\\
&\textbf{Output: } \text{FP16 精度的矩阵乘法结果 } Y
\\[3pt]
\hline
\\[-2pt]
&\textbf{Step 1: } \text{离群特征检测}
\\
&\quad\mathcal{O}
=
\left\{
j\mid \exists i,\ |X_{ij}|>\tau
\right\}
\\
&\quad\bar{\mathcal{O}}
=
\left\{
1,\ldots,H
\right\}\setminus\mathcal{O}
\\
&\text{按照特征维度（列）划分输入矩阵，并 *同步* 划分权重矩阵：}
\\
&\quad X=[X_{\mathcal{O}},X_{\bar{\mathcal{O}}}],
\qquad
W=
\begin{bmatrix}
W_{\mathcal{O}}\\
W_{\bar{\mathcal{O}}}
\end{bmatrix}
\\[5pt]
\hline
\\[-2pt]
&\textbf{Step 2: } \text{混合精度分块矩阵乘法}
\\
&\text{离群特征分支：保持 FP16 精度进行矩阵乘法}
\\
&\quad Y_{\mathcal{O}}^{\mathrm{FP16}}
=
X_{\mathcal{O}}^{\mathrm{FP16}}
W_{\mathcal{O}}^{\mathrm{FP16}}
\\[3pt]
&\text{普通特征分支：将输入和权重量化为 INT8}
\\
&\quad X_{\bar{\mathcal{O}}}^{\mathrm{FP16}}
\xrightarrow{Q_X}
X_{\bar{\mathcal{O}}}^{\mathrm{INT8}},
\qquad
W_{\bar{\mathcal{O}}}^{\mathrm{FP16}}
\xrightarrow{Q_W}
W_{\bar{\mathcal{O}}}^{\mathrm{INT8}}
\\
&\text{执行 INT8 矩阵乘法，使用 INT32 累加结果}
\\
&\quad Y_{\bar{\mathcal{O}}}^{\mathrm{INT32}}
=
X_{\bar{\mathcal{O}}}^{\mathrm{INT8}}
W_{\bar{\mathcal{O}}}^{\mathrm{INT8}}
\\[5pt]
\hline
\\[-2pt]
&\textbf{Step 3: } \text{反量化与结果合并}
\\
&\text{将普通特征分支的 INT32 计算结果反量化为 FP16}
\\
&\quad Y_{\bar{\mathcal{O}}}^{\mathrm{FP16}}
=
\operatorname{Dequantize}
\left(
Y_{\bar{\mathcal{O}}}^{\mathrm{INT32}}
\right)
\\
&\text{将两条分支的计算结果相加，得到最终输出}
\\
&\quad Y^{\mathrm{FP16}}
=
Y_{\mathcal{O}}^{\mathrm{FP16}}
+
Y_{\bar{\mathcal{O}}}^{\mathrm{FP16}}
\\[3pt]
&\textbf{Return: } Y^{\mathrm{FP16}}
\end{aligned}
}
$$

:::tip

1. int8 * int8 用int32存储结果，避免溢出。
2. 划分完 $X$ ，权重矩阵需要同步划分（对应的行--列对应）
3. 对于 $X_{\bar{\mathcal{O}}}$ / $W_{\bar{\mathcal{O}}}$ 的量化粒度是 per-token/per-channel

:::

### GPTQ

GPTQ per-tensor 逐层量化，重点解决权重量化造成的模型输出误差，通过优化权重的量化结果来尽可能保持原模型的行为。目标是 **让量化后的层输出尽量接近原始层输出**

它利用 Hessian 近似估计**每个权重对输出的影响**，按列量化并在量化后 **补偿误差**。GPTQ 可以把权重压到 3–4 bit，推理时反量化计算。

$$
\min_{\hat{W}}
\left\|XW - X\hat{W}\right\|_2^2
$$

$$
\boxed{
\begin{aligned}
&\textbf{Input: }\text{权重矩阵 } W,\ \text{校准数据对应的输入激活 } X,\ \text{量化位宽 } b
\\
&\textbf{Output: }\text{量化后的权重矩阵 } \hat{W} \\
&\textbf{目标：最小化量化前后的层输出误差}\min_{\hat{W}}\left\|XW-X\hat{W}\right\|_F^2
\\
\hline
\\
&\textbf{Step 1: 计算 Hessian 矩阵}
\\
&\quad H=X^TX
\\
&\textbf{Step 2: 计算逆 Hessian}
\\
&\quad H^{-1}=(X^TX)^{-1}
\\
&\textbf{Step 3: 逐列量化权重并补偿误差}
\\
&\text{对权重矩阵 }W\text{ 的每一列，依次处理其中的权重元素}
\\
&\text{对于当前待量化权重 }w_i，执行量化并算误差
\\
&\quad\hat w_i=Q(w_i)
\\

&\quad e_i=w_i-\hat w_i
\\
&\text{利用逆 Hessian 调整尚未量化的权重，补偿输出误差：}
\\
&\quad w_{i+1:}
\leftarrow
w_{i+1:}
-
\frac{e_i}{[H^{-1}]_{ii}}H^{-1}_{i+1:,i} \\[6pt]
&\textbf{Step 4: 逐列完成量化}
\\
&\text{重复上述过程，直到所有权重列均完成量化}
\\
&\textbf{Return: }\hat{W}
\end{aligned}
}
$$

:::tip

- 这玩意的祖宗 OBQ 的思想是：当我们决定把某个权重量化到一个离散值时，可以调整其他尚未量化的权重，来补偿这次量化造成的误差。

- Block-wise 是工程优化。 GPTQ 实际实现中会分块处理权重，并利用逆 Hessian 的 Cholesky 分解结果高效地更新权重，而不是简单地对每个元素单独求逆矩阵。

- 这里的 $X\in\mathbb{R}^{T\times d_{model}}$ 因此 $H=X^TX$。如果把输入样本按列排列，写成 $X\in\mathbb R^{d_{\text{in}}\times N}$，就是 $H=XX^T$

:::

### SmoothQuant

激活值难量化、权重容易量化。SmoothQuant 引入平滑因子 $s$ 平滑激活值中的异常值，做等效变换:

$$
Y = (XW) = \left(X\operatorname{diag}(s)^{-1}\right)\left(\operatorname{diag}(s)W\right)\\[1mm]
s_j = \frac{\max_i |X_{ij}|^\alpha}{\max_i |W_{ij}|^\alpha} j\in\{1,2,\ldots,C\}\quad\text{(每个通道的最大激活值)}
$$

让激活值除以 $s$ 缩小离群点影响，权重乘以 $s$ 承担一部分难度，从而把“激活难量化、权重易量化”变成两者都较容易量化。

### SpQR：模型跨模型规模的近乎无损压缩

SpQR **识别并保护** 对量化误差 **特别敏感** 的少量权重（算敏感度并排序 top 1%），用稀疏矩阵高精度保存，其余权重压到 3–4 bit。

$W$ 中每个权重 $w_{ij}$ 的敏感度 $s_{ij}$：原始预测与所有该权重被量化后的权重矩阵 $\hat{W}$ 预测之间的**最小差值**

### AWQ

AWQ（Activation-aware Weight Quantization）认为只需保护少量关键权重就能显著减少误差。

它根据 **激活值和权重的大小** （不像SpQR那样基于误差来识别关键权重），寻找缩放因子，保护重要通道，而不是单独存储离群权重，因此实现更简单、推理更高效。

## 模型蒸馏

蒸馏把复杂的、庞大的教师模型的知识迁移到更小、更高效的学生模型。

让学生模型学习教师模型的泛化能力，而不是单纯地对训练数据进行拟合

学生不只学习 **真实标签**，还学习教师输出的 **软标签**（一定温度下softmax后的概率分布），其中包含类别之间的相似性信息。

### 蒸馏的损失函数构成

蒸馏损失、教师损失和学生损失共同构成

- 教师损失：评估教师模型在原始任务上的性能，通常不直接影响学生模型的训练
- 学生损失：评估学生模型在原始任务上的性能，是学生模型训练的一部分，通常用交叉熵
- 蒸馏损失：评估学生模型的输出和教师模型的输出之间的差距，用KL散度

对于学生和教师模型，用 $\mathbf{z}_T$、$\mathbf{z}_S$ 表示它们的 logits， $\mathbf{p}_T^{(\tau)}$, $\mathbf{p}_S^{(\tau)}$ 表示logits经过 softmax在温度 $\tau$ 下得到的概率分布（教师的 $\mathbf{p}_T^{(\tau)}$ 就是软标签），$\mathbf{y}$ 表示真实标签。这些符号都是向量。可以如下形式化表示

- 学生损失：$\mathcal{L}_S =- \operatorname{CE}(\mathbf{y}, \mathbf{p}_S^{(\tau)})=-\sum_{i} y_i \log p_{S,i}^{(\tau)}$，交叉熵衡量学生输出和真实标签的差距；用真实标签监督。
- 蒸馏损失（软目标损失）：$\mathcal{L}_D = D_{\text{KL}}(\mathbf{p}_T^{(\tau)}\|\mathbf{p}_S^{(\tau)})=\sum_{i} p_{T,i}^{(\tau)} \log \dfrac{p_{T,i}^{(\tau)}}{p_{S,i}^{(\tau)}}$，KL散度衡量学生输出和教师输出的差距；用教师输出监督。
- 温度 $\tau$ 控制 softmax 的平滑程度，
  $$
  \operatorname{softmax}(\mathbf{z}^{(\tau)})_i = \frac{\exp(z_i/\tau)}{\sum_j \exp(z_j/\tau)}
  $$
  - $\tau>1$ 会让概率分布更平滑，$\tau<1$ 会让概率分布更尖锐。
  - 蒸馏中通常使用 $\tau>1$，因为教师模型的输出分布可能过于尖锐，学生模型难以学习。

于是综合损失：

$$
\mathcal{L} = \alpha \mathcal{L}_S + (1-\alpha) \mathcal{L}_D
$$

:::tip

实际使用过程中会乘上温度 $\tau^2$ 来平衡梯度大小，避免 $\tau$ 过大导致梯度过小。

这里的KL散度的方向也需要注意，$\mathcal{L}_D = D_{\text{KL}}(\mathbf{p}_T^{(\tau)}\|\mathbf{p}_S^{(\tau)})$，是以教师为基准，学生去拟合教师的分布。属于**反向 KL 散度**，而还有一种 **正向KL散度**（比如说miniLLM） $\mathcal{L}_D = D_{\text{KL}}(\mathbf{p}_S^{(\tau)}\|\mathbf{p}_T^{(\tau)})$，让学生模型更关注自身生成的结果是否落在教师模型认可的高概率区域中，从而减少学生模型对教师模型低概率区域的过度估计。

:::

### 白盒与黑盒

- **白盒蒸馏**：可以访问教师内部结构和中间层，例如 MiniLLM 用反向 KL 散度让学生匹配教师的分布，避免学生在教师低概率区域分配过多概率；
- **黑盒蒸馏**：只能访问教师的输入和输出，例如 GKD 对学生生成的序列进行采样，用教师打分来构造训练信号。

### 涌现能力的蒸馏

大模型的上下文学习（ICL）、思维链（CoT）、指令遵循（IF）等能力通常在规模达到一定程度后才出现。蒸馏不只迁移最终答案，还可以迁移：

- 教师的推理过程（思维链）；
- 教师对示例的使用方式；
- 教师的指令遵循行为。

这比只拟合输出分布更难，因为学生需要学习“如何思考”，而不只是“答案是什么”。

## 取舍

| 方法 | 压缩对象 | 优点 | 局限 |
| --- | --- | --- | --- |
| 量化 | 权重/激活 | 显著降低显存和带宽，推理快 | 低位量化可能损失精度 |
| 蒸馏 | 模型规模 | 学生模型小、推理便宜 | 需要教师和训练数据，能力上限受教师限制 |

量化通常不需要重新训练，适合快速部署；蒸馏需要训练学生模型，但能得到结构更小、延迟更低的新模型。实际部署中两者可以叠加，例如先蒸馏得到小模型，再做 4-bit 量化。

## 相关阅读

- 推理框架与 KV Cache：[推理框架与部署](/posts/nlp/11-01-inference-frameworks/)
- QLoRA 中的 4-bit 量化：[LoRA 与 QLoRA](/posts/nlp/08-02-peft-lora/)
- 训练显存与混合精度：[大模型训练系统](/posts/nlp/07-02-llm-training-systems/)
- 模型能力评价：[大语言模型的评价](/posts/nlp/10-03-llm-evaluation/)
- 知识蒸馏中的概率分布：[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)
