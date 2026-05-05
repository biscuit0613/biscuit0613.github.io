---
title: solve_Ax=B:线性方程组求解,矩阵LU分解,矩阵的稳定性
published: 2026-04-15
description: '高斯消元法和LU分解是求解线性方程组 $A\mathbf{x} = \mathbf{b}$ 的两种常用方法。本文将介绍这两种方法的基本原理、步骤以及它们之间的关系。顺便提一下矩阵的稳定性问题。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

紧接着[linear_space.md](https://biscuit0613.github.io/posts/lineralgebra/linear_space/)中对矩阵的列空间、行空间和零空间的定义，我们可以通过这些空间来理解和求解方程组 $A\mathbf{x} = \mathbf{b}$。

对于矩阵 $A\in \mathbb{R}^{m\times n}$

:::tip
行满秩，列无敌
        ----帕拉迪宇
:::

$$
\begin{cases}
m \leq n,\text{A行满秩} \rArr A\mathbf{x}\text{可以构成} \mathbb{R}^m \text{中任意向量} \\
m \geq n,\text{A列满秩} \rArr A\mathbf{x}\text{不存在非零的} \mathbf{x} \text{使 } A\mathbf{x}=0
\end{cases}
$$

如果右端项 $b$ 落在矩阵 $A$ 的列空间中，$b\in \mathcal{C}(A)$，那么方程组 $A\mathbf{x} = \mathbf{b}$ 就有解。此时称线性系统 $A\mathbf{x} = \mathbf{b}$ 是 **兼容的** (consistent)。如果 $b$ 不在列空间中，则方程组无解，称为 **不兼容的** (inconsistent)。

判断方程组是否兼容的一个常用方法是将**增广矩阵** $[A | \mathbf{b}]$ 进行行变换，观察其行秩是否与 $A$ 的行秩相同：

- 如果 $rank([A | \mathbf{b}]) = rank(A)$，则方程组兼容。当方程组兼容时，解的结构取决于矩阵 $A$ 的秩：

  - 如果 $rank(A)=$ 列数 $n$（未知数的数量），则方程组有唯一解。
  - 如果 $rank(A)<$ 列数 $n$，则方程组有无穷多解，这些解可以表示为一个特解加上零空间的任意向量的线性组合。

- 如果 $rank([A | \mathbf{b}]) > rank(A)$，则方程组不兼容，无解。

:::tip

有如下几个等价的条件：

1. $A\mathbf{x} = \mathbf{b}$ 有唯一解。
2. $A\mathbf{x}= \mathbf{0}$ 只有零解。
3. $A$ 可逆（是非奇异的）
4. $A$ 的行列式不为零。
5. rank(A) = n（列数）

:::

## 行变换求解线性方程组

采用基本行变换(参考[BasicChange.md](https://biscuit0613.github.io/posts/lineralgebra/linearalgebra_basic_change/))进行转化:

对增广矩阵 $[A \mid \mathbf{b}]$ 进行初等行变换，化为行最简形（Reduced Row Echelon Form）：

$$
\begin{bmatrix}
A \mid \mathbf{b}
\end{bmatrix}
\xrightarrow{\text{行变换}}
 \begin{bmatrix}
 I_r &F &\mathbf{d} \\[10pt]
 0 & 0 & 0
\end{bmatrix}\\[5pt]
\text{或等价地：}\\
A\mathbf{x}=b \rArr A'x = b'
$$

其中 $A'$ 是 $A$ 经过行变换后的**上三角矩阵**，$b'$ 是 $b$ 经过相同变换后的向量；$I_r$ 是 $r$ 维的单位矩阵，$r$ 是 $A$ 的秩。$F$ 是 $r \times (n-r)$ 矩阵

在方程组有解的情况下，上三角阵主对角线上无零元素。增广矩阵变换后的行最简最后一列无主元）

- 一个特解 $\mathbf{x}_p$ 为：自由变量取 $0$，主元变量取 $\mathbf{d}$ 的对应分量。

- 齐次解（零空间）由 $F$ 确定：自由变量取标准基向量，主元变量取 $-F$ 的对应列。

通解 = 特解 + 零空间任意向量。

### 高斯消元法

分为两步

1. **前向消元**：逐渐将第i行到第n行的 $x_j,j<i$消去，得到上三角矩阵 $A'$ 和变换后的向量 $b'$。
2. **回代求解**：从最后一行开始，逐行向上求解未知数。

把系数矩阵变成上三角形的过程，等价于第 $j$ 步用初等变换把第 $j$ 列的主对角线下方元素消为零。

设 $A^{(0)} = A$ 是原始矩阵，$A^{(1)}, A^{(2)}, \dots, A^{(n-1)}$ 是每一步**消元后**的矩阵。每一步的初等变换都可以表示为一个初等矩阵 $E^{(j)}$，使得：

$$
A^{(j)} = E^{(j)} A^{(j-1)}
$$

$E^{(j)}$ 是单位阵初等变换来的，唯一的区别就是他的j列j行的元素( $E^{(j)}_{jj}$ )被修改成 $-\dfrac{A^{(j-1)}_{ij}}{A^{(j-1)}_{jj}}$

定义一个向量 $\mathbf{l}_j$，其第 $i$ 个元素为 $-\dfrac{A^{(j-1)}_{ij}}{A^{(j-1)}_{jj}}$，其他元素为 $0$，则 $E^{(j)}$ 可以表示为：

$$
E^{(j)} = I - \mathbf{l}_j \mathbf{e}_j^T
$$

其中 $\mathbf{e}_j$ 是第 $j$ 个标准基向量。

可能的问题：某一行的主元过小，不适合做分母,某一行的应该等于零的值在数值计算中很可能因为舍入误差变成非零，导致出错。

解决：**主元法**

在第k步前向消除时，选择**第k列中绝对值最大**的元素所在的行作为**主元行**，与**第k行**交换位置。这样可以避免数值不稳定的问题，提高算法的鲁棒性。

这个不是换一次就可以，而是每一步都需要选一次列主元，直到消元完成。

置换的操作可以通过一个置换矩阵 $P$ 来表示，$P$ 是一个单位矩阵经过行交换得到的矩阵。对于每一步的主元选择和行交换，我们都有一个对应的置换矩阵 $P^{(j)}$，使得：

$$
P^{(j)} A^{(j-1)} = A^{(j)}
$$

所以总结下来完整的带主元法的高斯消元过程可以表示为：

$$
P^{(n-1)} E^{(n-1)} P^{(n-2)} E^{(n-2)} \cdots P^{(1)} E^{(1)} P^{(0)} E^{(0)} A = A^{(n-1)}
$$

$$
\begin{aligned}
    P^{(n-1)} E^{(n-1)} P^{(n-2)} E^{(n-2)} \cdots P^{(1)} E^{(1)} P^{(0)} E^{(0)} A \mathbf{x} &= P^{(n-1)} E^{(n-1)} P^{(n-2)} E^{(n-2)} \cdots P^{(1)} E^{(1)} P^{(0)} E^{(0)} \mathbf{b} \\
\iff A^{(n-1)} \mathbf{x} &= \mathbf{b}^{(n-1)}
\end{aligned}
$$

### 矩阵的LU分解

:::tip
高斯消元的前向消元过程等价于矩阵分解
:::

$$
A = LU
$$

其中 $L$ 是一个单位下三角矩阵（对角线元素全为 1，上三角部分全为 0），$U$ 是一个上三角矩阵。通过这种分解，我们可以将求解 $A\mathbf{x} = \mathbf{b}$ 转化为两个简单的三角矩阵方程：

$$
\begin{cases}
L\mathbf{y} = \mathbf{b} .... (1)\\
U\mathbf{x} = \mathbf{y} .... (2)
\end{cases}
$$

首先求解方程 (1) 来得到 $\mathbf{y}$，然后将 $\mathbf{y}$ 代入方程 (2) 来求解 $\mathbf{x}$。

### LU分解的手动计算

LU 分解的核心思想是将一个矩阵 $A$ 分解为一个单位下三角矩阵 $L$（Lower triangular，主对角线全为 1）和一个上三角矩阵 $U$（Upper triangular）。它的本质其实就是高斯消元法的矩阵表达。我们用一个简单的 $3 \times 3$ 矩阵来演示手算过程。

待分解矩阵示例假设我们要分解矩阵 $A$：

$$
A = \begin{bmatrix} 2 & 3 & 1 \\ 4 & 7 & 0 \\ -2 & 2 & 14 \end{bmatrix}
$$

手算步骤我们在对 $A$ 进行 **高斯消元** （按列顺序处理，从左到右。）得到 $U$ 的过程中，将消元所用的系数填入 $L$ 的对应位置。

系数 $l_{ij}$ 是在消元过程中用来消去 $A(U)$ 第 $i$ 行第 $j$ 列元素的系数，也是存入 $L(i,j)$ 的元素。

对于第 $j$ 列的消元，系数 $l_{ij}$ 的计算公式为：

- 选取第 $j$ 列的主元元素 $A_{jj}$。
- 对于第 $i$ 行（$i > j$），计算消元系数：$l_{ij} = \dfrac{A_{ij}}{A_{jj}}$。

然后用这个系数 $l_{ij}$ 来更新第 $i$ 行：

$$
R_i \leftarrow R_i - l_{ij} R_j
$$

第一步：处理第一列，我们要把第 2 行和第 3 行的第一列元素化为 0。

$R_2 \leftarrow R_2 - (2)R_1$：消掉 4。系数 $l_{21} = 2$。

$R_3 \leftarrow R_3 - (-1)R_1$：消掉 -2。系数 $l_{31} = -1$。

变换后的矩阵：
$$
\begin{bmatrix} 2 & 3 & 1 \\ 0 & 1 & -2 \\ 0 & 5 & 15 \end{bmatrix}
$$

第二步：处理第二列我们要把第 3 行的第二列元素化为 0。

$R_3 \leftarrow R_3 - (5)R_2$：消掉 5。系数 $l_{32} = 5$。

变换后的矩阵（这就是 $U$）：

$$
U = \begin{bmatrix} 2 & 3 & 1 \\ 0 & 1 & -2 \\ 0 & 0 & 25 \end{bmatrix}
$$

构建矩阵 $L$矩阵 $L$ 的主对角线全是 1，其余位置填入我们刚才记录的系数 $l_{ij}$：

$$
L = \begin{bmatrix} 1 & 0 & 0 \\ l_{21} & 1 & 0 \\ l_{31} & l_{32} & 1 \end{bmatrix} = \begin{bmatrix} 1 & 0 & 0 \\ 2 & 1 & 0 \\ -1 & 5 & 1 \end{bmatrix}
$$

验证结果我们将 $L$ 和 $U$ 相乘，看是否回到 $A$：

$$
\begin{bmatrix} 1 & 0 & 0 \\ 2 & 1 & 0 \\ -1 & 5 & 1 \end{bmatrix} \begin{bmatrix} 2 & 3 & 1 \\ 0 & 1 & -2 \\ 0 & 0 & 25 \end{bmatrix} = \begin{bmatrix} 2 & 3 & 1 \\ 4+0 & 6+1 & 2-2 \\ -2+0 & -3+5 & -1-10+25 \end{bmatrix} = \begin{bmatrix} 2 & 3 & 1 \\ 4 & 7 & 0 \\ -2 & 2 & 14 \end{bmatrix} = A
$$

💡 手算小技巧总结

保持 $L$ 的对角线为 1：这是 Doolittle 分解法的标准。

符号不要搞反：如果在消元时是 $R_i - k R_j$，那么 $L$ 矩阵对应位置存的就是这个 $k$；如果是 $R_i + k R_j$，存的就是 $-k$。

什么时候不能直接分解？：如果在消元过程中发现主元（对角线元素）为 0，普通的 LU 分解就会失效，这时候需要进行行交换，也就是引入置换矩阵 $P$，变为 $PA = LU$ 分解。

## 矩阵的稳定性，衡量标准和解决方法

在数值计算中，矩阵的稳定性是一个重要的概念，通常通过**条件数**（Condition Number）来衡量。对于一个矩阵 $A$，其条件数定义为：

$$
\kappa(A) = \|A\| \cdot \|A^{-1}\|
$$

其中 $\|\cdot\|$ 是某种矩阵范数。条件数越大，矩阵越不稳定，解的相对误差也会越大。

### 条件数的由来：误差e与残差r

设 $\mathbf{x}$ 是 $A\mathbf{x} = \mathbf{b}$ 的一个解，$\tilde{\mathbf{x}}$ 是数值计算得到的近似解，那么误差 $\mathbf{e}$ 和残差 $\mathbf{r}$ 定义为：

$$
\begin{cases}
    \mathbf{e} = \mathbf{x}-\tilde{\mathbf{x}} \\
\mathbf{r} =\mathbf{b} - A\tilde{\mathbf{x}}
\end{cases}

\iff A\mathbf{e} = \mathbf{r}
$$

在实际计算中，单纯用误差和残差不能反映矩阵本身的稳定性，因此对绝对误差的上限用矩阵进行表示：

$$
||\mathbf{e}|| =||x-\tilde{x}|| = ||A^{-1}r|| \leq ||A^{-1}|| \cdot ||r||
$$

所以相对误差的上限为：

$$
\frac{||\mathbf{e}||}{||\mathbf{x}||} \leq \frac{||A^{-1}|| \cdot ||r||}{||\mathbf{x}||}
$$

想办法把右边化成和输入$\mathbf{x}$无关：

$$
\frac{||\mathbf{e}||}{||\mathbf{x}||} \leq ||A^{-1}|| \cdot \frac{||r||}{||\mathbf{b}||} \cdot \frac{||\mathbf{b}||}{||\mathbf{x}||}\\
\leq ||A^{-1}|| \cdot ||A|| \cdot \frac{||r||}{||\mathbf{b}||}\\
 = \kappa(A) \cdot \frac{||r||}{||\mathbf{b}||}
$$

### 优化误差和残差：迭代

求解迭代的基本步骤：

从一个初始猜测 $\mathbf{x}^{(0)}$ 开始，

对于第k步计算残差 $\mathbf{r}^{(k)} = \mathbf{b} - A\mathbf{x}^{(k)}$。

根据残差，更新修正量 $\mathbf{\delta x}^{(k)}$，使得 $A\mathbf{\delta x}^{(k)} \approx \mathbf{r}^{(k)}$。

用修正量更新解 $\mathbf{x}^{(k+1)} = \mathbf{x}^{(k)} + \mathbf{\delta x}^{(k)}$。

重复，直到残差足够小或者达到预设的迭代次数。

### 优化矩阵的条件数：预处理病态矩阵

对于病态矩阵，我们可以通过**预处理**来改善其条件数。预处理就要引入 **预条件子**（Preconditioner） $M$，它是一个近似于 $A^{-1}$ 的矩阵，。通过左乘预条件子，期望 $MA$ 的条件数比 $A$ 更小：
