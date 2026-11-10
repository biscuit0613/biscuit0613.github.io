---
title: '词向量基础：从 one-hot 到共现矩阵与 SVD'
published: 2026-10-20
description: 'one-hot 表示的局限、分布式假设、共现矩阵、PMI/PPMI 加权与奇异值分解降维'
image: ''
tags: [NLP, Embedding, SVD, Co-occurrence]
category: '09-自然语言处理'
order: 601
draft: false
lang: ''
---

## one-hot 表示的局限

计算机无法直接理解“apple”或“苹果”这样的符号，必须把词转换成数值表示。最直接的表示是 **one-hot 向量**：词汇表大小为 $V$，每个词对应一个长度为 $V$ 的向量，只有该词的位置为 1，其余为 0。

例如词表为 $\{\text{apple}, \text{banana}, \text{cat}, \text{dog}, \text{eat}\}$：

$$
\mathbf{x}_{\text{apple}} = [1, 0, 0, 0, 0]^T,\quad
\mathbf{x}_{\text{banana}} = [0, 1, 0, 0, 0]^T
$$

one-hot 表示有两个致命缺陷：

1. **维度灾难**：真实词表可达 $10^5$ 到 $10^6$，向量极其稀疏且高维；
2. **语义鸿沟**：任意两个不同词的 one-hot 向量内积都是 0，无法表达“apple”和“banana”都是水果这类相似性。

## 分布式假设/表示

分布式假设（Distributional Hypothesis）认为：**出现在相似上下文中的词，往往具有相似的语义**。

分布式表示（word distributed representation）是指将单词映射到一个连续向量
空间中的过程，这些向量通常是高维的，并且能够捕捉单词之间的语义相似性。

- 使具有相似语义的单词在向量空间中距离较近

形式上可抽象成建立词嵌入矩阵 $\mathbf{E} \in \mathbb{R}^{|V| \times d}$，其中 $d \ll |V|$，每一行 $\mathbf{e}_i$ 是词 $i$ 的低维向量表示。

## 基于共现矩阵奇异值分解的词向量模型

构建一个 $V \times V$ 的共现矩阵 $\mathbf{C}$，其中：

- $C_{ij}$：词 $j$ 出现在词 $i$ 上下文窗口中的次数；
- $\mathbf{C}_{i}$：词 $i$ 的上下文分布，即共现矩阵的行向量。

上下文窗口可以是对称的，也可以只取左侧或右侧。距离较近的词通常更重要，因此可以对共现次数按距离加权，例如使用距离的倒数：

$$
C_{ij} = \sum_{d(w_i, w_j)} \frac{1}{d(w_i, w_j)}
$$

共现矩阵的维度仍然是 $V$，而且非常稀疏。直接把它当作词向量，会面临高维、稀疏和噪声问题。

### 点互信息与 PPMI

共现次数受词频影响很大：高频词和任何词都容易共现。为了衡量“共现是否超出偶然”，可以使用 **点互信息**（Pointwise Mutual Information, PMI）：

$$
\operatorname{PMI}(w_i, w_j) = \log\frac{P(w_i, w_j)}{P(w_i)P(w_j)}
= \log\frac{C_{ij} \cdot |\mathcal{C}|}{C_i \cdot C_j}
$$

其中：

- $C_i = \sum_j C_{ij}$：词 $i$ 在共现矩阵中的行和；
- $|\mathcal{C}|$：语料中的总词数。

PMI 为正表示共现比随机预期更频繁，为负表示更少。

PMI 对低频词不稳定，且可能取负值。常用 **正点互信息**（Positive PMI, PPMI）：

$$
\operatorname{PPMI}(w_i, w_j) = \max\left(\operatorname{PMI}(w_i, w_j), 0\right)
$$

PPMI 矩阵通常比原始共现矩阵更能反映语义关系。

### SVD 降维

共现矩阵或 PPMI 矩阵仍然是 $V \times V$ 的高维矩阵。奇异值分解（SVD）可以把它分解为：

$$
\mathbf{C} = \mathbf{U}\mathbf{\Sigma}\mathbf{V}^T
$$

- $\mathbf{U} \in \mathbb{R}^{V \times V}$：左奇异向量矩阵；
- $\mathbf{\Sigma} \in \mathbb{R}^{V \times V}$：对角矩阵，对角线元素为奇异值，按从大到小排列；
- $\mathbf{V} \in \mathbb{R}^{V \times V}$：右奇异向量矩阵。

保留前 $k$ 个奇异值及对应的奇异向量，得到低秩近似：

$$
\mathbf{C} \approx \mathbf{U}_k \mathbf{\Sigma}_k \mathbf{V}_k^T
$$

其中 $k \ll V$。词 $i$ 的低维表示可以取：

- $\mathbf{U}_k$ 的第 $i$ 行；
- $\mathbf{U}_k \mathbf{\Sigma}_k^{1/2}$ 的第 $i$ 行，后者会把奇异值的大小纳入表示。

此时词嵌入矩阵为 $\mathbf{E} = \mathbf{U}_k \mathbf{\Sigma}_k^{1/2}$，每个词的向量维度为 $k$。

SVD 的数学细节见 [奇异值与 SVD](/posts/math/singularandsvd/)。

### 为什么 SVD 能得到语义表示

SVD 找到的是矩阵中方差最大的 $k$ 个正交方向。在共现矩阵中，这些方向往往对应潜在的语义维度，例如“动物性”“可食用性”“大小”等。把词投影到这些方向上，就得到了稠密、低维的语义向量。

### 优缺点

| 方面 | 说明 |
| --- | --- |
| 优点 | 利用全局统计信息；数学上可解释；训练稳定 |
| 缺点 | 共现矩阵构建和 SVD 的计算成本高；新词加入需要重新分解；难以处理多义词 |
| 与词向量的关系 | Word2Vec、GloVe 可以看作对共现统计的不同建模方式 |

## 从全局统计到预测模型

基于 SVD 的方法直接对全局共现矩阵做分解；Word2Vec 则用局部上下文预测任务训练词向量，训练效率更高，且能通过负采样扩展到大规模语料。GloVe 又把全局共现统计和加权最小二乘结合起来。三者共同奠定了静态词向量的基础。

## 相关阅读

- 用预测任务训练词向量：[Word2Vec](/posts/nlp/06-02-word2vec/)
- 全局共现与加权最小二乘：[GloVe](/posts/nlp/06-03-glove/)
- 子词表示与 OOV：[子词分词](/posts/nlp/06-04-subword-tokenization/)
- SVD 的数学推导：[奇异值与 SVD](/posts/math/singularandsvd/)
