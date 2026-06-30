---
title: 光流（二）——Horn-Schunck与金字塔LK
published: 2026-06-23
description: 'HS全局平滑假设、能量函数（数据项+平滑项）、欧拉-拉格朗日方程推导、迭代求解、金字塔LK图像扭曲与增量光流、三种光流方法对比总结'
image: ''
tags: []
category: '计算机视觉'
order: 11
draft: false
lang: ''
---

前一篇文章建立了光流的基础：亮度恒常性假设和小运动假设共同导出了光流约束方程 $I_x u + I_y v + I_t = 0$。一个方程、两个未知数，欠定问题的不同解决方式定义了不同的光流算法。LK 用局部空间一致性来约束，本篇的 Horn-Schunck 方法则走向了另一个方向——全局平滑性。

## HS 的独特假设：全局平滑光流场

Horn-Schunck（HS）引入了与 LK 完全不同的额外假设：

**全局平滑性**：同一物体表面的相邻像素通常属于同一运动，因此整个光流场是连续且平滑的。光流的突变只发生在运动边界处，而运动边界只占图像的很小一部分。

数学上，平滑性约束要求光流场的梯度尽可能小：

$$
\|\nabla u\|^2 + \|\nabla v\|^2 \approx 0
$$

其中 $\nabla u = (\partial u / \partial x,\ \partial u / \partial y)$，$\nabla v$ 同理。

## 能量函数

HS 将光流求解转化为一个能量泛函的极值问题，能量函数包含两项：

$$
E(u, v) = \underbrace{\iint (I_x u + I_y v + I_t)^2 \, dx \, dy}_{\text{数据项（Data Term）}} + \underbrace{\iint \alpha \big( \|\nabla u\|^2 + \|\nabla v\|^2 \big) \, dx \, dy}_{\text{平滑项（Smoothness Term）}}
$$

- **数据项**：光流必须满足约束方程，惩罚偏离亮度恒常性的区域。
- **平滑项**：惩罚光流场的空间梯度，迫使相邻像素的光流趋于一致。
- $\alpha$：平衡参数，控制两项的权重。$\alpha$ 很小 → 数据优先（可能产生噪点）；$\alpha$ 很大 → 平滑优先（可能抹掉运动边界）。

在运动边界处，数据项希望光流突变以解释亮度变化，平滑项则阻止突变。没有任何一个 $(u,v)$ 能让两项同时为 0，因此 HS 寻找的是使整体能量最小的折衷解。

## 欧拉-拉格朗日方程

根据变分法，能量泛函 $E = \iint L \, dx \, dy$ 取极值的必要条件是被积函数 $L$ 满足欧拉-拉格朗日方程。记

$$
L = (I_x u + I_y v + I_t)^2 + \alpha(u_x^2 + u_y^2 + v_x^2 + v_y^2)
$$

分别对 $u$ 和 $v$ 及其偏导数列出欧拉-拉格朗日方程：

$$
\begin{cases}
\dfrac{\partial L}{\partial u} - \dfrac{d}{dx}\dfrac{\partial L}{\partial u_x} - \dfrac{d}{dy}\dfrac{\partial L}{\partial u_y} = 0 \\[1em]
\dfrac{\partial L}{\partial v} - \dfrac{d}{dx}\dfrac{\partial L}{\partial v_x} - \dfrac{d}{dy}\dfrac{\partial L}{\partial v_y} = 0
\end{cases}
$$

代入各项偏导数：

$$
\begin{aligned}
\frac{\partial L}{\partial u} &= 2 I_x (I_x u + I_y v + I_t), &
\frac{\partial L}{\partial u_x} &= 2 \alpha u_x, &
\frac{\partial L}{\partial u_y} &= 2 \alpha u_y \\[4pt]
\frac{\partial L}{\partial v} &= 2 I_y (I_x u + I_y v + I_t), &
\frac{\partial L}{\partial v_x} &= 2 \alpha v_x, &
\frac{\partial L}{\partial v_y} &= 2 \alpha v_y
\end{aligned}
$$

得到两个 PDE：

$$
\begin{cases}
I_x (I_x u + I_y v + I_t) - \alpha (u_{xx} + u_{yy}) = 0 \\[1em]
I_y (I_x u + I_y v + I_t) - \alpha (v_{xx} + v_{yy}) = 0
\end{cases}
$$

记拉普拉斯算子 $\nabla^2 u = u_{xx} + u_{yy}$，$\nabla^2 v = v_{xx} + v_{yy}$：

$$
\alpha \nabla^2 u = I_x (I_x u + I_y v + I_t),\quad
\alpha \nabla^2 v = I_y (I_x u + I_y v + I_t)
$$

## 离散化与迭代求解

在像素网格上，拉普拉斯算子可以用邻域平均近似：

$$
\nabla^2 u \approx \bar{u} - u,\quad
\nabla^2 v \approx \bar{v} - v
$$

其中 $\bar{u}$ 是像素 $(x,y)$ 的四邻域平均光流：$\bar{u} = \frac{1}{4}(u_{\text{上}} + u_{\text{下}} + u_{\text{左}} + u_{\text{右}})$，$\bar{v}$ 同理。

代入 PDE 得到迭代公式：

$$
u^{k+1} = \bar{u}^k - \frac{I_x (I_x \bar{u}^k + I_y \bar{v}^k + I_t)}{\alpha + I_x^2 + I_y^2}
$$

$$
v^{k+1} = \bar{v}^k - \frac{I_y (I_x \bar{u}^k + I_y \bar{v}^k + I_t)}{\alpha + I_x^2 + I_y^2}
$$

### HS 算法流程

1. 初始化光流场 $u^0, v^0 = 0$
2. 计算图像梯度 $I_x, I_y$ 和时间梯度 $I_t$
3. 对每个像素计算邻域平均 $\bar{u}^k, \bar{v}^k$
4. 按迭代公式更新 $u^{k+1}, v^{k+1}$
5. 重复 3–4 直到收敛（变化量小于阈值）或达到最大迭代次数

HS 的收敛速度相对较慢，但好处是不需要显式检测纹理特征，即使在平坦区域也能通过平滑项的扩散作用获得光流估计。

## 金字塔 LK：突破小运动假设

标准 LK 依赖于小运动假设，当物体位移超过 2–3 个像素时，泰勒展开线性化失效。金字塔 LK 通过由粗到细的策略解除这一限制。

### 核心思路

1. 将图像构建为高斯金字塔，从上到下分辨率逐层增加。
2. 在顶层（最小分辨率）运行标准 LK，大运动在顶层已经被缩放到小位移。
3. 将顶层的计算结果映射到下一层作为初始猜测，对图像做 warp（扭曲）以抵消已估计的运动，剩余残差是微小位移，适用标准 LK。
4. 逐层向下，每层做增量求解。

### 算法流程

设图像金字塔共 $n+1$ 层，$L_0$ 为原始图像，$L_n$ 为顶层（最小分辨率）。

1. 在顶层 $L_n$ 上运行标准 LK，得到光流估计 $g_n = (u_n, v_n)^T$。

2. 从顶层向底层遍历 $i = n-1, \dots, 0$：
   - 将上一层光流映射到当前层：$g_i = 2 \times g_{i+1}$（分辨率加倍，光流也加倍）。
   - 用 $g_i$ 对第 2 帧图像做 warp（图像扭曲）：$I'_2 = I_2(x + u_i, y + v_i)$。
   - warp 后的 $I'_2$ 与第 1 帧已大致对齐，剩余运动 $\Delta g_i$ 落在小运动范围内，用标准 LK 求解残差光流。
   - 本层实际光流：$g_i \leftarrow g_i + \Delta g_i$。

3. 返回 $g_0$ 作为最终光流场。

### 为什么要 warp

大运动导致灰度函数 $I(x,y,t)$ 的变化是非线性的，直接对泰勒展开等效于假设线性，自然失败。warp 先将图像按已有的"粗略估计"搬过去，把大运动抵消掉，剩下的残差就足够小了。这本质上是一种增量求解的工程智慧。

:::tip 三种光流方法对比

| 维度 | LK（标准） | HS | 金字塔 LK |
|------|-----------|-----|-----------|
| 解决欠定的方式 | 局部空间一致性 | 全局平滑性 | 同标准 LK |
| 独特假设 | 邻域内光流相同 | 全图光流平滑 | 多尺度+增量求解 |
| 小运动假设 | 依赖 | 依赖 | **不依赖**（warp 消除大运动） |
| 纹理需求 | 强（角点/纹理区域） | 弱（平滑项可扩散） | 强（底层仍是 LK） |
| 平坦区域表现 | 失效 | 可估计（但不准确） | 失效 |
| 计算方式 | 闭式最小二乘 | 迭代求解 | 逐层 LK + warp |

:::

:::tip 光流假设层级总结

$$
\underbrace{\text{亮度恒常性} + \text{小运动}}_{\text{所有方法共享}} \rightarrow \underbrace{I_x u + I_y v + I_t = 0}_{\text{光流约束方程}}
$$

$$
\begin{cases}
\text{LK: } + \ \text{局部空间一致性} \rightarrow \text{最小二乘闭式解} \\[4pt]
\text{HS: } + \ \text{全局平滑性} \rightarrow \text{能量泛函 + 迭代解} \\[4pt]
\text{Pyr-LK: } + \ \text{局部空间一致性} + \text{图像金字塔 + warp} \rightarrow \text{大运动兼容}
\end{cases}
$$

:::

