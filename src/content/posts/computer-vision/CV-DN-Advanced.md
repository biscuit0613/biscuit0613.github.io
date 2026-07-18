---
title: '去噪前沿：CBDNet、自监督方法与新趋势'
published: 2026-07-01
description: 'CBDNet非对称损失与真实噪声建模、Noise2Void盲点架构、Neighbor2Neighbor成对子采样、Noise2Noise引用、SwinIR Transformer去噪、扩散模型去噪'
image: ''
tags: []
category: '08-计算机视觉'
order: 23
draft: false
lang: ''
---

DnCNN 和 FFDNet 在 AWGN 上表现优异，但真实场景中的噪声混合了多种来源，且不依赖干净图的训练需求也在增长。本篇概述几个重要的去噪前沿方向。

## 真实噪声建模：CBDNet

CBDNet（Convolutional Blind Denoising Network, Guo et al., 2019）针对真实场景中的盲去噪问题设计。真实噪声不符合 AWGN 的独立同分布假设，噪声水平与信号强度相关、受传感器增益和温度影响。CBDNet 用两个子网络分别处理噪声估计和去噪。

### 噪声估计子网络

输入含噪图像 $y$，输出逐像素的噪声水平图 $\hat{\sigma}(y)$。该子网络是一个浅层 FCN（5 层 Conv+ReLU），没有 BN 层（BN 会让噪声分布的信息在训练中被抹平）。$\hat{\sigma}(y)$ 的取值下限被限制为一个小正值，防止估计为零。

### 非对称损失

CBDNet 的关键贡献在于非对称损失函数。在真实数据上，没有一个"标准答案"式的噪声水平图做 ground truth。CBDNet 使用以下间接约束：

$$
\mathcal{L}_{\text{asym}} = \sum_i \left| \alpha - \mathbb{I}_{(\hat{\sigma}_i - \sigma_i < 0)} \right| \cdot (\hat{\sigma}_i - \sigma_i)^2
$$

其中 $\sigma_i$ 是从含噪图 $y$ 的局部方差估计的初始噪声水平。函数 $\mathbb{I}$ 是指示函数：当 $\hat{\sigma}_i < \sigma_i$（低估噪声）时系数为 $\alpha$，当 $\hat{\sigma}_i \geq \sigma_i$（高估噪声）时系数为 $1-\alpha$。取 $0 < \alpha < 0.5$，则低估噪声的惩罚比高估噪声更大。这种设计是因为：
- 低估噪声 → 去噪不足 → 残留噪声明显
- 高估噪声 → 去噪过度 → 图像过平滑 → 视觉上更容易接受

### 去噪子网络

接收含噪图 $y$ 和估计的 $\hat{\sigma}(y)$ 作为输入，采用 U-Net 风格结构输出干净估计 $\hat{x}$。在合成噪声 + 真实噪声混合数据上训练。

## 自监督去噪

自监督去噪不依赖干净-含噪图像对，仅利用含噪数据本身完成训练。

### Noise2Noise（N2N）

Noise2Noise 证明了对同一场景的两张独立含噪观测 $(y_1, y_2)$，用 $L_2$ 损失训练 $f(y_1)$ 逼近 $y_2$ 等价于逼近干净图——只要噪声零均值。详细推导参见 `CV-PriorInLowLevelVision.md`。

### Noise2Void（N2V）与盲点架构

N2Noise 仍然需要成对观测，在实际应用中（如单张显微图像去噪）很难获取。Noise2Void（Krull et al., 2019）仅需单张含噪图。

N2V 的核心是盲点（blind-spot）架构：网络预测一个像素 $i$ 的值时，$i$ 位置自身的像素被隐藏（masked out），只能用其邻域像素推断。损失函数为该位置的预测值与实际含噪值的差异。由于噪声是像素独立的而信号是空间相关的，网络无法通过"记住"输入噪声来降低损失——它必须学习邻域像素的结构信息来推理中心像素，从而输出干净信号。

### Neighbor2Neighbor

Neighbor2Neighbor（Huang et al., 2021）从单张含噪图中构造出两组等价的子观测。将含噪图通过均匀子采样生成两个子图 $g_1(y)$ 和 $g_2(y)$，两个子图的空间位置不重叠，因此噪声独立。然后以 $f(g_1(y)) \approx g_2(y)$ 为目标训练，与 N2Noise 的框架相同。子采样的正则化项防止网络退化为简单的插值。

### 自监督方法谱系

| 方法 | 需要成对数据 | 依赖信号独立性 | 典型场景 |
|------|------------|-------------|---------|
| N2N | 是（两次观测） | 否 | 摄影、视频 |
| N2V | 否（单张） | 是（盲点架构） | 显微图像 |
| N2S | 否 | 是（subsampling） | 显微图像 |
| Neighbor2Neighbor | 否 | 是（子采样 + 正则化） | 自然图像 |
| AP-BSN / BNN | 否 | 是（多策略盲点） | 通用 |

## 当前趋势：Transformer 与扩散模型

### SwinIR

SwinIR（Liang et al., 2021）将 Swin Transformer 引入图像恢复。它用移位窗口自注意力替代卷积，在去噪、超分、JPEG 去块等任务上都超越了 CNN 时代的方法。SwinIR 的结构包含浅层特征提取、深层 Transformer 特征提取（多个 RSTB 模块）和图像重建模块三个阶段。

### 扩散模型用于去噪

扩散模型（Denoising Diffusion Probabilistic Models, DDPM）本身就是一个从噪声到数据的生成过程。利用预训练的扩散模型做盲去噪是近年来的新趋势，核心思路是将去噪视为一个逆向扩散过程的条件生成问题（给定 $y$ 生成 $x$）。扩散模型在高噪声水平和真实噪声场景上的表现优于专用去噪网络，但推理速度远慢于 DnCNN 和 FFDNet。
