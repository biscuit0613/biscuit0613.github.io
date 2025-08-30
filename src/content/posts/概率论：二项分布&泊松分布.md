---
title: 概率论：二项分布与泊松分布
published: 2025-08-20
description: 二项分布与泊松分布
tags: [概率论，二项分布]
category: 概率论
author: biscuit
draft: false
---


## 二项分布

**伯努利试验**：
在随机试验的条件下，结果只有两种可能:
发生或者不发生
每次试验的结果之间相互独立，互不干扰。

**二项分布**：
定义：在重复n次独立的伯努利试验中，探究n次试验中成功的次数r。当试验次数为1时，二项分布服从0-1分布。
若随机变量 X 服从参数为 (n, p\) 的二项分布,
记作：$X \sim \mathrm{Bin}(n, p)$

**分布律**
$$
P(X=k)=\binom{n}{k}\,p^{k}(1-p)^{\,n-k},\qquad k=0,1,2,\ldots,n
$$

$$
其中 \displaystyle \binom{n}{k}=\frac{n!}{k!(n-k)!}。
$$

**期望与方差**  
$$
\mathbb{E}[X]=np
$$
$$
\mathrm{Var}(X)=np(1-p)
$$

## 泊松分布

**分布律**
$$
P\{X=k\}=\frac{\lambda^k e^{-\lambda}}{k!}, k=0,1,2,…
$$
其中λ>0<br>
称随机变量X服从参数为λ的泊松分布，记作
$X\sim\pi(\lambda)$


## 泊松逼近定理

如果$n\to \infin,p\to 0,np=\lambda$保持为正常数，则
$$
\frac{n!}{k!(n-k)!}p^{k}(1-p)^{\,n-k}\to \frac{\lambda^k e^{-\lambda}}{k!}, k=0,1,2,…
$$
在实际计算中，往往只需要$n\geq10,p\leq0.1$即可

如果从失败的角度考虑，成功k次$\Leftrightarrow$失败$n-k$次，这两个概率应该相等，实际计算中$n\geq10,p\geq0.9$
$$
\frac{n!}{k!(n-k)!}p^{k}(1-p)^{\,n-k}\to \frac{[n(1-p)]^{n-k} e^{-n(1-p)}}{(n-k)!}, k=0,1,2,…\\[5bp]
\text{这里}\lambda=n(1-p),k\text{换成}n-k
$$
$0.1\leq p\leq 0.9$时可以采用正态近似

+ n越大，p越小，近似效果越好
