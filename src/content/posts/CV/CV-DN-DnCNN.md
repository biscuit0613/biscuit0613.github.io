---
title: DnCNN：残差学习的CNN去噪
published: 2026-07-01
description: 'DnCNN问题定义、残差学习策略（F(y)≈n, x̂=y-F(y)）、Conv+BN+ReLU架构、噪声水平图（noise level map）、L₂损失函数'
image: ''
tags: []
category: '计算机视觉'
order: 21
draft: false
lang: ''
---

DnCNN（Zhang et al., 2017）是深度学习图像去噪的里程碑工作。它将图像去噪形式化为一个端到端的残差学习问题，用深度卷积网络拟合噪声而非干净图像，配合批次归一化（BN）在 AWGN 去噪上取得了当时最优的结果。

## 问题定义

给定干净图像 $x$、噪声 $n$、含噪观测 $y = x + n$，目标是估计 $\hat{x}$ 使其尽可能接近 $x$。

传统监督学习范式学习从 $y$ 到 $x$ 的直接映射：$f(y) \approx x$。DnCNN 的核心变化是**学习从 $y$ 到 $n$ 的残差映射**：

$$
F(y) \approx n, \quad \hat{x} = y - F(y)
$$

残差学习利用了去噪问题的一个特性：干净图像到含噪图像的映射接近恒等映射（因为噪声能量通常远小于信号能量）。网络只需学习噪声部分，而噪声的结构远比图像简单——零均值、分布固定、无纹理模式。这使得网络的优化路径更短、收敛更快。

与 ResNet 的残差连接（skip connection 传递信号梯度）不同，DnCNN 的残差是**学习目标**的残差化，而非网络结构的残差化。两者共享"拟合残差比拟合原映射更容易"的思想，但作用层面不同。ResNet 的残差结构参见 ML 篇 `CNN-ResNet.md`。

## 网络结构

DnCNN 是一个全卷积网络（不包含全连接层或池化层），输入和输出尺寸相同。结构分为三层：

### 输入层

```
Conv(3×3, c→64) + ReLU
```

$c$ 为输入通道数：灰度图为 1，彩色图为 3。这是不包含 BN 的单层。

### 中间层（重复 $d$ 次）

```
Conv(3×3, 64→64) + BN + ReLU
```

$d$ 是深度参数。对于 AWGN 去噪，$d=15$ 或 $17$。每层 64 个 $3\times3$ 卷积核。BN 层插入在卷积和 ReLU 之间，起到稳定训练分布、加速收敛的作用。BN 的计算细节参见 ML 篇 `CNN-BatchNorm.md`。

### 输出层

```
Conv(3×3, 64→c)
```

输出残差图像 $F(y)$。不附加任何激活函数。

总层数：$1 + d + 1 = d+2$ 层。DnCNN 的深度（17–20 层）超过了当时的典型分类网络，足够大的感受野（约 $35\times35$ 到 $41\times41$）使其能捕获中远距离的上下文信息。

### 整体计算图

$$
y \xrightarrow{\text{Conv+ReLU}} \xrightarrow{(\text{Conv+BN+ReLU}) \times d} \xrightarrow{\text{Conv}} F(y) \xrightarrow{\hat{x} = y - F(y)} \hat{x}
$$

## 噪声水平图（Noise Level Map）

传统去噪算法（如 BM3D）需要输入噪声标准差 $\sigma$，不同的 $\sigma$ 需要不同的参数，导致无法用单一模型处理多噪声水平。DnCNN 通过向输入网络额外拼接一张噪声水平图来解决这个问题。

将 $\sigma$ 展开为与图像同尺寸的通道，与含噪图像 $y$ 沿通道维度拼接：

$$
\text{Input} = [y; \ \sigma \cdot \mathbf{1}] \in \mathbb{R}^{H \times W \times (c+1)}
$$

$\mathbf{1}$ 是全 1 矩阵。网络输入层的第一层卷积核变为 $(c+1) \to 64$。

这种方式使得单一 DnCNN 模型可以覆盖 $\sigma \in [0, 55]$ 的连续噪声水平。训练时每个 batch 的 $\sigma$ 从该区间中随机采样，提高泛化能力。

## 损失函数与训练

DnCNN 使用像素级的均方误差（MSE）作为损失函数：

$$
\mathcal{L}(\Theta) = \frac{1}{2} \| F(y; \Theta) - n \|^2
$$

$\Theta$ 为网络参数。等价于在输出端最大化 PSNR（因为 $L_2$ 损失最小化等价于 MSE 最小化等价于 PSNR 最大化）。

训练数据：$128\times128$ 或 $64\times64$ 的 patches，从 BSD400/500 或 ImageNet 等自然图像数据集中提取。优化器 Adam，初始学习率 $10^{-3}$，逐步衰减。

## DnCNN 的扩展应用

DnCNN 不仅适用于 AWGN 去噪，通过微调训练数据还可以推广到其他任务：

- **高斯去噪**：$\sigma \in [0, 55]$ 的 AWGN
- **超分**：双三次降采样的 LR↔HR 对
- **JPEG 去块**：不同质量因子的压缩伪影

这种"一个架构对应多个底层视觉任务"的特性也得益于其全卷积设计——不同任务只改变训练数据的生成方式，网络结构完全不变。
