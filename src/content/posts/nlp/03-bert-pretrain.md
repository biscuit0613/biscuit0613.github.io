---
title: 'BERT：预训练+微调范式'
published: 2026-07-18
description: '从双向上下文建模到 MLM/NSP 预训练任务：BERT 如何用 Transformer 编码器统一 NLU 任务'
image: ''
tags: [NLP, BERT, Pre-training, Transformer, LLM]
category: '09-自然语言处理'
order: 3
draft: false
lang: ''
---

:::tip[符号约定]

沿用 [word2vec](/posts/nlp/01-word2vec/) 和 [GloVe/BPE](/posts/nlp/02-glove-bpe/) 的符号体系，新增：

| 符号 | 含义 |
|------|------|
| $\mathbf{E} \in \mathbb{R}^{d \times n}$ | 输入 token 嵌入序列，$n$ 为序列长度 |
| $\mathbf{T} \in \mathbb{R}^{d \times n}$ | BERT 输出的上下文表示序列 |
| $\mathbf{T}_i \in \mathbb{R}^d$ | 第 $i$ 个 token 的上下文表示 |
| $\mathbf{W}_{\text{MLM}} \in \mathbb{R}^{V \times d}$ | MLM 输出投影矩阵 |
| $\text{[CLS]}$ | 序列起始标记，其输出表示用作句子级特征 |
| $\text{[SEP]}$ | 句子分隔标记 |
| $\text{[MASK]}$ | 被遮蔽的 token 的占位符 |

:::

## 1. 从静态到上下文相关

word2vec 和 GloVe 为每个词分配一个固定的向量——无论 "bank" 出现在 "river bank" 还是 "central bank" 中，它都使用同一个向量。这是静态词嵌入的根本局限。

BERT 通过 [Transformer 编码器](/posts/transformer/trasformer-attetion/) 的 self-attention 机制，为每个 token 生成**取决于整个上下文的动态表示**：

$$
\mathbf{T} = \text{TransformerEncoder}(\mathbf{E})
$$

同一个词 "bank" 在不同上下文中，$\mathbf{T}_{\text{bank}}$ 完全不同——因为 self-attention 让 "bank" 关注了 "river" 或 "central"，从而吸收了上下文的语义。

:::tip[直观理解：单词的"变色龙"能力]

静态词向量像是给每个词拍了一张证件照——只能看到词的固定面貌。BERT 的上下文表示像是给同一个词在不同场景下拍了不同的照片——"bank" 在河边是一张照片，在金融中心是另一张照片，两张照片虽然都是 "bank"，但呈现的语义完全不同。

这种能力来自 self-attention 的加权求和：每个 token 的最终表示是**整个序列中所有 token 的加权平均**，权重由注意力机制根据语义相关性动态计算。
:::

## 2. BERT 的输入表示

BERT 的输入由三个嵌入相加得到：

$$
\mathbf{E}_{\text{input}} = \mathbf{E}_{\text{token}} + \mathbf{E}_{\text{segment}} + \mathbf{E}_{\text{position}}
$$

### 2.1 Token 嵌入

使用 WordPiece 子词分词器，词汇表大小 $V = 30,522$。句子对的标准输入格式为：

```
[CLS] 句子A [SEP] 句子B [SEP]
```

- `[CLS]`（Classification）：序列的第一个 token，其最终隐藏状态 $\mathbf{T}_{\text{[CLS]}}$ 用作整个序列的聚合表示，用于分类任务
- `[SEP]`（Separator）：分隔两个句子，同时告诉模型句子边界在哪里

### 2.2 Segment 嵌入

通过可学习的 segment embedding 区分句子 A 和句子 B。句子 A 的所有 token 加上 $\mathbf{e}_A$，句子 B 的所有 token 加上 $\mathbf{e}_B$。两个 segment embedding 是随机初始化并随训练更新的。

### 2.3 Position 嵌入

不同于原始 Transformer 的**正弦位置编码**，BERT 使用**可学习的位置嵌入**。最大序列长度为 512，因此有 512 个位置嵌入向量，每个维度为 $d = 768$（BERT-base）。

| 位置编码方式 | 代表模型 | 优缺点 |
|:---|:---|:---|
| 正弦编码（sinusoidal） | 原始 Transformer | 可外推到训练时未见过的长度 |
| 可学习嵌入（learned） | BERT、GPT | 更灵活，但无法外推 |

:::tip[为什么 BERT 用 512 作为最大长度？]

self-attention 的计算复杂度为 $O(n^2)$，其中 $n$ 是序列长度。$n = 512$ 时，注意力矩阵大小为 $512 \times 512$，计算量仍可接受。$n = 1024$ 时，计算量增长 4 倍。在当时（2018 年）的硬件条件下，512 是工程上的 sweet spot。

现代 LLM 通过 Flash Attention、稀疏注意力等技术将上下文窗口扩展到 32K 甚至 128K，但核心原理仍是 self-attention。
:::

## 3. 预训练任务

BERT 使用两个无监督任务进行预训练，二者同时进行，总损失为两项之和。

### 3.1 Masked Language Model（MLM）

**任务**：随机遮蔽输入序列中 15% 的 token，让模型预测被遮蔽的原始 token。

**为什么不能用标准的语言模型（预测下一个词）？**

标准的因果语言模型（如 GPT）只能看到左侧上下文，但 BERT 使用双向 Transformer 编码器——每个 token 可以看到所有其他 token。如果让它预测下一个词，模型可以直接"看到"答案（信息泄露），训练将毫无意义。

MLM 通过随机遮蔽解决了这个问题。

**遮蔽策略**：

对于被选中的 15% token，并非全部替换为 `[MASK]`：

| 操作 | 比例 | 示例（原始词 = "apple"） |
|:---|:---:|:---|
| 替换为 `[MASK]` | 80% | "I eat an `[MASK]` today" |
| 替换为随机词 | 10% | "I eat an **car** today" |
| 保持不变 | 10% | "I eat an **apple** today" |

:::tip[为什么需要 10% 随机替换和 10% 保持不变？]

如果所有被选中的 token 都替换为 `[MASK]`，模型在预训练时只需要学会"看到 `[MASK]` 就预测原词"，而在微调时下游任务中并没有 `[MASK]` 标记，造成预训练-微调不匹配。

- **10% 随机替换**：迫使模型在即使看到"car"时也要怀疑它可能是被替换的，不能盲目信任输入
- **10% 保持不变**：让模型学会在不需要预测时保持原词（即输出 = 输入），这对某些下游任务有帮助

这种设计使得 BERT 在预训练-微调之间保持一致的输入分布。
:::

**MLM 损失**：对被遮蔽的 token 集合 $\mathcal{M}$，使用交叉熵损失：

$$
\mathcal{L}_{\text{MLM}} = -\frac{1}{|\mathcal{M}|} \sum_{i \in \mathcal{M}} \log P(w_i \mid \mathbf{T}_i)
$$

其中 $P(w_i \mid \mathbf{T}_i) = \operatorname{softmax}(\mathbf{W}_{\text{MLM}} \mathbf{T}_i + \mathbf{b}_{\text{MLM}})$。注意，只有被遮蔽的位置才计算损失，非遮蔽位置不参与 MLM 损失。

### 3.2 Next Sentence Prediction（NSP）

**任务**：给定两个句子 A 和 B，判断 B 是否是 A 的真实后续句子。

这是一个二分类任务，使用 `[CLS]` token 的最终隐藏状态 $\mathbf{T}_{\text{[CLS]}}$ 作为输入：

$$
P(\text{IsNext} \mid A, B) = \sigma(\mathbf{w}_{\text{NSP}}^T \mathbf{T}_{\text{[CLS]}} + b_{\text{NSP}})
$$

训练数据构造：50% 的样本中 B 是 A 的真实后续（正例），50% 的样本中 B 是从语料中随机抽取的句子（负例）。

:::tip[NSP 的争议与后续]

NSP 的设计初衷是让 BERT 理解句子间的关系，这对问答（QA）和自然语言推断（NLI）等任务有帮助。但后续研究（如 RoBERTa）发现：

- **移除 NSP 反而可能提升性能**，只要使用更大的批次和更长的序列
- NSP 将两个不相关的句子拼接在一起，可能让模型学到的是"主题是否一致"而非"逻辑是否连贯"

因此，后来的模型（RoBERTa、ALBERT 等）大多**移除了 NSP**，只保留 MLM 作为预训练任务。但 NSP 作为 BERT 的原始设计，在理解句子对任务的发展历程中仍有历史意义。
:::

## 4. 微调（Fine-tuning）

BERT 预训练完成后，通过添加一个简单的任务特定层，在标注数据上进行微调。

### 4.1 单句分类

如情感分析，使用 `[CLS]` 的表示 $\mathbf{T}_{\text{[CLS]}}$ 作为句子特征：

$$
P(y \mid \text{text}) = \operatorname{softmax}(\mathbf{W} \mathbf{T}_{\text{[CLS]}} + \mathbf{b})
$$

### 4.2 句子对分类

如自然语言推断（判断前提和假设的关系），两个句子用 `[SEP]` 分隔，同样使用 `[CLS]` 表示。

### 4.3 序列标注

如命名实体识别（NER），每个 token 的输出 $\mathbf{T}_i$ 独立预测一个标签：

$$
P(y_i \mid \text{text}) = \operatorname{softmax}(\mathbf{W} \mathbf{T}_i + \mathbf{b}), \quad \forall i
$$

这利用了 BERT 为每个 token 生成的上下文相关表示——同一个词在不同上下文中，NER 标签可以不同（例如 "Apple" 在 "Apple Inc." 中是 ORG，在 "I eat an apple" 中不是实体）。

### 4.4 问答

对于 SQuAD 风格的抽取式问答，BERT 预测答案的起始位置和结束位置：

$$
P_{\text{start}}(i) = \operatorname{softmax}(\mathbf{w}_{\text{start}}^T \mathbf{T}_i)
$$

$$
P_{\text{end}}(i) = \operatorname{softmax}(\mathbf{w}_{\text{end}}^T \mathbf{T}_i)
$$

:::tip[微调 vs 预训练的关键区别]

- **预训练**：数据量巨大（BooksCorpus 800M 词 + English Wikipedia 2.5B 词），无标签，训练时间长（BERT-base 在 16 个 TPU 上训练 4 天）
- **微调**：数据量小（通常几千到几万条标注数据），有标签，训练时间短（通常在单 GPU 上几小时）

这正是"预训练+微调"范式的核心价值：**只需一次昂贵的预训练，即可通过廉价的微调适配到多种下游任务**。这与我们即将在 [minimind](/posts/minimind/) 中看到的流程完全一致——预训练学习通用语言知识，SFT 适配特定任务。
:::

## 5. BERT 的局限与 LLM 的演进

BERT 开创了预训练+微调范式，但存在一些局限：

| 局限 | 说明 | LLM 的改进 |
|:---|:---|:---|
| 双向编码 | MLM 不适合文本生成，因为生成时看不到未来 token | GPT 使用因果注意力（单向），专为生成设计 |
| 固定长度 | 最大 512 token，无法处理长文档 | 现代 LLM 支持 32K-128K 上下文 |
| 微调成本 | 每个下游任务需要单独微调一个模型 | GPT-3 展示了大模型的**零样本/少样本**能力，无需微调 |
| 模型规模 | BERT-large 340M 参数 | 现代 LLM 动辄数十亿到数千亿参数 |

BERT 的预训练+微调范式是 GPT-1 和 GPT-2 的灵感来源，而 GPT-3 的 In-Context Learning 又进一步推动了 LLM 的发展。在下一节中，我们将通过情感分析的任务来具体实践 BERT 的微调过程。

## 参考文献

- Devlin, J., et al. (2019). BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding. *NAACL 2019*.
- Liu, Y., et al. (2019). RoBERTa: A Robustly Optimized BERT Pretraining Approach. *arXiv:1907.11692*.
- Vaswani, A., et al. (2017). Attention Is All You Need. *NeurIPS 2017*.