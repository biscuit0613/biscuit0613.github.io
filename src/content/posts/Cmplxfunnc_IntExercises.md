---
title: 复变函数积分练习题
published: 2025-09-15
description: ''
image: ''
tags: []
category: ''
draft: false 
lang: ''
---

eg1: 计算$\int_C f(z)dz$,，其中C是复平面内从原点到$(3,4)$的直线段

:::tip[solution]
做参数化：$z=(3+4i)t\,,t:0\to1$
$$
\int_Cf(z)dz=\int_0^1(3+4i)(3+4i)dt
$$
:::

eg2: 计算 $\oint_{|z-z_0|\leq r} \frac{1}{(z-z_0)^n},n\in\mathbb{Z}$

:::tip[solution]

采用参数化
$$
\begin{align*}
&z-z_0=re^{i\theta},\theta\in(0,2\pi]\\
&\int_0^{2\pi}\frac{1}{(re^{i\theta})^n}re^{i\theta}id\theta\\[5bp]
&=ir^{1-n}\int_0^{2\pi}(e^{i\theta})^{1-n}d\theta\\
&=\begin{cases}
    0, &n\neq1\\
    2\pi i, &n=1
\end{cases}
\end{align*}
$$

:::

eg3: 计算$\oint\frac{1}{2z-3}dz,|z|=1$

:::tip[solution]
奇点是$(\frac{3}{2},0)$不在解析区域内，原积分是0
:::

eg4: 计算$\int_{z+i}^{2+4i}z^2dz$

:::tip[solution]
幂函数是整个复平面上的解析函数，因此积分与路径无关
:::

eg5: 计算$\int_{1-\pi i}^{1+\pi i}e^{\frac{z}{2}}dz$

:::tip[solution]
指数函数也是全纯函数，积分与路径无关
:::

eg6: 计算$\oint_C\frac{1}{z^2-z}dz$,，这里C是包含$|z|=1$在内的正向封闭曲线

:::tip[solution]
取$C_1=|z-0|=\delta_1,C_2=|z-1|=\delta_2$,由复合闭路定理：
$$
\oint_C\frac{1}{z^2-z}dz=\oint_C(\frac{1}{z-1}-\frac{1}{z})dz\\
\text{分别考察$C_1,C_2$}\\
=0-2\pi i+2\pi i-0=0
$$
:::


利用柯西积分公式:

$$
\oint_C \frac{f(z)}{z-z_0}dz=f(z_0)2\pi i
$$

eg7 :$\oint_C\frac{sin(z\frac{\pi}{4})}{z^2-1}dz$ 其中C是包含$|z+1|=\frac{1}{2},|z-1|=\frac{1}{2},|z|=2$

::: tip[solution]

:::

:::note
无论是柯西积分公式还是高阶导数公式，遇到需要变形的情况，不要破坏分式原有的乘积结构，灵活选择包含奇点的式子与$f(z)$
:::

利用高阶导数公式:

$$
f^{(n)}(a) = \frac{n!}{2\pi i} \oint_{\Gamma} \frac{f(z)}{(z-a)^{n+1}} \, dz, \quad n = 0,1,2,\dots
$$

eg8: $\oint_C\frac{cos(\pi z)}{(z-1)^5}dz$ 其中C$|z|>1$

:::tip[solution]

:::

eg9： $\oint_C\frac{e^z}{(z^2+1)^2}dz$ 其中C$|z|$>1

:::tip[solution]

:::

eg10: $\oint_C\frac{z^3+1}{(z+1)^4}$

:::tip[solution]

:::
