---
title: 期望值以及常见分布的期望
published: 2025-10-23
description: '随机变量的期望'
image: ''
tags: [概率论, 随机变量, 期望值]
category: '概率论与数理统计'
draft: false 
lang: ''
---

## 离散随机变量的期望

离散随机变量的期望就是其所有可能取值的加权平均值，权重是各取值的概率。设随机变量 $X$ 取值为 $x_1, x_2, \ldots, x_n$，对应的概率为 $p_1, p_2, \ldots, p_n$，则期望值 $E(X)$ 定义为：

$$
E(X) = \sum_{i=1}^{+\infty} x_i p_i
$$

这个形式和级数很像，当级数收敛时期望才有意义

### 0-1 分布的期望

分布列：

| $X$   |  1  | 0     |
| :-: | --- | :---: |
| $P(X)$ | $p$   | $1-p$ |

期望：

$$
\boxed{\mathbb{E}(X) = 1 \cdot p + 0 \cdot (1-p) = p}
$$

### 二项分布的期望

$$
X\sim B(n,p)
$$

分布列：
$$
P(x=k)=C_n^k p^k (1-p)^{n-k} \quad k=0,1,2,\ldots,n
$$

期望：

$$
\boxed{\mathbb{E}(X) = np}
$$

:::note
[证明]
:::

$$
\begin{aligned}
\mathbb{E}(X) &= \sum_{k=0}^{n} k C_n^k p^k (1-p)^{n-k} \\
&= \sum_{k=0}^{n}k\cdot\frac{n!}{k!(n-k)!} p^k (1-p)^{n-k}\\
&= \sum_{k=1}^{n} \frac{n(n-1)!}{(k-1)!(n-k)!} p^k (1-p)^{n-k} \\
&= np \sum_{k=1}^{n} \frac{(n-1)!}{(k-1)!(n-k)!} p^{k-1} (1-p)^{(n-1)-(k-1)} \\
&= np \sum_{j=0}^{n-1} C_{n-1}^j p^j (1-p)^{(n-1)-j} \\
&= np (p + (1-p))^{n-1} = np
\end{aligned}
$$

### 泊松分布的期望

$$
X\sim P(\lambda)
$$

分布列：
$$
P(X=k)=\frac{\lambda^k}{k!}e^{-\lambda} \quad k=0,1,2,\ldots
$$

期望：

$$
\boxed{\mathbb{E}(X) = \lambda}
$$

:::tip[助记]  
泊松分布和二项分布存在近似，近似条件是 $n \to \infty$，$p \to 0$，且 $np = \lambda$ 为常数。
:::

:::note
[证明]
:::

$$
\begin{aligned}
\mathbb{E}(X)
&= \sum_{k=1}^{\infty} k \cdot \frac{\lambda^k}{k!} e^{-\lambda} \\
&= \sum_{k=1}^{\infty} \frac{\lambda^k}{(k-1)!} e^{-\lambda} \\
&= \lambda e^{-\lambda} \sum_{k=1}^{\infty} \frac{\lambda^{k-1}}{(k-1)!} \\
&= \lambda e^{-\lambda} \sum_{j=0}^{\infty} \frac{\lambda^j}{j!}\quad\text{级数这一块} \\
&= \lambda e^{-\lambda} e^{\lambda} = \lambda
\end{aligned}
$$

### 超几何分布的期望

$$
X\sim H(N,M,n)
$$

分布列：
$$
P(X=k)=\frac{C_M^k C_{N-M}^{n-k}}{C_N^n} \quad \max(0,n-(N-M)) \leq k \leq \min(n,M)
$$

期望：

$$
\mathbb{E}(X) = n\cdot\frac{M}{N}
$$

:::tip  
就是实验次数乘以成功概率，很像二项分布的期望  
:::

:::note  
[证明]  
:::

设随机变量 $X$ 表示抽到的好球数，定义指示变量：
$$
I_k = \begin{cases}
1, & \text{第 } k \text{ 次抽到好球} \\
0, & \text{第 } k \text{ 次抽到坏球}
\end{cases}
$$

则有：
$$
X = I_1 + I_2 + \cdots + I_n
$$
根据期望的线性性质，有：
$$
\mathbb{E}(X) = \mathbb{E}(I_1) + \mathbb{E}(I_2) + \cdots + \mathbb{E}(I_n)
$$
由于每次抽到好球的概率为 $\frac{M}{N}$，因此：
$$
\mathbb{E}(I_k) = 1 \cdot \frac{M}{N} + 0 \cdot \left(1 - \frac{M}{N}\right) = \frac{M}{N}
$$
所以：
$$
\mathbb{E}(X) = n \cdot \frac{M}{N}
$$

## 连续随机变量的期望

对于连续型随机变量 $X$，其概率密度函数为 $f(x)$，则期望值 $E(X)$ 定义为：

$$
E(X) = \int_{-\infty}^{\infty} x f(x) \, dx
$$

如果该反常积分收敛，则期望存在且有意义。

### 均匀分布的期望

$$
X\sim U(a,b)
$$

概率密度函数：

$$
f(x) = \begin{cases}
\dfrac{1}{b-a}, & a \leq x \leq b \\
0, & \text{otherwise}
\end{cases}
$$

期望：

$$
\boxed{\mathbb{E}(X) = \frac{a+b}{2}}
$$

:::note  
[证明]  
:::

$$
\begin{aligned}
\mathbb{E}(X)
&= \int_{a}^{b} x \cdot \frac{1}{b-a} \, dx \\
&= \frac{1}{b-a} \left[ \frac{x^2}{2} \right]\Big|_{a}^{b} \\
&= \frac{1}{b-a} \left( \frac{b^2 - a^2}{2} \right) \\
&= \frac{b+a}{2}
\end{aligned}
$$

### 指数分布的期望

$$
X\sim \mathrm{Exp}(\lambda)
$$

概率密度函数：

$$
f(x) = \begin{cases}
\lambda e^{-\lambda x}, & x \geq 0 \\
0, & x < 0
\end{cases}
$$

期望：

$$
\boxed{\mathbb{E}(X) = \frac{1}{\lambda}}
$$

:::note  
[证明]  
:::

$$
\begin{aligned}
\mathbb{E}(X)
&= \int_{0}^{\infty} x \lambda e^{-\lambda x} \, dx \\
&= \left[ -x e^{-\lambda x} \right]\Big|_{0}^{\infty} + \int_{0}^{\infty} e^{-\lambda x} \, dx \quad \text{分部积分} \\[5pt]
&= 0 + \left[ -\frac{1}{\lambda} e^{-\lambda x} \right]_{0}^{\infty} \\
&= \frac{1}{\lambda}
\end{aligned}
$$

### 正态分布的期望

$$
X\sim N(\mu, \sigma^2)
$$

概率密度函数：

$$
f(x) = \dfrac{1}{\sigma \sqrt{2\pi}} \exp\left\{-\dfrac{(x-\mu)^2}{2\sigma^2}\right\}, \quad x \in \mathbb{R}
$$

期望：

$$
\boxed{\mathbb{E}(X) = \mu}
$$

:::note  
[证明]  
:::

$$
\begin{aligned}
\mathbb{E}(X)
&= \int_{-\infty}^{\infty} x \cdot \dfrac{1}{\sigma \sqrt{2\pi}} \exp\left\{-\dfrac{(x-\mu)^2}{2\sigma^2}\right\} \, dx \\
&= \int_{-\infty}^{\infty} (y + \mu) \cdot \dfrac{1}{\sigma \sqrt{2\pi}} \exp\left\{-\dfrac{y^2}{2\sigma^2}\right\} \, dy \quad (y = x - \mu) \\[5pt]
&= \mu \int_{-\infty}^{\infty} \dfrac{1}{\sigma \sqrt{2\pi}} \exp\left\{-\dfrac{y^2}{2\sigma^2}\right\} \, dy + \int_{-\infty}^{\infty} y \cdot \dfrac{1}{\sigma \sqrt{2\pi}} \exp\left\{-\dfrac{y^2}{2\sigma^2}\right\} \, dy \\
&= \mu \cdot 1 + 0 \quad \text{(第二项为奇函数积分)} \\
&= \mu
\end{aligned}
$$

### 柯西分布的期望

：：：warning
柯西分布没有定义期望值，因为其积分发散。
：：：

$$
X\sim \mathrm{Cauchy}(x_0, \gamma)
$$

概率密度函数：

$$
f(x) = \frac{1}{\pi \gamma \left[1 + \left(\frac{x - x_0}{\gamma}\right)^2\right]}, \quad x \in \mathbb{R}
$$

期望：

$$
\mathbb{E}(X) \text{ 不存在}
$$

:::note  
[说明]  
柯西分布的尾部较重，导致期望积分发散，因此没有定义期望值。
:::

## 随机变量函数的期望

设 $Y = g(X)$，则 $Y$ 的期望为：

- 对于离散随机变量 $X$：

$$
\mathbb{E}(Y) = \sum_{x} g(x) P(X=x)
$$

- 对于连续随机变量 $X$：

$$
\mathbb{E}(Y) = \int_{-\infty}^{\infty} g(x) f(x) \, dx
$$

其中 $P(X=x)$ 是 $X$ 的分布列，$f(x)$ 是 $X$ 的概率密度函数。

:::tip  
就是把 $x$ 换成 $g(x)$，其他不变  
:::

## 期望的性质

1. 线性性质：
    $$
    \mathbb{E}[aX + b] = a\mathbb{E}[X] + b\\
    \iff \begin{cases}
        \mathbb{E}[X_1+X_2+\cdots+X_n] = \mathbb{E}[X_1] + \mathbb{E}[X_2] + \cdots + \mathbb{E}[X_n]\\[10pt]
        \text{若}X_i\text{相互独立：}\mathbb{E}[X_1X_2\cdots X_n] = \mathbb{E}[X_1]\mathbb{E}[X_2]\cdots \mathbb{E}[X_n] 
    \end{cases}
    $$
