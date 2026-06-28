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

1. 假设类条件概率的分布长这样：$P(\mathbf{x}|\omega_i) = P(\mathbf{x}|\omega_i;\theta_i)$。
2. 独立同分布：同一类别的样本是**独立同分布**的随机变量。可以把联合概率写成乘积的形式：$P(D_i|\omega_i) = \prod_{j=1}^{N_i} P(\mathbf{x}_j|\omega_i)$。

方便起见通常把类 $\omega_i$ 省略掉，参数 $\theta_i$ 简称为 $\theta$

### 最大似然估计（MLE）

最大似然估计的核心思想是：在给定数据的前提下，找到使得 **数据出现概率** $P(D_i|\theta_i)$ 最大的参数值 $\hat{\theta_i}$。

对于某一类 $\omega_i$ 的数据集：$D_i = \{\mathbf{x}_j | y_j = \omega_i\}$

似然$L(\theta_i) = P(D_i | \theta_i) = \prod_{j=1}^{N_i} P(\mathbf{x}_j | \omega_i; \theta_i)$。

- 对数化 $l(\theta_i) = \ln P(D_i | \theta_i)= \sum_{j=1}^{N_i} \ln P(\mathbf{x}_j | \omega_i; \theta_i)$。

- 目标函数 $\hat{\theta_i} = \arg\max_{\theta_i} l(\theta_i)=\argmax_{\theta_i} \ln P(D_i | \theta_i)$。
- 计算：解方程 $\frac{\partial}{\partial \theta}l(\theta) = 0$

对于服从高斯分布的类条件概率，参数 $\theta_i$ 包括均值 $\mu_i$ 和协方差矩阵 $\Sigma_i$，MLE 的解为：

$$
\hat{\mu}_{\text{ML}} = \frac{1}{N_i} \sum_{j=1}^{N_i} \mathbf{x}_j, \quad \hat{\Sigma}_{\text{ML}} = \frac{1}{N_i} \sum_{j=1}^{N_i} (\mathbf{x}_j - \hat{\mu}_{\text{ML}})(\mathbf{x}_j - \hat{\mu}_{\text{ML}})^T
$$

### 最大后验估计（MAP）

最大后验估计的核心思想是：在给定数据的前提下，结合对参数 $\theta_i$ 的先验，找到使得参数 $\theta_i$ 的 **后验概率** $P(\theta_i|D_i)$ 最大的参数值 $\hat{\theta_i}$。

根据贝叶斯定理，后验概率可以写成：$P(\theta_i|D_i) = \frac{P(D_i|\theta_i)P(\theta_i)}{P(D_i)}\propto P(D_i|\theta_i)P(\theta_i)$。

似然函数 $L(\theta_i) = P(D_i|\theta_i)$，先验概率 $P(\theta_i)$。

- 对数化 $l(\theta_i) = \ln P(D_i|\theta_i) + \ln P(\theta_i)=\sum_{j=1}^{N_i} \ln P(\mathbf{x}_j | \omega_i; \theta_i) + \ln P(\theta_i)$。
- 目标函数 $\hat{\theta_i} = \arg\max_{\theta_i} l(\theta_i) = \arg\max_{\theta_i} \ln P(D_i|\theta_i) + \ln P(\theta_i)$。
- 计算：解方程 $\frac{\partial}{\partial \theta_i}l(\theta_i) = 0$

相比于 MLE，MAP 通过引入先验概率 $P(\theta_i)$ 来对参数进行 **正则化**，避免过拟合问题。

- 当先验为高斯分布时，MAP等价于Ridge回归（L2正则化）
- 当先验为拉普拉斯分布时，等价于Lasso回归（L1正则化）。

### 贝叶斯估计（Bayesian Estimation）

计算参数 $\theta_i$ 的 **后验分布** $P(\theta_i|D_i)$，而不是单一的点估计 $\hat{\theta_i}$。

#### 学习过程

计算后验分布 $P(\theta_i|D_i) = \frac{P(D_i|\theta_i)P(\theta_i)}{P(D_i)}=\frac{P(D_i|\theta_i)P(\theta_i)}{\int P(D_i|\theta_i)P(\theta_i)d\theta_i}$。分母那一坨是归一化用的。

#### 分类过程（预测）

对于一个新的样本 $\mathbf{x}$，计算其类条件概率的 **预测分布**：

$$
P(\mathbf{x}|D_i) = \int P(\mathbf{x}|\theta_i)P(\theta_i|D_i)d\theta_i
$$

这里 $D_i$ 的意思和 $\omega_i$ 是一样的，都是第i类的数据集。

然后根据最小错误率准则，计算后验概率 $P(\omega_i|\mathbf{x}) \propto P(\mathbf{x}|D_i)P(\omega_i)$，选择后验概率最大的类别 $\omega_i$ 作为预测结果。

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
