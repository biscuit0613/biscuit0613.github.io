---
title: '自回归语言模型：从联合概率到下一个 Token 预测'
published: 2026-07-18
description: '从概率链式法则出发，建立现代生成式语言模型、因果语言建模与 Next-Token Prediction 的统一理论框架'
image: ''
tags: [NLP, LLM, Pre-training]
category: '09-自然语言处理'
order: 6
draft: true
lang: ''
---

:::tip[本文定位]

**语言模型到底在学习什么，训练数据、序列概率与 loss 是如何连接起来的？**

本文只用最小的代码和例子辅助理解，不展开 MiniMind 的具体实现。模型结构、数据工程和训练脚本将在后续文章中分别讨论。

:::

## 1. 理论范围与知识衔接

本文聚焦以下学习目标：

- 文本序列的概率表示与条件概率模型
- 从概率链式法则到 Next-Token Prediction
- Logits、Softmax、最大似然与交叉熵的联系
- 序列错位、Teacher Forcing 与训练并行
- 自回归生成与训练—推理差异
- Pre-training、SFT 和 DPO 的统一概率基础

相关前置知识可参考：

- [BPE 与子词表示](/posts/nlp/02-glove-bpe/)
- [BERT 的 MLM 预训练](/posts/nlp/03-bert-pretrain/)
- [从 word2vec 到 LLM](/posts/nlp/05-nlp-to-llm/)

## 2. 语言模型与文本概率

首先将文本表示为随机变量序列。设一段文本经过 Tokenizer 后得到：

$$
x_{1:T}=(x_1,x_2,\ldots,x_T)
$$

Token 是离散随机变量，整段文本可以看作一个随机变量序列。

在给出语言模型的正式定义前，需要先区分文本概率与事实真实性。假设模型已经读到前文：

```text
今天下雨了，所以我出门时带了
```

模型会在整个词表上给出下一个 Token 的概率。为了便于说明，假设其中几个候选词的概率是：

```text
雨伞：0.70
书：  0.08
冰箱：0.01
```

模型更倾向于生成“雨伞”，因为“下雨”和“带雨伞”在训练文本中经常一起出现。这里的概率表示的是：

> 在当前上下文和模型参数下，某个 Token 作为后续文本出现的可能性。

它并不直接表示这个句子在现实世界中是否为真。比如下面两句话都可能具有较高的语言概率：

```text
北京是中国的首都。
北京是法国的首都。
```

第二句话语法通顺、形式上也很像训练语料中的事实陈述，因此模型可能给它较高的概率，但它的事实内容是错误的。反过来，一个罕见但真实的科学事实，由于在训练数据中出现次数较少，也可能得到较低的概率。

因此需要区分两个问题：

| 问题                                       | 关注的对象             |
| ------------------------------------------ | ---------------------- |
| 这段文本像不像人类通常会写出的后续内容？   | 模型概率 $P_\theta(x)$ |
| 这段文本是否符合现实、任务要求或外部证据？ | 事实真实性与语义正确性 |

语言模型预训练首先优化的是前一个问题，而不是后一个问题。这也是语言模型可能生成“听起来合理但实际错误”的内容，也就是幻觉的理论背景之一。

在这个基础上，语言模型可以理解为一个**条件概率模型**：给定前文 $x_{<t}$ 时，估计下一个 Token $x_t$ 出现的概率：

$$
P(x_t\mid x_{<t})
$$

## 3. 概率链式法则与自回归分解

对任意序列，概率链式法则给出：

$$
P(x_1,\ldots,x_T)
=
\prod_{t=1}^{T}P(x_t\mid x_1,\ldots,x_{t-1})
=
P(x_1)\cdot P(x_2\mid x_1)\cdot P(x_3\mid x_1,x_2)\cdots P(x_T\mid x_{<T})
$$

这里使用的是概率链式法则，而不是额外假设 Token 之间相互独立。

链式法则自然导出 **自回归** 建模：“自回归”表示当前变量的分布依赖于已经生成的历史变量。

生成过程：

```text
x₁ → x₁ x₂ → x₁ x₂ x₃ → …
```

自回归分解要求: 预测 $x_t$ 时只能依赖历史 $x_{<t}$。在 Decoder-only Transformer 中，这个概率约束由 Causal Mask 落实为信息访问约束：当前位置可以关注自己和过去的位置，但不能关注未来位置。

```text
位置 1：只能看位置 1
位置 2：只能看位置 1、2
位置 3：只能看位置 1、2、3
```

如果预测 $x_t$ 时能够看到 $x_t$ 或更晚的 Token，模型就可能直接读取答案，训练目标也就失去了意义。

## 4. Next-Token Prediction 与词表分布

Decoder-only 语言模型在每个位置预测下一个 Token：

$$
\hat{x}_t\sim P_\theta(\cdot\mid x_{<t})
$$

需要说明的是，模型并不是直接输出“文字理解结果”，而是在词表 (记作符号 $\mathcal{V}$) 上输出一个概率分布。

为了得到词表上的条件概率分布，模型首先输出词表大小为 $V=|\mathcal{V}|$ 的 logits：

$$
\mathbf{z}_t\in\mathbb{R}^{V}
$$

对于词表中的每个词元 $v\in\mathcal{V}$，通过 Softmax 得到它作为 $x_t$ 的概率：

$$
P_\theta(x_t=v\mid x_{<t})
=
\frac{\exp(z_{t,v})}
{\sum_{u=1}^{V}\exp(z_{t,u})}
$$

下面用一个四词元词表展示从 logits 到 loss 的完整计算。假设当前上下文是：

```text
今天下雨了，所以我出门时带了
```

词表中暂时只考虑四个候选 Token：

```text
vocab = [雨伞, 书, 冰箱, 电影]
```

模型输出的 logits 假设为：

```text
logits = [2.0, 1.0, 0.0, -1.0]
```

logits 还不是概率。经过 softmax 后：

$$
\begin{aligned}
e^2+e^1+e^0+e^{-1}&\approx 11.475\\
P(\text{雨伞})&=\frac{e^2}{11.475}\approx 0.644\\
P(\text{书})&=\frac{e^1}{11.475}\approx 0.237\\
P(\text{冰箱})&=\frac{e^0}{11.475}\approx 0.087\\
P(\text{电影})&=\frac{e^{-1}}{11.475}\approx 0.032
\end{aligned}
$$

如果数据中的真实下一个 Token 是“雨伞”，one-hot 标签为：

```text
target = [1, 0, 0, 0]
```

那么交叉熵只取真实类别对应的负对数概率：

$$
\mathcal{L}
=-\log P(\text{雨伞})
=-\log(0.644)
\approx 0.440
$$

如果真实答案其实是“冰箱”，那么 loss 会变成：

$$
\mathcal{L}=-\log(0.087)\approx 2.442
$$

因此，模型并不是因为“预测错了”就得到一个固定的惩罚，而是：

- 给真实 Token 的概率越高，loss 越小；
- 给真实 Token 的概率越低，loss 越大；
- 其他候选 Token 的概率会通过 softmax 共同影响这个分布。

## 5. 最大似然、NLL 与交叉熵（数学补充）

训练数据中包含许多文本样本，最大似然估计要求真实文本在模型下的概率尽可能大：

$$
\max_\theta\sum_{x\in\mathcal{D}}\log P_\theta(x)
$$

为了把最大化问题转成常见的最小化问题，工程上通常使用负对数似然：

$$
\mathcal{L}_{\mathrm{NLL}}
=
-\sum_{t=1}^{T}\log P_\theta(x_t\mid x_{<t})
$$

在 one-hot 标签下，负对数似然可以直接写成交叉熵。这里对应[交叉熵与 KL 散度笔记](/posts/math/KLDivergenceAndCrossEntropy/)中的符号：

- $P$：真实标签分布；
- $Q$：模型预测分布；
- $H(P,Q)$：用模型分布 $Q$ 对真实分布 $P$ 的样本进行编码时的平均代价。

对于第 $t$ 个位置，真实的下一个 Token 是 $x_t$。把它写成一个词表上的 one-hot 分布：

$$
P_t(v)=\begin{cases}
1,&v=x_t\\
0,&v\neq x_t
\end{cases}
$$

模型通过 softmax 得到预测分布：

$$
Q_t(v)=P_\theta(x_t=v\mid x_{<t})
$$

代入交叉熵定义：

$$
\begin{aligned}
H(P_t,Q_t)
&=-\sum_{v\in\mathcal{V}}P_t(v)\log Q_t(v)\\
&=-\log Q_t(x_t)\\
&=-\log P_\theta(x_t\mid x_{<t})
\end{aligned}
$$

最后一项正是第 $t$ 个位置的负对数似然（NLL）。对整段序列求和：

$$
\mathcal{L}_{\mathrm{NLL}}(x)
=
\sum_{t=1}^{T}H(P_t,Q_t)
=
-\sum_{t=1}^{T}\log P_\theta(x_t\mid x_{<t})
$$

因此，在 Next-Token Prediction 中：

> 对于 Next-Token Prediction，交叉熵就是每个 Token 的负对数似然；整段 Token 的交叉熵之和就是序列 NLL。

从笔记中的 KL 散度来看：

$$
H(P_t,Q_t)=H(P_t)+D_{\mathrm{KL}}(P_t\|Q_t)
$$

one-hot 分布的熵 $H(P_t)=0$，所以这里有：

$$
H(P_t,Q_t)=D_{\mathrm{KL}}(P_t\|Q_t)
$$

如果使用 label smoothing，$P_t$ 不再是严格的 one-hot 分布，但它仍然是固定的目标分布。此时 $H(P_t)$ 与模型参数无关，因此最小化交叉熵和最小化 KL 散度仍然得到相同的最优方向。

将上述理论落到 PyTorch 实现时，语言模型目标可以按三层理解：

```text
最大化真实序列的 log-likelihood
        ↓ 取负号
最小化 NLL
        ↓ one-hot 分类形式
最小化 Token-level Cross Entropy
```

代码中通常不显式构造 one-hot 向量，而是直接用真实 Token 的整数 ID 作为标签：

```python
loss = F.cross_entropy(
    logits.reshape(-1, vocab_size),
    labels.reshape(-1),
)
```

其中 `F.cross_entropy` 在实现上等价于：

```python
log_probs = F.log_softmax(logits, dim=-1)
loss = F.nll_loss(log_probs, labels)
```

也就是说，PyTorch 的 `cross_entropy` 只是高效地完成了 `log_softmax + NLLLoss`，并没有引入一个新的语言模型训练目标。

## 6. 序列错位、Teacher Forcing 与并行训练

实际构造训练样本时，需要把同一段 Token 序列错开一个位置：

```text
原始序列： [我, 喜欢, 学习, 人工, 智能]

input_ids： [我, 喜欢, 学习, 人工]
labels：    [喜欢, 学习, 人工, 智能]
```

第 $t$ 个输入位置的输出，用来预测第 $t+1$ 个 Token。

这种始终使用真实历史作为上下文的训练方式称为 Teacher Forcing：训练模型预测第 $t$ 个 Token 时，输入的是训练数据中的真实历史 $x_{<t}$，而不是模型此前生成的 Token。

仍以这段真实序列为例：

```text
真实序列：[我, 喜欢, 学习, 人工, 智能]
```

训练时，模型在逻辑上完成的是“给定 `我` 预测 `喜欢`，给定 `我 喜欢` 预测 `学习`，给定 `我 喜欢 学习` 预测 `人工`”等任务。假设模型在第一个位置错误地认为“讨厌”的概率最高，下一个位置仍然使用真实的“我 喜欢”作为上下文，而不会改成“我 讨厌”。模型此前的采样结果不会被送回训练序列。

训练数据已经给出了整段真实序列，所以所有位置需要的真实历史都是已知的。Transformer 可以一次性输入：

```text
[我, 喜欢, 学习, 人工]
```

并在一次前向传播中输出四个位置的 logits：

```text
预测：[喜欢, 学习, 人工, 智能]
```

Causal Mask 保证第 $t$ 个位置只能利用 $x_{\leq t}$，因此模型虽然在一次前向传播中计算了所有位置，仍然没有看到任何未来答案。换句话说，Teacher Forcing 提供真实的历史，Causal Mask 划定每个位置能够访问的范围，二者共同使自回归训练既满足因果约束，又能利用 Transformer 的并行计算。

这也对应最大似然目标：因为真实的 $x_{<t}$ 已知，可以直接计算序列中每一项

$$
\log P_\theta(x_t\mid x_{<t})
$$

并将它们相加或取平均。Teacher Forcing 并不是把当前答案 $x_t$ 提前泄漏给模型；预测 $x_t$ 时，模型只能看到真实历史 $x_{<t}$，当前 Token 和未来 Token 仍然会被遮挡。

对应的最小实现如下：

```python
input_ids = tokens[:, :-1]
labels = tokens[:, 1:]

logits = model(input_ids)

loss = cross_entropy(
    logits.reshape(-1, vocab_size),
    labels.reshape(-1),
)
```

## 7. 自回归生成与训练—推理差异

Teacher Forcing 使训练时的所有真实历史都已知，模型可以通过一次前向传播并行计算多个位置。推理时却没有真实的后续文本可用，模型只能采样或选择一个 Token，将它追加到上下文中，再预测下一个 Token：

```text
输入 → 生成 x₁ → 生成 x₂ → 生成 x₃ → …
```

两种阶段使用的概率模型相同，区别在于上下文的来源：

| 阶段 | 第 $t$ 步看到的历史         | 是否可按序列位置并行 | 前面错误的影响   |
| ---- | --------------------------- | -------------------- | ---------------- |
| 训练 | 真实历史 $x_{<t}$           | 可以                 | 不会进入后续输入 |
| 推理 | 模型生成历史 $\hat{x}_{<t}$ | 通常不可以           | 可能向后累积     |

例如模型早期生成了不合适的 Token：

```text
我 → 我 讨厌 → 我 讨厌 学习 → …
```

后续预测就会建立在这个上下文上，生成轨迹可能逐渐偏离。训练时主要接触真实历史、推理时必须处理自身生成历史，这种上下文分布不一致通常称为 **Exposure Bias（暴露偏差）**。它并不意味着 Teacher Forcing 的目标有误，而是描述最大似然训练与自由生成之间客观存在的差异。

Seq2Seq 研究中曾提出 Scheduled Sampling 等方法，在训练时混入模型生成的 Token；现代 Decoder-only LLM 的预训练通常仍采用标准 Teacher Forcing，因为它目标清晰、训练稳定，并且能充分利用 Transformer 的并行计算。推理阶段则通过 Greedy Decoding、Temperature、Top-k 或 Top-p 等解码策略，从模型给出的词表概率分布中决定实际生成的 Token；具体的解码算法不属于本文重点。

## 8. MLM、CLM 与 Seq2Seq 预训练范式

| 范式       | 预测目标       | 注意力范围                 | 典型模型             |
| ---------- | -------------- | -------------------------- | -------------------- |
| MLM        | 被遮盖的 Token | 通常双向                   | BERT                 |
| CLM        | 下一个 Token   | 因果                       | GPT、LLaMA、MiniMind |
| Seq2Seq LM | 目标序列 Token | Encoder 双向、Decoder 因果 | T5、原始 Transformer |

需要强调：BERT 的 MLM 和 GPT 的 CLM 都叫“预训练”，但学习目标、注意力约束和输出用途不同。

## 9. Pre-training、SFT 与 DPO 的统一概率视角

三个训练阶段的数据和损失形式不同，但都依赖模型对 Token 序列给出的条件概率或序列 log-probability：

| 阶段         | 数据形式                   | 概率目标                                                  |
| ------------ | -------------------------- | --------------------------------------------------------- |
| Pre-training | 普通文本                   | 最大化所有有效 Token 的 $\log P_\theta(x_t\mid x_{<t})$   |
| SFT          | 指令与回答                 | 最大化回答部分的 Token 概率，通常对 prompt 使用 loss mask |
| DPO          | prompt、chosen 与 rejected | 比较两种回答相对于参考模型的序列 log-probability          |

因此，后续阶段不是抛弃自回归语言模型目标另起炉灶，而是在同一个 $P_\theta(y\mid x)$ 基础上改变训练数据、损失掩码或概率比较方式。

<!-- TODO：下一篇 DPO 理论文章再完整推导参考模型、KL 正则与 DPO 损失。 -->

## 10. 核心结论与概念边界

- 语言模型是在估计条件概率。
- 交叉熵下降不等于模型事实一定正确。
- 训练时一次性计算多个位置，不代表生成时可以完全并行。
- 自回归不等于“只能处理一个 Token”，而是每个位置不能访问未来信息。
- 更低的训练 loss 不自动等于更好的对话能力。

全文的知识主线可以归纳为：

```text
文本序列
  ↓
概率链式法则
  ↓
自回归分解
  ↓
Next-Token Prediction
  ↓
负对数似然 / 交叉熵
  ↓
训练与生成
```

下一篇理论文章将讨论：

> **Decoder-only Transformer：Causal Mask、RoPE、RMSNorm 与现代 LLM Block**
