---
title: Bayes判别准则
published: 2026-06-12
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 1
draft: false 
lang: ''
---

:::tip[符号约定]

本系列统一使用以下符号规则：

| 符号           | 含义                     | 示例                                                               |
| -------------- | ------------------------ | ------------------------------------------------------------------ |
| $P(\cdot)$     | **概率**（离散事件）     | 先验 $P(\omega_i)$、后验 $P(\omega_i \mid \mathbf{x})$             |
| $p(\cdot)$     | **概率密度**（连续变量） | 类条件密度 $p(\mathbf{x} \mid \omega_i)$、证据因子 $p(\mathbf{x})$ |
| $\mathbf{x}$   | 加粗 = 特征向量          | $\mathbf{x} = (x_1,\dots,x_d)^T$                                   |
| $\omega_i$     | 第 $i$ 个类别            | $\omega_1$ 表示"正类"，$\omega_2$ 表示"负类"                       |
| $\hat{\omega}$ | 预测类别                 | $\hat{\omega} = \arg\max_i P(\omega_i \mid \mathbf{x})$            |

**角标规则**：$\lambda_{ij}$ 中第一个下标 $i$ 为真实类别，第二个 $j$ 为预测类别。
**密度和概率永远不会出现在等式同侧参与比较**（密度可以 $>1$，概率始终 $\in [0,1]$）。

:::

三种判别准则：

1. 最小错误率准则：选择后验概率最大的类别。
2. 最小风险准则：考虑不同类型错误的损失，选择期望风险最小的类别。
3. 聂曼-皮尔逊准则：在二分类问题中，在限定一类错误率条件下使另一类错误率为最小

## 1. 最小错误率准则

### 单个样本 $\mathbf{x}$ 的条件错误率（用于决策）

- 多分类判别 $\mathbf{x}$ 为 $\hat{\omega}$ 的条件错误率：

$$
P(\text{error} | \mathbf{x}) = 1 - P(\hat{\omega} | \mathbf{x})
$$

- 二分类：

$$
\begin{cases}
    P(\text{error}_1 | \mathbf{x}) = P(\omega_2 | \mathbf{x}), & \text{if } \hat{\omega} = \omega_1 \\
    P(\text{error}_2 | \mathbf{x}) = P(\omega_1 | \mathbf{x}), & \text{if } \hat{\omega} = \omega_2
\end{cases}
$$

### 整体数据集的总体错误率（用于评估）

从联合概率密度的视角来看，可以用积分表示：设 $\hat{\mathbf{x}}$ 是决策边界，当特征向量 $\mathbf{x}$ 实际为 $\omega_1$ 时，错误率为

$P(error_2)=\int_{R_2} p( \mathbf{x}|\omega_1 )P(\omega_1) d\mathbf{x}$

当 $\mathbf{x}$ 实际为 $\omega_2$ 时，错误率为

$P(error_1 )=\int_{R_1} p( \mathbf{x}|\omega_2 ) P(\omega_2) d\mathbf{x}$。

整体：$P(mistake) = P(error_1) + P(error_2)$

### 图解

![alt text](image-6.png)

### 最小错误率决策准则

对于一个待分类样本 $\mathbf{x}$，我们计算每个类别 $\omega_j$ 的后验概率 $P(\omega_j | \mathbf{x})$，然后选择后验概率最大的类别 $\omega_i$ 作为预测结果：

$$
i = \arg\max_{1 \leq j \leq c} P(\omega_j | \mathbf{x}), x\in \omega_i
$$

### 最小错误率判别函数

对于每个类别 $\omega_j$，定义判别函数 $g_j(\mathbf{x})$：

$$
g_j(\mathbf{x}) = P(\omega_j | \mathbf{x})\propto p(\mathbf{x} | \omega_j) P(\omega_j)
$$

或对数形式：

$$
g_j(\mathbf{x}) = \ln p(\mathbf{x} | \omega_j) + \ln P(\omega_j)
$$

$$
i=\arg\max_{1 \leq j \leq c} g_j(\mathbf{x}), \mathbf{x}\in \omega_i
$$

### 对于两类问题(1)

两类问题的等价形式：似然比(或者他们的对数形式)和阈值比大小

$$
\hat{\omega} = \begin{cases}
\omega_1, & \text{if } \dfrac{p(\mathbf{x} | \omega_1) }{p(\mathbf{x} | \omega_2) } > \dfrac{P(\omega_2)}{P(\omega_1)} \\
\omega_2, & \text{otherwise}
\end{cases}
$$

决策边界 $\mathbf{x}$ 由 $\dfrac{p(\mathbf{x} | \omega_1) }{p(\mathbf{x} | \omega_2) } = \dfrac{P(\omega_2)}{P(\omega_1)}$ 定义。

## 2. 最小风险准则

### 单个样本 $\mathbf{x}$ 的条件风险 （用于决策）

将真实类别 $\omega_i$ 判断成 $\omega_j$ 的损失定义为 $\lambda_{ij}$，则对于一个待分类样本 $\mathbf{x}$，我们计算每个类别 $\omega_j$ 的期望风险 $R(\omega_j | \mathbf{x})$ ，是 $\mathbf{x}$ 属于 $\omega_i$ 的条件下，将 $\mathbf{x}$ 误分类为 $\omega_j$ 的期望损失。

$$
R(\omega_j | \mathbf{x}) = \sum_{i} \lambda_{ij} P(\omega_i | \mathbf{x})
$$

:::tip

例如有正常人(w1)和病人(w2)两类，误将病人判断为正常人的风险就是 $R(\omega_1 | \mathbf{x}) = \lambda_{21} P(\omega_2 | \mathbf{x})$，误将正常人判断为病人的风险就是 $R(\omega_2 | \mathbf{x}) = \lambda_{12} P(\omega_1 | \mathbf{x})$。

:::

### 整体数据集的总体风险（用于评估）

整个特征空间上，总体风险是对所有样本的条件风险求期望：

$$
R_\text{total} = \int R(\hat{\omega}(\mathbf{x}) | \mathbf{x}) p(\mathbf{x}) d\mathbf{x}
$$

其中 $\hat{\omega}(\mathbf{x})$ 是决策准则。

### 最小风险决策准则

对于一个待分类样本 $\mathbf{x}$，计算所有类别 $\omega_j$ 的期望风险 $R(\omega_j | \mathbf{x})$，然后选择风险最小的类别作为预测结果：

$$
i = \arg\min_{1 \leq j \leq c} R(\omega_j | \mathbf{x}), x\in \omega_i
$$

### 最小风险判别函数

对于每个类别 $\omega_j$，定义判别函数 $g_j(\mathbf{x})$ 为期望风险的负数，把最小风险问题转化为最大判别函数问题:

$$
g_j(\mathbf{x}) = -R(\omega_j | \mathbf{x}) = -\sum_{i=1}^{c} \lambda_{ij} P(\omega_i | \mathbf{x})\\= -\sum_{i=1}^{c} \lambda_{ij} p(\mathbf{x} | \omega_i) P(\omega_i)
$$

$$
i=\arg\max_{1 \leq j \leq c} g_j(\mathbf{x}), \mathbf{x}\in \omega_i
$$

### 对于两类问题(2)

定义决策表，里面的元素 $\lambda_{ij}$ 表示将真实类别 $\omega_i$ 判断成 $\omega_j$ 的损失。对于二分类问题，决策表可以简化为：

|                 | 预测 $\omega_1$  | 预测 $\omega_2$  |
| --------------- | ---------------- | ---------------- |
| 真实 $\omega_1$ | $\lambda_{11}=0$ | $\lambda_{12}$   |
| 真实 $\omega_2$ | $\lambda_{21}$   | $\lambda_{22}=0$ |

误分类只包括 $\lambda_{12}$ 和 $\lambda_{21}$

对于一个待分类样本 $\mathbf{x}$，计算误分类的期望风险：

$$
\begin{aligned}
R(\omega_1 | \mathbf{x}) &=  \lambda_{21} P(\omega_2 | \mathbf{x})=\lambda_{21}p(\mathbf{x}|\omega_2)P(\omega_2) \\
R(\omega_2 | \mathbf{x}) &= \lambda_{12} P(\omega_1 | \mathbf{x})=\lambda_{12}p(\mathbf{x}|\omega_1)P(\omega_1)
\end{aligned}
$$

对应的判别函数：

$$
\begin{aligned}
g_1(\mathbf{x}) &= -R(\omega_1 | \mathbf{x}) = -\lambda_{21} p(\mathbf{x} | \omega_1) P(\omega_1) \\
g_2(\mathbf{x}) &= -R(\omega_2 | \mathbf{x}) = -\lambda_{12} p(\mathbf{x} | \omega_2) P(\omega_2)
\end{aligned}
$$

判别准则：
$$
\hat{\omega} = \begin{cases}
\omega_1, & \text{if } \dfrac{p(\mathbf{x} | \omega_1) }{p(\mathbf{x} | \omega_2) } > \dfrac{P(\omega_2)\lambda_{21}}{P(\omega_1)\lambda_{12}} \\
\omega_2, & \text{otherwise}
\end{cases}
$$

当使用0-1损失函数时，$\lambda_{ij} = 0$ if $i=j$ else 1，此时最小风险准则退化为最小错误率准则。

决策边界 $\mathbf{x}$ 由 $\dfrac{p(\mathbf{x} | \omega_1) }{p(\mathbf{x} | \omega_2) } = \dfrac{P(\omega_2)\lambda_{12}}{P(\omega_1)\lambda_{21}}$ 定义。

## 3. 聂曼-皮尔逊准则

### 单个样本 $\mathbf{x}$ 的似然比检验（用于决策）

与最小错误率直接使用后验概率不同，N-P 准则不依赖先验，而是直接构造**似然比**

$$
\Lambda(\mathbf{x}) = \frac{p(\mathbf{x} | \omega_1)}{p(\mathbf{x} | \omega_2)}
$$

### 整体数据集的错误率约束（用于评估）

二分类问题中，第一类错误率（$\epsilon_1$ , $\omega_2$ 被误判为 $\omega_1$）不超过某个阈值 $\alpha$，第二类错误率（$\epsilon_2$ , $\omega_1$ 被误判为 $\omega_2$）。定义两类错误率：

$$
 \int_{R_1} p(\mathbf{x} | \omega_2)P(\omega_2) d\mathbf{x} = \epsilon_1, \\
 \int_{R_2} p(\mathbf{x} | \omega_1)P(\omega_1) d\mathbf{x} = \epsilon_2
$$

- 决策区域： $R_1$ 是将 $\mathbf{x}$ 分类为 $\omega_1$ 的区域，$R_2$ 是将 $\mathbf{x}$ 分类为 $\omega_2$ 的区域。
- 约束条件：固定 $\epsilon_2 = \alpha$，最小化 $\epsilon_1$。

### 聂曼-皮尔逊决策准则

似然比检验：大于某个阈值 $\lambda$ 则判为 $\omega_1$，否则判为 $\omega_2$

### 聂曼-皮尔逊判别函数

$$
\min \epsilon_1 \quad s.t. \quad \epsilon_2 = \alpha
$$

固定 $\epsilon_2 = \alpha$，最小化 $\epsilon_1$。用拉格朗日乘子法求解，引入拉格朗日乘子 $\mu$：

$$
\begin{aligned}
& \underset{\hat{\omega}}{\text{minimize}} \quad \mathcal{L} = \int_{R_1} p(\mathbf{x} | \omega_2) P(\omega_2) d\mathbf{x} + \mu \left( \int_{R_2} p(\mathbf{x} | \omega_1) P(\omega_1) d\mathbf{x} - \alpha \right) \\
& \text{subject to} \quad \int_{R_2} p(\mathbf{x} | \omega_1) P(\omega_1) d\mathbf{x} = \alpha
\end{aligned}
$$

推导：

$$
\begin{aligned}
\mathcal{L} &= \int_{R_1} p(\mathbf{x} | \omega_2) P(\omega_2) d\mathbf{x} + \mu \left( 1-\int_{R_1} p(\mathbf{x} | \omega_1) P(\omega_1) d\mathbf{x} - \alpha \right) \\
&= \int_{R_1} \left( p(\mathbf{x} | \omega_2) P(\omega_2) - \mu p(\mathbf{x} | \omega_1) P(\omega_1) \right) d\mathbf{x} + \mu (1-\alpha)
\end{aligned}
$$

等价于对每个 $\mathbf{x}$ **逐点最小化**被积函数：

- 若 $p(\mathbf{x} | \omega_2) P(\omega_2) - \mu p(\mathbf{x} | \omega_1) P(\omega_1) > 0$，说明把 $\mathbf{x}$ 分入 $R_1$ 产生的代价更大，因此 $\mathbf{x}$ 应属于 $R_2$
- 若为负，则 $\mathbf{x}$ 应属于 $R_1$

即：

$$
p(\mathbf{x} | \omega_2) P(\omega_2) - \mu p(\mathbf{x} | \omega_1) P(\omega_1) < 0
$$

移项：

$$
\frac{p(\mathbf{x} | \omega_1)}{p(\mathbf{x} | \omega_2)} > \frac{P(\omega_2)}{\mu P(\omega_1)} \tag*{(*)}
$$

确定判别阈值 $\mu$:

先用 (*) 定义决策区域 $R_2$ ,然后用等式 $\int_{R_2} p(\mathbf{x} | \omega_1) P(\omega_1) d\mathbf{x} = \alpha$ 来求解 $\mu$。

:::tip

推导过程中，先验是固定的，可以最后算。

:::

## 4. 三类准则的统一视角

三类准则看似不同，但本质上都是 **对似然比 $\dfrac{p(\mathbf{x} | \omega_1)}{p(\mathbf{x} | \omega_2)}$ 设一个阈值**，区别仅在于阈值由什么决定：

| 准则            | 决策依据                                   | 似然比阈值（二分类）                                                 | 依赖先验？   | 依赖损失？           | 适用场景                             |
| --------------- | ------------------------------------------ | -------------------------------------------------------------------- | ------------ | -------------------- | ------------------------------------ |
| **最小错误率**  | 最大后验概率 $P(\omega_j \mid \mathbf{x})$ | $\dfrac{P(\omega_2)}{P(\omega_1)}$                                   | 是           | 否（隐含0-1损失）    | 默认选择，各类错误代价相同           |
| **最小风险**    | 最小期望损失 $R(\omega_j \mid \mathbf{x})$ | $\dfrac{P(\omega_2)\lambda_{12}}{P(\omega_1)\lambda_{21}}$           | 是           | 是（$\lambda_{ij}$） | 误分类代价不对称（如医疗诊断）       |
| **聂曼-皮尔逊** | 固定一类错误率，最小化另一类               | $\dfrac{P(\omega_2)}{\mu P(\omega_1)}$（$\mu$ 由约束 $\alpha$ 解出） | 形式上不依赖 | 否                   | 先验未知或两类错误有硬约束（如安检） |

**记法**：三类准则都等价于$\dfrac{p(\mathbf{x} | \omega_1)}{p(\mathbf{x} | \omega_2)} > \text{threshold} \implies \text{判为 } \omega_1$。核心框架是同一个，变化的只是分子的分母的权重。

同时 $\bm{\arg\max}$ 视角也统一：三类都可以写成 $i = \arg\max_j g_j(\mathbf{x})$ 的形式——最小错误率用后验概率，最小风险用负风险，NP 用似然比（等价于 $g_1 = \Lambda$，$g_2 = \text{threshold}$）。

## 5. 贝叶斯错误率

**任何分类器**的错误率都有一个理论下界，称为**贝叶斯错误率（Bayes Error Rate）**。

### 条件错误率与总体错误率

对于任意分类器 $\hat{\omega}(\mathbf{x})$，在样本 $\mathbf{x}$ 处的条件错误率为：
$$
P(\text{error} \mid \mathbf{x}) = 1 - P(\hat{\omega}(\mathbf{x}) \mid \mathbf{x})
$$

总体错误率是对所有 $\mathbf{x}$ 积分：
$$
P(\text{error}) = \int P(\text{error} \mid \mathbf{x}) \, p(\mathbf{x}) \, d\mathbf{x}
= 1 - \int P(\hat{\omega}(\mathbf{x}) \mid \mathbf{x}) \, p(\mathbf{x}) \, d\mathbf{x}
$$

### 最优性证明

贝叶斯分类器选择后验概率最大的类别 $\hat{\omega}^*(\mathbf{x}) = \arg\max_j P(\omega_j \mid \mathbf{x})$，因此：

$$
P(\hat{\omega}^*(\mathbf{x}) \mid \mathbf{x}) = \max_j P(\omega_j \mid \mathbf{x}) \geq P(\hat{\omega}(\mathbf{x}) \mid \mathbf{x}), \quad \forall \hat{\omega}(\mathbf{x})
$$

代入总体错误率公式，不等式反向（减去更大的数得更小的值）：

$$
P^*(\text{error}) = 1 - \int \max_j P(\omega_j \mid \mathbf{x}) \, p(\mathbf{x}) \, d\mathbf{x}
\leq 1 - \int P(\hat{\omega}(\mathbf{x}) \mid \mathbf{x}) \, p(\mathbf{x}) \, d\mathbf{x} = P(\text{error})
$$

即 **任何分类器的错误率 $\geq$ 贝叶斯错误率**，等号仅当分类器 $\hat{\omega}(\mathbf{x})$ 每点都选择后验最大的类。

### 另一种等价形式

用 §1 的积分区域语言，最小错误率分类器选择：
$$
R_1^* = \{\mathbf{x} \mid P(\omega_1 \mid \mathbf{x}) > P(\omega_2 \mid \mathbf{x})\}, \quad
R_2^* = \{\mathbf{x} \mid P(\omega_2 \mid \mathbf{x}) \geq P(\omega_1 \mid \mathbf{x})\}
$$

贝叶斯错误率就是在这个最优分界下的积分值（即 §1 中 $P(mistake)$ 在最优决策 $R_1^*, R_2^*$ 下的取值）：
$$
P^*(\text{error}) = \int_{R_2^*} p(\mathbf{x} \mid \omega_1) P(\omega_1) \, d\mathbf{x}
+ \int_{R_1^*} p(\mathbf{x} \mid \omega_2) P(\omega_2) \, d\mathbf{x}
$$

或等价地写成**后验的 min 形式**（更紧凑）：

$$
P^*(\text{error}) = \int \min_j P(\omega_j \mid \mathbf{x}) \, p(\mathbf{x}) \, d\mathbf{x}
$$

### 意义

贝叶斯错误率是分类问题的"天花板"——它反映数据本身的重叠程度。如果两类在特征空间上完全可分（分布不重叠），贝叶斯错误率为 0；如果完全不可分（分布完全重合），贝叶斯错误率等于 $\min(P(\omega_1), P(\omega_2))$（瞎猜的水平）。实际分类器的错误率越接近这个值，说明模型越充分挖掘了数据的信息。

## 6. 生成式与判别式分类器

从本篇到下一章，分类器的设计哲学有一条重要的分水岭：**生成式 vs 判别式**。

### 两种建模路径

| | 生成式（Generative） | 判别式（Discriminative） |
|---|---|---|
| **方式** | 先建模 $p(\mathbf{x} \mid \omega_i)$ 和 $P(\omega_i)$，再用贝叶斯公式反推 $P(\omega_i \mid \mathbf{x})$ | 直接建模决策边界 $P(\omega_i \mid \mathbf{x})$ 或 $g(\mathbf{x}) = 0$ |
| **路径** | 数据 $\to$ 类条件分布 $\to$ 后验概率 $\to$ 决策 | 数据 $\to$ 决策函数 $\to$ 决策 |
| **例子** | 贝叶斯分类器、朴素贝叶斯、GMM、HMM | 逻辑回归、感知机、SVM、神经网络 |
| **优点** | 可生成新样本、自然处理缺失值、对数据量要求更低 | 聚焦在分类边界上，通常数据充分时精度更高 |
| **缺点** | 需要假设分布形式，假设错误时偏差大 | 无法生成样本、无法利用无标签数据 |

### 直观对比

以两类问题为例：

- **生成式**先回答"$\omega_1$ 的数据大概长什么样？$\omega_2$ 呢？"，再根据新样本更像哪个来分类。
- **判别式**直接回答"分界线在哪？"，不在意外围数据长什么样，只关心边界附近的样本。

### 本篇定位

本篇（Bayes）是生成式的典范——从概率密度出发，通过贝叶斯公式得到决策规则。接下来（线性分类器）将转向判别式路径，直接从数据学习决策边界，不再显式建模概率密度。两种范式各有所长，理解它们的差异是理解整个模式识别学科的关键视角。
