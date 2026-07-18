---
title: 全局词向量与子词嵌入：GloVe、fastText 与 BPE
published: 2026-07-18
description: '从全局共现统计到子词切分：GloVe 的加权最小二乘、fastText 的 n-gram 表示、BPE 的分词算法'
image: ''
tags: [NLP, GloVe, BPE, Tokenizer, Embedding, LLM]
category: '09-自然语言处理'
order: 2
draft: false
lang: ''
---

:::tip[符号约定]

沿用符号体系，新增：

| 符号 | 含义 |
|------|------|
| $X_{ij}$ | 词 $i$ 出现在词 $j$ 上下文中的次数 |
| $X_i = \sum_k X_{ik}$ | 词 $i$ 的总出现次数 |
| $P_{ij} = X_{ij} / X_i$ | 词 $j$ 出现在词 $i$ 上下文中的概率 |
| $f(X_{ij})$ | 加权函数，控制高频词对的权重 |
| $\mathbf{w}_i, \tilde{\mathbf{w}}_j$ | GloVe 中词 $i$ 作为中心词/上下文词的向量 |
| $b_i, \tilde{b}_j$ | GloVe 中词 $i$ 和词 $j$ 的偏置项 |

:::

## 1. word2vec 的局限性：局部 vs 全局

word2vec 通过滑动窗口逐对处理词，本质上是**局部上下文**方法。考虑以下语料：

> The cat sits on the mat. The dog sits on the mat. The cat and the dog play together.

word2vec 需要多次遍历窗口才能捕捉到"cat"和"dog"共享"sits"、"mat"等上下文——它无法直接利用"cat 和 dog 在所有句子中与哪些词共现了多少次"这一全局统计信息。

这引出了另一种思路：**能否直接对全局共现矩阵建模？**

## 2. GloVe：全局词向量

GloVe（Global Vectors）由 Pennington 等人于 2014 年提出，核心思想是：**词向量应当编码全局共现统计中蕴含的语义关系**。

### 2.1 共现概率比

首先构建一个 $V \times V$ 的共现矩阵 $\mathbf{X}$，其中 $X_{ij}$ 表示词 $j$ 在词 $i$ 的上下文窗口中出现次数。定义共现概率：

$$
P_{ij} = P(j \mid i) = \frac{X_{ij}}{X_i}
$$

GloVe 的关键洞察是：**共现概率的比值**比纯粹的概率值更能编码语义。考虑三个词 $i = \text{ice}$、$j = \text{steam}$ 和探测词 $k$：

| 探测词 $k$ | $P(k \mid \text{ice})$ | $P(k \mid \text{steam})$ | $\frac{P(k \mid \text{ice})}{P(k \mid \text{steam})}$ |
|:---|:---:|:---:|:---:|
| solid | $1.9 \times 10^{-4}$ | $2.2 \times 10^{-5}$ | **8.9** |
| gas | $1.8 \times 10^{-5}$ | $1.7 \times 10^{-4}$ | **0.094** |
| water | $3.0 \times 10^{-4}$ | $3.2 \times 10^{-4}$ | ≈ 1.0 |
| fashion | $1.7 \times 10^{-5}$ | $1.8 \times 10^{-5}$ | ≈ 1.0 |

- 当 $k$ 与 ice 相关但不与 steam 相关（solid），比值 >> 1
- 当 $k$ 与 steam 相关但不与 ice 相关（gas），比值 << 1
- 当 $k$ 与两者都相关或都不相关（water, fashion），比值 ≈ 1

:::tip[直观理解]

仅看 $P(\text{solid} \mid \text{ice})$ 本身，你只知道"solid"偶尔出现在"ice"旁边。但**比值** $P(\text{solid} \mid \text{ice}) / P(\text{solid} \mid \text{steam})$ 告诉你：solid 更偏向 ice 而不是 steam。这个"偏向"信息才是区分语义的关键。

word2vec 间接利用了这种信息（通过负采样让共现词的向量靠近），但 GloVe 直接对共现概率比建模。
:::

### 2.2 模型

GloVe 希望词向量 $\mathbf{w}_i$ 和 $\tilde{\mathbf{w}}_j$ 的内积能够编码概率比：

$$
\mathbf{w}_i^T \tilde{\mathbf{w}}_j + b_i + \tilde{b}_j = \log X_{ij}
$$

这个等式来自以下推导：我们希望 $\mathbf{w}_i^T \tilde{\mathbf{w}}_j$ 近似 $\log P_{ij}$，而 $\log P_{ij} = \log X_{ij} - \log X_i$。引入偏置项 $b_i$ 吸收 $\log X_i$，$\tilde{b}_j$ 平衡对称性，最终得到上述形式。

损失函数为加权最小二乘：

$$
J = \sum_{i=1}^{V} \sum_{j=1}^{V} f(X_{ij}) \left( \mathbf{w}_i^T \tilde{\mathbf{w}}_j + b_i + \tilde{b}_j - \log X_{ij} \right)^2
$$

其中加权函数 $f(X_{ij})$ 的设计非常关键：

$$
f(x) = \begin{cases}
(x / x_{\max})^\alpha, & x < x_{\max} \\
1, & x \geq x_{\max}
\end{cases}
$$

典型参数：$\alpha = 0.75$，$x_{\max} = 100$。

:::tip[加权函数的作用]

- 低频词对（$X_{ij}$ 小）：权重小，因为统计不靠谱——"cat"和"quantum"可能只共现了 1 次，纯属巧合
- 高频词对（$X_{ij}$ 大）：权重截断为 1，防止"the"和"a"这种无意义高频词对主导训练
- $\alpha = 0.75$ 的幂次：在低频和高频之间平滑过渡，既不过度信任低频统计，也不被高频词对淹没

相比之下，word2vec 的负采样用 $P(w) \propto \text{count}(w)^{3/4}$ 来处理类似问题，但 GloVe 的加权机制更精细——它直接作用于共现矩阵的每个元素。
:::

### 2.3 GloVe vs word2vec

| 方面 | word2vec | GloVe |
|------|----------|-------|
| 统计视角 | 局部窗口，逐对训练 | 全局共现矩阵，一次性建模 |
| 训练方式 | 随机梯度下降，在线学习 | 加权最小二乘，可批量优化 |
| 稀有词 | Skip-gram 更好 | 依赖共现矩阵，稀疏时表现差 |
| 高频词 | 负采样截断 | 加权函数截断 |
| 并行性 | 较差（在线更新） | 较好（矩阵分解风格） |

实际应用中两者效果接近，但 GloVe 的全局视角使其在**词类比任务**上略优，word2vec 的局部视角使其在**稀有词**上略优。

## 3. 词嵌入的共同瓶颈：OOV 问题

word2vec 和 GloVe 都有一个根本限制：**每个词必须有独立的向量**。这意味着：

- 词汇表外的词（Out-Of-Vocabulary, OOV）无法处理
- "cat"和"cats"需要两个完全独立的向量，无法共享词根信息
- 对于形态丰富的语言（如土耳其语、芬兰语），词汇表爆炸

例如，传统词嵌入无法理解"unhappiness" = "un" + "happy" + "ness"——即使"happy"已经有了很好的向量。

## 4. 子词嵌入（Subword Embeddings）

### 4.1 fastText

fastText 的解决方案简单而有效：**每个词表示为其字符 n-gram 向量之和**。

以词 "where" 为例，加上边界标记 `<` 和 `>` 后变成 `<where>`。取 $n=3$ 的字符 trigram：

```
<wh, whe, her, ere, re>
```

词 "where" 的向量 = 所有 trigram 向量之和 + 词本身的向量。

这使得 fastText 能够：
- **处理 OOV**：未见过的词 "wheres" 可以由 trigram `<wh, whe, her, ere, res, es>` 的向量和表示
- **共享词根**："where" 和 "wherever" 共享 trigram `whe, her, ere`，向量自然相近
- **捕捉拼写规律**：前缀、后缀、词根等形态信息自动编码在 n-gram 中

### 4.2 BPE（Byte Pair Encoding）

BPE 是当今 LLM 分词器的核心算法，minimind 使用的正是 BPE tokenizer。它从字符级别开始，通过迭代合并最频繁的字符对来构建子词词汇表。

**算法流程：**

1. 初始化：词汇表 = 所有字符 + 结束符
2. 统计所有相邻符号对的频率
3. 合并频率最高的符号对为一个新符号
4. 重复步骤 2-3，直到词汇表达到预设大小 $V$

**具体例子：**

初始语料（每个词后加 `_` 表示词尾）：

```
low_ lower_ lowest_ newer_ wider_
```

字符级拆分：

```
l o w _   l o w e r _   l o w e s t _   n e w e r _   w i d e r _
```

统计频率最高的相邻对：`e r` 出现 4 次 → 合并为 `er`：

```
l o w _   l o w er _   l o w e s t _   n e w er _   w i d er _
```

继续：`er _` 出现 3 次 → 合并为 `er_`：

```
l o w _   l o w er_   l o w e s t _   n e w er_   w i d er_
```

继续：`l o` 出现 3 次 → 合并为 `lo`：

```
lo w _   lo w er_   lo w e s t _   n e w er_   w i d er_
```

经过足够多次合并后，词汇表可能包含：`low`, `er`, `est`, `er_`, `new`, `wid` 等子词。

这样，"lowest" 被切分为 `low` + `est`，而 "lower" 被切分为 `low` + `er`，共享了词根 `low`。

:::tip[BPE 与 LLM 分词器]

minimind 的 BPE tokenizer 词表大小为 6400，远小于 Qwen2（151,643）或 Llama 3（128,000），但这是小模型的有意设计——更小的词表意味着更小的 embedding 层和输出层，显著降低小模型的参数占比。

以 minimind-3 为例：$d = 768$，$V = 6400$，embedding 层参数量 $V \times d = 4.9\text{M}$，占总参数 $64\text{M}$ 的约 $7.6\%$。如果使用 $V = 32000$ 的词表，embedding 层将占用 $24.6\text{M}$，占比飙升到 $38\%$。
:::

### 4.3 WordPiece 与 SentencePiece

| 方法 | 选择合并的准则 | 代表模型 |
|------|---------------|----------|
| BPE | 频率最高 | GPT 系列、minimind |
| WordPiece | 最大似然提升（$\frac{P(\text{合并后})}{P(\text{合并前})}$） | BERT |
| Unigram | 从大词表开始，逐步剪枝 | SentencePiece（T5、LLaMA） |

**WordPiece** 与 BPE 类似，但合并时选择使训练数据似然提升最大的对，而非单纯频率最高。例如，`un` + `##affable` 即使频率不高，但如果合并后大幅提升语言模型概率，也会被优先合并。

**SentencePiece** 将空格也视为普通字符（用 `▁` 表示），因此可以处理任何语言，并且分词是可逆的——直接拼接 tokens 即可还原原文。

## 5. 从子词嵌入到 BERT

子词嵌入解决了 OOV 问题，但仍然是**静态**的：同一个子词嵌入在所有上下文中保持不变。

下一节我们将看到 **BERT** 如何将子词嵌入与 Transformer 的上下文建模能力结合，为每个 token 生成**上下文相关**的表示——同一个词在不同句子中会有不同的向量。这是从"静态词向量"到"动态上下文表示"的关键跃迁。

## 参考文献

- Pennington, J., Socher, R., & Manning, C. (2014). GloVe: Global Vectors for Word Representation. *EMNLP 2014*.
- Bojanowski, P., et al. (2017). Enriching Word Vectors with Subword Information. *TACL 2017*.
- Sennrich, R., Haddow, B., & Birch, A. (2016). Neural Machine Translation of Rare Words with Subword Units. *ACL 2016*.