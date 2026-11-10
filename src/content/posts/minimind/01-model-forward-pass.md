---
title: 'MiniMind 代码导读（一）：从 Token IDs 到训练 Loss'
published: 2026-07-20
description: '沿着 MiniMind 的一次前向传播，将模型配置、Embedding、Decoder Block、LM Head 与错位交叉熵逐段翻译为数学公式和张量形状'
image: ''
tags: [minimind, LLM, Pre-training]
category: '10-MiniMind项目'
order: 1
draft: false
lang: ''
---

:::tip[本文定位]

前面的[自回归语言模型](/posts/nlp/06-autoregressive-language-model/)建立了 Next-Token Prediction 的概率目标，[Decoder-only Transformer](/posts/transformer/decoder-only-transformer/)和[现代 LLM 组件](/posts/transformer/modern-llm-components/)建立了模型结构。

本文开始阅读 MiniMind 源码，沿着一次训练前向传播，建立三者之间的对应：

```text
代码语句 ↔ 数学运算 ↔ 张量形状
```

本文主要对应三个文件：

- `model/model_minimind.py`：模型结构与 Loss；
- `dataset/lm_dataset.py`：预训练样本与标签；
- `trainer/train_pretrain.py`：模型调用入口。

Attention 内部的 Q/K/V 投影、RoPE、GQA、Causal Mask、Flash Attention 和 KV Cache 暂时视为一个整体，留到下一篇单独展开。

:::

## 1. 一次训练前向传播的调用链

预训练循环中真正启动模型计算的是下面两行：

```python
# trainer/train_pretrain.py
res = model(input_ids, labels=labels)
loss = res.loss + res.aux_loss
```

这里的 `model` 是 `MiniMindForCausalLM`，不是仅包含 Transformer 主干的 `MiniMindModel`。一次调用会依次经过：

```text
MiniMindForCausalLM.forward
└── MiniMindModel.forward
    ├── Token Embedding
    ├── MiniMindBlock.forward × L
    └── Final RMSNorm
└── LM Head
└── Shifted Cross Entropy
```

用一个函数概括，就是：

$$
(Z,\mathcal{L})=f_\theta(I,Y)
$$

$I$ 是输入 Token ID，$Y$ 是训练标签，$Z$ 是词表 logits，$\mathcal{L}$ 是训练损失，$\theta$ 表示 Embedding、Attention、FFN、Norm 和 LM Head 中的全部可训练参数。

本文统一使用以下符号：

| 符号     | 代码参数或含义                          |
| -------- | --------------------------------------- |
| $B$      | Batch Size 多少行样本                   |
| $T$      | Sequence Length  每条样本有多少个 token |
| $V$      | `vocab_size`，词表大小                  |
| $d$      | `hidden_size`，隐藏维度                 |
| $L$      | `num_hidden_layers`，Decoder Block 数量 |
| $h_q$    | `num_attention_heads`，Query 头数       |
| $h_{kv}$ | `num_key_value_heads`，Key/Value 头数   |
| $d_h$    | `head_dim`，每个注意力头的维度          |
| $m$      | `intermediate_size`，FFN 中间维度       |

## 2. MiniMindConfig 将架构选择变成具体维度

模型配置中的核心代码可以压缩成：

```python
class MiniMindConfig(PretrainedConfig):
    def __init__(self, hidden_size=768, num_hidden_layers=8, **kwargs):
        self.hidden_size = hidden_size
        self.num_hidden_layers = num_hidden_layers
        self.vocab_size = kwargs.get("vocab_size", 6400)

        self.num_attention_heads = kwargs.get("num_attention_heads", 8)
        self.num_key_value_heads = kwargs.get("num_key_value_heads", 4)
        self.head_dim = kwargs.get(
            "head_dim", self.hidden_size // self.num_attention_heads
        )

        self.intermediate_size = kwargs.get(
            "intermediate_size",
            math.ceil(hidden_size * math.pi / 64) * 64
        )
        self.max_position_embeddings = kwargs.get(
            "max_position_embeddings", 32768
        )
```

`Config` 本身不处理输入张量。它的作用是确定模型中各参数矩阵的尺寸。默认配置对应：

| 参数                      | 默认值 | 数学含义                              |
| ------------------------- | ------ | ------------------------------------- |
| `vocab_size`              | 6400   | $V=6400$                              |
| `hidden_size`             | 768    | $d=768$                               |
| `num_hidden_layers`       | 8      | $L=8$                                 |
| `num_attention_heads`     | 8      | $h_q=8$                               |
| `num_key_value_heads`     | 4      | $h_{kv}=4$                            |
| `head_dim`                | 96     | $d_h=d/h_q=768/8$                     |
| `intermediate_size`       | 2432   | $m=64\left\lceil\pi d/64\right\rceil$ |
| `max_position_embeddings` | 32768  | RoPE 查找表最多预计算 32768 个位置    |

这里有两个容易忽略的比例。首先，Query 总维度为：

$$
h_qd_h=8\times96=768=d
$$

其次，GQA 中每组 K/V 需要服务的 Query 头数为：

$$
r=\frac{h_q}{h_{kv}}=\frac{8}{4}=2
$$

因此 MiniMind 默认有 8 个 Query 头、4 个 K/V 头，每个 K/V 头会对应 2 个 Query 头。`max_position_embeddings` 只决定 RoPE 缓冲区的可用位置范围，并不表示每条训练样本一定长达 32768 个 Token；训练脚本仍可以使用更短的 `max_seq_len`。

## 3. 模型初始化对应参数化函数的组成

`MiniMindModel.__init__` 创建 Transformer 主干：

```python
class MiniMindModel(nn.Module):
    def __init__(self, config):
        self.embed_tokens = nn.Embedding(
            config.vocab_size,
            config.hidden_size
        )
        self.dropout = nn.Dropout(config.dropout)
        self.layers = nn.ModuleList([
            MiniMindBlock(l, config)
            for l in range(config.num_hidden_layers)
        ])
        self.norm = RMSNorm(
            config.hidden_size,
            eps=config.rms_norm_eps
        )
```

它对应四组数学对象：

$$
E\in\mathbb{R}^{V\times d}
$$

$$
\operatorname{Block}_\ell:
\mathbb{R}^{B\times T\times d}
\rightarrow
\mathbb{R}^{B\times T\times d},
\qquad \ell=0,1,\ldots,L-1
$$

$$
\gamma_{\mathrm{final}}\in\mathbb{R}^{d}
$$

其中 $E$ 是 Embedding 矩阵，每个 `MiniMindBlock` 是一个保持隐藏状态形状不变的函数，$\gamma_{\mathrm{final}}$ 是最终 RMSNorm 的可训练缩放参数。

`ModuleList` 只是把 $L$ 个 Block 注册为模型子模块，并不会在初始化阶段执行它们。真正的复合运算发生在 `forward` 的循环中。

`MiniMindForCausalLM` 在主干之后增加 LM Head：

```python
class MiniMindForCausalLM(PreTrainedModel, GenerationMixin):
    def __init__(self, config=None):
        self.model = MiniMindModel(self.config)
        self.lm_head = nn.Linear(
            self.config.hidden_size,
            self.config.vocab_size,
            bias=False
        )

        if self.config.tie_word_embeddings:
            self.model.embed_tokens.weight = self.lm_head.weight
```

LM Head 的权重形状为：

$$
W_{\mathrm{lm}}\in\mathbb{R}^{V\times d}
$$

当 `tie_word_embeddings=True` 时：

$$
W_{\mathrm{lm}}=E
$$

这不是复制一份数值相同的矩阵，而是让输入 Embedding 和输出 LM Head 引用同一个可训练参数。输入端用它按 Token ID 查行，输出端则执行矩阵乘法：

$$
z_{b,t}=h_{b,t}E^\top
$$

权重共享将两块原本各自需要 $Vd$ 个参数的矩阵合并为一块，但“查表”和“输出分类”仍然是两种不同运算。

### 共享为什么合理

把 LM Head 的计算按分量展开，可以看出它其实是一组内积：

$$
z_{b,t,v}=\langle h_{b,t},E_{v,:}\rangle
$$

也就是说，token $v$ 的 logit 等于当前隐藏状态与 $v$ 的 Embedding 向量的相似度。于是训练目标可以理解为：让 $h_{b,t}$ 在方向上靠近下一个 Token 的 Embedding。

在这个视角下，共享权重不只是省参数，还意味着输入侧和输出侧使用同一个语义空间：同一个词作为输入时的表示，和作为预测目标时的表示，是同一个向量。

### 共享带来的三个代价

**梯度来源不同。** 每一步更新中，$E$ 会同时收到两路梯度。Embedding 路径只更新当前 Batch 中实际出现过的行；LM Head 路径则更新全部 $V$ 行，因为 Softmax 对词表中每个 Token 都产生梯度。两者的更新方向并不总是一致。

**表达受到约束。** 输入表示和输出表示被强制共用一个空间。部分工作发现在较大模型上解绑（untied）效果更好，因此并非所有模型都启用权重共享。这是一个与规模相关的权衡：小模型省下的 $Vd$ 占比高，收益大于约束带来的损失；模型变大后，$Vd$ 的相对占比下降，约束的代价就相对突出。

**初始化尺度需要折中。** Embedding 的输出直接进入网络主干，LM Head 的输出要经过 Softmax，两者理想的初始化尺度并不一定相同，共享后只能取一个折中值。

## 4. Token ID 查表得到初始隐藏状态

`MiniMindModel.forward` 首先读取输入形状并调用 Embedding：

```python
def forward(self, input_ids, attention_mask=None,
            past_key_values=None, use_cache=False, **kwargs):
    batch_size, seq_length = input_ids.shape

    hidden_states = self.dropout(
        self.embed_tokens(input_ids)
    )
```

输入是整数矩阵(`input_ids`  [B, T] input_ids [B, T] 就是一个 B 行 T 列的整数矩阵,每一行是一条样本的 token id 序列)：

$$
I=[i_{b,t}]\in\{0,1,\ldots,V-1\}^{B\times T}
$$

:::tip[例子]
例如用预训练的配置：预训练:  batch_size=128, max_seq_len=512  →  input_ids [128, 512]

```text
            ┌─── T = 512 个 token ───┐
       样本0 │ 1  882  53  ...  0  0 │
       样本1 │ 1  204  91  ...  0  0 │
       样本2 │ 1   77  16  ...  0  0 │
        ... │                       │
    样本127  │ 1  431  62  ...  0  0 │
            └───────────────────────┘
            ↑ B = 128 行
```

:::

Embedding 按 ID 从 $E$ 中取行：

$$
H^{(0)}_{b,t,:}=E_{i_{b,t},:}
$$

所以形状发生变化，查表后得到的是三维张量，多出来的那一维就是 hidden_size=768 —— 原来每个格子是一个整数(token id),现在每个格子被替换成一个 768 维向量：

$$
[B,T]\longrightarrow[B,T,d]
$$

这里不是把 $[B,T]$ 乘成 $[B,T,d]$，也不是对整数 ID 做连续数值计算，而是执行 $B\times T$ 次查表。

相同 Token ID 在不同位置会先取得 **同一个** 基础向量，Embedding 层完全不知道位置。区分它们的工作全部由后面的 **Attention + RoP**E 完成 —— 上下文融合之后,两个同一词的表示才会分化。

而且这个 [B, T, 768] 的形状在整个 8 层主干里保持不变 —— 每个 Block 进去是 [B,T,768],出来还是 [B,T,768]。只有最后过 LM Head 时最后一维才从 768 变成 6400。



Dropout 不改变张量形状。训练阶段它对元素施加随机掩码并进行尺度补偿，推理阶段则相当于恒等映射：

$$
\widetilde H^{(0)}
=
\operatorname{Dropout}(H^{(0)})
\in\mathbb{R}^{B\times T\times d}
$$

值得注意的是当前实践中 `config.dropout`  默认是 0.0,而三个训练脚本都没有覆盖它。所以 nn.Dropout(0.0) 在这个项目里全程等于恒等映射 —— 包括 Attention 里的 attn_dropout 和 resid_dropout 也一样。

```python
self.dropout = kwargs.get("dropout", 0.0)   # config 默认 0.0
```

:::tip

现代 LLM 预训练通常不用 dropout:数据量足够大、每个样本基本只见一次(epochs=1),过拟合风险很低,而 dropout 会拖慢收敛。Dropout 是"数据少、多轮重复训练"时代的正则手段。不过 LoRA 那次训了 5 个 epoch、数据只有 1.6 万条 —— 那个场景其实是有过拟合风险的,dropout 保持 0 可能是退化原因之一。

:::

MiniMind 没有把位置向量直接加到 Embedding 上。它从预计算的 RoPE 表中切出当前位置：

```python
start_pos = (
    past_key_values[0][0].shape[1]
    if past_key_values[0] is not None else 0
)

position_embeddings = (
    self.freqs_cos[start_pos:start_pos + seq_length],
    self.freqs_sin[start_pos:start_pos + seq_length]
)
```

若当前输入长度为 $T$，则：

$$
C,S\in\mathbb{R}^{T\times d_h}
$$

训练时没有历史 KV Cache，通常有 `start_pos=0`；逐 Token 推理时，`start_pos` 等于已经缓存的历史长度。`position_embeddings` 会继续传入 Attention，在 Q/K 投影后参与旋转，而不会直接修改此处的 $H^{(0)}$。

## 5. MiniMindBlock 对应两次 Pre-Norm 残差更新

单个 Decoder Block 的主干代码是：

```python
def forward(self, hidden_states, position_embeddings,
            past_key_value=None, use_cache=False,
            attention_mask=None):
    residual = hidden_states
    hidden_states, present_key_value = self.self_attn(
        self.input_layernorm(hidden_states),
        position_embeddings,
        past_key_value,
        use_cache,
        attention_mask
    )
    hidden_states = hidden_states + residual

    hidden_states = hidden_states + self.mlp(
        self.post_attention_layernorm(hidden_states)
    )
    return hidden_states, present_key_value
```

设进入第 $\ell$ 个 Block 的隐藏状态为 $H^{(\ell)}$，代码可以逐行翻译为：

$$
\widehat H^{(\ell)}
=
\operatorname{RMSNorm}_1(H^{(\ell)})
$$

$$
A^{(\ell)}
=
\operatorname{Attention}
\left(
\widehat H^{(\ell)};C,S,M,K_{\mathrm{past}},V_{\mathrm{past}}
\right)
$$

$$
U^{(\ell)}
=
H^{(\ell)}+A^{(\ell)}
$$

$$
F^{(\ell)}
=
\operatorname{MLP}
\left(
\operatorname{RMSNorm}_2(U^{(\ell)})
\right)
$$

$$
H^{(\ell+1)}
=
U^{(\ell)}+F^{(\ell)}
$$

代码反复覆盖 `hidden_states`，数学表达则给每个中间结果单独命名。第一处 `residual` 显式保存 $H^{(\ell)}$；第二次残差没有再创建变量，因为此时 `hidden_states` 本身已经是 $U^{(\ell)}$。

整条主干上的形状始终保持：

$$
H^{(\ell)},A^{(\ell)},U^{(\ell)},F^{(\ell)},H^{(\ell+1)}
\in\mathbb{R}^{B\times T\times d}
$$

只有形状一致，Attention 输出和 FFN 输出才能分别与残差逐元素相加。`present_key_value` 是供生成阶段复用的旁路输出，不会代替当前层的隐藏状态。

## 6. Block 堆叠形成完整 Transformer 主干

`MiniMindModel.forward` 用循环依次调用全部 Block：

```python
presents = []
for layer, past_key_value in zip(self.layers, past_key_values):
    hidden_states, present = layer(
        hidden_states,
        position_embeddings,
        past_key_value=past_key_value,
        use_cache=use_cache,
        attention_mask=attention_mask
    )
    presents.append(present)

hidden_states = self.norm(hidden_states)
return hidden_states, presents, aux_loss
```

这对应函数复合：

$$
H^{(L)}
=
\operatorname{Block}_{L-1}
\circ\cdots\circ
\operatorname{Block}_1
\circ
\operatorname{Block}_0
\left(H^{(0)}\right)
$$

虽然每层输入输出形状都为 $[B,T,d]$，不同层拥有各自独立的 Attention、FFN 和 Norm 参数，因此每一层学习的变换并不相同。

循环结束后执行最终 RMSNorm：

$$
H_{\mathrm{final}}
=
\operatorname{RMSNorm}_{\mathrm{final}}(H^{(L)})
\in\mathbb{R}^{B\times T\times d}
$$

`presents` 保存每一层产生的 KV Cache；训练时默认 `use_cache=False`，其中的元素为 `None`。`aux_loss` 用于 MoE 路由负载均衡；普通 FFN 配置下没有 MoE 层，因此它为 0。两者都是主隐藏状态之外的附加输出。

## 7. LM Head 将隐藏状态变成词表 Logits

`MiniMindForCausalLM.forward` 先调用主干，再执行输出投影：

```python
hidden_states, past_key_values, aux_loss = self.model(
    input_ids,
    attention_mask,
    past_key_values,
    use_cache,
    **kwargs
)

slice_indices = (
    slice(-logits_to_keep, None)
    if isinstance(logits_to_keep, int)
    else logits_to_keep
)
logits = self.lm_head(
    hidden_states[:, slice_indices, :]
)
```

对每个位置的最终隐藏向量 $h_{b,t}\in\mathbb{R}^{d}$，LM Head 计算：

$$
z_{b,t}
=
W_{\mathrm{lm}}h_{b,t}
\in\mathbb{R}^{V}
$$

按照 PyTorch 的批量张量写法，等价于：

$$
Z=H_{\mathrm{final}}W_{\mathrm{lm}}^\top
\in\mathbb{R}^{B\times T\times V}
$$

因此最后一个维度从隐藏特征 $d$ 变成词表类别 $V$：

$$
[B,T,d]\longrightarrow[B,T,V]
$$

$Z$ 是 logits，不是概率。对某个位置应用 Softmax 才得到条件概率：

$$
p_{b,t,v}
=
\frac{\exp(z_{b,t,v})}
{\sum_{u=0}^{V-1}\exp(z_{b,t,u})}
$$

`logits_to_keep` 是推理优化参数，可以只计算最后若干位置的 logits。默认值为 0，而 Python 中 `-0` 等于 0，所以 `slice(-0, None)` 实际是 `slice(0, None)`，训练默认仍会保留全部 $T$ 个位置。

代码没有在 LM Head 后显式调用 Softmax，因为训练使用的 `F.cross_entropy` 会在数值更稳定的实现中合并 Log-Softmax 与负对数似然。

## 8. 标签错位把输入序列变成下一个 Token 目标

预训练数据集先把输入复制为标签，再把 PAD 位置设为 `-100`：

```python
# dataset/lm_dataset.py
tokens = [bos_token_id] + tokens + [eos_token_id]
input_ids = tokens + [pad_token_id] * (
    max_length - len(tokens)
)

input_ids = torch.tensor(input_ids, dtype=torch.long)
labels = input_ids.clone()
labels[input_ids == pad_token_id] = -100
return input_ids, labels
```

看到 `labels = input_ids.clone()` 时，容易误以为模型在学习原样复制输入。真正的时间错位发生在模型内部：

```python
if labels is not None:
    x = logits[..., :-1, :].contiguous()
    y = labels[..., 1:].contiguous()

    loss = F.cross_entropy(
        x.view(-1, x.size(-1)),
        y.view(-1),
        ignore_index=-100
    )
```

假设一条补齐后的序列是：

```text
input_ids = [BOS, Thinking, Machines, EOS, PAD]
labels    = [BOS, Thinking, Machines, EOS, -100]
```

切片后形成：

| 模型输入位置产生的 logits | 对应监督目标 |
| ------------------------- | ------------ |
| `BOS` 位置                | `Thinking`   |
| `Thinking` 位置           | `Machines`   |
| `Machines` 位置           | `EOS`        |
| `EOS` 位置                | `-100`，忽略 |

也就是：

$$
z_{b,t}\quad\text{预测}\quad i_{b,t+1}
$$

若完整 logits 形状为 $[B,T,V]$，切片和展平对应：

$$
x: [B,T-1,V]\longrightarrow[B(T-1),V]
$$

$$
y: [B,T-1]\longrightarrow[B(T-1)]
$$

`F.cross_entropy` 要求每一行包含 $V$ 个类别分数，并为这一行提供一个整数类别 ID，所以代码把 Batch 维和时间维合并为一个样本维。`contiguous()` 先确保切片结果在内存中连续，使后续 `view` 能安全重塑。

设有效目标位置集合为：

$$
\Omega
=
\{(b,t)\mid Y_{b,t+1}\ne-100\}
$$

默认平均交叉熵为：

$$
\mathcal{L}_{\mathrm{LM}}
=
-\frac{1}{|\Omega|}
\sum_{(b,t)\in\Omega}
\log
P_\theta
\left(
Y_{b,t+1}\mid I_{b,\le t}
\right)
$$

这正是因果语言模型的 Token 级负对数似然。`ignore_index=-100` 会从求和与平均分母中排除 PAD 目标。交叉熵与 NLL 的完整关系可以回看[KL 散度与交叉熵笔记](/posts/math/KLDivergenceAndCrossEntropy/)。

因果掩码和标签错位承担不同职责：Causal Mask 保证位置 $t$ 的隐藏状态不能读取未来 Token；标签错位则规定位置 $t$ 应该预测 Token $t+1$。缺少前者会泄露答案，缺少后者则不会形成标准的 Next-Token Prediction。

## 例子

为了把维度看清，假设使用以下配置：

$$
B=2,\quad T=5,\quad V=100,\quad d=64,\quad L=2
$$

$$
h_q=4,\quad h_{kv}=2,\quad d_h=16,\quad m=128
$$

一次训练前向传播的形状为：

| 代码位置                   | 张量                 | 形状        |
| -------------------------- | -------------------- | ----------- |
| `input_ids`                | $I$                  | $[2,5]$     |
| `embed_tokens(input_ids)`  | $H^{(0)}$            | $[2,5,64]$  |
| `MiniMindBlock[0]` 输出    | $H^{(1)}$            | $[2,5,64]$  |
| `MiniMindBlock[1]` 输出    | $H^{(2)}$            | $[2,5,64]$  |
| `self.norm(hidden_states)` | $H_{\mathrm{final}}$ | $[2,5,64]$  |
| `lm_head(hidden_states)`   | $Z$                  | $[2,5,100]$ |
| `logits[..., :-1, :]`      | $x$                  | $[2,4,100]$ |
| `labels[..., 1:]`          | $y$                  | $[2,4]$     |
| `x.view(-1, 100)`          | 交叉熵输入           | $[8,100]$   |
| `y.view(-1)`               | 交叉熵类别 ID        | $[8]$       |
| `F.cross_entropy(...)`     | $\mathcal{L}$        | 标量        |

这个表揭示了完整前向传播中两次关键的最后一维变化：Embedding 把整数 ID 变成 $d$ 维隐藏向量，LM Head 再把 $d$ 维隐藏向量变成 $V$ 维词表分数。中间的 $L$ 个 Decoder Block 都保持 $[B,T,d]$ 不变。

## 10. 从代码阅读过渡到组件实现

现在可以把 MiniMind 主干压缩成一组代码与数学对象的对照：

| 代码对象                   | 数学语言                                             |
| -------------------------- | ---------------------------------------------------- |
| `MiniMindConfig`           | 确定 $V,d,L,h_q,h_{kv},d_h,m$                        |
| `nn.Embedding(V, d)`       | $H^{(0)}=E[I]$                                       |
| `MiniMindBlock`            | $H^{(\ell+1)}=\operatorname{Block}_\ell(H^{(\ell)})$ |
| `ModuleList([...])`        | 保存 $L$ 个参数独立的 Block                          |
| `for layer in self.layers` | 执行 $L$ 个函数的顺序复合                            |
| `RMSNorm`                  | 归一化特征尺度，不改变形状                           |
| `lm_head`                  | $Z=H_{\mathrm{final}}W_{\mathrm{lm}}^\top$           |
| `logits[..., :-1, :]`      | 去掉没有下一 Token 目标的最后一个预测位置            |
| `labels[..., 1:]`          | 将监督目标向左对齐到对应预测位置                     |
| `F.cross_entropy`          | Token 级 NLL 的批量工程实现                          |

到这里，已经能从训练脚本一路追踪到标量 Loss，但仍把 `self.self_attn(...)` 当作一个整体。下一篇将进入 `Attention.forward`，逐段对应 Q/K/V 投影、QK Norm、RoPE、GQA、Causal Mask、注意力矩阵和 KV Cache。
