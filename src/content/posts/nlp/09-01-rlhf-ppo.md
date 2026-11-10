---
title: 'RLHF 与 PPO：用人类偏好对齐语言模型'
published: 2026-10-20
description: '从 3H 原则到奖励模型与 PPO：策略、评论、奖励、参考四个模型如何协作，GAE 如何估计优势，KL 约束如何防止跑偏'
image: ''
tags: [NLP, LLM, RLHF, PPO, Reward-Model, GAE]
category: '09-自然语言处理'
order: 901
draft: false
lang: ''
---

## 为什么 SFT 之后还要 RLHF

[SFT](/posts/nlp/08-01-llm-sft/) 用“标准答案”训练模型，但很多问题没有唯一正确答案。同一句回答可以更简洁、更礼貌、更诚实，也可以更有用；SFT 无法表达“哪个更好”这种相对偏好。

人类反馈的强化学习（Reinforcement Learning from Human Feedback, RLHF）用人类偏好训练一个奖励模型，再用强化学习优化语言模型。目标通常概括为 **3H 原则**：

- **Helpful**：回答有帮助，真正解决用户问题；
- **Honest**：不编造、不误导，承认不确定性；
- **Harmless**：不产生有害、歧视或危险内容。

RLHF 的优势是能评估整段回答的质量和风格，而不仅是逐 token 的似然；代价是流程复杂、训练不稳定，且需要大量偏好标注。

## 把生成看作强化学习

语言模型生成回答可以写成一个序列决策过程：

- **状态** $s_t$：提示词加上已经生成的前缀；
- **动作** $a_t$：下一个 token；
- **策略** $\pi_\theta$：语言模型本身；
- **奖励** $r(x,y)$：整段回答结束后由奖励模型给出的分数。

设提示为 $x$，回答为 $y=(y_1,\dots,y_T)$。RLHF 的目标是最大化奖励，同时限制新策略不要偏离参考模型太远：

$$
\max_{\pi_\theta}\;
\mathbb{E}_{x \sim \mathcal{D},\, y \sim \pi_\theta(\cdot \mid x)}
\left[r(x,y)\right]
- \beta \operatorname{KL}\big(\pi_\theta(\cdot \mid x) \,\|\, \pi_{\text{ref}}(\cdot \mid x)\big)
$$

$\pi_{\text{ref}}$ 通常是 SFT 后的模型，$\beta$ 控制 KL 惩罚的强度。没有 KL 约束时，策略会钻奖励模型的空子（reward hacking），生成奖励高但人类并不喜欢的文本。

实际实现常把 KL 惩罚分摊到每个 token 的奖励中：

$$
\tilde{r}_t =
-\beta \log\frac{\pi_\theta(y_t \mid x,y_{<t})}
{\pi_{\text{ref}}(y_t \mid x,y_{<t})}
$$

最后一个 token 再加上奖励模型的分数。这样每个生成步骤都有即时反馈，便于用 PPO 优化。

## 奖励模型

奖励模型（Reward Model, RM）把“人类更喜欢哪个回答”学成一个可打分的函数。

### 数据收集

对同一个提示，让模型生成两个回答，由标注者判断哪个更好。数据形式为 $(x, y_w, y_l)$，其中：

- $x$：提示；
- $y_w$：更受偏好的回答；
- $y_l$：较差的回答。

标注时通常只保留偏好明确的样本，排除平局。

### 模型结构

从 SFT 模型初始化，去掉最后的词表输出层，换成一个输出标量的线性头。输入 $x$ 和回答 $y$，取最后一个 token 的隐藏状态，输出奖励 $r_\phi(x,y)$。

### 损失函数

采用 Bradley–Terry 模型，假设偏好概率由奖励差的 sigmoid 决定：

$$
P(y_w \succ y_l \mid x) =
\sigma\big(r_\phi(x,y_w) - r_\phi(x,y_l)\big)
$$

训练目标是最小化负对数似然：

$$
\mathcal{L}_{\text{RM}} =
-\mathbb{E}_{(x,y_w,y_l)}
\log \sigma\big(r_\phi(x,y_w) - r_\phi(x,y_l)\big)
$$

奖励模型的输出只有相对大小有意义，绝对数值并不重要。它也可能被策略“攻破”：策略找到得分高但实际质量差的模式，因此需要 KL 约束和持续的人工评估。

## PPO 的训练流程

PPO（Proximal Policy Optimization）是一种策略梯度方法，核心是用重要性采样复用旧策略采到的数据，并限制新旧策略的差异。完整推导见 [PPO](/posts/reinforcement-learning/ppo/)，这里只看它在 RLHF 中的用法。

RLHF 同时维护四个模型：

| 模型 | 作用 |
|---|---|
| 策略模型 $\pi_\theta$ | 生成回答，被优化 |
| 评论模型 $V_\psi$ | 估计状态价值，计算优势 |
| 奖励模型 $r_\phi$ | 给完整回答打分 |
| 参考模型 $\pi_{\text{ref}}$ | 计算 KL，约束策略偏移 |

### 1. 环境采样

从数据集中取提示 $x$，用当前策略生成回答 $y$，奖励模型给出 $r(x,y)$，同时计算每个 token 相对参考模型的 KL 惩罚。

### 2. 优势估计

评论模型估计每个状态的价值 $V_\psi(s_t)$。时序差分误差为

$$
\delta_t = \tilde{r}_t + \gamma V_\psi(s_{t+1}) - V_\psi(s_t)
$$

GAE（Generalized Advantage Estimation）对多步 TD 误差做指数加权：

$$
\hat{A}_t =
\sum_{l=0}^{T-t} (\gamma\lambda)^l \,\delta_{t+l}
$$

$\lambda=0$ 时退化为单步 TD，偏差大、方差小；$\lambda=1$ 时接近蒙特卡洛，方差大、偏差小。$\lambda \in (0,1)$ 在两者之间折中。

### 3. 优化策略

设新旧策略的概率比为

$$
\rho_t(\theta) =
\frac{\pi_\theta(y_t \mid s_t)}
{\pi_{\theta_{\text{old}}}(y_t \mid s_t)}
$$

PPO 的裁剪目标为

$$
\mathcal{L}_{\text{clip}}(\theta) =
-\mathbb{E}_t\left[
\min\left(
\rho_t \hat{A}_t,\;
\operatorname{clip}(\rho_t, 1-\epsilon, 1+\epsilon)\hat{A}_t
\right)
\right]
$$

当优势为正时，提高该动作概率；当优势为负时，降低概率。裁剪项阻止 $\rho_t$ 偏离 1 太远，避免一次更新把策略带崩。

评论模型用均方误差拟合回报：

$$
\mathcal{L}_V = \mathbb{E}_t\left[\big(V_\psi(s_t) - \hat{R}_t\big)^2\right]
$$

总损失通常是策略损失、价值损失和熵奖励的加权和：

$$
\mathcal{L} =
\mathcal{L}_{\text{clip}} + c_1 \mathcal{L}_V - c_2 \mathcal{H}(\pi_\theta)
$$

熵奖励鼓励探索，防止策略过早坍塌到单一回答模式。

### 4. 迭代

用收集到的轨迹更新策略和评论模型若干轮，然后重新采样。由于策略在变，旧数据只能有限次复用，这也是 PPO 数据效率不高的原因。

## 难点与改进

- **显存开销**：四个模型同时存在，策略和评论通常还要各自保存优化器状态，70B 级别模型的 RLHF 成本很高；
- **训练不稳定**：奖励、KL、优势的尺度都会影响收敛，需要仔细调参；
- **奖励劫持**：策略可能利用奖励模型的漏洞，生成高分低质内容；
- **标注成本**：高质量偏好数据昂贵，且标注者之间可能存在分歧。

为降低 critic 的开销，[GRPO](/posts/reinforcement-learning/grpo/) 用同一提示下多个回答的组内相对得分代替价值网络，去掉评论模型；[DPO](/posts/nlp/09-02-dpo/) 则完全跳过强化学习循环，直接用偏好数据优化策略。

## 相关阅读

- 策略梯度与 PPO 推导：[PPO](/posts/reinforcement-learning/ppo/)
- 强化学习基础：[MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/)
- 去掉 critic 的变体：[GRPO](/posts/reinforcement-learning/grpo/)
- 直接偏好优化：[DPO](/posts/nlp/09-02-dpo/)
- SFT 基础：[LLM 有监督微调](/posts/nlp/08-01-llm-sft/)
- 对齐后的评测：[大语言模型的评价](/posts/nlp/10-03-llm-evaluation/)
