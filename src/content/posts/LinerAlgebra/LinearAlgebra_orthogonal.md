---
title: 线性代数：正交与正交补，直和分解
published: 2026-03-11
description: ''
image: ''
tags: []
category: ''
draft: false 
lang: ''
---

“正交补”（Orthogonal Complement）这个概念，其实就是把 **“垂直”** （正交这一块）和 **“填满”** （补这一块）这两个想法结合在了一起。

## 正交补

**定义**

如果 $S \subseteq V$，$V$ 为内积空间，则 $S$ 的正交补表示为$S^\perp$:

$$
 S^\perp = \{v \in V \mid v \perp s, \forall s \in S\}
$$

:::tip

如果把一个大空间$V$（比如 $\mathbb{R}^n$）看作一个房间，而子空间 $S$ 是这个房间里的一块地毯，那么 $S$ 的正交补 $S^\perp$（读作 S-perp）就是所有与这块地毯完全垂直的向量所组成的空间。

:::

### 1 + 1 = 全部

直和分解（Direct Sum Decomposition）是线性代数中的一个重要概念，它描述了一个向量空间如何被分解成**两个子空间**的和，并且这两个子空间之间**没有重叠**。以此类推，可以得到一个向量被分解成来自两个没有重叠的次空间的部分的唯一表示：

对于任意 $v \in V$，存在**唯一一对** $v_S \in S, v_\perp \in S^\perp$，使得 $v = v_S + v_\perp$

:::tip

任何一个向量 $x$，都可以唯一地分解为两个部分的相加：$x = v + v_\perp$。其中 $v$ 属于原空间，$v_\perp$ 属于正交补。

:::

从维度的角度看

维度相加：$\dim(S) + \dim(S^\perp) = \dim(V)$。
