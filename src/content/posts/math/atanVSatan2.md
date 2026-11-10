---
title: atan 与 atan2 的比较
published: 2025-10-23
description: ''
image: ''
tags: []
category: '复变函数'
draft: false 
lang: ''
---

## atan2

atan2 和复数计算幅角的公式本质上没有区别

$$
atan(y,x)=arg(x+yi)
=\begin{cases}
    arctan(\frac{y}{x}) & x>0 \text{点在一四象限} \\
    arctan(\frac{y}{x})+\pi & x<0,y\ge0\text{点在x轴和以上的} \\
    arctan(\frac{y}{x})-\pi & x<0,y<0 \\
    \frac{\pi}{2} & x=0,y>0 \\
    -\frac{\pi}{2} & x=0,y<0 \\
    \text{undefined} & x=0,y=0
\end{cases}
$$

atan2 的优点在于它能区分象限，从而避免了除零错误。