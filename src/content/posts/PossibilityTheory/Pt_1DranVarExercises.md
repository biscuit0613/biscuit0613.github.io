---
title: 一维随机变量及其分布练习题
published: 2025-10-09
description: '一维随机变量及其分布练习题'
image: ''
tags: [随机变量,习题]
category: '概率论与数理统计'
draft: false 
lang: ''
---

>eg1：机器在时间t内出故障的次数N(t)，$N(t)\sim P(\lambda t)$，求
>
>（1）：相邻两次故障之间的时间间隔T的分布  
>（2）：已经无故障工作8小时的条件下，继续无故障工工作8小时的概率

(1)

$$
\begin{aligned}
F_T(t)&=P(T\leq t)=1-P(T\geq t)\\
&=1-P(N(t)=0)\\
&=1-\frac{(\lambda t)^0}{0!}\cdot e^{-\lambda t}\\
&=1-e^{-\lambda t}\;\;t>0\\
F_T(t)&=\begin{cases}
    1-e^{-\lambda t}\;\;t>0\\
    0\;\;t\leq 0
\end{cases}\\
&T\sim E(\lambda)\text{服从指数分布}
\end{aligned}

$$

(2)：利用指数分布的无记忆性

$$
P(T>16|T>8)=P(T>8)＝1-P(T\leq 8)=e{-8\lambda}
$$

>eg2：$|X|\leq 1,P(X=-1)=\frac{1}{8},P(X=1)=\frac{1}{4},P(a<X<b|-1<X<1)$ 与 $(b-a)$ 成正比，$(a,b)\in(-1,1)$.求 $F_X(x)$

:::tip
这个随机变量既有连续的部分(-1,1),也有离散的部分 $x=\pm 1$,

对于连续的部分，概率和区间长度成正比，说明在(-1,1)区间上服从均匀分布，取端点作为区间长度，算出来连续区间的概率密度k。注意这里需用条件概率，因为有随机变量的取值里面既有离散也有连续。
:::

连续区间内的概率密度为
$$
\begin{aligned}
&P(-1<X<1| -1<X<1)=1=2k\iff k=\frac{1}{2}\\
&F_X(x)=P(X\leq x)\\
\end{aligned}
$$

当 $x< -1$ 时 $F_X(x)=0$

当 $－1\leq x<1$ 时，-1处是离散点

$$
\begin{aligned}
&F_X(x) =P(X=-1)+P(-1<X\leq x)\\
&=\frac{1}{8}+P(-1<X\leq x|-1<x<1)\cdot P(-1<X<1)\\
&=\frac{1}{8}+\frac{1}{2}\cdot(x+1)\cdot\frac{5}{8}\\
&=\frac{5x+7}{16}\\
\end{aligned}
$$

当 $x \geq 1$ 时  $F_X(x)=1$
