---
title: 'MiniMind 数据侧：Tokenizer 与三阶段数据处理'
published: 2026-09-06
description: '从 6400 词表的构成讲起，再分别拆解 Pre-training、SFT、DPO 三个阶段如何把原始 jsonl 变成模型可以吃下的张量'
image: ''
tags: [minimind, LLM, Tokenizer, Pre-training, SFT, DPO]
category: '10-MiniMind项目'
order: 0.5
draft: false
lang: ''
---

:::tip[本文定位]

进入模型内部之前，先把「输入」这一侧讲清楚。模型看到的永远只是整数矩阵，
所有的语义、对话结构、偏好信息，都是在数据处理阶段被编码进 token id 和
mask 里的。

主要对应两个文件：

- `trainer/train_tokenizer.py`：词表训练
- `dataset/lm_dataset.py`：三个阶段的 Dataset 实现

后续的模型前向传播见[从 Token IDs 到训练 Loss](/posts/minimind/01-model-forward-pass/)。

:::

## 第一部分：Tokenizer

Tokenizer 是三个阶段共用的，所以先单独讲。它的设计会一路影响到参数量、
显存和评测指标的可比性。

### 6400 是怎么凑出来的

`train_tokenizer.py` 里的 `vocab_size=6400` 是**总预算**，不是「学 6400 个词」。
拆开 `tokenizer.json` 数一遍，正好对得上：

```text
    36  特殊 token（id 0~35，预留槽位）
+  256  ByteLevel 基础字节（initial_alphabet）
+ 6108  BPE 合并规则产生的 token
────────
  6400
```

特殊 token 和 256 个字节先占位，剩下的额度才留给 BPE 去学合并。

那 36 个槽位里真正在用的只有几个：

| id | token | 用途 |
| --- | --- | --- |
| 0 | `<\|endoftext\|>` | pad / unk |
| 1 | `<\|im_start\|>` | bos，对话角色起始 |
| 2 | `<\|im_end\|>` | eos，对话轮次结束 |
| 21 / 22 | `<tool_call>` / `</tool_call>` | 工具调用 |
| 25 / 26 | `<think>` / `</think>` | 思考块 |

剩下的 `<\|buffer1~9\|>` 是空占位，留着以后加新功能时不必改词表大小；
`<\|vision_start\|>`、`<tts_pad>` 这些是照抄 Qwen 体系预留的，这个模型用不上。

### ByteLevel BPE：为什么永远不会有 UNK

预分词器是 `ByteLevel`，意思是文本先被打成 UTF-8 字节，再在字节序列上做 BPE：

```text
"你"  ─UTF-8→  E4 BD A0  ─映射→  3 个可见字符  ─BPE→  可能合并成 1 个 token
```

因为 256 个字节全在词表里，**任何输入都能被表示**，不存在 OOV。所以
`unk_token` 虽然被设成了 `<|endoftext|>`，实际永远不会被触发。

### 中文的实际切分粒度

统计词表里含中文的 token，按包含的汉字数分组：

```text
1 个汉字: 1297 个   ████████████████
2 个汉字: 1402 个   █████████████████
3 个汉字:  296 个   ███
4 个汉字:   97 个   █
5+ 个汉字:  25 个   ▏
```

二字词最多，`可以`、`一个`、`数据`、`技术`、`学习`、`用户` 这类高频词都学到了。
所以中文压缩率大致在 **1.5~2 个汉字 / token** 这个量级。

对比 Qwen 的 15 万词表，同样一句话 MiniMind 需要更多 token，意味着相同的
512 窗口装下的实际内容更少。

### 小词表带来的三个连锁影响

**① Embedding 只占 4.9M**

$$
6400 \times 768 = 4{,}915{,}200 \approx 4.9\text{M}
$$

只占 63.91M 总参数的 7.7%。如果换成 Llama 的 32000 词表：
$32000 \times 768 = 24.6\text{M}$，单独一个 Embedding 就顶 3 层 Transformer。

**小词表是 63.91M 这个总量能成立的前提之一**，省下的参数预算被让给了 8 层主干。
而且因为 `tie_word_embeddings=True`，Embedding 和 LM Head 共享同一份权重，
这 4.9M 只算一次。

**② perplexity 不能跨模型比较**

预训练最终 loss 2.2545，$e^{2.2545} \approx 9.5$，听起来是「平均从 10 个候选里选一个」。

但随机猜的基线是 $\log 6400 = 8.76$；如果词表是 32000，基线会变成 $10.37$。
**词表越小，均匀分布对应的 loss 上限越低，数值天然更好看。**

所以拿 2.2545 去和其他模型比是没有意义的。跨模型比较需要归一化到
bits-per-character 这类与词表无关的指标。

**③ 显存项**

LM Head 的输出形状是 $[B, T, V]$。预训练时 `batch_size=128`、$T=512$：

```text
128 × 512 × 6400 = 4.19 亿个元素

  bf16 存储:                        0.84 GB
  cross_entropy 内部升 float32:     1.68 GB
```

已经是 GB 量级了。如果词表换成 32000，同样配置直接变成 **4.2 GB / 8.4 GB**，
光 logits 就能把显存打爆。这也是大词表模型常用 chunked cross-entropy 或者
融合 kernel 的原因。

## 第二部分：Pre-training 数据

### 原始数据

`pretrain_t2t_mini.jsonl`，127 万行，每行一个独立 JSON：

```json
{"text": "鉴于甲方与乙方就房屋租赁事宜达成如下协议..."}
```

只有纯文本，没有任何标注。这就是预训练的全部输入 ——
**监督信号来自文本自身**，不需要人工标注。

### `PretrainDataset.__getitem__`

```python
tokens = tokenizer(str(sample['text']), add_special_tokens=False,
                   max_length=self.max_length - 2, truncation=True).input_ids
tokens = [bos_token_id] + tokens + [eos_token_id]
input_ids = tokens + [pad_token_id] * (self.max_length - len(tokens))

input_ids = torch.tensor(input_ids, dtype=torch.long)
labels = input_ids.clone()
labels[input_ids == pad_token_id] = -100
return input_ids, labels
```

假设 `max_seq_len=8`（真实是 512），文本分出 4 个 token：

```text
① 分词（不加特殊符）        [T1 T2 T3 T4]
                            截断上限 = 8-2 = 6，给 bos/eos 留位

② 包裹 bos/eos              [1  T1 T2 T3 T4  2]
                             ↑bos           ↑eos

③ 右侧 pad 到 8             [1  T1 T2 T3 T4  2  0  0]
                                                ↑  ↑ pad

④ labels = clone            [1  T1 T2 T3 T4  2  0  0]

⑤ pad 位置 → -100           [1  T1 T2 T3 T4  2 -100 -100]
```

两个细节：

- **bos 的作用**：它是第一个预测位置的输入。没有 bos，`T1` 就没有任何东西能预测它。
- **eos 是有效标签**（它是 2 不是 0，没被置 -100），所以模型会学「文本该在哪结束」。
  这是推理时能正常停止生成的前提。

### `labels = input_ids.clone()` 不是让模型抄输入

第一次读到这行几乎都会困惑：label 和 input 一模一样，模型学复制吗？

**错位不在数据侧，在模型内部**：

```python
x = logits[..., :-1, :]   # 丢掉最后一个位置的预测
y = labels[..., 1:]       # 标签整体左移一格
```

对齐后是这样：

```text
位置:        0    1    2    3    4    5    6    7
input_ids:  bos  T1   T2   T3   T4  eos  pad  pad
             │    │    │    │    │    │
             ▼    ▼    ▼    ▼    ▼    ▼
预测目标:    T1   T2   T3   T4  eos -100   ✗    ✗
                                       └─ 被 ignore_index 丢弃
                                  ✗ = 位置 7 无下一个 token，被 [:-1] 切掉
```

所以这 8 个位置里只有 **5 个**产生有效 loss。`ignore_index=-100` 会把 -100
从交叉熵的分子**和分母**里同时排除，不会因为大量 pad 而稀释掉平均 loss。

### 没有返回 attention_mask

预训练脚本调用模型时也没有传。这条路径仍然成立的原因：

```text
真实 token 因 causal mask 看不到右边的 pad        ✓
pad 位置能看到前文，但它的 label 是 -100，不进 loss  ✓
```

注意这只在**右侧 padding** 下成立。换成左侧 padding 就必须显式传 mask，
否则真实 token 会 attend 到前面的 pad。

### 没有做 sequence packing

每条样本是一个独立文档，短文本后面全是 pad：

```text
现在:     [doc_A .......... pad pad pad pad pad]   ← 算力浪费在 pad 上
packing:  [doc_A | doc_B | doc_C | doc_D ........]  ← 拼满 512，几乎无浪费
```

工业界预训练普遍会做 packing（把多篇文档拼到 512 塞满，用 document mask 隔开）。
MiniMind 为了代码可读性没有实现，这是一个真实存在的吞吐优化空间。

## 第三部分：SFT 数据

### Chat Template：先渲染成一个字符串

原始数据：

```json
{"conversations": [
  {"role": "user", "content": "猫可以吃巧克力吗？"},
  {"role": "assistant", "content": "不可以，巧克力对猫有毒。"}
]}
```

`apply_chat_template(tokenize=False)` 把它拼成**纯文本**
（注意 `tokenize=False`，这一步只做字符串拼接）：

```text
<|im_start|>system
你是minimind，一个小巧但有用的语言模型。<|im_end|>
<|im_start|>user
猫可以吃巧克力吗？<|im_end|>
<|im_start|>assistant
<think>

</think>

不可以，巧克力对猫有毒。<|im_end|>
```

### 两个数据增强

**`pre_processing_chat`** —— 如果原数据没有 system，以 **20% 概率**
随机插一条（从 10 条候选里抽）。作用是让模型对「有 / 没有 system prompt」
两种输入都鲁棒，不会因为部署时忘了传 system 就崩。

**`post_processing_chat`** —— 模板对 assistant 恒定插入
`<think>\n\n</think>\n\n`，这个函数以 **80% 概率**把空的 think 块删掉：

```python
if '<think>\n\n</think>\n\n' in prompt_content and random.random() > 0.2:
    prompt_content = prompt_content.replace('<think>\n\n</think>\n\n', '')
```

所以 80% 的样本没有 think 标签、20% 保留。这是给后续接推理模式留的接口，
模型两种格式都见过。

### `generate_labels`：双指针扫描

先看初始化的两个标记，这是理解全部逻辑的钥匙：

```python
self.bos_id = tokenizer(f'{tokenizer.bos_token}assistant\n',
                        add_special_tokens=False).input_ids   # <|im_start|>assistant\n
self.eos_id = tokenizer(f'{tokenizer.eos_token}\n',
                        add_special_tokens=False).input_ids   # <|im_end|>\n
```

**这里必须做子序列匹配，不能查单个 id** —— 查词表可以确认 `assistant`
这个字符串**不是**单个 token，会被 BPE 切成若干 subword 片段。所以
`bos_id` 是一个多 token 的序列；`eos_id` 则确定是 2 个：`<|im_end|>`=2 和 `\n`=234。

扫描过程（用 A1/A2/A3 代表 `assistant` 被切开的片段）：

```text
idx:      0    1    2    3    4    5    6    7    8    9   10   11
tok:      1   A1   A2   A3  234   C1   C2   C3    2  234    0    0
          └───── bos_id ──────┘   └─content─┘  └─eos─┘  └─pad─┘
                                  ↑            ↑
                              start=5       end=8

labels: -100 -100 -100 -100 -100   C1   C2   C3    2  234 -100 -100
                                   └──────── 还原成真实 id ────────┘
```

写入范围是 `for j in range(start, min(end + len(self.eos_id), self.max_length))`，
所以 **`<|im_end|>\n` 这两个 token 也在监督范围内** —— 模型因此学会
「回答完了要输出结束符」。这是推理时能正常停下来的直接原因。

### label 的下标和「谁来预测它」错了一位

`SFTDataset` 返回的 `labels` 与 `input_ids` **同下标对齐**，错位仍然在模型内部做
（`logits[..., :-1]` vs `labels[..., 1:]`）。展开看：

```text
输入位置:   4        5      6      7      8
            │        │      │      │      │
            ▼        ▼      ▼      ▼      ▼
预测目标:   C1       C2     C3      2     234
            ↑                              ↑
    marker 最后一个 token           学会输出 <|im_end|>
    （即 "\n"）负责预测第一个内容字
```

所以有效监督其实从 `start-1` 这个位置开始，那个位置的输入是 marker 的
最后一个 `\n`。这正是我们希望的行为：**看到 `<|im_start|>assistant\n`
就该开始生成回答**。

### 与预训练的对比

```text
Pre-training:  labels = clone(input)，只把 pad → -100
               ████████████████████░░░░   （几乎全部监督）

SFT:           labels 全置 -100，只把 assistant 区间还原
               ░░░░░░░░░░████████░░░░░░   （只有回复区间）
               system+user  回复  pad
```

一句话概括：**预训练学语言分布，SFT 学「在什么位置该说什么」**。
user 的提问只作为 context 参与前向和 attention，不产生梯度。

多轮对话也没问题 —— while 循环处理完一个 assistant 区间后
`i = end + len(self.eos_id)` 继续往后扫，所以**每一轮 assistant 回复都会被监督**。

### 一个边界缺陷

`__getitem__` 里是硬截断：

```python
input_ids = self.tokenizer(prompt).input_ids[:self.max_length]   # 512
```

如果一段长对话**在 assistant 回复中间被切断**，`eos_id` 就永远匹配不到。
此时 `end` 会一路走到 `len(input_ids)`，然后：

```python
for j in range(start, min(end + 2, max_length))   # → range(start, 512)
```

**截断后的残缺回复照样被全部监督，但没有结束符。**

```text
理想:  [...assistant\n  回答内容完整  <|im_end|>\n]
                                        ↑ 学会停

截断:  [...assistant\n  回答内容被切———]  ← 到 512 硬停，没有结束符
                        └─ 仍然全部计入 loss ─┘
```

后果是模型见过一批「话说到一半就没了」的样本，会轻微削弱它输出
`<|im_end|>` 的倾向。更稳妥的做法是：检测到 eos 缺失就丢弃这个区间的监督，
或者直接丢掉整条样本。

## 第四部分：DPO 数据

### 原始数据

`dpo.jsonl`，每行是**一对**回答：

```json
{
  "chosen":   [{"role": "user", "content": "猫能吃巧克力吗？"},
               {"role": "assistant", "content": "不可以，巧克力含可可碱，对猫有毒。"}],
  "rejected": [{"role": "user", "content": "猫能吃巧克力吗？"},
               {"role": "assistant", "content": "可以，少量没关系。"}]
}
```

**prompt 完全相同，只有 assistant 回复不同。** 这是偏好数据的定义 ——
它不告诉模型「正确答案是什么」，只告诉模型「这两个里哪个更好」。

### 与 SFT 的三处关键差异

**① mask 是 0/1，不是 -100**

`generate_loss_mask` 的扫描逻辑和 SFT 的 `generate_labels` 完全一样
（同样的双指针、同样的 marker），唯一区别是写入的值：

```python
# SFT:  labels[j] = input_ids[j]     → 交给 cross_entropy 的 ignore_index
# DPO:  loss_mask[j] = 1            → 自己动手做乘法
```

为什么不能用 -100？因为 DPO 需要的是**序列级**的 log 概率：

```python
ref_log_probs = (ref_log_probs * mask).sum(dim=1)
```

先逐 token 取 log prob，乘 mask 清零无关位置，再沿序列维**求和**。
`ignore_index` 只在 `F.cross_entropy` 里起作用，而这里根本没有调用它。

**② 错位在 dataset 里做，不在模型里**

```python
x_chosen = torch.tensor(chosen_input_ids[:-1], dtype=torch.long)
y_chosen = torch.tensor(chosen_input_ids[1:], dtype=torch.long)
mask_chosen = torch.tensor(chosen_loss_mask[1:], dtype=torch.long)
```

三个阶段对比：

```text
Pretrain / SFT:  dataset 返回等长的 (input_ids, labels)
                 → model(input_ids, labels=labels)
                 → 模型内部切 logits[..., :-1] 和 labels[..., 1:]

DPO:             dataset 直接返回错位好的 (x, y, mask)
                 → model(x)        ← 不传 labels！
                 → 只取 outputs.logits，自己算 log prob
```

所以 `max_seq_len=512` 时，x 和 y 的实际长度都是 **511**。

这个差异是有原因的：DPO 不使用交叉熵，传 labels 反而会让模型白算一遍
用不到的 loss。

**③ `batch_size=8` 实际是 16 条序列过模型**

```python
x = torch.cat([x_chosen, x_rejected], dim=0)   # [8,511] + [8,511] → [16,511]
```

chosen 和 rejected 沿 batch 维拼成一个大 batch，**一次前向**算完，再在
loss 函数里靠 `batch_size // 2` 切开：

```text
        ┌─────────── x [16, 511] ───────────┐
batch:   0  1  2  3  4  5  6  7 │ 8  9 ... 15
         └───── chosen (8) ─────┘ └ rejected (8) ┘
                    │                    │
                    ▼                    ▼
              π(y_c|x) 的 log       π(y_r|x) 的 log
                    └────── 相减 ────────┘
                          = pi_logratios
```

**这就是为什么 DPO 的 batch_size 只敢开 8**：显存里实际有 16 条序列，
而且还要同时驻留**两个模型**（策略 + reference），reference 还要跑一次前向。
相比 SFT 的 64，小了 8 倍。

### 完整数据流

```text
一行 jsonl
    │
    ├── chosen   → chat_template → tokenize → pad 到 512
    │                                  │
    │                                  ├── x_chosen    [511]
    │                                  ├── y_chosen    [511]
    │                                  └── mask_chosen [511]
    │
    └── rejected → chat_template → tokenize → pad 到 512
                                       │
                                       ├── x_rejected    [511]
                                       ├── y_rejected    [511]
                                       └── mask_rejected [511]

              collate 成 batch=8 后 cat → [16, 511]
```

### sum 而不是 mean 会引入长度偏置

```python
policy_log_probs = (policy_log_probs * mask).sum(dim=1)
```

log prob 每一项都是负数，所以**回答越长，序列 log prob 越小**。如果数据里
chosen 系统性地比 rejected 长（人类标注很常见的偏好：更详细 = 更好），
那么 `pi_logratios` 就带上了一个与内容质量无关的长度信号。

这是 DPO 的已知问题，后续工作用不同方式处理：

| 方法 | 聚合方式 | 备注 |
| --- | --- | --- |
| DPO（本实现） | `sum` | 存在长度偏置 |
| IPO | 改损失函数形式 | 缓解对偏好数据的过拟合 |
| SimPO | `mean`（长度归一化） | 并且去掉了 reference model |

### reference model 的开销

```python
with torch.no_grad():
    ref_outputs = ref_model(x)
    ref_logits = ref_outputs.logits
```

`no_grad` 省掉了梯度和激活值的存储，但**参数副本仍然占显存**
（63.91M × 2 bytes ≈ 128 MB，小模型无所谓），前向计算也实打实要跑一遍。

在真实规模下这是 DPO 的主要成本，所以工程上常见两种优化：

- 提前把 `ref_log_probs` 离线算好存盘，训练时直接读 ——
  reference 是冻结的，结果不会变；
- 用 LoRA 训练，推理时关掉 adapter 就是 reference，省掉一份参数。

同样，这里也**没有传 `attention_mask`**，依赖的仍然是
「右侧 padding + pad 位置 mask=0」这条链。

## 三阶段对照

| | Pre-training | SFT | DPO |
| --- | --- | --- | --- |
| 数据格式 | `{"text": ...}` | `{"conversations": [...]}` | chosen / rejected 对 |
| 监督范围 | 全部非 pad | assistant 区间 | assistant 区间 |
| 标记方式 | `-100` | `-100` | `0/1` mask |
| 错位位置 | 模型内 | 模型内 | dataset 内 |
| 聚合方式 | token 级平均 | token 级平均 | **序列级求和** |
| 一步几条序列 | 128 | 64 | **16**（8 × 2） |
| 损失函数 | 交叉熵 | 交叉熵 | $-\log\sigma(\beta \cdot \text{margin})$ |

三个阶段共用同一个 tokenizer、同一套特殊 token、同一个模型结构。真正的区别
全部落在**监督信号怎么标注、怎么聚合**这两件事上。

:::note[下一篇]

数据侧到这里闭环。接下来进入模型内部：
[从 Token IDs 到训练 Loss](/posts/minimind/01-model-forward-pass/)。

:::
