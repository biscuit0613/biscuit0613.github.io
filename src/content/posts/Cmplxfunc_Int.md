---
title: 复变函数积分
published: 2025-08-20
description: 复变函数积分
tags: [复变函数]
category: 复变函数
author: biscuit
draft: false
---

-[复变函数积分的定义](#复平面积分的定义)
-[积分存在性及其求法](#积分存在性及其求法)
   -[直接法：转化为第二型曲面积分/二重积分](#1-直接法第二型曲线积分二重积分)
   -[参数化：转化为定积分](#2-参数化定积分)
-[柯西古萨定理](#柯西古撒定理)
   -[背景](#背景)
   -[定理内容](#柯西古撒定理内容)
      -[推论1：区域内推广到边界](#推论1区域内曲线推广到边界上)
      -[推论2:复合闭路定理](#推论2复合闭路定理有洞的柯西古撒定理)
      -[推论3：柯西积分公式](#推论3柯西积分公式)
      -[推论4：积分与路径无关＆＆原函数存在定理](#推论4解析函数积分与路径无关和原函数存在定理)

# 复变函数积分

类比于实函数积分，复变函数积分与第二型曲线积分类似

## 复平面积分的定义

设函数$\omega=f(z)$定义在区域$D$内，C是D内以A为起点，B为终点的任意**光滑有向**曲线，在曲线C上插入一系列点：
$$
z_1,z_2,z_3,z_4,z_5...z_{n-1}
$$
这些点把C分成n个小弧段$\overset{\frown}{z_{k-1}z_k}$，记$\Delta z_k=z_k-z_{k-1}$，在每小段弧上任取一点$\zeta_k(\xi_k,\eta_k)=\xi_k+i\eta_k$，作和式：
$$
S_n=\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k
$$
记$\delta=\max\{\overset{\frown}{z_{k-1}z_k}\text{的弧长}\}$，若不论对C的分法以及$\zeta_k(\xi_k,\eta_k)$的取法，极限
$$
\lim_{\delta\to 0}\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k
$$
总是存在且唯一，则称此极限值为f（z）沿着有向曲线C的积分，记作
$$
\int_C f(z)dz
$$

## 积分存在性及其求法

### 1. 直接法$\to$第二型曲线积分/二重积分

如果$f(z)=u(x,y)+iv(x,y)$在有向光滑曲线C上**连续**，那么$f(z)$沿C的积分存在，并且
$$
\int_Cf(z)dz=\int_C{udx-vdy}+i\int_C{vdx+udy}
$$
证明：(用定义)
>$$
>   \begin{align*}
>   z_k&=x_k+iy_k,x_k-x_{k-1}=\Delta x_k,y_k-y_{k-1}=\Delta y_k\\
   >\zeta_k&=\xi_k+i\eta_k,u_k=u(\xi_k,\eta_k),v_k=v(\xi_k,\eta_k)\\
   >S_n&=\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k\\
   >&=\sum_{k=1}^{k=n}(u_k+iv_k)(\Delta x_k+i\Delta y_k)\\
   >&=\sum_{k=1}^{k=n}[u_k\Delta x_k-v_k\Delta y_k+i(v_k\Delta x_k+u_k\Delta y_k)]\\
   >&=\sum_{k=1}^{k=n}u_k\Delta x_k-v_k\Delta y_k+\sum_{k=1}^{k=n}i(v_k\Delta x_k+u_k\Delta y_k)\\
   >&\text{f(z)沿曲线C连续，由复变函数连续的充要条件是实部虚部函数连续，}\\
   >&\text{}{故u(x,y),v(x,y)在曲线C上也连续}\\
   >&\text{再由可积定义，函数连续必可积，u,v对应的两个第二型曲线积分一定存在。}\\
   >&=\int_C{udx-vdy}+i\int_C{vdx+udy}
   >\end{align*}
>$$

+ 说明了一个复变函数沿某曲线可积，那么它的积分能表示成两个第二型曲线积分的运算组合
+ 曲线C上连续不代表曲线C上处处连续，曲线C上连续只是说C上的点沿C的方向是连续的，而处处连续要考虑曲线外的方向

### 2.参数化$\to$定积分

如果C是有向的简单光滑曲线，$z=z(t)=x(t)+iy(t),t\in[t_0,T]$，且$t_0,T$分别对应曲线的起点和终点，如果$f(z)$在曲线$C$上**连续**，那么

$$
\int_Cf(z)dz=\int_{t_0}^Tf(z(t))z(t)^\prime dt\\
=\int_a^b [u(x(t),y(t))+iv(X(t)+y(t))][x^\prime(t)+iy^\prime(t)]dt
$$
证明：
>$$
>\begin{align*}
>dz&=(x^\prime(t)+iy^\prime(t))dt\\
>\int_Cf(z)dz&=\int_C[u(x(t),y(t))+iv(x(t),y(t))]\cdot(x^\prime(t)+iy^\prime(t))dt\\
>&\text{令}u(t)=u(x(t),y(t)),v(t)=v(x(t),y(t))\\
>&=\int_C[u(t)x^\prime(t)-v(t)y^\prime(t)]dt+i\int_C[v(t)x^\prime(t)+u(t)y^\prime(t)]dt
>\end{align*}
>$$

### 复变函数积分的性质

1. 有向性：$\int_C f(z)dz=-\int_{C^-} f(z)dz$
2. $\int(kf(z)+lg(z))dz=k\int f(z)dz+l\int g(z)dz$
3. 分段可加性：如果$C=C_1+C_2+\ddots+C_n$
4. 模有界性：$|\int f(z)dz|\leq\int|f(z)|ds\leq ML$，这里$|f(z)\leq M,\forall z\in \mathbb{C}|$，积分路径的长度为 $L$

简要证明一下：

$$
|\int f(z)dz|\\
=|\lim_{\delta\to 0}\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k|\\
=\lim_{\delta\to 0}|\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k|\\
\text{这里用一步放缩}
$$

# 柯西古撒定理

## 背景

1. >复习积分与路径无关的四个等价条件

2. >如果$f(z)=u(x,y)+iv(x,y)$在有向光滑曲线C上**连续**，那么$f(z)$沿C的积分存在，并且
   >$$
      >\int_Cf(z)dz=\int_C{udx-vdy}+i\int_C{vdx+udy}
   >$$

## 柯西古撒定理内容

### 基本形式（回路在解析区域内，不含边界）

**柯西古撒定理**：对于单连通区域$D,C$为$D$中任意一条**简单闭曲线**(不自交，端点相等，连续)，如果$f(z)$在$D$内**解析**，那么
$$
      \oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0
$$

:::tip[]
推导：

这两个第二型曲线积分如果满足**积分与路径无关**则有
$$
-\frac{\partial v}{\partial x}=\frac{\partial u}{\partial y},  \frac{\partial u}{\partial x}=\frac{\partial v}{\partial y}\tag{\#}
$$
这一坨式子很熟悉，是**柯西-黎曼条件**，即f(z)在某点处可微的必要条件之一。只要加上u，v一阶偏导数连续（即u，v在某点可微）这个补充条件，就成了充要条件。

回顾**格林公式**：
$\oint Pdx+Qdy=\iint_D(\frac{\partial Q}{\partial x}-\frac{\partial P}{\partial y})dxdy$当这玩意等于0时，显然满足#条件，此时$\oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0$。

但是这样还不够，课本上给的前提是f在D 上解析，不是可微，为什么会给出一个更严格的条件呢？这是因为u，v在D内处处可微且处处满足柯西黎曼条件，这恰好是f在区域D解析的充要条件

:::

### 推论1：区域内曲线推广到边界上

1. **闭区域内的柯西古撒定理**：如果**简单闭曲线**$C$为单连通区域$D$的边界，函数$f(z)$在**闭区域**$\overline{D}=D+C$上**解析**，那么

   $$
      \oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0
   $$

2. **边界连续内部解析的柯西古撒定理**：如果**简单闭曲线**$C$为单连通区域$D$的边界，函数$f(z)$在**区域**$D$内**解析**且在**闭区域**$\overline{D}=D+C$上**连续**，那么

   $$
      \oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0
   $$

+ 推论1到2是将“整个闭区域解析”弱化为“闭区域内部解析，边界连续”

### 推论2：复合闭路定理（有洞的柯西古撒定理）

**复合闭路定理**：设 $C$ 为**多连通**区域$D$的一条简单闭曲线，$C$ 内含有简单闭曲线 $C_k,k=1,2,3...C_k$ 它们相互不包含，也互不相交， $C$ 和 $C_k$ 均取**正方向**，$f(z)$在区域 $D$ 内解析，记 $C_k^-$ 为曲线 $C_k$ 负方向，则

$$
\begin{align}
\oint_Cf(z)dz&=\sum_{k=1}^{n}\oint_{C_k}f(z)dz\\
\oint_\Gamma f(z)dz&=0,\\
\Gamma=&{C+C_1^-+C_2^-+C_3^-...}\notag
\end{align}
$$

>证明总体思路：闭路变形原理：区域内一个解析函数沿简单闭曲线（对应上文的$C$）的积分是0（柯西古撒定理），对这个简单闭曲线做变形，同时保持其连续性且不经过函数的不解析点（对应上文的$C_k$）这样的变形不会改变积分值

如图，在 $C$ 中取简单闭曲线 $C_1$,用直线段 $AA^\prime,BB^\prime$ 链接，那么便产生了两个不包含奇点的闭区域，f(z)在这两个闭区域边界的积分分别用柯西古撒定理，再加一起，直线段的积分因为方向相反抵消，就能得到（1）式。

### 推论3：柯西积分公式

先来回顾一道陈年老题：
 函数$f(z)=1/z$在圆$C:z=Re^{i\theta}$上的积分为:

:::note[solution]
$$
 \oint f(z)dz=\int_0^{2\pi}\frac{1}{Re^{i\theta}}iRe^{i\theta}d\theta=2\pi i
$$
:::

那么推广一下，令$F(z)=\frac{f(z)}{z-z_0}$在简单闭曲线$C$围成的区域内解析（圆周$C$换成任意闭曲线，并且圆心的奇点等效于$\frac{1}{z-z_0},z_0\in C$），则积分
$$
\oint_C \frac{f(z)}{z-z_0}dz=f(z_0)2\pi i
$$
其中的参数化是 $z=z_0+re^{i\theta}$

**柯西积分公式**：如果$f(z)$在区域$D$内处处解析，$C$为$D$内的任何一条正向简单闭曲线，它的内部完全包含于$D$，$z_0$为$C$内部的任一点（不能在C上），那么
$$
\oint_C \frac{f(z)}{z-z_0}dz=f(z_0)2\pi i
$$

+ 在实际的计算中，往往需要手动找出奇点并化成许多个柯西积分公式的形式。常见的有拆分母。

+ 如果遇到奇点在积分路径上的情况，不能用柯西积分公式，但可以可以考虑让 𝑎从内部趋近边界，然后取极限。用 Plemelj公式（或称柯西积分的边界值公式）这里不多讲。

### 推论4：解析函数积分与路径无关和原函数存在定理

1. **积分与路径无关**：
若$f(z)$是区域$D$内的解析函数，那么曲线积分$\int_Cf(z)$在$D$内与路径无关，只与起始点有关。

   :::tip
   证明：

   设$\Gamma,C$为$D$内任意同向的从$z_1\to z_2$的路径，由柯西古撒定理，

   $$
   \oint_{C^-+\Gamma}f(z)dz=0\\
   \int_{\Gamma}f(z)dz-\int_Cf(z)dz=0\\
   \int_{\Gamma}f(z)dz=\int_Cf(z)dz
   $$

   :::

   常见的全纯函数以及部分解析的函数：
   指数函数 $e^z$ ,幂函数 $z^n$ 以及对应的多项式函数，三角函数与双曲函数

   如 $\frac{1}{z}$ 这种在区域 $\mathbb{C}/{(0,0)}$ 内解析，若闭区域积分不是单连通则参考复合闭路定理

   如 $\ln (z+1)$ 在 $(-1.+\infin)$ 内解析

1. **原函数存在定理**：设 $f(z)$ 是区域$D$内的解析函数，那么存在变上限积分函数 $F(z)$  
   $$
   F(z)=\int_{z_0}^zf(\zeta)d\zeta
   $$
   $F(z)$ 也是**解析**函数，并且满足
   $$
   F^\prime(z)=f(z)
   $$
   :::tip证明：
   $$
   \begin{align*}
   F^\prime(z)&=\lim_{\Delta z\to 0}\frac{F(z+\Delta z)-F(z)}{\Delta z}\\[10bp]
   &=\lim_{\Delta z\to 0}\frac{\int_{z_0}^{z+\Delta z}f(\zeta)d\zeta-\int_{z_0}^{z}f(z)d\zeta}{\Delta z}\\[10bp]
   &=\lim_{\Delta z\to 0}\frac{\int_z^{z+\Delta z}f(\zeta)d\zeta}{\Delta z}\\
   &\forall \zeta>0,\exist \delta>0,when\,|\Delta z|<\delta\\
   &|\frac{\int_z^{z+\Delta z}f(\zeta)d\zeta}{\Delta z}-f(z)|<\epsilon\\
   as\,long\,as&\frac{|\int_z^{z+\Delta z}f(\zeta)d\zeta-\int_z^{z+\Delta z}f(z)d\zeta|}{|\Delta z|}<\epsilon\\
   &\frac{|\int_z^{z+\Delta z}[f(\zeta)-f(z)]d\zeta|}{|\Delta z|}<\epsilon\\
   &\frac{\int_z^{z+\Delta z}|f(\zeta)-f(z)|d\zeta}{|\Delta z|}<\epsilon\\
   &\frac{\int_z^{z+\Delta z}|f(\zeta)|-|f(z)|d\zeta}{|\Delta z|}<\epsilon\\
   &if \Delta z\to 0,then \zeta_{\Delta z}\to z\\
   &\therefore F^\prime(z)=f(z)
   \end{align*}\\
   $$
   注意这里不能用积分中值定理（微分中值定理在复变中不加条件不成立）。证明了$F(z)$在$D$内可导，而且导数恰好是$f(z)$，又因为$f(z)$解析所以$f(z)$连续，所以$F(z)$一阶导连续，由解析的判定定理可知$F(z)$解析
   :::

2. **原函数和不定积分**： $\Phi(z),f(z)$ 是区域$D$内确定的函数，其中 $\Phi(z)$ 是**解析函数**。如果满足
   $$
   \Phi^\prime(z)=f(z)
   $$
   则称 $\Phi(z)$ 是 $f(z)$ 的一个**原函数**， $f(z)$ 所有的原函数构成它的**不定积分**，记作 $\int f(z)dz$ ，满足
   $$
   \int f(z)dz=\Phi(z)+C,C\text{为任意常数}
   $$

3. **牛顿莱布尼兹公式**：设 $f(z)$ 是单连通区域$D$上的解析函数， $\Phi(z)$ 是 $f(z)$ 的一个原函数，则
   $$
   \forall z_0,z_1\in D,\int_{z_0}^{z_1}f(z)dz=\Phi(z_1)-\Phi(z_0)
   $$

+ 初等函数都是定义域内处处解析的，因此都有原函数
+ 凑微分，分部积分在复变函数领域依然适用

## morera定理

**morera定理**：设$f(z)$在单连通区域D内连续，C为D 内任意一条简单封闭曲线，如果 $\oint_Cf(z)dz=0$,那么函数$f(z)$解析。

证明：可积说明存在原函数，$F^\prime(z)=f(z)$,并且原函数是解析函数，由解析函数可以无限阶求导以及求导之后解析性不变可以得到$f(z)$是解析函数

## 柯西不等式

射$f(z)$在$C:|z-z_0|=\rho$所围成的区域内解析，则$|f^{(n)}(z)|\leq\frac{n!M(\rho)}{\rho^n}$