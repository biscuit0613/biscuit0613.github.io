---
title: '词向量的评价与应用（单词分布式表示的评价）：相似度与类比任务'
published: 2026-10-20
description: '词向量内在评价的两类任务：余弦相似度与词类比，以及常用数据集、评价指标和局限'
image: ''
tags: [NLP, Embedding, Evaluation, word2vec, GloVe]
category: '09-自然语言处理'
order: 502
draft: false
lang: ''
---

单词分布式表示（Word Embedding）把离散的词映射到连续的向量空间，是神经网络 NLP 的基础。那么如何评价词向量的质量呢？

## 内在评价与外在评价

词向量的评价通常分为两类：

- **内在评价**（Intrinsic Evaluation）：测试词向量是否能够有效地表达特定的语义特征，如词义相关性或类比性，并通过返回一个分数来衡量词向量的质量。速度快、成本低，但和下游任务的表现不一定一致。
- **外在评价**（Extrinsic Evaluation）：把词向量作为特征或初始化，放到 NER、词性标注、文本分类等下游任务中，看最终指标。更贴近实际效果，但计算成本高，且受下游模型影响。

## 词义相关性（相似度）

给定两个词 $w_i$ 和 $w_j$，用余弦相似度衡量它们向量方向的接近程度：

$$
\operatorname{sim}(w_i, w_j) =
\frac{\mathbf{v}_i^T \mathbf{v}_j}{\|\mathbf{v}_i\| \|\mathbf{v}_j\|}
$$

余弦相似度只关注方向，不受向量长度影响。对于“相似词检索”任务，给定 $w_i$，在词表中找最相似的词：

$$
w_j = \arg\max_{w \in \mathcal{V}} \operatorname{sim}(w_i, w)
$$

评价时，通常把模型算出的相似度与人工标注的相似度做 **斯皮尔曼相关系数**（参考[评价指标](/posts/nlp/05-01-evaluation-metrics/)），衡量两者的排序一致性。常用数据集包括：

- **WordSim-353**：353 个词对，覆盖广泛语义关系；
- **MEN**：3000 个词对，强调人类对相似度的判断；
- **SimLex-999**：999 个词对，更强调“相似”而非“相关”，例如“car”和“automobile”相似，而“car”和“road”相关但不相似。

不同数据集对“相似”的定义不同，模型在一个数据集上表现好，不代表在所有语义关系上都好。

## 词类比

词类比任务用向量运算检验词向量是否编码了关系结构。最著名的例子是：

$$
\mathbf{v}_{\text{king}} - \mathbf{v}_{\text{man}} + \mathbf{v}_{\text{woman}} \approx \mathbf{v}_{\text{queen}}
$$

给定类比关系 $w_i : w_j :: w_k : ?$，要找到满足“$w_i$ 到 $w_j$ 的关系，类似 $w_k$ 到 $w_l$”的词 $w_l$。常用两种打分方式：

### 3CosAdd

$$
w_l = \arg\max_{w \in \mathcal{V}} \operatorname{sim}\left(\mathbf{v}_j - \mathbf{v}_i + \mathbf{v}_k,\ \mathbf{v}_w\right)
$$

### 3CosMul

$$
w_l = \arg\max_{w \in \mathcal{V}}
\frac{\operatorname{sim}(\mathbf{v}_j, \mathbf{v}_w)\operatorname{sim}(\mathbf{v}_k, \mathbf{v}_w)}
{\operatorname{sim}(\mathbf{v}_i, \mathbf{v}_w) + \varepsilon}
$$

3CosMul 通过乘法组合相似度，通常在类比任务上更稳健。

### 类比任务的局限

- **只衡量一种关系**：词类比主要覆盖性别、时态、国名-首都等少量关系，不能代表全部语义；
- **受词频和 hubness 影响**：高频词容易成为很多查询的最近邻；
- **存在社会偏见**：词向量会继承语料中的性别、种族等刻板印象，类比结果可能放大偏见；
- **对 tokenizer 敏感**：子词模型的“词”可能不是一个 token，类比需要在词级别聚合子词表示。

## 外在评价

把词向量用于下游任务，比较不同词向量带来的性能差异。常见任务包括：

- 命名实体识别；
- 词性标注；
- 文本分类；
- 句法分析；
- 机器翻译。

外在评价更接近实际应用，但结果受下游模型、训练数据、超参数影响。一个词向量在某个任务上更好，可能只是因为它的维度和下游模型更匹配。

## 评价方法的取舍

| 维度 | 内在评价 | 外在评价 |
| --- | --- | --- |
| 成本 | 低 | 高 |
| 速度 | 快 | 慢 |
| 可解释性 | 强 | 弱 |
| 与下游效果的一致性 | 不一定 | 直接 |
| 适用场景 | 快速筛选、分析词向量性质 | 最终选型、任务优化 |

实践中通常先用内在评价快速筛选，再用外在评价做最终判断。对于预训练语言模型，词级别的内在评价已经不够，因为同一个词在不同上下文中的表示不同，评价需要转向句子级任务或上下文相关的探测任务（probing）。

## 相关阅读

- 静态词向量的训练：[Word2Vec](/posts/nlp/06-02-word2vec/)、[GloVe](/posts/nlp/06-03-glove/)
- 子词与上下文相关表示：[子词分词](/posts/nlp/06-04-subword-tokenization/)、[ELMo](/posts/nlp/06-06-elmo/)
- 分类与生成任务的评价指标：[NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)
