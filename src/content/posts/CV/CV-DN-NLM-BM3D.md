---
title: '传统去噪：NLM与BM3D'
published: 2026-07-01
description: 'NLM非局部均值去噪：搜索窗口、相似度权重、加权平均；BM3D两步流程：Block Matching→3D变换→硬阈值/Wiener滤波→聚合；NLM与BM3D对比'
image: ''
tags: []
category: '计算机视觉'
order: 20
draft: false
lang: ''
---

高斯滤波、中值滤波等局部方法只考虑邻域像素，在噪声强度高时要么去噪不彻底，要么模糊边缘。NLM（Non-Local Means，非局部均值）和 BM3D（Block-Matching and 3D Filtering）分别从空间域和变换域两个方向突破了局部邻域的限制。

## NLM 非局部均值

### 核心思想

图像中存在大量重复的局部结构（patch）。给定一个待去噪的像素点，遍历全图寻找与它周围 patch 相似的所有 patch，将这些 patch 中心像素的加权平均值作为去噪结果。权重由 patch 之间的相似度决定，而非像素之间的空间距离。

### 数学定义

设 $y$ 为含噪图像，$\hat{x}(p)$ 为像素 $p$ 的去噪结果。以 $p$ 为中心的 patch $P_p$ 和以 $q$ 为中心的 patch $P_q$ 之间的相似度由高斯加权欧几里得距离度量：

$$
d(p, q) = \|P_p - P_q\|_{2,a}^2 = \sum_{k=1}^{K^2} G_a(k) \cdot \big(P_p(k) - P_q(k)\big)^2
$$

其中 $G_a$ 是标准差为 $a$ 的高斯核，用于给 patch 内的中心像素更大权重。$K$ 为 patch 尺寸（通常 $K=7$）。

相似度权重为：

$$
w(p, q) = \exp\left(-\frac{\max(d(p,q) - 2\sigma^2, 0)}{h^2}\right)
$$

$\sigma$ 是噪声标准差，$h$ 是滤波参数（控制权重的衰减速度）。$d$ 中减去 $2\sigma^2$ 是因为两个独立含噪 patch 的期望距离中包含噪声贡献，需做偏差校正。

最终输出为加权平均：

$$
\hat{x}(p) = \frac{1}{C(p)} \sum_{q \in S(p)} w(p, q) \cdot y(q), \quad C(p) = \sum_{q \in S(p)} w(p, q)
$$

$S(p)$ 是以 $p$ 为中心的搜索窗口（通常 $21\times21$ 或 $31\times31$），而非整幅图像——在全图搜索的代价过高，最佳相似 patch 通常也落在局部邻域内。

### 参数影响

| 参数 | 含义 | 典型值 | 影响 |
|------|------|--------|------|
| patch 尺寸 $K$ | 局部结构的范围 | 7×7 | 太小区分度不足，太大包含冗余信息 |
| 搜索窗尺寸 $|S|$ | 相似 patch 的搜索范围 | 21×21 | 太小可能找不到足够相似块，太大计算量高 |
| $h$ | 权重衰减速度 | $0.4\sigma$–$0.6\sigma$ | $h$ 过小去噪不足，过大图像过平滑 |

## BM3D：三步协同滤波

BM3D（Dabov et al., 2007）在 NLM 的基础上引入了第三个维度——将相似块叠成 3D 柱状体，在 3D 变换域中做噪声与信号的分离。BM3D 在 PSNR 指标上长期处于传统方法的最高水平。

整个流程分为两步：基础估计（硬阈值）和最终估计（维纳滤波）。

### 符号定义

- $y$：含噪输入图像
- $\hat{x}^{\text{basic}}$：基础估计输出
- $\hat{x}^{\text{final}}$：最终估计输出
- $P$：参考 patch，$P^{\text{HT}}$ 和 $P^{\text{Wiener}}$ 分别表示两步中提取的块组
- $T_{3D}$：3D 可分离变换（2D DCT + 1D Haar 或 1D Walsh-Hadamard）
- $\tau_{3D}$：硬阈值门限
- $\gamma_{3D}^{\text{Wiener}}$：维纳滤波系数

### Step 1：基础估计

**1a. Block Matching**

遍历图像，对每个参考 patch $P_R$，在搜索窗内找到所有与之相似的 patch。相似度用两个 patch 的归一化 $L_2$ 距离衡量，距离小于阈值 $\tau_{\text{match}}$ 的 patch 被视为匹配。

**1b. 3D Stacking**

将匹配到的所有 patch（包括参考 patch自身）堆叠成一个 3D 柱状体。柱状体的三维结构为：$K \times K \times N_{\text{match}}$，其中 $K$ 为 patch 尺寸，$N_{\text{match}}$ 为匹配到的 patch 数量。

**1c. 3D 变换与硬阈值**

对 3D 柱状体施加可分离的 3D 变换：先在二维空间（patch 内）做 2D DCT，再在第三维（跨 patch）做 1D 变换（Haar 或 Walsh-Hadamard）。跨 patch 的变换利用了 NLM 的"多块平均"思想，但将"平均"提升到了变换域——噪声在 3D 谱中分散为小系数，信号集中在少数大系数上。

变换后执行硬阈值收缩：

$$
\hat{P}^{\text{HT}} = T_{3D}^{-1}\left( \Gamma\left( T_{3D}(P^{\text{HT}}) \right) \right), \quad
\Gamma(\xi) = \begin{cases}
\xi, & |\xi| \geq \tau_{3D} \\
0, & |\xi| < \tau_{3D}
\end{cases}
$$

**1d. 聚合**

逆变换回 2D 空间后，每个 patch 被放回它在原图中的位置。同一像素可能出现在多个 patch 中（因为不同参考 patch 的搜索窗会有重叠），最终像素值取所有覆盖该像素的变换域估计值的加权平均。权重为该 3D 块组中保留的非零系数数量（估计更可靠的块组获得更大权重）。

这一步的输出称为基础估计 $\hat{x}^{\text{basic}}$，已经去除了大部分噪声，但边缘处可能因硬阈值的"硬切割"出现轻微振铃。

### Step 2：最终估计

**2a. 重新匹配**

在基础估计 $\hat{x}^{\text{basic}}$（已大幅降噪）上重新执行 block matching。此时图像噪声已显著降低，匹配距离更准确，能找到更多正确的相似块。

**2b. 3D 变换与维纳滤波**

分别从含噪图 $y$ 和基础估计 $\hat{x}^{\text{basic}}$ 中提取对应的 3D 块组 $P^{\text{Wiener}}$（含噪）和 $P^{\text{basic}}$（基础）。对两组块做相同的 3D 变换。

维纳滤波系数由基础估计的能量谱决定：

$$
\gamma_{3D}^{\text{Wiener}}(\xi) = \frac{|T_{3D}(P^{\text{basic}})(\xi)|^2}{|T_{3D}(P^{\text{basic}})(\xi)|^2 + \sigma^2}
$$

然后用该系数对含噪块组的变换域系数做缩放：

$$
\hat{P}^{\text{Wiener}} = T_{3D}^{-1}\left( \gamma_{3D}^{\text{Wiener}} \cdot T_{3D}(P^{\text{Wiener}}) \right)
$$

维纳滤波的系数是连续的（0–1 之间），不像硬阈值那样做二值截断，因此 Step 2 的输出更平滑、振铃更少。

**2c. 聚合**

与 Step 1 相同的方法，将所有重叠块的估计结果加权聚合，得到最终估计 $\hat{x}^{\text{final}}$。

:::tip NLM vs BM3D

| 维度 | NLM | BM3D |
|------|-----|------|
| 处理单元 | 整像素 | 块组（3D 柱状体） |
| 相似性利用 | 空间域加权平均 | 3D 变换域协同滤波 |
| 降噪机制 | 多块平均 → 噪声方差 $\propto 1/N$ | 变换域阈值/Wiener → 信号噪声分离更彻底 |
| 质量 | 中（边缘保持尚可） | 高（长期传统方法最优） |
| 速度 | 慢（逐像素加权） | 更慢（做两次） |

:::
