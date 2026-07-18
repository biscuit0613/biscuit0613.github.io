---
title: 复变函数：拉普拉斯变换
published: 2025-10-22
description: '复变函数中的拉普拉斯变换及其应用'
image: ''
tags: [复变函数, 拉普拉斯变换]
category: '复变函数'
draft: false 
lang: ''
---

学到这已经有点似了，没啥证明了，纯纯背吧

定义式：

$$
\mathcal{L}\{f(t)\} = \int_{0}^{\infty} e^{-st} f(t) \, dt
$$

其中，$s$ 是复变量，$f(t)$ 是定义在 $[0, \infty)$ 上的函数。

## 常见变换对

| 原函数 $f(t)$ | 拉普拉斯变换 $F(s) = \mathcal{L}\{f(t)\}$ |注释|
|:------------------:|:--------------------------------------------:|:------------------:|
| $1$                | $\dfrac{1}{s}$      |常数的变换|
| $t^n$              | $\dfrac{\mathcal{\Gamma(n+1)}}{s^{n+1}}$    |变后上下幂+1，上为gamma下s幂|
| $e^{at}$          | $\dfrac{1}{s-a}$|指数函数的变换|
| $\sin(bt)$        | $\dfrac{b}{s^2 + b^2}$ |$\dfrac{1}{s^2+1}=\mathcal{L}\{\sin(t)\}$|
| $\cos(bt)$        | $\dfrac{s}{s^2 + b^2}$     |$\dfrac{s}{s^2+1}=\mathcal{L}\{\cos(t)\}$|
| $u(t)$         | $\dfrac{1}{s}$ |单位阶跃，其实t>0时为1|
| $\delta(t)$     | $1$  |冲激函数的变换|

关于 $\Gamma$ 函数的定义：

$$
\Gamma(s) = \int_{0}^{\infty} t^{s-1} e^{-t} \, dt
$$

记住递推：

$$
\Gamma(s+1) = s \Gamma(s)
$$

记住特值：

$$
\Gamma(n) = (n-1)!, \quad n \in \mathbb{N}\\[6pt]
\Gamma(1) = 1\;;\Gamma(2)=1\;;\Gamma(3)=2\;;\Gamma(4)=6\\[6pt]
\Gamma\left(\dfrac{1}{2}\right) = \sqrt{\pi}\\
$$

s大时，用斯特林公式：

$$
\Gamma(s) \sim \sqrt{2 \pi / s} (s/e)^s, \quad s \to \infty
$$

## 拉普拉斯变换的性质

1. 线性性质：

   $$
   \mathcal{L}\{a f(t) + b g(t)\} = a \mathcal{L}\{f(t)\} + b \mathcal{L}\{g(t)\}
   $$

2. 微分性质：

    常用于解微分方程：（注意后面变成 $f^{(n)}(0)$ 不是 $F$）
    $$
    \mathcal{L}\{f^{(n)}(t)\} = s^n F(s) - s^{n-1} f(0) - s^{n-2} f'(0) - \cdots - f^{(n-1)}(0)
    $$

    用于计算有 $t$ 的幂的情况：

    $$
    \mathcal{L}\{t^n f(t)\} = (-1)^n  F^{(n)}(s)
    $$

3. 积分性质：

    $$
    \mathcal{L}\left\{\int_{0}^{t} f(\tau) \, d\tau\right\} = \dfrac{F(s)}{s}
    $$
    和
    $$
    \mathcal{L}\left\{\frac{f(t)}{t}\right\} = \int_{s}^{\infty} F(u) \, du
    $$
    还有积分恒等式：
    $$
    \int_{0}^{\infty} \frac{f(t)}{t} \, dt = \int_{0}^{+ \infty} F(s) \, ds
    $$

4. 位移性质：(动s)

    :::warning  
    注意正负号！！！  
    :::

    :::tip  
    相当于把变换核 $e^{-st}$ 变成 $e^{-s t} e^{a t} = e^{-(s - a) t}$，所以有  
    :::

    $$
    \mathcal{L}\{e^{at} f(t)\} = F(s - a)
    $$
    用来处理 $e^{at}$ 和 $f(t)$ 的乘积，算的时候一般是先算 $\mathcal{L}\{f(t)\}=F(s)$ ，再把 $s$ 换成 $s-a$。

    + 这里 $f(t)=1$ 时，得到 $\mathcal{L}\{e^{at}\} = \dfrac{1}{s-a}$

5. 延迟性质：（动t）

    $$
    \mathcal{L}\{f(t-a)\} = e^{-as} F(s), \quad t-a>0
    $$

    有时候写成
    $$
    \mathcal{L}\{u(t-a) f(t-a)\} = e^{-as} F(s)
    $$
    其中，$u(t-a)$ 是单位阶跃函数。相当于限制 $t<a$ 时函数为0。

6. 相似性质：

    $$
    \mathcal{L}\{f(at)\} = \dfrac{1}{a} F\left(\dfrac{s}{a}\right)
    $$

## 终值定理（记一下）

1. 如果 $f(t)$ 在 $[0, \infty)$ 上有界且 $\mathcal{L}\{f(t)\} = F(s)$，则
   $$
   \lim_{t \to \infty} f(t) = \lim_{s \to 0} s F(s)
   $$

2. 如果 $f(t)$ 在 $[0, \infty)$ 上单调递增且 $\mathcal{L}\{f(t)\} = F(s)$，则
   $$
   \lim_{t \to \infty} f(t) = \lim_{s \to 0} s F(s)
   $$

## 拉普拉斯卷积

定义：
$$
(f * g)(t) = \int_{0}^{t} f(\tau) g(t - \tau) \, d\tau
$$

:::tip  
正常卷积：$(f * g)(t) = \int_{-\infty}^{+\infty} f(\tau) g(t - \tau) \, d\tau$ 因为拉普拉斯变换定义域是 $[0, \infty)$，
$$
(f * g)(t) = \int_{-\infty}^{0}\underbrace{f(\tau)}_{0} g(t - \tau) \, d\tau + \int_{0}^{t} f(\tau) g(t - \tau) \, d\tau + \int_{t}^{+\infty} f(\tau) \underbrace{g(t - \tau)}_{0}  \, d\tau
$$

所以卷积积分上下限变成了 $0$ 和 $t$。  
:::

### 拉普拉斯变换下的卷积定理

令 $F(s) = \mathcal{L}\{f(t)\}, G(s) = \mathcal{L}\{g(t)\}$

$$
\mathcal{L}\{f * g\} = F(s) G(s)\\[6pt]
\mathcal{L}^{-1}\{F(s)\cdot G(s)\} = f * g
$$

:::tip  
考点还是逆变换，有时候需要手动拆出来 $F(s)$ 和 $G(s)$ 再反变换。  
:::

## 拉普拉斯变换+微积分方程

拉普拉斯变换可以将微分方程转化为代数方程，从而简化求解过程。

利用的是微分性质：
$$
\mathcal{L}\{f^{(n)}(t)\} = s^n F(s) - s^{n-1} f(0) - s^{n-2} f'(0) - \cdots - f^{(n-1)}(0)
$$

和积分性质：
$$
\mathcal{L}\left\{\int_{0}^{t} f(\tau) \, d\tau\right\} = \dfrac{F(s)}{s}
$$

步骤：

两边同时取拉普拉斯变换，利用线性性质，积分/微分性质，将微积分方程转化为关于 $F(s)$ 的代数方程。

一般题目会给出初始条件 $f(0), f'(0), \ldots$，这样就能直接代入。

解出 $F(s)$ 后，再通过反变换 $\mathcal{L}^{-1}\{F(s)\}$ 得到 $f(t)$。
