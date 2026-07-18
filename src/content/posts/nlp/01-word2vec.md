---
title: 词嵌入基础：word2vec
published: 2026-07-18
description: '从 one-hot 到分布式表示：Skip-gram、CBOW、负采样与层次 Softmax 的完整推导'
image: ''
tags: [NLP, word2vec, Embedding, LLM]
category: '09-自然语言处理'
order: 1
draft: false
lang: ''
---

:::tip[符号约定]

| 符号 | 含义 | 示例 |
|------|------|------|
| $\mathcal{V}$ | 词汇表 | $\vert\mathcal{V}\vert = 10^4$ |
| $V$ | 词汇表大小 | $V = \vert\mathcal{V}\vert$ |
| $d$ | 词向量维度 | $d = 300$（典型值） |
| $w_t$ | 位置 $t$ 处的中心词 | $w_t = \text{"apple"} $ |
| $w_{t+j}$ | 位置 $t+j$ 处的上下文词 | $w_{t-1} = \text{"eat"} $ |
| $m$ | 上下文窗口大小 | $m = 2$（两侧各 2 个词） |
| $\mathbf{v}_w \in \mathbb{R}^d$ | 词 $w$ 作为中心词的向量 | 输入向量 |
| $\mathbf{u}_w \in \mathbb{R}^d$ | 词 $w$ 作为上下文词的向量 | 输出向量 |
| $\mathbf{W}_{\text{in}} \in \mathbb{R}^{d \times V}$ | 输入嵌入矩阵 | 每一列是一个词的 $\mathbf{v}_w$ |
| $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$ | 输出嵌入矩阵 | 每一行是一个词的 $\mathbf{u}_w$ |

:::

## 1. 从 One-Hot 到分布式表示

### 1.1 One-Hot 的困境

在 word2vec 之前，词的标准表示是 **one-hot 向量**：每个词 $w$ 被表示为一个长度为 $V$ 的向量，只有词 $w$ 对应的位置为 $1$，其余为 $0$。

例如，词汇表 $\mathcal{V} = \{\text{"apple"}, \text{"banana"}, \text{"cat"}, \text{"dog"}, \text{"eat"}\}$：

$$
\mathbf{x}_{\text{apple}} = \begin{bmatrix} 1 \\ 0 \\ 0 \\ 0 \\ 0 \end{bmatrix},\quad
\mathbf{x}_{\text{banana}} = \begin{bmatrix} 0 \\ 1 \\ 0 \\ 0 \\ 0 \end{bmatrix},\quad
\mathbf{x}_{\text{eat}} = \begin{bmatrix} 0 \\ 0 \\ 0 \\ 0 \\ 1 \end{bmatrix}
$$

这种表示有两个致命缺陷：

1. **维度灾难**：实际词汇表 $V$ 可达 $10^5 \sim 10^6$，向量极其稀疏且高维。
2. **语义鸿沟**：任意两个词的 one-hot 向量内积为 $0$，无法表达"apple"和"banana"之间的语义相似性——它们都是水果，但在 one-hot 空间里与"cat"和"apple"的距离完全相同。

:::tip[直观理解]

如果词是城市，one-hot 编码相当于给每个城市分配一个唯一的编号（北京=0001，上海=0002），但从编号中你看不出北京和上海都是中国的大都市，也看不出北京和东京的距离比北京和火星的距离更近。

**分布式表示**则像是给每个城市一组坐标（经纬度、人口、GDP、气候类型...），语义相近的城市自然在向量空间中靠得更近。

:::

### 1.2 分布式假设

word2vec 的核心思想来自 **分布式假设（Distributional Hypothesis）**：

> "You shall know a word by the company it keeps." — J.R. Firth, 1957

一个词的语义可以由它周围的上下文词来刻画。考虑以下句子：

> The **cat** sits on the **mat**.

在"cat"的上下文中，我们频繁看到"the"、"sits"、"mat"等词；而在"dog"的上下文中，我们也会频繁看到"the"、"sits"、"mat"、"barks"等词。因为"cat"和"dog"有大量相似的上下文，它们的词向量应当相似。

## 2. Skip-gram 模型

Skip-gram 的目标是：**给定中心词 $w_t$，预测其上下文窗口内的词 $w_{t+j}$**（$j \in \{-m, \dots, -1, 1, \dots, m\}$）。

### 2.1 模型结构

Skip-gram 是一个极简的两层神经网络：

```
输入层 (one-hot) → 隐藏层 (d维) → 输出层 (V维 softmax)
```

设中心词 $w_t$ 的 one-hot 向量为 $\mathbf{x} \in \mathbb{R}^V$（只有 $w_t$ 对应位置为 $1$），则：

$$
\mathbf{h} = \mathbf{W}_{\text{in}}^T \mathbf{x} = \mathbf{v}_{w_t}
$$

因为 $\mathbf{x}$ 是 one-hot 的，$\mathbf{h}$ 本质上就是从 $\mathbf{W}_{\text{in}}$ 中"查表"取出 $w_t$ 对应的列向量 $\mathbf{v}_{w_t}$。这正是 **embedding lookup** 操作。

对于输出层，每个上下文词 $w_o$ 的得分：

$$
\text{score}(w_o \mid w_t) = \mathbf{u}_{w_o}^T \mathbf{v}_{w_t}
$$

经过 softmax 归一化得到概率：

$$
P(w_o \mid w_t) = \frac{\exp(\mathbf{u}_{w_o}^T \mathbf{v}_{w_t})}{\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})}
$$

### 2.2 损失函数

对于一对中心词-上下文词 $(w_t, w_o)$，损失函数为负对数似然：

$$
J = -\log P(w_o \mid w_t) = -\mathbf{u}_{w_o}^T \mathbf{v}_{w_t} + \log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})
$$

:::tip[直观理解：内积作为相似度]

$\mathbf{u}_{w_o}^T \mathbf{v}_{w_t}$ 是两个向量的内积。如果中心词向量 $\mathbf{v}_{\text{cat}}$ 和上下文词向量 $\mathbf{u}_{\text{sits}}$ 的内积很大，说明模型认为"cat"和"sits"经常共现，softmax 会给 $P(\text{"sits"} \mid \text{"cat"})$ 分配较高的概率。

训练的目标是：让真实共现的词对 $(\mathbf{v}_{w_t}, \mathbf{u}_{w_o})$ 内积变大，让随机词对的内积变小。
:::

### 2.3 梯度推导

对 $\mathbf{v}_{w_t}$（中心词向量）求梯度：

$$
\frac{\partial J}{\partial \mathbf{v}_{w_t}} = -\mathbf{u}_{w_o} + \sum_{w \in \mathcal{V}} P(w \mid w_t) \cdot \mathbf{u}_w
$$

第一项 $-\mathbf{u}_{w_o}$ 将中心词向量"拉向"真实上下文词；第二项是**所有词的加权平均**，将中心词向量"推开"不相关的词。

这就是 softmax 的瓶颈所在：**每次更新都需要对全体词汇表 $V$ 求和**，当 $V = 10^5$ 时计算量不可接受。

## 3. CBOW 模型

CBOW（Continuous Bag of Words）是 Skip-gram 的镜像：**给定上下文词 $\{w_{t-m}, \dots, w_{t-1}, w_{t+1}, \dots, w_{t+m}\}$，预测中心词 $w_t$**。

对于一个上下文窗口 $\mathcal{C}_t = \{w_{t+j} : j \in \{-m, \dots, m\}, j \neq 0\}$，将上下文词向量取平均：

$$
\mathbf{h} = \frac{1}{|\mathcal{C}_t|} \sum_{w \in \mathcal{C}_t} \mathbf{v}_w
$$

然后送入 softmax：

$$
P(w_t \mid \mathcal{C}_t) = \frac{\exp(\mathbf{u}_{w_t}^T \mathbf{h})}{\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{h})}
$$

CBOW 将多个上下文词的信息聚合到一个向量中，训练速度比 Skip-gram 快（因为一次预测一个中心词，而 Skip-gram 一次预测 $2m$ 个上下文词），但对稀有词的表示效果略差。

| 模型 | 输入 | 输出 | 适合 | 训练速度 |
|------|------|------|------|:--:|
| Skip-gram | 1 个中心词 | $2m$ 个上下文词 | 稀有词、小数据集 | 慢 |
| CBOW | $2m$ 个上下文词 | 1 个中心词 | 高频词、大数据集 | 快 |

## 4. 近似训练方法

softmax 分母 $\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})$ 需要对所有 $V$ 个词求和，计算量 $O(V)$。两种近似方法将复杂度降到 $O(\log V)$ 或 $O(k)$。

### 4.1 负采样（Negative Sampling）

负采样的核心思想：**不必对所有负例建模，只需随机采样 $k$ 个"噪声词"作为负例**。

对于每个正样本 $(w_t, w_o)$，随机采样 $k$ 个噪声词 $\{w_1, \dots, w_k\}$，目标函数变为：

$$
J = -\log \sigma(\mathbf{u}_{w_o}^T \mathbf{v}_{w_t}) - \sum_{i=1}^{k} \log \sigma(-\mathbf{u}_{w_i}^T \mathbf{v}_{w_t})
$$

其中 $\sigma(x) = \frac{1}{1 + e^{-x}}$ 是 sigmoid 函数。

:::tip[直观理解]

这本质上是一个**二分类问题**：对于每个词对，模型需要判断它们是"真实共现"（正例）还是"随机配对"（负例）。

- $\sigma(\mathbf{u}_{w_o}^T \mathbf{v}_{w_t})$：模型认为 $(w_t, w_o)$ 是真实共现的概率
- $\sigma(-\mathbf{u}_{w_i}^T \mathbf{v}_{w_t})$：模型认为 $(w_t, w_i)$ 不是真实共现的概率

和 softmax 的区别在于：softmax 对所有词做 $V$-分类；负采样对每个词对做独立的二分类，只需计算 $k+1$ 次 sigmoid。
:::

噪声词的采样分布通常为：

$$
P(w) \propto \text{count}(w)^{3/4}
$$

$3/4$ 次幂的作用是**提升低频词的采样概率**，防止它们被完全忽略。

### 4.2 层次 Softmax（Hierarchical Softmax）

另一种思路：**用 Huffman 树将 $V$-分类转化为 $\log V$ 次二分类**。

将词汇表中的每个词放在 Huffman 树的叶子节点上（高频词路径短，低频词路径长）。对于中心词 $w_t$，预测上下文词 $w_o$ 的概率为从根节点走到 $w_o$ 叶子节点的路径上各次二分类概率的乘积：

$$
P(w_o \mid w_t) = \prod_{l=1}^{L(w_o)-1} \sigma\left([\![n(w_o, l+1) = \text{left}(n(w_o, l))]\!] \cdot \mathbf{u}_{n(w_o, l)}^T \mathbf{v}_{w_t}\right)
$$

其中 $L(w_o)$ 是路径长度，$n(w_o, l)$ 是路径上第 $l$ 个节点，$[\![\cdot]\!]$ 是指示函数（走左子树为 $+1$，右子树为 $-1$）。

:::tip[直观理解]

想象一个猜词游戏。softmax 的做法是：一次列出所有 $V$ 个词，直接选一个。层次 softmax 的做法是：不断问"是水果吗？"→"是红色的吗？"→"是苹果吗？"，每次只需做二选一。

Huffman 编码保证高频词路径短，所以平均只需 $\log_2 V$ 次二分类。
:::

## 5. 词向量的语义性质

训练完成后，word2vec 的词向量展现出令人惊讶的语义结构。

### 5.1 类比推理

最经典的例子：

$$
\mathbf{v}_{\text{king}} - \mathbf{v}_{\text{man}} + \mathbf{v}_{\text{woman}} \approx \mathbf{v}_{\text{queen}}
$$

向量运算捕捉到了"性别"这个语义维度：从"king"中减去"man"的语义，加上"woman"的语义，得到"queen"。

其他类比：
- $\mathbf{v}_{\text{Paris}} - \mathbf{v}_{\text{France}} + \mathbf{v}_{\text{Italy}} \approx \mathbf{v}_{\text{Rome}}$（首都-国家关系）
- $\mathbf{v}_{\text{walking}} - \mathbf{v}_{\text{walk}} + \mathbf{v}_{\text{swim}} \approx \mathbf{v}_{\text{swimming}}$（动词时态）

### 5.2 为什么会出现线性结构？

负采样的目标函数可以重写为点互信息（Pointwise Mutual Information, PMI）的矩阵分解：

$$
\mathbf{u}_w^T \mathbf{v}_c \approx \text{PMI}(w, c) - \log k
$$

其中 $\text{PMI}(w, c) = \log \frac{P(w, c)}{P(w)P(c)}$ 衡量两个词的实际共现频率与随机共现频率之比。这说明 word2vec 本质上在做**共现矩阵的隐式分解**，将高维稀疏的 PMI 矩阵压缩为低维稠密的词向量。

## 6. 从 word2vec 到现代 LLM

word2vec 奠定了现代 NLP 的基石，但也存在局限性：

| 方面 | word2vec | 现代 LLM (Transformer) |
|------|----------|------------------------|
| 词表示 | **静态**：每个词只有一个固定向量 | **上下文相关**：同一个词在不同句子中向量不同 |
| 多义词处理 | 无法区分"bank"（银行/河岸） | 根据上下文自动消歧 |
| 上下文范围 | 固定窗口 $m$ | 自注意力机制，理论上无限长 |
| 训练目标 | 预测邻居词 | 预测下一个 token（语言模型） |

具体来说，word2vec 训练出的词向量是**静态的**：无论"bank"出现在"river bank"还是"central bank"中，它都使用同一个向量。而 Transformer 的 self-attention 机制会为每个词生成**上下文相关的表示**——这正是我们已经在 [Transformer 编码器核心：self-attention](/posts/transformer/trasformer-attetion/) 中详细讨论过的。

然而，word2vec 的核心思想——**用低维稠密向量表示词，通过共现信息学习语义**——仍然是所有现代词嵌入方法（包括 BERT、GPT 的 embedding 层）的基础。在下一节中，我们将看到 GloVe 如何改进 word2vec 的统计信息利用，以及 BPE 子词嵌入如何解决 OOV 问题。

## 参考文献

- Mikolov, T., et al. (2013). Efficient Estimation of Word Representations in Vector Space. *arXiv:1301.3781*.
- Mikolov, T., et al. (2013). Distributed Representations of Words and Phrases and their Compositionality. *NIPS 2013*.
- Goldberg, Y., & Levy, O. (2014). word2vec Explained: Deriving Mikolov et al.'s Negative-Sampling Word-Embedding Method. *arXiv:1402.3722*.