---
title: 'MiniMind 训练实战：从预训练到偏好对齐的全流程记录'
published: 2026-07-20
description: '在 A100-80GB 上完成 MiniMind 的三阶段训练（Pre-training → SFT → DPO），详细记录每阶段的参数配置、训练日志、loss 曲线与权重文件'
image: ''
tags: [minimind, LLM, Pre-training, SFT, DPO, 训练实战]
category: '10-MiniMind项目'
order: 3
draft: false
lang: ''
---

:::tip[本文定位]

前面的[代码导读（一）](/posts/minimind/01-model-forward-pass/)和[代码导读（二）](/posts/minimind/02-attention-forward-pass/)已经逐行解析了 MiniMind 的模型结构与前向传播逻辑。本文记录一次完整的端到端训练实践：从环境搭建、数据集下载，到在 A100 上依次完成 Pre-training、SFT、DPO 三个阶段，最终产出可用的对话模型权重。

:::

## 1. 训练环境

| 项目    | 配置                      |
| ------- | ------------------------- |
| GPU     | NVIDIA A100-SXM4-80GB × 1 |
| CUDA    | 12.8                      |
| Driver  | 570.133.20                |
| Python  | 3.12                      |
| PyTorch | 2.x                       |


## 1.2 项目整体结构

MiniMind 的学习主线可以压缩为下面这条数据和参数流：

```text
原始文本/对话/偏好数据
        │
        ▼
dataset/lm_dataset.py
        │  tokenization + padding + loss mask
        ▼
model/model_minimind.py
        │  Embedding → Decoder Blocks → LM Head
        ▼
trainer/train_pretrain.py
        │
        ├── Pre-training：学习下一个 Token
        ▼
trainer/train_full_sft.py
        │
        ├── SFT：只对 assistant 回复计算损失
        ▼
trainer/train_dpo.py
        │
        └── DPO：提高 chosen 相对 rejected 的概率
```

这条链路中，模型结构基本保持不变，变化主要发生在数据格式、监督信号和训练目标上。因此阅读项目时，不能只看 `model_minimind.py`，还需要把 dataset、trainer 和 checkpoint 逻辑连起来。

## 2. 模型架构

本次训练使用 MiniMind 默认配置，未启用 MoE：

| 参数                | 值          |
| ------------------- | ----------- |
| `hidden_size`       | 768         |
| `num_hidden_layers` | 8           |
| `use_moe`           | 0           |
| 总参数量            | **63.91M**  |
| 可训练参数量        | **63.912M** |

这是一个 8 层 Decoder-only Transformer，约 6400 万参数，属于极轻量级 LLM。对比 GPT-2 Small（124M 参数）小约一半，适合教学和快速实验。

## 3. 第一阶段：Pre-training（预训练）

### 3.1 目标

标准自回归语言建模（Causal LM）：给定前文 token 序列，预测下一个 token，使用交叉熵损失。

数据格式：每行一条纯文本 `{"text": "一段中文文本..."}`。

### 3.2 训练参数

```bash
python train_pretrain.py \
  --batch_size 128 \
  --max_seq_len 512 \
  --num_workers 0 \
  --epochs 1 \
  --data_path ../dataset/pretrain_t2t_mini.jsonl
```

| 参数                 | 值                        | 说明                        |
| -------------------- | ------------------------- | --------------------------- |
| `batch_size`         | 128                       | 每步处理 128 条样本         |
| `max_seq_len`        | 512                       | 每条序列最多 512 token      |
| `epochs`             | 1                         | 训练 1 轮                   |
| `learning_rate`      | 5e-4                      | 余弦退火，峰值 5e-4         |
| `accumulation_steps` | 8                         | 梯度累积（等效 batch=1024） |
| `dtype`              | bfloat16                  | 混合精度训练                |
| 数据集               | `pretrain_t2t_mini.jsonl` | 127 万条中文文本，约 1.2GB  |

### 3.3 训练日志

训练共 9924 步，耗时约 55 分钟。Loss 从初始的 7.2 持续下降至 2.25：

| Step | Loss   | ETA    |
| ---- | ------ | ------ |
| 100  | 7.2061 | 57 min |
| 500  | 5.8286 | 54 min |
| 1000 | 4.3968 | 51 min |
| 2000 | 3.2656 | 45 min |
| 3000 | 2.7209 | 40 min |
| 4000 | 2.5131 | 34 min |
| 5000 | 2.3837 | 28 min |
| 6000 | 2.3750 | 22 min |
| 7000 | 2.3283 | 16 min |
| 8000 | 2.2877 | 11 min |
| 9000 | 2.3555 | 5 min  |
| 9924 | 2.2545 | 0 min  |

Loss 下降趋势平滑，说明模型在有效学习中文语言的统计规律。最终 loss 2.25 意味着模型对每个 token 的平均困惑度（perplexity）约为 $e^{2.25} \approx 9.5$，即平均从约 10 个候选词中选一个。

### 3.4 输出

```
out/pretrain_768.pth  (132MB, 68.83M 参数)
```

## 4. 第二阶段：SFT（监督微调）

### 4.1 目标

在预训练权重基础上，用对话数据（问答对）进行监督微调。核心区别：仅对 assistant 回复部分计算损失，忽略 user 和 system 部分。这样模型学会的是「如何回答」而非「如何提问」。

数据格式：每行一组对话 `{"conversations": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}`。

### 4.2 训练参数

```bash
python train_full_sft.py \
  --batch_size 64 \
  --max_seq_len 512 \
  --num_workers 0 \
  --epochs 1 \
  --from_weight pretrain \
  --data_path ../dataset/sft_t2t_mini.jsonl
```

| 参数            | 值                   | 说明                                |
| --------------- | -------------------- | ----------------------------------- |
| `batch_size`    | 64                   | 每步 64 条对话                      |
| `max_seq_len`   | 512                  | 序列长度同预训练                    |
| `learning_rate` | 1e-5                 | 远低于预训练的 5e-4，防止灾难性遗忘 |
| `from_weight`   | pretrain             | 基于预训练权重初始化                |
| 数据集          | `sft_t2t_mini.jsonl` | 对话数据，约 1.6GB                  |

### 4.3 关键机制

SFT 与预训练的核心区别在于 **损失掩码（Loss Mask）**：

```python
# SFTDataset.generate_labels() 的逻辑：
# 1. 初始所有位置 label = -100（PyTorch 交叉熵忽略）
# 2. 扫描 token 序列，找到 "assistant\n" 标记
# 3. 找到对应的 "<eos>\n" 标记
# 4. 将两者之间的 token 标记为真实 token ID（参与损失计算）
```

这样确保模型只学习生成 assistant 的回复内容，不学习 user 的提问。

### 4.4 输出

```
out/full_sft_768.pth  (132MB, 68.83M 参数)
```

## 5. 第三阶段：DPO（偏好优化）

### 5.1 目标

在 SFT 模型基础上，利用人类偏好数据（chosen vs rejected 对比）进行偏好对齐。DPO 的核心思想是：让模型对「好回答」的概率高于「差回答」，同时用参考模型（冻结的 SFT 模型）作为锚点，防止策略模型偏离太远。

### 5.2 DPO 损失函数

DPO 损失公式为：

$$
\mathcal{L}_{\text{DPO}} = -\log \sigma \left( \beta \cdot \left[ \log \frac{\pi_\theta(y_c|x)}{\pi_\theta(y_r|x)} - \log \frac{\pi_{\text{ref}}(y_c|x)}{\pi_{\text{ref}}(y_r|x)} \right] \right)
$$

其中：

- $\pi_\theta$：策略模型（可训练）
- $\pi_{\text{ref}}$：参考模型（冻结的 SFT 模型）
- $y_c$：chosen 回复（好回答）
- $y_r$：rejected 回复（差回答）
- $\beta$：温度参数，控制偏离参考模型的惩罚力度
- $\sigma$：sigmoid 函数

直觉理解：当策略模型对 chosen 的偏好与参考模型一致时，$\log \frac{\pi_\theta(y_c)}{\pi_\theta(y_r)} - \log \frac{\pi_{\text{ref}}(y_c)}{\pi_{\text{ref}}(y_r)} > 0$，sigmoid 接近 1，loss 接近 0；当策略模型开始偏好 rejected 时，该项为负，sigmoid 接近 0，loss 迅速增大。

### 5.3 训练参数

```bash
python train_dpo.py \
  --batch_size 8 \
  --max_seq_len 512 \
  --num_workers 0 \
  --epochs 1 \
  --beta 0.15 \
  --from_weight full_sft \
  --data_path ../dataset/dpo.jsonl
```

| 参数            | 值          | 说明                                        |
| --------------- | ----------- | ------------------------------------------- |
| `batch_size`    | 8           | DPO 每步同时处理 chosen + rejected 两份数据 |
| `learning_rate` | 4e-8        | 极低学习率，避免灾难性遗忘                  |
| `beta`          | 0.15        | DPO 温度参数                                |
| `from_weight`   | full_sft    | 策略模型和参考模型都基于 SFT 权重           |
| 数据集          | `dpo.jsonl` | 偏好对比数据，约 53MB                       |

### 5.4 关键机制

DPO 与 SFT 的关键区别：

1. **双模型架构**：同时加载策略模型（可训练）和参考模型（冻结），参考模型提供「锚点」
2. **数据格式**：每条数据包含 chosen（好回答）和 rejected（差回答）两套对话
3. **损失计算**：不是交叉熵，而是 sigmoid-based 的偏好对比损失
4. **梯度只更新策略模型**：参考模型完全不参与梯度计算

### 5.5 输出

```
out/dpo_768.pth  (132MB, 68.83M 参数)
```

## 6. 权重文件汇总

| 文件               | 阶段     | 大小  | 参数量 |
| ------------------ | -------- | ----- | ------ |
| `pretrain_768.pth` | 预训练   | 132MB | 68.83M |
| `full_sft_768.pth` | 监督微调 | 132MB | 68.83M |
| `dpo_768.pth`      | 偏好优化 | 132MB | 68.83M |

三个文件大小完全相同，因为模型结构未变，只是参数值不同。文件以 half 精度（float16）存储，每个参数占 2 字节，$68.83 \times 10^6 \times 2 \text{ bytes} \approx 132 \text{ MB}$。

## 7. 训练耗时对比

| 阶段         | 步数  | A100 耗时   | 笔记本 RTX 4060 预估 |
| ------------ | ----- | ----------- | -------------------- |
| Pre-training | 9924  | ~55 min     | ~4.5 h               |
| SFT          | ~9930 | ~15 min     | ~1.5 h               |
| DPO          | ~1850 | ~5 min      | ~30 min              |
| **总计**     |       | **~75 min** | **~6.5 h**           |

A100 相比笔记本 RTX 4060 加速约 5-6 倍，主要得益于更大的显存带宽和更高的计算吞吐量。

## 8. 本地推理测试

将权重文件下载到本地后，即可进行推理测试：

```bash
# 测试 SFT 模型
python eval_llm.py --weight full_sft

# 测试 DPO 模型
python eval_llm.py --weight dpo

# 测试预训练模型（纯文本补全，无对话能力）
python eval_llm.py --weight pretrain
```

## 9. 小结

本次训练在 A100-80GB 上完成了 MiniMind 三阶段全流程，总耗时约 75 分钟，产出了三个阶段的权重文件。关键经验：

1. **预训练 loss 下降是有效的信号**：从 7.2 降到 2.25，说明模型确实在学习中文语言规律
2. **SFT 学习率要大幅降低**：从 5e-4 降到 1e-5，否则会覆盖预训练学到的知识
3. **DPO 学习率要更低**：4e-8，同时 beta=0.15 提供适度的约束
4. **A100 单卡跑 64M 模型绰绰有余**：可以轻松跑更大的模型（如 200M-400M 参数）
5. **DSW 平台注意路径长度限制**：`num_workers` 需要设为 0，否则 Unix socket 路径超长导致报错

后续可以尝试的方向：增大模型参数（hidden_size=2048, num_layers=16）、使用完整数据集（非 mini 版）、增加 MoE 架构、或接入 RL 训练（PPO/GRPO）。

| 阶段         | 输入                   | 优化目标              | 得到的能力                       |
| ------------ | ---------------------- | --------------------- | -------------------------------- |
| Pre-training | 纯文本                 | 预测下一个 Token      | 学习语言和知识的统计结构         |
| SFT          | 多轮对话               | 只拟合 assistant 回复 | 学习回答格式、角色边界和指令跟随 |
| DPO          | chosen/rejected 偏好对 | 增大偏好回答相对概率  | 在参考模型约束下调整回答偏好     |

因此，Pre-training loss 下降并不等于模型已经会对话，SFT loss 下降也不等于回答质量一定提高。每个阶段都需要使用与目标能力匹配的评测和样例进行验证。

1. **损失掩码决定监督信号的位置**：SFT 不是简单把预训练数据换成对话数据，而是要确保 user/system token 不参与损失。
2. **DPO 需要同时读取 policy 和 reference 的 token-level log probability**：chosen/rejected 的比较必须在相同 prompt 和有效回复区域上完成。
3. **梯度累积改变的是有效 batch size，不会自动降低单步显存**：它可以缓解显存压力，但会增加更新前的计算和等待。
4. **混合精度需要和数值稳定性一起考虑**：RMSNorm、Softmax、log probability 等位置不能只追求 dtype 更低。
5. **checkpoint 不是单纯保存模型参数**：可复现的训练还需要保存 optimizer、scheduler、step、随机状态和配置。
