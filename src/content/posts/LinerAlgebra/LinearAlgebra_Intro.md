---
title: 线性代数：从"列"的角度理解矩阵与向量
published: 2026-03-11
description: '这里参考gilbert strang的线性代数教材。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---


## 如何理解Ax

老爷子说“Multiplication $A\mathbf{x}$ Using **Columns** of $A$”，引出了两种不同但等价的计算思路，也就引出了值域空间和列空间这两个等价概念

### 第一种方法：**inner products** of the **rows** with $\mathbf{x}$

（线性变换角度）

将矩阵$A$的**行向量**与向量$\mathbf{x}$进行点积运算，得到结果向量的每个元素。这种方法强调了矩阵的行空间。得到的叫做**值域空间**（range space），也就是线性映射的输出空间。

### 第二种方法 : combination of the **columns** of $A$ with the **components** of $\mathbf{x}$

（线性组合角度）

这种视角下，$A\mathbf{x}$ 就是矩阵 $A$ 所有**列向量**的线性组合。而对于$\mathbf{x}$，他的每一个分量—— $A$ 中列向量的权重——可以取到任意实数，因此：

矩阵的所有**列向量**的**所有线性组合**所构成的向量空间称为矩阵的**列空间**（column space），记作 $C(A)$。也就是“The combinations of the columns fill out the column space of А.”

:::note  
注意这里定义列空间的时候并没有强调矩阵 $A$ 列向量的相关性，因为无论列向量是否相关，列空间都是由这些列向量的线性组合构成的。 
:::

## 如何理解AB

    AB = Sum of Rank One Matrices

即两个矩阵$A(m\times n)$和$B(n\times p)$的乘积是多个秩为1的矩阵的和。

这里不局限于数值运算，而是将A的列向量($m\times 1$)和B的行向量($1\times p$)进行**外积**运算，得到许多个秩为1的矩阵并相加。

![alt text](crmultiplication.png)