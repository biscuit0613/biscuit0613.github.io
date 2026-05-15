---
title: 逼近
published: 2026-05-15
description: ''
image: ''
tags: []
category: ''
draft: false 
lang: ''
---

## 函数类

函数类： $C_L^{k,p}(Q),Q\subset \mathbb{R}^n$ 是定义在 $Q$ 上的 $k$ 次**连续可微**函数集合，且其 $p$ 阶导数满足 Lipschitz 条件，Lipschitz 常数为 $L$，即：

$$
\forall x,y \in Q, ||\nabla^p f(x) - \nabla^p f(y)|| \leq L ||x-y||
$$

函数类 $C_L^{k,p}(Q)$ 的性质

1. **包含关系**：如果 $k' > k$，则 $C_L^{k',p}(Q) \subseteq C_L^{k,p}(Q)$。高阶连续可微函数必然也是低阶连续可微函数。
2. 如果 $f_1\in C_{L_{1}}^{k,p}(Q)$ 和 $f_2\in C_{L_{2}}^{k,p}(Q)$，则对于任意标量 $\alpha$ 和 $\beta$，线性组合 $\alpha f_1 + \beta f_2$ 也属于 $C_{L}^{k,p}(Q)$，其中 $L = |\alpha| L_1 + |\beta| L_2$。
3. **闭包性质**：函数类 $C_L^{k,p}(Q)$ 在适当的函数空间中是闭合的。这意味着如果一个函数序列 $\{f_n\}$ 中的每个函数都属于 $C_L^{k,p}(Q)$，并且 $f_n$ 收敛于某个函数 $f$，那么 $f$ 也属于 $C_L^{k,p}(Q)$。
4. **逼近性质**：对于任何函数 $f \in C_L^{k,p}(Q)$，都存在一个多项式函数 $P$，使得 $P$ 在 $Q$ 上以任意小的误差逼近 $f$。具体来说，对于任意 $\epsilon > 0$，存在一个多项式 $P$，使得 $\sup_{x \in Q} |f(x) - P(x)| < \epsilon$。

常见的函数类：$C_{L}^{1,1}(Q)$ 是定义在 $Q$ 上的**Lipschitz连续**函数集合，满足$\forall x,y \in Q, ||\nabla f(x) - \nabla f(y)|| \leq L ||x-y||$。