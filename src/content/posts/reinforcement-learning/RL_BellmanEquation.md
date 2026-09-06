---
title: 强化学习笔记：贝尔曼方程、值函数与表格学习
published: 2025-11-02
description: '从价值函数推导贝尔曼方程，并介绍动态规划、时序差分、SARSA 与 Q-learning'
image: ''
tags: [RL, 贝尔曼方程, 值函数, SARSA, Q-learning]
category: '11-强化学习'
draft: false
lang: ''
---

本文使用[强化学习基础](./RL_basicConception)中的时间下标，并建立在[MDP 与 MRP](./RL_Markov)的定义之上。内容覆盖从回报到贝尔曼方程，再到动态规划和表格型强化学习算法的完整链条。

## 一、统一记号

- $S_t,A_t,R_{t+1},S_{t+1}$ 是随机变量；$s,a,r,s'$ 是它们的具体取值；
- $\pi(a\mid s)$ 是策略；
- $p(s'\mid s,a)$ 是状态转移概率；
- $p(r,s'\mid s,a)$ 是奖励和下一状态的联合分布；
- $\bar r(s,a)=\mathbb{E}[R_{t+1}\mid S_t=s,A_t=a]$ 是平均即时奖励；
- $0\le \gamma<1$ 是折扣因子；
- 终止状态不再产生后续奖励，若下一状态是终止状态，则后续价值项取 $0$。

在有限离散状态空间中，求和遍历所有可能的 $a$、$r$ 和 $s'$；连续变量场景则将求和替换为积分。

## 二、回报与价值函数

### 1. 回报

从时间步 $t$ 开始的折扣回报为：

$$
G_t=R_{t+1}+\gamma R_{t+2}+\gamma^2R_{t+3}+\cdots.
$$

有限回合在终止时间 $T$ 结束时：

$$
G_t=\sum_{k=0}^{T-t-1}\gamma^kR_{t+k+1},
\qquad G_T=0.
$$

回报具有递推关系：

$$
G_t=R_{t+1}+\gamma G_{t+1}.
$$

这条递推关系是贝尔曼方程的起点：当前回报由当前一步奖励和下一时刻的未来回报组成。

### 2. 状态价值函数

固定策略 $\pi$ 后，状态 $s$ 的 **状态价值函数（state-value function）** 定义为：

$$
 v_\pi(s)=\mathbb{E}_\pi[G_t\mid S_t=s].
$$

它回答的问题是：**从状态 $s$ 出发，之后一直按照策略 $\pi$ 行动，能够得到的期望折扣回报是多少？**

价值必须带上策略下标，因为同一个状态使用不同策略，未来得到的回报通常不同。

### 3. 动作价值函数

固定策略 $\pi$ 后，状态—动作对 $(s,a)$ 的 **动作价值函数（action-value function）** 定义为：

$$
q_\pi(s,a)=\mathbb{E}_\pi[G_t\mid S_t=s,A_t=a].
$$

它回答的问题是：**在状态 $s$ 先执行动作 $a$，之后按照策略 $\pi$ 行动，能够得到的期望折扣回报是多少？**

状态价值和动作价值的关系是：

$$
 v_\pi(s)=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)q_\pi(s,a).
$$

状态价值评价一个状态；动作价值可以在同一状态下比较不同动作，因此对决策通常更直接。

## 三、贝尔曼期望方程

贝尔曼方程表达的是：当前价值等于当前一步的期望奖励，加上下一状态价值的折扣期望。

### 1. 动作价值的贝尔曼方程

从 $(s,a)$ 出发，对奖励和下一状态的联合分布取期望：

$$
\begin{aligned}
q_\pi(s,a)
&=\mathbb{E}_\pi[G_t\mid S_t=s,A_t=a]\\
&=\sum_{r,s'}p(r,s'\mid s,a)
\left[r+\gamma\sum_{a'}\pi(a'\mid s')q_\pi(s',a')\right].
\end{aligned}
$$

也可以使用平均即时奖励和状态转移概率写成：

$$
q_\pi(s,a)=\bar r(s,a)+\gamma\sum_{s'}p(s'\mid s,a)v_\pi(s').
$$

这两个表达式是等价的。第二种写法利用了期望的线性性质，并不要求奖励和下一状态在给定 $(s,a)$ 后相互独立。

### 2. 状态价值的贝尔曼方程

根据动作由策略 $\pi$ 选择，有：

$$
\begin{aligned}
v_\pi(s)
&=\sum_a\pi(a\mid s)q_\pi(s,a)\\
&=\sum_a\pi(a\mid s)
\left[\bar r(s,a)+\gamma\sum_{s'}p(s'\mid s,a)v_\pi(s')\right].
\end{aligned}
$$

把奖励和下一状态的联合分布完全展开，也可以写成：

$$
 v_\pi(s)=\sum_a\pi(a\mid s)\sum_{r,s'}p(r,s'\mid s,a)
 \left[r+\gamma v_\pi(s')\right].
$$

如果 $s'$ 是终止状态，约定 $v_\pi(s')=0$。

### 3. 贝尔曼方程的含义

贝尔曼方程把一个长期问题分解为一步问题：

$$
\text{当前价值}
=\text{当前一步的期望奖励}
+\gamma\times\text{下一状态的期望价值}.
$$

它不是另一种奖励定义，而是价值函数满足的递推关系。动态规划、时序差分和许多强化学习算法，都在不同程度上利用了这一递推结构。

## 四、矩阵形式与动态规划

下面考虑有限状态的 MRP，或者固定策略 $\pi$ 后的策略诱导过程。设：

- $v$ 是价值向量，第 $s$ 个分量为 $v(s)$；
- $r$ 是平均即时奖励向量，第 $s$ 个分量为 $\bar r(s)$；
- $P$ 是策略诱导的状态转移矩阵，$P_{s,s'}=p_\pi(s'\mid s)$；
- $I$ 是单位矩阵。

逐状态的贝尔曼方程可以写为：

$$
 v=r+\gamma Pv.
$$

移项可得：

$$
 (I-\gamma P)v=r.
$$

在 $I-\gamma P$ 可逆时，理论上的精确解为：

$$
 v=(I-\gamma P)^{-1}r.
$$

矩阵求逆主要用于理论分析。状态数量很大时，显式求逆的计算和存储代价都很高，实际通常使用迭代方法。

### 1. 贝尔曼更新

给定价值估计 $v_k$，用它计算下一次估计：

$$
 v_{k+1}(s)=\bar r(s)+\gamma\sum_{s'}p_\pi(s'\mid s)v_k(s').
$$

这叫作贝尔曼更新。用后继状态当前的估计来更新当前状态的估计，这种“用估计更新估计”的思想称为**自举（bootstrapping）**。

### 2. 迭代策略评估

```text
输入：已知的 MDP 模型、策略 π、折扣因子 γ
初始化 v(s)，例如全部设为 0
重复：
    对每个非终止状态 s：
        v_new(s) = Σ_a π(a|s)
                   [r̄(s,a) + γ Σ_{s'} p(s'|s,a) v(s')]
    v ← v_new
直到 max_s |v_new(s) - v(s)| < ε
输出：v
```

在有限状态、有限动作且 $0\le \gamma<1$ 时，贝尔曼期望算子是压缩映射，迭代通常收敛到唯一的 $v_\pi$。该方法需要知道奖励和转移模型，因此属于基于模型的动态规划方法。

## 五、最优价值函数与贝尔曼最优方程

### 1. 最优价值函数

在所有可选策略中，状态 $s$ 能达到的最大状态价值定义为：

$$
 v_*(s)=\max_\pi v_\pi(s).
$$

同理，最优动作价值函数定义为：

$$
 q_*(s,a)=\max_\pi q_\pi(s,a).
$$

这里的 $q_*(s,a)$ 表示先在 $(s,a)$ 执行动作，然后从后续状态开始采取最优行为。

### 2. 贝尔曼最优方程

最优状态价值满足：

$$
 v_*(s)=\max_{a\in\mathcal{A}(s)}
 \left[\bar r(s,a)+\gamma\sum_{s'}p(s'\mid s,a)v_*(s')\right].
$$

最优动作价值满足：

$$
 q_*(s,a)=\bar r(s,a)+\gamma\sum_{s'}p(s'\mid s,a)
 \max_{a'\in\mathcal{A}(s')}q_*(s',a').
$$

并且：

$$
 v_*(s)=\max_{a\in\mathcal{A}(s)}q_*(s,a).
$$

### 3. 最优策略

任意满足下式的策略都是最优策略：

$$
\pi^*(a\mid s)>0
\quad\text{仅当}\quad
 a\in\arg\max_{a'\in\mathcal{A}(s)}q_*(s,a').
$$

最简单的确定性贪心策略为：

$$
\pi^*(s)\in\arg\max_{a\in\mathcal{A}(s)}q_*(s,a).
$$

在有限状态—动作空间、折扣因子小于 $1$ 或满足适当终止条件时，最优值函数存在；在常见的折扣有限 MDP 中，最优值函数是唯一的。最优策略不一定唯一：如果多个动作的 $q_*(s,a)$ 相同，它们都可以组成最优策略。

## 六、从完整回合到一步样本：时序差分

### 1. Monte Carlo 与 TD 的区别

Monte Carlo 方法等到回合结束后，使用真实采样回报 $G_t$ 更新价值：

$$
V(S_t)\leftarrow V(S_t)+\alpha\left[G_t-V(S_t)\right].
$$

它不需要环境模型，也不使用价值估计进行目标计算，但通常要等回合结束，且目标方差较大。

时序差分（Temporal-Difference, TD）方法只等待一步转移，就用下一状态的价值估计构造目标：

$$
Y_t^{\mathrm{TD}}=R_{t+1}+\gamma V(S_{t+1}),
$$

$$
\delta_t=Y_t^{\mathrm{TD}}-V(S_t)
=R_{t+1}+\gamma V(S_{t+1})-V(S_t).
$$

其中 $\delta_t$ 称为 TD 误差，一步 TD 更新为：

$$
V(S_t)\leftarrow V(S_t)+\alpha\delta_t.
$$

如果 $S_{t+1}$ 是终止状态，则目标为 $Y_t^{\mathrm{TD}}=R_{t+1}$，不再加未来价值项。

TD 方法的特点是：

- 无需等待整个回合结束；
- 不需要知道完整环境模型；
- 使用后继状态的价值估计，因而具有自举性质；
- 目标通常比完整回报方差更低，但会引入估计偏差。

$\alpha\in(0,1]$ 是学习率，控制每次样本对旧估计的影响大小。

## 七、SARSA：同策略时序差分控制

### 1. 更新公式

SARSA 的名字来自一次更新涉及的五个量：

$$
(S_t,A_t,R_{t+1},S_{t+1},A_{t+1}).
$$

在当前状态执行 $A_t$ 后，按照行为策略在下一状态选择 $A_{t+1}$。动作价值更新为：

$$
Y_t^{\mathrm{SARSA}}
=R_{t+1}+\gamma Q(S_{t+1},A_{t+1}),
$$

$$
Q(S_t,A_t)\leftarrow Q(S_t,A_t)+\alpha
\left[Y_t^{\mathrm{SARSA}}-Q(S_t,A_t)\right].
$$

若 $S_{t+1}$ 是终止状态，则 $Y_t^{\mathrm{SARSA}}=R_{t+1}$。

### 2. 为什么 SARSA 是 on-policy？

SARSA 用实际按照行为策略选出的 $A_{t+1}$ 构造目标。也就是说，执行动作的策略和被评估、被改进的策略是同一个策略，因此称为**同策略（on-policy）**控制。

实际中经常使用 $\varepsilon$-greedy 策略：

- 以较大概率选择当前 $Q$ 值最大的动作；
- 以较小概率 $\varepsilon$ 随机探索其他动作。

探索策略可以避免智能体过早固定在当前看起来较好的动作上。

## 八、Q-learning：离策略时序差分控制

### 1. 更新公式

Q-learning 使用下一状态的最大动作价值构造目标：

$$
Y_t^{\mathrm{Q}}=R_{t+1}+\gamma\max_{a'\in\mathcal{A}(S_{t+1})}Q(S_{t+1},a'),
$$

$$
Q(S_t,A_t)\leftarrow Q(S_t,A_t)+\alpha
\left[Y_t^{\mathrm{Q}}-Q(S_t,A_t)\right].
$$

若下一状态为终止状态，则 $Y_t^{\mathrm{Q}}=R_{t+1}$。

### 2. 为什么 Q-learning 是 off-policy？

Q-learning 可以使用 $\varepsilon$-greedy 等带探索的行为策略收集数据，但目标中的下一动作使用：

$$
\arg\max_{a'}Q(S_{t+1},a')
$$

对应的贪心策略。因此，收集样本的行为策略和目标策略可以不同，Q-learning 是**离策略（off-policy）**算法。

Q-learning 不需要知道 $p(s'\mid s,a)$ 或奖励分布，只需要不断获得转移样本，所以是 model-free 的 TD 控制方法。在有限表格 MDP 和满足充分探索、合适学习率等条件时，它可以收敛到最优动作价值函数。实际训练中，最大化操作也可能带来 Q 值过估计问题。

## 九、SARSA 与 Q-learning 对比

| 对比项           | SARSA                               | Q-learning                             |
| ---------------- | ----------------------------------- | -------------------------------------- |
| TD 目标          | $R_{t+1}+\gamma Q(S_{t+1},A_{t+1})$ | $R_{t+1}+\gamma\max_{a'}Q(S_{t+1},a')$ |
| 下一动作         | 按行为策略实际采样                  | 直接取最大 Q 值                        |
| 策略关系         | on-policy                           | off-policy                             |
| 是否需要环境模型 | 不需要                              | 不需要                                 |
| 主要特点         | 学习实际执行的探索策略              | 学习贪心最优策略                       |

## 十、基础知识复习路线

可以按下面的依赖关系复习：

$$
\begin{aligned}
&\text{状态、动作、奖励、策略}\\
&\quad\longrightarrow\text{MDP 与马尔可夫性}\\
&\quad\longrightarrow\text{轨迹与回报 }G_t\\
&\quad\longrightarrow v_\pi(s),q_\pi(s,a)\\
&\quad\longrightarrow\text{贝尔曼期望方程}\\
&\quad\longrightarrow\text{矩阵解与动态规划}\\
&\quad\longrightarrow\text{最优值函数与贝尔曼最优方程}\\
&\quad\longrightarrow\text{TD、SARSA、Q-learning}.
\end{aligned}
$$

### 检查自己是否掌握

1. 能否解释为什么奖励写成 $R_{t+1}$，并写出一个完整转移元组？
2. 能否区分 $p(s'\mid s)$、$p(s'\mid s,a)$ 和 $P^\pi(s'\mid s)$？
3. 能否从 $G_t=R_{t+1}+\gamma G_{t+1}$ 推导状态价值的贝尔曼方程？
4. 能否说明为什么 $v_\pi(s)=\sum_a\pi(a\mid s)q_\pi(s,a)$？
5. 能否区分贝尔曼更新、Monte Carlo 更新和 TD 更新？
6. 能否指出 SARSA 与 Q-learning 的目标为什么分别对应 on-policy 和 off-policy？
7. 能否写出 $v_*$、$q_*$ 和它们对应的贝尔曼最优方程？
