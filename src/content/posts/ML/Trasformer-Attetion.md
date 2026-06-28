---
title: Trasformer-编码器核心：self-attention自注意力机制
published: 2026-06-27
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 28
draft: false 
lang: ''
---

Transformer的架构由编码器（Encoder） 和解码器（Decoder） 两大部分组成

这里重点介绍编码器部分的核心机制：**自注意力机制（Self-Attention）**，它是Transformer的核心创新之一。

## 符号

:::tip

工程上，行优先，常见于代码，例如$X\in \mathbb{R}^{n \times d}$；列优先，常见于数学公式。这里为了方便理解，采用列优先的方式。两者在乘积顺序和转置上面有一点区别，但本质上是一样的。

:::

| 符号                               | 含义                                             |
| ---------------------------------- | ------------------------------------------------ |
| $n$                                | 输入序列的长度（词元个数）                       |
| $d$                                | 词嵌入向量的维度                                 |
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

| 参数                                | 含义                                                 |
| ----------------------------------- | ---------------------------------------------------- |
| $W_Q\in \mathbb{R}^{d_k \times d}$  | 查询的权重矩阵                                       |
| $W_K\in \mathbb{R}^{d_k \times d}$  | 键的权重矩阵                                         |
| $W_V\in \mathbb{R}^{d_v \times d}$  | 值的权重矩阵                                         |
| $W_O\in \mathbb{R}^{d \times hd_v}$ | 输出的权重矩阵，用于将多头注意力的输出映射回原始维度 |

## "自" 参注意力

在机器翻译中，传统的注意力（Cross-Attention，交叉注意力）是：解码器在生成“苹果”这个词时，去编码器里找输入句子“I love apples”中哪个词（I / love / apples）最相关。

而自注意力中的“自”指的是：Query（查询）、Key（键）、Value（值）这三个向量，全部来自同一个输入序列本身。

## 前置概念

词嵌入向量（Embedding）：每个输入词都会被映射为一个高维向量，称为词嵌入向量。假设输入序列长度为 $n$，每个词的嵌入维度为 $d$，则输入序列可以表示为一个矩阵 $X=[\mathbf{x_1}, \mathbf{x_2}, ..., \mathbf{x_n}] \in \mathbb{R}^{d \times n}$。

为了计算注意力，需要为每个词生成**三个**不同的向量。这三个向量是通过三个可训练的权重矩阵与输入向量相乘得到的：

- Query（查询）向量 $Q = W_QX=[\mathbf{q_1}, \mathbf{q_2}, ..., \mathbf{q_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_Q \in \mathbb{R}^{d_k \times d}$ 是查询的权重矩阵，$d_k$ 是查询向量的维度。
  - “提问者”。这个词想知道：“在当前语境下，我应该关注谁？”
- Key（键）向量 $K = W_KX=[\mathbf{k_1}, \mathbf{k_2}, ..., \mathbf{k_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_K \in \mathbb{R}^{d_k \times d}$ 是键的权重矩阵。
  - “被问者”。这个词说：“我的特征是XXX，看看你要找的是不是我？”
- Value（值）向量 $V = W_VX=[\mathbf{v_1}, \mathbf{v_2}, ..., \mathbf{v_n}]\in \mathbb{R}^{d_v \times n}$，
  - 其中 $W_V \in \mathbb{R}^{d_v \times d}$ 是值的权重矩阵，$d_v$ 是值向量的维度。
  - “实际内容”。一旦确认了“提问者”和“被问者”很匹配，这就是我实际要传递给你的具体语义信息。

## self-attention计算步骤

### 第1步：计算注意力得分（点积）

计算任意两个词元 $i$ 和 $j$ 的注意力得分（标量）

$$
s_{ij} = \mathbf{q_i}^T \mathbf{k_j} = \sum_{l=1}^{d_k} q_{il} k_{jl}
$$

得分矩阵 $S = [s_{ij}] \in \mathbb{R}^{n \times n}$，其中 $s_{ij}$ 表示第 $i$ 个词元对第 $j$ 个词元的注意力得分。

$$
S = Q^T K
$$

### 第2步：缩放 + Softmax（按行做 Softmax，使每一行之和为 1）

$$
A = \text{softmax}\left(\frac{S}{\sqrt{d_k}}\right)
$$

A是注意力权重矩阵，$A \in \mathbb{R}^{n \times n}$，其中 $A_{ij}$ 表示第 $i$ 个词元对第 $j$ 个词元的注意力权重。

### 第3步：加权求和(对应的Value向量)

对于每个词元 $i$，其输出向量 $\mathbf{z_i}$ 是所有值向量的加权和：

$$
\mathbf{z_i} = \sum_{j=1}^{n} A_{ij} \mathbf{v_j}
$$

写成矩阵形式：

$$
Z = VA^T\in \mathbb{R}^{d_v \times n}
$$

### 写成矩阵形式

$$
Z = VA^T = V \cdot \text{softmax}\left(\frac{Q^T K}{\sqrt{d_k}}\right)^T
$$

## 多头注意力机制（Multi-Head Attention）

多头指的是：将查询、键、值向量分别映射到多个子空间中，进行多次注意力计算，然后将结果拼接起来。

有点类似于CNN中的多通道卷积，每个通道可以学习到不同的特征表示。这里每个头也可以看作是一个独立的注意力机制，它们可以关注输入序列的不同方面。

### 每个头的QKV以及输出

对于每个头 $r$，有独立的权重矩阵 $W_Q^r, W_K^r, W_V^r$，计算得到每个头的输出 $Z^r$：

$$
Z^r = V^r A^{rT} = V^r  \cdot \text{softmax}\left(\frac{(Q^r )^T (K^r )}{\sqrt{d_k}}\right)^T
$$

### 拼接（Concatenate）所有头的输出

将 h 个头的输出矩阵在行方向（特征维度）上堆叠：

$$
Z_{concat} = [Z^1; Z^2; ...; Z^h] \in \mathbb{R}^{hd_v \times n}
$$

### 输出回到原始维度

需要一个新参数矩阵 $W_O \in \mathbb{R}^{d \times hd_v}$，将拼接后的输出映射回原始维度：

$$
Z_{final} = W_O Z_{concat} \in \mathbb{R}^{d \times n}
$$

### 小巧思

对于嵌入维度 $d$，通常选择 $d_k = d_v = d/h$，这样每个头的输出维度为 $d_v$，拼接后总维度为 $hd_v = d$，与输入维度一致。

- 不增加总参数量。
- 这种“降维投影 + 多头并行”的设计，强迫每个头必须在低维空间（64 维）里寻找特征。由于每个头的初始权重随机且独立训练，它们会自然演化出不同的关注重点（有的擅长局部纹理，有的擅长全局形状）。
