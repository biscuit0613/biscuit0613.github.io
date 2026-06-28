---
title: Blob检测
published: 2026-06-03
description: ''
image: ''
tags: []
category: '计算机视觉'
order: 6
draft: false 
lang: ''
---

Blob 是图像中与周围区域有显著差异的局部区域，通常表现为：

- 一块明亮的区域被暗背景包围（或反之）

- 例如：远处的圆形光斑、细胞核、气泡等

>“For a Blob-like Feature to be useful, we need to: Locate the blob, Determine its size, Determine its orientation, Formulate a description or signature that is independent of size and orientation.”

翻译：要让 Blob 特征变得有用，我们需要：

- 定位 Blob
- 确定它的大小
- 确定它的方向
- 构造一个与大小和方向无关的描述符。

:::tip
角点检测（如 Harris）对尺度变化非常敏感：图像缩放后，窗口大小固定的角点会失效。

Blob 检测通过多尺度分析，能够同时检测出 Blob 的位置和特征尺度（大小），从而实现尺度不变性。

:::

## 尺度空间分析

给定一个图像 $I(x,y)$，我们可以通过卷积高斯核来构建尺度空间：

$$
S(x,y,\sigma) = G(x,y,\sigma) * I(x,y)
$$

其中 $G(x,y,\sigma)$ 是标准差为 $\sigma$ 的二维高斯核：
$$
G(x,y,\sigma) = \frac{1}{2\pi\sigma^2} e^{-\frac{x^2 + y^2}{2\sigma^2}}
$$

其中 $\sigma$ 越大，对应的尺度越高（但不是图像放大，而是信息粗糙化）

## (Normalized) Laplacian of Gaussian (LoG)

不直接使用模糊后的尺度空间图像，而是使用其**归一化拉普拉斯**来检测 Blob：

$$
\text{LoG}(x,y,\sigma) = \nabla^2 S(x,y,\sigma) =\nabla^2 G_{\sigma} * I(x,y)\\
\text{NLoG}(x,y,\sigma) = \sigma^2 \nabla^2 S(x,y,\sigma)= \sigma^2 \nabla^2 G_{\sigma} * I(x,y)
$$

- $\nabla^2=\frac{\partial^2}{\partial x^2} + \frac{\partial^2}{\partial y^2}$ 是拉普拉斯算子，计算图像的二阶导数，能够突出局部极值点。
- $\sigma^2$ 是归一化因子，确保不同尺度下的响应具有可比性。

检测blob是一个求局部极大值的过程：
$$
(x^*, y^*, \sigma^*) = \argmax_{x,y,\sigma} \sigma^2 \nabla^2 G_{\sigma} * I(x,y)
$$

- $(x^*, y^*)$ 是Blob的**中心位置**
- $\sigma^*$ 是Blob的**特征尺度**（可以通过 $\sigma\approx 0.707 R$ 确定blob的大小）
- $\text{LoG}_{peak} = \sigma^2 \nabla^2 G_{\sigma} * I(x^*, y^*)$ 是Blob的**响应强度**，反映了Blob的显著程度。

为什么需要 $\sigma^2$ 归一化？

对于二阶高斯导数，可以证明：  
当滤波器尺度 $\sigma$ 与 Blob 的特征宽度（设为 $R$）成比例时，一般是 $\sigma \approx 0.707 R$，此时 $\text{LoG}_{peak}$ 和尺度 $\sigma$ 的关系为：

$$
\text{LoG}_{peak} \propto \frac{1}{\sigma^2}
$$

同一个亮斑，对于LoG方法

- 如果我们用 小尺度（σ 小）去检测，响应很大；

- 用 大尺度（σ 大）去检测，响应非常小。

但我们想检测不同大小的 Blob，希望它们在自己的特征尺度上都能给出 可比较的强响应。如果响应随着 σ 增大而急剧衰减，那么大 Blob 的响应永远比不上小 Blob 的响应，我们就无法通过比较不同 σ 下的响应值来找出“哪个尺度最匹配”。

所以乘上 $\sigma^2$ 进行归一化后，对于与滤波器尺度匹配的 Blob，归一化后的响应幅度与 σ 无关

## 找到 Blob 位置和尺度的完整数学过程

1. **定义尺度空间**  
   一组离散尺度 $\sigma_0, \sigma_1, \dots, \sigma_k$（等比数列）。

2. **计算响应函数**  
   $$
   R(x,y,\sigma) = \sigma^2 \left( \nabla^2 G_{\sigma} * I(x,y) \right)
   $$

   - 先用高斯核 $G_{\sigma}$ 对图像进行模糊，得到尺度空间图像 $S(x,y,\sigma)$。
   - 再对 $S$ 用拉普拉斯核进行卷积，得到 $\nabla^2 S$。(这也可以用DoG高斯差分金字塔近似，比如sift就是用DoG来近似LoG)
   - 最后乘以 $\sigma^2$ 进行归一化。

3. **检测局部极值**  
   - 邻域空间：对于每个像素 $(x,y)$，检查其在当前尺度 $\sigma$ 上的响应值 $R(x,y,\sigma)$ 是否是其空间邻域内的最大值（通常是3x3窗口）。
   - 邻域尺度：同时检查在相邻的尺度 $\sigma_{prev}$ 和 $\sigma_{next}$ 上的响应值（共27个邻居），确保 $R(x,y,\sigma)$ 也是这两个尺度上的局部最大值。

4. **输出**  
   - 位置：$x^*, y^*$ 对应的像素坐标  
   - 特征尺度：$\sigma^*$（Blob 的大小)
   - 响应强度：$R(x^*, y^*, \sigma^*)$（Blob 的显著程度）
