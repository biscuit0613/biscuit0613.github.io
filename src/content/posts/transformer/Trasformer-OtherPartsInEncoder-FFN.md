---
title: Trasformer-OtherPartsInEncoder-FFN
published: 2026-06-28
description: ''
image: ''
tags: []
category: '05-注意力与Transformer'
order: 35
draft: false 
lang: ''
---

这里讲解 Transformer Block 中的前馈网络（Feed Forward Network，FFN）。它是编码器和解码器中的重要子层，通常位于多头注意力子层之后。

![alt text](assets/image-28.png)

## 逐位置

在 Transformer 中，前馈网络是逐位置（position-wise）的：它对输入中 **每个位置** 的词嵌入独立地应用 **同一套** 前馈网络参数，不涉及其他位置的信息。也就是说，FFN 对每个 token 的表示都是独立处理的，参数矩阵在所有位置共享。

## 公式

为与自注意力一节保持一致，以下采用**列优先**表示：$X_{in}\in\mathbb{R}^{d\times n}$，其中每一列 $\mathbf{x}_i\in\mathbb{R}^{d}$ 是第 $i$ 个 token 的表示；$n$ 是序列长度，$d$ 是特征维度。这个输入通常来自前一注意力子层；残差连接与 LayerNorm 的具体顺序见 [Add & Norm](/posts/transformer/trasformer-otherpartsinencoder-addandnorm/)。

一个标准的FFN包含两个线性层（Linear Layers），中间夹一个非线性激活函数（原始Transformer用ReLU，现代GPT/ViT多用GELU）。对于输入 $X_{in}$以及其单个token的 $\mathbf{x}_i$，前馈网络的计算公式为：

$$
\operatorname{FFN}(X_{in}) = W_2\,\sigma\left(W_1X_{in}+\mathbf{b}_1\mathbf{1}_n^T\right)+\mathbf{b}_2\mathbf{1}_n^T\\[1ex]
\operatorname{FFN}(\mathbf{x}_i) = W_2\,\sigma\left(W_1\mathbf{x}_i+\mathbf{b}_1\right)+\mathbf{b}_2
$$

其中 $\sigma$ 是逐元素激活函数，例如 ReLU 或 GELU；$\mathbf{1}_n\in\mathbb{R}^{n}$ 用于将偏置广播到所有 token 列。由单个位置的公式可见，FFN 对每个 $\mathbf{x}_i$ 都是独立处理的；参数矩阵 $W_1,W_2$ 与偏置向量 $\mathbf{b}_1,\mathbf{b}_2$ 则在所有位置共享。

注意参数矩阵的维度

- $W_1\in\mathbb{R}^{d_{ff}\times d}$，$\mathbf{b}_1\in\mathbb{R}^{d_{ff}}$ 用于将输入投影到更高维的隐藏空间，通常 $d_{ff}$ 比 $d$ 大很多（例如 $d_{ff}=4d$）。
- $W_2\in\mathbb{R}^{d\times d_{ff}}$，$\mathbf{b}_2\in\mathbb{R}^{d}$ 用于将隐藏空间投影回原始维度。

### 第一层线性变换

理解第一层线性变换，可以把矩阵 $W_1\in\mathbb{R}^{d_{ff}\times d}$ 看作一个 $d_{ff}$ 个 **行向量** 的集合，而输入 $X_{in}\in\mathbb{R}^{d\times n}$ 是一个 $n$ 个列向量的集合。矩阵乘法 $W_1X_{in}$ 的结果是一个 $d_{ff}\times n$ 的矩阵，其中第 $j$ 列是输入序列中第 $j$ 个 token 的表示 $\mathbf{x}_j$ 与 $W_1$ 每个行向量的点积结果。

$$
\begin{bmatrix}
\leftarrow \mathbf{w}_1\rightarrow\\
\leftarrow \mathbf{w}_2\rightarrow\\
\vdots\\
\leftarrow \mathbf{w}_{d_{ff}}\rightarrow
\end{bmatrix}
\begin{bmatrix}
\uparrow \\
\mathbf{x}_j \\
\downarrow \\
\end{bmatrix}
=
\begin{bmatrix}
    \mathbf{w}_1\cdot \mathbf{x}_j \\ \mathbf{w}_2\cdot \mathbf{x}_j \\ \cdots \\ \mathbf{w}_{d_{ff}}\cdot \mathbf{x}_j
\end{bmatrix}
$$

### 第二层线性变换

理解第二层线性变换，可以把矩阵 $W_2\in\mathbb{R}^{d\times d_{ff}}$ 看作一个 $d_{ff}$ 个列向量的集合，将矩阵的每一列分别与输入向量 $\mathbf{h}$（第一层激活输出）中的对应元素相乘，然后将所有经过缩放后的列相加起来。

$$
\begin{bmatrix}
\uparrow & \uparrow & \cdots & \uparrow \\
\mathbf{w}_1 & \mathbf{w}_2 & \cdots & \mathbf{w}_{d_{ff}} \\
\downarrow & \downarrow & \cdots & \downarrow \\
\end{bmatrix}
\begin{bmatrix}
h_1 \\ h_2 \\ \vdots \\ h_{d_{ff}}
\end{bmatrix}
=
h_1\mathbf{w}_1 + h_2\mathbf{w}_2 + \cdots + h_{d_{ff}}\mathbf{w}_{d_{ff}}
$$

$W_2$ 的 **列** 与 **嵌入空间** 具有相同的维度，因此我们可以将列视为该空间中的各个方向。

结合激活函数的影响，输入第二层的列向量中的每个元素，被激活函数放大（正向）的元素会，会导致 $W_2$ 中对应的列对输出产生更大的贡献，而被抑制（负向或0）的元素则导致 $W_2$ 中对应的列对输出产生较小的贡献。

## 为什么需要FFN

如果把 Transformer 比作一个“办公流程”：

- 多头注意力是“开会讨论”（Token 间互相传递消息，确认“谁对谁重要”）；

- FFN 则是“散会后回工位独立处理”（每个 Token 拿着开会得出的纪要，回到自己的高维思维空间里深思熟虑，过滤掉噪声，只提取对自己最有用的模式，最后写成新的汇报提交）。

常见的 $d_{ff}=4d$ 是经验性的宽度设置；更宽的隐藏层能容纳更多特征组合与参数容量，但会增加计算和显存开销。现代模型也会采用其他扩张比例或门控 FFN（如 SwiGLU）。

FFN 本质上是一个庞大的 Key-Value 记忆网络。

- 第一层的权重（和偏置）可以看作是一组 Key（键）。

- 第二层的权重（的每一行）可以看作是对应的 Value（值）。

计算过程：输入向量与所有 Key 做点积（计算相似度），经过激活函数过滤，再加权组合对应的 Value 输出。FFN 的两层计算产生一个“增量更新量”（Delta）。

## CNN中的1x1卷积和FFN的相似

在 CNN 中，1×1 卷积的作用是跨通道混合信息：只混合特征维度 $c$，不混合空间维度 $(H,W)$。

在 ViT 中，FFN 也是只混合特征维度 $d$，完全不混合序列维度 $n$。

多头注意力负责混合“空间/序列”信息（类似CNN的大卷积核），而FFN负责混合“通道/特征”信息（类似
CNN的1×1 卷积）。这种“空间-通道”交替处理的范式，是视觉模型（无论是CNN还是Transformer）的共同底层逻辑。
