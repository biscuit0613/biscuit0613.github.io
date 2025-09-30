---
title: 复变函数：导数可微解析的例题
published: 2025-09-08
description: '可导、可微与解析的例题'
image: ''
tags: [复变函数]
category: '复变函数'
draft: false 
lang: ''
---

## 柯西黎曼条件的应用

### eg:求参数使得函数解析

若 $f(z)=x^2+axy+by^2+i(cx^2+dxy+y^2)$ 在整个复平面内都可导，求参数abcd

:::tip[solution]

由复变函数可导的充要条件：实部虚部函数可微且满足柯西黎曼条件： $\frac{\partial u}{\partial x}=\frac{\partial v}{\partial y}$,  $\frac{\partial u}{\partial y}=-\frac{\partial v}{\partial x}$

其中$u=x^2+axy+by^2,v=cx^2+dxy+y^2$，计算偏导数：

$$
\begin{align*}
\frac{\partial u}{\partial x}&=2x+ay;&
\frac{\partial u}{\partial y}&=ax+2by\\[10bp]
\frac{\partial v}{\partial x}&=2cx+dy;&
\frac{\partial v}{\partial y}&=dx+2y
\end{align*}
$$

代入柯西黎曼条件：

$$
\left\{\begin{matrix}
\begin{align*}
2x+ay&=dx+2y\\[10bp]
ax+2by&=-(2cx+dy)
\end{align*}
\end{matrix}\right.
$$

化简得：

$$
a=2c=2;
d=2;
b=-1;
$$

:::

### eg:求共轭调和函数

若 $u=x^2+xy-y^2,f(i)=-1+i,f(z)$ 解析，求 $f(z)=u+iv$

:::note[hint]

考虑用多种方法做，法一是直接用算u的共轭调和函数，法二是通过表示f的导数（用实部虚部函数偏导的四种形式），然后再积分，法三（并不算一个单独的方法，凑微分这一块）。

:::

:::tip[solution]

其中$u=x^2+xy-y^2$，直接套公式偏积分：
$$
\begin{align*}
    v(x,y)&=\int_{0，0}^{x,y}{-\frac{\partial u}{\partial y}dx+\frac{\partial u}{\partial x}dy}\\
    &=\int_{0}^{x}{-\frac{\partial u}{\partial y}dx}+\int_{0}^{y}{\frac{\partial u}{\partial x}dy}\\
    &=\int_{0}^{x}{-(x-2y)dx}+\int_{0}^{y}{(2x+y)dy}\\
    &=-\frac{1}{2}x^2+xy+y^2+C
\end{align*}
$$
由$f(i)=-1+i$，得初值条件$v(0,1)=1$，$C=0$，所以
$$
f(z)=x^2+xy-y^2+i(-\frac{1}{2}x^2+xy+y^2)
$$

:::

### eg：典型的根据定义判定解析

 e.g.分析 $f(z)=\overline{z}\cdot z^2$ 这个函数在z=0处的解析性

:::tip[solution]
$$
\begin{align*}

&f(z)=(x^2+y^2)(x+iy)\\
&\text{在$z=0$处的可导性}\\[5bp]
&\lim_{z\to 0}{\frac{(x^2+y^2)(x+iy)-0}{(x+iy)-0}}=0\\[5bp]
&\text{在$z\neq 0$处，z的邻域里的可导性}\\[5bp]
&\lim_{\Delta z\to 0}{\frac{[(x+\Delta x)^2+(y+\Delta y)^2](x+\Delta x+i(y+\Delta y))-(x^2+y^2)(x+iy)}{\Delta z}}\\[5bp]
&=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{(\Delta x^2+\Delta y^2+2x\Delta x+2y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+\Delta x^2 +2x\Delta x+y^2+\Delta y^2 +2y\Delta y}\\[5bp]
&=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{(\Delta x^2+\Delta y^2)(x+iy)}{\Delta x+i\Delta y}+\frac{2(x\Delta x+y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+ y^2 }\text{第一坨高阶无穷小在上为0}\\[5bp]
&=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{2(x\Delta x+y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+ y^2 }\\[5bp]
&=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{2(2xy\Delta x\Delta y+x^2\Delta x^2+y^2\Delta y^2-i(\Delta x\Delta y(x^2-y^2)+xy(\Delta y^2-\Delta x^2)))}{\Delta x^2-\Delta y^2}+x^2+ y^2 }\text{肉眼可见和xy有关}
\end{align*}
$$
在z=0邻域内不可导，也就不解析

:::

### 下列函数在何处可导，何处解析？

(1) $f(z)=x^2-iy$

:::note[hint]
考虑用偏导+柯西黎曼条件判定
:::

:::tip[solution]
$$
\begin{align*}
&\frac{\partial u}{\partial x}=2x,\frac{\partial u}{\partial y}=0\\[10bp]
&\frac{\partial v}{\partial x}=0,\frac{\partial v}{\partial y}=-1,\text{显然一阶偏导连续}\\
&\text{当满足柯西黎曼条件时：}x=-\frac{1}{2},\forall y\\
\end{align*}
$$
:::

(2) $f(z)=xy^2+i x^2y$

:::tip[solution]
$$
\begin{align*}
&\frac{\partial u}{\partial x}=y^2,\frac{\partial u}{\partial y}=2xy\\[10bp]
&\frac{\partial v}{\partial x}=2xy,\frac{\partial v}{\partial y}=x^2\text{显然一阶偏导连续}\\
&\text{当满足柯西黎曼条件时：}y=x=0\\
\end{align*}
$$

(3) $f(z)=\frac{x+y}{x^2+y^2}+i\frac{x-y}{x^2+y^2}$

:::tip[solution]

$$
\begin{align*}
&\frac{\partial u}{\partial x}=\frac{y^2-x^2-2xy}{(x^2+y^2)^2},\frac{\partial u}{\partial y}=\frac{x^2-y^2-2xy}{(x^2+y^2)^2}\\[10bp]
&\frac{\partial v}{\partial x}=\frac{y^2-x^2+2xy}{(x^2+y^2)^2},\frac{\partial v}{\partial y}=\frac{y^2-x^2-2xy}{(x^2+y^2)^2}\text{显然一阶偏导连续}\\
&\text{当满足柯西黎曼条件时：}x\neq 0,y\neq 0\\
\end{align*}
$$
所以在复平面上除原点外处处解析
:::

(4) $f(z)=\Im z=y$

:::tip[solution]
$$
\begin{align*}
&\frac{\partial u}{\partial x}=0,\frac{\partial u}{\partial y}=1\\[10bp]
&\frac{\partial v}{\partial x}=0,\frac{\partial v}{\partial y}=0\text{显然一阶偏导连续}\\
&\text{当满足柯西黎曼条件时：}无解\\
\end{align*}
$$
所以在复平面上处处不可导
:::

