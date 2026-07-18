---
title: 光流（一）——Lucas-Kanade方法
published: 2026-06-23
description: '光流定义、亮度恒常性假设与小运动假设、光流约束方程Ixu+Iyv+It=0、孔径问题、LK局部空间一致性假设、最小二乘求解、与Harris结构张量的联系'
image: ''
tags: []
category: '08-计算机视觉'
order: 10
draft: false
lang: ''
---

## 光流

光流描述的是观察者与场景之间的相对运动在图像平面上形成的表观运动模式。给定两个连续图像帧 $I(t)$ 和 $I(t+1)$，光流的目标是计算每个像素点在两帧之间的位移向量 $(u, v)$。

## 所有光流算法的共同假设

无论是 LK、HS 还是深度学习方法，所有光流算法共享以下两个基本假设。

### 假设一：亮度恒常性

同一物体点的亮度值在连续帧中保持不变。这个假设将像素的亮度值在帧间直接关联起来，使得光流计算可以建立在逐像素比较的基础上，无需提取高层语义特征。

$$
I(x(t), y(t), t) = C
$$

### 假设二：小运动

相邻两帧之间的运动位移足够微小（通常 1–2 个像素以内），从而可以用泰勒展开将非线性的运动模型线性化。

记 $\delta t$ 为帧间时间间隔，位移为 $(\delta x = u\delta t,\ \delta y = v\delta t)$，亮度恒常性假设可重新表述为：

$$
I(x + u\delta t,\ y + v\delta t,\ t + \delta t) = I(x, y, t)
$$

## 光流约束方程

对上述等式左边做一阶泰勒展开：

$$
\begin{aligned}
I(x+u\delta t, y+v\delta t, t+\delta t) &\approx I(x,y,t) + \frac{\partial I}{\partial x} u \delta t + \frac{\partial I}{\partial y} v \delta t + \frac{\partial I}{\partial t} \delta t
\end{aligned}
$$

代入恒等条件并消去公共项：

$$
\frac{\partial I}{\partial x} u + \frac{\partial I}{\partial y} v + \frac{\partial I}{\partial t} = 0
$$

记作

$$
I_x u + I_y v + I_t = 0
$$

这就是光流约束方程，也是所有光流算法的出发点。其中 $I_x, I_y$ 为图像空域梯度（已知，可用 Sobel 等算子计算），$I_t = I(t+1) - I(t)$ 为时间梯度（已知，帧间差分得到），$u, v$ 为待求的光流分量。

一个方程包含两个未知数，构成了一个欠定系统。要得到唯一解，必须引入额外的约束条件——不同光流算法的本质区别就在于它们引入的假设不同。

## 孔径问题

局部图像信息无法提供足够约束来唯一确定运动矢量，这称为孔径问题。直观理解是：通过一个小窗口观察一条边缘，只能感知到垂直于边缘方向的运动分量，沿边缘方向的运动无法被探测。

数学上，若一个局部区域内梯度只存在于某个方向，那么光流约束方程中只有一个方向有有效信息，另一个方向完全不受约束。

## LK 的独特假设：局部空间一致性

Lucas-Kanade（LK）方法引入了第三个假设来解决欠定问题：

**局部空间一致性**：在小的局部邻域内，所有像素共享相同的光流向量 $(u, v)$。

基于这个假设，对每个目标像素取一个 $w \times w$ 的邻域窗口（如 $5\times5$），假设窗口内 $w^2$ 个像素 $p_1, \dots, p_{w^2}$ 的光流都等于 $(u, v)$，则每个像素提供一个光流约束方程：

$$
\begin{cases}
I_x(p_1) u + I_y(p_1) v + I_t(p_1) = 0 \\
I_x(p_2) u + I_y(p_2) v + I_t(p_2) = 0 \\
\ \ \ \ \vdots \\
I_x(p_{w^2}) u + I_y(p_{w^2}) v + I_t(p_{w^2}) = 0
\end{cases}
$$

写成矩阵形式 $A \mathbf{x} = \mathbf{b}$：

$$
A = \begin{bmatrix}
I_x(p_1) & I_y(p_1) \\
I_x(p_2) & I_y(p_2) \\
\vdots & \vdots \\
I_x(p_{w^2}) & I_y(p_{w^2})
\end{bmatrix},\quad
\mathbf{x} = \begin{bmatrix} u \\ v \end{bmatrix},\quad
\mathbf{b} = \begin{bmatrix} -I_t(p_1) \\ -I_t(p_2) \\ \vdots \\ -I_t(p_{w^2}) \end{bmatrix}
$$

这是一个超定方程组（$w^2$ 个方程，2 个未知数），通过最小二乘法求解：

$$
\min_{\mathbf{x}} \|A\mathbf{x} - \mathbf{b}\|_2^2
$$

导数为零得到正规方程：

$$
A^T A \mathbf{x} = A^T \mathbf{b},\quad \mathbf{x} = (A^T A)^{-1} A^T \mathbf{b}
$$

## 可解性条件与 Harris 角点的联系

正规方程有解要求 $A^T A$ 可逆。观察 $A^T A$ 的结构：

$$
A^T A = \begin{bmatrix}
\sum I_x^2 & \sum I_x I_y \\
\sum I_x I_y & \sum I_y^2
\end{bmatrix}
$$

这正是 Harris 角点检测中的结构张量。回顾其特征值 $\lambda_1, \lambda_2$ 的三种情况：

- $\lambda_1, \lambda_2$ 都很小：平坦区域，梯度接近零 → $A^T A$ 近似零矩阵 → **不可解**
- $\lambda_1$ 很大，$\lambda_2$ 很小：边缘区域，梯度只沿一个方向 → 只能解出法线方向的光流分量 → **孔径问题**
- $\lambda_1, \lambda_2$ 都很大：角点或纹理丰富区域 → 梯度在两个方向都有足够变化 → **可稳定求解**

所以 LK 光流的可靠性与图像中的纹理丰富程度直接相关。角点和斑块区域是 LK 最稳定的工作区域，平坦区域则完全失效。

:::tip 假设层级速查

| 假设 | 层级 | 作用 |
|------|------|------|
| 亮度恒常性 | 共同假设 | 建立帧间像素关联 |
| 小运动 | 共同假设 | 线性化光流约束方程 |
| 局部空间一致性 | **LK 独有** | 将欠定转为超定，最小二乘求解 |

:::

$$ \boxed{\text{共同假设} \rightarrow \text{光流约束方程} \rightarrow \text{局部一致性假设} \rightarrow \text{最小二乘求解}} $$

光流约束方程 $I_x u + I_y v + I_t = 0$ 是所有光流算法的基础，下一篇文章将介绍 Horn-Schunck 方法——它使用完全不同的额外假设（全局平滑性）来解决同一个欠定问题，以及金字塔 LK 如何突破小运动假设的限制。
