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

## 傅里叶积分定理(了解就行)

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

## $\delta$ 函数（单位脉冲函数）

**$\delta$ 函数**：形如

$$
\mathcal{\delta}_\lambda(t)=\begin{cases}
    0&t<0\\
    \frac{1}{\lambda}&0\leq t\leq\lambda\\
    0\lambda<t
\end{cases}
$$

**定义**： $\delta$ 函数的反常积分积分值为1

$$
\int_{-\infty}^{+\infty} \mathcal{\delta}_{\lambda}(t)dt=1
$$

令 $\lambda\to 0$，那么 $\mathcal{\delta}_{\lambda}(t)\to\mathcal{\delta}(t)$

$$
\boxed{\begin{aligned}
\delta_\lambda(t)&=\begin{cases}
    0&t\neq 0\\
    +\infty&t=0\\
\end{cases}\\
\int_{-\infty}^{+\infty}\delta(t)dt&=1
\end{aligned}}
$$

同理

$$
\boxed{\begin{aligned}
    \mathcal{\delta}_\lambda(t-t_0)&=\begin{cases}
    0&t\neq t_0\\
    +\infty&t=t_0\\
\end{cases}\\
\int_{-\infty}^{+\infty}\delta(t)dt&=1
\end{aligned}}
$$

## $\delta$ 函数的性质

1. $\delta(t)$ 是偶函数

2. 筛选性质：（前提：$f(t)$ 是连续函数）
    $$
        \boxed{\int_{-\infty}^{\infty}\delta(t-t_0)f(t)dt=f(t_0)}
    $$
    令 $t_0=0$
    $$
        \boxed{\int_{-\infty}^{\infty}\delta(t-0)f(t)dt=f(0)}
    $$
    :::tip  
    这个性质可证 $\delta(t)$ 的傅里叶变换是1，把 $e^{-i\omega t}$ 当成 $f(t),t_0=0$ 就行；顺带就证明了1的傅里叶逆变换是 $\delta(t)$  
    :::
3. 坐标缩放
    $$
    \boxed{\delta(at)=\frac{1}{|a|}\delta(t)}
    $$
    :::tip  
    a=-1的时候体现 $\delta(t)$ 是偶函数  
    :::  
4. 高阶导数
    $$
    \boxed{\delta^{(n)}(-t)=(-1)^n\delta^{(n)}(t)}
    $$
5. 重要等式（由筛选性质得来）
    $$
    \boxed{g(t)\delta(t-t_0)=g(t_0)\delta(t-t_0)}
    $$
6. $\delta$ 函数的傅里叶变换
    $$
    \boxed{\begin{align*}
    \mathcal{F}[\delta(t)]&=\int_{-\infty}^{+\infty}\delta(t)e^{-i\omega t}dt=1\\
    \mathcal{F}[\delta(t-t_0)]&=\int_{-\infty}^{+\infty}\delta(t-t_0)e^{-i\omega t}dt=e^{-i\omega t_0}
    \end{align*}}
    $$

## 广义傅里叶变换

当被变换的函数平均值不为0或 $-\infty\to+\infty$ 广义积分不收敛（比如说持续震荡的三角函数）时，就要用广义傅里叶变换

### $\delta$ 函数的傅里叶变换

$$
\begin{aligned}
\qquad\mathcal{F}(\delta(t))&=\int_{-\infty}^{+\infty}\delta(t)e^{-i\omega t}dt=1\\
\mathcal{F}(\delta(t-t_0))&=\int_{-\infty}^{+\infty}\delta(t-t_0)e^{-i\omega t}dt=e^{-i\omega t_0}\\
\mathcal{F}(1)&=2\pi\delta(\omega)\\
\mathcal{F}(e^{i\omega_0t})&=2\pi\delta(\omega-\omega_0)
\end{aligned}

$$

相应的有逆变换

$$
\begin{aligned}
\mathcal{F}^{-1}(1)&=\delta(t)\\
\mathcal{F}^{-1}(e^{-i\omega t_0})&=\delta(t-t_0)\\
\mathcal{F}^{-1}(2\pi\delta(\omega))&=\frac{1}{2\pi}\int_{-\infty}^{+\infty}2\pi\delta(\omega)e^{-i\omega t}d\omega=1\\
\mathcal{F}^{-1}(2\pi\delta(\omega-\omega_0))&=\frac{1}{2\pi}\int_{-\infty}^{+\infty}2\pi\delta(\omega-\omega_0)e^{-i\omega t}d\omega=e^{-i\omega_0 t}
\end{aligned}
$$

### 符号函数的傅立叶变换

符号函数 $sgn(t)=\begin{cases}
    -1&t<0\\
    1&t>0\\
\end{cases}$ 的傅立叶变换是 $\dfrac{1}{i\omega}$

$$
\boxed{\mathcal{F}[sgn(t)]=\frac{1}{i\omega}}
$$

:::tip
求傅里叶正变换并不好算，可以考虑逆变换证明
:::

$$
\mathcal{F}^{-1}(\frac{1}{i\omega})=\frac{1}{2\pi}\int_{-\infty}^{+\infty}\frac{1}{i\omega}e^{i\omega t}d\omega\\[10bp]
=\frac{1}{\pi}\int_{-\infty}^{+\infty}\frac{\cos\omega t+i\sin\omega t}{i\omega}d\omega\\
$$
后半个sin相关的奇函数积分为0

遇到狄利克雷积分 $\int_0^{+\infty}\frac{sin ax}{x}dx=\frac{\pi}{2}$，利用留数定理就行

### 越阶函数的傅里叶变换

越阶函数$u(t)=\begin{cases}
    0&t<0\\
    1&t>0\\
\end{cases}$的傅立叶变换是 $\pi\delta(\omega)+\dfrac{1}{i\omega}$

$$
\boxed{\mathcal{F}[u(t)]=\pi\delta(\omega)+\frac{1}{i\omega}}
$$

:::tip
把 $u(t)$ 和符号函数结合，$u(t)=\dfrac{1+sgn(t)}{2}$ ,利用符号函数的傅里叶变换
:::

### 正弦函数和余弦函数的傅里叶变换

$f(t)=\sin \omega t,f(t)=\cos\omega t$ 的傅里叶变换

$$
\boxed{\begin{aligned}
\mathcal{F}[\sin \omega_0 t]&=i\pi\{\delta(\omega+\omega_0)-\delta(\omega-\omega_0)\}\\
\mathcal{F}[\cos \omega_0 t]&=\pi\{\delta(\omega+\omega_0)+\delta(\omega-\omega_0)\}
\end{aligned}}
$$

:::tip
拆成e的形式，然后找 $e^{i\omega t}$ 的傅里叶变换
:::

## 傅里叶变换的性质

记 $f(t)$ 的傅里叶变换是 $F(\omega)$

1. 线性性：
    $$
    \mathcal{F}[k_1f(t)+k_2g(t)]=\mathcal{F}[k_1f(t)]+\mathcal{F}[k_2g(t)]
    $$

2. 对称性：
    交换自变量，有
    $$
    \boxed{\mathcal{F}\left[F(t)\right]=2\pi f(-\omega)}
    $$
3. 放缩性质：
    $$
    \boxed{\mathcal{F}\left[f(at)\right]=\frac{1}{|a|}\mathcal{F}\left(\frac{\omega}{a}\right),\;\;a\neq 0}
    $$
    :::note[简单证一下：]
    $$
    \mathcal{F}\left[f(at)\right]=\int_{-\infty}^{+\infty}f(at)e^{-i\omega t}dt\\
    $$
    a>0时，令 $at=\tilde{t}$, 则有 $t=\dfrac{\tilde{t}}{a}$, $dt=\frac{1}{a}d\tilde{t}$ 代入得
    $$
    =\int_{-\infty}^{+\infty}f(\tilde{t})e^{-i\omega \frac{\tilde{t}}{a}}\frac{1}{a}d\tilde{t}=\frac{1}{|a|}F\left(\frac{\omega}{a}\right)
    $$
    a<0时，注意积分上下限变为 $(+\infty\to-\infty)$ ，在外面加负号调回来，就得到了 $|a|$ 。
    :::

4. 平移性质：  

    注意 $F(\omega)$ 正负号变化是跟 $f(t)$ 反过来的
    $$
    \boxed{\begin{aligned}
    \star\; \mathcal{F}[f(t\pm t_0)]&=e^{\pm i\omega t_0}F(\omega)\\[10pt]
    \mathcal{F}^{-1}[e^{\pm i\omega t_0}F(\omega)]&=f(t\pm t_0)\\[10pt]
    \star\; \mathcal{F}[e^{\pm i\omega_0 t}f(t)]&=F(\omega\mp \omega_0)\\[10pt]
    \mathcal{F}^{-1}[F(\omega\pm\omega_0)]&=e^{\mp i\omega_0 t}f(t)
    \end{aligned}}
    $$
5. 导数性质
    $$
    \boxed{\begin{aligned}
    \mathcal{F}[f^{(n)}(t)]&=i\omega F(\omega)\\[10pt]
    F^{(n)}(\omega)&=\mathcal{F}[(-i t)^nf(t)]
    \end{aligned}}
    $$

    :::note[简单证一下：(以一阶导为例)]

    $$
    \begin{aligned}
    \mathcal{F}[f^{(1)}(t)]&=\int_{-\infty}^{+\infty}e^{-i\omega t}df(t)\\
    &=-\int_{-\infty}^{+\infty}f(t)(-i\omega)e^{-i\omega t}dt\\
    &=i\omega F(\omega)\\
    \end{aligned}
    $$

    $$
    \begin{aligned}
    F^{(1)}(\omega)&=\frac{d}{d\omega}\int_{-\infty}^{+\infty}f(t)e^{-i\omega t}dt\\
    &=\int_{-\infty}^{+\infty}f(t)(-it)e^{-i\omega t}dt\\
    &=\mathcal{F}[-itf(t)]
    \end{aligned}
    $$
    :::
6. 积分乘积性质
    $$
    \boxed{\int_{-\infty}^{+\infty}f_1\cdot {f_2} dt=\frac{1}{2\pi}\int_{-\infty}^{+\infty}F_1\cdot\bar{F_2}d\omega=\frac{1}{2\pi}\int_{-\infty}^{+\infty}\bar{F_1}\cdot F_2 d\omega}
    $$
    特别地，如果 $f_1=f_2$ 得到帕斯威尔定理：

    $$
    \boxed{\int_{-\infty}^{+\infty}|f(t)|^2 dt=\frac{1}{2\pi}\int_{-\infty}^{+\infty}|F(\omega)|^2d\omega}
    $$

    :::note[简单证一下：]
    $$
    f_1=\mathcal{F}^{-1}[F_1]=\frac{1}{2\pi}\int_{-\infty}^{+\infty}F_2e^{i\omega t}d\omega\\
    $$
    求共轭的过程给每一项分别求共轭,积分的时候换一下积分次序
    :::

>eg1 求1：$f(t)=\sin (\omega_0 t)u(t)$ 2: $f(t)=e^{i\omega_0 t}tu(t)$

主要是第二个，方法有很多，可以用对称性，也可以注意到tu(t)求导之后就是 u（t）,或者用放缩也可以，里面成一个i

>eg2 求积分 $I=\int_{-\infty}^{+\infty}(\frac{sin t}{t})^2dt$

:::tip
利用parsevar定理，把 $\frac{sin t}{t}$ 当成 f（t）
:::
