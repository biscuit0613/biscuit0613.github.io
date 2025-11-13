---
title: 强化学习笔记：马尔可夫决策过程（MDP）
published: 2025-11-02
description: '马尔可夫性，马尔可夫决策过程（MDP）的基本概念介绍'
image: ''
tags: [RL, 马尔可夫决策过程]
category: 'RL'
draft: false 
lang: ''
---

## MDP(这一部分直接参考书本内容)

马尔可夫决策过程（Markov Decision Process, MDP）是强化学习中的一个重要概念，用于描述智能体与环境的交互过程。MDP由以下几个基本要素组成：

1. **状态空间（State Space）** $\mathcal{S}$：表示环境中所有可能状态的集合。

2. **动作空间（Action Space）** $\mathcal{A}$：表示智能体在各个状态下可以执行的所有可能动作的集合。
3. **奖励集合** $\mathcal{R}$：表示智能体在$(s,a)$可能获得的奖励值的集合。
4. **状态转移概率（State Transition Probability）** $p(s'|s,a)$：表示在状态 $s$ 下执行动作 $a$ 后，转移到下一个状态 $s'$ 的概率。满足 $\sum_{s'\in\mathcal{S}} p(s'|s,a) = 1$。
5. **奖励概率** $p(r|s,a)$：表示在状态 $s$ 下执行动作 $a$ 后，获得奖励 $r$ 的概率。满足 $\sum_{r\in\mathcal{R(s,a)}} p(r|s,a) = 1$。
6. **策略（Policy）**： $\pi(a|s)$：表示在状态 $s$ 下，选择动作 $a$ 的概率。满足 $\sum_{a\in\mathcal{A(s)}} \pi(a|s) = 1$。

### 马尔可夫性（Markov Property）

马尔可夫性：下一个状态仅依赖于当前状态和动作，而与过去的状态和动作无关。

在MDP中，马尔可夫性意味着状态转移概率和奖励概率只依赖于当前状态和动作：

$$
p(s_{t+1}|s_t,a_t) = p(s_{t+1} |  s_t, a_t,s_{t-1},a_{t-1},\ldots)\\
p(r_{t+1}|s_t,a_t) = p(r_{t+1} | s_t, a_t,s_{t-1},a_{t-1},\ldots)
$$
