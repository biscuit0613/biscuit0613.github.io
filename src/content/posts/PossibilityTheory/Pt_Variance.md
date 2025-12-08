---
title: 概率论：方差（速通版）
published: 2025-09-01
description: '为了RM的卡尔曼滤波先学方差'
image: ''
tags: [概率论，RM]
category: '概率论'
draft: false 
lang: ''
---

## 一维随机变量的方差

### 一维随机变量的方差定义

设 $X$ 是一个随机变量，若 $E[(X-E(X))]^2$ 存在，则称 $E[(X-E(X))]^2$ 为随机变量 $X$ 的方差，记作 $D(X)$
$$
D(X)=E[(X-E(X))]^2
$$
称 $\sqrt{D}$ 为 $X$ 的标准差或者均差，记作 $\sigma$

从另一个角度理解，方差就是随机变量函数 $g(X)=[(X-E(X))]^2$ 的均值

### 一维随机变量方差的计算

**离散型**随机变量的方差：
$$
D(X)=\sum_{i=1}^\infin[x_i-E(X)]\cdot p_i
$$

**连续型**随机变量的方差
$$
D(X)=\int_{-\infin}^{+\infin}[x-E(X)]f(x)dx
$$

常用公式：$D(X)=E(X^2)-E^2(X)$

重要推论： $E(X^2)=D(X)+E^2(X)$

:::note[推导]
$$
\begin{align*}
    D(X)&=E[(X-E(X))]^2\\
    &=E[X^2-2XE(X)+E^2(X)]\\
    &=E[X^2-2E^2(X)+E^2(X)]
\end{align*}
$$
:::

### 方差的性质

1. **非负性**  
   $\mathrm{Var}(X) \geq 0$，且仅当 $X$ 为常数时 $\mathrm{Var}(X)=0$。  

2. **平移不变性**  
   $\mathrm{Var}(X+c) = \mathrm{Var}(X)$。  

3. **比例缩放**  
   $\mathrm{Var}(aX) = a^2 \mathrm{Var}(X)$。  

4. **和的方差(注意正负号)**  
   - 若 $X,Y$ 独立：
     $$
     \mathrm{Var}(X\pm Y) = \mathrm{Var}(X) + \mathrm{Var}(Y)
     $$
   - 若不独立：
     $$
     \mathrm{Var}(X\pm Y) = \mathrm{Var}(X) + \mathrm{Var}(Y) \pm 2\mathrm{Cov}(X,Y)
     $$
