---
title: GRPO：砍掉 Critic 的 PPO 改进版
published: 2026-07-15
description: 'GRPO（Group Relative Policy Optimization）的原理：如何用组内相对比较替代价值网络，降低 LLM 对齐训练的显存开销'
image: ''
tags: [RL, GRPO, PPO, RLHF, LLM, DeepSeek]
category: 'RL'
draft: false 
lang: ''
---

## 前言

GRPO（Group Relative Policy Optimization）是 DeepSeek 团队在训练 DeepSeek-R1 等推理模型时提出的强化学习算法。它是 PPO 的一个巧妙改进：**砍掉了 Critic 网络（价值函数），用同一 prompt 下多采样的组内比较来替代**。

本文先回顾 PPO 在 LLM 场景下的痛点，再详细推导 GRPO 的核心机制。

## 一、回顾：PPO 在 LLM 中的痛点

PPO 用优势函数来指导策略更新：

$$
\hat{A}_t = Q(s_t, a_t) - V(s_t)
$$

要计算优势，就需要一个 Critic 网络 $V_\phi$ 来估计状态价值。在 LLM 场景中，Critic 通常和 Actor（策略模型 $\pi_\theta$）**一样大**。

| 问题 | 说明 |
|------|------|
| **显存翻倍** | Critic 和 Actor 一样大，训练需要约 2× 显存 |
| **训练不稳定** | Critic 本身也需要训练，Critic 估计不准会导致 Actor 学歪 |
| **复杂度高** | 需要维护两个模型，调参更复杂 |

GRPO 的核心问题：**能不能不要 Critic？**

## 二、GRPO：Group Relative Policy Optimization

### 2.1 核心创新：用 Group 替代 Critic

GRPO 的做法非常巧妙。对于同一个 prompt $q$，从旧策略 $\pi_{\theta_{\text{old}}}$ 中**采样 $G$ 个不同的输出**：

$$
\{o_1, o_2, \ldots, o_G\} \sim \pi_{\theta_{\text{old}}}(\cdot | q)
$$

每个输出 $o_i$ 都能得到一个 reward $r_i$（由 reward model 给出）。然后计算**组内相对优势**：

$$
\hat{A}_i = \frac{r_i - \text{mean}(\{r_1, \ldots, r_G\})}{\text{std}(\{r_1, \ldots, r_G\})}
$$

:::tip
这就像「在班上排名」。与其请一个专家（Critic）给每个学生打分，不如直接看排名——分数减去全班平均分，再除以标准差，就是「相对优势」。简单、高效，而且不需要额外训练一个专家模型。

同一个 prompt 下的多个输出天然构成了一个「对照组」，组内比较比绝对打分更可靠。
:::

### 2.2 和 PPO 的优势计算对比

| 方法 | PPO | GRPO |
|------|-----|------|
| 优势来源 | Critic 估计 $Q - V$ | 组内标准化 score |
| 需要额外模型 | 是（Critic） | 否 |
| 估计方式 | 逐 token 的 TD 误差 | 序列级 reward 的组内排名 |
| 参数 | GAE 的 $\lambda$、$\gamma$ | 组大小 $G$ |

:::note
PPO 用 GAE 做时序差分估计，每个 token 都有独立的优势值。GRPO 由于 reward 只在序列结束时给出，同一个输出里所有 token 共享同一个优势值 $\hat{A}_i$。
:::

### 2.3 GRPO 的目标函数

GRPO 的目标函数保留了 PPO 的 clip 机制：

$$
\begin{aligned}
J_{\text{GRPO}}(\theta) = \mathbb{E}_{q \sim P(Q), \{o_i\}_{i=1}^G \sim \pi_{\theta_{\text{old}}}(\cdot|q)} \Bigg[ \frac{1}{G} \sum_{i=1}^{G} \frac{1}{|o_i|} \sum_{t=1}^{|o_i|} 
\min\Big( &r_{i,t}(\theta) \hat{A}_{i,t},
&\text{clip}(r_{i,t}(\theta), 1-\epsilon, 1+\epsilon) \hat{A}_{i,t} \Big) \Bigg]
\end{aligned}
$$

其中：

- $r_{i,t}(\theta) = \dfrac{\pi_\theta(o_{i,t} | q, o_{i,<t})}{\pi_{\theta_{\text{old}}}(o_{i,t} | q, o_{i,<t})}$：和 PPO 一样的概率比

- $\hat{A}_{i,t}$：第 $i$ 个输出第 $t$ 个 token 的优势 —— **同一个输出里所有 token 共享同一个优势值**（因为 reward 是序列级给出的）
- $\frac{1}{|o_i|}$：按输出长度做平均，避免长序列占主导
- $\frac{1}{G}$：对 $G$ 个采样取平均

:::tip
外层是「同一个 prompt 采样 $G$ 个回答」，内层是 PPO 的 clip 机制。核心区别只有一条：优势 $\hat{A}_i$ 不是 Critic 算出来的，而是这 $G$ 个回答互相比较出来的。
:::

### 2.4 GRPO 的 KL 惩罚

GRPO 不使用 PPO 的 reward 级 KL 惩罚，而是在损失函数中直接加入：

$$
\mathcal{D}_{\text{KL}}\left(\pi_\theta \;\|\; \pi_{\text{ref}}\right) = \frac{1}{|o_i|} \sum_{t=1}^{|o_i|} \text{KL}\left(\pi_\theta(\cdot|q, o_{i,<t}) \;\|\; \pi_{\text{ref}}(\cdot|q, o_{i,<t})\right)
$$

完整损失：

$$
\mathcal{L}_{\text{GRPO}} = -J_{\text{GRPO}}(\theta) + \beta \cdot \mathcal{D}_{\text{KL}}
$$

:::tip
PPO 把 KL 惩罚塞进 reward 里，是「间接」约束；GRPO 把 KL 惩罚直接加在 loss 里，是「直接」约束。效果类似，但 GRPO 的方式更简洁，不需要额外调整 reward 的计算方式。
:::

### 2.5 训练流程

```
对于每个 prompt q：
  1. 从旧策略 π_θ_old 采样 G 个输出 {o_1, ..., o_G}
  2. Reward model 打分，得到 {r_1, ..., r_G}
  3. 计算组内标准化优势 Â_i = (r_i - mean) / std
  4. 用 GRPO 目标函数更新策略
  5. 更新参考模型（定期同步或 EMA）
```

## 三、PPO vs GRPO 完整对比

| 维度 | PPO | GRPO |
|------|-----|------|
| **Critic 网络** | 需要，和 Actor 一样大 | 不需要 |
| **优势计算** | $Q(s,a) - V(s)$，用 GAE 估计 | 组内标准化：$(r_i - \text{mean}) / \text{std}$ |
| **显存占用** | 约 2× Actor 大小 | 约 1× Actor 大小（+ 采样开销） |
| **KL 惩罚** | 加在 reward 中 | 直接加在 loss 中 |
| **采样方式** | 每个 prompt 采样一次 | 每个 prompt 采样 $G$ 次 |
| **训练稳定性** | 依赖 Critic 的准确性 | 依赖组内样本数量 $G$ |
| **代表工作** | ChatGPT, InstructGPT, Claude | DeepSeek-R1, DeepSeekMath |

## 四、总结

- 核心创新：**用 Group 采样替代 Critic**，砍掉价值网络
- 优势 = 组内标准化 score，简单粗暴但有效
- 显存友好，特别适合训练大模型（省掉一个等大的 Critic）
- KL 惩罚直接加在 loss 中，比 PPO 的 reward 级 KL 更简洁
- 需要同一 prompt 采样 $G$ 次，增加了推理开销
