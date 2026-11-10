---
title: '统计语言模型：n-gram 与数据平滑'
published: 2026-07-18
description: '语言模型的定义、马尔可夫假设、n-gram 极大似然估计，以及加一、插值、回退、Good-Turing 与 Kneser-Ney 平滑'
image: ''
tags: [NLP, n-gram, language-model, Smoothing]
category: '09-自然语言处理'
order: 301
draft: false
lang: ''
---

## 语言模型

定义： 语言模型用于建模语言符号序列的概率分布，衡量一个词序列出现的可能性。

给定词序列 $(w_1,w_2,\ldots,w_N)$，其联合概率为：

$$
P(w_1,w_2,\ldots,w_N)
$$

根据概率链式法则：

$$
\boxed{
P(w_1,\ldots,w_N)
=\prod_{i=1}^{N}P(w_i\mid w_1,\ldots,w_{i-1})
}
$$

核心思想： 将联合概率分解为一系列条件概率，即根据已有历史预测下一个词。

语言模型的两个主要用途：

1. 概率评估： 计算一个句子出现的概率。

2. 文本生成： 根据当前上下文预测或采样下一个词。

## n-gram 模型

直接估计 $P(w_i \mid w_1, \ldots, w_{i-1})$ 需要枚举任意长的历史，参数空间无法承受。数据稀疏现象也会导致概率变成0.

n-gram 模型引入 **马尔可夫假设**：一个词出现的概率只取决于它前面最近的 $n-1$ 个词:

因此：

$$
\boxed{
P(w_i\mid w_1,\ldots,w_{i-1})
\approx P(w_i\mid w_{i-n+1},\ldots,w_{i-1})
}
$$

整个序列的概率近似为：

$$
P(w_1,\ldots,w_N)
\approx
\prod_{i=1}^{N}
P(w_i\mid w_{i-n+1},\ldots,w_{i-1})
$$

- $n=1$：unigram，词与词独立，只看词频。
- $n=2$：bigram，当前词只看前一个词 $P(w_i \mid w_{i-1})$。
- $n=3$：trigram，当前词看前两个词 $P(w_i \mid w_{i-2}, w_{i-1})$。

### 参数估计：极大似然估计

n-gram 的参数通常用极大似然估计（MLE）得到：

$$
P(w_i \mid w_{i-n+1}, \ldots, w_{i-1}) = \frac{\operatorname{count}(w_{i-n+1}, \ldots, w_i)}{\operatorname{count}(w_{i-n+1}, \ldots, w_{i-1})}
$$

记忆：条件概率 = 完整 n-gram 频数 / 前缀频数。

### 一个 bigram 的例子

```text
我 喜欢 苹果
我 喜欢 香蕉
他 喜欢 苹果
```

总词数为 9。unigram 与 bigram 的频数如下：

| unigram | 频数 | 概率 | bigram | 频数 |
| --- | --- | --- | --- | --- |
| 我 | 2 | 2/9 | 我 喜欢 | 2 |
| 喜欢 | 3 | 3/9 | 喜欢 苹果 | 2 |
| 苹果 | 2 | 2/9 | 喜欢 香蕉 | 1 |
| 香蕉 | 1 | 1/9 | 他 喜欢 | 1 |
| 他 | 1 | 1/9 | | |

由 bigram 频数可以算出条件概率：

```text
P(喜欢|我) = count(我 喜欢) / count(我) = 2/2 = 1
P(苹果|喜欢) = count(喜欢 苹果) / count(喜欢) = 2/3
P(香蕉|喜欢) = count(喜欢 香蕉) / count(喜欢) = 1/3
P(喜欢|他) = count(他 喜欢) / count(他) = 1/1
```

对于测试句“我喜欢苹果”：

```text
P_uni(我 喜欢 苹果) = 2/9 × 3/9 × 2/9 = 12/729
P_bi(我 喜欢 苹果)  = 2/9 × 1 × 2/3 = 4/27
```

bigram 给了一个高得多的概率，因为它利用了词序信息。

## 用困惑度评价语言模型

语言模型的常用内在评价指标是 **困惑度**（Perplexity, PPL）。给定长度为 $N$ 的测试序列：

$$
\operatorname{PPL}(W) = P(w_1, \ldots, w_N)^{-1/N}
= \exp\left(-\frac{1}{N}\sum_{i=1}^{N}\log P(w_i \mid w_{<i})\right)
$$

困惑度可以理解为模型在每一步“平均要在多少个候选词中犹豫”。困惑度越低，模型对测试数据的预测越好。它本质上是测试集上平均负对数似然（交叉熵）的指数，详细推导见 [困惑度](/posts/dl-basics/perplexity/)。

:::note[注意]

困惑度只在相同的词表和分词方式下可比；不同 tokenizer 的困惑度不能直接比较。

:::

## 数据稀疏与零概率

n-gram 的 MLE 有一个致命问题：**训练集中没有出现过的 n-gram，其概率为 0**。只要测试句包含一个未见过的 bigram，整句概率就会变成 0，困惑度变成无穷大。

$n$ 越大，模型能利用的上下文越长，但参数数量和数据稀疏问题也随之加剧。此外，多个概率连乘容易造成数值下溢，实际计算时通常在对数空间求和。

解决零概率问题的技术统称为 **数据平滑**（Smoothing）：从高频事件中“借”一部分概率质量，分配给未观察到的事件。

### 加一与加 k 平滑

最简单的平滑是加一平滑（Laplace smoothing）：假设每个 n-gram 至少额外出现一次。

$$
P_{\text{add-1}}(w_i \mid w_{i-1}) = \frac{\operatorname{count}(w_{i-1}, w_i) + 1}{\operatorname{count}(w_{i-1}) + V}
$$

其中 $V$ 是词表大小。分母加 $V$ 是为了保证所有条件概率之和为 1。

加一平滑对高频词影响不大，但对低频词和未登录词会“过度分配”概率，反而伤害模型。把 1 换成更小的 $k$ 得到加 k 平滑：

$$
P_{\text{add-}k}(w_i \mid w_{i-1}) = \frac{\operatorname{count}(w_{i-1}, w_i) + k}{\operatorname{count}(w_{i-1}) + kV}
$$

$k$ 通常取 $0 < k < 1$。加 k 平滑简单，但在大词表上仍然不够精细。

### 插值与回退

**插值**（Interpolation）把不同阶的 n-gram 概率加权组合，让高阶模型在数据充足时发挥作用，低阶模型在数据稀疏时兜底。以 trigram 为例：

$$
P(w_i \mid w_{i-2}, w_{i-1}) =
\lambda_3 P(w_i \mid w_{i-2}, w_{i-1})
+ \lambda_2 P(w_i \mid w_{i-1})
+ \lambda_1 P(w_i)
$$

其中 $\lambda_1 + \lambda_2 + \lambda_3 = 1$。权重可以固定，也可以根据语料用 EM 算法学习。

**回退**（Backoff）则不混合，而是按阶数从高到低尝试：高阶 n-gram 计数为 0 时，退到低阶；如果低阶也为 0，再继续退。Katz 回退会给低阶概率乘一个折扣因子，保证整体概率归一化：

$$
P_{\text{Katz}}(w_i \mid w_{i-1}) =
\begin{cases}
d \cdot \dfrac{\operatorname{count}(w_{i-1}, w_i)}{\operatorname{count}(w_{i-1})}, & \operatorname{count}(w_{i-1}, w_i) > 0 \\[6pt]
\alpha(w_{i-1}) \cdot P_{\text{Katz}}(w_i), & \operatorname{count}(w_{i-1}, w_i) = 0
\end{cases}
$$

### Good-Turing 平滑

Good-Turing 的核心思想是：**用“出现 $r+1$ 次的 n-gram 数量”来估计“出现 $r$ 次的 n-gram 应该分配多少概率”**。令 $N_r$ 表示恰好出现 $r$ 次的 n-gram 种类数，则调整后的计数为：

$$
r^* = (r+1)\frac{N_{r+1}}{N_r}
$$

概率估计为 $P_{\text{GT}} = r^* / N$，其中：

- $r^*$：调整后的计数；
- $N$：总的 n-gram 出现次数。

所有未出现的 n-gram 共享的总概率质量约为 $N_1 / N$。

Good-Turing 的直觉很优雅，但当 $N_r$ 很小或为 0 时 $r^*$ 不稳定，实际系统通常会做平滑拟合（如 Simple Good-Turing）。它更多是后续折扣方法的理论基础。

## Kneser-Ney 平滑

Kneser-Ney（KN）是目前最经典的 n-gram 平滑方法之一。它观察到：**一个词在低阶模型中出现的次数，不应该按原始词频计算，而应该按它出现在多少个不同的上下文中计算**。这个量称为 **接续计数**（continuation count）：

$$
N_{1+}(\bullet w_i) = \left|\{w_{i-1} : \operatorname{count}(w_{i-1}, w_i) > 0\}\right|
$$

以 bigram 为例，绝对折扣插值的 KN 形式为：

$$
P_{\text{KN}}(w_i \mid w_{i-1}) =
\frac{\max\big(\operatorname{count}(w_{i-1}, w_i) - D,\ 0\big)}{\operatorname{count}(w_{i-1})}
+ \lambda(w_{i-1}) \cdot P_{\text{KN}}(w_i)
$$

其中 $D$ 是折扣常数（通常取 $0.5$ 到 $0.75$ 左右），低阶概率用接续计数估计：

$$
P_{\text{KN}}(w_i) = \frac{N_{1+}(\bullet w_i)}{\sum_{w} N_{1+}(\bullet w)}
$$

插值权重为：

$$
\lambda(w_{i-1}) = \frac{D \cdot N_{1+}(w_{i-1}\bullet)}{\operatorname{count}(w_{i-1})}
$$

其中 $N_{1+}(w_{i-1}\bullet)$ 表示紧跟在 $w_{i-1}$ 后面、出现过的不同词的数量。

KN 的关键改进在于低阶分布：像 "Francisco" 这样的词，原始词频可能不高，但它几乎只出现在 "San" 后面，接续计数会正确地反映这种上下文专一性。trigram 版本需要递归地对低阶使用接续计数，称为 Modified Kneser-Ney。

## 平滑方法怎么选

| 方法 | 核心思想 | 优点 | 局限 |
| --- | --- | --- | --- |
| 加一 / 加 k | 给所有事件加一个常数 | 简单、必有正概率 | 大词表上过度平滑 |
| 插值 | 各阶概率加权混合 | 灵活，可学习权重 | 需要调参 |
| 回退 | 高阶为零时退到低阶 | 保留高阶信息 | 需要折扣保证归一化 |
| Good-Turing | 用 $N_{r+1}/N_r$ 调整计数 | 理论优雅 | 稀疏时 $N_r$ 不稳定 |
| Kneser-Ney | 绝对折扣 + 接续计数 | 实践中效果最好 | 实现较复杂 |

n-gram 平滑只能缓解稀疏，无法从根本上解决“未见过的上下文”问题。神经网络语言模型通过分布式表示和参数共享，把相似的上下文映射到相近的表示，从而获得泛化能力，见 [NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)。

## 相关阅读

- 词法分析中的分词与序列标注：[词法分析](/posts/nlp/03-02-lexical-analysis/)
- 语言模型评价与生成指标：[NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)
- 困惑度与交叉熵的推导：[困惑度](/posts/dl-basics/perplexity/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)
- n-gram 的神经替代：[NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)
