---
title: Trasformer-编码器核心：self-attention自注意力机制
published: 2026-06-27
description: ''
image: ''
tags: []
category: '05-注意力与Transformer'
order: 32
draft: false 
lang: ''
---

Transformer的架构由编码器（Encoder） 和解码器（Decoder） 两大部分组成

这里重点介绍编码器部分的核心机制：**自注意力机制（Self-Attention）**

## 符号

| 符号                               | 含义                                             |
| ---------------------------------- | ------------------------------------------------ |
| $n$                                | 输入序列的长度（token个数）                       |
| $d$ 或 $d_{model}$                    | 词嵌入向量的维度                                 |
| $X\in \mathbb{R}^{d \times n}$     | 输入序列的词嵌入矩阵，每一列是一个词元的嵌入向量 |
| $Q\in \mathbb{R}^{d_k \times n}$   | 查询（Query）矩阵，每一列是一个词元的查询向量    |
| $\mathbf{q_i}\in \mathbb{R}^{d_k}$ | 第 $i$ 个词元的查询向量                          |
| $K\in \mathbb{R}^{d_k \times n}$   | 键（Key）矩阵，每一列是一个词元的键向量          |
| $\mathbf{k_j}\in \mathbb{R}^{d_k}$ | 第 $j$ 个词元的键向量                            |
| $V\in \mathbb{R}^{d_v \times n}$   | 值（Value）矩阵，每一列是一个词元的值向量        |
| $\mathbf{v_j}\in \mathbb{R}^{d_v}$ | 第 $j$ 个词元的值向量                            |
| $d_k$                              | 查询和键向量的维度                               |
| $d_v$                              | 值向量的维度                                     |

| 中间量                                               | 含义                                     |
| ---------------------------------------------------- | ---------------------------------------- |
| $s_{ij}$                                             | 第 $i$ 个词元对第 $j$ 个词元的注意力得分 |
| $S\in \mathbb{R}^{n \times n}$                       | 注意力得分矩阵                           |
| $A\in \mathbb{R}^{n \times n}$                       | 注意力权重矩阵                           |
| $A_{ij}$ 或 $\text{Attention}_{ij}$ 或 $\alpha_{ij}$ | 第 $i$ 个词元对第 $j$ 个词元的注意力权重 |
| $Z\in \mathbb{R}^{d_v \times n}$                     | 自注意力机制的输出矩阵                   |
| $\mathbf{z_i}\in \mathbb{R}^{d_v}$                   | 第 $i$ 个词元的输出向量                  |

| 参数                                | 含义                                                                  |
| ----------------------------------- | --------------------------------------------------------------------- |
| $W_Q\in \mathbb{R}^{d_k \times d}$  | 查询的权重矩阵                                                        |
| $W_K\in \mathbb{R}^{d_k \times d}$  | 键的权重矩阵                                                          |
| $W_V\in \mathbb{R}^{d_v \times d}$  | 值的权重矩阵                                                          |
| $W_O\in \mathbb{R}^{d \times hd_v}$ | 多头注意力共享的输出矩阵；混合拼接后的各头输出并映射回 $d$ 维嵌入空间 |

## "自" 参注意力

在机器翻译中，传统的注意力（Cross-Attention，交叉注意力）是：解码器在生成“苹果”这个词时，去编码器里找输入句子“I love apples”中哪个词（I / love / apples）最相关。

而自注意力中的“自”指的是：Query（查询）、Key（键）、Value（值）这三个向量，全部来自同一个输入序列本身。

## 词嵌入+位置编码

词嵌入向量（Embedding）：每个输入词都会被映射为一个 $d$ 维向量，称为 **词嵌入向量**。

Attention 本身通常不负责最开始的词向量编码，而是接收 Embedding 层生成的词向量。Embedding 层内部有一个 **可学习** 的矩阵：

$$
E\in\mathbb{R}^{d\times V}
$$

每个token都对应着矩阵中的一列。可以通过查表的方式取出对应的 $d$ 维词嵌入向量

位置编码（Positional Encoding）：Transformer没有循环结构或卷积结构，因此需要为每个词元添加位置信息。位置编码向量与词嵌入向量 **相加**，得到最终的输入向量。

假设输入序列长度为 $n$，每个词的嵌入维度为 $d$，则输入序列可以表示为一个 **词嵌入矩阵**

$X=[\mathbf{x_1}, \mathbf{x_2}, ..., \mathbf{x_n}] \in \mathbb{R}^{d \times n}$。

加上位置编码后，输入序列的最终表示为：

$X\leftarrow X + P \in \mathbb{R}^{d \times n}$，其中 $P$ 是位置编码矩阵。

## QKV矩阵与对应的权重矩阵$W_Q, W_K, W_V$

为了计算注意力，需要为每个词生成 **三个** 不同的向量 $\mathbf{q}_i, \mathbf{k}_i, \mathbf{v}_i$。这三个向量是通过三个 **可训练** 的 **权重矩阵** 与 **输入向量** $\mathbf{x}_i$ 相乘得到的。对于一整个输入序列也就是三个 **权重矩阵** 与 **词嵌入矩阵** $X$ 相乘得到对应的 **Q、K、V矩阵**：

- Query（查询）矩阵
  - $Q = W_QX=[W_Q\mathbf{x_1}, W_Q\mathbf{x_2}, ..., W_Q\mathbf{x_n}]=[\mathbf{q_1}, \mathbf{q_2}, ..., \mathbf{q_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_Q \in \mathbb{R}^{d_k \times d}$ 是查询的权重矩阵，$d_k$ 是查询向量的维度。
  - “提问者”。这个词想知道：“在当前语境下，我应该关注谁？”

- Key（键）矩阵
  - $K = W_KX=[W_K\mathbf{x_1}, W_K\mathbf{x_2}, ..., W_K\mathbf{x_n}]=[\mathbf{k_1}, \mathbf{k_2}, ..., \mathbf{k_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_K \in \mathbb{R}^{d_k \times d}$ 是键的权重矩阵。
  - “被问者”。这个词说：“我的特征是XXX，看看你要找的是不是我？”

:::tip

$Q$ 和 $K$ 都把词嵌入向量投影到一个低维的查询空间（Query Space）和键空间（Key Space），这个低维空间的维度通常比原始嵌入维度小很多（例如 $d_k=128\lt d=12888$）。

:::

- Value（值）矩阵
  - $V = W_VX=[W_V\mathbf{x_1}, W_V\mathbf{x_2}, ..., W_V\mathbf{x_n}]=[\mathbf{v_1}, \mathbf{v_2}, ..., \mathbf{v_n}]\in \mathbb{R}^{d_v \times n}$，
  - 其中 $W_V \in \mathbb{R}^{d_v \times d}$ 是值的权重矩阵，$d_v$ 是值向量的维度。
  - “实际内容”。一旦确认了“提问者”和“被问者”很匹配，这就是我实际要传递给你的具体语义信息。

:::tip

这里 $W_v$ 的输入输出空间都是 $d$ 维的嵌入空间，对于单头 $d_v=d$，也就是值向量的维度和原始嵌入维度相同；但在多头注意力中，通常会选择 $d_v=d/h$，也就是每个头的值向量维度比原始嵌入维度小很多（例如 $d_v=64\lt d=12888$）。

:::

## scaled dot-product attention（缩放点积注意力）

有了 Query、Key、Value 三个矩阵，就可以计算注意力了。注意力的核心思想是：**用 Query 与 Key 的相似度来加权 Value**。

计算任意两个词元 $i$ 和 $j$ 的 **注意力得分**（标量），用 $i$ 的 Query 向量 $\mathbf{q_i}$ 与 $j$ 的 Key 向量 $\mathbf{k_j}$ 做点积：

$$
s_{ij} = \mathbf{q_i}^T \mathbf{k_j} = \sum_{l=1}^{d_k} q_{il} k_{jl}
$$

得分矩阵 $S = [s_{ij}] \in \mathbb{R}^{n \times n}$，其中 $s_{ij}$ 表示第 $i$ 个词元对第 $j$ 个词元的注意力得分。写成矩阵形式：

$$
S = Q^T K
$$

然后进行 **缩放**（Scaling）

$$
S_{scaled} = \frac{S}{\sqrt{d_k}} = \frac{Q^T K}{\sqrt{d_k}}\\[1ex]
S_{scaled_{ij}} = \frac{s_{ij}}{\sqrt{d_k}} = \frac{\mathbf{q_i}^T \mathbf{k_j}}{\sqrt{d_k}}
$$

:::tip[为什么要缩放]

假设 $\mathbf{q_i}$ 和 $\mathbf{k_j}$ 的每个元素都是独立同分布(i.i.d.)的随机变量，均值为 0，方差为 1，这俩做点积，均值为 0，方差和 $d_k$ 成正比：

$$
\mathbb{E}[\mathbf{q_i}^T \mathbf{k_j}] = \sum_{l=1}^{d_k} \mathbf{E}[q_{il}] \mathbb{E}[k_{jl}] = 0\\

\mathbb{D}[\mathbf{q_i}^T \mathbf{k_j}] = \sum_{l=1}^{d_k} \mathbb{D}[q_{il}k_{jl}] = \sum_{l=1}^{d_k} \mathbb{E}[q_{il}k_{jl}^2]- \mathbb{E}[q_{il}k_{jl}]^2 =\sum_{l=1}^{d_k} \mathbb{E}[q_{il}^2]\mathbb{E}[k_{jl}^2]-0 = d_k
$$

缩放之后，$\mathbb{D}[S_{scaled_{ij}}] = \mathbb{D}[\dfrac{\mathbf{q_i}^T \mathbf{k_j}}{\sqrt{d_k}}] = 1$，方差不再随 $d_k$ 增大而增大。

这个的作用是让梯度更稳定，从softmax函数的梯度公式： $\frac{\partial \text{softmax}(x_i)}{\partial x_j} = \text{softmax}(x_i)(\delta_{ij}-\text{softmax}(x_j))$ 如果输入的 $x_i>>x_j$，那么 $\text{softmax}(x_i)\approx 1$，$\text{softmax}(x_j)\approx 0$，梯度就会消失。

:::

再经过 softmax 归一化，得到注意力权重矩阵 $A = [A_{ij}] \in \mathbb{R}^{n \times n}$：

$$
A_{ij} = \frac{\exp(S_{scaled_{ij}})}{\sum_{k=1}^n \exp(S_{scaled_{kj}})}\\[1ex]
A=\text{softmax}\left(\frac{Q^T K}{\sqrt{d_k}}\right)
$$

这个注意力权重矩阵的 **每一列** 都是一个概率分布，表示第 $i$ 个词元对包含它自身在内的所有词元的注意力分布。

:::tip[关于归一化方向]

如果一开始就把 $Q$ 和 $K$ 的维度写成 $n \times d_k$，那么 $S=QK^T$，归一化就是对每一行做 softmax；如果写成 $d_k \times n$，那么 $S=Q^TK$，归一化就是对每一列做 softmax。两种写法本质相同，只是矩阵转置了。

:::

随后用注意力权重矩阵 $A$ 加权 Value 矩阵 $V$，得到输出矩阵 $Z$：

$$
Z = VA^T = V \cdot \text{softmax}\left(\frac{Q^T K}{\sqrt{d_k}}\right)^T
$$

这个输出矩阵 $Z \in \mathbb{R}^{d_v \times n}$，每一列 $\mathbf{z_i}$ 是第 $i$ 个词元的输出向量，它是所有词元的值向量的加权和，权重由注意力机制决定。

在transformer模块中，注意力层后面跟的是一个残差连接和一个归一化层，最终输出为：

$$
O= \operatorname{LayerNorm}(X + Z)
$$

## 多头注意力机制（Multi-Head Attention）

**多头** 指的是：将查询、键、值向量分别映射到 **多个子空间** 中，进行多次注意力计算，然后将结果拼接起来。

>有点类似于CNN中的多通道卷积，每个通道可以学习到不同的特征表示。这里每个头也可以看作是一个独立的注意力机制，它们可以关注输入序列的不同方面。

除了每个头各自拥有的 $W_Q^r,W_K^r,W_V^r$ 外，**多头注意力模块**还有一套 **共享** 参数 $W_O$。它不是第四种 Q/K/V 投影，也不直接作用于输入 $X$：每个头先完成注意力加权并得到低维输出，所有头的输出拼接后，才由 $W_O$ 将它们混合并写回原始嵌入空间。

整体数据流可以概括为：

$$
X\xrightarrow{W_Q^r,W_K^r,W_V^r}
Q^r,K^r,V^r
\xrightarrow{\mathrm{Attention}}
Z^r
\xrightarrow{\mathrm{Concat}}
Z_{concat}
\xrightarrow{W_O}
\Delta X
\xrightarrow{+X}
\xrightarrow{LayerNorm}
O
$$

### 每个头都是一个独立的self -attention

对于每个头 $r$，有独立的权重矩阵 $W_Q^r, W_K^r, W_V^r$，由于是多头，相当于把$d_{model}$ 给拆成了 $h$ 个头，每个头的维度通常是 $d_k=d_v=d/h$，所以每个头的 Q/K/V 投影矩阵的维度：$W_Q^r,W_K^r\in\mathbb R^{d_k\times d}$，$W_V^r\in\mathbb R^{d_v\times d}$。

$$
Q^r = W_Q^r X,\qquad
K^r = W_K^r X,\qquad
V^r = W_V^r X
$$

$$
A^r = \text{softmax}\left(\frac{(Q^r )^T (K^r )}{\sqrt{d_k}}\right)
$$

$$
Z^r = V^r A^{rT} = V^r  \cdot \text{softmax}\left(\frac{(Q^r )^T (K^r )}{\sqrt{d_k}}\right)^T
$$

### 拼接（Concatenate）所有头的输出

将 h 个头的输出矩阵在行方向（特征维度）上堆叠：$d_v$ 维的输出向量拼接成 $hd_v$ 维的向量，列数仍然是 $n$：

$$
Z_{concat} = [Z^1; Z^2; ...; Z^h] \in \mathbb{R}^{hd_v \times n}
$$

:::tip

在常见的行优先代码表示中，张量形状是 $n\times d_v$，所以会说“沿最后一个维度 拼接”；本质完全相同：固定 token 维度，拼接特征维度。

:::

### 输出回到原始维度，并通过残差+归一化更新

需要一个新参数矩阵 $W_O \in \mathbb{R}^{d \times hd_v}$，将拼接后的输出映射回原始嵌入空间。将这个映射结果记为注意力子层提供的更新量 $\Delta X$：

$$
\Delta X=W_OZ_{concat}\in\mathbb{R}^{d\times n}
$$

这里 $W_O$ 会混合各个头读出的信息，并将其翻译回原始的 $d$ 维嵌入空间；

残差连接：token的原始表示加注意力带来的上下文增量。归一化层则对输出进行标准化，使得后续层的输入分布更加稳定。

## 工程实现中的参数化变体

上文使用的是最清晰、也是原始 Transformer 中最常见的写法：每个词嵌入向量 $\mathbf{x_i}\in\mathbb{R}^{d}$ 分别经过三套独立参数，得到 Query、Key 和 Value：

$$
\mathbf{q_i}=W_Q\mathbf{x_i},\qquad
\mathbf{k_i}=W_K\mathbf{x_i},\qquad
\mathbf{v_i}=W_V\mathbf{x_i}
$$

这里 $W_Q\in\mathbb{R}^{d_k\times d}$、$W_K\in\mathbb{R}^{d_k\times d}$、$W_V\in\mathbb{R}^{d_v\times d}$，三者互不共享参数。但需要存储较多的 Key 和 Value，推理时 KV Cache 开销较大

$$
\text{KV Cache}
\propto 2LBT H_{kv}d_h

$$

- $L$：层数
- $B$：batch size
- $T$：序列长度
- $H_{kv}$：KV头数
- $d_h$：每个头的维度
- 系数 2 对应 K 和 V

实际工程中，为了降低参数量、计算量或 KV Cache 的显存占用，常会改变 **QKV 的参数化方式**；但注意力的基本计算逻辑仍是“用 $Q$ 与 $K$ 计算权重，再用权重加权 $V$”。

### 共享 KV：MQA 与 GQA

另一个常见工程优化并不是低秩分解，而是减少多头注意力中 Key 和 Value 的副本数。设有 $h$ 个 Query 头：

$$
\mathbf{q_i}^{(r)}=W_Q^{(r)}\mathbf{x_i},\qquad r=1,\ldots,h
$$

- **MQA（Multi-Query Attention）**：所有 Query 头共用同一组 $K,V$，即 $\mathbf{k_i}=W_K\mathbf{x_i}$、$\mathbf{v_i}=W_V\mathbf{x_i}$。这样解码时只需缓存一份 K/V。显存消耗减少为原来的 1/h
- **GQA（Grouped-Query Attention）**：将 $h$ 个 Query 头分成若干组；同一组共享一组 $K,V$。它在 MHA（每头独立 KV）与 MQA（全部头共享 KV）之间折中。显存消耗减少为原来的 G/h，其中 G 是组数。

两者中，Query 仍然由自己的 $W_Q^{(r)}$ 产生；被共享的是 K/V。主要收益是降低自回归推理时的 KV Cache 显存和带宽开销。
