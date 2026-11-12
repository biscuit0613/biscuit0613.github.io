---
title: '预训练语言模型：四种范式速览'
published: 2026-10-20
description: '以教材 6.3 节为框架，把 ELMo、GPT、BERT、BART 放进统一的“结构→预训练目标→下游适配”视角对比，并给出选型直觉'
image: ''
tags: [NLP, Pre-training, ELMo, GPT, BERT, BART]
category: '09-自然语言处理'
order: 608
draft: false
lang: ''
---

1. **结构**：输入层/编码层/输出层各是什么？上下文是单向、双向还是兼而有之？
2. **预训练目标**：拿无标注数据预测什么？（公式）
3. **下游适配**：取哪个位置的表示、接什么头、用什么损失？

## 四种范式

- **动态词向量（ELMo）**：双向语言模型，但预训练模型**冻结**，各层表示按任务加权组合后当作输入特征——“预训练 + 特征提取”。
- **自回归（GPT）**：decoder-only，只用因果注意力，从左到右预测下一个 token——擅长生成。
- **掩码（BERT）**：encoder-only，MLM + NSP，双向上下文——擅长理解。
- **去噪重建（BART）**：encoder-decoder，对输入加噪后自回归重建原文——理解与生成兼顾。

这些差异不是“模型大小”的差异，而是**预训练目标决定了它们更适合理解还是生成**。

## 对比

| 模型 | 结构 | 预训练目标 | 下游取哪个表示 | 擅长 |
| --- | --- | --- | --- | --- |
| ELMo | 双向 LSTM | 双向 LM | 各层加权和（冻结接入） | 作为特征增强任意下游模型 |
| GPT | decoder-only，因果注意力 | 下一词预测 | 末位置 $\mathbf{h}_n^{(L)}$ + $\mathbf{W}_y$ | 生成、续写、对话 |
| BERT | encoder-only，双向注意力 | MLM + NSP | $[\text{CLS}]$ 位置或各位置 $\mathbf{h}_i$ | 分类、抽取式问答、序列标注 |
| BART | encoder-decoder | 多种去噪重建 | 解码器末状态 / 自回归生成 | 摘要、翻译、生成式理解 |

## 选型

- 需要**双向上下文**的理解任务 → BERT；
- 需要**逐 token 生成**、严格因果顺序 → GPT；
- 既要用上下文理解输入、又要生成输出（seq2seq）→ BART；
- 下游模型结构不能大改、只想加上下文特征 → ELMo。

## 历史线索

ELMo 证明了大规模无标注语料预训练能学到通用语言知识；GPT 和 BERT 标志着“预训练 - 微调”范式成熟。从表示能力看，encoder-decoder 同时具备双向理解和自回归生成；从训练效率看，decoder-only 结构简单、易于扩展到超大模型，最终成为现代大语言模型的主流架构，具体结构见 [Decoder-only Transformer](/posts/transformer/decoder-only-transformer/)。

## 相关阅读

- 动态词向量：[ELMo](/posts/nlp/06-06-elmo/)
- 自回归预训练：[GPT](/posts/nlp/06-08b-gpt/)
- 掩码预训练：[BERT](/posts/nlp/06-07-bert/)、[BERT 微调实践](/posts/nlp/06-10-bert-finetune/)
- 去噪 seq2seq 预训练：[BART](/posts/nlp/06-09-bart/)
- Transformer 结构：[自注意力](/posts/transformer/trasformer-attetion/)
- 大模型的指令微调：[LLM 有监督微调](/posts/nlp/08-01-llm-sft/)
