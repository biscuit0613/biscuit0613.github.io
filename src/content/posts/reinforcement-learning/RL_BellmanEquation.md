---
title: 强化学习（二）：价值函数与贝尔曼方程
published: 2025-11-02
description: '从回报的递推关系推导贝尔曼期望方程与贝尔曼最优方程，并在模型已知时用动态规划求解'
image: ''
tags: [RL, 贝尔曼方程, 值函数, 动态规划]
category: '11-强化学习'
draft: false
order: 2
lang: ''
---

**如果环境模型 $P$、$R$ 完全已知，如何精确地评价一个策略、并求出最优策略？**

## 记号回顾

- $S_t,A_t,R_t,S_{t+1}$ 是随机变量，$s,a,r,s'$ 是它们的具体取值；
- $\pi(a\mid s)$ 是策略，$p(s'\mid s,a)$ 是状态转移概率；
- $R(s,a)=\mathbb{E}[R_t\mid S_t=s,A_t=a]$ 奖励函数是即时奖励的期望；
- $0\le\gamma<1$ 是折扣因子；
- 终止状态不再产生后续奖励，若下一状态是终止状态，则后续价值项取 $0$。

## 价值函数

**回报**（Return）$G_t$ 可以衡量策略 $\pi$ 的好坏：如果遵循某个 $\pi$ 获得的 $G_t$ 更大，那么该策略就更好

但由于策略和环境都有随机性，同一个状态出发每次得到的 $G_t$ 并不相同，所以用 **回报的期望** 来定义价值。

- 价值必须带策略上标，因为同一状态用不同策略，未来回报通常不同。

### 1. 状态价值函数

$$
V^\pi(s)=\mathbb{E}_\pi[G_t\mid S_t=s].
$$

它回答：**从状态 $s$ 出发，之后一直按策略 $\pi$ 行动，能得到的期望折扣回报是多少？**

### 2. 动作价值函数

$$
Q^\pi(s,a)=\mathbb{E}_\pi[G_t\mid S_t=s,A_t=a].
$$

它回答：**在 $s$ 先执行动作 $a$，之后按策略 $\pi$ 行动，能得到的期望折扣回报是多少？**

### 3. 状态价值与动作价值的关系

如果不考虑具体动作，那么 $V^\pi(s)$ 就相当于对 $Q^\pi(s,a)$ 按策略取期望。状态价值和动作价值的关系为：

$$
V^\pi(s)=\mathbb{E}_{\pi}[Q(s,a)]=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)Q^\pi(s,a),
$$

:::tip[ Q 比 V 更重要]

$V$ 只能告诉"这个状态大概值多少分"，不能直接指导选哪个动作；$Q$ 可以在同一状态下直接比较 $Q(s,a_1),Q(s,a_2),\dots$，选最大的那个。所以决策阶段几乎都用 $Q$。

:::

:::tip[关于动作价值里面的a]

$Q^\pi(s,a)$ 中的 $a$ 表示在状态 $s$ 下首先强制执行的动作，不受当前策略 $\pi$ 的动作选择约束；但从下一步开始，仍然按照策略 $\pi$ 行动。因此，即使某个动作在策略 $\pi$ 下的选择概率为零，它仍然可以定义动作价值。

:::

## 贝尔曼期望方程

贝尔曼方程表达通式：**当前价值 = 当前一步的期望奖励 + 下一状态价值的折扣**。

关键推导：回报 $G_t$ 的递推关系 $G_t=R_t+\gamma G_{t+1}$

### 1. 状态价值的贝尔曼期望方程

**当前价值 = 当前一步的期望奖励 + 下一状态价值的折扣**

$$
\boxed{V^\pi(s)=\mathbb{E}_\pi[R_t+\gamma V^\pi(S_{t+1})\mid S_t=s]}
$$

#### 1.1 状态价值的贝尔曼期望方程展开

从 $V^\pi$ 的定义出发，先用 **回报递推** 和 **期望的线性性** 把"当前一步"和"未来"拆开：

$$
\begin{aligned}
V^\pi(s)&=\mathbb{E}_\pi[G_t\mid S_t=s] & &\text{(定义)}\\
&=\mathbb{E}_\pi[R_t+\gamma G_{t+1}\mid S_t=s] & &\text{(回报递推)}\\
&=\underbrace{\mathbb{E}_\pi[R_t\mid S_t=s]}_{\text{当前一步奖励期望}}
+\gamma\underbrace{\mathbb{E}_\pi[G_{t+1}\mid S_t=s]}_{\text{未来回报期望}}. & &\text{(线性性)}
\end{aligned}
$$

把 $\mathbb{E}_\pi$ 换成具体的表达式:

- 当前一步用 $\pi(a\mid s)$ 加权奖励函数

$$
\begin{aligned}
    \mathbb{E}_\pi[R_t\mid S_t=s]
&=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)\,R(s,a)\\

\end{aligned}

$$

- 未来项要先按 $\pi$ 选动作 $a$、再按 $p$ 转移到 $s'$，然后把条件从 $S_t=s$ **换成** $S_{t+1}=s'$ （马尔可夫性）：

$$
\begin{aligned}
\mathbb{E}_\pi[G_{t+1}\mid S_t=s]
&=\sum_{a\in\mathcal{A}(s)}\big[\pi(a\mid s)\sum_{s'\in\mathcal{S}}p(s'\mid s,a)\,\mathbb{E}_\pi[G_{t+1}\mid S_{t+1}=s']\big]\\
&=\sum_{a\in\mathcal{A}(s)}\big[\pi(a\mid s)\sum_{s'\in\mathcal{S}}p(s'\mid s,a)\,V^\pi(s')\big].
\end{aligned}

$$

> **这一步正是马尔可夫性在起作用**：给定 $s'$ 之后，$G_{t+1}$ 的期望与"你从哪个 $s$ 来"无关，于是塌缩成 $V^\pi(s')$。没有马尔可夫性，这个条件替换不成立，贝尔曼方程也就写不出来。

放一块发现可以提出 $\sum_a\pi(a\mid s)$，得到状态价值的贝尔曼期望方程的求和形式：

$$
\boxed{
V^\pi(s)=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)\left[R(s,a)+\gamma\sum_{s'\in \mathcal{S}}p(s'\mid s,a)V^\pi(s')\right]}
$$

:::note[奖励的三种等价格式导出贝尔曼方程的三种形式]

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

三者靠一条全期望公式互相换算：

$$
R(s,a)=\sum_{s'}p(s'\mid s,a)R(s,a,s')=\sum_r r\,p(r\mid s,a)
$$

:::

### 2. 动作价值的贝尔曼期望方程

**当前价值 = 当前一步的期望奖励 + 下一状态价值的折扣**

$$
\boxed{Q^\pi(s,a)=\mathbb{E}_\pi[R_t+\gamma Q^\pi(S_{t+1},A_{t+1})\mid S_t=s,A_t=a]}
$$

#### 2.1 动作价值的贝尔曼期望方程展开

把动作也固定住，推理与上一小节完全平行：条件从 $S_t=s$ 细化为 $S_t=s,A_t=a$,因此相较于 $V^\pi$ 的贝尔曼期望方程少了 $\sum_a\pi(a\mid s)$ 这一层。

$$
\begin{aligned}
Q^\pi(s,a)&=\mathbb{E}_\pi[G_t\mid S_t=s,A_t=a]\\
&=\mathbb{E}_\pi[R_t+\gamma G_{t+1}\mid S_t=s,A_t=a]\\
&=\underbrace{\mathbb{E}_\pi[R_t\mid S_t=s,A_t=a]}_{\text{当前一步奖励期望}}
+\gamma\underbrace{\mathbb{E}_\pi[G_{t+1}\mid S_t=s,A_t=a]}_{\text{未来回报期望}}.\\
&=R(s,a)+\gamma\sum_{s'\in \mathcal{S}}p(s'\mid s,a)\,V^\pi(s').
\end{aligned}
$$

或者另一种理解思路，状态价值函数就是对动作价值函数按策略取期望：
$$
\begin{aligned}
\mathbb{E}_\pi[G_t\mid S_t=s]&=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)\,\mathbb{E}_\pi[G_t\mid S_t=s,A_t=a]
\\
\iff
V^\pi(s)&=\sum_{a\in\mathcal{A}(s)}\pi(a\mid s)Q^\pi(s,a)
\end{aligned}
$$

和状态价值函数的贝尔曼方程比较一下，就得到动作价值函数的贝尔曼期望方程：

$$
\boxed{Q^\pi(s,a)=R(s,a)+\gamma\sum_{s'\in \mathcal{S}}p(s'\mid s,a)V^\pi(s')}
$$

这里展开

$$
V^\pi(s')=\sum_{a'\in\mathcal{A}(s')}\pi(a'\mid s') Q^\pi(s',a')
$$

就能得到一个只含 $Q^\pi$ 的方程：

$$
\boxed{Q^\pi(s,a)=R(s,a)+\gamma\sum_{s'\in \mathcal{S}}p(s'\mid s,a)\sum_{a'\in\mathcal{A}(s')}\pi(a'\mid s')Q^\pi(s',a')}
$$

## 矩阵形式与动态规划

贝尔曼方程可以写成矩阵形式——本质上就是**把 $n$ 个状态的贝尔曼方程当成一个 $n$ 元一次方程组一次解掉**。前提是状态空间有限、能编号，设 $\mathcal{S}=\{s_1,\dots,s_n\}$，默认用**列向量**：

把标量形式的状态价值函数

$$
V^\pi(s)=
\sum_a\pi(a\mid s)
\left[
R(s,a)+\gamma\sum_{s'}p(s'\mid s,a)V^\pi(s')
\right]
$$

紧凑写成

$$
V^\pi(s)=r_\pi(s)+\gamma\sum_{s'}p_\pi(s'\mid s)V^\pi(s')\\
\iff \quad \forall s,s'\in\mathcal{S}\\
V^\pi(s_1)=r_\pi(s_1)+\gamma\sum_{s'}p_\pi(s'\mid s_1)V^\pi(s')\\
V^\pi(s_2)=r_\pi(s_2)+\gamma\sum_{s'}p_\pi(s'\mid s_2)V^\pi(s')\\
\vdots\\
V^\pi(s_n)=r_\pi(s_n)+\gamma\sum_{s'}p_\pi(s'\mid s_n)V^\pi(s')\\
\iff \\
\mathbf{v}=\mathbf{r}+\gamma \mathbf{P}\mathbf{v}\;
$$

| 对象     | 符号 | 形状        | 第 $i$ 个分量                                       |
| -------- | ---- | ----------- | --------------------------------------------------- |
| 价值向量 | $\mathbf{v}$  | $n\times1$  | $v_i=V^\pi(s_i)$                                    |
| 奖励向量 | $\mathbf{r}$  | $n\times1$  | $r_i=r_\pi(s_i)$ |
| 转移矩阵 | $\mathbf{P}$  | $n\times n$ | $P_{ij}=p_\pi(s_j\mid s_i)$                         |
| 单位矩阵 | $\mathbf{I}$  | $n\times n$ | $I_{ii}=1$，其余 $0$                                |

（连续或可数无限状态摊不成 $n\times n$ 的表，只能用算子视角描述。）

- $r_\pi(s)=\sum_a\pi(a\mid s)R(s,a)$ 是按策略 $\pi$ 选动作后得到的即时奖励期望
- $\mathbf{P}$ 的形状：第 $i$ 行表示从状态 $s_i$ 出发，一步后到达各个状态的概率分布；第 $j$ 列对应下一状态 $s_j$。因此，矩阵乘法 $\mathbf P\mathbf v$ 就是对所有可能的下一状态价值进行加权求和。
- $\mathbf{P}$ 是**策略诱导**的：表示按照策略 $\pi$ 行动时，从状态 $s_i$ 转移到状态 $s_j$ 的概率。

    $$
    P_{ij}=p_\pi(s_j\mid s_i)=\sum_a\pi(a\mid s_i)\,p(s_j\mid s_i,a),
    $$

- 奖励和状态转移矩阵都包含了策略选动作的随机性

### 求解：求逆 = 把所有时间步加起来

$$
\mathbf{v}=\mathbf{r}+\gamma \mathbf{P}\mathbf{v}\;\Longrightarrow\;\mathbf{v}-\gamma \mathbf{P}\mathbf{v}=\mathbf{r}\;\Longrightarrow\;(I-\gamma \mathbf{P})\mathbf{v}=\mathbf{r}.
$$

$\gamma<1$ 且 $P$ 每行和为 $1$（谱半径 $\le1$）保证 $\mathbf{I}-\gamma \mathbf{P}$ 可逆，理论上的精确解为

$$
\mathbf{v}=(\mathbf{I}-\gamma \mathbf{P})^{-1}\mathbf{r},
$$

把逆矩阵展开成几何级数（Neumann 级数）$(\mathbf{I}-\gamma \mathbf{P})^{-1}=\mathbf{I}+\gamma \mathbf{P}+\gamma^2 \mathbf{P}^2+\cdots$，代回去得：

$$
\mathbf{v}=\mathbf{r}+\gamma \mathbf{P}\mathbf{r}+\gamma^2 \mathbf{P}^2\mathbf{r}+\gamma^3 \mathbf{P}^3\mathbf{r}   +\cdots
$$

第 $k$ 项 $\gamma^kP^kr$ 是"从各状态出发、$k$ 步后领到奖励"的期望，正好与回报 $G_t=R_t+\gamma R_{t+1}+\gamma^2R_{t+2}+\cdots$ 逐项对应。**矩阵求逆就是把未来所有时间步的奖励折扣求和。** 也正因为 $\gamma^k\to0$ 级数才收敛，$(I-\gamma P)^{-1}$ 才存在。

不过状态数很大时显式求逆的计算和存储代价都很高，所以矩阵求逆主要用于理论分析，实践中用下面的**迭代法**。

## 贝尔曼更新与自举

用后继状态**当前的估计**来更新当前状态的估计，这种"用估计更新估计"的思想称为**自举（bootstrapping）**——它是后续 TD 方法的核心。

### 迭代策略评估

```text
输入：已知的 MDP 模型、策略 π、折扣因子 γ
初始化 v(s)，例如全部设为 0
重复：
    对每个非终止状态 s：
        v_new(s) = Σ_a π(a|s)[R(s,a) + γ Σ_{s'} p(s'|s,a) v(s')]        
    v ← v_new
直到 max_s |v_new(s) - v(s)| < ε
输出：v
```

在有限状态、有限动作且 $0\le\gamma<1$ 时，贝尔曼期望算子是压缩映射，迭代收敛到唯一的 $v_\pi$。该方法需要知道奖励和转移模型，属于**基于模型（model-based）** 的动态规划方法。

## 最优价值函数与贝尔曼最优方程

### 1. 最优状态价值函数

从状态 $s$ 出发，用所有策略中最优策略来指导后续动作，能得到的最大期望回报：

$$
V^*(s)=\max_\pi V^\pi(s),
$$

只能保证回报的期望是最优的，不代表在这个策略下任何一次采样都是最优。

### 2. 最优动作价值函数

从状态 $s$ 出发，先执行动作 $a$，之后用最优策略指导后续动作，能得到的最大期望回报：

$$
Q^*(s,a)=\max_\pi Q^\pi(s,a).
$$

有了这玩意，就能直接读出最优策略：在状态 $s$ 下选 $Q^*(s,a)$ 最大的动作。

### 3. 贝尔曼最优方程

与期望方程的区别在于：把"按策略对动作取期望"换成"对动作取最大"。

$$
\boxed{
V^*(s)=\max_a
\left[
R(s,a)+\gamma\sum_{s'}p(s'\mid s,a)V^*(s')
\right]
}
$$

$$
\boxed{
Q^*(s,a)=R(s,a)+\gamma
\sum_{s'}p(s'\mid s,a)
\max_{a'}Q^*(s',a')
}
$$

并且 $V^*(s)=\max_{a}Q^*(s,a)$。

### 3. 最优策略

贪心策略的公式为：
$$
\boxed{
\pi^*(s)\in\arg\max_a Q^*(s,a)
}
$$

如果随机策略
$$
\pi^*(a\mid s)>0
\implies
a\in\arg\max_{a'}Q^*(s,a')
$$

在有限状态—动作空间、$\gamma<1$ 或满足适当终止条件时，最优值函数存在且唯一；但最优策略不一定唯一：若多个动作的 $Q^*(s,a)$ 相同，它们都可组成最优策略。
