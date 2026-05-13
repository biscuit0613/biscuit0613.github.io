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

之前讨论了确定的有穷自动机（DFA），所谓确定，就是 $\delta(q, a)$ 对于每个状态 $q$ 和输入符号 $a$ 都有且仅有一个结果状态。对于非确定的有穷自动机（NFA），我们放宽这个限制，允许 $\delta(q, a)$ 可以有多个结果状态

$$
(0|1)^*(00)(11)(0|1)^*
$$