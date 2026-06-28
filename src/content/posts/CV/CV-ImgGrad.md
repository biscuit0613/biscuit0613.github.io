---
title: 图像的梯度
published: 2026-05-25
description: ''
image: ''
tags: []
category: '计算机视觉'
order: 1
draft: false 
lang: ''
---

## 离散一维信号的一阶二阶差分

对于一维离散信号 $f[n]$，取 $\delta=1$ 其一阶差分定义为：

$$
f'[n] = f[n+1] - f[n]
$$

二阶差分定义为：

$$
f''[n] = f'[n] - f'[n-1] = f[n+1] - 2f[n] + f[n-1]
$$

## 图像的一阶微分

图像是离散的，不能直接求导 → 用差分近似

图像在 $(x,y)$ 处的一阶微分定义为：（写成一阶差分的形式）

$$
I_x(x,y) = I(x+1,y) - I(x-1,y)\\
I_y(x,y) = I(x,y+1) - I(x,y-1)\\
$$

等价于卷积形式：

$$
K_x = \begin{bmatrix}0&0&0\\-1&0&1\\0&0&0\end{bmatrix} \quad\quad K_y = \begin{bmatrix}0&-1&0\\0&0&0\\0&1&0\end{bmatrix}\\
I_x = I * K_x =\frac{1}{2}\sum_{i=-1}^{1}\sum_{j=-1}^{1} K_x(i,j) \cdot I(x-i,y-j) \\
 I_y = I * K_y =\frac{1}{2}\sum_{i=-1}^{1}\sum_{j=-1}^{1} K_y(i,j) \cdot I(x-i,y-j)
$$

梯度的幅值 $\iff$ 边缘强度，梯度的方向 $\iff$ 边缘方向

$$
\nabla I(i,j) = (I_x, I_y) \quad\quad E_s(i,j|I)=||\nabla I|| = \sqrt{I_x^2 + I_y^2}\\[1em]
\theta = \arctan{\frac{I_y}{I_x}}  \quad\quad E_\theta(i,j|I) = \theta+\frac{\pi}{2}
$$

![alt text](image-3.png)

图像的一阶微分算子 $\nabla$，就是把垂直水平方向的差分卷积核应用到图像上，得到每个像素点的梯度信息。常见的算子有Sobel、Prewitt等，它们在差分的基础上加入了权重，能够更好地抑制噪声。

## 二阶微分

图像的二阶微分可以通过对一阶微分再次求导来近似：

这也是拉普拉斯算子（图像二阶微分算子） $\nabla^2$ 的定义：

$$
\nabla^2 I = \frac{\partial^2 I}{\partial x^2} + \frac{\partial^2 I}{\partial y^2} \approx I(x+1,y) + I(x-1,y) + I(x,y+1) + I(x,y-1) - 4I(x,y)
$$

等价于卷积形式：

$$
K = \begin{bmatrix}0&1&0\\1&-4&1\\0&1&0\end{bmatrix} \quad\quad \nabla^2 I = I * K
$$

还可以进行拓展，加入对角线方向的二阶微分，得到更精确的边缘检测。

$$
K = \begin{bmatrix}1&1&1\\1&-8&1\\1&1&1\end{bmatrix} \quad\quad \nabla^2 I = I * K
$$

![alt text](image-4.png)
