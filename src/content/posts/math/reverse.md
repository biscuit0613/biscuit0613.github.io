---
title: 矩阵的可逆性与Sherman-Morrison 
published: 2026-04-20
description: '矩阵的可逆性定义、性质以及计算方法。Sherman-Morrison (-woodbury)公式的应用。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

## 定义

对于一个 $n \times n$ 的矩阵 $A$，如果存在一个矩阵 $A^{-1}$ 满足：

$$
AA^{-1} = A^{-1}A = I_n
$$
其中 $I_n$ 是 $n \times n$ 的单位矩阵，那么我们称 $A^{-1}$ 是 $A$ 的逆矩阵，$A$ 是可逆

- 可逆矩阵又称为非奇异矩阵（nonsingular matrix）或正则矩阵（regular matrix）。、

## 可逆矩阵的性质

### 充要条件

对于一个 $n \times n$ 的矩阵 $A$，以下条件是等价的：

1. $A$ 是可逆的。
2. $A$ 的行列式 $\det(A) \neq 0$。
3. $A$ 的秩 $\text{rank}(A) = n$。
4. 行/列向量组线性无关。
5. 零空间只有零向量。$A\mathbf{x} = \mathbf{0}$ 只有零解。$\text{nullity}(A) = \mathbf{0}$。
6. 线性方程组 $A\mathbf{x} = \mathbf{b}$ 对于任意 $\mathbf{b}$ 都有唯一解。
7. $A$ 的所有特征值**均不为零**(可正可负可相同)。
8. $A$ 可以表示为初等矩阵的乘积，也就是高斯消元一定能把它变成单位矩阵
9. $A$ 的行/列最简形式是单位矩阵 $I_n$。
10. 伴随矩阵 $(A^*)$ 存在且可逆 $A^{-1} = \frac{1}{\det(A)} A^*$。

### 充分条件

$A$ 满足下面的条件就可逆，但可逆矩阵不一定满足下面的条件：

1. $A$ 是正交矩阵：$A^T A = I$。
2. $A$ 是正定矩阵：对于所有非零向量 $\mathbf{x}$，$\mathbf{x}^T A \mathbf{x} > 0$。这时候 $A$ 对称且特征值全为正数。

### 必要条件

若 $A$ 可逆，则 $A$ 满足下面的条件：

1. $A$ 对称 $\iff$ $A^{-1}$ 对称；$A$ 正交 $\iff$ $A^{-1}$ 正交；$A$ 正定 $\iff$ $A^{-1}$ 正定。
2. $A$ 的幂次 $A^k$ 也是可逆的，且 $(A^k)^{-1} = (A^{-1})^k$。
3. $A^{-1}$ 的特征值是 $A$ 的特征值的倒数，且对应特征向量相同。

### 注意

可逆和特征分解（相似对角化）之间没有必然联系。

可逆关心的是特征值有没有0,对角化关心的是特征向量有没有线性无关

如下表：

| 可逆？ | 特征分解？（相似对角化） | 例子                                             |
| ------ | ------------------------ | ------------------------------------------------ |
| 可逆   | 可对角化                 | $A = \begin{bmatrix}2 & 0 \\ 0 & 3\end{bmatrix}$ |
| 可逆   | 不可对角化               | $A = \begin{bmatrix}1 & 1 \\ 0 & 1\end{bmatrix}$ |
| 不可逆 | 可对角化                 | $A = \begin{bmatrix}0 & 0 \\ 0 & 1\end{bmatrix}$ |
| 不可逆 | 不可对角化               | $A = \begin{bmatrix}0 & 1 \\ 0 & 0\end{bmatrix}$ |

可逆**推不出**可对角化
不可逆**推不出**不可对角化

但若两者同时满足，则

可逆+可对角化 $\iff$  $A$ 的特征值全不为零 + 几何重数=代数重数

## 计算矩阵的逆

### 手算1:高斯-约旦消元法

步骤：

1. 构造增广矩阵 $[A | I_n]$，其中 $I_n$ 是 $n \times n$ 的单位矩阵。

2. 对增广矩阵进**行初等行变换**，直到左边的 $A$ 被化为单位矩阵 $I_n$。这时，增广矩阵的右边部分就变成了 $A$ 的逆矩阵 $A^{-1}$。

### 手算2：伴随矩阵法

伴随矩阵：

$$
\text{adj}(A) = \begin{bmatrix}C_{11} & C_{21} & \cdots & C_{n1} \\ C_{12} & C_{22} & \cdots & C_{n2} \\ \vdots & \vdots & \ddots & \vdots \\ C_{1n} & C_{2n} & \cdots & C_{nn}\end{bmatrix}\\[1em]

\text{或} \quad \text{adj}(A)_{ij} = (-1)^{i+j} M_{ij}
$$  

其中 $M_{ij}$ 是 $A$ 中去掉第 $i$ 行和第 $j$ 列后得到的 $(n-1) \times (n-1)$ 子矩阵的行列式。称为**代数余子式**

公式：

$$
A^{-1} = \frac{1}{\det(A)} \text{adj}(A)
$$

其中 $\text{adj}(A)$ 是 $A$ 的伴随矩阵

### 手算3：分块矩阵求逆

:::tip
上三角求逆依旧是上三角，下三角求逆依旧是下三角

速记：上三角分块矩阵的逆矩阵的上三角部分是 $-B^{-1}CD^{-1}$，下三角分块矩阵的逆矩阵的下三角部分是 $-D^{-1}CB^{-1}$。

:::

常见上三角分块矩阵：

$$
A = \begin{bmatrix}B & C \\ 0 & D\end{bmatrix}
$$  

其中 $B$ 和 $D$ 是可逆的方阵，那么 $A$ 的逆矩阵为：

$$
A^{-1} = \begin{bmatrix}B^{-1} & -B^{-1} C D^{-1} \\ 0 & D^{-1}\end{bmatrix}
$$

下三角分块矩阵：

$$
A = \begin{bmatrix}B & 0 \\ C & D\end{bmatrix}
$$

其中 $B$ 和 $D$ 是可逆的方阵，那么 $A$ 的逆矩阵为：

$$
A^{-1} = \begin{bmatrix}B^{-1} & 0 \\ -D^{-1} C B^{-1} & D^{-1}\end{bmatrix}
$$

### 手算4：2x2矩阵求逆(伴随矩阵的最简例子)

$$
A = \begin{bmatrix}a & b \\ c & d\end{bmatrix}
$$

如果 $ad - bc \neq 0$，则 $A$ 可逆，且其逆矩阵为：

$$
A^{-1} = \frac{1}{ad - bc} \begin{bmatrix}d & -b \\ -c & a\end{bmatrix}
$$

### Sherman-Morrison 公式

在机器学习中，常常需要把数据 $D$（长方形 $n \times d$ 矩阵）求内积 $D^T D$ 得到方阵 $C$，然后求逆。如果多了一个样本维度（也就是有新数据 $\mathbf{v}$），D 就变成了 $(n+1) \times d$ 的矩阵，求内积得到的方阵 $C$ 就可以更新成 $D^TD+\mathbf{v}\mathbf{v}^T$ 能不能快速求逆呢？答案是可以的，这就是 Sherman-Morrison 公式：

Sherman-Morrison 公式是用于**秩-1更新**的求逆公式。它提供了一种高效的方法来计算矩阵 $A$ 加上一个**秩-1**矩阵 $\mathbf{u}\mathbf{v}^T$ 的逆矩阵。

令 $A$ 是一个可逆的 $n \times n$ 矩阵，$\mathbf{u}$ 和 $\mathbf{v}$ 是 $n$ 维列向量，那么 $(A + \mathbf{u}\mathbf{v}^T)$是可逆的，当且仅当 $1 + \mathbf{v}^T A^{-1} \mathbf{u} \neq 0$：

$$
(A + \mathbf{u}\mathbf{v}^T)^{-1} = A^{-1} - \frac{A^{-1} \mathbf{u} \mathbf{v}^T A^{-1}}{1 + \mathbf{v}^T A^{-1} \mathbf{u}}
$$

记住形状，证明就是验证乘法是不是单位阵

这里面的向量 $\mathbf{u}$ 和 $\mathbf{v}$ 可以推广到扁平矩阵 $U(n \times k)$ 和 $V(k \times n)$，得到更一般的Woodbury 矩阵恒等式（Sherman-Morrison-Woodbury），针对**低秩-k更新** 的情况：

$$
(A + UV^T)^{-1} = A^{-1} - A^{-1} U (I + V^T A^{-1} U)^{-1} V^T A^{-1}
$$

:::tip
证明：构造了一个线性方程组来证明
![alt text](image-1.png)
:::
