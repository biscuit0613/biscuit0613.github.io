---
title: GCN：图神经网络
published: 2026-10-19
description: '图神经网络的概念和一些常见的图神经网络模型'
image: ''
tags: []
category: '图神经网络'
draft: false 
lang: ''
---

## 图神经网络

图神经网络主要处理 **非欧几里得结构** 的图数据，如社交网络、知识图谱、论文引用网络、化学分子、交通网络、电商网络等

:::tip[欧几里得结构]
指传统的网格状数据，如图像、文本等，具有规则的几何形状和明确的坐标系。
:::

和其他的神经网络得到图/句子的嵌入式向量表示类似，图神经网络的 **核心和关键** 就是要得到节点或者边的嵌入式低维向量表示，使原图中相似的节点在嵌入空间中也接近。

嵌入向量的用途：节点/边分类、回归、聚类、链接预测、可视化、重构原始图等

### 核心思想：消息传递（Message Passing）

通过迭代的方式，让每个节点聚合其邻居节点的信息，从而学习到节点的表示（Embedding）

一层传递通常聚合邻居节点的信息（一跳），多层就有更大的感受野（多跳），可以融合更广范围的邻居信息。

一般分为三个步骤：

1. Message：邻居节点生成并发送消息。
2. Aggregate：聚合所有邻居的消息。
3. Update：结合自身特征，更新节点表示。

$$
m_{u\rightarrow v}^{(k)}
=
M^{(k)}(h_u^{(k)},h_v^{(k)},e_{uv})
$$

$$
m_v^{(k)}
=
\operatorname{AGG}
\left(
\{m_{u\rightarrow v}^{(k)}:u\in N(v)\}
\right)
$$

$$
h_v^{(k+1)}
=
U^{(k)}(h_v^{(k)},m_v^{(k)})
$$

$h_v^{(k)}$：节点 $v$ 在第 $k$ 层的特征。

$N(v)$：节点 $v$ 的邻居集合。

$M$：消息生成函数。

AGG：聚合函数，如 sum、mean、max、attention 等。

$U$：更新函数，大多包含concat拼接和非线性激活函数。

### 典型模型

- 浅层图嵌入（Shallow Embedding）
  - DeepWalk模型（深度优先）
  - LINE模型（宽度优先）
- 深层图神经网络（Deep GNN）
  - 图卷积神经网络GCN
  - 图注意力网络GAT
  - GraphSAGE

## 浅层图嵌入（Shallow Embedding）

### DeepWalk 模型：基于深度优先的随机游走

序列采样方法：**随机游走**（Random Walk）：

从一个起点节点出发，每一步都随机选择一个相邻节点走过去，重复若干步，得到一条节点序列。然后用 skip-gram 模型学习节点的嵌入式向量表示，使得在随机游走中相邻的节点在嵌入空间中也接近。

算法步骤：

- Input:
  - 图 $G=(V,E)$，点集合 $V$，边集合 $E$
  - 窗口大小为 $w$，嵌入维度为 $d$。skip- gram 模型的窗口大小
  - 的随机游走长度 $l$，
  - 每个节点的游走次数 $\gamma$，做起点的节点需要游走多少次
- Output: 节点表征矩阵 $\Phi \in \mathbb{R}^{|V| \times d}$；

伪代码：

$$
\boxed{
    \begin{aligned}
       &\Phi=\mathcal{U}^{|V| \times d}(-1,1) \quad \text{初始化节点嵌入向量}
       \\
       &V\to T\text{节点集合构造二叉树用于层次softmax}\\
        &\text{for} i=1 \text{ to } \gamma \text{ do}
        \\
        &\quad \mathcal{O}=\operatorname{shuffle}(V) \quad \text{打乱节点顺序}
        \\
        &\quad\text{for} v \in \mathcal{O} \text{ do}
        \\
        &\quad\quad\text{随机游走} \quad \text{walk}=\operatorname{RandomWalk}(G,v,l)
        \\
        &\quad\quad\text{for} j=1 \text{ to } l \text{ do}
        \\
        &\quad\quad\quad\text{for} k=\max(0,j-w) \text{ to } \min(l,j+w) \text{ do}
        \\
        &\quad\quad\quad\text{if } k \neq j \text{ then}
        \\
        &\quad\quad\quad\text{更新节点嵌入向量} \quad \Phi[\text{walk}[j]] \leftarrow \Phi[\text{walk}[j]] - \eta \nabla_{\Phi[\text{walk}[j]]} \log P(\text{walk}[k] \mid \Phi[\text{walk}[j]])
    \end{aligned}
}
$$

优势：

- 并行化。随机游走发生在网络的局部区域，因而可以同时以图中不同节点为起点进行随机游走以获得采样序列，效率较高；
- 适应性。由于游走的局部性，对于较大的图，即使网络中个别点或边发生变化，也只会影响到个别随机游走序列，因而不一定需要对整个图重新进行随机游走处理

### LINE 模型：基于宽度优先的邻域相似度

基本思想：在图中距离较小（或相似度较高）的点，在新的低维嵌入空间中也应尽可能接近。

- 一阶相似度：每条边$(u,v)$的权重 $w_{uv}$，表示节点 $u$ 和节点 $v$ 的一阶相似度，无直连的点的一阶相似度为 0
- 二阶邻近性（Second-order Proximity）：两个节点是否拥有相似的邻居

- 对于加权图，可以直接用权
- 对于无权图，$w_{uv}=1$，表示节点 $u$ 和节点 $v$ 之间有一条边相连

## GCN 模型：图卷积神经网络

从图论中提取出三个重要的矩阵：

- 邻接矩阵 $A$：表示图中节点之间的连接关系
- 度矩阵 $D$：图中与每个节点相连的边的个数，对角矩阵，$D_{ii}=\sum_j A_{ij}$，$D_{ij}=0$，$i\neq j$
- 特征矩阵 $X$：每个节点的特征向量组成的矩阵，$X \in \mathbb{R}^{N \times d}$，其中 $N$ 是节点数，$d$ 是每个节点的特征维度

### 局部卷积：聚合(aggregate)

对于图来说，局部邻域就是其邻接节点，节点 $i$ 的新特征，等于他的邻居节点的特征向量乘以对应边权重之后的加权和，权重由邻接矩阵 $A$ 决定。

$$
agg(X_i) = \sum_{j \in N(i)} A_{ij} X_j
$$

其中

- $N(i)$ 表示节点 $i$ 的邻居节点集合
- $A_{ij}$ 表示节点 $i$ 和节点 $j$ 是否有边相连，若有边相连则为 1(无权)或权重（加权），否则为 0

推广到整张图，邻居聚合可以表示为矩阵形式：

$$
agg(X) = AX
$$

这时还没有考虑自身，加上自身节点的特征向量，邻居聚合可以表示为：

$$
\begin{aligned}
    agg(X_i) &= \sum_{j \in N(i)} A_{ij} X_j+X_i \quad &\text{对于节点 }i\\
    \tilde{A}&= A+I \quad &\text{邻接矩阵加上单位矩阵}\\
    agg(X) &= \tilde{A}X \quad &\text{对于整张图}
\end{aligned}
$$

归一化：图中节点度动态变化，常用几何平均归一化：

$$
\begin{aligned}
    \tilde{D}_{ii} &= \sum_j \tilde{A}_{ij} \quad &\text{度矩阵}\\
    agg(X) &= \tilde{D}^{-\frac{1}{2}}\tilde{A}\tilde{D}^{-\frac{1}{2}}X \quad &\text{归一化邻居聚合}
\end{aligned}
$$

### 前向传播到隐藏层

聚合之后，乘以权重参数并过激活函数，得到隐藏层的输出：

$$
\begin{aligned}
    H^{(l+1)} &= \sigma(\tilde{D}^{-\frac{1}{2}}\tilde{A}\tilde{D}^{-\frac{1}{2}}H^{(l)}W^{(l)})\\
    H^{(0)} &= X
\end{aligned}
$$

### 特点

- 原始 GCN 实验设定是直推式：训练和测试基于同一图结构；

- 随着层数加深，节点感受野扩大，可融合更广范围邻居信息；

- 对带标签节点计算交叉熵损失，反向传播优化参数。

## GAT 图注意力网络

GCN依赖图结构（直推式），缺少泛化能力，GAT更擅长处理归纳（inductive）任务中的动态图，即测试阶段的图结构可以和训练阶段的图有所不同

GAT用注意力机制对一阶邻域节点做加权求和，让模型学习对不同节点的关注程度（注意力系数），然后用注意力系数对邻居节点的特征向量做加权求和，得到节点的表示。

### 注意力系数的计算

对于节点 $i$ 的每个邻居节点 $j$：

$$
e_{ij} = \sigma(\mathbf{a}[W \mathbf{h_i} || W \mathbf{h_j}])
$$

然后用 softmax 函数归一化，得到注意力系数：

$$
\alpha_{ij} = \frac{\exp(e_{ij})}{\sum_{k \in N(i)} \exp(e_{ik})}
$$

- 先对节点 $i,j$ 的特征向量 $\mathbf{h_i}, \mathbf{h_j}$ 做线性变换 $W$ 投影到隐藏层维度 $d$
- 然后拼接 $[\cdot||\cdot]$，维度 $\mathbb{R}^d\rightarrow\mathbb{R}^{2d}$
- 再用一个共享的注意力向量 $\mathbf{a}$ 得到注意力系数 $e_{ij}$
- 有时候exp里面会用$\sigma=$ LeakyReLU 激活函数，防止梯度消失

### 节点特征向量更新（aggregate）

这里邻居 $N(i)$ 包括节点 $i$ 本身，节点 $i$ 的新特征向量是其邻居节点的特征向量加权求和：

$$
\mathbf{h_i'} = \sigma(\sum_{j \in N(i)} \alpha_{ij} W \mathbf{h_j})
$$
