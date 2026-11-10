---
title: PPO：从策略梯度到 RLHF 的核心优化器
published: 2026-07-15
description: 'PPO（Proximal Policy Optimization）的完整推导、Clip 机制的直观理解，以及在 RLHF 中的应用'
image: ''
tags: [RL, PPO, RLHF, LLM]
category: '11-强化学习'
draft: false 
lang: ''
---

## 前言

PPO（Proximal Policy Optimization）是当前大模型对齐训练中最核心的强化学习算法之一。OpenAI 在 ChatGPT/InstructGPT 中用它做 RLHF 的策略优化，DeepMind 的 Gopher、Anthropic 的 Claude 也都采用了类似思路。

本文从策略梯度出发，逐步推导 PPO 的设计动机与数学形式，最后介绍它在 LLM 对齐训练中的具体应用。

## 一、前导知识：策略梯度与 Actor-Critic（速览）

本文默认前两篇的结论，只做一个最小回顾，推导请移步：

- 策略梯度定理的完整推导 → [深度学习（六）：策略学习与REINFORCE算法](/posts/RL_PolicyLearning/)
- Baseline、优势函数、TD 误差与 GAE → [深度学习（七）：Actor-Critic 方法](/posts/RL_ActorCritic/)

**策略梯度**：目标 $J(\theta)=\mathbb{E}_{\tau\sim\pi_\theta}\big[\sum_t \gamma^t r_t\big]$，梯度为

$$
\nabla_\theta J(\theta) = \mathbb{E}_{\tau \sim \pi_\theta} \left[ \sum_{t=0}^{T} \nabla_\theta \log \pi_\theta(a_t|s_t) \cdot G_t \right]
$$

$\nabla_\theta \log \pi_\theta(a_t|s_t)$ 告诉「如何调整参数让 $a_t$ 的概率变大」，$G_t$ 告诉我们「这个动作到底好不好」，两者相乘即"方向 × 步长"。

**优势函数**：直接用 $G_t$ 当权重方差太大（回报高可能只因状态本身好）。减去基线 $V(s_t)$，权重换成优势

$$
\hat{A}_t = Q(s_t, a_t) - V(s_t)
$$

——"比平均水平好多少"的相对信号，方差小得多。实践中 $\hat A_t$ 由 GAE（$\lambda$ 在 MC 与单步 TD 之间调档）算出，本文直接把它当作现成的输入。

## 二、PPO：Proximal Policy Optimization

### 2.1 问题：策略梯度为什么不稳定？

策略梯度是一个 **on-policy** 算法：每次更新参数后，之前采样的数据就不再来自当前策略了。如果一步更新太大，新策略和老策略差异巨大，那么：

1. 老数据完全不能用了（重要性采样失效）
2. 策略可能直接崩掉，再也恢复不过来


### 2.2 重要性采样与替代目标

为了解决数据复用问题，我们用**重要性采样**（Importance Sampling）：

$$
\mathbb{E}_{x \sim p}[f(x)] = \mathbb{E}_{x \sim q}\left[ \frac{p(x)}{q(x)} f(x) \right]
$$

定义概率比：

$$
r_t(\theta) = \frac{\pi_\theta(a_t|s_t)}{\pi_{\theta_{\text{old}}}(a_t|s_t)}
$$

- $\theta_{\text{old}}$：采样时用的「老策略」参数
- $\theta$：正在优化的「新策略」参数
- 当 $\theta = \theta_{\text{old}}$ 时，$r_t = 1$

:::tip
$r_t(\theta) > 1$ 说明新策略比老策略更喜欢这个动作，$r_t(\theta) < 1$ 说明新策略在「压制」这个动作。初始时 $r_t = 1$，表示一视同仁。
:::

替代目标函数为：

$$
L^{\text{CPI}}(\theta) = \mathbb{E}_t \left[ r_t(\theta) \cdot \hat{A}_t \right]
$$

:::note
CPI = Conservative Policy Iteration。这个目标让我们可以用老数据优化新策略。但问题是：$r_t(\theta)$ 可以变得非常大或非常小，如果 $\hat{A}_t$ 也很大，策略更新会失控。
:::

### 2.3 PPO-Clip：核心思想

PPO 的思路简单粗暴：**别让 $r_t(\theta)$ 偏离 1 太远**。用 clip 操作把 $r_t$ 限制在 $[1-\epsilon, 1+\epsilon]$ 范围内（通常 $\epsilon = 0.1$ 或 $0.2$）：

$$
L^{\text{CLIP}}(\theta) = \mathbb{E}_t \left[ \min\left( r_t(\theta) \hat{A}_t, \quad \text{clip}(r_t(\theta), 1-\epsilon, 1+\epsilon) \hat{A}_t \right) \right]
$$

这个公式需要分两种情况理解：

#### 情况一：$\hat{A}_t > 0$（这个动作比平均好）

我们想增大 $\pi_\theta(a_t|s_t)$，即让 $r_t$ 变大。但 clip 限制 $r_t \leq 1+\epsilon$：

$$
\min\left( r_t \hat{A}_t,\; (1+\epsilon) \hat{A}_t \right)
$$

- 如果 $r_t < 1+\epsilon$：取 $r_t \hat{A}_t$，正常增大
- 如果 $r_t \geq 1+\epsilon$：取 $(1+\epsilon) \hat{A}_t$，**不再继续增大**

:::tip
**直觉**：这个动作确实不错，但别上头。即使它再好，概率也别涨太多，防止过拟合到这个动作上，失去探索能力。
:::

#### 情况二：$\hat{A}_t < 0$（这个动作比平均差）

我们想减小 $\pi_\theta(a_t|s_t)$，即让 $r_t$ 变小。但 clip 限制 $r_t \geq 1-\epsilon$：

$$
\min\left( r_t \hat{A}_t,\; (1-\epsilon) \hat{A}_t \right)
$$

由于 $\hat{A}_t < 0$，$(1-\epsilon) \hat{A}_t$ 是更负的值（更小），所以 $\min$ 取 $(1-\epsilon) \hat{A}_t$：

- 如果 $r_t > 1-\epsilon$：取 $(1-\epsilon) \hat{A}_t$，限制惩罚力度
- 如果 $r_t \leq 1-\epsilon$：取 $r_t \hat{A}_t$，但 gradient 为 0（$r_t$ 已被 clip），不再继续惩罚

:::tip
**直觉**：这个动作确实不好，但别把它一巴掌拍死。即使它差，也别把概率压得太低——万一下次环境变了，这个动作可能又有用呢？
:::

### 2.4 完整损失函数

PPO 的完整目标包含三项：

$$
L^{\text{total}}(\theta) = L^{\text{CLIP}}(\theta) - c_1 \cdot L^{\text{VF}}(\theta) + c_2 \cdot S[\pi_\theta]
$$

1. **$L^{\text{CLIP}}$**：策略损失（clipped surrogate objective）
2. **$L^{\text{VF}} = \mathbb{E}_t\left[(V_\theta(s_t) - V_t^{\text{target}})^2\right]$**：Value 损失，训练 critic（Actor-Critic 篇已讲，PPO 中通常与 actor 共享主干网络）
3. **$S[\pi_\theta] = -\sum_a \pi_\theta(a|s) \log \pi_\theta(a|s)$**：熵正则项，鼓励探索

:::tip
Critic 告诉你「这个局面值多少分」，Actor 用 Critic 的信息计算优势然后更新策略。熵正则项防止策略过于确定（比如某个动作概率 99%），保留随机性。
:::

### 2.5 训练流程

```
循环多轮：
  1. 用当前策略 π_θ 采样一批轨迹 {s_t, a_t, r_t, ...}
  2. 用 GAE（Generalized Advantage Estimation）计算每个时间步的优势 Â_t
  3. 在这批数据上做 K 个 epoch 的 SGD（通常 K=4~10）
     每个 epoch 优化 L^total
  4. θ_old ← θ，进入下一轮采样
```

:::note
**GAE**：$\hat{A}_t^{\text{GAE}(\lambda)} = \sum_{l=0}^{\infty} (\gamma \lambda)^l \delta_{t+l}$，其中 $\delta_t = r_t + \gamma V(s_{t+1}) - V(s_t)$ 是 TD 误差。$\lambda$ 的偏差-方差调档（$\lambda=0$ 单步 TD、$\lambda=1$ Monte Carlo）详见 [深度学习（七）：Actor-Critic 方法](/posts/RL_ActorCritic/)，PPO 实践中常取 $\lambda \in [0.95, 0.98]$。
:::

## 三、PPO 在 RLHF 中的应用

### 3.1 RLHF 三阶段

在 ChatGPT / InstructGPT 中，PPO 用在第三阶段：

1. **SFT（Supervised Fine-Tuning）**：用高质量对话数据微调基座模型
2. **Reward Model**：训练一个奖励模型 $r_\phi(x, y)$，给模型输出打分
3. **PPO 训练**：用 reward model 作为奖励信号，优化 LLM 策略

### 3.2 LLM 中的 PPO 设定

在 LLM 场景下，强化学习的要素映射为：

- **状态 $s_t$**：输入的 prompt + 已生成的前 $t-1$ 个 token
- **动作 $a_t$**：生成第 $t$ 个 token（从词表中选择）
- **策略 $\pi_\theta$**：LLM 本身，输出下一个 token 的概率分布
- **奖励 $r_t$**：只在序列结束时给出（reward model 打分），中间步 $r_t = 0$

### 3.3 KL 惩罚项

为了防止模型在 PPO 训练中「作弊」（比如生成乱码骗 reward model），PPO 的奖励中额外加入一个 KL 惩罚，约束模型不要偏离 SFT 模型太远：

$$
R(x, y) = r_\phi(x, y) - \beta \cdot \text{KL}\left(\pi_\theta(y|x) \;\|\; \pi_{\text{SFT}}(y|x)\right)
$$

其中 $\beta$ 是 KL 惩罚系数，控制偏离程度。

:::tip
**直觉**：reward model 是人训练的，可能有漏洞。模型可能学会说一些「reward model 喜欢但人类读不懂」的话。KL 惩罚相当于说：「你可以优化，但别跑太远，保持在 SFT 模型的附近」。这就像给模型画了一个安全区。
:::


## 四、总结

- **Clip 操作**限制策略更新幅度，简单有效
- 需要 Critic 网络，显存开销大（约 2× Actor）
- 用 GAE 计算优势，bias-variance 可通过 $\lambda$ 调节
- 在 RLHF 中加 KL 惩罚防止偏离 SFT 模型

