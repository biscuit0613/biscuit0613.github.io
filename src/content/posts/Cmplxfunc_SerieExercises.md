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

## 敛散性判别这一块：

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

(3):把$\frac{1}{z-b}$写成