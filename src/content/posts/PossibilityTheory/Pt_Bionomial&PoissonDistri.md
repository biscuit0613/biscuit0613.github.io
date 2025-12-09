---
title: 二项分布与泊松分布
published: 2025-08-20
description: '二项分布与泊松分布'
tags: [概率论,二项分布]
category: '概率论与数理统计'
author: biscuit
draft: false
---


## 二项分布

:::note[前情提要：伯努利实验]
在随机试验的条件下，结果只有两种可能:发生或者不发生每次试验的结果之间相互独立，互不干扰。
：：：

定义：在重复 $n$ 次独立的伯努利试验中，探究 $n$ 次试验中成功的次数 $k$ 。当试验次数为1时，二项分布服从0-1分布。
若随机变量 $X$ 服从参数为 $(n, p)$ 的二项分布,
记作：$X \sim \mathrm{Bin}(n, p)$

### 二项分布的分布律

$$
P(X=k)=\binom{n}{k}\,p^{k}(1-p)^{\,n-k},\quad k=0,1,2,\ldots,n\\[5bp]
\text{其中}\displaystyle \binom{n}{k}＝C_n^k=\frac{n!}{k!(n-k)!}
$$
这个组合数表示在n次实验中选k次成功。

### 期望与方差

$$
\mathbb{E}[X]=np\\
\mathrm{Var}(X)=np(1-p)
$$

## 泊松分布

### 泊松分布的分布律

$$
P\{X=k\}=\frac{\lambda^k e^{-\lambda}}{k!}, k=0,1,2,…
$$

其中 $\lambda>0$ 称随机变量 $X$ 服从参数为 $\lambda$ 的泊松分布，记作 $X\sim\pi(\lambda)$

## 泊松逼近定理

如果 $n\to \infty,p\to 0,np=\lambda$ 保持为正常数，则

$$
\frac{n!}{k!(n-k)!}p^{k}(1-p)^{\,n-k}\to \frac{\lambda^k e^{-\lambda}}{k!}, k=0,1,2,…
$$
在实际计算中，往往只需要 $n\geq10,p\leq0.1$ 即可

如果从失败的角度考虑，成功 $k$ 次 $\Leftrightarrow$ 失败 $n-k$ 次，这两个概率应该相等，实际计算中 $n\geq10,p\geq0.9$
$$
\frac{n!}{k!(n-k)!}p^{k}(1-p)^{\,n-k}\to \frac{[n(1-p)]^{n-k} e^{-n(1-p)}}{(n-k)!}, k=0,1,2,…\\[5bp]
\text{这里}\lambda=n(1-p),k\text{换成}n-k
$$
$0.1\leq p\leq 0.9$时可以采用正态近似

+ n越大，p越小，近似效果越好

eg: 2500人参保，保险费12元。出事了赔2000元，出事的概率是0.002,求保险公司亏本的概率？

:::tip[solution]
每个人只有可能出意外或不出意外，这是一个重复2500次的伯努利实验

设事件A：保险公司亏本，X为出意外的人数

$$
P(A)=P(X\geq15)=\sum_{k=16}^{2500}C_{2500}^k0.998^{(2500-k)}\\
n=2500,p=0.002,\lambda=np=5\,\text{可以用泊松分布近似}
\approx\sum_{k=16}^2500\frac{5^k}{k!}e^{-5}\\
=\sum_{k=16}^{\infin}\frac{5^k}{k!}e^{-5}-\sum_{k=2501}^{\infin}\frac{5^k}{k!}e^{-5}\\
\approx 0.00007-0=0.00007
$$

:::
