---
title: 二维随机变量函数的分布
published: 2025-08-17
description: '二维随机变量函数的分布'
tags: [随机变量函数]
category: '概率论'
author: biscuit
draft: false
---

$Z=g(X,Y)$ ，其中 $(X,Y)$ 是二维随机变量，$Z$ 是一维随机变量，求 $Z$ 的分布。

回归定义，求分布函数：

$$
F_Z(z)=P(Z\leq z)=P(g(X,Y)\leq z)\\
=\iint\limits_{g(x,y)\leq z}f(x,y)dxdy\\
$$

难点：找积分区域和求积分。

## 离散型随机变量函数的分布

设离散型随机变量 $(X,Y)$ 的分布列为 $P(X=x_i,Y=y_j)=p_{ij}$,$Z=g(X,Y)$ 是一维离散型随机变量，用 $z_k=g(x_i,y_j)$ 表示 $Z$ 的取值，则Z的分布列：
$$
P(Z=z_k)=\sum_{g(X,Y)=z_k}P(X=x_i,Y=y_j)\\
=\sum_{g(x_i,y_j)=z_k}P(X=x_i)\cdot P(Y=y_j)\;\;\text{XY独立} \\
$$

eg:$(X,Y)$ 分布列

|X\Y|0|1|2|
|---|---|---|---|
|-1|0.1|0.15|0.2|
|1|0.15|0.1|0.3|

$Z=2X+Y Z=-2,-1,0,2,3,4$

|Z| -2| -1|0|2|3|4|
|---|---|---|---|---|---|---|
|P|0.1|0.12|0.2|0.15|0.1|0.3|

### 同分布独立的可加性

再生性：同类型的随机变量，在独立的情况下，其联合分布依然是该类型，并且参数为各自参数之和  

以泊松分布为例：
$X\sim P(\lambda_1),Y\sim P(\lambda_2),Z=X+Y$

$$
\begin{aligned}
P(X=i)&=\frac{\lambda_1^i}{i!}e^{-\lambda_1},P(Y=j)=\frac{\lambda_2^j}{j!}e^{-\lambda_2}\\
Z&=0,1,2,3...\\
P(Z=k)&=P(X+Y=k)\\
&=P(\underset{i=0}{\cup}(X=i,Y=k-i))\\
&=\sum_{i=0}^k P(X=i,Y=k-i)\\
&=\sum_{i=0}^kP(X=i)P(Y=k-i)\\
&=\frac{\lambda_1^i}{i!}e^{-\lambda_1}\cdot\frac{\lambda_2^{k-i}}{(k-i)!}e^{-\lambda_2}\\[5bp]
&=\frac{(\lambda_1+\lambda_2)^k}{k!}e^{-(\lambda_1+\lambda_2)}\sim P(\lambda_1+\lambda_2)\\
\end{aligned}
$$

## 连续型随机变量函数的分布

### 特例：$Z=X+Y$

$$
\begin{aligned}
F_Z(z)&=P(Z\leq z)=P(X+Y\leq z)\\
&=\iint\limits_{x+y\leq z}f(x,y)dxdy\\
&=\int_{-\infin}^{+\infin}\int_{-\infin}^{z-x}f(x,y)dydx\\
\end{aligned}
$$
换元，令 $y=u-x$，

$$
F_Z(z)=\int_{-\infin}^{+\infin}\int_{-\infin}^{z}f(x,u-x)dudx\\
$$

交换积分次序

$$
F_Z(z)=\int_{-\infin}^{z}\underbrace{\int_{-\infin}^{+\infin}f(x,u-x)dx}_{=f_U(u)}d u\\[8bp]
f_Z(z)=F_Z^\prime(z)=\int_{-\infin}^{+\infin}f(x,z-x)dx
$$

就得到了 $Z=X+Y$ 的概率密度函数。

$$
\boxed{f_Z(z)=\int_{-\infin}^{+\infin}f(x,z-x)dx=\int_{-\infin}^{+\infin}f(z-y,y)dy}
$$

### 卷积公式

更特殊地，如过 $X,Y$ 独立，则
$$
\boxed{f_Z(z)=\int_{-\infin}^{+\infin}f_X(x)f_Y(z-x)dx=\int_{-\infin}^{+\infin}f_X(z-y)f_Y(y)dy}
$$

:::warning
无论是哪种形式，都需要实际考虑积分区间。
:::

:::tip  
对x积分则$f_X$不变，$x$ 保留支撑集，$y=z-x$ 在 $y$ 支撑集，反解出x的积分区间；

对y积分则$f_Y$不变，$y$ 保留支撑集，$x=z-y$ 在 $x$ 支撑集 ，反解出y的积分区间。
:::

### 一般情况

$$
\begin{aligned}
F_Z(z)&=P(Z\leq z)=P(X+Y\leq z)\\
&=\iint\limits_{x+y\leq z}f(x,y)dxdy\\
&=\int_{-\infin}^{+\infin}\int_{-\infin}^{z-x}f(x,y)dydx\\
\end{aligned}
$$

到这一步，老老实实分析积分区间做二重积分。
