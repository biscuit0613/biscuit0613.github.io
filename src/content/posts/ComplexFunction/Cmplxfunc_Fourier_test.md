---
title: Fourier变换的考试速通版
published: 2025-11-13
description: '变换对照表+性质速记'
image: ''
tags: [傅立叶变换]
category: '复变函数'
draft: false 
lang: ''
---

## 傅里叶变换对照表

| 原函数 $f(t)$ | 傅里叶变换 $F(\omega) = \mathcal{F}\{f(t)\}$ |注释|
|:------------------:|:--------------------------------------------:|:------------------:|
| $1$                | $2\pi \delta(\omega)$      |常数|
| $e^{i\omega_0t}$          | $2\pi \delta(\omega - \omega_0)$|指数函数|
| $\delta(t)$     | $1$  |冲激函数|
| $\cos(\omega_0t)$        | $\pi[\delta(\omega - \omega_0) + \delta(\omega + \omega_0)]$     |余弦函数|
| $\sin(\omega_0t)$        | $i\pi[\delta(\omega + \omega_0) - \delta(\omega - \omega_0)]$ |正弦函数|
| $u(t)$         | $\pi \delta(\omega) + \dfrac{1}{i\omega}$ |单位阶跃函数的变换|
| $e^{-\beta t}u(t)$   | $\dfrac{1}{\beta + i\omega}$ |指数衰减，$\beta>0$，$u(t)$ 用来限制 $t > 0$|
| $e^{-a\|t\|}$ | $\dfrac{2a}{a^2+\omega^2}$ | 双边衰减，$a>0$ |
| $t^n e^{-at}u(t)$ | $\dfrac{n!}{(a + i\omega)^{n+1}}$ |乘以$t^n$，对单边的n阶导（抹掉i），$a>0$|
| $e^{-t^2/2}$ | $\sqrt{2\pi} e^{-\omega^2/2}$ |高斯函数|
| $Ee^{-\beta t^2}$ | $E\sqrt{\dfrac{\pi}{\beta}} e^{-\omega^2/(4\beta)}$ |钟形脉冲，$\beta>0$|
|$\begin{cases}\dfrac{2E}{\tau}(t+\dfrac{\tau}{2}) & 0<t < \dfrac{\tau}{2}\\[6pt]-\dfrac{2E}{\tau}(t+\dfrac{\tau}{2}) & -\dfrac{\tau}{2}<t<0\\[6pt]0 & t > \|\dfrac{\tau}{2}\|\end{cases}$| $\dfrac{8E}{\tau\omega^2}\cdot\sin^2(\omega \tau/4)$ |三角形函数|
| $\begin{cases}E & t < \|\dfrac{\tau}{2}\|\\[6pt]0 & t > \|\dfrac{\tau}{2}\|\end{cases}$ | $2E \cdot \dfrac{(\omega \tau/2)}{\omega}$ |矩形函数|
| $sgn(t)$ | $\dfrac{2}{i\omega}$ |符号函数|

## 傅里叶变换的性质

1. 线性性质：

   $$
   \mathcal{F}\{a f(t) + b g(t)\} = a F(\omega) + b G(\omega)
   $$

2. 对称性：

   $$
   \mathcal{F}\{F(t)\} = 2\pi f(-\omega)
   $$

   $$
   \mathcal{F}\{f(\omega)\} = \frac{1}{2\pi} F(-t)
   $$

3. 平移性质：(动t)

   $$
   \mathcal{F}\{f(t \pm t_0)\} = e^{\pm i\omega t_0} F(\omega)
   $$

4. 调制性质：（动ω）

   $$
   \mathcal{F}\{e^{\mp i\omega_0 t} f(t)\} = F(\omega \pm \omega_0)
   $$
   推论：
   $$
   \mathcal{F}\{\cos(\omega_0 t) f(t)\} = \frac{1}{2}[F(\omega - \omega_0) + F(\omega + \omega_0)]\\[6pt]
   \mathcal{F}\{\sin(\omega_0 t) f(t)\} = \frac{1}{2i}[F(\omega - \omega_0) - F(\omega + \omega_0)]
   $$

5. 微分性质：

   $$
   \mathcal{F}\left\{f^{(n)}(t)\right\} = (i\omega)^n F(\omega)
   $$

   $$
   \mathcal{F}^{-1}\{F^{(n)}(\omega)\} = (-it)^n f(t)
   $$

6. 积分性质：

   $$
   \mathcal{F}\left\{\int_{-\infty}^{t} f(\tau) d\tau\right\} = \frac{F(\omega)}{i\omega} + \pi F(0) \delta(\omega)
   $$

7. 时间缩放性质：

   $$
   \mathcal{F}\{f(at)\} = \frac{1}{|a|} F\left(\frac{\omega}{a}\right)
   $$

8. 卷积定理：

   乘积-> $\frac{1}{2\pi}$ 卷积
   $$
   \mathcal{F}\{f(t)\cdot g(t)\} = \frac{1}{2\pi} F(\omega) * G(\omega)
   $$

   卷积-> 乘积
   $$
   \mathcal{F}\{f(t) * g(t)\} = F(\omega)\cdot G(\omega)
   $$

   其中卷积定义为：

   $$
   (f * g)(t) = \int_{-\infty}^{\infty} f(\tau) g(t - \tau) d\tau
   $$

9. Parseval定理：

   $$
   \int_{-\infty}^{\infty} |f(t)|^2 dt = \frac{1}{2\pi} \int_{-\infty}^{\infty} |F(\omega)|^2 d\omega
   $$

10. 双重积分定理：

   $$
   \int_{-\infty}^{\infty} f(t) g(t) dt =  \int_{-\infty}^{\infty} F(\omega) \overline{G(\omega)} d\omega=\int_{-\infty}^{\infty} \overline{F(\omega)} G(\omega) d\omega
   $$

## 傅立叶+微积分方程

利用傅里叶变换可以将微分方程转化为代数方程，从而简化求解过程。

利用的是微分性质：
$$
\mathcal{F}\{f^{(n)}(t)\} = (i\omega)^n F(\omega)
$$

和积分性质：
$$
\mathcal{F}\left\{\int_{-\infty}^{t} f(\tau) d\tau\right\} = \frac{F(\omega)}{i\omega} + \pi F(0) \delta(\omega)
$$
