---
title: '强化学习课程复习索引：课件与博客对应关系'
published: 2026-11-10
description: '按课程讲次整理强化学习博客文章：MDP 与贝尔曼、MC/TD、SARSA/Q-learning、DQN、策略梯度、Actor-Critic/PPO、模型学习、探索与内在奖励、VLA 与图强化学习'
image: ''
tags: [RL, Course, Index]
category: '11-强化学习'
order: 0
draft: false
lang: ''
---

本索引按课程讲义二~九与 10 月 31 日复习课整理的 15 条要点组织。标「未整理」的是博客当前的空白，不是课程没有讲；复习时请回到对应讲义与复习单。

> 课件目录中只有第二讲及之后的 PDF，第一讲无文件，故本表从第二讲开始。

| 讲次 | 课件主题 | 对应文章 | 外部笔记与补充 |
|---|---|---|---|
| 2 | 强化学习的数学基础：马尔可夫性、MRP、回报与折扣、V/Q、贝尔曼方程与矩阵形式、动态规划 | [MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/)、[价值函数与贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/)、[网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) | [期望](/posts/math/pt_expectation/)、[方差](/posts/math/pt_variance/)、[大数定律](/posts/math/pt_bignumbertheory/)、[矩阵求逆](/posts/math/reverse/) |
| 3 | 被动/主动强化学习：MC、TD(0)、探索与利用、ε-greedy、SARSA、Q-learning、Cliff Walking | [被动强化学习与策略评价](/posts/reinforcement-learning/rl_passiverl/)、[主动强化学习、SARSA 与 Q-learning](/posts/reinforcement-learning/rl_activerl/)、[网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) | ε-greedy 概率计算见主动篇；UCB、乐观初始化、Thompson Sampling 已整理进第九讲笔记（草稿） |
| 4 | 深度强化学习 DQN：Q 表失效、函数逼近、TD 损失、Adam、经验回放、目标网络、完整训练流程 | [深度 Q 网络（DQN）](/posts/reinforcement-learning/rl_dqn/) | 讲义四还讲了 Adam 与 Huber 损失等实现细节，博客未展开 |
| 5 | 策略学习与 REINFORCE：直接/间接学习、Softmax 与高斯策略、J(θ)、对数导数技巧、Baseline | [策略学习与 REINFORCE](/posts/reinforcement-learning/rl_policylearning/) | 轨迹概率与对数梯度推导都在该篇；[PPO](/posts/reinforcement-learning/ppo/) 直接沿用 |
| 6 | Actor-Critic、A2C、A3C、PPO：优势函数、n-step、同步/异步采样、Clip | Actor-Critic、A2C 与 A3C（草稿，已补齐，未发布）、[PPO](/posts/reinforcement-learning/ppo/) | A2C/A3C 的同步/异步采样已整理；PPO 的 RLHF 应用见 [RLHF 与 PPO](/posts/nlp/09-01-rlhf-ppo/) |
| 7 | 基于模型的强化学习：环境模型、残差动力学、误差传播、Model Exploitation、六步闭环 | 基于模型的强化学习：环境模型、残差动力学与误差传播（草稿，待发布） | 误差传播的数学补充：[雅可比矩阵](/posts/math/jacobianmatrix/)、[范数](/posts/math/norm/)；残差动力学对应实验四 |
| 8 | VLA 与图强化学习融合的单智能体未知空间自主探索 | VLA 与图强化学习：未知空间自主探索的分层框架（草稿，待发布） | 图表示补充：[GCN](/posts/gcn/gcn/)；LLM 与 RL 的另一条路线见 [RLHF 与 PPO](/posts/nlp/09-01-rlhf-ppo/)、[DPO](/posts/nlp/09-02-dpo/) |
| 9 | 探索机制与内在奖励：MAB、ε-greedy、UCB/LCB、Thompson、计数/预测误差/ICM/RND、Noisy-TV、信息增益 | 探索机制与内在奖励：从 ε-greedy 到 Noisy-TV（草稿，待发布） | 信息增益的数学基础：[信息论](/posts/dl-basics/informationtheory/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)；ε-greedy 见第 3 讲主动篇 |
| 复习 | 期末复习 15 条要点 | 见下方「复习要点覆盖自查」 | 录音转写与复习单在课程目录 `复习/` 下，不属于博客 |

## 复习要点覆盖自查

| # | 复习要点 | 状态 | 对应文章 / 缺口 |
|---|---|---|---|
| 1 | 状态、动作、奖励、回报、策略、价值；奖励 vs 回报；V vs Q | 已覆盖 | [MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/)、[价值函数与贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/) |
| 2 | 强化学习、监督学习、无监督学习的区别与联系 | 已覆盖（草稿未发布） | 强化学习、监督学习与无监督学习：三种范式到底差在哪 |
| 3 | MDP 五要素、转移矩阵与行和为 1、折扣因子、马尔可夫性 | 已覆盖 | [MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/)（含 γ=0 与 γ→1 的极端行为）、[贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/) |
| 4 | 贝尔曼方程及其矩阵形式 | 已覆盖 | [价值函数与贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/)；迭代求解见 [网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) |
| 5 | 轨迹表示与轨迹概率 | 已覆盖 | [策略学习与 REINFORCE](/posts/reinforcement-learning/rl_policylearning/) 的轨迹概率连乘；[基础篇](/posts/reinforcement-learning/rl_basicconception/) 有轨迹定义 |
| 6 | TD 目标/误差、SARSA vs Q-learning、同策略/异策略 | 已覆盖 | [被动强化学习](/posts/reinforcement-learning/rl_passiverl/)、[主动强化学习](/posts/reinforcement-learning/rl_activerl/) |
| 7 | DQN 两个网络、经验回放 | 已覆盖 | [深度 Q 网络（DQN）](/posts/reinforcement-learning/rl_dqn/) |
| 8 | Q 表计算 | 已覆盖 | [主动强化学习](/posts/reinforcement-learning/rl_activerl/) 的 Cliff Walking 更新；[网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) 有逐回合手算 |
| 9 | 策略学习、对数概率梯度推导、θ 与 J(θ) 的证明 | 已覆盖 | [策略学习与 REINFORCE](/posts/reinforcement-learning/rl_policylearning/) |
| 10 | Actor-Critic 两网络、优势函数、PPO 特点、ρ 含义、截断、保持策略稳定的措施 | 基本覆盖（草稿未发布） | Actor-Critic、A2C、A3C 已补齐（草稿）；[PPO](/posts/reinforcement-learning/ppo/) 覆盖 ρ、截断、Clip 与 KL 稳定性措施 |
| 11 | 模型学习的优点/作用/局限、与无模型学习的区别、一步估计误差 | 已覆盖（草稿未发布） | 基于模型的强化学习：环境模型、残差动力学与误差传播 |
| 12 | ε-greedy、LCB、Thompson Sampling 的区别与计算 | 已覆盖（草稿未发布） | [主动强化学习](/posts/reinforcement-learning/rl_activerl/) 的 ε-greedy + 第九讲笔记的 UCB/LCB/乐观初始化/Thompson（含数值例题） |
| 13 | 内在奖励与外在奖励、典型方法、Noisy-TV | 已覆盖（草稿未发布） | 探索机制与内在奖励：从 ε-greedy 到 Noisy-TV |
| 14 | 大模型与强化学习的关系、一个任务如何同时设计大模型与 RL | 已覆盖（草稿未发布） | VLA 与图强化学习：未知空间自主探索的分层框架（含大模型 × RL 六步设计模板）；[PPO](/posts/reinforcement-learning/ppo/)、[GRPO](/posts/reinforcement-learning/grpo/) 讲 RLHF |
| 15 | 考试题型与难点 | 非博客内容 | 见课程复习单；本索引用作各考点的入口 |

## 按主题复习

### 值函数主线

[MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/) → [价值函数与贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/) → [被动强化学习（MC/TD）](/posts/reinforcement-learning/rl_passiverl/) → [主动强化学习（SARSA/Q-learning）](/posts/reinforcement-learning/rl_activerl/) → [DQN](/posts/reinforcement-learning/rl_dqn/)；全程可用 [网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) 对照演算。

### 策略梯度主线

[策略学习与 REINFORCE](/posts/reinforcement-learning/rl_policylearning/) → Actor-Critic、A2C 与 A3C（草稿） → [PPO](/posts/reinforcement-learning/ppo/) → [GRPO](/posts/reinforcement-learning/grpo/)

### 已补齐但尚未发布的草稿

- **第七讲 基于模型的强化学习**：环境模型与残差动力学、误差累积、模型被规划器利用。
- **第八讲 VLA 与图强化学习**：POMDP 建模、动态图与 frontier 特征、VLA 先验与 PPO 的结合，以及大模型 × RL 六步设计模板。
- **第九讲 探索与内在奖励**：UCB/LCB、Thompson Sampling、计数型/预测误差型/ICM/RND、Noisy-TV、信息增益。
- **复习要点 2**：强化学习与监督/无监督学习的对照。

以上四篇均为 `draft: true`，在本地 dev 环境可见，发布前需要把草稿标记改为 `false` 并补上文章内链。
