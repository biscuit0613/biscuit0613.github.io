---
title: Trasformer-OtherPartsInEncoder-FFN
published: 2026-06-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 35
draft: false 
lang: ''
---

这里讲解码器的前馈网络（Feed Forward Network，FFN），它是 Transformer 编码器和解码器中每个子层的一个重要组成部分。也是 Transformer block 中的第二个子层（第一个子层是多头注意力）。

![alt text](image-28.png)

## 逐位置

在transformer中，前馈网络是逐位置（position-wise）的，也就是说，它对**每个位置**的表示独立地应用 **相同** 的前馈网络。

## 公式

假设输入序列的表示为 $X\in\mathbb{R}^{n, d}$，其中 $n$ 是序列长度，$d$ 是特征维度

一个标准的FFN包含两个线性层（Linear Layers），中间夹一个非线性激活函数（原始Transformer用ReLU，现代GPT/ViT多用GELU）。

$$
FFN(X) = \max(0, XW_1 + \mathbf{b_1})W_2 + \mathbf{b_2}\\[1ex]
\text{for} \mathbf{x}_i\in X,\mathbf{x}_i\in\mathbb{R}^{1, d}, \\ FFN(\mathbf{x}_i) = \max(0, \mathbf{x}_iW_1 + \mathbf{b_1})W_2 + \mathbf{b_2}
$$

从下面的公式可以看出，FFN对每个位置的向量 $\mathbf{x}_i$ 都是独立处理的，**不涉及其他位置的信息**。而且参数矩阵 $W_1, W_2$ 和偏置向量 $\mathbf{b_1}, \mathbf{b_2}$ 在所有位置共享。

注意参数矩阵的维度

- $W_1\in\mathbb{R}^{d, d_{ff}}$，$\mathbf{b_1}\in\mathbb{R}^{d_{ff}}$
- $W_2\in\mathbb{R}^{d_{ff}, d}$，$\mathbf{b_2}\in\mathbb{R}^{d}$

$d_{ff}$ 是前馈网络的隐藏层维度，通常比 $d$ 大很多（例如 $d_{ff}=4d$）。

## 为什么需要FFN

注意力本质上是“线性组合”：多头注意力做的事情本质上是**加权求和**（**线性组合**）。如果不加FFN，把多个注意力层堆叠起来，数学上等价于一个线性变换（因为线性变换的复合还是线性变换）。

FFN提供“非线性”：扩宽后的FFN + 激活函数，给了模型独立于注意力之外的强大非线性表达能力。它把每个位置的向量先“投影”到一个高维空间（4倍宽），在这个空间里做**非线性变换**（GELU/ReLU），再投影回原来的维度。

至于为什么要扩宽4倍，应该是为了有足够的“神经元储备”去挖掘特征组合，说白了就是堆参数。

## CNN中的1x1卷积和FFN的相似

在CNN中，1×1 卷积的作用是跨通道混合信息（即只混合特征维度 c，不混合空间维度 (H,W)。

在ViT中，FFN也是只混合特征维度 d , 完全不混合序列维度 n

多头注意力负责混合“空间/序列”信息（类似CNN的大卷积核），而FFN负责混合“通道/特征”信息（类似
CNN的1×1 卷积）。这种“空间-通道”交替处理的范式，是视觉模型（无论是CNN还是Transformer）的共同底层逻辑。
