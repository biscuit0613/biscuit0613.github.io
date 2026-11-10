---
title: 'Word2Vec：Skip-gram、CBOW 与负采样'
published: 2026-10-20
description: '把词向量学习转化为上下文预测：Skip-gram 与 CBOW 的结构、softmax 的计算瓶颈、负采样与层次 Softmax'
image: ''
tags: [NLP, word2vec, Skip-gram, CBOW, Negative-Sampling]
category: '09-自然语言处理'
order: 602
draft: false
lang: ''
---

## 用预测任务学习词向量

[共现矩阵与 SVD](/posts/nlp/06-01-word-representation/) 直接对全局统计做分解。Word2Vec 换了一个思路：**用一个词预测它的上下文（或反过来），把预测任务训练好之后，词向量作为副产品被得到**。真正要优化的是预测，最终使用的是学到的嵌入矩阵。

分布式假设仍然成立：经常出现在相似上下文中的词，语义相近。但 Word2Vec 不再显式构造 $V \times V$ 的共现矩阵，而是从语料中逐窗口采样训练样本，因而更容易扩展到大规模语料。

设词表为 $\mathcal{V}$，大小为 $V$，词向量维度为 $d$。模型维护两套参数：

- 输入嵌入矩阵 $\mathbf{W}_{\text{in}} \in \mathbb{R}^{d \times V}$，第 $t$ 列是词 $w_t$ 作为**中心词**时的向量 $\mathbf{v}_{w_t}$；
- 输出嵌入矩阵 $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$，第 $j$ 行是词 $w_{j}$ 作为**上下文词**时的向量 $\mathbf{u}_{w_{j}}$。

总参数量为 $2Vd$。

Word2Vec 的网络没有偏置、没有激活函数、只有一个隐藏层，本质上是线性投影；非线性只出现在输出端的 softmax 或 sigmoid 中。

## Skip-gram：中心词预测上下文

给定长度为 $T$ 的词序列和窗口大小 $m$，Skip-gram

- 对每个位置 $t$，用中心词 $w_t$ **预测窗口内所有上下文词** $w_{t+j}, j \in \{-m,\dots,-1,1,\dots,m\}$）：
- 通过最大化上下文词在中心词条件下的对数似然，学习词向量：

$$
\begin{aligned}
\prod_{\substack{-m \le j \le m \\ j \ne 0}} P(w_{t+j} \mid w_t)  \quad &\text{建模对象(对于窗口内上下文，中心词)}\\
\prod_{t=1}^{T} \prod_{\substack{-m \le j \le m \\ j \ne 0}} P(w_{t+j} \mid w_t)  \quad &\text{建模对象(对于整个语料)}\\
\max_{\theta} \sum_{t=1}^{T} \sum_{\substack{-m \le j \le m \\ j \ne 0}}
\log P(w_{t+j} \mid w_t)  \quad &\text{目标函数（对数似然）}\\
\mathcal{L}(\theta) = -\sum_{t=1}^{T} \sum_{\substack{-m \le j \le m \\ j \ne 0}} \log P(w_{t+j} \mid w_t)  \quad &\text{损失函数（对于整个语料）}
\end{aligned}
$$

### Skip-gram 一对正样本的 softmax 及损失函数

对于一对正样本 $(w_t, w_{t+j})$ ，条件概率由中心词向量（输入 Embedding 矩阵查找） $\mathbf{v}_{w_t}$ 与候选上下文词向量(输出Embedding矩阵查找) $\mathbf{u}_{w_{t+j}}$ 的点积经 softmax 得到：

$$
P(w_{t+j} \mid w_t) =
\frac{\exp(\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t})}
{\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})}
$$

对正样本 $(w_t, w_{t+j})$，损失为

$$
\mathcal{L} = -\log P(w_{t+j} \mid w_t)
= -\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t}
+ \log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})
$$

关键结论是：**每次更新都要对全词表 $V$ 求和并更新所有 $\mathbf{u}_w$**，这就是 softmax 的瓶颈。

:::tip[计算开销分析]

语料长度：$T=10000$， 词汇表大小：$V=5000$，词向量维度：$d=100$，上下文窗口大小：$m=2$。每个中心词都能产生完整的 $2m$ 个上下文词，忽略句子边界影响

1. 一个中心词要预测 $2m=4$ 个上下文词
2. 一个预测需要计算 $V=5000$ 个候选词的点积和指数，加乘运算复杂度为 $O(Vd)=O(5000*100)$；
3. 整个语料的复杂度为 $O(T*2m*Vd)=O(10000*4*5000*100)$。

:::

### 梯度与参数更新

对 $\mathbf{v}_{w_t}$ 求梯度：

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{v}_{w_t}}
= -\mathbf{u}_{w_o} + \sum_{w \in \mathcal{V}} P(w \mid w_t)\,\mathbf{u}_w
$$

第一项把中心词向量拉向真实上下文词的向量；第二项按模型当前的预测分布把所有输出向量加权平均，相当于一个“推开”项，防止模型只靠高频词蒙混过关。对 $\mathbf{u}_w$ 的梯度为

$$
\frac{\partial \mathcal{L}}{\partial \mathbf{u}_w}
= \big(P(w \mid w_t) - \delta_{w,w_o}\big)\mathbf{v}_{w_t}
$$

真实上下文词被拉近，其余词被推远。推导本身不难

## CBOW：上下文预测中心词

CBOW（Continuous Bag of Words）是 Skip-gram 的镜像：

- 给定窗口内的上下文词 $w_{t+j}, j \in \{-m,\dots,-1,1,\dots,m\}$ ，预测中心词 $w_t$。
- 通过最大化中心词在上下文条件下的对数似然，学习词向量：

$$
\begin{aligned}
    P(w_t \mid w_{t-m},\dots,w_{t-1},w_{t+1},\dots,w_{t+m}) \qquad &\text{建模对象}\\
    \prod_{t=1}^{T} P(w_t \mid w_{t-m},\dots,w_{t-1},w_{t+1},\dots,w_{t+m}) \qquad &\text{建模对象(对于整个语料)}\\
    \max_{\theta} \sum_{t=1}^{T} \log P(w_t \mid w_{t-m},\dots,w_{t-1},w_{t+1},\dots,w_{t+m}) \qquad &\text{目标函数}\\

    \mathcal{L}(\theta) = -\sum_{t=1}^{T} \log P(w_t \mid w_{t-m},\dots,w_{t-1},w_{t+1},\dots,w_{t+m}) \qquad &\text{损失函数}
\end{aligned}

$$

### CBOW一对正样本的 softmax及损失函数

对于每个样本，先把上下文词向量取平均：

$$
\mathbf{h} = \frac{1}{|\mathcal{C}_t|} \sum_{w \in \mathcal{C}_t} \mathbf{v}_w,
\qquad \mathcal{C}_t = \{w_{t-m},\dots,w_{t-1},w_{t+1},\dots,w_{t+m}\}
$$

再计算候选中心词 $w_t$ 的 softmax 概率：

$$
P(w_t \mid \mathcal{C}_t) =
\frac{\exp(\mathbf{u}_{w_t}^T \mathbf{h})}
{\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{h})}
$$

带入整体的损失函数 $\mathcal{L}(\theta)$，这里的计算量就小很多，

$$
\mathcal{L}(\theta) = -\sum_{t=1}^{T} \log P(w_t \mid \mathcal{C}_t)
= -\sum_{t=1}^{T} \big[\mathbf{u}_{w_t}^T \mathbf{h}
+ \log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{h})
\big]
$$

CBOW 把多个上下文词平均成一个向量，一次只预测一个中心词，训练速度比 Skip-gram 快；代价是上下文信息被平均稀释，稀有词作为中心词被训练的机会也更少。

## Skip-gram 与 CBOW 的对比

比较维度| CBOW| Skip-gram|
---|---|---|
输入| 多个上下文词| 一个中心词|
预测目标| 一个中心词| 多个上下文词
建模对象| $P(w_t\mid C_t)$| $\prod_{\substack{-m \le j \le m \\ j \ne 0}} P(w_{t+j}\mid w_t)$
优化目标| 最大化中心词在上下文条件下的对数似然| 最大化上下文词在中心词条件下的对数似然
标准损失| $-\sum_t\log P(w_t\mid C_t)$| $-\sum_t\sum_{\substack{-m \le j \le m \\ j \ne 0}}\log P(w_{t+j}\mid w_t)$
上下文处理| 聚合上下文词向量| 分别预测各上下文词
经典结构的顺序信息 |不显式保留 | 不显式建模窗口内词序

CBOW 的参数结构同样是 $\mathbf{W}_{\text{in}}$ 和 $\mathbf{W}_{\text{out}}$，但一次更新中，输入矩阵只更新窗口内的 $2m$ 个词，输出矩阵只更新中心词对应的行；Skip-gram 则相反，输入只更新一个词，输出要对窗口内每个上下文词分别求梯度。这解释了训练速度与稀有词效果的差异。

## 负采样

softmax 的分母需要对 $V$ 个词求和。负采样（Negative Sampling）把“从全词表中选出正确上下文词”的 $V$ 分类问题，改成“判断某个词对是否真实共现”的二分类问题。

对每个正样本 $(w_t, w_o)$，从噪声分布 $P(w)$ 中采样 $k$ 个未出现在该窗口中的词作为负例。

用 $D=1$ 表示中心词 $w_t$ 与候选上下文词 $w_o$ 被判定为真实词对，$D=0$ 表示噪声词对

对于一个正样本 $(w_t, w_o)$ 和 $k$ 个负样本 $(w_t, w_{t,o,i}^-), i=1,\dots,k$

$$
P(D=1 \mid w_t, w_o) = \sigma(\mathbf{u}_{w_o}^T \mathbf{v}_{w_t})
\qquad (w_t, w_o)\text{被判定成正样本的概率}\\[5pt]
P(D=0 \mid w_t, w_{t,o,i}^-) = \sigma(-\mathbf{u}_{w_{t,o,i}^-}^T \mathbf{v}_{w_t})\qquad (w_t, w_{t,o,i}^-)\text{被判定成负样本的概率}\\[5pt]
\prod_{i=1}^{k} P(D=0 \mid w_t, w_{t,o,i}^-) = \prod_{i=1}^{k} \sigma(-\mathbf{u}_{w_{t,o,i}^-}^T \mathbf{v}_{w_t})\qquad k\text{个负样本都被判定成负样本的概率}
$$

- $\sigma(x) = 1/(1+e^{-x}),\sigma(-x) = 1/(1+e^{x})=1-\sigma(x)$。

对于Skip-gram，建模对象变为最大化正确区分正样本与负样本的分类似然，对单个正样本 $(w_t, w_{t+j})$ 和它对应的 $k$ 个负样本 $(w_t, w_{t,j,i}^-), i=1,\dots,k$ 而言就是乘一块：

$$
P(D=1 \mid w_t, w_{t+j})\prod_{i=1}^{k} P(D=0 \mid w_t, w_{t,j,i}^-)\\
=\sigma(\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t})\prod_{i=1}^{k} (1-\sigma(\mathbf{u}_{w_{t,j,i}^-}^T \mathbf{v}_{w_t}))
$$

单个正样本的损失函数为他的对数似然：

$$
\mathcal{L} = -\log \sigma(\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t})
- \sum_{i=1}^{k} \log \sigma(-\mathbf{u}_{w_{t,j,i}^-}^T \mathbf{v}_{w_t})
$$

对于整个语料，负采样方法的损失函数在外面套了两个求和：

$$
\mathcal{L}_N(\theta) = -\sum_{t=1}^{T} \sum_{\substack{-m \le j \le m \\ j \ne 0}}
\Big[\log \sigma(\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t})
+ \sum_{i=1}^{k} \log \sigma(-\mathbf{u}_{w_i}^T \mathbf{v}_{w_t})
\Big]
$$

对比一下不用负采样的损失函数：

$$
\mathcal{L}(\theta) = -\sum_{t=1}^{T} \sum_{\substack{-m \le j \le m \\ j \ne 0}}
\Big[\mathbf{u}_{w_{t+j}}^T \mathbf{v}_{w_t} - \log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})\Big]
$$

每次更新只需计算 $k+1$ 个 sigmoid，复杂度从 $O(V)$ 降到 $O(k)$。

负例按

$$
P(w) \propto \operatorname{count}(w)^{3/4}
$$

采样。$3/4$ 次幂压低了高频词的采样概率、提升了低频词的采样概率，避免负例几乎全是“the”“a”这类词。实践中 $k$ 通常取 5–20（小语料）或 2–5（大语料）。

负采样可以看作对 softmax 的近似：它不直接归一化全词表，而是用少量负例估计“这个上下文词相对于随机词是否足够突出”。训练完成后，$\mathbf{W}_{\text{in}}$ 的列、或 $\mathbf{W}_{\text{in}}$ 与 $\mathbf{W}_{\text{out}}^T$ 的平均，都可以作为最终词向量。

## 层次 Softmax

层次 Softmax（Hierarchical Softmax）是另一种降低复杂度的方法：用一棵 Huffman 树把词表组织成二叉树，每个词对应一条从根到叶的路径。预测词 $w_o$ 的概率是从根出发、沿路径做若干次二分类的概率乘积：

$$
P(w_o \mid w_t) =
\prod_{l=1}^{L(w_o)-1}
\sigma\!\left(s_l \cdot \mathbf{u}_{n(w_o,l)}^T \mathbf{v}_{w_t}\right)
$$

其中：

- $L(w_o)$：路径长度；
- $n(w_o,l)$：路径上的节点；
- $s_l \in \{+1,-1\}$：该步走向左子树还是右子树。

Huffman 树让高频词路径短、低频词路径长，平均只需 $O(\log V)$ 次二分类。

层次 Softmax 在早期实现中很常见，但树结构依赖词频，且难以并行；现代实现更常用负采样。

## 训练细节

- **动态窗口**：每个样本的窗口大小在 $[1,m]$ 内随机取，近距离词对更容易被采到，相当于一种数据增强；
- **高频词下采样**：以与词频相关的概率丢弃高频词（如“的”“the”），减少无信息样本；
- **学习率衰减**：训练后期降低学习率，让向量稳定下来；
- **语料与窗口**：窗口越大，学到的语义越偏向主题相关；窗口越小，越偏向句法和搭配。

## 性质与局限

Word2Vec 得到的是**静态词向量**：每个词只有一个向量，与上下文无关。因此：

- 多义词无法区分，“bank”在“河岸”和“银行”语境下是同一个向量；
- 词表之外的词（OOV）没有向量，需要借助子词方法处理；
- 向量只编码了窗口内的共现信息，无法直接表示长距离句法结构。

这些局限分别由 [子词分词](/posts/nlp/06-04-subword-tokenization/)、[ELMo](/posts/nlp/06-06-elmo/) 和 [BERT](/posts/nlp/06-07-bert/) 等上下文相关表示逐步解决。Word2Vec 的结构也可以看作对早期 [神经网络语言模型](/posts/nlp/06-05-nnlm-rnnlm/) 的简化：去掉隐藏层和非线性，只保留嵌入查表和输出预测。

## 相关阅读

- 全局统计与 SVD：[词向量基础](/posts/nlp/06-01-word-representation/)
- 全局共现的加权最小二乘建模：[GloVe](/posts/nlp/06-03-glove/)
- 子词与 OOV：[子词分词](/posts/nlp/06-04-subword-tokenization/)
- 神经网络语言模型：[NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)
- 词向量的内在评价：[词向量的评价](/posts/nlp/05-02-embedding-evaluation/)
- 上下文相关表示：[ELMo](/posts/nlp/06-06-elmo/)、[BERT](/posts/nlp/06-07-bert/)
