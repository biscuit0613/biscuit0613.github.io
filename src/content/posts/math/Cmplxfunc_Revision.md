---
title: 复变函数： 复习与总结
published: 2025-10-22
description: ''
image: ''
tags: [复变函数复习]
category: '复变函数'
draft: false 
lang: ''
---

### 辐角主值

定义为复数的幅角取值范围为 $(-\pi, \pi]$ 的主值。

$$
\arg z=\arctan\frac{Im z}{Re z}
$$

常常配合 $arctan$ 函数的性质使用：

$$
arccot x=\arctan \frac{1}{x}\\
\arctan x+\arctan \frac{1}{x}=\begin{cases}
    \frac{\pi}{2}&x>0\\
    -\frac{\pi}{2}&x<0
\end{cases}
$$

### CR定理

速记：先写雅各比矩阵，再主对角相等副对角相反

速用1：在uv一阶偏导连续的情况下，点满足 $\iff$ 可导；区域满足 $\iff$ 全纯（解析）

速用2：结合调和函数，若u调和，则存在v使得f=u+iv全纯。求f有两种方法，一种是由u偏导结合CR方程来求v,另一种是直接用CR方程写f'并积分。如果有初值记得代

### 解析函数

常见的解析函数有有理，三角（本质上是指数），对数，指数等。解析函数的导积商复合仍是解析函数

解析函数的单连通解析域内闭路积分（Cauchy古撒定理）

### 柯西积分公式

设 $f(z)$ 在单连通区域 $D$ 内**解析**，$\Gamma$ 是区域内包含点 $a$ 的正向简单闭曲线，则有柯西积分公式：

$$
f(a) = \frac{1}{2\pi i} \oint_{\Gamma} \frac{f(z)}{z-a} \, dz
$$

有些题目中，往往a被当作变量z来处理，从而得到 $f(z)$ 的表达式

### 高阶导数公式

设 $f(z)$ 在单连通区域 $D$ 内**解析**，$\Gamma$ 是区域内包含点 $a$ 的正向简单闭曲线，则 $f$ 的 $n$ 阶导数公式为：

$$
f^{(n)}(a) = \frac{n!}{2\pi i} \oint_{\Gamma} \frac{f(z)}{(z-a)^{n+1}} \, dz
$$

### 留数

在求m阶极点的留数时，常用公式： 
$$
Res[f,z_0]=\frac{1}{(m-1)!}\lim_{z\to z_0}\left[\frac{d^{m-1}}{dz^{m-1}}((z-z_0)^mf(z))\right]
$$

其中极限意味着可以洛必达

其中 $(z-z_0)^m$ 作用：

1. 抵消极点的奇异性，使得括号内在 $z_0$ 处解析

2. 可以挪到分母上，结合lim把难算的部分变成高阶导数（结合零点阶数的定义）

eg $z_0$ 是 $g(z)$ 的二阶零点，则 $\lim\limits_{z\to z_0}\frac{g(z)}{(z-z_0)^2}=g^{\prime\prime}(z_0)$