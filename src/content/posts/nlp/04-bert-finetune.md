---
title: 'BERT 微调实践：情感分析'
published: 2026-07-18
description: '以 IMDb 影评情感分析为例，详解 BERT 微调的完整流程：数据准备、模型构建、训练策略与评估'
image: ''
tags: [NLP, BERT, Fine-tuning, SFT]
category: '09-自然语言处理'
order: 4
draft: false
lang: ''
---

:::tip[符号约定]

沿用 [BERT 预训练](/posts/nlp/03-bert-pretrain/) 的符号体系。新增：

| 符号 | 含义 |
|------|------|
| $\mathcal{D} = \{(\mathbf{x}_i, y_i)\}_{i=1}^{N}$ | 下游任务标注数据集 |
| $\mathbf{x}_i$ | 第 $i$ 个样本的 token 序列 |
| $y_i \in \{0, 1\}$ | 第 $i$ 个样本的标签（二分类） |
| $\theta_{\text{BERT}}$ | 预训练 BERT 的参数 |
| $\theta_{\text{task}}$ | 任务特定层的参数 |
| $\eta$ | 学习率 |
| $B$ | 批次大小 |

:::

## 1. 微调的本质

BERT 微调的核心思想是：**利用预训练阶段学到的通用语言知识，在小规模标注数据上快速适配特定任务**。

形式上，微调是在预训练权重 $\theta_{\text{BERT}}$ 的基础上，通过少量标注数据同时更新 $\theta_{\text{BERT}}$ 和 $\theta_{\text{task}}$（任务特定层参数）：

$$
\theta^* = \arg\min_{\theta_{\text{BERT}}, \theta_{\text{task}}} \frac{1}{N} \sum_{i=1}^{N} \mathcal{L}(f(\mathbf{x}_i; \theta_{\text{BERT}}, \theta_{\text{task}}), y_i)
$$

与从零训练相比，微调的优势在于：

| 方面 | 从零训练 | BERT 微调 |
|:---|:---|:---|
| 数据需求 | 百万级标注样本 | 几千到几万即可 |
| 训练时间 | 数天到数周 | 数小时 |
| 泛化能力 | 差（容易过拟合小数据集） | 好（预训练提供了通用语言知识） |

:::tip[直观理解：转学 vs 重新上学]

从零训练就像让一个从来没上过学的人去学医学——你首先要教他识字、数数、基本的逻辑推理，然后再教他医学知识。而 BERT 微调就像让一个大学毕业生去转专业学医——他已经有了扎实的通识基础，只需要学习医学的专业知识即可。

BERT 的预训练阶段"通识教育"包括：词法、句法、语义、常识推理等通用语言能力。微调阶段只需要教会它特定任务模式。
:::

## 2. 任务：IMDb 影评情感分析

我们以 IMDb 电影评论数据集为例，任务是将影评分类为**正面**（positive）或**负面**（negative）。

**数据样例**：

| 文本 | 标签 |
|:---|:---:|
| "This movie is absolutely fantastic! The acting was superb and the plot kept me on the edge of my seat." | 1（正面） |
| "A complete waste of time. The dialogue was wooden and the special effects were laughable." | 0（负面） |

**数据集**：25,000 条训练样本，25,000 条测试样本，正负比例均衡。

## 3. 数据预处理

### 3.1 Tokenization

使用 BERT 的 WordPiece tokenizer 将文本转换为 token 序列：

```python
# 原始文本
text = "This movie is fantastic!"

# 分词结果
tokens = ["[CLS]", "this", "movie", "is", "fantastic", "##!", "[SEP]"]
token_ids = [101, 2023, 3185, 2003, 10392, 999, 102]
```

其中 `##!` 是 WordPiece 的子词——因为 "fantastic!" 被切分为 "fantastic" + "##!"（`##` 前缀表示该 token 是前一个 token 的延续）。

### 3.2 截断与填充

BERT 的最大输入长度为 512 token。对于超过 512 token 的影评，需要截断。对于不足 512 token 的影评，需要填充 `[PAD]`（token ID = 0）到统一长度。

**截断策略**：对于长文本，通常保留开头和结尾部分（因为影评的开头和结尾往往包含最重要的情感信息）或只保留开头 510 token（加上 `[CLS]` 和 `[SEP]` 共 512）。

**Attention Mask**：生成一个与输入等长的二元掩码，标记哪些位置是真实 token（1）和填充 token（0）。self-attention 计算时，填充位置的注意力权重被设为 $-\infty$，softmax 后接近 0，确保填充 token 不影响真实 token 的表示。

### 3.3 Segment IDs

对于单句分类任务，所有 token 的 segment ID 都为 0。对于句子对任务，句子 A 为 0，句子 B 为 1。

## 4. 模型构建

在预训练 BERT 之上添加一个简单的分类头：

```python
class BertForSentimentAnalysis(nn.Module):
    def __init__(self, pretrained_bert):
        super().__init__()
        self.bert = pretrained_bert          # 预训练 BERT 编码器
        self.classifier = nn.Linear(768, 2)  # 分类头: d → 2

    def forward(self, input_ids, attention_mask):
        # BERT 编码: (B, L) → (B, L, d)
        outputs = self.bert(input_ids, attention_mask)

        # 取 [CLS] token 的表示: (B, d)
        cls_output = outputs[:, 0, :]

        # 分类: (B, d) → (B, 2)
        logits = self.classifier(cls_output)

        return logits
```

关键设计：**仅使用 `[CLS]` token 的最后一层隐藏状态**。`[CLS]` 在预训练阶段被训练为聚合整个序列信息的表示，因此在微调时自然成为句子级分类的最佳特征。

:::tip[为什么用 [CLS] 而不是对所有 token 取平均？]

BERT 预训练时，`[CLS]` 被 NSP 任务强制要求编码句子对的语义关系信息。经过充分预训练后，`[CLS]` 的表示已经包含了整个序列的聚合信息——它通过 self-attention 关注了所有 token，并学会了如何整合它们。

对所有 token 表示取平均也是可行的（ALBERT 就采用了这种策略），但 `[CLS]` 在预训练中有专门的设计，通常效果更好。
:::

## 5. 训练策略

### 5.1 损失函数

二分类交叉熵损失：

$$
\mathcal{L} = -\frac{1}{B} \sum_{i=1}^{B} \left[ y_i \log \hat{y}_i + (1 - y_i) \log (1 - \hat{y}_i) \right]
$$

其中 $\hat{y}_i = \operatorname{softmax}(\text{logits}_i)$ 是模型预测为正类的概率。

### 5.2 优化器与学习率

BERT 微调通常使用 AdamW 优化器，采用**分层学习率**策略：

- **BERT 层**：较小的学习率（$2 \times 10^{-5}$），因为预训练权重已经很好，只需小幅调整
- **分类头**：较大的学习率（$1 \times 10^{-4}$），因为它是随机初始化的，需要快速收敛

:::tip[分层学习率的直觉]

想象你在调一辆已经调好音的钢琴（BERT 预训练权重）。你只需要微调几个键（低学习率），而不是重新调整架钢琴。但分类头是一把全新的吉他（随机初始化），需要大幅调音（高学习率）。

这与 minimind 的 SFT 训练有相似之处——预训练权重只需要小幅调整来适应指令格式，而不是重新学习语言。
:::

### 5.3 学习率调度

使用线性预热 + 线性衰减：

```
lr
 │
 │     ╱‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾╲
 │    ╱                        ╲
 │   ╱                          ╲
 │  ╱                            ╲
 │ ╱                              ╲
 └──────────────────────────────────→ steps
    warmup          main           decay
```

- **预热阶段**（前 10% 步）：学习率从 0 线性增加到目标值，防止训练初期梯度不稳定
- **主训练阶段**：保持目标学习率
- **衰减阶段**：学习率线性衰减到 0，帮助模型收敛到更优的局部最小值

```python
def get_linear_schedule(optimizer, num_warmup_steps, num_training_steps):
    def lr_lambda(current_step):
        if current_step < num_warmup_steps:
            return float(current_step) / float(max(1, num_warmup_steps))
        return max(0.0, float(num_training_steps - current_step) /
                   float(max(1, num_training_steps - num_warmup_steps)))
    return LambdaLR(optimizer, lr_lambda)
```

### 5.4 超参数建议

| 超参数 | 推荐值 | 说明 |
|:---|:---|:---|
| 批次大小 | 16 或 32 | 取决于 GPU 显存 |
| 学习率（BERT 层） | $2 \times 10^{-5}$ 到 $5 \times 10^{-5}$ | 过大容易破坏预训练知识 |
| 训练轮数 | 2-4 | BERT 微调很快收敛，过多轮次容易过拟合 |
| 最大序列长度 | 128 或 256 | 较短的序列训练更快，且对大多数影评足够 |
| 预热步数 | 总步数的 10% | 稳定训练初期 |

## 6. 评估与迭代

### 6.1 评估指标

对于情感分析（二分类，类别均衡），使用**准确率**（Accuracy）：

$$
\text{Accuracy} = \frac{\text{TP} + \text{TN}}{\text{TP} + \text{TN} + \text{FP} + \text{FN}}
$$

对于不平衡数据集，应使用 F1 分数或 AUC-ROC。

### 6.2 常见问题与对策

| 问题 | 症状 | 对策 |
|:---|:---|:---|
| 过拟合 | 训练准确率 >> 验证准确率 | 降低学习率、增加 dropout、减少训练轮数 |
| 欠拟合 | 训练准确率本身很低 | 增加学习率、增加训练轮数、更大的模型 |
| 灾难性遗忘 | 微调后模型在通用语言任务上表现下降 | 降低学习率、混合预训练数据（多任务学习） |
| 长文本截断 | 影评超过 512 token 被截断，丢失关键信息 | 使用层次化模型（如将长文本分段编码后聚合） |

:::tip[灾难性遗忘与 SFT]

灾难性遗忘在 BERT 微调中相对轻微（因为 BERT 参数量小，微调时间短），但在 LLM 的 SFT 阶段是一个重要问题。这与我们之前在 [BERT 预训练](/posts/nlp/03-bert-pretrain/) 中讨论的预训练-微调不匹配有关。

在 minimind 的 SFT 中，我们也会看到类似的问题：模型在微调后可能会"忘记"预训练阶段学到的一些知识。解决策略包括：混合预训练数据、使用较小的学习率、以及 LoRA 等参数高效微调方法。
:::

## 7. 与 minimind SFT 的对比

BERT 微调情感分析 与 minimind 的 SFT（Supervised Fine-Tuning）本质上是同一个范式：

| 步骤 | BERT 微调 | minimind SFT |
|:---|:---|:---|
| 输入 | 影评文本 | 多轮对话 |
| 输出 | 正面/负面（二分类） | 下一个 token（自回归生成） |
| `[CLS]` 表示 | 用于分类 | 不使用（decoder-only 架构） |
| 损失 | 交叉熵（分类） | 交叉熵（语言模型） |
| 优化器 | AdamW | AdamW |
| 学习率 | $2 \times 10^{-5}$ | $5 \times 10^{-5}$（典型） |
| 训练轮数 | 2-4 | 1-3（minimind 小模型） |

核心区别在于：BERT 是 **encoder-only** 架构（双向注意力），适合理解任务；minimind 是 **decoder-only** 架构（因果注意力），适合生成任务。但"预训练 + 微调"的范式完全一致。

## 参考文献

- Devlin, J., et al. (2019). BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding. *NAACL 2019*.
- Sun, C., et al. (2019). How to Fine-Tune BERT for Text Classification? *arXiv:1905.05583*.
- Howard, J., & Ruder, S. (2018). Universal Language Model Fine-tuning for Text Classification. *ACL 2018*.