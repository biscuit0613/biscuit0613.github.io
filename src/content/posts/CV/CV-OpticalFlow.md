---
title: 光流（Optical Flow）算法
published: 2026-06-23
description: ''
image: ''
tags: []
category: '计算机视觉'
order: 9
draft: false 
lang: ''
---

## 光流

**光流**：是指由于观察者（比如摄像机或人眼）与场景之间的相对运动，在视觉场景中形成的物体、表面和边缘的表观运动模式。

- 表观运动：它指的并不是物体绝对意义上的物理位移，而是在画面（比如摄像头的每一帧图像）里看起来在移动的样子。
- 相对运动：这种运动既可以是因为物体自己在动，也可以是因为观察者自己在动。只要两者之间有位置变化，就会产生光流。
- 物体、表面和边缘：光流捕捉的不是单一像素的乱跳，而是由这些视觉元素组成的规律的运动场

问题描述：给定两个连续的图像帧，计算每个像素点在两帧之间的位移向量（即光流向量）。

## 光流算法的基本假设

无论是哪种算法都有两个核心假设：光流的计算依赖于两个基本假设：

### 1. 亮度/色彩恒常性假设（Brightness Constancy Assumption）

含义：同一物体点的亮度值在 **连续帧** 中应保持不变。

支持直接对单个像素的亮度值进行跨帧像素级的直接比较比对（而非基于图像特征的比较，无需依赖边缘、纹理等高层特征）

$$
I(x(t), y(t), t) = C
$$

### 2. 小运动（Small Motion）

含义：相邻两帧之间，物体的运动位移非常微小（通常指1~2个像素以内）。

正是因为位移足够小，我们才敢对图像函数进行泰勒展开（Taylor Expansion），把非线性的变化转化为线性的偏导数计算。

记像素点在极小时间步长 $\delta t$ 的位移为 $(\delta x=u\delta t, \delta y=v\delta t )$，亮度恒常性假设可以写成如下形式：

$$
I(x(t)+u\delta t, y(t)+v\delta t, t+\delta t)= I(x(t), y(t), t)
$$

## 光流的数学模型

对 $I(x+u\delta t, y+v\delta t, t+\delta t)= I(x, y, t)$ 左边泰勒展开，得到：

$$
I(x+u\delta t, y+v\delta t, t+\delta t) = I(x, y, t) + \frac{\partial I}{\partial x}u\delta t + \frac{\partial I}{\partial y}v\delta t + \frac{\partial I}{\partial t}\delta t = I(x, y, t)\\[1em]
\therefore \frac{\partial I}{\partial x}\frac{dx}{dt} + \frac{\partial I}{\partial y}\frac{dy}{dt} + \frac{\partial I}{\partial t} = 0
$$

记作 $I_x u + I_y v + I_t = 0$

- $I_x, I_y, I_t$ 分别是图像在 $x, y, t$ 方向的**偏导数**，
- $u, v$ 分别是**光流**在 $x, y$ 方向的**分量**。
- $I_t$ 是图像在时间方向的变化率，反映了像素亮度随时间的变化。

如何计算？

### 图像梯度 $I_x, I_y$ 的计算（已知量）

可以用 Sobel 算子、Prewitt 算子、Scharr 算子等方法计算图像在 $x, y$ 方向的梯度。

### 时间梯度 $I_t$ 的计算（已知量）

可以用简单的 **帧间差分** 计算时间梯度：

$$
I_t = I(x, y, t+\delta t) - I(x, y, t)
$$

### 光流向量 $(u, v)$ 的求解（未知量）

一个方程 $I_x u + I_y v + I_t = 0$，有两个未知数 $u, v$，这是个欠定方程，因此无法直接求解。

## Lucas-Kanade 光流算法

### 孔径问题 （Aperture Problem）

局部图像信息（单个像素或小边缘）无法提供足够的约束来唯一确定全局运动矢量。

### 局部空间一致性 （Spatial Coherence）

这是LK方法的核心假设：在 **小的局部区域** 内，所有像素点的光流向量（运动矢量）是相同的。

基于这个假设，对于需要计算光流的像素点，取一个邻域窗口$P$（$w \times w$）（比如 5x5 或 7x7），假设该窗口内所有像素 $p_i$ 的光流向量 $(u, v)$ 相同。可以建立 $w^2$ 个方程：

$$
\begin{cases}
I_x(p_1) u + I_y(p_1) v + I_t(p_1) = 0 \\
I_x(p_2) u + I_y(p_2) v + I_t(p_2) = 0 \\
\vdots \\
I_x(p_{w^2}) u + I_y(p_{w^2}) v + I_t(p_{w^2}) = 0
\end{cases}
$$

这是一个典型的超定方程组，没有精确解，但我们可以通过最小二乘法（Least Squares）求它的最优近似解。

### LK——最小二乘法求解光流向量

对于超定方程组，写成矩阵形式：

$$
\begin{bmatrix}
I_x(p_1) & I_y(p_1) \\
I_x(p_2) & I_y(p_2) \\
\vdots & \vdots \\
I_x(p_{w^2}) & I_y(p_{w^2})
\end{bmatrix}
\begin{bmatrix}
u \\
v
\end{bmatrix}
=
\begin{bmatrix}
-I_t(p_1) \\
-I_t(p_2) \\
\vdots \\
-I_t(p_{w^2})
\end{bmatrix}\\[1em]
A\mathbf{x} = \mathbf{b}
$$

- $A$ 是一个 $w^2 \times 2$ 的矩阵，每一行代表一个像素点的xy方向梯度信息。
- $\mathbf{x} = \begin{bmatrix} u \\ v \end{bmatrix}$ 是我们要求解的光流向量。
- $\mathbf{b}$ 是一个 $w^2 \times 1$ 的向量，包含了每个像素点的时间梯度信息。

最小二乘形式：

$$
\min_{\mathbf{x}} \|A\mathbf{x} - \mathbf{b}\|_2^2
$$

展开，求导，导数为零，得到正规方程：

$$
A^T A \mathbf{x} = A^T \mathbf{b}\\
\mathbf{x} = (A^T A)^{-1} A^T \mathbf{b}
$$

想要有解，必须要求

- $A^T A$ 是可逆的，即 $\det(A^T A) \neq 0$。

- $A^T A$ 的条件数（Condition Number）不宜过大，否则求解结果会非常不稳定。

### 和角点检测的联系

关注一下矩阵 $A^T A$：

$$
A^T A = \begin{bmatrix}
\sum I_x(p_i)^2 & \sum I_x(p_i) I_y(p_i) \\
\sum I_x(p_i) I_y(p_i) & \sum I_y(p_i)^2
\end{bmatrix}=
\sum_{i=1}^{w^2} \begin{bmatrix}
I_x(p_i)^2 & I_x(p_i) I_y(p_i) \\
I_x(p_i) I_y(p_i) & I_y(p_i)^2
\end{bmatrix}
$$

这是角点检测中使用到的 **Harris 矩阵**，也称为 **结构张量（Structure Tensor）**。

回忆结构张量特征值的几种情况：

- $\lambda_1, \lambda_2$ 都很小：平坦区域——没有纹理，梯度几乎为0,矩阵 $A^T A$ 近似为零矩阵，无法求解光流。
- $\lambda_1$ 很大，$\lambda_2$ 很小：边缘——存在孔径问题，梯度几乎只沿一个方向变化，只能求解垂直边缘方向的光流，无法确定沿边缘的运动。
- $\lambda_1, \lambda_2$ 都很大：角点——x、y方向都有明显的梯度变化，光流可以被稳定地求解。

$\therefore$ 光流的计算依赖于图像中存在足够的纹理信息，尤其是 **角点区域**。

LK（Lucas-Kanade）光流算法的核心就是利用局部空间一致性假设，将光流计算问题转化为一个最小二乘问题，并通过结构张量的特征值来判断光流是否可解。但我们也看到了它的局限性：“孔径问题” 使得在纹理贫乏的区域，光流估计变得不可靠。

## Horn-Schunck 光流算法

与 LK 的“局部小团体”思路不同，Horn-Schunck（HS）算法着眼于全局。

### 平滑光流场

它引入了第二个核心假设（这也是它与 LK 最大的不同）：

**平滑光流场**假设：在一个图像中，属于同一物体的像素所形成的光流场应该是连续且平滑的。光流的突变只发生在物体边界，但这只占图像的很小一部分。

### HS——能量函数极值问题

HS需要满足两个条件：

- 条件1：光流约束方程：$I_x u + I_y v + I_t = 0$，这是数据项（Data Term），反映了光流与图像亮度变化之间的关系。
- 条件2：平滑性约束：光流场应该是连续且平滑的，用符号表示就是 $\nabla u \approx 0, \nabla v \approx 0$ (光流的梯度接近零)，这是平滑项（Smoothness Term），反映了光流场的空间连续性。

在物体运动边界处，条件1说“这里像素亮度急剧变化，光流必须突变”，而条件2说“平滑区域不允许突变”。

没有任何一个 $(u,v)$ 能同时让这两个条件都完美等于0

既然无法“精确满足”，数学上就只能转为“寻找一个平衡点”——让两个条件的总误差最小。

定义一个能量函数（Energy Function）：

$$
E(u, v) = \underbrace{\iint (I_x u + I_y v + I_t)^2dx dy}_{\text{Data Term}} + \underbrace{\iint\alpha(\|\nabla u\|^2 + \|\nabla v\|^2) dx dy}_{\text{Smoothness Term}}
$$

- 当 α 很小时，算法更听图像的话（数据优先），但可能产生噪点。

- 当 α 很大时，算法更听平滑的话（平滑优先），但会抹掉运动边界。

### 推导过程：欧拉-拉格朗日方程（Euler-Lagrange Equation）

把积分项记作 $L=(I_x u + I_y v + I_t)^2 + \alpha(u_x^2 + u_y^2 + v_x^2 + v_y^2)$，根据变分法原理，泛函 $E=\iint L dx dy$ 取得极值的必要条件是它必须满足欧拉-拉格朗日方程。

分别对两个函数 $u(x,y), v(x,y)$ 求偏导数，得到两个欧拉-拉格朗日方程：

$$
\begin{cases}
\dfrac{\partial L}{\partial u} - \dfrac{d}{dx}\dfrac{\partial L}{\partial u_x} - \dfrac{d}{dy}\dfrac{\partial L}{\partial u_y} = 0\\[1em]
\dfrac{\partial L}{\partial v} - \dfrac{d}{dx}\dfrac{\partial L}{\partial v_x} - \dfrac{d}{dy}\dfrac{\partial L}{\partial v_y} = 0
\end{cases}
$$

把 $L$ 代入，得到：

$$
\frac{\partial L}{\partial u} = 2 I_x (I_x u + I_y v + I_t), \quad
\frac{\partial L}{\partial u_x} = 2 \alpha u_x, \quad
\frac{\partial L}{\partial u_y} = 2 \alpha u_y\\[1em]
\frac{\partial L}{\partial v} = 2 I_y (I_x u + I_y v + I_t), \quad
\frac{\partial L}{\partial v_x} = 2 \alpha v_x, \quad
\frac{\partial L}{\partial v_y} = 2 \alpha v_y
$$

分别带入欧拉-拉格朗日方程，得到：

$$
\begin{cases}
I_x (I_x u + I_y v + I_t) - \alpha(u_{xx} + u_{yy}) = 0\\[1em]
I_y (I_x u + I_y v + I_t) - \alpha(v_{xx} + v_{yy}) = 0
\end{cases}
$$

记拉普拉斯算子 $\nabla^2 u = u_{xx} + u_{yy}$，$\nabla^2 v = v_{xx} + v_{yy}$，移项得到：

$$
\alpha \nabla^2 u =I_x (I_x u + I_y v + I_t) \\[1em]
\alpha \nabla^2 v = I_y (I_x u + I_y v + I_t)
$$

### 迭代公式

对于像素网格，拉普拉斯算子可以用邻域平均来近似：

$$
\nabla^2 u \approx \bar{u} - u, \quad
\nabla^2 v \approx \bar{v} - v
$$

其中 $\bar{u}=\frac{1}{4}\sum_{i=1}^{4} u_i$ 是像素点 $(x,y)$ 的4邻域平均光流向量，$\bar{v}$ 是4邻域平均光流向量。

带入上式，得到迭代公式：

$$
u^{k+1} = \bar{u}^k - \frac{I_x (I_x \bar{u}^k + I_y \bar{v}^k + I_t)}{\alpha + I_x^2 + I_y^2} \\[1em]
v^{k+1} = \bar{v}^k - \frac{I_y (I_x \bar{u}^k + I_y \bar{v}^k + I_t)}{\alpha + I_x^2 + I_y^2}
$$

### 算法流程

1. 初始化光流场 $u^0, v^0$ 为零。
2. 计算图像梯度 $I_x, I_y$ 和时间梯度 $I_t$。
3. 为每个像素点计算其邻域平均光流 $\bar{u}^k, \bar{v}^k$。
4. 根据迭代公式更新光流场 $u^{k+1}, v^{k+1}$。
5. 重复步骤3-4，直到收敛（如果两次迭代之间的光流变化小于某个阈值）或达到最大迭代次数。

## 对LK的和改进

标准LK有一个弱点：对“小运动”假设极其敏感。如果物体移动超过 2-3 个像素，泰勒展开线性化失效。为了解决这个问题，提出了金字塔LK（经典OpenCV实现）。

具体流程如下：

1. 将原图像（$L_0$）构建成高斯金字塔，得到多层图像 $L_0, L_1, L_2, ..., L_n$，其中 $L_n$ 是最小分辨率的图像。
2. 在最小分辨率图像 $L_n$ 上计算光流，得到初始光流估计 $g_n=(u_n, v_n)^T$。
3. 从顶（n）向下逐层迭代，

    1. 根据上一层（$L_{n+1}$）计算出的光流，映射到本层作为初始猜测$g_n$（通常乘以 2，因为图像放大了2倍）。
    2. 关键步骤：将当前帧图像 $I_2$ 依据初始猜测 $g_n$ 进行图像扭曲（Warp），即把 $I_2$ 按 $g_n$ 方向平移，使得两帧图像在像素上更接近（抵消大运动）。
    3. 计算残差光流$\Delta g_n$（此时只剩余微小位移，适用标准LK最小二乘求解）。
    4. 本层实际光流为：$g_n \leftarrow g_n + \Delta g_n$

因为大运动无法直接线性化，但先“猜”一个大概位移（用上一层粗糙结果*2），然后把图像搬过去，剩下的残差就是极小运动了。这做增量求解，保证了泰勒展开的线性化假设成立。
