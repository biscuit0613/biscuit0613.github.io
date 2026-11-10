---
title: Blob检测与SIFT特征
published: 2026-06-03
description: '尺度空间分析、LoG与NLoG检测Blob、σ²归一化必要性、SIFT关键点定位（子像素/对比度阈值/边缘响应移除）、方向分配与128维描述子构建、旋转尺度不变性来源'
image: ''
tags: []
category: '08-计算机视觉'
order: 8
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

## SIFT 关键点定位

DoG 检测到的候选关键点是在离散空间中找到的极值，位置精度受限于像素网格。SIFT 通过拟合三维二次函数来获取子像素精度的位置和尺度。

对 DoG 函数 $D(x,y,\sigma)$ 在当前候选点处做二阶泰勒展开，求导得到偏移量 $\hat{\mathbf{x}}$。若 $\|\hat{\mathbf{x}}\| > 0.5$，说明极值点更靠近相邻像素，需要插值移位后重新拟合，直到收敛或超出迭代次数。

拟合后还需两次筛选：

- **低对比度剔除**：将 $\hat{\mathbf{x}}$ 代回泰勒展开得到极值 $D(\hat{\mathbf{x}})$，若 $|D(\hat{\mathbf{x}})| < T$（通常 $T=0.03$）则认为对比度太低，剔除。
- **边缘响应剔除**：DoG 在边缘处也会产生强响应，但边缘上的关键点沿边缘方向定位不准。SIFT 用 Harris 矩阵的思想——计算该点处的 $2\times2$ Hessian 矩阵，若主曲率比值 $\frac{\text{tr}(H)^2}{\det(H)} > \frac{(r+1)^2}{r}$（通常取 $r=10$），则判定为边缘响应并剔除。

## SIFT 方向分配

每个关键点被赋予一个主导方向，从而使描述子具备旋转不变性。

以关键点所在尺度 $\sigma$ 的 1.5 倍为半径，取高斯加权窗口内的像素，计算每个像素的梯度幅值和方向。将方向 $0^\circ$–$360^\circ$ 量化到 36 个柱（每柱 $10^\circ$），用梯度幅值加权投票，生成方向直方图。直方图的最高峰对应的方向即主方向。若有其他峰值达到主峰值的 80%，则额外为该峰创建一个关键点（同一位置、不同方向）。

## SIFT 描述子（128维）

方向分配完成后，以关键点为中心取 $16\times16$ 的邻域窗口，旋转到主方向对齐（保证旋转不变）。将窗口划分为 $4\times4$ 个子区域，每个子区域内计算 8 个方向的梯度直方图（同样用高斯加权）。$4\times4\times8=128$ 个数值构成描述子向量。

最终对 128 维向量做归一化（消除光照线性变化的影响），并对大于 0.2 的幅值截断后再次归一化（抑制大梯度值的干扰，提高对非线性的光照变化的鲁棒性）。

:::tip 从 Blob 到 SIFT 的完整链条

| 步骤 | 作用 | 对应的不变性 |
|------|------|-------------|
| DoG 金字塔 + 3D极值检测 | 找到候选位置+特征尺度 | 尺度不变性 |
| 子像素拟合 + 低对比度/边缘剔除 | 精确定位，剔除不稳定点 | 稳定性 |
| 方向直方图 → 主方向 | 分配基准方向 | 旋转不变性 |
| 旋转对齐 + 4×4×8 直方图 | 构造唯一特征描述 | 局部几何描述 |
| 归一化 + 幅值截断 | 抑制光照影响 | 光照部分不变性 |

:::

:::tip LoG / DoG / NLoG 关系速查

- **LoG** $=\nabla^2 G_\sigma$：拉普拉斯算子对高斯核作用，检测 Blob。
- **NLoG** $=\sigma^2 \nabla^2 G_\sigma$：乘 $\sigma^2$ 保证多尺度下响应可比。
- **DoG** $\approx (k-1)\sigma^2 \nabla^2 G_\sigma = (k-1)\cdot\text{NLoG}$：相邻高斯层差分近似 LoG，多出常数因子 $(k-1)$ 不影响极值定位。

:::
