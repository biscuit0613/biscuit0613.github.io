---
title: '神经网络语言模型：NNLM 与 RNNLM'
published: 2026-10-20
description: '用前馈网络和循环网络估计下一词概率：NNLM 的嵌入、隐藏层与输出层，RNNLM 的隐藏状态递推及其优缺点'
image: ''
tags: [NLP, Language-Model, NNLM, RNNLM, Embedding]
category: '09-自然语言处理'
order: 605
draft: false
lang: ''
---

## 从 n-gram 到神经网络

[统计语言模型](/posts/nlp/03-01-language-model/) 用链式法则分解序列概率，再用马尔可夫假设把每个条件概率近似为前 $n-1$ 个词：

$$
P(w_1,\dots,w_m) = \prod_{i=1}^{m} P(w_i \mid w_1,\dots,w_{i-1})
\approx \prod_{i=1}^{m} P(w_i \mid w_{i-n+1},\dots,w_{i-1})
$$

n-gram 可以看作一种直接的近似策略，但有两个根本问题：

- 条件概率表随阶数指数增长，高阶模型严重稀疏；
- 单词的离散表示忽略了单词之间的相似性

神经网络语言模型（Neural Network Language Model, NNLM）用**低维稠密词向量 + 神经网络**估计 $P(w_i \mid w_{i-n+1},\dots,w_{i-1})$。词向量在训练语言模型的过程中顺带学到，这也正是 [Word2Vec](/posts/nlp/06-02-word2vec/) 的直接来源。

语言模型的训练数据可以直接取自原始文本：给定前文，下一个词就是标签。因此它是典型的**自监督学习**任务，不需要人工标注。

## NNLM 的结构

NNLM 沿用 n-gram 的马尔可夫假设，只使用固定长度的历史窗口 $w_{i-n+1},\dots,w_{i-1}$，目标是输出下一个词在词表 $\mathcal{V}$ 上的概率分布。

### 输入层：embedding lookup 与拼接

每个历史词先查表得到 $d$ 维词向量：

$$
\mathbf{v}_k = \mathbf{E} \mathbf{x}_{w_k} \in \mathbb{R}^d
$$

其中：

- $\mathbf{x}_{w_k}$：one-hot 向量；
- $\mathbf{E} \in \mathbb{R}^{d \times V}$：嵌入矩阵。

把 $n-1$ 个词向量按顺序拼接：

$$
\mathbf{v} = [\mathbf{v}_{i-n+1}; \dots; \mathbf{v}_{i-1}] \in \mathbb{R}^{(n-1)d}
$$

### 隐藏层

$$
\mathbf{h} = f(\mathbf{W}_{\text{hid}} \mathbf{v} + \mathbf{b}_{\text{hid}})
$$

其中：

- $\mathbf{W}_{\text{hid}} \in \mathbb{R}^{m \times (n-1)d}$：隐藏层权重；
- $m$：隐藏层维度；
- $f$：激活函数，常取 tanh 或 ReLU。

### 输出层

$$
\mathbf{y} = \mathbf{W}_{\text{out}} \mathbf{h} + \mathbf{b}_{\text{out}},
\qquad
P(w_i = k \mid \text{history}) = \frac{\exp(y_k)}{\sum_{j=1}^{V} \exp(y_j)}
$$

$\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times m}$，输出维度等于词表大小。

### 参数量(相比于 n-gram 的重要优势)

NNLM 的总参数量为

$$
\underbrace{Vd}_{\text{嵌入矩阵} \mathbf{E}} + \underbrace{m(n-1)d}_{\text{隐藏层}\mathbf{W}_{\text{hid}}} + \underbrace{m}_{\text{隐藏层偏置}\mathbf{b}_{\text{hid}}} + \underbrace{Vm}_{\text{输出层}\mathbf{W}_{\text{out}}} + \underbrace{V}_{\text{输出层偏置}\mathbf{b}_{\text{out}}}
= V(d+m+1) + m\big((n-1)d+1\big)
$$

- 前馈神经网络的参数量随词表大小 $V$ 和历史长度 $n-1$ **线性增长**；
- 而 n-gram 的条件概率表规模约为 $V^{n-1}$，随阶数指数增长。
- 这是 NNLM 相对 n-gram 的重要优势。

### 训练目标

对整个语料最大化对数似然，等价于最小化交叉熵：

$$
\mathcal{L} = -\sum_{i=1}^{T} \log P(w_i \mid w_{i-n+1},\dots,w_{i-1})
$$

用随机梯度下降和反向传播更新嵌入矩阵、隐藏层和输出层。训练完成后，嵌入矩阵 $\mathbf{E}$ 的列就是词向量。

## NNLM 的局限

固定窗口仍然继承了 n-gram 的假设：预测只依赖前 $n-1$ 个词。

- 固定长度的历史词并不总能提供足够的信
息。

- 若关键信息在更远处，窗口必须开得很大，参数量和计算量随之上升。

例如：

> 与小明一起旅行游玩总是充满了惊喜，你永远不会知道他将带你到哪里去。

要判断“他”指代“小明”，模型需要跨越十几个词的历史。前馈网络只能通过加长窗口硬解，无法动态保留更早的信息。

## RNNLM：用隐藏状态携带历史

循环神经网络语言模型（RNNLM）不再截断历史，而是用一个隐藏状态 $\mathbf{h}_i$ 递推地汇总到当前位置为止的全部历史。

RNN 常用于处理序列数据

- 上一时刻的隐藏层状态会作为当前时刻的输入
- 每个时刻的隐藏层状态都能够保存并传递过去所有词的信息
- 通过隐藏层状态动态地捕捉整个序列的依赖关系
- 有效地解决了语言模型中的动态依赖问题

### 输入层：词向量与历史拼接

第 $i$ 步的输入由前一个词 $w_{i-1}$ 的词向量 $\mathbf{v}_{i-1}$ 和上一时刻的 **包含所有历史词信息的** 隐藏状态 $\mathbf{h}_{i-1}$ **拼接** 而成：

$$
\mathbf{x}_i = [\mathbf{v}_{i-1}; \mathbf{h}_{i-1}] \in \mathbb{R}^{d+m}
$$

- $d$：词向量维度；
- $m$：隐藏状态维度。
- 第一个词没有历史，通常令 $\mathbf{h}_0$ 为零向量或随机初始化向量。

### 隐藏层：权重拆解

$$
\begin{aligned}
\mathbf{h}_i &=\tanh(\mathbf{W}_\text{hid}\mathbf{x}_i+\mathbf{b}_{\text{hid}})\\
&= \tanh(\mathbf{U}\mathbf{v}_{i-1} + \mathbf{V}\mathbf{h}_{i-1} + \mathbf{b})
\end{aligned}
$$

其中：

- 把 $\mathbf{W}_{\text{hid}}$ 拆成 $[\mathbf{U}, \mathbf{V}]$ 后，递归结构更清楚：$\mathbf{U}$ 负责处理当前词向量，$\mathbf{V}$ 负责处理上一时刻的隐藏状态。

- $\mathbf{U} \in \mathbb{R}^{m \times d}$：词向量的权重；
- $\mathbf{V} \in \mathbb{R}^{m \times m}$：隐藏状态的递推权重。

### 输出层：隐藏状态预测下一个词

$$
\mathbf{y}_i = \mathbf{W}_{\text{out}} \mathbf{h}_i + \mathbf{b}_{\text{out}},
\qquad
P(w_i = k \mid w_{<i}) = \frac{\exp(y_{k})}{\sum_{j=1}^{V} \exp(y_j)}
$$

- $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times m}$：输出层权重。

RNNLM 的关键性质：

- 所有时间步共享同一组参数，序列长度增加不会增加参数量；
- 隐藏状态在理论上可以携带任意远的历史信息。

### 训练与评价

训练仍然是对数似然最大化，梯度需要通过时间反向传播（BPTT），见 [RNN 基础](/posts/rnn/rnn-basic/) 和 [BPTT](/posts/rnn/rnn-bptt/)。语言模型常用困惑度（Perplexity, PPL）评价：

$$
\text{PPL} = \exp\left(-\frac{1}{T}\sum_{i=1}^{T}\log P(w_i \mid w_{<i})\right)
$$

PPL 可以理解为模型在每个位置上的“平均候选词数”，越低越好。具体推导见 [困惑度](/posts/dl-basics/perplexity/)。

### 优点与问题

RNNLM 的优点：

- 不限制历史长度，能建模长距离依赖；
- 参数量与序列长度无关，词向量在所有位置共享；
- 仍然是自监督训练，可直接利用大规模无标注文本。

问题：

- **梯度消失/爆炸**：长序列上 BPTT 的梯度不稳定。常用梯度截断缓解，但会削弱长距离建模；更好的方案是 [LSTM/GRU](/posts/rnn/rnn-gru-lstm/) 的门控结构；
- **串行计算**：第 $i$ 步依赖第 $i-1$ 步的隐藏状态，无法像 Transformer 那样在训练时并行处理整个序列；
- **固定容量瓶颈**：所有历史被压缩进固定维度的 $\mathbf{h}_i$，信息量大时会有损失。

这些限制后来由注意力机制和 [Transformer](/posts/transformer/trasformer-attetion/) 解决：自注意力可以直接建模任意两个位置，并在训练时并行。

## 与 Word2Vec 的关系

Word2Vec 可以看作 NNLM 的简化：

- Skip-gram 去掉隐藏层和非线性，直接用中心词向量预测上下文；
- CBOW 把上下文词向量平均后预测中心词，结构与 NNLM 的输入输出方向相反；
- 负采样把 softmax 的全词表归一化换成二分类，使训练能扩展到大规模语料。

NNLM 保留了隐藏层，语言模型能力更强；Word2Vec 放弃语言建模，只保留“用上下文学习词向量”这一目标，因此训练更简单、更快。

## 相关阅读

- n-gram 与平滑：[统计语言模型](/posts/nlp/03-01-language-model/)
- 困惑度：[困惑度](/posts/dl-basics/perplexity/)
- RNN 基础与 BPTT：[RNN 基础](/posts/rnn/rnn-basic/)、[BPTT](/posts/rnn/rnn-bptt/)
- 门控循环网络：[LSTM 与 GRU](/posts/rnn/rnn-gru-lstm/)
- 用预测任务学习静态词向量：[Word2Vec](/posts/nlp/06-02-word2vec/)
- 上下文相关表示：[ELMo](/posts/nlp/06-06-elmo/)
