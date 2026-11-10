---
title: 深度学习（七）：Actor-Critic 方法
published: 2026-10-25
description: '从REINFORCE的方差问题出发，Baseline与优势函数，Actor-Critic架构（待补充：A2C/A3C/PPO）'
image: ''
tags: []
category: '11-强化学习'
draft: true
lang: ''
---

## 从 REINFORCE 的方差问题说起

REINFORCE 的梯度估计：

$$
\nabla_\theta J(\theta)=\mathbb{E}_{\tau\sim\pi_\theta}\Big[\sum_{t=0}^{T-1}G_t\,\nabla_\theta\log \pi_\theta(a_t|s_t)\Big]
$$

它无偏、方向正确，但方差很大。梯度把 $\log\pi$ 的方向当作"更新方向"，把整条后续回报 $G_t$ 当作"这个方向该走多远"的权重。问题出在权重上：回报高，可能是因为状态本身好，跟动作没关系。

- CartPole 里特别直观：pole 稳稳竖直、还剩 490 步可活的状态，无论推左还是推右，回报都接近 500。于是 REINFORCE 会给这两个动作都打很大的正权重，"好动作"和"坏动作"被一起放大，梯度信号淹没在状态本身的噪声里，方差爆炸，学习极慢。

更一般地，$G_t=\sum_k \gamma^k r_{t+k}$ 把策略随机性、状态转移随机性、奖励随机性沿整条轨迹累积进来，轨迹越长，$\mathrm{Var}(G_t)$ 越大，训练越容易震荡、不易收敛。

## Baseline：减去一个"与动作无关"的参照物

引入基线函数 $b(s)$，将梯度估计改为

$$
\nabla_\theta J(\theta)=\mathbb{E}_{\tau\sim\pi_\theta}\Big[\sum_{t=0}^{T-1}\big(G_t-b(s_t)\big)\nabla_\theta\log \pi_\theta(a_t|s_t)\Big]
$$

- 只要基线函数和策略参数 $\theta$ 无关（不依赖具体动作），减去它不会改变梯度的期望，梯度估计仍然是无偏的：

  $$
  \mathbb{E}_{a\sim\pi_\theta}\big[b(s)\,\nabla_\theta\log\pi_\theta(a\mid s)\big]
  = b(s)\sum_a \pi_\theta(a\mid s)\,\nabla_\theta\log\pi_\theta(a\mid s)
  = b(s)\,\nabla_\theta\underbrace{\sum_a \pi_\theta(a\mid s)}_{=1} = 0
  $$

  这和 REINFORCE 篇里"因果性替换"（$G_0\to G_t$）用的是同一个技巧：与动作无关的项，在期望下梯度贡献为零，去掉只会降方差、不会引偏差。

- 常用的基线是状态价值函数 $V^\pi(s)$。此时权重 $G_t - V(s_t)$ 恰好是**优势函数**

  $$
  A^\pi(s,a)=Q^\pi(s,a)-V^\pi(s)
  $$

  的蒙特卡洛 **无偏** 估计——"这个动作比该状态的 **平均水平** 好多少"。

  固定 $(s_t=s,\ a_t=a)$，对 $G_t - V^\pi(s_t)$ 在"从 $(s,a)$ 出发、之后一直跟随 $\pi$"的轨迹分布下取期望：
   $$
   \mathbb{E}\big[G_t - V^\pi(s_t)\big|s_t=s,a_t=a\big]
   =\underbrace{\mathbb{E}\big[G_t\mid s_t=s,a_t=a\big]}_{=,Q^\pi(s,a)\text{（是
   }Q\text{ 的定义）}}
   -\underbrace{V^\pi(s_t)}_{=,V^\pi(s)\ \text{（条件期望下是常数）}}
   =A^\pi(s,a)
   $$

所以梯度估计可以用优势函数改写成

$$
\nabla_\theta J(\theta)=\mathbb{E}_{\tau\sim\pi_\theta}\Big[\sum_{t=0}^{T-1}A_t^\pi(s_t,a_t)\nabla_\theta\log \pi_\theta(a_t|s_t)\Big]
$$

## Actor-Critic 架构

![alt text](image-ac.png)

- **Actor（策略网络）** $\pi_\theta(a|s)$：负责选动作，沿策略梯度方向更新；
- **Critic（价值网络）** $V_w(s)$：负责给状态打分，学的是 $V^\pi(s)$。做baseline
- **更新方式**：用时序差分（TD）方法学习，损失就是普通的回归误差

$$
L^{\text{VF}}(w)=\mathbb{E}_t\big[(V_w(s_t)-V_t^{\text{target}})^2\big]
$$


### TD 误差：自带一个更好的优势估计

用 MC 回报 $G_t$ 估计优势，方差大的老问题还在。Actor-Critic 的解法是**自举（bootstrapping）**：不等轨迹走完，用 Critic 的当前估计代替"未来"，得到单步 TD 误差

$$
\delta_t = r_{t+1} + \gamma\, V_w(s_{t+1}) - V_w(s_t)
$$

它正好是优势 $A(s_t,a_t)$ 的一个 **有偏的** 估计：$r_{t+1}+\gamma V_w(s_{t+1})$ 近似 $Q(s_t,a_t)$，减去基线 $V_w(s_t)$。把它代进梯度：

$$
\nabla_\theta J(\theta)\approx\mathbb{E}\Big[\sum_t \delta_t\,\nabla_\theta\log\pi_\theta(a_t|s_t)\Big]
$$

- **方差大幅下降**：权重 $\delta_t$ 只含一步奖励的随机性，不再累积整条尾部轨迹；
- **代价是有偏**：$V_w$ 还没学好时估计不准；
- **可以在线更新**：走一步算一步，不必等 episode 结束。

### GAE：在 MC 和 TD 之间连续调档

单步 TD 偏差大，MC 回报方差大——能不能插值？广义优势估计（Generalized Advantage Estimation）给出一个 $\lambda$ 控制的连续谱：

$$
\hat A_t^{\text{GAE}(\gamma,\lambda)}=\sum_{l=0}^{\infty}(\gamma\lambda)^l\,\delta_{t+l}
$$

- $\lambda=0$：退化为单步 TD 误差 $\delta_t$ —— 低方差、有偏；
- $\lambda=1$：退化为 MC 优势 $G_t - v_w(s_t)$ —— 高方差、无偏；
- 中间值：$l$ 越大的项被 $(\gamma\lambda)^l$ 指数压低，偏差和方差折中。

实践中 $\lambda\in[0.9,0.98]$，$\gamma\lambda$ 相当于一个"有效视野"：优势信号主要来自未来 $1/(1-\gamma\lambda)$ 步。GAE 保留了 REINFORCE 的梯度骨架（还是"方向 × 权重"），只是把权重从昂贵的 $G_t$ 换成了可调档的 $\hat A_t$——这也是后来 PPO 直接继承的组件。

## 从 REINFORCE 到 Actor-Critic 的谱系

| | REINFORCE | Actor-Critic (TD) | GAE |
| --- | --- | --- | --- |
| 权重信号 | $G_t$（MC 回报） | $\delta_t$（单步 TD） | $\hat A_t^{\text{GAE}(\lambda)}$ |
| 偏差 | 无偏 | 有偏 | $\lambda$ 调节 |
| 方差 | 大（随轨迹长度累积） | 小 | $\lambda$ 调节 |
| 更新时机 | episode 结束后 | 每步 | 每步 |
| 需要 Critic | 否（或另学 baseline） | 是 | 是 |

（待补充：基于第六讲 PPT 的 A2C/A3C 并行化与同步/异步更新。）
