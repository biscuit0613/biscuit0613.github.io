---
title: 2维随机变量及其分布 习题
published: 2025-10-16
description: ''
image: ''
tags: [概率论,多维随机变量]
category: '概率论与数理统计'
draft: false 
lang: ''
---

eg1:设
$$
f(x,y)=\begin{cases}
    e^{-x-y}&x>0,y>0\\
    0&\text{others}
\end{cases}
$$
判断独立性

$$
\begin{alignedat}{2}
f_X(x)&=\int_{-\infty}^{+\infty}f(x,y)dy\\
&=\begin{cases}
    \int_0^{=+\infty}e^(-x-y)dy;&x>0\\
    0&x\leq 0\\
\end{cases}\\
&=\begin{cases}
    e^{-x}&x>0\\
    0&x\leq 0
\end{cases}\\
&\text{由对称性}\\
f_Y{y}=\begin{cases}
    e^{-y}&y>0\\
    0&y\leq 0\\
\end{cases}\\
＆\text{经检验，独立}
\end{alignedat}
$$

eg2: 设X，Y在G上服从均匀分布，$G=\{(x,y)|x\in(0,4),y<\frac{1}{4}x\}$

$$
S(G)=2,\text{联合概率密度：}f(x,y)=\begin{cases}
    \frac{1}{2}&\in G\\
    0&\notin G
\end{cases}\\
f_X(x)=\begin{cases}
    \int_0^{\frac{x}{4}}\frac{1}{2}dy=\frac{x}{8} & x\in(0,4),0<y<\frac{x}{4}\\[8bp]
    0 & \text{其他}
\end{cases}\\[5bp]
f_Y(y)=\begin{cases}
    \int_{4y}^4\frac{1}{2}dx=2-2y & 0\leq y\leq 1\\[8bp]
    0 & \text{其他}
\end{cases}\\[5bp]
\text{显然，不独立}
$$

:::tip  
联合支撑集的区间不是矩形，必然不独立

如果独立，则联合概率密度(或分布函数)能够分解成含有x,y的因子的乘积  
:::

eg3: $(X,Y)~N(\mu_1,\mu_2,\sigma_1^2 ,\sigma_2^2,\rho)$ 求证 $X,Y$ 相互独立 $\iff\rho=0$

当$X,Y$ 相互独立时
$$
f(x,y)=\frac{1}{2\pi\sigma_1\sigma_2\sqrt{1-\rho^2}}\operatorname{exp}\left\{-\frac{1}{2(1-\rho^2)}\left[\frac{(x-\mu_1)^2}{\sigma_1^2}-2\rho\frac{x-\mu_1}{\sigma_1}\frac{y-\mu_2}{\sigma_2}+\frac{(y-\mu_2)^2}{\sigma_2^2}\right]\right\}\\
$$

当 $\rho=0$

$$
\begin{aligned}
f(x,y)&=\frac{1}{2\pi\sigma_1\sigma_2}\operatorname{exp}\left\{-\frac{1}{2}\left[\frac{(x-\mu_1)^2}{\sigma_1^2}+\frac{(y-\mu_2)^2}{\sigma_2^2}\right]\right\}\\[8bp]
&=\frac{1}{\sqrt{2\pi}\sigma_1}exp\left\{-\dfrac{(x-\mu_1)^2}{2\sigma_1^2}\right\} \cdot \frac{1}{\sqrt{2\pi}\sigma_2}exp\left\{-\dfrac{(y-\mu_2)^2}{2\sigma_2^2}\right\}\\[8bp]
&=f_X(x)\cdot f_Y(y)
\end{aligned}
$$

必要性取最大值点带特值证明即可
