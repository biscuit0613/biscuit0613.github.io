---
title: 'GloVe：全局共现+局部上下文窗口'
published: 2026-10-20
description: '用共现概率的比值构造词向量目标，把全局统计与加权最小二乘结合起来的 GloVe 模型'
image: ''
tags: [NLP, GloVe, Embedding, Xo-occurrence]
category: '09-自然语言处理'
order: 603
draft: false
lang: ''
---

[Word2Vec](/posts/nlp/06-02-word2vec/) 在局部窗口上做预测，训练快，但没有直接利用整个语料的全局统计；[共现矩阵与 SVD](/posts/nlp/06-01-word-representation/) 利用全局统计，却要显式构造并分解 $V \times V$ 的矩阵。

GloVe（Global Vectors）试图结合两者：**用全局共现统计与局部上下文窗口构造训练目标，用类似预测模型的最小二乘方式学习词向量**。它不直接做 SVD，而是让词向量的点积去拟合共现次数的对数。

:::tip
这里的局部上下文窗口是在统计共现时的限制，只在窗口内的词才算共现。
:::

## 共现矩阵，共现概率与共现概率比

共现矩阵记为 $X \in \mathbb{R}^{V \times V}$，其中 $V$ 是词表大小。

- 它是对称的，即 $X_{ij} = X_{ji}$。

- $X_{ij}$ 是词 $j$ 出现在词 $i$ **一定窗口内** 的上下文中的次数（可按距离加权）
- $X_i = \sum_j X_{ij}$表示词语 $i$ 与所有上下文词的总共现次数。
- 共现概率：词语 $i$ 的上下文中词 $j$ 出现的概率为

$$
P_{ij}\quad \text{或条件概率形式}\quad P(j \mid i) = \frac{X_{ij}}{X_i}
$$

单独看 $P_{ij}$ 受词频影响很大，但两个共现概率的 **比值** 可以过滤掉这种影响。

:::tip[论文例子]

以经典的“冰”和“蒸汽”为例：

| 上下文词 $k$ | $P(k \mid \text{ice})$ | $P(k \mid \text{steam})$ | 比值 $\dfrac{P(k \mid \text{ice})}{P(k \mid \text{steam})}$ |
| --- | --- | --- | --- |
| solid | $1.9 \times 10^{-4}$ | $2.2 \times 10^{-5}$ | 8.9 |
| gas | $6.6 \times 10^{-5}$ | $7.8 \times 10^{-4}$ | 0.085 |
| water | $3.0 \times 10^{-3}$ | $2.2 \times 10^{-3}$ | 1.36 |
| fashion | $1.7 \times 10^{-5}$ | $1.8 \times 10^{-5}$ | 0.96 |

- $k=solid$：比值远大于 1，说明 solid 更倾向于出现在 ice 附近。

- $k=gas$：比值远小于 1，说明 gas 更倾向于出现在 steam 附近。

- $k=water$：比值接近 1，说明它对区分 ice 和 steam 没什么帮助。

- $k=fashion$：比值也接近 1，同样没有明显区分能力。

:::

**共现概率的比值** $\dfrac{P_{ik}}{P_{jk}}=\dfrac{P(k\mid i)}{P(k\mid j)}$ 能够表示两个词之间具有 **区分性** 的 **语义关系**：

- **比值接近 1 表示该上下文词与两个中心词都无关或都相关**
- **比值远离 1 表示它能区分两者**。
  - $>>1$ 表示 $i$ 比 $j$ 更倾向于出现在 $k$ 附近；
  - $<<1$ 表示 $j$ 比 $i$ 更倾向于出现在 $k$ 附近。

## 使用词向量表示概率比（推导）

GloVe 希望词向量能重现这种比值结构。

定义：

- $\mathbf{w}_i$：目标/中心词（Center Word / Target Word） $i$ 的向量。
- $\mathbf{w}_j$：目标词 $j$ 的向量。
- $\tilde{\mathbf{w}}_k$：上下文词 $k$ 的向量。

$$
F(\mathbf{w}_i, \mathbf{w}_j, \tilde{\mathbf{w}}_k) = \frac{P_{ik}}{P_{jk}}
$$

:::tip[注意到]

- word2vec的工作已经证明了词类比关系是向量差，因此肯定有减号
- 右边是个标量且大于零，左边大概率有内积
- 这玩意是对称的,在词-词共现矩阵中，目标词和上下文词的角色其实是可以互换的。交换目标词和上下文词的角色，不应该改变模型所表达的基本统计关系。
  - 此时 $F$ 成为下面两个群之间的同态（homomorphism）：
    $$
    (\mathbb R,+)
    \longrightarrow
    (\mathbb R_{>0},\times)
    $$
  - 用人话说就是 $F(a+b) = F(a)F(b),F(a-b) = F(a)/F(b)$，所以 $F$ 很可能是指数函数。

:::

$$
\begin{aligned}
F(\mathbf{w}_i - \mathbf{w}_j, \tilde{\mathbf{w}}_k) &= \frac{P_{ik}}{P_{jk}}
\\
\rightarrow
F((\mathbf{w}_i - \mathbf{w}_j)^T \tilde{\mathbf{w}}_k) &= \frac{P_{ik}}{P_{jk}}
\\
\text{令}a=\mathbf{w}_i^T\tilde{\mathbf w}_k\quad
b=\mathbf w_j^T\tilde{\mathbf w}_k &\text{用F的同态性质}\\
\rightarrow
\frac{F(\mathbf{w}_i^T\tilde{\mathbf w}_k) }{ F(\mathbf w_j^T\tilde{\mathbf w}_k)} &= \frac{P_{ik}}{P_{jk}}\\
\end{aligned}
$$

直接令分子和分母相等，两个分数就相等（还涉及一个公共乘法因子的自由度；论文采用了最自然的归一化选择，将这个因子取为 1），再结合 $F$ 的指数函数形式得到：

$$
\mathbf{w}_i^T \tilde{\mathbf{w}}_k = \log P_{ik} = \log X_{ik} - \log X_i
$$

$$
\boxed{
\mathbf{w}_i^T \tilde{\mathbf{w}}_k + \log X_i = \log X_{ik}
}
$$

这个框里面的结果很重要

1. 把原来三个词之间的关系，转换成了单个目标词和上下文词之间的关系。
2. 说明了**词向量的点积（加偏置）应当拟合它们共现次数的对数**。可以用最小二乘的方式来训练词向量。

## 加权最小二乘目标(损失函数)

把上面的近似写成平方损失，并对所有共现对求和：其中：

- $b_i$：目标词偏置，吸收 $\log X_i$；
- $c_j$：上下文词偏置，保证交换 $i,j$ 时形式对称。

- 权重函数 $f(X_{ij})$ 用来处理不同频率的共现对：

    $$
    f(x) =
    \begin{cases}
    (x / x_{\max})^\alpha, & x < x_{\max} \\
    1, & x \ge x_{\max}
    \end{cases}
    $$

    典型取值为 $\alpha = 0.75$，$x_{\max} = 100$。

  - $X_{ij}=0$ 时 $f(0)=0$，未共现的词对不参与损失；
  - 低频共现对统计噪声大，权重相应较小；
  - 高频共现对权重截断为 1，防止“的”“the”这类词对主导训练。
  - $\alpha = 0.75$ 在“不过度信任低频统计”和“不让高频词对淹没训练”之间折中。

$$
\boxed{J = \sum_{i=1}^{V} \sum_{j=1}^{V}
f(X_{ij}) \left( \mathbf{w}_i^T \mathbf{\tilde{w}}_j + b_i + c_j - \log X_{ij} \right)^2}
$$

## 参数量

要训练的参数量为：

- 目标词向量矩阵 $W \in \mathbb{R}^{V \times d}$，其中 $d$ 是词向量维度；
- 上下文词向量矩阵 $\tilde{W} \in \mathbb{R}^{V \times d}$，其中 $d$ 是词向量维度；
- 目标词偏置向量 $b \in \mathbb{R}^{V}$；
- 上下文词偏置向量 $c \in \mathbb{R}^{V}$。

$$
2Vd + 2V = 2V(d+1)
$$

## 参数更新

GloVe 用 AdaGrad 对上述目标做随机梯度下降。对单个词的梯度计算如下，实际中会累积梯度后再更新：

$$
\begin{aligned}
\frac{\partial J}{\partial \mathbf{w}_i} &= \sum_{j=1}^{V} f(X_{ij}) \left( \mathbf{w}_i^T \mathbf{\tilde{w}}_j + b_i + c_j - \log X_{ij} \right) \mathbf{\tilde{w}}_j
\\
\frac{\partial J}{\partial \mathbf{\tilde{w}}_j} &= \sum_{i=1}^{V} f(X_{ij}) \left( \mathbf{w}_i^T \mathbf{\tilde{w}}_j + b_i + c_j - \log X_{ij} \right) \mathbf{w}_i
\\
\frac{\partial J}{\partial b_i} &= \sum_{j=1}^{V} f(X_{ij}) \left( \mathbf{w}_i^T \mathbf{\tilde{w}}_j + b_i + c_j - \log X_{ij} \right)
\\
\frac{\partial J}{\partial c_j} &= \sum_{i=1}^{V} f(X_{ij}) \left( \mathbf{w}_i^T \mathbf{\tilde{w}}_j + b_i + c_j - \log X_{ij} \right)
\\
\theta &\leftarrow \theta - \eta \frac{\partial J}{\partial \theta}
\end{aligned}
$$

## 词向量最终表示

由于共现矩阵对称，词 $i$ 作为中心词和上下文词的向量在理论上应当一致，但随机初始化和训练过程会让它们不同。常见做法是取两者之和：

$$
\mathbf{e}_i = \mathbf{w}_i + \mathbf{\tilde{w}}_i
$$

作为最终词向量。偏置项只用于拟合，训练完成后丢弃。

## 与 word2vec、SVD 的关系

| 方面 | SVD | word2vec | GloVe |
| --- | --- | --- | --- |
| 统计来源 | 全局共现矩阵 | 局部窗口预测 | 全局共现矩阵 |
| 训练方式 | 矩阵分解 | 随机梯度下降 | 加权最小二乘 |
| 目标 | 低秩近似 | 上下文似然 | 拟合 $\log X_{ij}$ |
| 计算特点 | 需构造完整矩阵 | 可流式采样 | 需构造完整矩阵 |

GloVe 可以看作“带加权的最小二乘矩阵分解”，也可以看作一种隐式的共现统计模型。它与 word2vec 在多数任务上效果接近：word2vec 的局部窗口对稀有词更友好，GloVe 的全局统计在词类比等任务上略占优势。

## 局限

- 需要先统计全局共现矩阵，内存开销随 $V^2$ 增长，构造成本高；
- 新词加入后，严格来说需要更新共现统计并重新训练；
- 仍然是静态词向量，无法区分多义词；
- 词表外的词没有表示，需要依靠子词方法（见 [子词分词](/posts/nlp/06-04-subword-tokenization/)）。

## 相关阅读

- 共现矩阵、PMI 与 SVD：[词向量基础](/posts/nlp/06-01-word-representation/)
- 局部上下文预测：[Word2Vec](/posts/nlp/06-02-word2vec/)
- 子词与 OOV：[子词分词](/posts/nlp/06-04-subword-tokenization/)
- 神经语言模型：[NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)
- 词向量评价：[词向量的评价](/posts/nlp/05-02-embedding-evaluation/)
