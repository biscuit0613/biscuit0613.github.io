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
\frac{1}{2\pi }\int_{-\infty}^{+\infty}\left[\int_{-\infty}^{+\infty}f(\tau)e^{-i\omega\tau}dt\right]e^{i\omega t}d\omega
$$

存在且收敛

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
5. 重要等式
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