---
title: 'BERT 微调实践：情感分析'
published: 2026-10-20
description: '以 IMDb 影评情感分析为例，梳理 BERT 微调的数据处理、模型结构、训练策略、评估与常见问题'
image: ''
tags: [NLP, BERT, Fine-tuning, Sentiment-Analysis]
category: '09-自然语言处理'
order: 609
draft: false
lang: ''
---

## 微调的本质

[BERT](/posts/nlp/06-07-bert/) 在预训练阶段学到了通用语言表示。微调是在预训练权重 $\theta_{\text{BERT}}$ 的基础上，用少量标注数据同时更新编码器和任务特定层 $\theta_{\text{task}}$：

$$
\theta^* = \arg\min_{\theta_{\text{BERT}}, \theta_{\text{task}}}
\frac{1}{N}\sum_{i=1}^{N}
\mathcal{L}\big(f(\mathbf{x}_i; \theta_{\text{BERT}}, \theta_{\text{task}}), y_i\big)
$$

与从零训练相比，微调需要的数据和算力都少得多：

| 方面 | 从零训练 | BERT 微调 |
|---|---|---|
| 数据需求 | 百万级标注样本 | 几千到几万条 |
| 训练时间 | 数天到数周 | 单卡数小时 |
| 泛化能力 | 小数据上容易过拟合 | 预训练提供通用语言知识 |

## 任务与数据

以 IMDb 影评情感分析为例，任务是把影评分类为正面或负面。数据集包含 25,000 条训练样本和 25,000 条测试样本，类别均衡。

### Tokenization

使用 BERT 的 [WordPiece](/posts/nlp/06-04-subword-tokenization/) 分词器：

```python
text = "This movie is fantastic!"
tokens = ["[CLS]", "this", "movie", "is", "fantastic", "##!", "[SEP]"]
input_ids = [101, 2023, 3185, 2003, 10392, 999, 102]
```

`##!` 表示它是前一个 token 的延续；`[CLS]` 和 `[SEP]` 是 BERT 的特殊标记。

### 截断、填充与掩码

BERT 的最大输入长度为 512。长影评需要截断，短影评用 `[PAD]`（ID 0）填充到统一长度。常见截断策略是保留开头和结尾，因为影评的关键情感信息常出现在这两处。

同时生成 attention mask：真实 token 为 1，填充 token 为 0。self-attention 计算时把填充位置的权重置为 $-\infty$，softmax 后接近 0，避免它们影响真实 token 的表示。

单句分类任务中所有 token 的 segment ID 都为 0；句子对任务中句子 A 为 0、句子 B 为 1。

## 模型结构

在预训练 BERT 之上加一个线性分类头：

```python
class BertForSentimentAnalysis(nn.Module):
    def __init__(self, pretrained_bert):
        super().__init__()
        self.bert = pretrained_bert
        self.classifier = nn.Linear(768, 2)

    def forward(self, input_ids, attention_mask):
        outputs = self.bert(input_ids, attention_mask=attention_mask)
        cls_output = outputs.last_hidden_state[:, 0, :]
        return self.classifier(cls_output)
```

关键是取 `[CLS]` 的最后一层隐藏状态作为句子表示。`[CLS]` 通过 self-attention 聚合整个序列，预训练中的 NSP 又要求它编码句对关系，因此适合做句子级分类。对所有 token 取平均也可行，ALBERT 就采用了平均池化，但 `[CLS]` 是 BERT 的原始设计。

## 训练策略

### 损失函数

二分类交叉熵：

$$
\mathcal{L} =
-\frac{1}{B}\sum_{i=1}^{B}
\left[y_i \log \hat{y}_i + (1-y_i)\log(1-\hat{y}_i)\right]
$$

其中 $\hat{y}_i$ 是模型预测为正类的概率。

### 优化器与分层学习率

通常使用 AdamW，并给不同部分设置不同学习率：

- **BERT 编码器**：$2\times10^{-5}$ 到 $5\times10^{-5}$，预训练权重只需小幅调整；
- **分类头**：约 $1\times10^{-4}$，它是随机初始化的，需要更快收敛。

学习率调度一般采用线性预热加线性衰减：前 10% 的步数从 0 线性增加到目标值，随后逐渐衰减到 0。预热可以避免训练初期梯度不稳定。

```python
def get_linear_schedule(optimizer, num_warmup_steps, num_training_steps):
    def lr_lambda(step):
        if step < num_warmup_steps:
            return float(step) / float(max(1, num_warmup_steps))
        return max(0.0,
                   float(num_training_steps - step) /
                   float(max(1, num_training_steps - num_warmup_steps)))
    return LambdaLR(optimizer, lr_lambda)
```

### 超参数

| 超参数 | 常用取值 | 说明 |
|---|---|---|
| 批次大小 | 16 或 32 | 取决于显存 |
| BERT 学习率 | $2\times10^{-5}$–$5\times10^{-5}$ | 过大会破坏预训练知识 |
| 训练轮数 | 2–4 | 过多容易过拟合 |
| 最大序列长度 | 128 或 256 | 影评任务通常够用，训练更快 |
| 预热比例 | 总步数的 10% | 稳定训练初期 |

## 评估与常见问题

类别均衡时用准确率；类别不平衡时用宏平均 F1 或 AUC，指标定义见 [NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)。

| 问题 | 症状 | 对策 |
|---|---|---|
| 过拟合 | 训练准确率远高于验证准确率 | 降低学习率、增加 dropout、减少轮数 |
| 欠拟合 | 训练准确率本身很低 | 提高学习率、增加轮数或模型容量 |
| 灾难性遗忘 | 微调后通用语言能力下降 | 降低学习率、混合预训练数据 |
| 长文本截断 | 超过 512 token 的信息丢失 | 分段编码后聚合，或使用长上下文模型 |

## 与 LLM 的 SFT 区分

BERT 微调是**任务特定微调**：一个任务一个分类头，输入是单句或句对，输出是类别或跨度。大语言模型的 SFT 通常指**指令微调**：输入是“指令 + 上下文”，输出是目标文本，用自回归交叉熵训练，一个模型可以适配多种任务。

两者共享“预训练 + 有监督微调”的思路，但架构、输出形式和任务组织方式不同。LLM SFT 的具体流程见 [LLM 有监督微调](/posts/nlp/08-01-llm-sft/)。

## 相关阅读

- BERT 的结构与预训练任务：[BERT](/posts/nlp/06-07-bert/)
- WordPiece 分词：[子词分词](/posts/nlp/06-04-subword-tokenization/)
- 大模型的指令微调：[LLM 有监督微调](/posts/nlp/08-01-llm-sft/)
- 参数高效微调：[LoRA 与 QLoRA](/posts/nlp/08-02-peft-lora/)
- 分类指标：[NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)
