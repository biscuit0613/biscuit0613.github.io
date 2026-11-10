---
title: RNN-BPTT，梯度消失与梯度爆炸以及对应的解决方案
published: 2026-06-26
description: ''
image: ''
tags: []
category: '04-循环神经网络'
order: 29
draft: false 
lang: ''
---

## 回顾符号定义，前向传播的过程

| 参数符号 | 含义                                 |
| -------- | ------------------------------------ |
| $U$      | 输入到隐藏层的权重矩阵               |
| $W$      | 隐藏层到隐藏层的权重矩阵（循环权重） |
| $V$      | 隐藏层到输出层的权重矩阵             |
| $b$      | 隐藏层的偏置向量                     |
| $c$      | 输出层的偏置向量                     |

| 中间量          | 含义                                 |
| --------------- | ------------------------------------ |
| $a^{(t)}$       | 第 $t$ 时刻隐藏层的净输入（激活前）  |
| $h^{(t)}$       | 第 $t$ 时刻隐藏层的输出（激活后）    |
| $o^{(t)}$       | 第 $t$ 时刻的输出层净输入            |
| $\hat{y}^{(t)}$ | 第 $t$ 时刻的预测输出（经softmax后） |
| $y^{(t)}$       | 第 $t$ 时刻的真实标签                |
| $L^{(t)}$       | 第 $t$ 时刻的损失值                  |

**前向传播公式：**

路径：$x^{(t)} \to a^{(t)} \to h^{(t)} \to o^{(t)} \to \hat{y}^{(t)}$

$$a^{(t)} = b + Wh^{(t-1)} + Ux^{(t)}$$

$$h^{(t)} = \tanh(a^{(t)})$$

$$o^{(t)} = c + Vh^{(t)}$$

$$\hat{y}^{(t)} = \text{softmax}(o^{(t)})$$

## BPTT (Backpropagation Through Time)过程

路径：$L^{(t)} \to o^{(t)} \to h^{(t)} (\to a^{(t)}) \to h^{(t-1)}\to ... \to h^{(1)}$

### 1. 对总损失求各时刻损失的梯度

$$
\frac{\partial L}{\partial L^{(t)}} = 1
$$

用$\nabla_{*}$表示对 * 求梯度，在别的文献中也叫 $\delta_{*}$

### 2. 对输出层的净输入求梯度

损失函数对输出层净输入的梯度 $\nabla_{o^{(t)}} L \triangleq \hat{y}^{(t)} - y^{(t)}$

$$
\nabla_{o^{(t)}} L = \frac{\partial L}{\partial o^{(t)}} = \frac{\partial L}{\partial L^{(t)}} \cdot \frac{\partial L^{(t)}}{\partial o^{(t)}}= \hat{y}^{(t)} - y^{(t)}
$$

### 3. 对隐藏层的输出求梯度

单个时间步内的损失函数对隐藏层输出的梯度  $\nabla_{h^{(t)}} L^{(t)}\triangleq V^T \nabla_{o^{(t)}} L$ ,是下面的方框项

整体损失函数对隐藏层输出的梯度 $\delta^{(t)} \triangleq \dfrac{\partial L}{\partial h^{(t)}}$ :

$$
\begin{aligned}
\delta^{(t)}=\frac{\partial L}{\partial h^{(t)}}
&= \boxed{\frac{\partial L^{(t)}}{\partial h^{(t)}}} + \frac{\partial L^{(t+1)}}{\partial h^{(t)}} + \frac{\partial L^{(t+2)}}{\partial h^{(t)}} + \ldots \\[1em]
&= \boxed{\frac{\partial L^{(t)}}{\partial h^{(t)}}} + \frac{\partial h^{(t+1)}}{\partial h^{(t)}} \frac{\partial L^{(t+1)}}{\partial h^{(t+1)}} + \frac{\partial h^{(t+2)}}{\partial h^{(t+1)}}\frac{\partial h^{(t+1)}}{\partial h^{(t)}} \frac{\partial L^{(t+2)}}{\partial h^{(t+2)}} + \ldots\\
&=\boxed{\frac{\partial L^{(t)}}{\partial h^{(t)}}} + \sum_{k=1}^{\tau-t} \frac{\partial}{\partial h^{(t)}} L^{(t+k)}
\end{aligned}
$$

$$
\frac{\partial}{\partial h^{(t)}} L^{(t+k)} = \frac{\partial h^{(t+1)}}{\partial h^{(t)}} \cdot \frac{\partial h^{(t+2)}}{\partial h^{(t+1)}} \cdots \frac{\partial L^{(t+k)}}{\partial h^{(t+k)}}= \left(\prod_{j=1}^{k} \frac{\partial h^{(t+j)}}{\partial h^{(t+j-1)}}\right) \frac{\partial L^{(t+k)}}{\partial h^{(t+k)}}
$$

- 对于方框里面的部分，$L^{(t)}$ 只依赖于 $h^{(t)}$，所以可以直接求导；

- 对于后续时刻的 $L^{(t+1)}, L^{(t+2)}, \ldots$，它们依赖于 $h^{(t)}$ 是通过 $h^{(t+1)}, h^{(t+2)}, \ldots$ 传递，所以需要用链式法则展开，但是展开依旧是一坨乘积，没法算

- 距离越远，乘积越长，容易出现梯度消失或梯度爆炸问题，导致训练困难。

注意递推关系，把 $t$ 换成 $t+1$：

$$
\begin{aligned}
\delta^{(t+1)}=\frac{\partial L}{\partial h^{(t+1)}}
&= \frac{\partial L^{(t+1)}}{\partial h^{(t+1)}} + \frac{\partial L^{(t+2)}}{\partial h^{(t+1)}} + \frac{\partial L^{(t+3)}}{\partial h^{(t+1)}} + \ldots \\[1em]
&= \frac{\partial L^{(t+1)}}{\partial h^{(t+1)}} + \frac{\partial h^{(t+2)}}{\partial h^{(t+1)}} \frac{\partial L^{(t+2)}}{\partial h^{(t+2)}} + \frac{\partial h^{(t+3)}}{\partial h^{(t+2)}}\frac{\partial h^{(t+2)}}{\partial h^{(t+1)}} \frac{\partial L^{(t+3)}}{\partial h^{(t+3)}} + \ldots\\[1em]
\end{aligned}
$$

这个两边同时乘以 $\dfrac{\partial h^{(t+1)}}{\partial h^{(t)}}$，就可以得到 $\delta^{(t)}$  **非方框** 中的部分！

重大发现：$\delta^{(t)}$ 可以递推计算：

$$
\begin{aligned}
\delta^{(t)}=\dfrac{\partial L}{\partial h^{(t)}}&= \frac{\partial L^{(t)}}{\partial h^{(t)}} + \left(\frac{\partial h^{(t+1)}}{\partial h^{(t)}}\right)^T \delta^{(t+1)}\\[5pt]
&=  \left(\frac{\partial o^{(t)}}{\partial h^{(t)}}\right)^T \frac{\partial L^{(t)}}{\partial o^{(t)}}  +  \left(\frac{\partial h^{(t+1)}}{\partial h^{(t)}}\right)^T \frac{\partial L}{\partial h^{(t+1)}} \\[1em]
&= V^T \nabla_{o^{(t)}} L + W^T\text{diag}(1 - (h^{(t+1)})^2) \nabla_{h^{(t+1)}} L
\end{aligned}
$$

其中 $\dfrac{\partial h^{(t+1)}}{\partial h^{(t)}}$ 是通过链式法则展开得到的：

$$
\begin{aligned}
h^{(t+1)} &= \tanh(a^{(t+1)})\\
a^{(t+1)} &= b + W\boxed{h^{(t)}} + Ux^{(t+1)}\\[2pt]
\Rightarrow \frac{\partial h^{(t+1)}}{\partial h^{(t)}} &= \frac{\partial h^{(t+1)}}{\partial a^{(t+1)}} \cdot \frac{\partial a^{(t+1)}}{\partial h^{(t)}} = W^T\text{diag}(1 - (h^{(t+1)})^2)
\end{aligned}
$$

### 对参数求梯度

注意每个参数在所有时刻共享，所以要对所有时刻求和。

$$
\begin{aligned}
\nabla_{U} L &= \sum_t \text{diag}(1 - (h^{(t)})^2) \nabla_{h^{(t)}} L^{(t)} \cdot (x^{(t)})^T\\
\nabla_{W} L &= \sum_t \text{diag}(1 - (h^{(t)})^2) \cdot \nabla_{h^{(t)}} L^{(t)} \cdot (h^{(t-1)})^T\\
\nabla_{V} L &= \sum_t \nabla_{o^{(t)}} L \cdot (h^{(t)})^T\\
\nabla_{b} L &= \sum_t \text{diag}(1 - (h^{(t)})^2) \cdot \nabla_{h^{(t)}} L\\
\nabla_{c} L &= \sum_t \nabla_{o^{(t)}} L
\end{aligned}
$$

## 长期依赖

当间隔时间步很长时，$\delta^{(t)}$ 中的乘积项 $\prod_{j=1}^{k} \dfrac{\partial h^{(t+j)}}{\partial h^{(t+j-1)}}$ 会导致梯度消失或梯度爆炸问题，训练困难。

在消失的情况下，$t$ 时刻的梯度对 $t+k$ 时刻以及之前的损失几乎没有影响，导致模型无法学习长期依赖关系。

## 梯度消失与梯度爆炸的解决方案

### 1. 截断梯度

实际应用中，两种方式性能表现类似

- 方式1：在参数更新之前，逐元素地截断Mini-batch
产生的参数梯度
- 方式2：在参数更新之前，整体约束参数梯度大小
（不改变梯度方向）

### 2. 时间维度的跳跃连接

直接构造从 $t$ 时刻单元到 $t + d$ 时刻单元的连接

### 3. 渗漏单元

对于隐藏层之间的连接：

从开始的 $h^{(t)} = \tanh(b + Wh^{(t-1)} + Ux^{(t)})$ 改结构成：

$$
h^{(t)} = \alpha h^{(t-1)} + (1 - \alpha) g(x^{(t)}, h^{(t-1)})
$$

- $g$ 可以是任意的非线性函数，比如 $g(x^{(t)}, h^{(t-1)}) = \tanh(b + Wh^{(t-1)} + Ux^{(t)})$，也可以是其他的函数。
- $\alpha$ 是一个小于 1 的常数，表示“渗漏”比例。它可以让梯度在时间维度上有一个“泄漏”，从而缓解梯度消失问题。
- $\alpha\approx 1$ 容易饱和。
- $\alpha\approx 0$ 退化为普通RNN。
