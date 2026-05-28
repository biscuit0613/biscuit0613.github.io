---
title: 非确定的有穷自动机
published: 2026-05-08
description: ''
image: ''
tags: []
category: '形式语言与自动机'
draft: false 
lang: ''
---

## 非确定的有穷自动机

之前讨论了确定的有穷自动机（DFA），所谓确定，就是 $\delta(q, a)$ 对于每个状态 $q$ 和输入符号 $a$ 都有且仅有一个结果状态。对于非确定的有穷自动机（NFA），我们放宽这个限制，允许 $\delta(q, a)$ 可以有多个结果状态

$$
(0|1)^*(00)(11)(0|1)^*
$$

NFA 的定义：一个非确定的有穷自动机（NFA）是一个五元组 $A = (Q, \Sigma, \delta, q_0, F)$，其中：

- $Q$ 是状态的有限集合；
- $\Sigma$ 是输入字母表；
- $\delta: Q \times (\Sigma \cup \{\varepsilon\}) \to \mathcal{P}(Q)=2^{|Q|}$ 是转移函数，其中 $\mathcal{P}(Q)$ 表示 $Q$ 的幂集；
- $q_0 \in Q$ 是初始状态；
- $F \subseteq Q$ 是接受状态的集合。

:::tip

与DFA的区别：

1. 转移函数 $\delta=2^{|Q|}$
2. 同一个输入符号可以有多个转移结果 

:::

## 带有空转移的非确定有穷自动机 （NFA-ε）

可能不读字符就转移状态

定义：一个带有空转移的非确定的有穷自动机（NFA-ε）是一个五元组 $A = (Q, \Sigma, \delta, q_0, F)$，其中：

- $Q$ 是状态的有限集合；
- $\Sigma$ 是输入字母表；
- $\delta: Q \times (\Sigma \cup \{\varepsilon\}) \to \mathcal{P}(Q)=2^{|Q|}$ 是转移函数，其中 $\mathcal{P}(Q)$ 表示 $Q$ 的幂集；
- $q_0 \in Q$ 是初始状态；
- $F \subseteq Q$ 是接受状态的集合。