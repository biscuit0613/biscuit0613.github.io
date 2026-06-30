---
title: 'StyleGAN：解耦隐空间与层级化生成'
published: 2026-07-01
description: 'Mapping Network与W空间的解耦性质、Synthesis Network逐级分辨率生成、AdaIN风格注入、Style Mixing正则化、Truncation Trick、StyleGAN2/3改进方向'
image: ''
tags: []
category: '计算机视觉'
order: 26
draft: false
lang: ''
---

StyleGAN（Karras et al., 2019）在 FFHQ 人脸数据集上达到了当时最逼真的生成效果。更重要的是它引入了一套精心设计的隐空间结构，使生成过程的不同属性（姿态、肤色、发型、纹理）可以在不同层级上独立控制。这套设计在后来的图像编辑和反演工作中被反复使用。

## 从 Z 到 W：Mapping Network

传统 GAN 将随机噪声 $z$ 直接输入生成器第一层。StyleGAN 在中间插入一个 Mapping Network，将 $z$ 映射到一个中间隐空间 $W$。

### Mapping Network 结构

$$
z \in \mathbb{R}^{512} \xrightarrow{\text{FC} \rightarrow \text{BN} \rightarrow \text{ReLU} \times 8} w \in \mathbb{R}^{512}
$$

Mapping Network 是 8 层全连接网络。输入 $z$ 来自标准高斯分布 $\mathcal{N}(0, I)$，输出 $w$ 的分布通过 MLP 学习变换后不再是标准高斯。变换使 $W$ 空间中不同维度之间的相关性被削弱。

### 为什么 Mapping Network 产生解耦

$Z$ 空间服从各向同性的高斯分布，其所有维度具有相同的方差。如果直接用 $z$ 控制生成，噪声向量中任何一个方向的变化都会同等程度地影响所有生成属性——网络无法对不同属性"分配"不同的敏感度。

Mapping Network 将各向同性的 $Z$ 映射到非各向同性的 $W$：$W$ 空间中不同方向携带不同方差，网络可以自行决定哪些方向对应哪些语义属性（姿态、肤色、性别等）。这种"自动分配"就是解耦（disentanglement）的核心机制。

## Synthesis Network：层级化生成

Synthesis Network 从 $4\times4$ 的特征图开始，通过 8 个分辨率级别（$4^2 \rightarrow 8^2 \rightarrow 16^2 \rightarrow \dots \rightarrow 1024^2$）逐级上采样生成最终图像。每级分辨率包含两个 $3\times3$ 卷积和一个 $2\times$ 上采样。

与传统 GAN 不同，Synthesis Network 的**每一层**都接收经 AdaIN 调整后的风格信息。

## AdaIN：风格注入

AdaIN（Adaptive Instance Normalization）将来自 $W$ 空间的风格向量注入到当前层的特征图中：

$$
\text{AdaIN}(x_i, w) = \gamma_i(w) \cdot \frac{x_i - \mu(x_i)}{\sigma(x_i)} + \beta_i(w)
$$

其中 $x_i$ 是第 $i$ 层特征图的某个通道，$\mu$ 和 $\sigma$ 在单样本的空间维度和通道上计算（Instance Normalization）。$\gamma_i$ 和 $\beta_i$ 由 $w$ 经过一个小的全连接层生成。

AdaIN 只改变当前层的风格统计量（均值和方差），不破坏空间结构。不同层级的 AdaIN 控制不同尺度的特征：浅层控制姿态和粗略形状，中层控制面部特征，深层控制颜色和纹理等细节。

:::tip TODO

在此处插入 StyleGAN 架构示意图（Mapping Network + Synthesis Network + AdaIN 注入点）

:::

## Style Mixing

训练时将同一 batch 中的两张图 $(z_1, z_2)$ 分别映射到 $(w_1, w_2)$，在合成网络中跨越层级混合：前 $k$ 层用 $w_1$，后 $N-k$ 层用 $w_2$。损失仅计算混合图像的真伪。

Style Mixing 有两个作用。正则化角度：防止网络让相邻层对 $w$ 的响应高度相关，强制各层风格控制独立。效果角度：跨层混合使生成器学会将不同层级的属性分离。

## Truncation Trick

训练完成后，$W$ 空间中大多数样本落在某一中心区域附近，离中心较远的样本对应罕见或极端特征。Truncation Trick 在推理时将 $w$ 向均值 $\bar{w}$ 拉近：

$$
w' = \bar{w} + \psi \cdot (w - \bar{w}), \quad \psi \in [0, 1]
$$

$\psi=1$ 保留全部分散度（多样性最大，可能有伪影）；$\psi \approx 0.7$ 是常见折中（质量高、多样性略有下降）；$\psi=0$ 所有结果退化为均值图像。Truncation Trick 为图像质量与多样性之间提供了可调杠杆。

## StyleGAN2 / 3 的主要改进方向

- **StyleGAN2**：去掉 AdaIN 中的 Instance Normalization，改用权重解调（weight demodulation），消除了水滴伪影。
- **StyleGAN3**：引入等变约束，使生成图像在平移和旋转时特征也相应平滑变化，提升了对精细纹理的生成连贯性。
