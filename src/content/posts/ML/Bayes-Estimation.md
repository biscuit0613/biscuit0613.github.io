---
title: 概率密度估计：参数法与非参数法
published: 2026-06-16
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 2
draft: false 
lang: ''
---

## 两个重要的概率密度

类条件概率 $p(\mathbf{x}|\omega_i)$ 和先验概率 $P(\omega_i)$

- **方法A（参数法）**：假设已知 $p(\mathbf{x}|\omega_i)$ 的参数形式（如高斯分布、伯努利分布）。唯一未知的是参数 $\theta_i$（如 $\mu, \Sigma$）。
- **方法B（非参数法）**：不假设任何分布形式，直接从数据中“拼凑”出密度函数。如parzen窗口法、k近邻法等。

重点关注 $p(\mathbf{x}|\omega_i)$ 的估计方法。

## 类条件概率的参数估计

假设前提：

1. 假设类条件概率的分布长这样：$p(\mathbf{x}|\omega_i) = p(\mathbf{x}|\omega_i;\theta_i)$。
2. 独立同分布：同一类别（$\omega_i$ 相同）的样本是**独立同分布**的随机变量。可以把联合概率写成乘积的形式：$p(D_i|\omega_i) = \prod_{j=1}^{N_i} p(\mathbf{x}_j|\omega_i)$。其中 $D_i = \{\mathbf{x}_j | y_j = \omega_i\}$ 是第 $i$ 类的训练样本集合，$N_i$ 是第 $i$ 类的样本数。

方便起见通常把类 $\omega_i$ 省略掉，参数 $\theta_i$ 简称为 $\theta$

### 最大似然估计（MLE）

最大似然估计的核心思想是：在给定数据的前提下，找到使得 **数据出现概率** $p(D_i|\theta_i)$ 最大的参数值 $\hat{\theta_i}$。

似然$L(\theta_i) = p(D_i | \theta_i) = \prod_{j=1}^{N_i} p(\mathbf{x}_j | \omega_i; \theta_i)$。

- 对数化 $l(\theta_i) = \ln p(D_i | \theta_i)= \sum_{j=1}^{N_i} \ln p(\mathbf{x}_j | \omega_i; \theta_i)$。

- 目标函数 $\hat{\theta_i} = \arg\max_{\theta_i} l(\theta_i)=\argmax_{\theta_i} \ln p(D_i | \theta_i)$。
- 计算：解方程 $\frac{\partial}{\partial \theta}l(\theta) = 0$

对于服从高斯分布的类条件概率，参数 $\theta_i$ 包括均值 $\mu_i$ 和协方差矩阵 $\Sigma_i$，MLE 的解为：

$$
\hat{\mu}_{\text{ML}} = \frac{1}{N_i} \sum_{j=1}^{N_i} \mathbf{x}_j, \quad \hat{\Sigma}_{\text{ML}} = \frac{1}{N_i} \sum_{j=1}^{N_i} (\mathbf{x}_j - \hat{\mu}_{\text{ML}})(\mathbf{x}_j - \hat{\mu}_{\text{ML}})^T
$$

### 最大后验估计（MAP）

核心思想：在 MLE 的基础上，引入对参数 $\theta_i$ 的先验知识 $p(\theta_i)$，最大化**后验概率** $p(\theta_i|D_i)$ 而非似然：

$$
p(\theta_i|D_i) = \frac{p(D_i|\theta_i)p(\theta_i)}{p(D_i)} \propto p(D_i|\theta_i)p(\theta_i)
$$

与 MLE 相比，目标函数仅多了一项 $\ln p(\theta_i)$，其余结构完全相同：

$$
l(\theta_i) = \underbrace{\ln p(D_i|\theta_i)}_{\text{MLE}} + \ln p(\theta_i)
= \sum_{j=1}^{N_i} \ln p(\mathbf{x}_j | \omega_i; \theta_i) + \ln p(\theta_i)
$$

$\hat{\theta_i} = \arg\max_{\theta_i} l(\theta_i)$，计算：解 $\frac{\partial}{\partial \theta_i}l(\theta_i) = 0$。

先验 $p(\theta_i)$ 起到了**正则化**的作用：

- 高斯先验 $\to$ Ridge回归（L2正则化）
- 拉普拉斯先验 $\to$ Lasso回归（L1正则化）

### 贝叶斯估计（Bayesian Estimation）

计算参数 $\theta_i$ 的 **后验分布** $p(\theta_i|D_i)$，而不是单一的点估计 $\hat{\theta_i}$。

#### 学习过程

计算后验分布 $p(\theta_i|D_i) = \dfrac{p(D_i|\theta_i)p(\theta_i)}{p(D_i)}=\dfrac{p(D_i|\theta_i)p(\theta_i)}{\int p(D_i|\theta_i)p(\theta_i)d\theta_i}$。分母那一坨是归一化用的。

#### 分类过程（预测）

对于一个新的样本 $\mathbf{x}$，计算其类条件概率的 **预测分布**：

$$
p(\mathbf{x}|\omega_i) = p(\mathbf{x}|D_i) = \int p(\mathbf{x}|\theta_i)p(\theta_i|D_i)d\theta_i
$$

与 MAP 用 $\hat{\theta}$ 这一个点不同，Bayesian 估计里 $\theta$ 服从后验分布 $p(\theta_i|D_i)$，积分就是在对 $\theta$ 的**不确定性做平均**（边际化）。如果后验本身很尖（数据足够多），结果接近 MAP；如果后验很宽（数据少），积分会自动分散权重，不会过度自信。

然后根据最小错误率准则，计算后验概率 $P(\omega_i|\mathbf{x}) \propto p(\mathbf{x}|D_i)P(\omega_i)$，选择后验概率最大的类别 $\omega_i$ 作为预测结果。


## 附：偏差-方差分解（Bias-Variance Decomposition）

MLE、MAP、Bayesian 三种估计方法的差异可以由偏差-方差分解来解释。对于参数 $\theta$ 的任意估计量 $\hat{\theta}$，其均方误差（MSE）可分解为：

### 定义

- **偏差**：$Bias(\hat{\theta}) = \mathbb{E}[\hat{\theta}] - \theta$，衡量估计的**系统性偏离**
- **方差**：$Var(\hat{\theta}) = \mathbb{E}[(\hat{\theta} - \mathbb{E}[\hat{\theta}])^2]$，衡量估计对样本的**敏感程度**

### 分解公式

$$
\begin{aligned}
MSE(\hat{\theta}) &= \mathbb{E}[(\hat{\theta} - \theta)^2] \\[1ex]
&= \mathbb{E}\big[ (\hat{\theta} - \mathbb{E}[\hat{\theta}] + \mathbb{E}[\hat{\theta}] - \theta)^2 \big] \\[1ex]
&= \underbrace{\mathbb{E}[(\hat{\theta} - \mathbb{E}[\hat{\theta}])^2]}_{Var(\hat{\theta})} + 2\underbrace{\mathbb{E}[(\hat{\theta} - \mathbb{E}[\hat{\theta}])]}_{=0}(\mathbb{E}[\hat{\theta}] - \theta) + \underbrace{(\mathbb{E}[\hat{\theta}] - \theta)^2}_{Bias(\hat{\theta})^2} \\[1ex]
&= Var(\hat{\theta}) + Bias(\hat{\theta})^2
\end{aligned}
$$

其中交叉项为 0 是因为 $\mathbb{E}[\hat{\theta} - \mathbb{E}[\hat{\theta}]] = 0$。

### 与三种方法的关系

| 方法 | 偏差 | 方差 | 说明 |
|------|------|------|------|
| **MLE** | 渐近无偏（$Bias \to 0$ 当 $N \to \infty$） | 高（完全由数据驱动） | 样本少时易过拟合 |
| **MAP** | 有偏（被先验拉向 $p(\theta)$ 的峰值） | 比 MLE 低（先验起约束作用） | 先验是正则项，$N$ 增大时先验影响衰减 |
| **Bayesian** | 不适用（无点估计） | 不适用（全分布） | 天然避免了"单点估计"的风险 |

**核心权衡**：偏差和方差是跷跷板——降低一个通常会抬升另一个。MLE 追求无偏但方差大，MAP 引入偏差来压低方差，Bayesian 则跳出"点估计"框架不再做这个权衡。三种参数估计方法的递进正是在探索不同的偏差-方差折衷策略。

## 类条件概率的非参数估计

令 $R$ 是包含样本点 $\mathbf{x}$ 的一个区域，其体积为 $V$，设有 $n$ 个训练样本，其中有 $k$ 个落在区域 $R$ 中，则可对概率密度作出一个估计：

$$
p(\mathbf{x}) \approx \frac{k}{nV}
$$

关于此估计的收敛性：

选择一系列包含样本点 $\mathbf{x}$ 的区域 $R_n$（n代表样本数量），其体积为 $V_n$，包含的训练样本数为 $k_n$，估计记作 $\hat{p}_n(\mathbf{x}) = \frac{k_n}{nV_n}$，则当 $n \to \infty$ 时，$\hat{p}_n(\mathbf{x})$ 以概率1收敛于真实的概率密度 $p(\mathbf{x})$ 的充分必要条件是：

1. $\lim_{n \to \infty} V_n \to 0$，即区域 $R_n$ 的体积趋于0。
2. $\lim_{n \to \infty} k_n \to \infty$，即区域 $R_n$ 中的训练样本数趋于无穷大。
3. $\lim_{n \to \infty} \dfrac{k_n}{n} \to 0$，即区域 $R_n$ 中的训练样本数占总样本数的比例趋于0。

核心矛盾在于：固定 $n$ 时，如何平衡 $V$ 和 $k$？由此衍生出两大经典流派：

### Parzen窗口法

先讲方窗的形式：

假设区域 $R_n$ 是正方形/立方体窗口，其边长为 $h_n$，则 $V_n = h_n^d$（d为维度）。

定义窗口函数 $\varphi(\mathbf{u})$：

$$
\varphi(\mathbf{u}) = \begin{cases}
1, & \|\mathbf{u}\|_\infty \leq 1/2 \\
0, & \text{otherwise}
\end{cases}
$$

把这个窗口中心放在待估计点 $\mathbf{x}$ 上，那么窗口函数可以写成 $\varphi\left(\frac{\mathbf{x} - \mathbf{x}_j}{h_n}\right)$，括号中的一坨理解为：当其他样本 $\mathbf{x}_j$ 落在窗口内（区域 $R_n$）时，函数值为1，否则为0。

通过推导过程可以得到窗函数的必要条件：

$$
\int \varphi(\mathbf{u}) d\mathbf{u} = 1\\
\varphi(\mathbf{u}) \geq 0
$$

其他窗函数：

- 高斯窗：$\varphi(\mathbf{u}) = \dfrac{1}{2\pi} \exp\left(-\dfrac{1}{2} \mathbf{u}^T \mathbf{u}\right)$
- 指数窗：$\varphi(\mathbf{u}) =  \exp\left(-\frac{1}{2}\|\mathbf{u}\|_1\right)$

计算落在窗口内的训练样本数 $k_n$：

$$
k_n = \sum_{j=1}^n \varphi\left(\frac{\mathbf{x} - \mathbf{x}_j}{h_n}\right)
$$

因此概率密度的估计为：

$$
\hat{p}_n(\mathbf{x}) = \frac{1}{nV_n} \sum_{j=1}^n \varphi\left(\frac{\mathbf{x} - \mathbf{x}_j}{h_n}\right) = \frac{1}{nh_n^d} \sum_{j=1}^n \varphi\left(\frac{\mathbf{x} - \mathbf{x}_j}{h_n}\right)
$$

**关键超参数**：窗口宽度 $h_n$ 的选择

- $h_n$ 太大：窗口内包含过多样本，密度估计值是 $n$ 个宽度较⼤、变化缓慢的函数的叠加估计过于平滑，其分辨率很低无法捕捉数据的细节。
- $h_n$ 太小：窗口内包含样本过少，密度估计值是 $n$ 个以样本为中⼼的尖峰函数的叠加,估计方差较大，噪声敏感。

### K近邻法

固定点数 $k_n$ , $k_n$ 是样本总量n的函数，随着n的增加而增加，例如 $k_n = \sqrt{n}$

围绕待估计点 $\mathbf{x}$ 不断 **扩大区域** $R_n$ **范围** ，直到恰好包含预设的  $k_n$ 个训练样本为止，此时该邻域的体积即为 $V_{k_n}$。

- 在样本密集的高密度区域，邻域体积 V 会自动缩小（提供精细分辨率）

- 在样本稀疏的低密度区域， V 会自动放大（避免估计值为零）。

- 但估计出的密度不是严格概率密度（积分不一定等于 1），且密度曲线不平滑（存在不连续点）。
