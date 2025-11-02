---
title: 机器学习笔记：贝尔曼方程
published: 2025-11-02
description: '贝尔曼方程的基本概念和推导过程'
image: ''
tags: [RL, 贝尔曼方程]
category: 'RL'
draft: false 
lang: ''
---

## 课本上前两个启发例子总结

1. 对于只产生一条轨迹的策略，回报可以用来评价一个策略的好坏。

2. 对于有多个可能轨迹的策略，回报的期望可以用来评价一个策略的好坏。

第二条引出状态值的概念。

计算回报：根据定义，回报是immediate reward和future reward的和。

有递推：

$$
R_t = r_{t+1} + \gamma R_{t+1}
$$

重要思想：从一个状态出发的回报依赖于从其他状态出发的回报。

## 状态值

我们用随机变量重新描述轨迹：t时刻的轨迹为

$$
\tau = (S_t,A_t,R_{t+1},S_{t+1},A_{t+1},R_{t+2},\ldots)
$$

:::note  
这里的 $R_{t+1}$ 表示在时间 $t$ （状态 $S_t$）采取动作 $A_t$ 后获得的奖励  
:::

这个轨迹的折扣回报也是一个随机变量：

$$
G_t = \underbrace{R_{t+1}}_{\text{即时回报}} + \underbrace{\gamma R_{t+2} + \gamma^2 R_{t+3} + \ldots}_{\text{未来回报}} = \sum_{k=0}^{\infty} \gamma^k R_{t+k+1}
$$

我们可以对 $G_t$ 取条件期望，条件是 $S_t=s$，就得到状态值函数：

$$
v_\pi(s) = \mathbb{E}_\pi[G_t|S_t=s]
$$

:::tip  
当策略唯一，状态值=回报。  
:::

## 贝尔曼方程

贝尔曼方程描述了所有状态值之间的关系。

$$
\begin{aligned}
G_t &= R_{t+1} + \gamma G_{t+1}\\
v_\pi(s) &= \mathbb{E}[G_t|S_t=s]\\
&= \mathbb{E}[R_{t+1} + \gamma G_{t+1}|S_t=s]\\
\end{aligned}
$$

根据期望的线性性质：

$$
v_\pi(s) = \underbrace{\mathbb{E}[R_{t+1}|S_t=s]}_{\text{即时奖励期望}} + \gamma \underbrace{\mathbb{E}[G_{t+1}|S_t=s]}_{\text{未来奖励期望}}
$$

对于即时奖励期望：由全期望公式可得

$$
\mathbb{E}[R_{t+1}|S_t=s] = \sum_{a\in\mathcal{A(s_t)}} \pi(a|s) \sum_{r\in\mathcal{R_{t+1}}} r \cdot p(r|s,a)
$$

对于未来奖励期望：由马尔可夫性，和过去的状态动作无关，只和下一个状态有关

$$
\begin{aligned}
\mathbb{E}[G_{t+1}|S_t=s] &= \sum_{s'\in\mathcal{S}} \mathbb{E}[G_{t+1}|S_{t+1}=s',S_t=s] \cdot p(s'|s)\\
&= \sum_{s'\in\mathcal{S}} \mathbb{E}[G_{t+1}|S_{t+1}=s'] \cdot p(s'|s)\\
&= \sum_{s'\in\mathcal{S}} v_\pi(s') \cdot\sum_{a\in\mathcal{A(s)}}  p(s'|s,a)\cdot \pi(a|s)
\end{aligned}
$$

综上，贝尔曼方程为：

$$
v_\pi(s) = \sum_{a\in\mathcal{A(s)}} \pi(a|s) \sum_{r\in\mathcal{R_{t+1}}} r \cdot p(r|s,a) + \gamma \sum_{s'\in\mathcal{S}} v_\pi(s') \cdot\sum_{a\in\mathcal{A(s)}}  p(s'|s,a)\cdot \pi(a|s)
$$

其中，未知量是 $v_\pi(s)$，用来描述策略

已知量是策略 $\pi(a|s)$

模型部分：奖励概率 $p(r|s,a)$，状态转移概率 $p(s'|s,a)$。可有可无
