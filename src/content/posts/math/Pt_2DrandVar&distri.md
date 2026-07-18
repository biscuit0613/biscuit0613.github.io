---
title: 多维（二维）随机变量及其分布
published: 2025-08-23
description: '离散型多维随机变量，连续型多维随机变量，二维随机变量的分布'
tags: [概率论,多维随机变量]
category: '概率论与数理统计'
author: biscuit
draft: false
---

- [联合累积分布函数](#联合累积分布函数)
  - [边缘分布函数](#边缘分布函数)
- [二维离散型随机变量](#二维离散型随机变量)
  - [分布列](#分布列)
  - [边缘分布列](#边缘分布列)
- [二维连续型随机变量](#二维连续型随机变量)
  - [联合概率密度](#联合概率密度)
  - [边缘概率密度](#边缘概率密度)
- [常见连续性二维随机变量概率分布](#常见连续性二维随机变量概率分布)
  - [二维均匀分布](#二维均匀分布)
  - [二维正态分布](#二维正态分布)

**多维随机变量（随机向量）**:
$X_1,X_2,X_3,X_4,X_5...$ 为定义在同一片样本空间内的随即变量，称 $(X_1,X_2,X_3,...X_n)$ 为 n 维随机变量或 $n$ 维随机向量。

## 联合累积分布函数

这个概念是一位随机变量的累积分布函数到多维的推广。对于二维随机变量（$X，Y$）,记
$$
F(x,y)=P(X\leq x,Y\leq y)
$$
为$X，Y$的**联合累计分布函数**，简称**联合分布函数**,即$(X\leq x)\cap (Y\leq y)$的概率

联合分布函数的性质

- $(x,y)\in \mathbb{R^2},\;0\leq F(x,y)\leq1$

- 联合分布函数对每一个变量均单调不减
- $\lim\limits_{x\to-\infin}F(x,y)=0$,$\lim\limits_{y\to-\infin}F(x,y)=0$,$\lim\limits_{x\to-\infin,y\to-\infin}F(x,y)=0$,$\lim\limits_{x\to+\infin,y\to+\infin}F(x,y)=1$
- 联合分布函数对于每一个自变量都是右连续的
- 计算区域内的概率：
  $$
  \forall x_1\leq x\leq x_2,\;y_1\leq y\leq y_2\\
  P(x_1\leq X\leq x_2,y_1\leq Y\leq y_2 )=F(x_2,y_2)-F(x_1,y_2)-F(x_2,y_1)+F(x_1,y_1)
  $$
  （几何意义：围出的矩形面积）
  
### 边缘分布函数

已知联合分布函数，可以求得 $X,Y$ **各自的分布函数** $F_X(x),F_Y(y)$ ，称为**边缘分布函数**
$$
F_X(x)=P(X\leq x,\forall y)=F(x,+\infin)=\lim_{y\to\infin}F(x,y)\\
F_Y(y)=P(\forall X ,Y\leq y)=F(+\infin,y)=\lim_{x\to\infin}F(x,y)\\
$$

- 边缘分布就是把联合分布对另一个变量积分（连续型）/求和（离散型）
- 已知联合分布函数可以求边缘分布函数，但反过来，已知各自的分布函数，**并不能**求出联合分布函数。因为没有做**随机变量独立性检验**，不知道随机变量之间的依赖关系

## 二维离散型随机变量

若二维随机变量 $(X，Y)$ 的取值是有限对或可列无穷多对，则称 $(X，Y)$ 为二维离散型随机变量。

### 分布列

$$
P(X=x_i,Y=y_j)=p_{ij}
$$
也可以用一个二维矩阵来表示，矩阵满足

- $p_{ij}>0$
- $\sum_i\sum_j p_{ij}=1$，矩阵里所有元素之和为1
- 矩阵里划定区域G，$P((X,Y)\in G)=\sum_{(x_i,y_i)\in G}P(X=x_i,Y=y_i)$

### 边缘分布列

求 $X$ 的边缘分布列，定义为 $X$ 加 $Y$，把 $X$ 那一行所有 $Y$ 的概率全部加起来。$Y$ 的边缘分布列同理。
$$
P(X=x_i)=\sum_j^\infin P(X=x_i,Y=y_j)=\sum_{j=1}^\infin p_{ij}=p_{i\cdot}\\
P(Y=y_i)=\sum_i^\infin P(X=x_i,Y=y_j)=\sum_{i=1}^\infin p_{ij}=p_{\cdot j}\\
$$

:::tip  
其实边缘分布列和边缘分布函数都是让一个随机事件交上另一个必然事件，是由二维求一维的一种方式  
:::

一个盒子里面有3个2号球，一个一号球，一次取一个，任取两球，X，Y为球号的随机变量，求分布列＆边缘分布列

(X,Y)的可能取值：(1,2),(2,2),(2,1)

$$
P(1,2)=P(X=1)=\frac{1}{4}\\
P(2,1)=P(X=2)P(Y=1|X=2)=\frac{3}{4}\cdot\frac{1}{3}=\frac{1}{4}\\
P(2,2)=1-P(1,2)-P(2,1)=\frac{1}{2}\\
$$

X \ Y|1|2|
---|---|---|
1|0|$\frac{1}{4}$|
2|$\frac{1}{4}$|$\frac{1}{2}$|

## 二维连续型随机变量

### 联合概率密度

设连续型二维随机变量 $(X,Y)$ 的联合分布函数为 $F(x,y)$，如果存在一个非负函数 $f(x,y)$，使得
$$
F(x,y)=\int_{-\infin}^x\int_{-\infin}^yf(u,v)dudv,f(u,v)\geq 0
$$
则称 $f(x,y)$ 为 $(X,Y)$ 的**联合概率密度**，记作 $f(x,y)$，并且在 $f(x,y)$ 的连续点，有

$$
f(x,y)=\frac{\partial^2F(x,y)}{\partial x\partial y}=\frac{\partial^2F(x,y)}{\partial y\partial x}
$$

设 $G$ 是平面 $xoy$ 的一个区域，则**点落在区域 $G$** 里面的**概率**是区域 $G$ 内对 $f(x,y)$ 的二重积分(为以 $G$ 为下底，$f(x,y)$ 为上底的曲顶柱体的体积)

$$
P((x,y)\in G)=\underset{G}{\int\int}f(x,y)dxdy
$$

联合概率密度的性质：

1. $f(x,y)\geq0$

2. $\int_{-\infin}^{\infin}\int_{-\infin}^{\infin}f(u,v)dudv=1$

3. 同一维概率密度，边界线、点处的概率也为零。

:::tip  
1,2作为判定 $f(x,y)$ 是否为联合概率密度的充要条件。  
:::

### 边缘概率密度

二维随机变量 $(X,Y)$ 的**边缘概率密度**记作 $f_X(x),f_Y(y)$ 由 $(X,Y)$ **边缘分布函数**推导而来
$$
f_X(x)=F^{\prime}_X(x)=\bigg(\int_{-\infin}^x\bigg(\int_{-\infin}^{+\infin}f(u,v)dv\bigg)du\bigg)^{\prime}=\int_{-\infin}^{+\infin}f(x,y)dy\\[10bp]
f_Y(y)=F^{\prime}_Y(y)=\bigg(\int_{-\infin}^y\bigg(\int_{-\infin}^{+\infin}f(u,v)du\bigg)dv\bigg)^{\prime}=\int_{-\infin}^{+\infin}f(x,y)dx\\
$$

**边缘概率密度就是对应随机变量的概率密度。**  

它们是相等的概念，只是出发点不同：  

- 从联合分布“边缘化”得到的密度，叫“边缘密度”；  
- 从单个随机变量的分布定义得到的密度，就是该随机变量的“概率密度”；
  
本质上是同一个东西。

## 常见连续性二维随机变量概率分布

### 二维均匀分布

设 $G$ 为平面上的有界区域，面积记作 $S(G)$，

若二维随机变量 $X,Y$ 的**联合概率密度**
$$
f(x,y)=\left\{\begin{matrix}
  \begin{align*}
    &\frac{1}{S(G)}&&(x,y)\in G\\
    &0&&others
  \end{align*}
\end{matrix}\right.
$$
则称二维随机变量 $(X,Y)$ 在 $G$ 上服从**均匀分布**

- 均匀表示落在 $G$ 内**任意区域**的**概率相等**。(类比于几何概型，用度量之比表示概率)

- $(x,y)\in G$ 类似于二重积分，需要确定上下限。

### 二维正态分布

若二维随机变量 $(X,Y)$ 的**联合概率密度**
$$
f(x,y)=\frac{1}{2\pi\sigma_1\sigma_2\sqrt{1-\rho^2}}\cdot\exp\Bigg\{-\frac{1}{2(1-\rho^2)}\cdot\bigg[\frac{(x-\mu_1)^2}{\sigma_1^2}-2\rho\frac{(x-\mu_1)(y-\mu_2)}{\sigma_1\sigma_2}+\frac{(y-\mu_2)^2}{\sigma_2^2}\bigg] \Bigg\}
$$
则称二维随机变量 $(X,Y)$ 服从参数为 $\mu_1,\mu_2,\sigma_1^2,\sigma_2^2,\rho$ 的**正态分布**，记作 $(X,Y)\sim N(\mu_1,\mu_2,\sigma_1^2,\sigma_2^2,\rho)$，其中 $\rho$ 为相关系数，当 $\rho=0$ 时，这两个随机变量相互**独立**，联合概率密度也退化成二者概率密度之积。

- 二维正态分布的两个**边缘概率密度**都是对应的一维正态分布，即

$$
\begin{align*}
(X,Y)&\sim N(\mu_1,\mu_2,\sigma_1^2,\sigma_2^2,\rho)\\[5bp]
\Leftrightarrow X&\sim N(\mu_1,\sigma_1^2);Y\sim N(\mu_2,\sigma_2^2)
\end{align*}
$$

:::tip  
推导过程采用标准化，令 $u=\frac{x-\mu_0}{\sigma_1},v=\frac{y-\mu_2}{\sigma_2}$
关键是算下面这个积分，联想到正态概率密度的积分 $\int_{-\infin}^{\infty}\frac{1}{\sqrt{2\pi}\sigma}e^{-\frac{(x-\mu)^2}{2\sigma^2}}dx=1$ ,这里 $\sigma=\sqrt{1-\rho^2}$
$$
\int_{-\infty}^{\infty}exp{-\frac{(v-\rho u)^2}{2(1-\rho^2)}}dv=\sqrt{2\pi}\cdot\sqrt{1-\rho^2}
$$
:::
