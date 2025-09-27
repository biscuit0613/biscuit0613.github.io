---
title: 概率论：一维随机变量及其分布
published: 2025-08-20
description: 分布函数，概率密度，离散型随机变量，连续型随机变量,随机变量函数。
tags: [概率论，随机变量]
category: 概率论
author: biscuit
draft: false
---

- [随机变量定义](#随机变量定义)
- [累计分布函数(Cumulative Distribution Function, CDF)](#累计分布函数cumulative-distribution-function-cdf)
  - [分布函数的性质](#分布函数的性质)
- [离散型随机变量及其分布列](#离散型随机变量及其分布列)
  - [分布列的性质](#分布列的性质)
- [常见的离散型随机变量概率分布](#常见的离散型随机变量概率分布)
  - [0-1分布/两点分布](#0-1分布两点分布)
  - [二项分布(有放回抽样)](#二项分布有放回抽样)
  - [泊松分布](#泊松分布)
  - [几何分布(二项分布首次成功)](#几何分布二项分布首次成功)
  - [超几何分布（不放回找次品）](#超几何分布不放回找次品)
- [连续型随机变量及其概率密度](#连续型随机变量及其概率密度)
  - [概率密度的性质](#概率密度的性质)
- [常见的连续型随机变量概率分布](#常见的连续型随机变量概率分布)
  - [均匀分布](#均匀分布)
  - [指数分布](#指数分布)
  - [正态分布](#正态分布)
    - [标准正态分布](#标准正态分布)
- [随机变量函数Y=g(X)的概率密度和分布函数](#随机变量函数ygx的概率密度和分布函数)

## 随机变量定义

随机试验的样本空间 $S$，对于 $S$ 中每个样本点 $e$，都有唯一的实数值 $X(e)$ 与之对应，称 $X(e)$ 为随机变量。随机变量按取值方式可分为两类：离散型和连续型。

- 随机变量是定义在样本空间上的实值函数， 简而言之，就是把事件和数之间建立双射。
  
- 随机变量的取值与概率分布（也就和事件与概率分布）之间有双射。

## 累计分布函数(Cumulative Distribution Function, CDF)

设X为一随机变量，$F(x)=P(X\leq x),-\infin\leq x\leq\infin$ 称为X的**累计分布函数**简称**分布函数**
，就是随机变量落在**某点左边**的概率。
$$
\begin{align*}
P(a< X<b)&=P(X<b)-P(X<a)\\
P(X=a)&=P(x\leq a)-P(x<a)=F(a)-F(a^-)\text{表示左极限}\\
P(X<a)&=1-P(X\geq a)=1-F(a)
\end{align*}
$$

### 分布函数的性质

1. $0\leq F(x)=P(X\leq x)\leq 1$

2. $x_1\leq x_2,F(x_1)\leq F(x_2),F(x)$ 是单调非减的
   - 离散型随机变量的分布函数是**阶梯式的**，断点的横坐标对应随机变量的取值，断点的高度（y坐标之差）是随机变量的概率
   - 连续型随机变量的分布函数是光滑的
3. $F(-\infin)=\lim_{x\to-\infin}F(x)=0,F(+\infin)=\lim_{x\to\infin}F(x)=1$
4. $F(x^+)=F(x)$ ，分布函数是右连续的
   + 如果是离散型随机变量，阶梯上是左闭右开（左边实心右边空心）
   + 对于连续性随机变量，分布函数是连续的（由原函数连续），在某点处的分布函数为0，因此随机变量落在区间内不考虑端点。

eg:分布函数 $F(x)=A+B\arctan x,x\in R$

:::tip[solution]
根据性质3：
$$
\begin{cases}
  \lim_{x\to+\infin} F(x)=1\\
  \lim_{x\to-\infin} F(x)=0
\end{cases}
$$
:::

## 离散型随机变量及其分布列

**定义**：只取有限个值或可列无穷多个值的随机变量称为离散型随机变量

**分布列**：既反映**每个样本点**的取某值的**概率**
$$
P(X=x_k)=p_k,k=1,2,3...
$$

或记作

$X$|$x_1$|$x_2$|$x_3$|...|$x_n$
---|---|---|---|---|---
$P$|$p_1$|$p_2$|$p_3$|...|$x_n$

离散型随机变量的分布列和分布函数之间是一一对应的。分布函数是分布列中所有**不大于**该数的**概率之和**
$$
F(x_i)=P(X\leq x_i)=\sum_{k=1,x_k\leq x_i}^iP(X=x_k)=\sum_{k=1}^ip_k
$$
分布列中各随机变量的**值**就是分布函数中**跳跃点的x坐标**，概率就是**跳跃高度**。由于分布函数的右连续性，在阶梯上的端点是**左闭右开**：
$$
P(X=x_i)=F(x_i)-F(x_i^-)
$$

### 分布列的性质

1. $p_k\geq0$

2. $\sum_{k=1}^{\infin}p_k=1$
3. 分布列的期望：$E(x)=\sum_{k=1}^{n}x_kp_k$
4. 样本点的方差：

  $$
  D(x)=\frac{1}{n}\sum_{k=1}^{n}(x_k-\overline{x})^2\\
  \Leftrightarrow\sum_{k=1}^{n}(x_k-\overline{x})^2\cdot p_k
  $$

5. 分布列的方差(与样本点的方差区分开)：推导见高中课本。

  $$
  D(x)=E(X^2)-E^2(X)
  $$

## 常见的离散型随机变量概率分布

### 0-1分布/两点分布

随机变量的取值只有0和1，其分布律为：
$$
P{x=k}=p^k\cdot (1-p)^{1-k},k=0,1
$$

X|0|1
---|:---:|----:
$P$|$1-p$|$p$

### 二项分布(有放回抽样)

分布列为
$$
P(x=k)=\binom{n}{k}\,p^{k}(1-p)^{\,n-k},\qquad k=0,1,2,\ldots,n
$$
详见二项分布那一章

### 泊松分布

见二项分布

### 几何分布(二项分布首次成功)

背景：假定我们有一系列伯努利试验，其中每一个的成功概率为 $p$，失败概率为 $1-p$。在获得**第一次成功**前要进行多次试验？

分布列为
$$
P(x=k)=p(1-p)^{k-1},k=1,2,3...
$$
推导：由几何级数的求和公式(等比求和)可以验证
$$
\sum_{k=1}^{\infin}p(1-p)^{k-1}=\frac{p}{1-(1-p)}
$$

**几何分布具有无记忆性**：只要期待的“是”（伯努利事件首次成功）没有出现，那么几何分布就仿佛不记得之前发生的事件。值得注意的是在离散分布中只有几何分布具有此特性
  
$$
P(X>m+n|X>n)=P(X>m),m,n\text{是正整数}
P(X=m+n|X>n)=P(X=m),m,n\text{是正整数}
$$
在这两个式子中，可以理解为 $m$ 次之后伯努利事件首次成功，尝试 $m$ 次与 $n+m$ 次的概率相同。

### 超几何分布（不放回找次品）

在产品质量的**不放回**抽检中，若 $N$ 件产品中有 $M$ 件次品，抽检 $n$ 件时所得次品数 $X=k$，此时有
$$
P(X=k)=\frac{\binom{M}{k}\binom{N-M}{n-k}}{\binom{N}{n}}
$$

总体 $N$ 很大，抽样 $n$ 很小时，可以用**二项分布近似超几何分布**。此时次品率占主导地位，不放回的那一部分样品相比于总样品微不足道。

## 连续型随机变量及其概率密度

对于非离散型的随机变量 $X$，其取值不能一一列举出来，因此就不能像离散型随机变量那样使用分布列描述它。

**概率密度**：引入**概率密度函数**来描述连续型随机变量。如果对连续型随机变量 $X$ 的**累计分布函数** $F(x)$ ，存在非负函数 $f(x)$ ，使对于任意实数$x$有

$$
F(x)=\int_{-\infty}^xf(t)dt,
$$

则称 $X$ 为**连续型随机变量** ，其中函数 $f(x)$ 称为 $X$ 的**概率密度函数**，简称**概率密度**。

### 概率密度的性质

1. $f(x)>0$
  
2. $F(x)$ 从几何意义上看是**概率密度曲线与坐标轴**围成的面积， $F(+\infin)=\int_{-\infin}^{+\infin}f(x)=1$ 和x轴围成的面积是1。
  
3. 表示点落在区间的概率：$P(x_1< X< x_2)=F(x_2)-F(x_1)=\int_{x_1}^{x_2}f(t)dt$ 。从这里可以看出**连续型随机变量**在**某一确定点的概率**取值为零（曲边梯形变成一条线，面积为零），故连续型随机变量计算区间概率时，区间端点可有可无。
4. $f(x)$ 的值反应 $X$ 落在 $x$ 的邻域 $(x,x+\Delta x)$ 的概率约为 $f(x)\Delta x$，近似成一个矩形的面积。
   $$
   \begin{align*}
   f(x)=F^\prime(x&)=\lim_{\Delta x\to 0}\frac{F(x+\Delta x)-F(x)}{\Delta x}\\[5bp]
   &=\lim_{\Delta x\to 0}\frac{P(x<X<x+\Delta x)}{\Delta x}\\
   \Leftrightarrow f(x)\cdot\Delta x&=P(x<X<x+\Delta x)
   \end{align*}
   $$
5. 当 $f(x)$ 可积时，其原函数 $F(x)$ 连续；当 $f(x)$ 可积且连续时，$F(x)$ 可导。$F^\prime(x)=f(x)$

- 1，2 是判定一个函数 $f(x)$ 是否为概率密度函数的**充要条件**
- 由 3，概率为零不是不可能事件

eg: 设随机变量 $X$ 的概率密度函数是 $\begin{cases}Axe^{-x^2},x>0\\0,x\leq0\end{cases}$ 求 $A$ 以及分布函数 $F(x)$

:::tip[solution]
$$
\begin{align*}
&\int_{-\infin}^{+\infin}f(x)dx=1\\
&\text{这里注意按照题目缩小随机变量的取值范围}\\
&\int_{-\infin}^{+\infin}Axe^{-x^2}dx=\frac{A}{2}(-e^{-x^2}\vert_0^\infin)=1\\
&A=2\\
&F(x)=\int_{-\infin}^xf(x)dx=0,x\leq0\\
&F(x)=\int_{0}^xf(x)dx=\int_{0}^x2te^{-t^2}dt=1-e^{-x^2},x>0\\
&\therefore F(x)=\begin{cases}
  0,x\leq0\\
  1-e^{-x^2},x>0
\end{cases} 
\end{align*}
$$
:::

## 常见的连续型随机变量概率分布

### 均匀分布

若连续型随机变量 $X$ 具有**概率密度**  :
$$
f(x) = \left\{
  \begin{matrix}
  \begin{align*}
    &\frac{1}{b − a} , a < x < b\\
    &0 \ , else\\
  \end{align*}
  \end{matrix}\right.
$$

则称 $X$ 在区间 $(a,b)$ 上服从均匀分布,记作 $X\sim U(a,b)$ 。期望 $E=\frac{a+b}{2}$ ，方差 $D=\frac{(b-a)^2}{12}$

- 均匀意思是等可能，随机变量落在 $[a,b]$ 中长度相等的子区间 $[x_1,x_2]$ 是等可能的,都是 $\frac{x_2-x_1}{b-a}$

均匀分布的**分布函数**:

$$
F(x)=\left\{\begin{matrix}
  \begin{align*}
    &0&x<a\\
    &\frac{x-a}{b-a}&a\leq x<b\\
    &1&x>b
  \end{align*}
\end{matrix}
\right.
$$

### 指数分布

若连续型随机变量 $X$ 具有**概率密度**:

$$
f(x)=\left\{\begin{matrix}
\begin{align*}
  &\lambda e^{-\lambda x} &x>0\\
  &0 &x\leq0
\end{align*} &&\lambda>0
\end{matrix}\right.
$$

则称X 服从参数为 $\lambda$ 的指数分布，记作 $X\sim E(\lambda)$ ，期望 $E=\frac{1}{\lambda}$ ，方差 $D=\frac{1}{\lambda^2}$

- 指数分布常用来描述寿命，比如说持续无故障的工作时间，平均寿命就是参数 $\lambda$
- 指数分布的无记忆： $P(x>t+s|x>s)=P(x>t)$ ，已工作8小时再无故障工作10小时的概率=工作十小时无故障的概率

指数分布的**分布函数**:

$$
F(x)=\left\{\begin{matrix}
\begin{align*}
  &1-e^{-\lambda x} &x>0\\
  &0 &x\leq0
\end{align*} &&\lambda>0
\end{matrix}\right.
$$

### 正态分布

若连续型随机变量 $X$ 具有**概率密度**

$$
f(x)=\frac{1}{\sigma \sqrt{2\pi}}e^{-\frac{(x-\mu)^2}{2\sigma^2}} ,\sigma>0,-\infin<x<\infin.
$$
​
则称 $X$ 服从参数为 $\mu,\sigma$ 的正态分布，记作 $X\sim N(\mu,\sigma^2)$ ，期望 $E=\mu$ ，方差 $D=\sigma^2$  

$$
\int_{-\infin}^{\infin}\frac{1}{\sigma \sqrt{2\pi}}e^{-\frac{(x-\mu)^2}{2\sigma^2}}dx=1\\[10bp]
\text{换元}t=\frac{x-\mu}{\sigma}\\[10bp]
\int_{-\infin}^{\infin}\frac{1}{\sigma \sqrt{2\pi}}e^{-\frac{(x-\mu)^2}{2\sigma^2}}dx=\frac{1}{\sqrt{2\pi}}\int_{-\infin}^{\infin}e^{-\frac{t^2}{2}}dt\\[10bp]
\text{剩下证法参考微积分}
$$

正态分布的**密度函数曲线**性质：

- $x=\mu$ 是对称轴， $\mu$ 决定对称轴的位置，也被称为位置参数

- 当 $x=\mu$ 时， $f(x)_{max}=\frac{1}{\sigma \sqrt{2\pi}},\sigma$决定离散程度，$\sigma$ 越大，最大值越小，图形越矮胖。
- $x\to\pm\infin,f(x)\to 0$
- 两个拐点：$\mu\pm\sigma$

正态分布的**分布函数**:

$$
F(x)=\frac{1}{\sigma\sqrt{2\pi}}\int_{-\infin}^{x}e^{-\frac{(t-\mu)^2}{2\sigma^2}}dt
$$

正态分布的**分布函数曲线**性质:

- 由于密度函数关于$x=\mu$对称，故对称轴左右两边与x轴围成面积各0.5，故 $F(\mu)=1/2$
- $x\to\infin,F(x)\to1,x\to-\infin,f(x)\to0$
  
#### 标准正态分布

若连续性随机变量 $X\sim N(\mu=0,\sigma^2=1)$ ，则称 $X$ 服从标准正态分布。

标准正态分布的概率密度：$\phi(x)=\frac{1}{\sqrt{2\pi}}e^{-\frac{x^2}{2}}$，对称轴是 $x=0$，偶函数

标准正态分布的分布函数：$\Phi(x)=\frac{1}{\sqrt{2\pi}}\int_{-\infin}^{x}e^{-\frac{t^2}{2}}dt$，对称中心是$(0，0.5)$， $\Phi(x)+\Phi(-x)=1$

一般的正态分布 $N(\mu,\sigma^2)$ 与标准正态分布的**分布函数**之间满足如下关系：

$$
F(x)=\Phi(\frac{x-\mu}{\sigma})\\
X\sim N(\mu,\sigma^2)\Leftrightarrow\frac{X-\mu}{\sigma}\sim N(0,1)\\[10bp]
$$
一般正态分布的分布函数有如下变形
$$
P(x_1< X< x_2)=F(x_2)-F(x_1)=\int_{x_1}^{x_2}f(t)dt\\
=\Phi(\frac{x_1-\mu}{\sigma})-\Phi(\frac{x_2-\mu}{\sigma})
$$

推导：

$$
\begin{align*}
F(x)&=\frac{1}{\sigma\sqrt{2\pi}}\int_{-\infin}^{x}e^{-\frac{(t-\mu)^2}{2\sigma^2}}dt\\
\text{换元,令 }v&=\frac{t-\mu}{\sigma}\\
F(x)&=\frac{1}{\sqrt{2\pi}}\int_{-\infin}^{\frac{x-\mu}{\sigma}}e^{-\frac{v^2}{2}}dv\\

\Phi(x)&=\frac{1}{\sqrt{2\pi}}\int_{-\infin}^{x}e^{-\frac{t^2}{2}}dt\\
x&\to \frac{x-\mu}{\sigma}
\end{align*}\\
 $$

## 随机变量函数Y=g(X)的概率密度和分布函数

- 核心思想：**变量代换**

一个核心问题是，如何通过 $X$ 的概率密度 $f_X(x)$ 和分布函数 $F_X(X)$ ，来获得 $Y=g(X)$ 的概率密度 $f_Y(y)$ 和分布函数 $F_Y(y)$ 。

使用如下方法来获得 $Y$ 的概率分布。对于函数关系 $Y\{y_1,y_2,y_3...y_n\}=g(X_1,X_2,...,X_n)$

1. 通过 $Y=g(X_1,X_2,...,X_n)$ ，找到对应 $\{Y≤y\}$ 的 $(x_1,x_2,...,x_n)$ 区间 $I$。

2. 在区间 $I$ 上， $\int_I f(x_1,x_2,...,x_n)$ ，获得 $P(Y≤y)$ ，也就是  $F_Y(y)$
3. 通过微分 $F_Y(y)$，获得密度函数 $f_Y(y)$。

$$
F_Y(y)=P(Y\leq y)=P(g(X)\leq y)\\
\text{解出来$x$的范围（含$y$），假设是$y_1\leq x\leq y_2$}\\
\begin{align*}
  F_Y(y)&=F_X(y_2)-F_X(y_1)\\
  \text{或}
F_Y(y)&=\int_{y_1}^{y_2}f_X(x)\\
f_Y(y)&=F_Y^\prime(y)\\
\end{align*}
$$

对于连续型随机变量，直接公式法：

若 $y=g(x)$ 是严格**单调**的且**反函数 $h(y)$ 可导**时, 则随机变量 $Y$ 仍为连续型随机变量, 且有概率密度函数

$$
f_Y(y)=\left\{\begin{matrix}
  \begin{align*}
    &f_X(h(y))\cdot|h^\prime(y)|&&A <y<B\\
    &0 &&others
  \end{align*}
\end{matrix}\right.\\
\text{其中}A=\min\{g(a),g(b)\},B=\max\{g(a),g(b)\}
 $$

- 推论：正态变量的线性变换依然是正态变量，即 $Y=aX+b,X\sim N(\mu,\sigma^2)$，则 $Y\sim N(a\mu+b,a^2\sigma^2)$
