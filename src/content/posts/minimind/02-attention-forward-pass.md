---
title: 'MiniMind 代码导读（二）：Attention 的完整张量流'
published: 2026-07-20
description: '沿着 MiniMind 的 Attention.forward，将 Q/K/V 投影、QK Norm、RoPE、GQA、KV Cache、因果掩码与缩放点积注意力逐段翻译为数学公式和张量形状'
image: ''
tags: [minimind, LLM, Transformer]
category: '10-MiniMind项目'
order: 2
draft: false
lang: ''
---

:::tip[本文定位]

上一篇[从 Token IDs 到训练 Loss](/posts/minimind/01-model-forward-pass/)把 `Attention` 暂时看成了一个保持形状不变的黑盒：

$$
\operatorname{Attention}:\mathbb{R}^{B\times T\times d}
\rightarrow\mathbb{R}^{B\times T\times d}
$$

本文打开这个黑盒，集中阅读 `model/model_minimind.py` 中的 `Attention.forward`、`apply_rotary_pos_emb` 和 `repeat_kv`。目标仍然是建立同一套对应关系：

```text
代码语句 ↔ 数学运算 ↔ 张量形状
```

组件的理论作用[现代 LLM 组件](/posts/transformer/modern-llm-components/)

:::

## 1. Attention 前向传播是一条可追踪的张量流水线

`Attention.forward` 接收某个 Decoder Block 中经过 RMSNorm 的隐藏状态：

$$
X\in\mathbb{R}^{B\times T_q\times d}
$$

$T_q$ 表示本次调用送入模型的 Query 长度。训练时通常一次送入整段序列，此时 $T_q=T$；使用 KV Cache 逐 Token 解码时，通常有 $T_q=1$。

本文使用以下符号：

| 符号 | 代码属性 | 含义 |
| --- | --- | --- |
| $B$ | `bsz` | Batch Size |
| $T_q$ | `seq_len` | 本次输入的 Token 数，即 Query 长度 |
| $T_{kv}$ | Key/Value 的序列维 | 历史缓存与本次输入合并后的长度 |
| $d$ | `hidden_size` | 模型隐藏维度 |
| $h_q$ | `n_local_heads` | Query 头数 |
| $h_{kv}$ | `n_local_kv_heads` | Key/Value 头数 |
| $d_h$ | `head_dim` | 单个注意力头的维度 |
| $r$ | `n_rep` | 每个 K/V 头服务的 Query 头数，$r=h_q/h_{kv}$ |

MiniMind 默认使用 $d=768$、$h_q=8$、$h_{kv}=4$、$d_h=96$，所以：

$$
h_qd_h=d,
\qquad
r=\frac{h_q}{h_{kv}}=2
$$

下面的图先给出整条数据流。虚线缓存支路只在自回归生成时发挥作用；QK Norm 和 RoPE 都不处理 Value。

<figure class="attn-flow" aria-labelledby="attn-flow-caption">
<style>
  .attn-flow {
    --af-ink: oklch(35% 0.028 255);
    --af-muted: oklch(54% 0.025 255);
    --af-line: oklch(78% 0.035 245);
    --af-blue: oklch(94% 0.055 236);
    --af-green: oklch(94% 0.075 135);
    --af-orange: oklch(95% 0.06 72);
    --af-pink: oklch(95% 0.06 345);
    margin: 1.8rem 0 2rem;
  }
  .attn-flow * {
    box-sizing: border-box;
  }
  .attn-flow__viewport {
    overflow-x: auto;
    padding: 0.3rem 0.1rem 0.8rem;
  }
  .attn-flow__canvas {
    min-width: 760px;
    padding: 24px;
    color: var(--af-ink);
    background: linear-gradient(145deg, oklch(99% 0.01 95), oklch(98% 0.012 245));
    border: 1px solid var(--af-line);
    border-radius: 22px;
    box-shadow: 0 14px 38px oklch(35% 0.035 250 / 0.07);
  }
  .attn-flow__row {
    display: flex;
    align-items: stretch;
    justify-content: center;
    gap: 9px;
  }
  .attn-flow__node {
    display: flex;
    min-width: 96px;
    min-height: 66px;
    flex: 1 1 0;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 9px 8px;
    text-align: center;
    background: white;
    border: 1px solid var(--af-line);
    border-radius: 13px;
    font-size: 13px;
    font-weight: 720;
    line-height: 1.25;
  }
  .attn-flow__node small {
    margin-top: 5px;
    color: var(--af-muted);
    font-size: 10px;
    font-weight: 560;
    white-space: nowrap;
  }
  .attn-flow__node--input,
  .attn-flow__node--output {
    background: var(--af-green);
  }
  .attn-flow__node--project {
    background: var(--af-blue);
  }
  .attn-flow__node--position {
    background: var(--af-orange);
  }
  .attn-flow__node--attend {
    background: var(--af-pink);
  }
  .attn-flow__arrow {
    display: grid;
    flex: 0 0 18px;
    place-items: center;
    color: var(--af-muted);
    font-size: 18px;
  }
  .attn-flow__cache {
    width: 300px;
    margin: 13px auto 0;
    padding: 8px 12px;
    color: var(--af-muted);
    text-align: center;
    border: 1px dashed oklch(64% 0.07 285);
    border-radius: 999px;
    font-size: 11px;
  }
  .attn-flow figcaption {
    margin-top: 0.7rem;
    color: var(--af-muted);
    text-align: center;
    font-size: 0.85rem;
  }
  @media (max-width: 760px) {
    .attn-flow__canvas {
      padding: 18px;
    }
  }
</style>
  <div class="attn-flow__viewport">
    <div class="attn-flow__canvas">
      <div class="attn-flow__row">
        <div class="attn-flow__node attn-flow__node--input">隐藏状态 X<small>[B, Tq, d]</small></div>
        <div class="attn-flow__arrow">→</div>
        <div class="attn-flow__node attn-flow__node--project">Q/K/V 投影<small>拆分多个头</small></div>
        <div class="attn-flow__arrow">→</div>
        <div class="attn-flow__node attn-flow__node--position">QK Norm + RoPE<small>只作用于 Q/K</small></div>
        <div class="attn-flow__arrow">→</div>
        <div class="attn-flow__node">GQA 展开<small>h<sub>kv</sub> → h<sub>q</sub></small></div>
        <div class="attn-flow__arrow">→</div>
        <div class="attn-flow__node attn-flow__node--attend">Scaled Dot-Product<small>Mask + Softmax</small></div>
        <div class="attn-flow__arrow">→</div>
        <div class="attn-flow__node attn-flow__node--output">合并头 + 输出投影<small>[B, Tq, d]</small></div>
      </div>
      <div class="attn-flow__cache">历史 K/V → 拼接当前 K/V → 返回新的 KV Cache</div>
    </div>
  </div>
  <figcaption id="attn-flow-caption">MiniMind Attention 的前向张量流；横向空间不足时可滚动查看。</figcaption>
</figure>

把这条流水线压缩成一组公式，就是：

$$
\begin{aligned}
Q&=\operatorname{QNorm}(XW_Q^\top),\\
K&=\operatorname{KNorm}(XW_K^\top),\\
V&=XW_V^\top,\\
\widetilde Q,\widetilde K&=\operatorname{RoPE}(Q,K),\\
\overline K,\overline V&=\operatorname{GQARepeat}(K_{\mathrm{cache}}\Vert\widetilde K,\,
V_{\mathrm{cache}}\Vert V),\\
A&=\operatorname{softmax}\!\left(
\frac{\widetilde Q\overline K^\top}{\sqrt{d_h}}+M_{\mathrm{causal}}+M_{\mathrm{pad}}
\right),\\
O&=\operatorname{ConcatHeads}(A\overline V)W_O^\top.
\end{aligned}
$$

后面的代码只是在显式构造这些量，同时不断改变它们的视图和形状。

## 2. Q/K/V 投影把表示空间拆成多个注意力头

Attention 初始化时创建四个无偏置线性层：

```python
self.q_proj = nn.Linear(
    config.hidden_size,
    config.num_attention_heads * self.head_dim,
    bias=False
)
self.k_proj = nn.Linear(
    config.hidden_size,
    self.num_key_value_heads * self.head_dim,
    bias=False
)
self.v_proj = nn.Linear(
    config.hidden_size,
    self.num_key_value_heads * self.head_dim,
    bias=False
)
self.o_proj = nn.Linear(
    config.num_attention_heads * self.head_dim,
    config.hidden_size,
    bias=False
)
```

`nn.Linear(in_features, out_features)` 保存的权重形状是 `[out_features, in_features]`，前向计算采用 $XW^\top$。因此：

$$
W_Q\in\mathbb{R}^{h_qd_h\times d},
\qquad
W_K,W_V\in\mathbb{R}^{h_{kv}d_h\times d},
\qquad
W_O\in\mathbb{R}^{d\times h_qd_h}
$$

`forward` 先完成投影，再用 `view` 把最后一个总维度拆成“头数 × 头维度”：

```python
bsz, seq_len, _ = x.shape

xq, xk, xv = self.q_proj(x), self.k_proj(x), self.v_proj(x)

xq = xq.view(bsz, seq_len, self.n_local_heads, self.head_dim)
xk = xk.view(bsz, seq_len, self.n_local_kv_heads, self.head_dim)
xv = xv.view(bsz, seq_len, self.n_local_kv_heads, self.head_dim)
```

对应的形状变化是：

$$
\begin{aligned}
X&:[B,T_q,d],\\
XW_Q^\top&:[B,T_q,h_qd_h]
\longrightarrow Q:[B,T_q,h_q,d_h],\\
XW_K^\top&:[B,T_q,h_{kv}d_h]
\longrightarrow K:[B,T_q,h_{kv},d_h],\\
XW_V^\top&:[B,T_q,h_{kv}d_h]
\longrightarrow V:[B,T_q,h_{kv},d_h].
\end{aligned}
$$

`view` 不会再学习一次投影，也不会把信息分发给独立的小网络；它只是重新解释连续内存中的维度。真正决定每个头看到什么子空间的是 $W_Q$、$W_K$ 和 $W_V$ 中不同的行。

MiniMind 默认 $h_qd_h=d$，所以 Query 投影前后的总维度相同；但这不等于没有发生变换。它仍然用一个 $d\times d$ 参数矩阵把每个 Token 的隐藏表示映射到了新的 Query 空间。K/V 总维度只有：

$$
h_{kv}d_h=4\times96=384=\frac d2
$$

这正是 GQA 比标准多头注意力节省 K/V 参数和缓存的来源。默认配置下，四个投影的主要参数量为：

$$
\underbrace{d^2}_{Q}
+\underbrace{\frac12d^2}_{K}
+\underbrace{\frac12d^2}_{V}
+\underbrace{d^2}_{O}
=3d^2
$$

如果 K/V 也各有 8 个头，标准 MHA 对应的投影参数量则是 $4d^2$。

## 3. QK Norm 与 RoPE 分别控制数值尺度和位置信息

完成多头拆分后，MiniMind 先归一化 Q/K，再施加 RoPE：

```python
xq, xk = self.q_norm(xq), self.k_norm(xk)

cos, sin = position_embeddings
xq, xk = apply_rotary_pos_emb(xq, xk, cos, sin)
```

这里的 `q_norm` 和 `k_norm` 都是 `RMSNorm(self.head_dim)`。以单个 Query 头向量 $q\in\mathbb{R}^{d_h}$ 为例：

$$
\operatorname{RMSNorm}(q)
=
\gamma_Q\odot
\frac{q}{\sqrt{\frac{1}{d_h}\sum_{i=1}^{d_h}q_i^2+\varepsilon}}
$$

代码在最后一维上计算均方根，因此每个 Token 的每个头独立计算自己的归一化尺度。与此同时，$\gamma_Q\in\mathbb{R}^{d_h}$ 会广播到 $B$、$T_q$ 和 $h_q$ 三个维度，即所有 Query 头共享同一组可训练缩放参数；Key 使用另一组独立的 $\gamma_K$。Value 不参与 QK Norm，因为注意力分数由 Q 与 K 的点积决定，而 V 是被权重汇总的内容。

自定义 `RMSNorm` 还会先把输入转成 `float32` 计算，再转回原来的数据类型：

```python
def _norm(self, x):
    return x * torch.rsqrt(
        x.pow(2).mean(-1, keepdim=True) + self.eps
    )

def forward(self, x):
    return (self.weight * self._norm(x.float())).type_as(x)
```

这一步不改变形状：

$$
[B,T_q,h,d_h]\longrightarrow[B,T_q,h,d_h]
$$

随后 `apply_rotary_pos_emb` 将位置旋转施加到 Q/K：

```python
def apply_rotary_pos_emb(q, k, cos, sin, unsqueeze_dim=1):
    def rotate_half(x):
        return torch.cat(
            (-x[..., x.shape[-1] // 2:],
              x[..., :x.shape[-1] // 2]),
            dim=-1
        )

    q_embed = (
        q * cos.unsqueeze(1)
        + rotate_half(q) * sin.unsqueeze(1)
    ).to(q.dtype)
    k_embed = (
        k * cos.unsqueeze(1)
        + rotate_half(k) * sin.unsqueeze(1)
    ).to(k.dtype)
    return q_embed, k_embed
```

若把一个头向量沿最后一维分成等长两半：

$$
x=[x_a,x_b],
\qquad
\operatorname{rotate\_half}(x)=[-x_b,x_a]
$$

那么位置 $t$ 的旋转可以写为逐元素运算：

$$
\operatorname{RoPE}_t(x)
=x\odot\cos\theta_t
+[-x_b,x_a]\odot\sin\theta_t
$$

`cos` 和 `sin` 的形状为 $[T_q,d_h]$，`unsqueeze(1)` 后变为 $[T_q,1,d_h]$，再通过广播同时作用于 Batch 与所有头。RoPE 不在隐藏状态上直接加一个位置向量，而是在 Q/K 空间中按位置旋转坐标，使后续点积能够表达相对位置信息。

两步的职责可以明确区分：QK Norm 控制参与点积的向量尺度，RoPE 改变参与点积的方向以编码位置。它们都只处理 Q/K，也都保持张量形状不变。

## 4. KV Cache 与 GQA 在不同维度上减少重复计算

RoPE 之后，代码先拼接历史缓存，再展开 GQA 的 K/V 头：

```python
if past_key_value is not None:
    xk = torch.cat([past_key_value[0], xk], dim=1)
    xv = torch.cat([past_key_value[1], xv], dim=1)

past_kv = (xk, xv) if use_cache else None

xq = xq.transpose(1, 2)
xk = repeat_kv(xk, self.n_rep).transpose(1, 2)
xv = repeat_kv(xv, self.n_rep).transpose(1, 2)
```

假设缓存中已有 $T_p$ 个历史 Token，本次又输入 $T_q$ 个 Token，那么拼接后的长度为：

$$
T_{kv}=T_p+T_q
$$

缓存的形状是：

$$
K_{\mathrm{cache}},V_{\mathrm{cache}}
\in\mathbb{R}^{B\times T_{kv}\times h_{kv}\times d_h}
$$

这两个缓存解决的是“时间维度上的重复”：历史 Token 的 K/V 已经算过，下一步生成时直接复用即可，不必把整个前缀重新送过模型。每层缓存的元素数为：

$$
2BT_{kv}h_{kv}d_h
$$

MiniMind 的 $h_{kv}=h_q/2$，因此其 KV Cache 元素数只有同头数 MHA 的一半。

但是 Query 有 $h_q$ 个头，缓存中的 K/V 只有 $h_{kv}$ 个头。点积计算前，`repeat_kv` 在头维度上把每个 K/V 头逻辑展开 $r$ 次：

```python
def repeat_kv(x, n_rep):
    bs, slen, num_key_value_heads, head_dim = x.shape
    if n_rep == 1:
        return x
    return (
        x[:, :, :, None, :]
        .expand(bs, slen, num_key_value_heads, n_rep, head_dim)
        .reshape(bs, slen, num_key_value_heads * n_rep, head_dim)
    )
```

默认的对应关系是：

```text
Query heads:  Q0  Q1 | Q2  Q3 | Q4  Q5 | Q6  Q7
K/V heads:    K0  K0 | K1  K1 | K2  K2 | K3  K3
group:        └─ G0 ─┘ └─ G1 ─┘ └─ G2 ─┘ └─ G3 ─┘
```

用形状表示为：

$$
[B,T_{kv},h_{kv},d_h]
\xrightarrow{\operatorname{repeat\_kv}}
[B,T_{kv},h_q,d_h]
\xrightarrow{\operatorname{transpose}(1,2)}
[B,h_q,T_{kv},d_h]
$$

Query 不需要复制，只需转置：

$$
[B,T_q,h_q,d_h]
\longrightarrow[B,h_q,T_q,d_h]
$$

GQA 解决的是“头维度上的冗余”：一组 Query 头共享同一组 K/V 表示。`repeat_kv` 是为了让普通批量矩阵乘法能够按相同头数执行，并不表示缓存中真的保存了 $h_q$ 份 K/V；`past_kv` 在展开之前就已经建立，仍然只保存 $h_{kv}$ 个头。

还要注意，代码默认 $h_q$ 能被 $h_{kv}$ 整除，因为 `n_rep` 使用整数除法。若自定义配置破坏了：

$$
h_q\bmod h_{kv}=0
$$

展开后的头数就无法正确匹配 Query。

## 5. 缩放点积、掩码与 Softmax 共同得到注意力权重

经过转置与 GQA 展开后，三个张量的形状为：

$$
\widetilde Q:[B,h_q,T_q,d_h],
\qquad
\overline K,\overline V:[B,h_q,T_{kv},d_h]
$$

手动分支直接实现了缩放点积注意力：

```python
scores = (
    xq @ xk.transpose(-2, -1)
) / math.sqrt(self.head_dim)

if self.is_causal:
    scores[:, :, :, -seq_len:] += torch.full(
        (seq_len, seq_len),
        float("-inf"),
        device=scores.device
    ).triu(1)

if attention_mask is not None:
    scores += (
        1.0 - attention_mask.unsqueeze(1).unsqueeze(2)
    ) * -1e9

weights = F.softmax(scores.float(), dim=-1).type_as(xq)
output = self.attn_dropout(weights) @ xv
```

首先计算每个 Query 与全部 Key 的相似度：

$$
S=\frac{\widetilde Q\overline K^\top}{\sqrt{d_h}}
\in\mathbb{R}^{B\times h_q\times T_q\times T_{kv}}
$$

若 Q/K 各维度具有近似相同的尺度，未经缩放的点积方差会随 $d_h$ 增长。除以 $\sqrt{d_h}$ 可以避免 Softmax 输入随头维度变大而过度极端。

因果掩码把“当前 Query 不应该看到的未来 Key”加为 $-\infty$。没有缓存时，$T_q=T_{kv}=T$，它是熟悉的上三角矩阵：

$$
M_{\mathrm{causal}}=
\begin{bmatrix}
0&-\infty&-\infty&\cdots\\
0&0&-\infty&\cdots\\
0&0&0&\cdots\\
\vdots&\vdots&\vdots&\ddots
\end{bmatrix}
$$

有缓存时，`scores[:, :, :, -seq_len:]` 只在本次新增的 $T_q\times T_q$ 区域加入上三角掩码。所有历史列都保持可见，因为历史 Token 对当前 Query 来说都位于过去。逐 Token 解码时 $T_q=1$，这个 $1\times1$ 上三角矩阵为 0，当前 Token 可以关注全部 $T_p+1$ 个 Key。

外部 `attention_mask` 通常形如 $[B,T_{kv}]$，两次 `unsqueeze` 后广播为 $[B,1,1,T_{kv}]$。其中 0 对应的 Key 位置被加上一个极小值，从而在 Softmax 后取得近似 0 的权重。这里的核心不是“用 0 乘掉分数”，而是在 Softmax 之前对不合法位置施加加性掩码：

$$
A=\operatorname{softmax}
\left(S+M_{\mathrm{causal}}+M_{\mathrm{pad}}\right)
$$

最后沿 Key 维归一化，并对 Value 加权求和：

$$
A:[B,h_q,T_q,T_{kv}],
\qquad
H=A\overline V:[B,h_q,T_q,d_h]
$$

`scores.float()` 让 Softmax 在 `float32` 中计算，降低半精度指数运算溢出或下溢的风险；随后 `type_as(xq)` 再把权重转回 Q 的数据类型。`attn_dropout` 只在训练模式下随机丢弃部分注意力权重，不改变形状。

预训练脚本调用模型时没有显式传入 `attention_mask`。`PretrainDataset` 采用右侧 Padding，真实 Token 无法越过因果掩码看到未来的 PAD；PAD 位置虽然可以看到前文，但其标签被设为 `-100`，不会进入语言模型 Loss。因此这一路径仍然成立。若 Batch 使用左侧 Padding 或更复杂的有效区间，就应正确传入 `attention_mask`。

## 6. Flash Attention 是同一数学运算的融合实现

当运行环境支持且配置启用 Flash Attention 时，MiniMind 会优先调用 PyTorch 的融合算子：

```python
if (
    self.flash
    and seq_len > 1
    and (not self.is_causal or past_key_value is None)
    and (attention_mask is None or torch.all(attention_mask == 1))
):
    output = F.scaled_dot_product_attention(
        xq,
        xk,
        xv,
        dropout_p=self.dropout if self.training else 0.0,
        is_causal=self.is_causal
    )
else:
    # 手动计算 scores、mask、softmax 和 output
    ...
```

这不是另一种注意力目标。两条分支都在计算：

$$
\operatorname{Attention}(Q,K,V)
=\operatorname{softmax}\left(
\frac{QK^\top}{\sqrt{d_h}}+M
\right)V
$$

差别在工程实现：融合算子可以分块完成点积、Mask、Softmax 与 Value 汇总，避免把完整的 $T_q\times T_{kv}$ 分数矩阵长期写入显存。序列越长，这种中间张量的显存开销越明显。

MiniMind 的条件也揭示了两条分支各自常见的使用场景：

| 场景 | 常见分支 | 原因 |
| --- | --- | --- |
| 整段预训练，未传 Padding Mask | Flash 分支 | `seq_len > 1`、无历史缓存且所有位置有效 |
| 带非全 1 Padding Mask 的输入 | 手动分支 | 当前条件不把该 Mask 交给融合算子 |
| 已有 KV Cache 的增量生成 | 手动分支 | `past_key_value is not None` |
| 单 Token 解码 | 手动分支 | `seq_len == 1` |

所以阅读手动分支最容易看懂数学过程，但不应据此认为训练一定真的显式保存了 `scores`；实际是否融合取决于配置、运行环境与输入条件。

## 7. 合并多头后才回到 Decoder Block 的残差主干

每个 Query 头都已得到自己的上下文向量后，代码把头维移回末尾并合并：

```python
output = output.transpose(1, 2).reshape(
    bsz, seq_len, -1
)
output = self.resid_dropout(self.o_proj(output))
return output, past_kv
```

对应的形状变化为：

$$
[B,h_q,T_q,d_h]
\xrightarrow{\operatorname{transpose}}
[B,T_q,h_q,d_h]
\xrightarrow{\operatorname{reshape}}
[B,T_q,h_qd_h]
\xrightarrow{W_O}
[B,T_q,d]
$$

多头结果不是求平均，而是先拼接成 $h_qd_h$ 维向量，再由 $W_O$ 混合各头的信息并映射回模型隐藏维度。由于输出仍为 $[B,T_q,d]$，它才能与进入 Attention 前的残差分支相加。

不过，`Attention.forward` 本身只返回 Attention 输出，没有在内部执行残差加法。加法位于外层 `MiniMindBlock.forward`：

```python
residual = hidden_states
hidden_states, present_key_value = self.self_attn(
    self.input_layernorm(hidden_states),
    position_embeddings,
    past_key_value,
    use_cache,
    attention_mask
)
hidden_states = residual + hidden_states
```

因此完整关系是：

$$
H'=H+\operatorname{Attention}(\operatorname{RMSNorm}(H))
$$

`resid_dropout` 的名字表示它作用于即将进入残差加法的 Attention 输出，而不是说残差连接发生在 `Attention` 类内部。把模块边界分清，阅读代码调用链时就不容易把两个不同位置的 RMSNorm、Dropout 与 Add 混在一起。

## 8. 两条形状轨迹连接训练与增量解码

为了让每个维度都能实际核对，下面使用一个缩小后的配置：

$$
B=2,
\quad d=64,
\quad h_q=4,
\quad h_{kv}=2,
\quad d_h=16,
\quad r=2
$$

整段输入 $T_q=5$ 时，形状轨迹如下：

| 阶段 | Q | K | V 或输出 |
| --- | --- | --- | --- |
| 输入 | — | — | $X:[2,5,64]$ |
| 线性投影 | `[2,5,64]` | `[2,5,32]` | `[2,5,32]` |
| 拆分头 | `[2,5,4,16]` | `[2,5,2,16]` | `[2,5,2,16]` |
| QK Norm + RoPE | `[2,5,4,16]` | `[2,5,2,16]` | `[2,5,2,16]` |
| GQA + 转置 | `[2,4,5,16]` | `[2,4,5,16]` | `[2,4,5,16]` |
| 注意力分数 | `[2,4,5,5]` | — | — |
| 每头上下文 | — | — | `[2,4,5,16]` |
| 合并头与输出投影 | — | — | `[2,5,64]` |
| 返回缓存 | — | `[2,5,2,16]` | `[2,5,2,16]` |

注意返回缓存仍然只有 2 个 K/V 头，而不是 GQA 展开后的 4 个头。

现在假设这 5 个 Token 已经写入缓存，下一次只输入 1 个新 Token。此时 $T_p=5$、$T_q=1$、$T_{kv}=6$：

| 阶段 | 形状 |
| --- | --- |
| 新输入 | `[2,1,64]` |
| 新 Q / K / V 投影 | `[2,1,64]` / `[2,1,32]` / `[2,1,32]` |
| 拼接后的紧凑 K/V | `[2,6,2,16]` |
| GQA 展开后的 K/V | `[2,4,6,16]` |
| Query | `[2,4,1,16]` |
| 注意力分数 | `[2,4,1,6]` |
| Attention 输出 | `[2,1,64]` |
| 返回的新缓存 | K/V 各 `[2,6,2,16]` |

这条轨迹说明了 KV Cache 的核心收益：第 6 个 Token 的 Query 仍需与 6 个 Key 比较，但前 5 个 Token 的 K/V 不再重复投影。生成长度增长时，每一步只为新增 Token 计算新的 Q/K/V，再把 K/V 追加到缓存中。

回到源码，可以把整个 `Attention.forward` 读成一句话：先将 $X$ 投影为多头 Q/K/V，用 QK Norm 稳定点积、用 RoPE 注入位置，再拼接紧凑的历史 K/V 并按 GQA 展开，经过带掩码的缩放点积注意力汇总上下文，最后合并各头并投影回 $d$ 维。

:::note[下一篇]

Attention 已经从黑盒变成了一条完整的张量流。下一篇继续阅读同一个 Decoder Block 中的 `FeedForward`、RMSNorm 与残差连接，并进一步区分普通 SwiGLU FFN 和 MiniMind 可选的 MoE 路径。

:::
