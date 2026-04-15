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

迹（Trace） 是矩阵运算中一个简单但非常强大的概念，尤其在范数、内积、特征值等领域频繁出现。

## 定义

只有方阵才有迹。对于一个 $n \times n$ 的矩阵 $A = [a_{ij}]$，它的迹定义为**主对角线元素的和**，是一个**标量**：

$$
\text{tr}(A) = a_{11} + a_{22} + \dots + a_{nn} = \sum_{i=1}^n a_{ii}
$$

## 迹的性质

假设 $A$ 和 $B$ 是 $n \times n$ 的矩阵，$c$ 是一个标量，那么迹满足以下性质：

1. **线性**：$\text{tr}(A + B) = \text{tr}(A) + \text{tr}(B)$ 和 $\text{tr}(cA) = c \cdot \text{tr}(A)$。

2. 转置不改变迹：$\text{tr}(A^T) = \text{tr}(A)$。
3. 共轭转置不改变迹：$\text{tr}(A^*) = \text{tr}(A)$。

4. **循环不变性**：$\text{tr}(ABC) = \text{tr}(BCA) = \text{tr}(CAB)$。
5. **乘积与转置**：$\text{tr}(A^T B) = \text{tr}(B^T A)=\sum_{i=1}^n\sum_{j=1}^n A_{ij} B_{ji}$。

即使A，B，C不是方阵，只要它们的**乘积是方阵**，循环不变性仍然成立。

由乘积与转置的性质可以看出，迹可以用来定义矩阵的 **Frobenius 内积** 对于两个同型矩阵 $A,B\in \mathbb{R}^{m \times n}$：

$$
\langle A, B \rangle_F = \text{tr}(A^T B)=\text{tr}(B^T A)\\
=\sum_{i=1}^n\sum_{j=1}^n A_{ij} B_{ji}
$$

- 把矩阵空间变成一个内积空间（标量）
- 当A和自己做内积时诱导出Frobenius范数：$\|A\|_F = \sqrt{\langle A, A \rangle_F} = \sqrt{\text{tr}(A^T A)}$

## 迹与特征值

一个重要的性质是：**矩阵的迹等于它的特征值之和**（考虑重根）。如果 $A$ 的特征值是 $\lambda_1, \lambda_2, \ldots, \lambda_n$，那么：

$$
\text{tr}(A) = \lambda_1 + \lambda_2 + \dots + \lambda_n
$$

这个性质在很多领域都有重要应用，比如在统计学中，协方差矩阵的迹等于数据的总方差。(对角线元素是方差，非对角线元素是协方差)

## 迹与矩阵求导

迹在矩阵微积分中也非常有用。对于一个函数 $f(A) = \text{tr}(A^T A)$，我们可以计算它的梯度（就是对A的导数）：

$$
\nabla_A f(A) = \frac{\partial f(A)}{\partial A} = 2A
$$

这个结果在机器学习中经常出现，比如在最小二乘法中，我们需要最小化 $\text{tr}((Y - XA)^T (Y - XA))$，通过计算梯度并设置为零，我们可以找到最优的参数矩阵 $A$。

## 附录：矩阵求导的符号约定

求导结果的形式取决于 分子布局 还是 分母布局。

- 分子布局（Numerator layout）：导数结果的维度与 分子 的维度一致。例如标量对向量求导得行向量（1×n）。

- 分母布局（Denominator layout）：导数结果的维度与 分母 的维度一致。例如标量对向量求导得列向量（n×1）。

本文采用分母布局。若想改用分子布局，只需对结果转置。

| 符号                                              | 含义                                           | 导完空间   |
| ------------------------------------------------- | ---------------------------------------------- | ---------- |
| $\frac{\partial y}{\partial \mathbf{x}}$          | 标量y对列向量 $\mathbf{x}$ 求导                | 列向量     |
| $\frac{\partial \mathbf{y}}{\partial \mathbf{x}}$ | 列向量 $\mathbf{y}$ 对列向量 $\mathbf{x}$ 求导 | 雅可比矩阵 |
| $\frac{\partial \mathbf{y}}{\partial A}$          | 向量 $\mathbf{y}$ 对矩阵 $A$ 求导              | 与$A$同型  |

### 标量对向量求导

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
