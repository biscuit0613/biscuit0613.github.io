---
title: 复变函数：积分
published: 2025-08-20
description: '复变函数积分的定义，计算方法以及柯西古撒定理'
tags: [复变函数]
category: '复变函数'
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
      -[推论3：柯西积分公式](#推论3柯西积分公式配合复合闭路定理)
      -[推论4：积分与路径无关＆＆原函数存在定理](#推论4高阶导数公式)
      -[推论5：莫雷拉定理](#推论5平均值公式)
      -[推论6：柯西不等式](#推论6柯西不等式)
      -[推论7：平均值公式](#推论7解析函数积分与路径无关和原函数存在定理)
      -[推论8：morera定理](#推论8morera定理)
   -[整函数](#整函数)
      -[刘维尔定理](#刘维尔定理)

:::tip
类比于实函数积分，复变函数积分与第二型曲线积分类似
:::

## 复平面积分的定义

设函数 $\omega=f(z)$ 定义在区域 $D$ 内，$C$ 是 $D$ 内以 $A$ 为起点，$B$ 为终点的任意**光滑有向**曲线，在曲线 $C$ 上插入一系列点：
$$
z_1,z_2,z_3,z_4,z_5...z_{n-1}
$$
这些点把C分成n个小弧段 $\overset{\frown}{z_{k-1}z_k}$ ，记 $\Delta z_k=z_k-z_{k-1}$，在每小段弧上任取一点 $\zeta_k(\xi_k,\eta_k)=\xi_k+i\eta_k$，作和式：
$$
S_n=\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k
$$
记 $\delta=\max\{\overset{\frown}{z_{k-1}z_k}\text{的弧长}\}$，若不论对C的分法以及 $\zeta_k(\xi_k,\eta_k)$ 的取法，极限
$$
\lim_{\delta\to 0}\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k
$$
总是存在且唯一，则称此极限值为 $f(z)$ 沿着有向曲线 $C$ 的积分，记作
$$
\int_C f(z)dz
$$

## 积分存在性及其求法

:::note
积分存在性：连续函数可积
:::

### 1. 直接法：第二型曲线积分/二重积分

如果 $f(z)=u(x,y)+iv(x,y)$ 在有向光滑曲线 $C$ 上 **连续**，那么 $f(z)$ 沿 $C$ 的积分存在，并且
$$
\begin{align*}
   \int_C f(z)dz &= \int_C (u + iv) dz \\
   &= \int_C (u + iv) (dx + i dy) \\
   &= \int_C (u dx -  v dy) + i \int_C (v dx +  u dy)
\end{align*}
$$

:::note
证明：(用定义)
$$
   \begin{align*}
   z_k&=x_k+iy_k,x_k-x_{k-1}=\Delta x_k,y_k-y_{k-1}=\Delta y_k\\
   \zeta_k&=\xi_k+i\eta_k,u_k=u(\xi_k,\eta_k),v_k=v(\xi_k,\eta_k)\\
   S_n&=\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k\\
   &=\sum_{k=1}^{k=n}(u_k+iv_k)(\Delta x_k+i\Delta y_k)\\
   &=\sum_{k=1}^{k=n}[u_k\Delta x_k-v_k\Delta y_k+i(v_k\Delta x_k+u_k\Delta y_k)]\\
   &=\sum_{k=1}^{k=n}u_k\Delta x_k-v_k\Delta y_k+\sum_{k=1}^{k=n}i(v_k\Delta x_k+u_k\Delta y_k)\\
   &\text{ $f(z)$ 沿曲线 $C$ 连续，由复变函数连续的充要条件是实部虚部函数连续，}\\
   &\text{故 $u(x,y),v(x,y)$ 在曲线$C$上也连续}\\
   &\text{再由可积定义，函数连续必可积，$u,v$ 对应的两个第二型曲线积分一定存在。}\\
   &=\int_C{udx-vdy}+i\int_C{vdx+udy}
   \end{align*}
$$
:::

+ 说明了一个复变函数沿某曲线可积，那么它的积分能表示成两个第二型曲线积分的运算组合
+ 曲线 $C$ 上连续不代表曲线 $C$ 上处处连续，曲线 $C$ 上连续只是说 $C$ 上的点沿 $C$ 的方向是连续的，而处处连续要考虑曲线外的方向

### 2. 参数化：定积分

如果 $C$ 是有向的简单光滑曲线，$z=z(t)=x(t)+iy(t),t\in[t_0,T]$，且 $t_0,T$ 分别对应曲线的起点和终点，如果 $f(z)$ 在曲线 $C$ 上 **连续**，那么

$$
\int_Cf(z)dz=\int_{t_0}^Tf(z(t))z(t)^\prime dt\\
=\int_a^b \Big[u\big(x(t),y(t)\big)+iv\big(x(t),y(t) \big)\Big]\Big[x^\prime(t)+iy^\prime(t)\Big]dt
$$

:::note

证明：
$$
\begin{align*}
dz&=(x^\prime(t)+iy^\prime(t))dt\\
\int_Cf(z)dz&=\int_C[u(x(t),y(t))+iv(x(t),y(t))]\cdot(x^\prime(t)+iy^\prime(t))dt\\
&\text{令}u(t)=u(x(t),y(t)),v(t)=v(x(t),y(t))\\
&=\int_C[u(t)x^\prime(t)-v(t)y^\prime(t)]dt+i\int_C[v(t)x^\prime(t)+u(t)y^\prime(t)]dt
\end{align*}
$$

:::

### 复变函数积分的性质

1. 有向性：$\int_C f(z)dz=-\int_{C^-} f(z)dz$
2. $\int(kf(z)+lg(z))dz=k\int f(z)dz+l\int g(z)dz$
3. 分段可加性：如果 $C=C_1+C_2+\dots+C_n$
4. 模有界性：$|\int f(z)dz|\leq\int|f(z)|ds\leq ML$，这里 $|f(z)|\leq M,\forall z\in \mathbb{C}|$，积分路径的长度为 $L$

简要证明一下：

$$
|\int f(z)dz|\\
=|\lim_{\delta\to 0}\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k|\\
=\lim_{\delta\to 0}|\sum_{k=1}^{k=n}f(\zeta_k)\Delta z_k|\\
\text{这里用一步放缩}
$$

## 柯西古撒定理

### 背景

1. 复习积分与路径无关的四个等价条件

2. 如果 $f(z)=u(x,y)+iv(x,y)$ 在有向光滑曲线 $C$ 上 **连续**，那么 $f(z)$ 沿 $C$ 的积分存在，并且
   $$
   \int_Cf(z)dz=\int_C{udx-vdy}+i\int_C{vdx+udy}
   $$

## 柯西古撒定理内容

### 基本形式（回路在解析区域内，不含边界）

**柯西古撒定理**：对于**单连通区域**（不包含奇点）$D,C$ 为 $D$ 中任意一条**简单闭曲线**(不自交，端点相等，连续)，如果 $f(z)$ 在 $D$ 内**解析**，那么
$$
\oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0
$$

简而言之，柯西古撒定理就是**解析函数在解析的单连通区域内闭路积分为0**

:::tip
推导：

这两个第二型曲线积分如果满足**积分与路径无关**则有
$$
-\frac{\partial v}{\partial x}=\frac{\partial u}{\partial y},  \frac{\partial u}{\partial x}=\frac{\partial v}{\partial y}\tag{\#}
$$
这一坨式子很熟悉，是**柯西-黎曼条件**，即 $f(z)$ 在某点处可微的必要条件之一。只要加上 $u$，$v$ 一阶偏导数连续（即 $u$，$v$ 在某点可微）这个补充条件，就成了充要条件。

回顾**格林公式**：
$\oint Pdx+Qdy=\iint_D(\frac{\partial Q}{\partial x}-\frac{\partial P}{\partial y})dxdy$当这玩意等于0时，显然满足#条件，此时$\oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0$。

但是这样还不够，课本上给的前提是 $f$ 在 $D$ 上解析，不是可微，为什么会给出一个更严格的条件呢？这是因为 $u$，$v$ 在 $D$ 内处处可微且处处满足柯西黎曼条件，这恰好是 $f$ 在区域 $D$ 解析的充要条件

:::

### 推论1：区域内曲线推广到边界上

1. **闭区域内的柯西古撒定理**：如果**简单闭曲线** $C$ 为单连通区域 $D$ 的边界（即 $C=\partial D$），且函数 $f(z)$ 在**闭区域** $\overline{D}=D+C$ 上**解析**，那么

   $$
      \oint_Cf(z)dz=\oint_C{udx-vdy}+i\oint_C{vdx+udy}=0
   $$

2. **边界连续内部解析的柯西古撒定理**：如果**简单闭曲线** $C$ 为单连通区域 $D$ 的边界（即 $C=\partial D$），函数 $f(z)$ 在**区域** $D$ 内**解析**且在**闭区域** $\overline{D}=D+C$ 上**连续**，那么

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

如图，在 $C$ 中取简单闭曲线 $C_1$,用直线段 $AA^\prime,BB^\prime$ 链接，那么便产生了两个不包含奇点的闭区域，$f(z)$ 在这两个闭区域边界的积分分别用柯西古撒定理，再加一起，直线段的积分因为方向相反抵消，就能得到（1）式。

:::note
如果一个函数在路径内只有有限个奇点，而在其他地方解析，那么整个积分可以看作是这些奇点“局部贡献”的总和。

这个思想在后续的留数定理中会更为明显。

在路径内，除了奇点以外的区域，函数是解析的；而根据柯西-古撒定理，在解析区域内的闭合路径积分为零；所以整个积分的“非零部分”只能来自那些奇点附近的行为。
:::

### 推论3：柯西积分公式(配合复合闭路定理)

先来回顾一道陈年老题：
 函数 $f(z)=1/z$ 在圆 $C:z=Re^{i\theta}$ 上的积分为:

:::note[solution]
$$
 \oint f(z)dz=\int_0^{2\pi}\frac{1}{Re^{i\theta}}iRe^{i\theta}d\theta=2\pi i
$$
:::

推广一下，令 $F(z)=\frac{f(z)}{z-z_0}$ 在简单闭曲线 $C$ 围成的区域内解析（圆周 $C$ 换成任意闭曲线，并且奇点由 $\frac{1}{z-z_0}$提供, $z_0\in C$），则积分
$$
\begin{align*}
   \oint_C \frac{f(z)}{z-z_0}dz&=\int_0^{2\pi}\frac{f(z_0+re^{i\theta})}{re^{i\theta}}dre^{i\theta}\\
   &=\int_0^{2\pi} \frac{f(z_0+re^{i\theta})}{re^{i\theta}}ire^{i\theta}d\theta\\
   &=i\int_0^{2\pi} f(z_0+re^{i\theta})d\theta\\
   &=2\pi i f(z_0)
\end{align*}
$$

**柯西积分公式**：如果 $f(z)$ 在区域 $D$ 内处处解析，$C$ 为 $D$ 内的任何一条正向简单闭曲线，它的内部完全包含于 $D$，$z_0$ 为 $C$ 内部的任一点（不能在 $C$ 上），那么
$$
\oint_C \frac{f(z)}{z-z_0}dz=f(z_0)2\pi i
$$

+ 当回路包含奇点时，才会用到复合闭路和柯西积分公式，不包含时直接柯西古撒定理得0

+ 在实际的计算中，往往需要手动找出奇点并化成许多个柯西积分公式的形式。常见的有拆分母。

+ 如果遇到奇点在积分路径上的情况，不能用柯西积分公式，但可以考虑让 $a$ 从内部趋近边界，然后取极限。用 Plemelj公式（或称柯西积分的边界值公式）这里不多讲。

### 推论4：高阶导数公式

**高阶导数公式**：设 $f(z)$ 在区域 $D$ 内解析，$C$ 为 $D$ 内的任意一条正向简单闭曲线，$z_0$ 为 $C$ 内部的任一点（不能在 $C$ 上），那么对于任意正整数 $n$，都有
$$
\oint_C \frac{f(z)}{(z-z_0)^{n+1}}dz=\frac{2\pi i}{n!}f^{(n)}(z_0)
$$

### 推论5：平均值公式

**平均值公式**：设 $D\subset\mathbb{C}$ 是一个开集，函数 $f$ 在区域 $D$ 上解析。闭圆盘 $|z-z_0|=R$ 完全包含在解析区域内，那么函数 $f$ 在圆心 $z_0$ 处的值等于在圆周上的值的算数平均：
$$
f(z_0)=\frac{1}{2\pi}\int_0^{2\pi}f(z)d\theta
$$

:::note[证明]
用柯西积分公式进行证明
$$
f(z_0)=\frac{1}{2\pi i}\oint\frac{f(z)}{z-z_0}dz\\[5bp]
z=z_0+re^{i\theta}\\[5bp]
f(z_0)=\frac{1}{2\pi}\oint\frac{f(z)}{re^{i\theta}}re^{i\theta}d\theta
$$
：：：

### 推论6：柯西不等式

**柯西不等式**：设 $f(z)$ 在 $C:|z-z_0|=\rho$ 所围成的区域（注意这里是**闭圆盘**，包括圆周）上解析，若在圆周上有 $|f(z)|\leq M$ 则
$$
|f^{(n)}(z_0)|\leq\frac{n!M(\rho)}{\rho^n}
$$

### 推论7：解析函数积分与路径无关和原函数存在定理

1. **积分与路径无关**：
   若 $f(z)$ 是区域 $D$ 内的**解析**函数，那么曲线积分 $\int_Cf(z)$ 在 $D$ 内**与路径无关**，只与起始点有关。

   :::tip
   证明：

   设 $\Gamma,C$ 为 $D$ 内任意同向的从 $z_1\to z_2$ 的路径，由柯西古撒定理，

   $$
   \begin{align*}
   &\oint_{C^-+\Gamma}f(z)dz=0\\
   &\int_{\Gamma}f(z)dz-\int_Cf(z)dz=0\\
   &\therefore\int_{\Gamma}f(z)dz=\int_Cf(z)dz
   \end{align*}
   $$

   :::

   常见的全纯函数以及部分解析的函数：
   指数函数 $e^z$ ,幂函数 $z^n$ 以及对应的多项式函数，三角函数与双曲函数

   如 $\frac{1}{z}$ 这种在区域 $\mathbb{C}/{(0,0)}$ 内解析，若闭区域积分不是单连通则参考复合闭路定理

   如 $\ln (z+1)$ 在 $(-1.+\infin)$ 内解析
2. **原函数存在定理**：
   设 $f(z)$ 是区域 $D$ 内的解析函数，那么存在变上限积分函数 $F(z)$，满足：

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
   注意这里不能用积分中值定理（微分中值定理在复变中不加条件不成立）。证明了 $F(z)$ 在 $D$ 内可导，而且导数恰好是 $f(z)$，又因为 $f(z)$ 解析所以 $f(z)$ 连续，所以 $F(z)$ 一阶导连续，由解析的判定定理可知 $F(z)$ 解析
   :::
3. **原函数和不定积分**：
   $\Phi(z),f(z)$ 是区域 $D$ 内确定的函数，其中 $\Phi(z)$ 是**解析函数**。如果满足
   $$
   \Phi^\prime(z)=f(z)
   $$
   则称 $\Phi(z)$ 是 $f(z)$ 的一个**原函数**， $f(z)$ 所有的原函数构成它的**不定积分**，记作 $\int f(z)dz$ ，满足
   $$
   \int f(z)dz=\Phi(z)+C,C\text{为任意常数}
   $$

4. **牛顿莱布尼兹公式**:
   设 $f(z)$ 是单连通区域 $D$ 上的解析函数， $\Phi(z)$ 是 $f(z)$ 的一个原函数，则
   $$
   \forall z_0,z_1\in D,\int_{z_0}^{z_1}f(z)dz=\Phi(z_1)-\Phi(z_0)
   $$

+ 初等函数都是定义域内处处解析的，因此都有原函数
+ 凑微分，分部积分在复变函数领域依然适用

### 推论8：morera定理

:::tip
morera定理可以看做柯西古萨定理的逆定理，即由闭路积分为零可以推出来解析
:::

**morera定理**：设 $f(z)$ 在单连通区域 $D$ 内连续，$C$ 为 $D$ 内任意一条简单封闭曲线，如果 $\oint_Cf(z)dz=0$,那么函数 $f(z)$ 解析。

证明：可积说明存在原函数， $F^\prime(z)=f(z)$ ,并且原函数是解析函数，由解析函数可以无限阶求导以及求导之后解析性不变可以得到 $f(z)$ 是解析函数

## 整函数

整函数的定义：在整个复平面 $\mathbb{C}$ 上解析的函数成为**整函数**

常见的整函数包括多项式函数指数函数(分支上)三角函数之类

### 刘维尔定理

刘维尔定理：有界的整函数必为常值函数

:::note[证明]
$$
\forall z\in\mathbb{C},|f(z)|\leq M\\
\text{用柯西不等式的一阶导形式}\\
|f^\prime(z)|\leq\frac{M}{\rho}\\
\lim_{\rho\to\infin}|f^\prime(z)|\leq0\\
\therefore f^\prime(z)=0,f(z)=C
$$
:::
