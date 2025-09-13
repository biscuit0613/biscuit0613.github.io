---
title: 雅各布矩阵&雅各布行列式
published: 2025-09-13
description: '系统介绍一下雅各布矩阵和雅各布行列式'
image: ''
tags: [向量的微积分，雅各布矩阵]
category: '线性代数'
draft: false 
lang: ''
---

## 雅各布矩阵

在向量微积分中，雅可比矩阵是一阶偏导数以一定方式排列成的矩阵，其行列式称为雅可比行列式。

雅可比矩阵的重要性在于它体现了一个可微方程与给出点的最优线性逼近。因此，雅可比矩阵类似于多元函数的导数。

设有一个从n维欧几里得空间到m维欧几里得空间的函数：
$$
\begin{align*}
\mathbf{F}:\mathbb{R}^n &\rightarrow \mathbb{R}^m \\
\mathbf{x} &\mapsto \mathbf{F}(\mathbf{x})
\end{align*}
$$
其中 $\mathbf{x}=(x_1,x_2,...,x_n)$，这个函数 $\mathbf{F}$ 由 $m$ 个实分量函数组成，即 $\mathbf{F}(\mathbf{x})=(f_1(\mathbf{x}),f_2(\mathbf{x}),...,f_m(\mathbf{x}))$。

如果每个分量函数 $f_i$ 在点 $\mathbf{a}$ 处对每个变量 $x_j$ 都可偏导，则称 $\mathbf{F}$ 在点 $\mathbf{a}$ 处可偏导。
雅可比矩阵$\mathbf{J}$定义为：
$$
\mathbf{J}=\begin{bmatrix}
\frac{\partial f_1}{\partial x_1} & \frac{\partial f_1}{\partial x_2} & \cdots & \frac{\partial f_1}{\partial x_n} \\[10bp]
\frac{\partial f_2}{\partial x_1} & \frac{\partial f_2}{\partial x_2} & \cdots & \frac{\partial f_2}{\partial x_n} \\[10bp]
\vdots & \vdots & \ddots & \vdots \\[10bp]
\frac{\partial f_m}{\partial x_1} & \frac{\partial f_m}{\partial x_2} & \cdots & \frac{\partial f_m}{\partial x_n}
\end{bmatrix}
$$
记作 $\mathbf{J}_{\mathbf{F}}(x_1,x_2,...,x_n)$。或者 $\frac{\partial \mathbf{F}}{\partial \mathbf{x}}=\frac{\partial{\mathbf{(f_1,f_2,...,f_m)}}}{\partial(x_1,x_2,...,x_n)}$ 。

:::tip

第二种记法生动形象的说明了雅各比矩阵的计算过程：分数线上面取一个$f_i$分别对下面的$x_j,j=1,2,...,n$求偏导。得到的导数排成行，就得到了雅各比矩阵的第$i$行。

:::

### 雅各布矩阵的意义

:::note[注]

在一元函数分析里，函数 $f:\R \to \R$ 的导数是  

$$
f'(x_0) = \lim_{\Delta x \to 0} \frac{f(x_0+\Delta x)-f(x_0)}{\Delta x}\\[10bp]
f(x_0+\Delta x) \approx f(x_0) + f'(x_0)\,\Delta x.
$$

几何意义：在 $x_0$ 处，函数最好的 **线性近似** 。也就是说，**导数就是线性近似的系数**。  

:::

在多维映射中。设 $F:\R^n \to \R^m$，在点 $\mathbf{x}_0=(x_{01},x_{02},...,x_{0n})$ 附近：  

$$
F(\mathbf{x}_0 + \Delta \mathbf{x}) \approx F(\mathbf{x}_0) + J_F(\mathbf{x}_0)\, \Delta \mathbf{x}.
$$

其中 $J_F(\mathbf{x}_0)$ 就是 **雅可比矩阵**。  

它的作用和一元函数的导数很像：  

- 在一元时，导数是“斜率”，把 $\Delta x$ 映射到近似的 $\Delta f$。  
- 在多元时，雅可比矩阵是一个“线性变换”，把小扰动 $\Delta x$ 映射到近似的 $\Delta F$。  

- **一元函数**：导数是数，表示伸缩因子。  
- **多维映射**：导数必须告诉我们不同方向上怎么伸缩，所以变成了“矩阵”。（其实这一块应该是雅各比行列式的作用，数值这一块。）

换句话说：  

- 一元导数：$\Delta y \approx f'(x_0)\Delta x$  
- 多元导数：$\Delta \mathbf{y} \approx J_F(\mathbf{x}_0)\, \Delta \mathbf{x}$  

矩阵就是多元情形下的“斜率”，因此可以看作导数的自然推广：

对于一维函数 $f:\mathbb{R}\to\mathbb{R},\mathbf{x}=x,\mathbf{F}=f$ ，$\mathbf{J}=\frac{\partial \mathbf{F}}{\partial \mathbf{x}}=\frac{\partial f}{\partial x}$ 就是导数。

对于二维函数 $f:\mathbb{R}^2\to\mathbb{R},\mathbf{x}=(x,y),\mathbf{F}=f$ ， $\mathbf{J}=\frac{\partial \mathbf{F}}{\partial \mathbf{x}}=\frac{\partial f}{\partial (x,y)}=(\frac{\partial f}{\partial x},\frac{\partial f}{\partial y})^T$ 就是梯度。(这里应该是列向量，写成行向量的转置)

对于二维函数的线性组合： $\mathbf{F}:\mathbb{R}^2\to\mathbb{R}^2,\mathbf{x}=(x,y),\mathbf{F}=(u,v)$ ， $\mathbf{J}=\frac{\partial \mathbf{F}}{\partial \mathbf{x}}=\frac{\partial (u,v)}{\partial (x,y)}$ 就是二维函数线性组合的雅各比矩阵。

## 雅各布行列式

想要取行列式，必须要求雅各布矩阵是方阵，即$m=n$。此时，雅各布矩阵的行列式称为雅各布行列式:

$$
\det(\mathbf{J_{\mathbf{F}}}(\mathbf{x}))=\begin{vmatrix}
    \frac{\partial f_1}{\partial x_1} & \frac{\partial f_1}{\partial x_2} & \cdots & \frac{\partial f_1}{\partial x_n} \\[10bp]
    \frac{\partial f_2}{\partial x_1} & \frac{\partial f_2}{\partial x_2} & \cdots & \frac{\partial f_2}{\partial x_n} \\[10bp]
    \vdots & \vdots & \ddots & \vdots \\[10bp]
    \frac{\partial f_n}{\partial x_1} & \frac{\partial f_n}{\partial x_2} & \cdots & \frac{\partial f_n}{\partial x_n}
\end{vmatrix}
$$

也记作 $|\frac{\partial (f_1,f_2,...,f_n)}{\partial (x_1,x_2,...,x_n)}|$ 。

这个玩意有一个重要的几何意义：

- 在二维中，$|\mathbf{J}|$就是小矩形被映射成小平行四边形时的面积比。

- 在三维中，$|\mathbf{J}|$就是小立方体变成平行六面体时的体积比。
- 符号决定了方向是否保持（正：方向保持；负：方向翻转），这点和一元函数的导数类似。
