---
title: 协方差与相关系数，矩
published: 2025-10-27
description: '协方差的定义、性质及其矩阵形式，相关系数的定义及其意义，矩的定义'
image: ''
tags: [概率论,协方差, 相关系数, 矩]
category: '概率论与数理统计'
draft: false 
lang: ''
---

## 协方差（Covariance）

### 协方差的定义

对于随机变量 $X,Y$：
$$
\begin{align*}
\mathrm{Cov}(X,Y) \\
&= \mathbb{E}[(X - \mathbb{E}[X])(Y - \mathbb{E}[Y])]\\
&=\mathbb{E}[XY-X\mathbb{E}[Y]-Y\mathbb{E}[X]+\mathbb{E}[X]\mathbb{E}[Y]]\\
&= \mathbb{E}[XY] - \mathbb{E}[X]\mathbb{E}[Y]
\end{align*}
$$
有由此可以看出单变量的方差其实是协方差的一种特殊情况$\mathbb{D}(X)=\mathrm{Cov}(X,X)$

### 协方差的性质

1. **对称性**  
   $$
   \mathrm{Cov}(X,Y) = \mathrm{Cov}(Y,X)
   $$  

2. **独立性的必要条件**  
   若 $X,Y$ 独立，则 $\mathrm{Cov}(X,Y)=0$。  
   （但 $\mathrm{Cov}(X,Y)=0$ 不一定独立）。

3. **计算变量和的方差**  
   $$
   \boxed{\mathrm{Var}(X\pm Y) = \mathrm{Var}(X) + \mathrm{Var}(Y) \pm 2\mathrm{Cov}(X,Y)}
   $$  

   特别地，当 $\mathrm{Cov}(X,Y)=0$ 时，$X+Y$ 的方差可以像计算均值那样直接相加。

4. **随机变量和常数的协方差=0**  
   $$
   \mathrm{Cov}(X,c)=0
   $$

5. **线性性**  
   $$
   \mathrm{Cov}(aX+b, \, cY+d) = ac \cdot \mathrm{Cov}(X,Y)
   $$

6. **协方差的组合性**
   $$
   \mathrm{Cov}(X_1+X_2, Y_1+Y_2) = \mathrm{Cov}(X_1,Y_1) + \mathrm{Cov}(X_1,Y_2)+ \mathrm{Cov}(X_2,Y_1)  + \mathrm{Cov}(X_2,Y_2)
   $$

7. **方差是协方差的特例**  
   $\mathrm{Var}(X) = \mathrm{Cov}(X,X)$。  

---

## 相关系数（Correlation Coefficient）

标准化的协方差定义为：
$$
\rho_{XY} = \frac{\mathrm{Cov}(X,Y)}{\sqrt{\mathrm{Var}(X)} \cdot \sqrt{\mathrm{Var}(Y)}}
$$

:::tip
如果 $\mathrm{Cov}(X,Y)=0$ ，则 $\rho_{XY}$ 得0。
:::

直观理解：协方差主要用来描述两个变量的相关性，因此**符号**很重要，但从数值上看，哪怕两个变量的变化趋势（上升或下降）相同，协方差的值也可能会因为其中单个变量的变化幅度而有很大差别。有没有一种方法通过**数值**来描述相关性呢？我们可以同时除以两个变量的**标准差**来消除这个影响，就得到了**相关系数**

相关系数的**大小**和**符号**都可以反映两随机变量的**线性**相关性

- $-1 \leq \rho_{XY} \leq 1$  （证明可以用柯西施瓦茨不等式）

- $\rho=0$：无**线性相关** （可能有别的非线性相关性）
- $\rho=1$：完全正相关 $\iff$ 存在常数 $a>0,b$ 使得 $Y=aX+b$
- $\rho=-1$：完全负相关 $\iff$ 存在常数 $a<0,b$ 使得 $Y=aX+b$  

:::warning[注意]  
$\rho=0$ 或 $\mathrm{Cov}(X,Y)=0$ 并不能推出 $X,Y$ 独立。  

独立一定不相关，相关一定不独，反之不一定成立。  

当且仅当 $X,Y$ 联合分布是二维正态分布时，不相关才能推出独立。  
:::

### 二维正态分布的相关系数

对于二维正态分布 $N(\mu_X, \mu_Y, \sigma_X^2, \sigma_Y^2, \rho)$，其相关系数

$$
\rho_{XY}=\frac{\mathrm{Cov}(X,Y)}{\sigma_X \sigma_Y}=\rho
$$

---

## 矩：原点矩，中心矩

**原点矩**的定义：若 $\mathbb{E}(X^k)$ 存在，则称 $\mathbb{E}(X^k)$ 为随机变量 $X$ 的 **k 阶原点矩**，记作 $\alpha_k=\mathbb{E}(X^k)$

**中心矩**的定义：若 $\mathbb{E}[(X-\mathbb{E}(X))^k]$ 存在，则称 $\mathbb{E}[(X-\mathbb{E}(X))^k]$ 为随机变量 $X$ 的 **k 阶中心矩**，记作 $\beta_k=\mathbb{E}[(X-\mathbb{E}(X))^k]$

:::note
注意这里k次方的位置
:::

- 可以看出，数学期望 $\mathbf{E}$ 是随机变量的 1 阶原点矩，方差 $\mathbf{D}$ 是随机变量的 2 阶中心矩。

**混合原点矩**的定义：设 $(X,Y)$ 是二维随机变量，若 $\mathbb{E}(X^k Y^l)$ 存在，则称 $\mathbb{E}(X^k Y^l)$ 为二维随机变量 $(X,Y)$ 的 **k+l阶混合原点矩**，记作 $\alpha_{k,l}=\mathbb{E}(X^k Y^l)$

**混合中心距**的定义：设 $(X,Y)$ 是二维随机变量，若 $\mathbb{E}[(X-\mathbb{E}(X))^k (Y-\mathbb{E}(Y))^l]$ 存在，则称 $\mathbb{E}[(X-\mathbb{E}(X))^k (Y-\mathbb{E}(Y))^l]$ 为二维随机变量 $(X,Y)$ 的 **k+l阶混合中心矩**，记作 $\beta_{k,l}=\mathbb{E}[(X-\mathbb{E}(X))^k (Y-\mathbb{E}(Y))^l]$

- 可以看出，协方差 $\mathrm{Cov}(X,Y)$ 是二维随机变量 $(X,Y)$ 的 1+1 阶混合中心矩。

## 协方差矩阵(了解)（Covariance Matrix）

:::tip  
协方差矩阵就是多为随机变量的方差，是一维随机变量方差的推广,从数变成矩阵了。
:::

对于随机向量
$$
X = \begin{bmatrix} X_1 \\ X_2 \\ \cdots \\ X_n \end{bmatrix},
\quad \mu = \mathbb{E}[X]=\begin{bmatrix}
   \mathbb{E}[X_1]\\
   \mathbb{E}[X_2]\\
   \dotsb\\
   \mathbb{E}[X_n]\\
\end{bmatrix}
$$

随机向量的协方差用于描述随机向量中每个分量的离散程度（方差）（对角线上）以及不同分量之间的线性相关性（协方差）（非对角线上）。定义为：
$$
\Sigma = \mathrm{Cov}(X) = \mathbb{E}[(X-\mu)(X-\mu)^T]
$$

展开为：
$$
\Sigma =
\begin{bmatrix}
\mathrm{Var}(X_1) & \mathrm{Cov}(X_1,X_2) & \cdots & \mathrm{Cov}(X_1,X_n) \\
\mathrm{Cov}(X_2,X_1) & \mathrm{Var}(X_2) & \cdots & \mathrm{Cov}(X_2,X_n) \\
\vdots & \vdots & \ddots & \vdots \\
\mathrm{Cov}(X_n,X_1) & \mathrm{Cov}(X_n,X_2) & \cdots & \mathrm{Var}(X_n)
\end{bmatrix}
$$

:::note[推导过程]
$$
(X-\mu)=\begin{bmatrix}
   X_1-\mathbb{E}[X_1]\\
   X_2-\mathbb{E}[X_2]\\
   X_3-\mathbb{E}[X_3]\\
   \dotsb\\
   X_n-\mathbb{E}[X_n]\\
\end{bmatrix}\\[5bp]
(X-\mu)(X-\mu)^T=\begin{bmatrix}
   (X_1-\mathbb{E}[X_1])^2 & (X_1-\mathbb{E}[X_1])\cdot(X_2-\mathbb{E}[X_2]) & \dotsb &(X_1-\mathbb{E}[X_1])\cdot(X_n-\mathbb{E}[X_n])\\
   (X_2-\mathbb{E}[X_1])(X_1-\mathbb{E}[X_1]) & (X_2-\mathbb{E}[X_2])^2 & \dotsb &(X_1-\mathbb{E}[X_1])\cdot(X_n-\mathbb{E}[X_n])\\
   \vdots&\vdots&\ddots&\vdots\\
   (X_n-\mathbb{E}[X_n])\cdot(X_1-\mathbb{E}[X_1]) &
   (X_n-\mathbb{E}[X_n])\cdot(X_2-\mathbb{E}[X_2]) &\dotsb&(X_n-\mathbb{E}[X_n])^2
\end{bmatrix}
$$

矩阵中的每一个元素(i,j)为

$$
(X_i-\mathbb{E}[X_i])\cdot(X_j-\mathbb{E}[X_j])
$$

而期望$\mathbb{E}$是线性作用于对象，即对矩阵中的每一个元素取期望

$$
\Sigma_{ij}=\mathbb{E}[(X_i-\mathbb{E}[X_i])\cdot(X_j-\mathbb{E}[X_j])]
$$

由方差以及协方差的定义式：

对于对角线元素: $i=j$
$$
\mathbb{E}[\Sigma_{ij}]=\mathbb{E}[(X_i-\mathbb{E}[X_i])^2]=\mathrm{Var}(X_i)
$$

对于非对角线元素: $i\neq j$
$$
\mathbb{E}[\Sigma_{ij}]=\mathbb{E}[(X_i-\mathbb{E}[X_i])(X_j-\mathbb{E}[X_j])]=\mathrm{Cov}(X_i,X_j)
$$
:::

当然，也许不必把每个元素都清清楚楚的算出来，$\Sigma=\mathbb{E}[XX^T]-\mu\mu^T$ 是更简单也更常用的式子。

:::note[推导过程]
$$
\begin{aligned}
\Sigma = \mathrm{Cov}(X) &= \mathbb{E}[(X-\mu)(X-\mu)^T]\\
&=\mathbb{E}[XX^T-X\mu^T-\mu X^T+\mu\mu^T]\\
\because \mathbb{E}[X]&=\mu\\
\therefore \;\Sigma&=\mathbb{E}[XX^T]-\mu\mu^T
\end{aligned}
$$
:::

---

### 性质

1. **对称性**：$\Sigma^T = \Sigma$  
2. **半正定性**：$\forall a, \; a^T \Sigma a \geq 0$  
3. **对角元素**：为各维的方差  
4. **非对角元素**：为各维的协方差  
5. **线性变换下的协方差**：若 $Y = AX + b$，则
   $$
   \mathrm{Cov}(Y) = A \, \mathrm{Cov}(X) \, A^T
   $$

---

## 五、直观例子

- $X$ = 小车位置，$Y$ = 小车速度  
- 若 $X,Y$ 独立：协方差 = 0 → 协方差矩阵是对角的  
- 若速度越大时位置偏离越大：协方差 > 0  
- 若速度越大时位置更接近原点：协方差 < 0  

这就是为什么在卡尔曼滤波中，状态协方差矩阵 $P$ 要随着预测和观测不断更新，它反映了不确定性和相关性。
