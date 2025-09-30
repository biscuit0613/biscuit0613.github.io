---
title: 复变级数练习题
published: 2025-09-22
description: ''
image: ''
tags: [复变函数，复级数]
category: '复变函数'
draft: false 
lang: ''
---

## 敛散性判别这一块

eg1:$\sum_{n=1}^\infin \frac{1}{n}(1+\frac{i}{n}$(发)

:::tip[solution]
实部级数是$\frac{1}{n}$发散，原级数发散
:::

eg2:$\sum_{n=1}^\infin\frac{(8i)^n}{n!}$(绝对收敛)

:::tip[solution]
考察级数$\sum_{n=1}^\infin\frac{(8)^n}{n!}$,用比值判别法
$$
\lim_{n\to\infin}\frac{\frac{(8)^(n+1)}{(n+1)!}}{\frac{(8)^n}{n!}}\\
=\lim_{n\to\infin}\frac{8}{n+1}=0
$$
:::

## 求收敛半径

eg1:$\sum_{n=1}^\infin \frac{z^n}{n^3}$

:::tip[solution]
$$
\rho=\lim_{n\to\infin}\frac{\frac{z^(n+1)}{(n+1)^3}}{\frac{z^n}{n^3}}=|z|\\
|z|<1\iff r=1
$$
:::

eg2:$\sum_{n=1}^\infin n!\cdot z^n$

:::tip[solution]
$$
\rho=\lim_{n\to\infin}\frac{(n+1)!z^(n+1)}{n!z^n}=\lim_{n\to\infin}(n+1)|z|<1\\
r=0
$$
:::

eg3:求和函数：$\sum_{n=1}^\infin z^n$

:::tip[solution]
$$
S_n(z)=\frac{1-z^n}{1-z}\\
\rho=\lim_{n\to\infin}\frac{|z^{n+1}|}{z^n}=\lim_{n\to\infin}|z|<1\\
r=1\\
\text{当｜z｜=1时，原级数一般项不趋近于0，发散}\\
\therefore S_n(z)=\frac{1-z^n}{1-z},\;|z|<1
$$
:::

eg4:求收敛半径并讨论收敛圆周上的敛散性
(1):$\sum_{n=1}^\infin(\ch \frac{i}{n})(z-1)^n$
:::tip[solution]
$$
\ch \frac{i}{n}=e^\frac{i}{n}+\frac{e^\frac{-i}{n}}{2}=\cos \frac{i}{n}\\
\rho=\lim_{n\to\infin}\frac{|\cos \frac{i}{n+1}(z-1)^{n+1}|}{|\cos \frac{i}{n}(z-1)^{n}|}\\
=|z-1|<1\\
r=1\\
\text{当z=1时，原级数一般项不趋近于0，发散}
$$
:::

(2):$\sum_{n=1}^\infin(\frac{z}{\ln in})^n$
根值判别法

(3):把$\frac{1}{z-b}$写成$\sum_{n=0}^\infty c_n(z-a)^n$的形式
:::tip[solution]

$$
\frac{1}{z-b}=\frac{1}{(z-a)+(a-b)}=\frac{1}{a-b}\cdot\frac{1}{1+\frac{z-a}{a-b}}\\
=\frac{1}{a-b}\sum_{n= 0}^\infty (-1)^n(\frac{z-a}{a-b})^n\\
=\sum_{n=0}^\infty \frac{(-1)^n}{(a-b)^{n+1}}(z-a)^n
$$
:::

(4):求$\sum_{n=0}^\infty (n+1)z^n$的和函数

:::tip[solution]
$$
S_n(z)=\sum_{n=0}^\infty (n+1)z^n=\sum_{n=0}^\infty \frac{d}{dz}z^{n+1}=\frac{d}{dz}\sum_{n=0}^\infty z^{n+1}=\frac{d}{dz}\frac{z}{1-z}=\frac{1}{(1-z)^2}
$$
:::

## 泰勒级数的应用

eg1: 设函数 $f(z)$ 在 $|z|<1$ 范围内解析，且 $g(z)=f(z^2)$ ,求 $g^{(2019)}(0)$

:::tip[solution]
$f(z)$ 解析，说明可以在 $z=0$ 处展开成泰勒级数：
$$
f(z)=\sum_{n=0}^\infty a_nz^n\\
g(z)=f(z^2)=\sum_{n=0}^\infty a_nz^{2n}\\
\text{可以看出，g(z)的泰勒展开式中只有偶数次幂项，说明奇数次幂的泰勒展开项系数是0}\\[5pt]
\therefore g^{(2019)}(0)=0
$$
:::

eg2:
