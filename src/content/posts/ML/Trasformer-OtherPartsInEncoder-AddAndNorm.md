---
title: Trasformer-编码器的其他部分：Add&Norm
published: 2026-06-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 34
draft: false 
lang: ''
---

Add: 指残差连接（Residual Connection），也叫跳跃连接（Skip Connection）

Norm: 指层归一化（Layer Normalization）

这俩加一块解决了深度神经网络训练中梯度消失/爆炸的问题，保证了训练的稳定性和收敛速度。

先看 Transformer 的一个标准 block，包含两次残差连接和两次层归一化：

![alt text](assets/image-28.png)

## 残差连接（Residual Connection）

对于一个子层（SubLayer，可以是多头注意力或前馈网络），把他的输出记作 $S\mathcal{F}(X_{in})$，那么残差连接的输出 $X_{out}$ 就是：

$$
X_{out} = X_{in} + \mathcal{F}(X_{in})
$$

结合CNN里讲的ResNet残差块，残差连接的作用就是让网络可以直接学习恒等映射（Identity Mapping），而不是强迫网络去学习一个复杂的非线性映射。

## 层归一化（Layer Normalization）

层归一化对**单个样本**的所有**特征维度**进行标准化（注意区分Batch Norm是对同一批次所有样本的同一个特征做标准化）。

一个子层的输入 $X_{in}\in\mathbb{R}^{n, d}$，那么层归一化的计算公式为：（对于输入序列的一行$\mathbf{x}_i\in\mathbb{R}^{1, d}$，索引j遍历所有特征维度）

$$
\mu_i = \frac{1}{d}\sum_{j=1}^{d} x_{ij}, \quad \sigma^2_i = \frac{1}{d}\sum_{j=1}^{d} (x_{ij} - \mu_i)^2\\[1ex]
\hat{x}_{ij} = \frac{x_{ij} - \mu_i}{\sqrt{\sigma^2_i + \epsilon}}, \quad LN(x_{ij}) = \gamma \hat{x}_{ij} + \beta
$$

其中 $\mu_i$ 和 $\sigma^2_i$ 分别是第 $i$ 个样本在特征维度上的均值和方差，$\epsilon$ 是一个小常数以避免除零错误，$\gamma$ 和 $\beta$ 是可学习的缩放和偏移参数。

拓展到整个输入矩阵 $X_{in}$，层归一化的每一步和最终输出可以表示为：

:::tip

在实际的代码中，算完均值向量之后会进行广播变成 $n\times d$ 的矩阵，求方差时和 $X_{in}$ 做差,逐元素平方再求逐行均值，最后再广播回去。这样可以充分利用矩阵运算的并行性。

:::

$$
\mathbf{\mu} = [\mu_1, \mu_2, \ldots, \mu_n]^T(n\times1\rightarrow n\times d) \quad \mathbf{\sigma}^2 = [\sigma^2_1, \sigma^2_2, \ldots, \sigma^2_n]^T\\[1ex]
\hat{X}_{in} = \frac{X_{in} - \mathbf{\mu}}{\sqrt{\mathbf{\sigma}^2 + \epsilon}} \quad LN(X_{in}) = \gamma\odot\hat{X}_{in} + \beta
$$

- $\odot$ 表示逐元素乘法（Hadamard Product）
- $\gamma$ 和 $\beta$ 是 $1\times d$ 的向量，分别表示每个特征维度的缩放和偏移参数。
- 这俩参数在计算时会广播成 $n\times d$ 的矩阵。

### 为什么不用 Batch Norm（批归一化）？

Batch Norm在CNN中极其成功，但在Transformer/NLP中水土不服，原因有三：

1. 序列长度变化：NLP中每句话长短不一。Batch Norm依赖于批次统计量（均值和方差），如果某个Batch恰好全是短句子，其统计量会严重偏离长句子的分布，导致训练不稳定。

2. 训练与推理不一致：Batch Norm在训练时用Batch统计量，推理时用全局滑动平均。这在NLP中容易造成性能抖动。

3. 并行计算干扰：在自注意力中，不同样本之间的关联性已经很强，Batch Norm会进一步引入样本间的依赖，反而容易引入噪声。

层归一化则完全独立于Batch，只依赖单个样本自身，天然适配变长序列。

把子层记作一个映射 $\mathcal{F}(X_{in})$，把层归一化记作 $\mathcal{LN}(\cdot)$，那么一个标准的 Transformer block 可以表示为：

## Pre-LN vs Post-LN

Post-LN（原始论文的做法）：

$$
\mathcal{LN}(X_{in} + \mathcal{F}(X_{in}))
$$

Pre-LN 现代主流实现（Pre-Norm，如GPT、LLaMA、ViT等）：

$$
X_{in} + \mathcal{F}(\mathcal{LN}(X_{in}))
$$

Post-Norm的问题：在深层网络中，残差路径的梯度虽然直通，但紧接着就进入LayerNorm。如果LayerNorm的梯度不稳定（尤其是早期训练阶段），仍可能放大噪声。

Pre-Norm的优势：它将所有子层（注意力/FFN）的输入都“摆正”（归一化到0均值1方差），使得子层的优化更加平稳。更重要的是，残差连接本身不受归一化影响，梯度可以直接“流过”加法路径，不用穿过LayerNorm。

### Pre-LN 架构的梯度分析

对于多头注意力子层$\mathcal{F}$，假设输入为 $X_l$，输出为 $X_{l+1}$，残差连接为 $X_{l+2} = X_l + \mathcal{F}(\mathcal{LN}(X_{in}))$。

损失函数 $L$ 对 $X_{l+2}$ 的梯度为 $\frac{\partial L}{\partial X_{l+2}}$，那么对 $X_l$ 的梯度为：

$$
\frac{\partial L}{\partial X_l} = \frac{\partial L}{\partial X_{l+2}} \cdot \left( I + \frac{\partial \mathcal{F}(\mathcal{LN}(X_l))}{\partial X_l} \right)
$$

这个公式说明了梯度可以直接通过残差连接的 $I$ 项传递，而不受 $\mathcal{F}$ 的影响，更不受 $\mathcal{LN}$ 的影响，从而保证了梯度的稳定性。
