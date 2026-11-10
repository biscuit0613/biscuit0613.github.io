---
title: 复变函数：级数练习题
published: 2025-09-22
description: ''
image: ''
tags: [复变函数, 复级数,留数定理]
category: '复变函数'
draft: false 
lang: ''
---

## 敛散性判别这一块

eg1:$\sum_{n=1}^\infin \frac{1}{n}(1+\frac{i}{n}$(发)

:::tip
实部级数是 $\frac{1}{n}$ 发散，原级数发散
:::

eg2:$\sum_{n=1}^\infin\frac{(8i)^n}{n!}$ (绝对收敛)

考察级数 $\sum_{n=1}^\infin\frac{(8)^n}{n!}$,用比值判别法
$$
\lim_{n\to\infin}\frac{\frac{8^{n+1}}{(n+1)!}}{\frac{(8)^n}{n!}}\\[5pt]
=\lim_{n\to\infin}\frac{8}{n+1}=0
$$

eg3：证明 $\sum_{n=0}^\infty\frac{z^n}{n^2}$ 在收敛圆内一致收敛

:::note[一致收敛的判定]

1. Weierstrass判别法
2. 柯西一致收敛准则

:::

原级数的收敛半径 $r=1$,考察任意有界闭区域 $|z|\leq r_0<1$,则有
$$
| \frac{z^n}{n^2} | \leq \frac{r_0^n}{n^2}
$$

用Weierstrass判别法，考察级数 $\sum_{n=0}^\infty\frac{r_0^n}{n^2}$,它是一个收敛的正项级数，因此原级数在收敛圆内一致收敛

## 收敛半径

eg1:$\sum_{n=1}^\infin \frac{z^n}{n^3}$

$$
\rho=\lim_{n\to\infin}\frac{\frac{z^{n+1}}{(n+1)^3}}{\frac{z^n}{n^3}}=|z|\\[5pt]
|z|<1\iff r=1
$$

eg2:$\sum_{n=1}^\infin n!\cdot z^n$

$$
\rho=\lim_{n\to\infin}\frac{(n+1)!\;z^{n+1}}{n!\;z^n}=\lim_{n\to\infin}(n+1)|z|<1\\
r=0
$$

eg3:求和函数：$\sum_{n=1}^\infin z^n$

$$
S_n(z)=\frac{1-z^n}{1-z}\\
\rho=\lim_{n\to\infin}\frac{|z^{n+1}|}{z^n}=\lim_{n\to\infin}|z|<1\\
r=1\\
\text{当｜z｜=1时，原级数一般项不趋近于0，发散}\\
\therefore S_n(z)=\frac{1-z^n}{1-z},\;|z|<1
$$

eg4:求收敛半径并讨论收敛圆周上的敛散性

(1):$\sum_{n=1}^\infin(\ch \frac{i}{n})(z-1)^n$

$$
\ch \frac{i}{n}=e^\frac{i}{n}+\frac{e^\frac{-i}{n}}{2}=\cos \frac{i}{n}\\
\rho=\lim_{n\to\infin}\frac{|\cos \frac{i}{n+1}(z-1)^{n+1}|}{|\cos \frac{i}{n}(z-1)^{n}|}\\
=|z-1|<1\\
r=1\\
\text{当z=1时，原级数一般项不趋近于0，发散}
$$

(2): $\sum_{n=1}^\infty(\frac{z}{\ln in})^n$ 根值判别法

## 求和函数，求幂级数展开

eg1:求 $\sum_{n=0}^\infty (n+1)z^n$ 的和函数

$$
S_n(z)=\sum_{n=0}^\infty (n+1)z^n=\sum_{n=0}^\infty \frac{d}{dz}z^{n+1}=\frac{d}{dz}\sum_{n=0}^\infty z^{n+1}=\frac{d}{dz}\frac{z}{1-z}=\frac{1}{(1-z)^2}
$$

eg2：求 $\frac{-1}{(1+z)^2}$ 的幂级数展开

$$
\frac{-1}{(1+z)^2}=(\frac{1}{1+z})^\prime\\[5pt]
\text{又}\;\frac{1}{1+z}=\sum_{n=0}^\infty (-1)^nz^n\\[5pt]
\therefore \frac{-1}{(1+z)^2}=\sum_{n=1}^\infty (-1)^nnz^{n-1}
$$

eg3: 求 $\frac{1}{z^3+z^2-z-1}$ 的幂级数展开

先把分母因式分解
$$
\frac{1}{z^3+z^2-z-1}=\frac{1}{(z-1)}\cdot\frac{1}{(z+1)^2}\\[5pt]
\text{又}\;\frac{-1}{(z+1)^2}=\sum_{n=1}^\infty (-1)^nnz^{n-1}\;;\frac{1}{(1-z)}=\sum_{n=0}^\infty z^n\\[5pt]\\
\text{根据幂级数的乘法公式}\\
\frac{1}{z^3+z^2-z-1}=\sum_{n=0}^\infty z^n\cdot \sum_{n=1}^\infty (-1)^nnz^{n-1}\\[5pt]
=\sum_{n=0}^\infty z^n\cdot \sum_{n=0}^\infty (-1)^{n+1}(n+1)z^n\\[5pt]\\
=\sum_{n=0}^\infty (n+1)(z^{2n+1}-z^{2n})\;|z|<1\\
$$

:::note[小技巧]

在处理幂级数的乘法时，可以利用卷积的思想，将两个级数的乘积转化为一个新的级数。

有两个幂级数：
$$
A(z) = \sum_{n=0}^\infty a_n z^n, \quad B(z) = \sum_{n=0}^\infty b_n z^n
$$
它们的乘积可以表示为：
$$
A(z) \cdot B(z) = \sum_{n=0}^\infty c_n z^n
$$
其中，$c_n$ 是通过卷积计算得到的系数：
$$
c_n = \sum_{k=0}^n a_k b_{n-k}
$$

可以画一个表格来帮助理解卷积的过程：

|       | b₀ | b₁ | b₂ | b₃ | ... |
|-------|----|----|----|----|-----|
| a₀    | a₀b₀ | a₀b₁ | a₀b₂ | a₀b₃ | ... |
| a₁    | a₁b₀ | a₁b₁ | a₁b₂ | a₁b₃ | ... |
| a₂    | a₂b₀ | a₂b₁ | a₂b₂ | a₂b₃ | ... |
| a₃    | a₃b₀ | a₃b₁ | a₃b₂ | a₃b₃ | ... |
| ...   | ... | ... | ... | ... | ... |

其中，$c_n$ 就是表格中第 $n+1$ 条对角线上的元素之和（n从0开始）。

比如说 $c_0 = a_0b_0$，$c_1 = a_0b_1 + a_1b_0$，$c_2 = a_0b_2 + a_1b_1 + a_2b_0$，以此类推。

注意要统一起始下标喵

:::

eg4：把 $\frac{1}{z-b}$ 写成 $\sum_{n=0}^\infty c_n(z-a)^n$ 的形式

$$
\frac{1}{z-b}=\frac{1}{(z-a)+(a-b)}=\frac{1}{a-b}\cdot\frac{1}{1+\frac{z-a}{a-b}}\\
=\frac{1}{a-b}\sum_{n= 0}^\infty (-1)^n(\frac{z-a}{a-b})^n\\
=\sum_{n=0}^\infty \frac{(-1)^n}{(a-b)^{n+1}}(z-a)^n
$$

eg5：求 $\frac{1}{z^2}$ 在 $z_0=-1$ 处的泰勒展开,并求出其收敛半径

$$
\frac{1}{z^2}\text{奇点是}z=0\\
\text{距离}z_0=-1\text{最近的奇点是}z=0\\
\therefore r=1\\
\frac{1}{z^2}=\frac{1}{1-(z+1)}\cdot\frac{1}{1-(z+1)}\\
=\sum_{n=0}^\infty (z+1)^n\cdot\sum_{n=0}^\infty (z+1)^n\\
=\sum_{n=0}^\infty (n+1)(z+1)^n\\
|z+1|<1\\
$$

eg6:求 $\frac{1}{4-3z}$ 在 $z_0=1+i$ 处的泰勒展开,并求出其收敛半径

$$
\frac{1}{4-3z}=\frac{1}{4-3(1+i)-3(z-(1+i))}=\frac{1}{1-3i-3(z-(1+i))}\\
=\frac{1}{1-3i}\cdot\frac{1}{1-\frac{3}{1-3i}(z-(1+i))}\\
=\frac{1}{1-3i}\sum_{n=0}^\infty(\frac{3}{1-3i})^n(z-(1+i))^n\\
\text{奇点是}z=\frac{4}{3}\\
\text{距离}z_0=1+i\text{最近的奇点是}z=\frac{4}{3}\\
\therefore r=|\frac{4}{3}-(1+i)|=\frac{\sqrt{10}}{3}
$$

eg7:求 $\frac{e^{z^2}}{\cos z}$ 在 $z_0=0$ 处的泰勒展开,并求出其收敛半径

$$
\text{奇点是}z=\frac{\pi}{2}+k\pi,k\in Z\\
\text{距离}z_0=0\text{最近的奇点是}z=\pm\frac{\pi}{2}\\
\therefore r=\frac{\pi}{2}\\
e^{z^2}=\sum_{n=0}^\infty \frac{z^{2n}}{n!}\\
\cos z=\sum_{n=0}^\infty (-1)^n\frac{z^{2n}}{(2n)!}\\
\text{根据幂级数的除法公式}\\

$$

## 洛朗级数展开

>eg1：求 $\frac{1}{(z^2+1)(z-2)}\;1<|z|< 2\;,2 < |z − i| < \sqrt{5}\;,\sqrt{4}<|z + i|<+\infty$ 在三个圆环内的洛朗级数展开。

(1): $1<|z|< 2$ 时
$$
\text{奇点}z=\pm i,2，\\
$$

## 泰勒级数的应用

>eg1: 设函数 $f(z)$ 在 $|z|<1$ 范围内解析，且 $g(z)=f(z^2)$ ,求 $g^{(2019)}(0)$

$f(z)$ 解析，说明可以在 $z=0$ 处展开成泰勒级数：
$$
f(z)=\sum_{n=0}^\infty a_nz^n\\
g(z)=f(z^2)=\sum_{n=0}^\infty a_nz^{2n}\\
$$

可以看出，g(z)的泰勒展开式中只有偶数次幂项，说明奇数次幂的泰勒展开项系数是0

$$
\therefore g^{(2019)}(0)=0
$$

>eg2:我们知道，函数 $\dfrac{1}{1+x}$ 当 $x$ 为任何实数时，都有确定的值，而且是可导的。但它的泰勒展开式：
>$$
>\frac{1}{1+x} = 1 - x + x^2 - x^3 + x^4 - \cdots
>$$
>却只当 $|x| < 1$ 时成立。通过研究函数 $\dfrac{1}{1+z^2}$，试说明其原因。

函数 $\dfrac{1}{1+z^2}$ 在复平面上有两个奇点，分别是 $z=i,-i$。这两个奇点距离原点的距离都是 1，因此函数 $\dfrac{1}{1+z^2}$ 在 $|z|<1$ 范围内解析，可以展开成泰勒级数

$$
\frac{1}{1+z^2}=\sum_{n=0}^\infty (-1)^nz^{2n}
$$
但是在 $|z|>1$ 范围内，函数 $\dfrac{1}{1+z^2}$ 不再解析，无法展开成泰勒级数。因此，虽然 $\dfrac{1}{1+x}$ 在实数范围内有定义，但其泰勒展开式只在 $|x|<1$ 范围内成立。

当 $|x|=1$ 时，左边=$\dfrac{1}{2}$，右边=$\sum_{n=0}^\infty (-1)^n$，因此泰勒展开式不成立。

### 留数定理的应用

三角函数反常积分这一块

>eg1: ：$I=\int_0^{\pi} \dfrac{\sin^2 x}{3+2\cos x} dz$

$$
\begin{alignedat}{2}
    &I &&=\frac{1}{2}\int_0^{2\pi} \dfrac{\sin^2 x}{3+2\cos x} dz\\
    & &&=\frac{1}{2}\oint\limits_{|z=1|}\frac{(\frac{z-\frac{1}{z}}{2i})^2}{3+z+\frac{1}{z}}\frac{1}{zi}dz\\
    & &&=\oint\limits_{|z=1|}\frac{-1}{8i}\frac{(z^4-2z^2+1)i}{z^3(z^2+3z+1)}dz\\
\end{alignedat}
$$
奇点是 $z=0$ (三阶), $\frac{-3\pm\sqrt{5}}{2}$(两个一阶),与分母没有共同零点,由留数定理，取一阶极点的留数

$$
\begin{alignedat}{2}
    & &&=\oint\limits_{|z=1|}\frac{-1}{8i}\frac{(z^4-2z^2+1)i}{z^3(z^2+3z+1)}dz\\
    & &&=\frac{-1}{8i}2\pi i\sum_{k=1}^{2}Res\left(\frac{(z^4-2z^2+1)i}{z^3(z^2+3z+1)},z_k\right)\\
\end{alignedat}
$$

:::tip
这里把 $\frac{(z^4-2z^2+1)i}{z^3}$ 当作 $P(z)$，$z^2+3z+1$ 当作 $Q(z)$ 用商式求留数的公式：

$$
    \operatorname{Res}(f, z_0) = \dfrac{P(z_0)}{Q'(z_0)}
$$
:::

$$
\begin{alignedat}{2}
    & &&=\frac{-1}{8i}2\pi i\sum_{k=1}^{2}Res\left(\frac{(z^4-2z^2+1)i}{z^3(z^2+3z+1)},z_k\right)\\
    & &&=\frac{-1}{8i}2\pi i\cdot(\frac{(z^4-2z^2+1)i}{z^3(2z+3)})\bigg|_{z=\frac{-3\pm\sqrt{5}}{2}}\\
    & &&=\frac{-\pi}{4}(3+\sqrt5)
\end{alignedat}
$$

>eg2：$I=\int_0^{\pi} \dfrac{\cos mx}{5-4\cos x}dx$

:::tip
遇到不方便表示的三角函数，可以用欧拉公式的实部或虚部表示
:::

$$
\begin{alignedat}{2}
    &I &&=\frac{1}{2}\int_0^{2\pi}\frac{\operatorname{Re}e^{imx}}{5-4\cos x}\,dx\\
    & &&=\frac{1}{2}\operatorname{Re}\int_0^{2\pi}\frac{e^{imx}}{5-4\cos x}\,dx\\
    & &&=\frac{1}{2}\operatorname{Re}\oint\limits_{|z|=1}\frac{z^m}{5-4\frac{z+z^{-1}}{2}}\,\frac{1}{iz}dz\\
    & &&=\frac{1}{2i}\operatorname{Re}\oint\limits_{|z|=1}\frac{z^m}{-2z^2+5z-2}dz\\
\end{alignedat}
$$
两个奇点，$z=\dfrac{1}{2},2$ ，均为一阶极点，注意只有 $z=\dfrac{1}{2}$ 在积分路径内被积函数满足商的形式，直接套公式 $\operatorname{Res}(f, z_0) = \dfrac{P(z_0)}{Q'(z_0)}$ 求留数

$$
\begin{alignedat}{2}
    & &&=\frac{1}{2i}\operatorname{Re}\oint\limits_{|z|=1}\frac{z^m}{-2z^2+5z-2}dz\\
    & &&=\frac{1}{2i}\operatorname{Re}2\pi iRes\left(\frac{z^m}{-2z^2+5z-2},\frac{1}{2}\right)\\
    & &&=\frac{1}{2i}\operatorname{Re}2\pi i\frac{(\frac{1}{2})^m}{-4(\frac{1}{2})+5}\\
    & &&=\frac{1}{3}\pi(\frac{1}{2})^m
\end{alignedat}
$$

多项式的反常积分这一块

>eg3 $I=\int_{-\infty}^{+\infty}\dfrac{x^2}{(x^2+b^2)(x^2+a^2)}dx,a>0,b>0$

上半平面的奇点是 $z_1=ai,z_2=bi$

$$
\begin{alignedat}{2}
    &I &&=2\pi i\sum_{k=1}^2\operatorname{Res}\left(\dfrac{x^2}{(x^2+b^2)(x^2+a^2)},z_k\right)\\
    & &&=2\pi i\left(\frac{\frac{x^2}{x+a^2}}{2x}\Bigg|_{z=bi}+ \frac{\frac{x^2}{x+b^2}}{2x}\Bigg|_{z=ai}\right)\\
    & &&=\frac{\pi}{a+b}
\end{alignedat}
$$

>eg4：$I=\int_0^{\infty}\dfrac{x^2}{x^4+1}dx$

奇点 $z_1=e^{i\frac{\pi}{4}},z_2=e^{i\frac{3\pi}{4}}$
$$
\begin{alignedat}{2}
    &I &&=\frac{1}{2}\int_{-\infty}^{+\infty}\dfrac{x^2}{x^4+1}dx\\
    & &&=\frac{1}{2}\operatorname{Res}\left(\dfrac{x^2}{x^4+1},e^{i\frac{\pi}{4}}\right)+\frac{1}{2}\operatorname{Res}\left(\dfrac{x^2}{x^4+1},e^{i\frac{3\pi}{4}}\right)\\
    & &&=\frac{1}{2}\left(\dfrac{x^2}{4x^3}\bigg|_{e^{i\frac{\pi}{4}}}\right)+\frac{1}{2}\left(\dfrac{x^2}{4x^3}\bigg|_{e^{i\frac{3\pi}{4}}}\right)\\
    & &&=\frac{\sqrt2 \pi }{4}
\end{alignedat}
$$

>eg5：$I=\int_{-\infty}^{+\infty}\dfrac{\cos ax}{(x^2+a^2)}dx,a>0$

分母无实根，但有零点，属于第三种情况

