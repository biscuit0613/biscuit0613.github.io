---
title: 复变函数：积分练习题
published: 2025-09-15
description: ''
image: ''
tags: [复变函数, 积分练习题]
category: '复变函数'
draft: false 
lang: ''
---

eg1: 计算 $\int_C f(z)dz$,，其中C是复平面内从原点到 $(3,4)$的直线段

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

eg3: 计算 $\oint\frac{1}{2z-3}dz,|z|=1$

:::tip[solution]
奇点是 $(\frac{3}{2},0)$ 不在解析区域内，由柯西古撒定理，原积分是0
:::

eg4: 计算 $\int_{z+i}^{2+4i}z^2dz$

:::tip[solution]
幂函数是整个复平面上的解析函数，因此积分与路径无关
:::

eg5: 计算 $\int_{1-\pi i}^{1+\pi i}e^{\frac{z}{2}}dz$

:::tip[solution]
指数函数也是全纯函数，积分与路径无关
:::

## 利用柯西积分公式

$$
\oint_C \frac{f(z)}{z-z_0}dz=f(z_0)2\pi i
$$

eg1: 计算 $\oint_C\frac{1}{z^2-z}dz$ ，这里C是包含 $|z|=1$ 在内的正向封闭曲线

:::tip[solution]
被积函数有两个奇点 $z=0,1$，均在C内，取 $C_1=|z-0|=\delta_1,C_2=|z-1|=\delta_2$,由复合闭路定理和柯西积分公式：
$$
\oint_C\frac{1}{z^2-z}dz=\oint_C(\frac{1}{z-1}-\frac{1}{z})dz\\
\text{分别考察$C_1,C_2$}\\
=0-2\pi i+2\pi i-0=0
$$
:::

eg2 :$\oint_C\frac{sin(z\frac{\pi}{4})}{z^2-1}dz$ 其中C是包含 $|z+1|=\frac{1}{2},|z-1|=\frac{1}{2},|z|=2$

![eg1](cauchy_eg7.svg)

:::tip[solution]
被积函数有两个奇点 $z=\pm1$，均在C内，因此
$$
\oint_C\frac{sin(z\frac{\pi}{4})}{z^2-1}dz=\oint_{C_1}\frac{sin(z\frac{\pi}{4})}{z-1}dz-\oint_{C_2}\frac{sin(z\frac{\pi}{4})}{z+1}dz
$$
其中 $C_1:|z-1|=\frac{1}{2},C_2:|z+1|=\frac{1}{2}$
$$
=2\pi i(sin(\frac{\pi}{4})-sin(-\frac{\pi}{4}))=2\pi i\sqrt{2}
$$
:::

:::note
柯西积分公式的精髓在于找到奇点，然后拆分成多个柯西积分公式的形式。每个奇点贡献一个积分，最后把它们加起来。
:::

## 利用高阶导数公式（柯西积分的高阶形式）

$$
\frac{2\pi i}{n!} \cdot f^{(n)}(a) = \oint_{\Gamma} \frac{f(z)}{(z-a)^{n+1}} \, dz, \quad n = 0,1,2,\dots
$$

eg1: $\oint_C\frac{cos(\pi z)}{(z-1)^5}dz$ 其中C$|z|>1$

:::tip[solution]
利用高阶导数公式
$$
\oint_C\frac{cos(\pi z)}{(z-1)^5}dz=2\pi i\frac{1}{4!}(-\pi)^4=\frac{\pi^4}{48}
$$
:::

eg2： $\oint_C\frac{e^z}{(z^2+1)^2}dz$ 其中C $|z|>1$

:::tip[solution]
把分母拆成 $(z-i)^2(z+i)^2$,根据不同的奇点选择不同的 $f(z)$ ，然后用高阶导数公式，再把结果加起来。
$$
\oint_C\frac{e^z}{(z^2+1)^2}dz=\oint_C\frac{e^z}{(z-i)^2(z+i)^2}dz\\[5pt]
\text{取 $f_1(z)=\frac{e^z}{(z+i)^2}$，奇点 $z=i$}\\
f_1^\prime(z)=\frac{e^z}{(z+i)^2}-\frac{2e^z}{(z+i)^3}\\
\oint_C\frac{f_1(z)}{(z-i)^2}dz=2\pi i\frac{1}{1!}f_1^\prime(z=i)=2\pi i\frac{-e^i(1+i)}{4}=\frac{\pi e^i(1-i)}{2}\\[5pt]
\text{取 $f_2(z)=\frac{e^z}{(z-i)^2}$，奇点 $z=-i$}\\
f_2^\prime(z)=\frac{e^z}{(z-i)^2}-\frac{2e^z}{(z-i)^3}\\
\oint_C\frac{f_2(z)}{(z+i)^2}dz=2\pi i\frac{1}{1!}f_2^\prime(z=-i)=\frac{\pi e^{-i}(1+i)}{2}\\[5pt]
\oint_C\frac{e^z}{(z^2+1)^2}dz=\frac{\pi}{2}(e^i+e^{-i})+\frac{\pi i}{2}(e^{-i}-e^i)=\pi \cos 1-i\pi \sin 1
$$
:::

eg3: $\oint_C\frac{z^3+1}{(z+1)^4}$

:::tip[solution]
被积函数在 $z=-1$ 处有三阶极点，取 $f(z)=z^3+1$，则
$$
f^{(3)}(z)=6\\
\oint_C\frac{z^3+1}{(z+1)^4}dz=2\pi i\frac{1}{3!}f^{(3)}(-1)=2\pi i \;\text{奇点在积分路径内}  
$$
:::
