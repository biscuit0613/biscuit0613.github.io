---
title: 线性规划的对偶问题
published: 2026-05-05
description: ''
image: ''
tags: []
category: '06-优化算法'
draft: false 
lang: ''
---

:::tip

抽象的对偶来自共轭函数——Fenchel对偶，拉格朗日对偶是对偶理论的一种具体形式，而线性规划的对偶问题是拉格朗日对偶在特定约束条件下的一个特例。

:::

## 拉格朗日对偶问题的定义

回顾拉格朗日函数及其对偶函数和对偶问题，这里不过多赘述

## 线性规划的对偶问题

LP对称形式的对偶问题定义如下：

LP:

$$
\begin{aligned}
\max z &= c^T x \\
s.t. Ax &\geq b \\
x &\geq 0
\end{aligned}
$$

DP

$$
\begin{aligned}
\min f &= b^T y \\
s.t. A^T y &\leq c \\
y &\geq 0
\end{aligned}
$$

含义：为每种资源赋予一个单价 $y$（对偶变量），使得在保证“成本不低于收益”的前提下，总资源价值 $b^T y$ 最小。

如果LP是标准形式

LP:

$$
\begin{aligned}
\max z &= c^T x \\
s.t. Ax &= b \\
x &\geq 0
\end{aligned}
$$

DP:(和上面DP的区别是y没有非负约束了)

$$
\begin{aligned}
\min f &= b^T y \\
s.t. A^T y &\leq c \\
\end{aligned}
$$

| 原问题 (Primal)          | 对偶问题 (Dual)          |
| ------------------------ | ------------------------ |
| 目标函数系数 $c$         | 约束条件的右端向量 $c$   |
| 约束条件的右端向量 $b$   | 目标函数系数 $b$         |
| 约束矩阵 $A$             | 转置矩阵 $A^T$           |
| 变量 $x_j \ge 0$         | 第 $j$ 个约束为 $\ge$ 型 |
| 第 $i$ 个约束为 $\le$ 型 | 变量 $y_i \ge 0$         |
| 目标函数 $\max$          | 目标函数 $\min$          |

:::tip

关于这个对偶是怎么来的

把LP统一成不等式约束为 $g(x) \le 0$ 的形式:$Ax-b \le 0$，给目标函数 $\max c^T x$ 加个负号符合拉格朗日乘子法的最小化问题。构造拉格朗日函数：

$$
L(x, y) = -c^T x + y^T (Ax - b)
$$

其中 $y \ge 0$ ，是拉格朗日乘子。对 $x$ 取下确界，构造对偶函数

$$
g(y) = \inf_x L(x, y) = \inf_x (-c^T x + y^T (Ax - b)) \\
= -y^T b + \inf_x ((-c^T + y^T A) x)
$$

求inf：如果 $-c^T + y^T A \lt 0$，则 $x\to \infty$ ,$g(y) = -\infty$,(注意原LP里面对 $x$ 的非负约束)，如果 $-c^T + y^T A \ge 0$，则 $x\to 0$ ,$g(y) = y^T b$。所以对偶问题就是：

$$
\begin{aligned}
\max_{y \ge 0} g(y) &= \max_{y \ge 0} -y^T b \\[1ex]
s.t. & -c^T + y^T A \ge 0 \\
\end{aligned}
$$

整理一下

$$
\begin{aligned}
\min_{y \ge 0}f &= b^T y \\[1ex]
s.t.  A^T y &\le c \\
y &\ge 0
\end{aligned}
$$

如果原问题是个标准形式，也就是 $Ax=b$,这个等式约束可以换成两个不等式约束 $Ax \le b$ 和 $-Ax \le -b$，同样的道理构造拉格朗日函数，这时候需要用到两个乘子 $y_1$ 和 $y_2$，分别对应 $Ax \le b$ 和 $-Ax \le -b$ 这两个约束。

$$
L(x, y_1, y_2) = -c^T x + y_1^T (Ax - b) + y_2^T (-Ax + b)
$$

$$
g(y_1, y_2) = \inf_x L(x, y_1, y_2) = \inf_x (-c^T x + y_1^T (Ax - b) + y_2^T (-Ax + b)) \\
= -y_1^T b + y_2^T b + \inf_x ((-c^T + y_1^T A - y_2^T A) x)
$$

如果 $-c^T + y_1^T A - y_2^T A \lt 0$，则 $x\to \infty$ ,$g(y_1, y_2) = -\infty$,(注意原LP里面对 $x$ 的非负约束)，如果 $-c^T + y_1^T A - y_2^T A \ge 0$，则 $x\to 0$ ,$g(y_1, y_2) = -y_1^T b + y_2^T b$。所以对偶问题就是：

$$
\begin{aligned}
\max_{y_1 \ge 0, y_2 \ge 0} g(y_1, y_2) &= \max_{y_1 \ge 0, y_2 \ge 0} -y_1^T b + y_2^T b \\[1ex]
s.t. & -c^T + y_1^T A - y_2^T A \ge 0 \\
\end{aligned}
$$

整理一下

$$
\begin{aligned}
\min_{y_1 \ge 0, y_2 \ge 0}f &= b^T y_1 - b^T y_2 \\[1ex]
s.t. & A^T y_1 - A^T y_2 \le c \\
\end{aligned}
$$

回忆一下化标准型流程中处理无约束变量的步骤：对于无约束变量 $x_j$，引入两个非负变量 $x_j^+ \ge 0$ 和 $x_j^- \ge 0$，使得 $x_j = x_j^+ - x_j^-$。这样就将无约束变量转化为两个非负变量。这里的 $y_1$ 和 $y_2$ 就是对应于原问题中无约束变量的两个非负变量。最终我们可以将 $y = y_1 - y_2$ 作为对偶变量，这个 $y$ 就没有非负约束了。

:::

## 线性规划的对偶理论

A. 弱对偶性 (Weak Duality)

若 $x$ 是原问题的可行解，$y$ 是对偶问题的可行解，则：

$$
c^T x \le b^T y
$$

推论1（最优性准则）：如果原问题有一个可行解 $x$ 和对偶问题有一个可行解 $y$，且满足 $c^T x = b^T y$，则 $x$ 和 $y$ 都是各自问题的最优解。

推论2：若LP有可行解，那么LP有最优解的充要条件是：DP有可行解。或者说，LP有可行解而DP无可行解 $\implies$ LP无最优解。

推论3：若DP有可行解，那么DP有最优解的充要条件是：LP有可行解。或者说，DP有可行解而LP无可行解 $\implies$ DP无最优解。

B. 强对偶性/主对偶定理 (Strong Duality)

若原问题有最优解 $x^*$，则对偶问题必有最优解 $y^*$，且：

$$
c^T x^* = b^T y^*
$$

反之亦然

C. 互补松弛性 (Complementary Slackness)

这是求解中最有用的性质。在最优解处：如果某个资源有剩余（$Ax < b$），那么该资源的对偶价格（影子价格）一定为 0（$y = 0$）。如果某个资源的影子价格大于 0（$y > 0$），那么该资源一定被全部用完（$Ax = b$）。

D. 解的状态对应

原问题有最优解 $\iff$ 对偶问题有最优解。

原问题具有无界解 $\implies$ 对偶问题无可行解。

原问题无可行解 $\implies$ 对偶问题具有无界解或无可行解。
