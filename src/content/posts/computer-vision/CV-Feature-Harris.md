---
title: Harris角点检测
published: 2026-05-28
description: '角点定义与数学推导（SSD→泰勒展开→结构张量M→特征值分析）、Harris响应函数R=det-α·tr²、算法流水线、旋转不变性与尺度敏感性'
image: ''
tags: []
category: '08-计算机视觉'
draft: false 
order: 7
lang: ''
---

## 什么是角点

若一个**小窗口**向**任意方向**移动，灰度都发生显著**变化**，那便是角点

- 平坦区域：向任意方向移动，灰度变化都很小
- 边缘：沿边缘方向移动，灰度变化小；垂直边缘方向移动，灰度变化大
- 角点：向任意方向移动，灰度变化都很大

## 数学推导

用SSD（Sum of Squared Differences）来衡量窗口移动后的灰度变化：

图像$I$，窗口大小为$W=w \times w$，移动向量为$(u,v)$, 则SSD定义为$E$：

$$
E(u,v) = \sum_{x,y\in W} w(x,y) [I(x+u, y+v) - I(x,y)]^2
$$

求和符号表示遍历窗口内的每个像素点。

用一阶泰勒展开近似 $I(x+u, y+v)$：

$$
I(x+u, y+v) \approx I(x,y) + I_x u + I_y v\\
I_x = \frac{\partial I}{\partial x}, I_y = \frac{\partial I}{\partial y}
$$

带入SSD公式,第二个等号化成二次型形式：

$$
E(u,v) \approx \sum_{x,y\in W} w(x,y) (I_x u + I_y v)^2 \\
=\sum_{x,y\in W} w(x,y) (I_x^2 u^2 + 2 I_x I_y u v + I_y^2 v^2)\\
=\begin{bmatrix} u & v \end{bmatrix} \sum_{x,y\in W} w(x,y) \begin{bmatrix} I_x^2 & I_x I_y \\ I_x I_y & I_y^2 \end{bmatrix} \begin{bmatrix} u \\ v \end{bmatrix}
$$

中间那一坨只和窗口内的图像梯度有关，与移动向量无关，记为矩阵$M$，叫做**结构张量**（structure tensor）：

$$
M = \sum_{x,y\in W}w(x,y) \begin{bmatrix} I_x^2 & I_x I_y \\ I_x I_y & I_y^2 \end{bmatrix}
$$

- $w(x,y)$是窗口权重函数，通常是高斯权重，强调窗口中心的像素点。
- $M$是一个对称正定矩阵，包含了窗口内的梯度信息。
- 特征值$\lambda_1, \lambda_2$反映了窗口内的灰度变化程度
- 特征向量$\mathbf{v_1}, \mathbf{v_2}$反映了窗口内灰度变化的方向

分类：

- $\lambda_1, \lambda_2$ 都很小：平坦区域
- $\lambda_1$ 很大，$\lambda_2$ 很小：边缘
- $\lambda_1, \lambda_2$ 都很大：角点

:::tip

关于这个矩阵的特征值$\lambda_1, \lambda_2$：

$$
M \mathbf{v_1} = \lambda_1 \mathbf{v_1}, \quad M \mathbf{v_2} = \lambda_2 \mathbf{v_2}
$$

代入SSD的二次型表达式：(这里取$\mathbf{v_1}, \mathbf{v_2}$为特征向量，$u', v'$为在特征向量方向上的坐标)

$$
E(u,v) = \begin{bmatrix} u' & v' \end{bmatrix} M \begin{bmatrix} u' \\ v' \end{bmatrix} = \lambda_1 u'^2 + \lambda_2 v'^2
$$

:::

但直接计算特征值开销较大，Harris 提出一个近似响应函数：

$$
R = \det(M) - \alpha \cdot \text{trace}(M)^2 = \lambda_1 \lambda_2 - \alpha (\lambda_1 + \lambda_2)^2
$$

- $\alpha$ 是经验参数，通常取0.04~0.06

分类

- $R < 0$: 边缘（trace主导）
- $|R| \approx 0$: 平坦区域
- $R > 0$ 且足够大: 角点

## Harris角点检测算法步骤

符号：$I$为输入图像.

### 1. 计算图像梯度 $I_x, I_y$

用sobel算子对 **整幅图像** 进行卷积，得到每个像素的水平和垂直梯度：

$$
I_x = I * S_x, \quad I_y = I * S_y
$$

### 2. 计算结构张量 $M$

对于得到的梯度图

1. 计算**每个像素**的结构张量：$I_x^2, I_y^2, I_x I_y$，得到三个图像

2. 对三图分别进行高斯模糊（卷积），得到三个平滑图（这里也是权重项的由来），然后构建每个像素的结构张量：

$$
M(x,y) = \begin{bmatrix} G_\sigma * I_x^2 & G_\sigma * I_x I_y \\ G_\sigma * I_x I_y & G_\sigma * I_y^2 \end{bmatrix}
$$

### 3. 计算响应函数 $R$

对于所有像素，计算响应函数：

$$
R(x,y) = \det(M(x,y)) - \alpha \cdot \text{trace}(M(x,y))^2
$$

- $\det(M) = (G_\sigma * I_x^2)(G_\sigma * I_y^2) - (G_\sigma * I_x I_y)^2$
- $\text{trace}(M) = (G_\sigma * I_x^2) + (G_\sigma * I_y^2)$

得到一个响应图。

### 4. 阈值筛选+非极大值抑制

1. 遍历相应图，找到所有 $R(x,y) > T$ 的像素点（$T$是预设的阈值），这些点是潜在的角点。剩下的置零。
2. NMS：对于每个潜在角点，检查其邻域内的响应值，如果该点的响应值不是邻域内的最大值，则将其置零。这样可以确保最终保留的角点是局部极大值。

### 5. 输出角点坐标

最终输出所有满足条件的角点坐标 $(x,y)$。

## Harris角点检测的特点

- 对旋转不变：因为响应函数只依赖于特征值，与方向无关。
- 对光照变化不敏感：因为响应函数依赖于梯度的平方
- 对噪声敏感：因为计算梯度时会放大噪声，所以通常在计算结构张量前会先对图像进行高斯模糊。
- **无法检测尺度变化**：因为窗口大小固定，无法适应不同尺度的角点。

:::tip Harris 关键公式速查

| 概念 | 公式 |
|------|------|
| 窗口移动灰度变化 | $E(u,v) = \sum w(x,y)[I(x+u,y+v)-I(x,y)]^2$ |
| 泰勒展开近似 | $E(u,v) \approx [u\ v]\ M\ [u\ v]^T$ |
| 结构张量 | $M = \sum w(x,y) \begin{bmatrix}I_x^2 & I_x I_y \\ I_x I_y & I_y^2\end{bmatrix}$ |
| 响应函数 | $R = \det(M) - \alpha \cdot \text{tr}(M)^2 = \lambda_1\lambda_2 - \alpha(\lambda_1+\lambda_2)^2$ |
| 判断 | $R>0$ 角点，$R \approx 0$ 平坦，$R<0$ 边缘 |

:::
