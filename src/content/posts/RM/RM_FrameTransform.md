---
title: 坐标变换这一块
published: 2025-10-17
description: '坐标变换的基本概念与应用'
image: ''
tags: [反向运动学, RM]
category: 'RM'
draft: false
lang: ''
---


## 旋转轴+角表示这一块

在三维空间中，任意旋转都可以表示为绕某一固定轴旋转一定角度。 这种表示方法称为旋转轴-角表示。对应的数学工具是罗德里格斯公式（Rodrigues' rotation formula）。

$$
R = I + \sin(\theta)K + (1 - \cos(\theta))K^2
$$

先规定符号：

我觉得把source和target都放在上下标里不太好理解，不如直接回归定义：左上标表示参考系，右下标表示被表示的对象

- P点在A基底下的表示：${^A}P$

- 绕固定轴的旋转矩阵：$R_{axis}(\theta)$
- A基底（向量）在B基底下的表示：${^B}X_A$
- B基底下到A基底的旋转：${^B}R_A=({^B}X_A,{^B}Y_A,{^B}Z_A)$
- B基底下到A基底的平移（A系下B的原点）：${^B}P_{Aorg}$
- B基底下A基底的齐次变换矩阵：${^B}T_A=\begin{bmatrix}{^B}R_A & {^B}P_{Aorg} \\0 & 1\end{bmatrix}$


## 绕固定轴旋转：旋转因子

旋转因子 $R_{axis}(\theta),\;axis\in\{x,y,z\}$ 表示绕axis轴正向旋转 $\theta$ 角度的旋转矩阵。

:::tip  
正向：右手定则：大拇指指向旋转轴正方向，四指弯曲方向为正向旋转方向  
:::

旋转因子的形式：

$$
R_X(\theta) = \begin{bmatrix}
1 & 0 & 0 \\
0 & \cos\theta & -\sin\theta \\
0 & \sin\theta & \cos\theta
\end{bmatrix}\\[1em]
R_Y(\theta) = \begin{bmatrix}
\cos\theta & 0 & \sin\theta \\
0 & 1 & 0 \\
-\sin\theta & 0 & \cos\theta
\end{bmatrix}\\[1em]
R_Z(\theta) = \begin{bmatrix}
\cos\theta & -\sin\theta & 0 \\
\sin\theta & \cos\theta & 0 \\
0 & 0 & 1
\end{bmatrix}\\[1em]
$$

:::tip  
看主对角线1的位置，从右往左依次是xyz；三角是 $\begin{matrix}c&s\\s&c\end{matrix}$ 形式，XZ轴-在右上角，Y轴-在左下角  
:::  

### 旋转因子的左乘与右乘

作用方式分为左乘和右乘：
$$
{^A}\vec{p}_{rotated} = R_Z(\theta) \cdot {^A}\vec{p}_{original}\\[1em]
{^{{A(\mathbf{rotated})}}}\vec{p} = {^A}\vec{p}_{original} \cdot R_Z(\theta)
$$

可见，左乘是坐标系不动，对向量进行旋转，得到原坐标系下旋转后的坐标；

右乘是对坐标系进行旋转，向量保持不变，得到向量在旋转后坐标系 $A_{rotated}$ 下的坐标。

### 旋转因子的连乘

在左乘（参考的坐标系不变）的情况下，按照欧拉角旋转，xyz和yzx的结果有可能不一样。对于，从 $\mathbf{axis1}$ 旋转 $\theta_1$，再从 $\mathbf{axis2}$ 旋转 $\theta_2$，最后从 $\mathbf{axis3}$ 旋转 $\theta_3$，总的旋转矩阵为：

$$
R = R_{\mathbf{axis3}}(\theta_3) \cdot R_{\mathbf{axis2}}(\theta_2)  R_{\mathbf{axis1}}(\theta_1)\\[5pt]
R\cdot {^A}\vec{p}_{original} = R_{\mathbf{axis3}}(\theta_3) \cdot R_{\mathbf{axis2}}(\theta_2)  R_{\mathbf{axis1}}(\theta_1)\cdot{^A}\vec{p}_{rotated}
$$

第一次转动写在乘积的最右边，依次往左。（可以理解为不断左乘进行变换）

在右乘（参考系变换）的情况下，按照欧拉角旋转，xyz和yzx的结果也是不一样的。对于，从 $\mathbf{axis1}$ 旋转 $\theta_1$，再从 $\mathbf{axis2}$ 旋转 $\theta_2$，最后从 $\mathbf{axis3}$ 旋转 $\theta_3$，总的旋转矩阵为：

$$
R = R_{\mathbf{axis1}}(\theta_1) \cdot R_{\mathbf{axis2}}(\theta_2)  R_{\mathbf{axis3}}(\theta_3)\\[5pt]
{^A}\vec{p}_{original}\cdot R = {^A}\vec{p}_{original}\cdot R_{\mathbf{axis1}}(\theta_1) \cdot R_{\mathbf{axis2}}(\theta_2)  R_{\mathbf{axis3}}(\theta_3)
$$

不断右乘进行变换。

### 旋转因子，置换矩阵和反转矩阵

**置换矩阵**：简单讲就是对单位矩阵的重新排列，3*3的置换矩阵有6个：
$$
P_1 = \begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix},\quad
P_2 = \begin{bmatrix}
0 & 1 & 0 \\
1 & 0 & 0 \\
0 & 0 & 1
\end{bmatrix},\quad
P_3 = \begin{bmatrix}
0 & 0 & 1 \\
0 & 1 & 0 \\
1 & 0 & 0
\end{bmatrix},\\[1em]
P_4 = \begin{bmatrix}
1 & 0 & 0 \\
0 & 0 & 1 \\
0 & 1 & 0
\end{bmatrix},\quad
P_5 = \begin{bmatrix}
0 & 1 & 0 \\
0 & 0 & 1 \\
1 & 0 & 0
\end{bmatrix},\quad
P_6 = \begin{bmatrix}
0 & 0 & 1 \\
1 & 0 & 0 \\
0 & 1 & 0
\end{bmatrix}
$$

置换矩阵的作用方式和旋转因子类似，也分为左乘和右乘。

$\textcolor{yellow}{左乘行变换，右乘列变换。}$

由于旋转矩阵的列向量有特殊性，表示旋转后坐标系的基底方向，所以常用右乘。

**反转矩阵**：单位阵主对角线元素取负号，3*3的反转矩阵有7个：（去掉单位阵）
$$
M_1 = \begin{bmatrix}
-1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix},\quad
M_2 = \begin{bmatrix}
1 & 0 & 0 \\
0 & -1 & 0 \\
0 & 0 & 1
\end{bmatrix},\quad
M_3 = \begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & -1
\end{bmatrix},\\[1em]
M_4 = \begin{bmatrix}
-1 & 0 & 0 \\
0 & -1 & 0 \\
0 & 0 & 1
\end{bmatrix},\quad
M_5 = \begin{bmatrix}
-1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & -1
\end{bmatrix},\quad
M_6 = \begin{bmatrix}
1 & 0 & 0 \\
0 & -1 & 0 \\
0 & 0 & -1
\end{bmatrix},\quad
M_7 = \begin{bmatrix}
-1 & 0 & 0 \\
0 & -1 & 0 \\
0 & 0 & -1
\end{bmatrix}
$$

反转矩阵的作用方式和旋转因子类似，也分为左乘和右乘。

$\textcolor{yellow}{左乘行变换，右乘列变换。}$

左乘在坐标系不动的前提下，对向量进行反转；右乘在向量不动的前提下，对坐标系进行反转。

这两种作用方式的到的向量互为转置，虽然元素相同，但意义不同。

:::tip  
反转矩阵里面有两个负号的可以看作旋转矩阵转了180
:::

旋转因子可以和置换矩阵、反转矩阵结合使用，完成更复杂的旋转操作。

正手：用三种矩阵组合完成任意旋转

反手：给定组合得到的矩阵，分解成旋转因子，置换矩阵，反转矩阵组合的形式

重点讲一下反手

设经过某种组合得到的矩阵 $T$，旋转因子记作 $R$，置换矩阵记作 $P$，反转矩阵记作 $M$，那么 $T$ 的分解方式和左乘右乘有关：

$$
\begin{cases}
    T = M \cdot P \cdot R \qquad if\quad T\cdot{^A}\vec{P}\\[1em]
    T = R \cdot P \cdot M \qquad if\quad {^A}\vec{P}\cdot T
\end{cases}
$$

例如：

$$
T=\begin{bmatrix}
-c & s & 0 \\
0 & 0 & 1 \\
s & c & 0
\end{bmatrix}
$$

如果 $T$ 是左乘作用于向量 ${^A}\vec{P}$，那么：

$$
T\cdot{^A}\vec{P}=\begin{bmatrix}
    -1 & 0 & 0\\0&1&0\\0&0&1
\end{bmatrix}\cdot\begin{bmatrix}
    1 & 0 & 0\\0&0&1\\0&1&0
\end{bmatrix}\cdot
\begin{bmatrix}
    c & -s & 0 \\
    s & c & 0 \\
    0 & 0 & 1
\end{bmatrix}\cdot{^A}\vec{P}
$$

表示向量 ${^A}\vec{P}$ 在坐标系不变的情况下，依次经历了旋转，置换，反转三个变换。

如果 $M$ 是右乘作用于向量 ${^A}\vec{P}$，那么：

$$
{^A}\vec{P}\cdot T={^A}\vec{P}\cdot\begin{bmatrix}
    c & 0 & s \\
    0 & 1 & 0 \\
    -s & 0 & c
\end{bmatrix}\cdot\begin{bmatrix}
    1 & 0 & 0\\0&0&1\\0&1&0
\end{bmatrix}\cdot\begin{bmatrix}
    -1 & 0 & 0\\0&1&0\\0&0&1
\end{bmatrix}
$$

表示向量 ${^A}\vec{P}$ 在**坐标系**依次经历了旋转，置换，反转三个变换后，在**新的坐标系**下的表示。

### 旋转因子的性质

- 旋转因子是正交矩阵，满足$R^TR=I$

- 旋转因子的行列式为1，$|R|=1$
- 旋转因子的逆矩阵等于其转置矩阵，$R^{-1}=R^T$
- 多个旋转因子相乘仍然是一个旋转因子

## 坐标变换矩阵这一块

上文的旋转矩阵更类似于一种“局部旋转”，即在固定坐标系下对向量进行旋转。而坐标变换矩阵则用于描述不同坐标系之间的转换关系。比如说不同的舵机都会有自己的基底坐标系，我们需要将它们转换到一个统一的全局坐标系下进行计算。

用矩阵 ${^A}P_{Borg}$ 表示在A基底下B基底的平移变换。也就是B 的原点在A坐标系下的表示：

用矩阵 ${^A}R_B$ 表示在A基底下B基底的旋转变换。也就是B 的基底在A坐标系下的表示：

$$
{^A}R_B = \begin{bmatrix}
{^A}X_B & {^A}Y_B & {^A}Z_B
\end{bmatrix}= \begin{bmatrix}
\hat{X}_B\cdot \hat{X}_A & \hat{Y}_B\cdot \hat{X}_A & \hat{Z}_B\cdot \hat{X}_A \\
\hat{X}_B\cdot \hat{Y}_A & \hat{Y}_B\cdot \hat{Y}_A & \hat{Z}_B\cdot \hat{Y}_A \\
\hat{X}_B\cdot \hat{Z}_A & \hat{Y}_B\cdot \hat{Z}_A & \hat{Z}_B\cdot \hat{Z}_A
\end{bmatrix}
$$

对于坐标变换矩阵的连乘

$$
{^A}R_C = {^A}R_B \cdot {^B}R_C
$$

## 齐次变换矩阵这一块

齐次变换矩阵是将旋转和平移结合在一起的矩阵，通常表示为4x4的形式：

$$
{^A}T_B = \begin{bmatrix}
{^A}R_B & {^A}P_{Borg} \\
0 & 1
\end{bmatrix}
$$

其中，${^A}R_B$ 是在A基底看B基底的旋转矩阵（可以是旋转因子和置换阵与反转阵的结合），${^A}P_{Borg}$ 是在A基底看B基底的平移向量。

### 其次变换矩阵左乘与右乘

需要注意的是，其次变换矩阵形式上包含旋转和平移，左乘和右乘对平移旋转的顺序有影响

左乘：**先旋转后平移**，不改变参考系，只改变向量

右乘：**先平移后旋转**，改变参考系，不改变向量

特别地，当右乘作用于基底时，可以得到新的坐标系，这就是正向运动学的数学基础

$$
\{B\}=\{A\}\cdot {^A}T_B
$$

齐次变换矩阵也满足连乘。
