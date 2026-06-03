---
title: 边缘和微分滤波器
published: 2026-05-25
description: ''
image: ''
tags: []
category: '计算机视觉'
draft: false 
lang: ''
---

## 锐化？

细节=原始图像-平滑滤波器(原始图像)

锐化=原始图像 + $\alpha$ x 细节=(1+$\alpha$) x 原始图像 - $\alpha$ x 平滑滤波器(原始图像)

## 一阶微分滤波器（梯度）

:::tip
梯度是一个向量，在这里一般用梯度的幅值替代梯度本身，用方向导数的一范数来替代二范数
:::

符号定义：

- $\nabla f=mag{\nabla\mathbf{f}}\approx|\frac{\partial f}{\partial x}| + |\frac{\partial f}{\partial y}|$
- $g_x = \frac{\partial f}{\partial x}$, $g_y = \frac{\partial f}{\partial y}$

不同的算子设计：(就是不同的卷积核设计)

### Roberts算子

核定义：

$$
K_x = \begin{bmatrix}1&0\\0&-1\end{bmatrix} \quad\quad K_y = \begin{bmatrix}0&1\\-1&0\end{bmatrix}
$$

对应的梯度计算思想是沿着对角线方向计算差分：

$$
g_x = I * K_x = I(x,y) - I(x+1,y+1) \\
g_y = I * K_y = I(x+1,y) - I(x,y+1)
$$

计算量极小

缺点：

- ❌ 对噪声非常敏感
- ❌ 只用2×2邻域，信息太少
- ❌ 方向性不直观（对角线）

### Prewitt算子

核定义：

$$
K_x = \begin{bmatrix}-1&0&1\\-1&0&1\\-1&0&1\end{bmatrix} \quad\quad K_y = \begin{bmatrix}-1&-1&-1\\0&0&0\\1&1&1\end{bmatrix}
$$

水平方向差分，竖直方向差分，使用3×3邻域，增强了对噪声的鲁棒性，但仍然比较简单。

### Sobel算子(最常用)

核定义：

$$
K_x = \begin{bmatrix}-1&0&1\\-2&0&2\\-1&0&1\end{bmatrix} \quad\quad K_y = \begin{bmatrix}-1&-2&-1\\0&0&0\\1&2&1\end{bmatrix}
$$

对应的梯度计算思想是沿着水平方向差分，竖直方向**加权**平均(以 $K_x$ 为例)：

:::tip

2 是用于增强中心像素重要性的权重，把算子拆分成两个可分离的卷积核：

$$
K_x = \begin{bmatrix}-1&0&1\end{bmatrix} * \begin{bmatrix}1\\2\\1\end{bmatrix} \quad\quad K_y = \begin{bmatrix}-1&-2&-1\end{bmatrix} * \begin{bmatrix}1\\0\\1\end{bmatrix}
$$

竖着的就是类似高斯平滑的效果，中间2的权重增强了中心像素的影响力，使得边缘检测更稳定。

:::

## 二阶微分滤波器（拉普拉斯）

常见的有两种卷积核

不带对角线：

$$
K = \begin{bmatrix}0&1&0\\1&-4&1\\0&1&0\end{bmatrix}
$$

带对角线：($45^o,135^o$方向的二阶微分)

$$
K = \begin{bmatrix}1&1&1\\1&-8&1\\1&1&1\end{bmatrix}
$$

无论哪种核，都是不可分离的卷积核，计算量较大。

:::tip
各向同性滤波器具有旋转不变性，即滤波响应基本不受图像灰度变
化方向的影响。图像在旋转前后经滤波所得结果相同。
:::

二阶微分本身比一阶微分对噪声更敏感，因此通常会先进行平滑处理（如高斯模糊）再进行二阶微分

利用二阶微分做图像增强：

$$
g(x,y) = f(x,y) - \alpha \nabla^2 f(x,y)
$$
