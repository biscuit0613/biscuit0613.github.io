---
title: 矩阵的迹(Trace)
published: 2026-04-15
description: ''
image: ''
tags: [迹]
category: '线性代数'
draft: false 
lang: ''
---

迹（Trace） 表示矩阵的能量。

## 定义

只有方阵才有迹。对于一个 $n \times n$ 的矩阵 $A = [a_{ij}]$，它的迹定义为**主对角线元素的和**，是一个**标量**：

$$
\text{tr}(A) = a_{11} + a_{22} + \dots + a_{nn} = \sum_{i=1}^n a_{ii}
$$

## 迹的性质

假设 $A$ 和 $B$ 是 $n \times n$ 的矩阵，$c$ 是一个标量，那么迹满足以下性质：

1. **线性**：$\text{tr}(A + B) = \text{tr}(A) + \text{tr}(B)$ 和 $\text{tr}(cA) = c \cdot \text{tr}(A)$。

2. 转置不改变迹：$\text{tr}(A^T) = \text{tr}(A)$。
3. 共轭转置不改变迹：$\text{tr}(A^*) = \text{tr}(A),\text{其中}A^*=\overline{A^T}={\overline{A}}^T$。

4. **循环不变性**：$\text{tr}(ABC) = \text{tr}(BCA) = \text{tr}(CAB)$。即使A，B，C不是方阵，只要它们的**乘积是方阵**，循环不变性仍然成立。这进一步引出了**相似变换不变性**：如果两个矩阵相似（即 $B = P^{-1}AP$），那么它们的迹相等：
   $$
   \text{tr}(B) = \text{tr}(P^{-1}AP) = \text{tr}(APP^{-1}) = \text{tr}(A \cdot I) = \text{tr}(A)
   $$
   这意味着迹是矩阵的一种固有几何属性，不随坐标系的选取（基变换）而改变。
5. **乘积与转置**：$\text{tr}(A^T B) = \text{tr}(B^T A)=\sum_{i=1}^n\sum_{j=1}^n A_{ij} B_{ji}$。
6. **迹等于特征值之和**：如果 $A$ 的特征值是 $\lambda_1, \lambda_2, \ldots, \lambda_n$，那么 $\text{tr}(A) = \lambda_1 + \lambda_2 + \dots + \lambda_n$。推广到**方阵的幂次**：
   $$
   \text{tr}(A^k) = \lambda_1^k + \lambda_2^k + \dots + \lambda_n^k
   $$
7. 若 $A=\alpha \beta^T$，那么 $\text{tr}(A) = \text{tr}(\alpha \beta^T) = \alpha^T \beta = \beta^T \alpha$。
8. 二次型的迹：对于一个对称矩阵 $A$ 和一个向量 $\mathbf{x}$，$\text{tr}(\mathbf{x}^T A \mathbf{x}) = \mathbf{x}^T A \mathbf{x}$。

由乘积与转置的性质可以看出，迹可以用来定义矩阵的 **Frobenius 内积** 对于两个同型矩阵 $A,B\in \mathbb{R}^{m \times n}$：

$$
\langle A, B \rangle_F = \text{tr}(A^T B)=\text{tr}(B^T A)\\
=\sum_{i=1}^n\sum_{j=1}^n A_{ij} B_{ji}
$$

- 把矩阵空间变成一个内积空间（标量）
- 当A和自己做内积时诱导出Frobenius范数：$\|A\|_F = \sqrt{\langle A, A \rangle_F} = \sqrt{\text{tr}(A^T A)}$

关于性质6：如果 $A$ 可以对角化，即存在可逆阵 $P$ 使得 $P^{-1}AP = \Lambda$，其中 $\Lambda$ 是对角线上为特征值 $\lambda_i$ 的对角阵。利用相似不变性知道 $Tr(A) = Tr(P^{-1}AP) = Tr(\Lambda)$。而对角阵 $\Lambda$ 的迹显然就是 $\sum \lambda_i$。因为 $(P^{-1}AP)^k = P^{-1}A^kP = \Lambda^k$。$\Lambda^k$ 的对角线元素正是 $\lambda_1^k, \lambda_2^k, \dots, \lambda_n^k$。同理，根据迹的相似不变性：$Tr(A^k) = Tr(\Lambda^k) = \sum \lambda_i^k$。

## 迹与矩阵求导

对于一个函数 $f(A) = \text{tr}(A^T A)$，我们可以计算它的梯度（就是对A的导数）：

$$
\nabla_A f(A) = \frac{\partial f(A)}{\partial A} = 2A
$$

这个结果在机器学习中经常出现，比如在最小二乘法中，我们需要最小化 $\text{tr}((Y - XA)^T (Y - XA))$，通过计算梯度并设置为零，我们可以找到最优的参数矩阵 $A$。

## 附录：矩阵求导的符号约定

求导结果的形式取决于 分子布局 还是 分母布局。

- 分子布局（Numerator layout）：导数结果的维度与 **分子** 的维度一致。例如标量对向量求导得行向量（1×n）。

- 分母布局（Denominator layout）：导数结果的维度与 **分母** 的维度一致。例如标量对向量求导得列向量（n×1）。

AI 领域（以及机器学习常用教材）通常默认使用【分母布局】。 即：如果 $\mathbf{y}$ 是标量，$x$ 是列向量，那么 $\frac{\partial \mathbf{y}}{\partial \mathbf{x}}$ 也是一个列向量。这样梯度更新时直接用 $\mathbf{x} - \eta \frac{\partial \mathbf{y}}{\partial \mathbf{x}}$ 格式非常统一

| 符号                                              | 含义                                           | 导完空间                     |
| ------------------------------------------------- | ---------------------------------------------- | ---------------------------- |
| $\frac{\partial y}{\partial \mathbf{x}}$          | 标量y对列向量 $\mathbf{x}$ 求导                | 与 $\mathbf{x}$ 同型 （n×1） |
| $\frac{\partial \mathbf{y}}{\partial \mathbf{x}}$ | 列向量 $\mathbf{y}$ 对列向量 $\mathbf{x}$ 求导 | 雅可比矩阵                   |
| $\frac{\partial \mathbf{y}}{\partial A}$          | 向量 $\mathbf{y}$ 对矩阵 $A$ 求导              | 与$A$同型                    |

### 标量对向量求导得到同型向量

$$
\begin{aligned}
f(\mathbf{x}) = \langle \mathbf{a}, \mathbf{x} \rangle &= \mathbf{a}^T \mathbf{x}&;\quad

\frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= \frac{\partial \mathbf{a}^T \mathbf{x}}{\partial \mathbf{x}} = \mathbf{a}\\

f(\mathbf{x}) = \langle \mathbf{x}, \mathbf{a} \rangle &= \mathbf{x}^T \mathbf{a}&;\quad
\frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= \frac{\partial \mathbf{x}^T \mathbf{a}}{\partial \mathbf{x}} = \mathbf{a}\\

f(\mathbf{x}) &= \mathbf{x}^TA\mathbf{x}&;\quad
\frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= \frac{\partial \mathbf{x}^TA\mathbf{x}}{\partial \mathbf{x}} = (A + A^T)\mathbf{x}\\

if\quad A\quad is\quad symmetric,f(\mathbf{x}) &= \mathbf{x}^TA\mathbf{x}&;\quad \frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= 2A\mathbf{x}\\

f(\mathbf{x}) = ||\mathbf{x}||_2^2 &= \mathbf{x}^T\mathbf{x}&;\quad
\frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= \frac{\partial \mathbf{x}^T\mathbf{x}}{\partial \mathbf{x}} = 2\mathbf{x}\\

f(\mathbf{x}) = ||\mathbf{x}-\mathbf{a}||_2^2 &= (\mathbf{x}-\mathbf{a})^T(\mathbf{x}-\mathbf{a})&;\quad
\frac{\partial f(\mathbf{x})}{\partial \mathbf{x}} &= \frac{\partial (\mathbf{x}-\mathbf{a})^T(\mathbf{x}-\mathbf{a})}{\partial \mathbf{x}} = 2(\mathbf{x}-\mathbf{a})

\end{aligned}
$$
