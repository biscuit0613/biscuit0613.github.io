---
title: 复变函数： 傅里叶变换
published: 2025-10-15
description: ''
image: ''
tags: [傅里叶变换]
category: '复变函数'
draft: false 
lang: ''
---

:::tip
函数满足狄利克雷条件，则可以进行傅里叶展开
:::

## 傅里叶积分定理

若定义在 $(-\infty,+\infty)$ 函数满足

1. 在任意有限区间上满足狄利克雷条件
2. 在 $(-\infty,+\infty)$ 上函数绝对可积，即 $\int_{-\infty}^{+\infty}|f(t)|dt$

那么傅里叶积分：

$$
\frac{1}{2\pi }\int_{-\infty}^{+\infty}\left[\int_{-\infty}^{+\infty}f(\tau)e^{-i\omega\tau}dt\right]e^{i\omega t}d\omega=
\begin{cases}
    f(t)&& \text{t为连续点}\\
    \frac{1}{2}[f(t+0)+f(t-0)]&& \text{t为第一类间断点}
\end{cases}
$$

## 傅里叶变换

所谓傅里叶变换，简单理解为变自变量，把t(time)变成频率 $\omega$(frequency)形式化定义如下

$$
\mathcal{F}[f(t)]=F(\omega)=\int_{-\infty}^{+\infty}f(t)e^{-i\omega t}dt
$$

相应的，逆变换的形式是

$$
\mathcal{F}^{-1}[F(\omega)]=f(t)=\frac{1}{2\pi}\int_{-\infty}^{+\infty}F(\omega)e^{i\omega t}d\omega
$$

求傅里叶变换的过程就是纯纯的积分

## 单位脉冲函数

**单位脉冲函数**：形如

$$
\mathcal{\delta}_\lambda(t)=\begin{cases}
    0&t<0\\
    \frac{1}{\lambda}&0\leq t\leq\lambda\\
    0\lambda<t
\end{cases}
$$

**定义** 单位脉冲函数的反常积分积分值为1

$$
\int_{-\infty}^{+\infty} \mathcal{\delta}_{\lambda}(t)dt=1
$$

令 $\lambda\to 0$，那么 $\mathcal{\delta}_{\lambda}(t)\to\mathcal{\delta}(t)$

$$
\begin{aligned}
\mathcal{\delta}_\lambda(t)&=\begin{cases}
    0&t\neq 0\\
    +\infty&t=0\\
\end{cases}\\
\int_{-\infty}^{+\infty}\mathcal{\delta}(t)dt&=1
\end{aligned}
$$

同理

$$
\begin{aligned}
    \mathcal{\delta}_\lambda(t-t_0)&=\begin{cases}
    0&t\neq t_0\\
    +\infty&t=t_0\\
\end{cases}\\
\int_{-\infty}^{+\infty}\mathcal{\delta}(t-t_0)dt&=1
\end{aligned}
$$

## $\delta$ 函数的性质

1. $\delta(t)$ 是偶函数

2. 筛选性质：（前提：$f(t)$ 是连续函数）
    $$
        \int_{-\infty}^{\infty}\delta(t-t_0)f(t)dt=f(t_0)
    $$
    令 $t_0=0$
    $$
        \int_{-\infty}^{\infty}\delta(t-0)f(t)dt=f(0)
    $$
    :::tip
    这个性质可以证明 $\delta$ 函数的傅里叶变换也是1，把 $e^{-i\omega t}$ 当成 $f(t)$ 就行
    :::
3. 坐标缩放
    $$
    \delta(at)=\frac{1}{|a|}\delta(t)
    $$
    :::tip
    a=-1的时候提现 $\delta$ 函数的偶函数性
    :::
4. 高阶导数
    $$
    \delta^{(n)}(-t)=(-1)^n\delta^{(n)}
    $$
5. 重要等式（由筛选性质得来）
    $$
    g(t)\delta(t-t_0)=g(t_0)\delta(t-t_0)
    $$
6. $\delta$ 函数的傅里叶变换
    $$
    \begin{align*}
    \mathcal{F}[\delta(t)]&=\int_{-\infty}^{+\infty}\delta(t)e^{-i\omega t}dt=1\\
    \mathcal{F}[\delta(t-t_0)]&=\int_{-\infty}^{+\infty}\delta(t-t_0)e^{-i\omega t}dt=e^{-i\omega t_0}
    \end{align*}
    $$

## 广义傅里叶变换

当被变换的函数平均值不为0或 $-\infty\to+\infty$ 广义积分不收敛（比如说持续震荡的三角函数）时，就要用广义傅里叶变换

### $\delta$ 函数的傅里叶变换

$$
\mathcal{F}(\delta(t))=\int_{-\infty}^{+\infty}\delta(t)e^{-i\omega t}dt=1\\
\mathcal{F}(\delta(t-t_0))=\int_{-\infty}^{+\infty}\delta(t-t_0)e^{-i\omega t}dt=e^{-i\omega t_0}\\
\mathcal{F}(1)=2\pi\delta(\omega)\\
\mathcal{F}(e^{i\omega_0t})=2\pi\delta(\omega-\omega_0)
$$

相应的有逆变换

$$
\mathcal{F}^{-1}(1)=\delta(t)\\
\mathcal{F}^{-1}(e^{-i\omega t_0})=\delta(t-t_0)\\
\mathcal{F}^{-1}(2\pi\delta(\omega))=\frac{1}{2\pi}\int_{-\infty}^{+\infty}2\pi\delta(\omega)e^{-i\omega t}d\omega=1\\
$$

:::note
重要结论：符号函数 $sgn(t)=\begin{cases}
    -1＆t<0\\
    1&t>0\\
\end{cases}$
:::

>eg1 证明符号函数的傅里叶变换是 $\frac{1}{i\omega}$

:::tip
求傅里叶正变换并不好算，可以考虑求逆变换
:::

$$
\mathcal{F}^{-1}(\frac{1}{i\omega})=\frac{1}{2\pi}\int_{-\infty}^{+\infty}\frac{1}{i\omega}e^{i\omega t}d\omega\\
=\frac{1}{\pi}\int_{-\infty}^{+\infty}\frac{\cos\omega t+i\sin\omega t}{i\omega}d\omega\\
\text{后半个sin相关的奇函数积分为0}\\
$$

遇到狄利克雷积分，利用留数定理就行

$$
\int_0^{+\infty}\frac{sin ax}{x}dx=\frac{\pi}{2}
$$

>eg2 求阶跃函数的傅里叶变换

$$
u(t)=\begin{cases}
    0&t<0\\
    1&t>0\\
\end{cases}
$$

:::tip
把 $u(t)$ 和符号函数结合，$u(t)=\dfrac{1+sgn(t)}{2}$ ,利用符号函数的傅里叶变换
:::

>eg3 求 $f(t)=\sin \omega t,f(t)=\cos\omega t$ 的傅里叶变换

:::tip
拆成e的形式，然后找 $e^{i\omega t}$ 的傅里叶变换
:::

>eg4 已知 $F(\omega)=\pi\{\delta(\omega+\omega_0)+\delta(\omega-\omega_0)\}$ 为函数 $f(t)$ 的傅里叶变换，求 $f(t)$

$$
f(t)=\mathcal{F}^{-1}(F(\omega))\\
=\pi\{\mathcal{F}^{-1}(\delta(\omega+\omega_0))+\mathcal{F}^{-1}(\omega-\omega_0))\}
$$

## 傅里叶变换的性质

记 $f(t)$ 的傅里叶变换是 $F(\omega)$

1. 线性性：
    $$
    \mathcal{F}[k_1f(t)+k_2g(t)]=\mathcal{F}[k_1f(t)]+\mathcal{F}[k_2g(t)]
    $$

2. 对称性：
    交换自变量，有
    $$
    \mathcal{F}\left[F(t)\right]=2\pi f(-\omega)
    $$
3. 放缩性质：
    $$
    \mathcal{F}\left[f(at)\right]=\frac{1}{|a|}\mathcal{F}(\frac{\omega}{a}),\;\;a\neq 0
    $$
    简单证一下：
    $$
    \mathcal{F}\left[f(at)\right]=\int_{-\infty}^{+\infty}f(at)e^{-i\omega t}dt\\
    \text{令}at=\tilde{t}
    $$
4. 平移性质：
    $$
    \mathcal{F}[f(t-t_0)]=e^{-i\omega t_0}F(\omega)\text{令}\tilde{t}=t-t_0\\
    \mathcal{F}[e^{i\omega_0 t}f(t)]=F(\omega-\omega_0)
    $$
5. 导数性质
    $$
    \mathcal{F}[f^{(n)}(t)]=i\omega F(\omega)\\
    F^{(n)}(\omega)=\mathcal{F}[(-i\omega t)^nf(t)]
    $$

    简单证一下：(以一阶导为例)

    $$
    \mathcal{F}[f^{(1)}(t)]=\int_{-\infty}^{+\infty}e^{-i\omega t}df(t)\\
    \text{进行分部积分法}\\
    =-\int_{-\infty}^{+\infty}f(t)(-i\omega)e^{-i\omega t}dt\\
    =i\omega F(\omega)\\
    F^{(1)}(\omega)=?
    $$
6. 积分性质
    $$
    \int_{-\infty}^{+\infty}f_1\cdot \bar{f_2} dt=\frac{1}{2\pi}\int_{-\infty}^{+\infty}F_1\cdot\bar{F_2}d\omega
    $$
    特别地，如果 $f_1=f_2$ 得到帕斯威尔定理：

    $$
    \int_{-\infty}^{+\infty}|f(t)|^2 dt=\frac{1}{2\pi}\int_{-\infty}^{+\infty}|F(\omega)|^2d\omega
    $$

    简单证一下：

    $$
    f_1=\mathcal{F}^{-1}[F_1]=\frac{1}{2\pi}\int_{-\infty}^{+\infty}F_2e^{i\omega t}d\omega\\
    \text{求共轭的过程给每一项分别求共轭}\\
    \text{积分的时候换一下积分次序}\\
    $$

>eg1 求1：$f(t)=\sin (\omega_0 t)u(t)$ 2: $f(t)=e^{i\omega_0 t}tu(t)$

主要是第二个，方法有很多，可以用对称性，也可以注意到tu(t)求导之后就是 u（t）,或者用放缩也可以，里面成一个i

>eg2 求积分 $I=\int_{-\infty}^{+\infty}(\frac{sin t}{t})^2dt$

:::tip
利用parsevar定理，把 $\frac{sin t}{t}$ 当成 f（t）
:::
