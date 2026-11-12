---
title: 强化学习（三）：被动强化学习与策略评价
published: 2025-11-02
description: '模型未知、策略固定时，如何仅从交互样本估计价值——蒙特卡洛法与时序差分 TD(0)'
image: ''
tags: [RL, 被动强化学习, 蒙特卡洛, 时序差分]
category: '11-强化学习'
draft: false
order: 3
lang: ''
---

从这里开始进入**无模型（model-free）** 方法。本篇先处理最简单的情形——**被动强化学习**。

被动强化学习的设定是：**奖励和状态转移不知道，策略 $\pi$ 已经给定并固定不变，学习的目标不是改进策略，而是评价它**——估计该策略下的 $V^\pi(s)$ 或 $Q^\pi(s,a)$。

> **关键：被动 RL 里不存在"探索与利用"的矛盾。** 策略已经定死，智能体不需要自己决定采集什么数据——它只是照着 $\pi$ 走，从走出来的轨迹里估计价值。这个矛盾要到下一篇主动 RL 才会出现。

从数学模型的角度看，贝尔曼方程里，无论是哪一种形式，转移概率 $p(s'\mid s,a)$ 和奖励分布 $p(r\mid s,a)$ **未知** 时都无法求解析解。

$$
\begin{aligned}
V^\pi(s)
&=\sum_a\pi(a\mid s)\Big[R(s,a)+\gamma\sum_{s'\in \mathcal{S}}p(s'\mid s,a)V^\pi(s')\Big]
& &\text{① 平均奖励（正文采用）}\\
&=\sum_a\pi(a\mid s)\sum_{s'\in\mathcal{S}}p(s'\mid s,a)\big[R(s,a,s')+\gamma V^\pi(s')\big]
& &\text{② 转移绑定 ，奖励和s'有关}\\
&=\sum_a\pi(a\mid s)\sum_{s'\in\mathcal{S}}\sum_{r\in \mathcal{R}(s,a)}p(r,s'\mid s,a)\big[r+\gamma V^\pi(s')\big]
& &\text{③ 联合分布（最一般）}
\end{aligned}
$$

智能体只能通过一条条交互样本 $(s_0,a_0,r_0,s_1,a_1,r_1,s_2,\dots)$ 去学习。

## 蒙特卡洛法：等一整个回合结束

**蒙特卡洛（Monte Carlo, MC）** 方法的思路最直接：从状态 $s$ 出发，按固定策略一直走到回合结束，得到一条完整轨迹，就能算出**真实的采样回报** $G_t$。多走几次，用这些 $G_t$ 的平均作为 $V^\pi(s)$ 的估计。假设总共走了 $N$ 条轨迹，得到 $N$ 个回报样本 $G_t^{(1)},G_t^{(2)},\dots,G_t^{(N)}$，则

$$
V^{\pi}_{(i)}(s)\approx \frac{1}{N}\sum_{i=1}^N G_t^{(i)}
$$

写成增量更新的形式（每来一个新样本 $G_t$ 就修正一次旧估计）：

$$
\begin{aligned}
V^{\pi}_{(i)}(s)&\approx \frac{1}{N}(G_t^{(i)}+(N-1)V^{\pi}_{(i-1)}(s))\\
&=\frac{1}{N}(G_t^{(i)}+NV^{\pi}_{(i-1)}(s)-V^{\pi}_{(i-1)}(s))\\
&=V^{\pi}_{(i-1)}(s)+\frac{1}{N}\left[G_t^{(i)}-V^{\pi}_{(i-1)}(s)\right]
\end{aligned}
$$

- 第一项 $V^{\pi}_{(i-1)}(s)$ 是历史均值（旧估计）；
- 第二项 $\frac{1}{N}\left[G_t^{(i)}-V^{\pi}_{(i-1)}(s)\right]$ 是新样本与旧估计的偏差。
- $\frac{1}{N}$ 可以看作某种学习率，但是用 1/N 会导致学习率随样本数 N 越来越小，收敛速度变慢。更常用的做法是用一个固定的学习率 $\alpha\in(0,1]$，于是更新公式变为

$$
\boxed{V^{\pi}(s_t)\leftarrow V^{\pi}(s_t)+\alpha\left[G_t-V^{\pi}(s_t)\right]}
$$

其中 $\alpha\in(0,1]$ 是学习率，控制每个样本对旧估计的影响。

MC 的特点：

- **不需要环境模型**，也不使用任何价值估计来构造目标；
- 用的是**真实完整回报** $G_t$，因此估计是无偏的；
- 但是样本之间的回报差距可能很大，故估计的方差较大。
- **必须等回合结束**才能更新，换句话说，必须有终止状态

## 时序差分 TD(0)：只等一步

蒙特卡洛必须等回合结束才知道 $G_t$，这在长回合或持续任务中很不方便。

TD（Temporal Difference，时序差分）并不是某一个特定算法，而是一种利用当前奖励和后续状态的估计，来更新当前估计的学习思想。——也就是**自举（bootstrapping）**。

他的通式可以表示成：

$$
\text{Estimate}_{\text{new}}(s)\leftarrow \text{Estimate}_{\text{old}}(s)+\alpha\big[\underbrace{\text{TD-Target}-\text{Estimate}_{\text{old}}(s)}_{\text{TD 误差}}\big]
$$

:::tip

采用TD思想的算法有很多，例如这里的TD(0)（一步时序差分）、TD(λ)（多步时序差分）、SARSA、Q-learning、DQN 等等。它们的共同点是：**用后继状态的估计来更新当前状态的估计**。他们的区别在于：更新什么、TD-Target 怎么构造、下一状态的价值怎么计算。

:::

待更新的估计是 $V^\pi(s_t)$，走一步拿到 $(r_t,s_{t+1})$ ,下面这个约等号表示期望意义上相等

$$
G_t=r_t+\gamma G_{t+1}\ \approx\ r_t+\gamma V^{\pi}(s_{t+1}).
$$

于是不必等回合结束， 就能构造更新目标：

$$
Y_t^{\mathrm{TD}}=r_t+\gamma V^{\pi}(s_{t+1}),
$$

$$
\boxed{\,V^{\pi}(s_t)\leftarrow V^{\pi}(s_t)+\alpha\big[\underbrace{r_t+\gamma V^{\pi}(s_{t+1})-V^{\pi}(s_t)}_{\text{TD 误差 }\delta_t}\big]\,}
$$

如果 $s_{t+1}$ 是终止状态，目标就退化为 $Y_t^{\mathrm{TD}}=r_t$，不再加未来价值项。

### TD 目标

表示经过一步真实交互以后，对当前状态价值得到的一个新的目标估计

$$
Y_t^{\mathrm{TD}}=r_t+\gamma V^{\pi}(s_{t+1}).
$$

### TD 误差

$$
\delta_t=r_t+\gamma V^{\pi}(s_{t+1})-V^{\pi}(s_t).
$$

它衡量"新的目标估计（包含一步实际结果与未来价值）"与"原来的价值预期"之间的差距：

- $\delta_t>0$：实际比预期好，应该抬高 $V^{\pi}(s_t)$；
- $\delta_t<0$：实际比预期差，应该压低 $V^{\pi}(s_t)$。

## 蒙特卡洛 vs TD(0)

两者都不需要模型，区别在于**用什么作为更新目标、以及要不要等回合结束**：

| 对比项 | 蒙特卡洛 (MC) | 时序差分 TD(0) |
| --- | --- | --- |
| 更新目标 | 真实完整回报 $G_t$ | 一步自举估计 $r_t+\gamma V^{\pi}(s_{t+1})$ |
| 需要等回合结束吗 | 需要 | 不需要，每步可更新 |
| 是否需要模型 $P,R$ | 不需要 | 不需要 |
| 是否自举 | 否 | 是 |
| 偏差 / 方差 | 无偏，但方差大 | 有偏，但方差小 |

MC 和 TD 的更新都是

$$
V(S_t)\leftarrow V(S_t)+\alpha\left[\text{目标}-V(S_t)\right],
$$

只是"目标"分别取真实回报 $G_t$ 和自举估计 $R_t+\gamma V(S_{t+1})$。

被动强化学习解决了"模型未知时如何评价一个固定策略"的问题：

$$
\text{固定策略 }\pi
\longrightarrow \text{采样轨迹}
\longrightarrow
\begin{cases}
\text{MC：用完整回报 }G_t\\
\text{TD：用一步自举 }R_t+\gamma V^{\pi}(S_{t+1})
\end{cases}
\longrightarrow \hat V^\pi.
$$

但被动 RL 有一个根本局限：**它只能告诉你"当前策略值多少分"，不能告诉你"该怎么改进策略"。** 如果这个策略本身很差，评价得再准也没用。

要真正学到好策略，就必须让策略从固定变成"边交互边改进"——这就进入[主动强化学习](./RL_ActiveRL)：策略不再固定，探索与利用的矛盾也随之登场，并由此得到 SARSA 与 Q-learning 两种经典算法。
