---
title: Trasformer-编码器核心：self-attention自注意力机制
published: 2026-06-27
description: ''
image: ''
tags: []
category: '05-注意力与Transformer'
order: 32
draft: false 
lang: ''
---

Transformer的架构由编码器（Encoder） 和解码器（Decoder） 两大部分组成

这里重点介绍编码器部分的核心机制：**自注意力机制（Self-Attention）**，它是Transformer的核心创新之一。

## 符号

:::tip

工程上，行优先，常见于代码，例如$X\in \mathbb{R}^{n \times d}$；列优先，常见于数学公式。这里为了方便理解，采用列优先的方式。两者在乘积顺序和转置上面有一点区别，但本质上是一样的。

:::

| 符号                               | 含义                                             |
| ---------------------------------- | ------------------------------------------------ |
| $n$                                | 输入序列的长度（词元个数）                       |
| $d$                                | 词嵌入向量的维度                                 |
| $X\in \mathbb{R}^{d \times n}$     | 输入序列的词嵌入矩阵，每一列是一个词元的嵌入向量 |
| $Q\in \mathbb{R}^{d_k \times n}$   | 查询（Query）矩阵，每一列是一个词元的查询向量    |
| $\mathbf{q_i}\in \mathbb{R}^{d_k}$ | 第 $i$ 个词元的查询向量                          |
| $K\in \mathbb{R}^{d_k \times n}$   | 键（Key）矩阵，每一列是一个词元的键向量          |
| $\mathbf{k_j}\in \mathbb{R}^{d_k}$ | 第 $j$ 个词元的键向量                            |
| $V\in \mathbb{R}^{d_v \times n}$   | 值（Value）矩阵，每一列是一个词元的值向量        |
| $\mathbf{v_j}\in \mathbb{R}^{d_v}$ | 第 $j$ 个词元的值向量                            |
| $d_k$                              | 查询和键向量的维度                               |
| $d_v$                              | 值向量的维度                                     |

| 中间量                                               | 含义                                     |
| ---------------------------------------------------- | ---------------------------------------- |
| $s_{ij}$                                             | 第 $i$ 个词元对第 $j$ 个词元的注意力得分 |
| $S\in \mathbb{R}^{n \times n}$                       | 注意力得分矩阵                           |
| $A\in \mathbb{R}^{n \times n}$                       | 注意力权重矩阵                           |
| $A_{ij}$ 或 $\text{Attention}_{ij}$ 或 $\alpha_{ij}$ | 第 $i$ 个词元对第 $j$ 个词元的注意力权重 |
| $Z\in \mathbb{R}^{d_v \times n}$                     | 自注意力机制的输出矩阵                   |
| $\mathbf{z_i}\in \mathbb{R}^{d_v}$                   | 第 $i$ 个词元的输出向量                  |

| 参数                                | 含义                                                                  |
| ----------------------------------- | --------------------------------------------------------------------- |
| $W_Q\in \mathbb{R}^{d_k \times d}$  | 查询的权重矩阵                                                        |
| $W_K\in \mathbb{R}^{d_k \times d}$  | 键的权重矩阵                                                          |
| $W_V\in \mathbb{R}^{d_v \times d}$  | 值的权重矩阵                                                          |
| $W_O\in \mathbb{R}^{d \times hd_v}$ | 多头注意力共享的输出矩阵；混合拼接后的各头输出并映射回 $d$ 维嵌入空间 |

## "自" 参注意力

在机器翻译中，传统的注意力（Cross-Attention，交叉注意力）是：解码器在生成“苹果”这个词时，去编码器里找输入句子“I love apples”中哪个词（I / love / apples）最相关。

而自注意力中的“自”指的是：Query（查询）、Key（键）、Value（值）这三个向量，全部来自同一个输入序列本身。

## 词嵌入向量/矩阵

词嵌入向量（Embedding）：每个输入词都会被映射为一个高维向量，称为 **词嵌入向量**。

假设输入序列长度为 $n$，每个词的嵌入维度为 $d$，则输入序列可以表示为一个 **词嵌入矩阵** $X=[\mathbf{x_1}, \mathbf{x_2}, ..., \mathbf{x_n}] \in \mathbb{R}^{d \times n}$。

## QKV向量/矩阵

为了计算注意力，需要为每个词生成 **三个** 不同的向量。这三个向量是通过三个 **可训练** 的 **权重矩阵** 与 **输入向量** 相乘得到的，对于一整个输入序列也就是三个 **权重矩阵** 与 **词嵌入矩阵** $X$ 相乘：

- Query（查询）矩阵 $Q = W_QX=[W_Q\mathbf{x_1}, W_Q\mathbf{x_2}, ..., W_Q\mathbf{x_n}]=[\mathbf{q_1}, \mathbf{q_2}, ..., \mathbf{q_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_Q \in \mathbb{R}^{d_k \times d}$ 是查询的权重矩阵，$d_k$ 是查询向量的维度。
  - “提问者”。这个词想知道：“在当前语境下，我应该关注谁？”

- Key（键）矩阵 $K = W_KX=[W_K\mathbf{x_1}, W_K\mathbf{x_2}, ..., W_K\mathbf{x_n}]=[\mathbf{k_1}, \mathbf{k_2}, ..., \mathbf{k_n}]\in \mathbb{R}^{d_k \times n}$，
  - 其中 $W_K \in \mathbb{R}^{d_k \times d}$ 是键的权重矩阵。
  - “被问者”。这个词说：“我的特征是XXX，看看你要找的是不是我？”

:::tip

这里可以发现，Query和Key的维度是一样的，都是 $d_k$，这是因为注意力得分是通过 Query 和 Key 的点积计算的，点积要求两个向量的维度相同。

$Q$ 和 $K$ 都把词嵌入向量投影到一个低维的查询空间（Query Space）和键空间（Key Space），这个低维空间的维度通常比原始嵌入维度小很多（例如 $d_k=128\lt d=12888$）。

:::

值得注意的是，当键向量 $\mathbf{k_j}$ 与查询向量 $\mathbf{q_i}$ "对齐" 的时候，意味着第 $i$ 个token 的嵌入在当前语境下应该更多地 **关注** 第 $j$ 个token的嵌入。用点积来衡量这种对齐程度是一个非常自然的选择，因为点积在向量空间中可以反映两个向量的相似性。

为了数值稳定性，通常会将点积结果除以 $\sqrt{d_k}$，这是因为在高维空间中，向量的点积可能会变得非常大(若 $q,k$ 分量方差近似为 1，则点积方差随 $d_k$ 增长；除以 $\sqrt{d_k}$ 使尺度稳定)，从而导致 Softmax 函数的梯度消失问题。

后续的注意力权重矩阵 $A$，就是对这个矩阵 **按行** 做 Softmax 归一化。（如果一开始是工程中常见的行优先表示法，那么就是按列做 Softmax 归一化）

- Value（值）矩阵 $V = W_VX=[W_V\mathbf{x_1}, W_V\mathbf{x_2}, ..., W_V\mathbf{x_n}]=[\mathbf{v_1}, \mathbf{v_2}, ..., \mathbf{v_n}]\in \mathbb{R}^{d_v \times n}$，
  - 其中 $W_V \in \mathbb{R}^{d_v \times d}$ 是值的权重矩阵，$d_v$ 是值向量的维度。
  - “实际内容”。一旦确认了“提问者”和“被问者”很匹配，这就是我实际要传递给你的具体语义信息。

这里 $W_v$ 的输入输出空间都是 $d$ 维的嵌入空间，对于单头 $d_v=d$，也就是值向量的维度和原始嵌入维度相同。但是这里可以采用 **低秩分解** 的技巧拆成两个小矩阵降低参数量和计算量

## self-attention计算步骤(单头)

### 第1步：计算注意力得分（点积）

计算任意两个词元 $i$ 和 $j$ 的注意力得分（标量）

$$
s_{ij} = \mathbf{q_i}^T \mathbf{k_j} = \sum_{l=1}^{d_k} q_{il} k_{jl}
$$

得分矩阵 $S = [s_{ij}] \in \mathbb{R}^{n \times n}$，其中 $s_{ij}$ 表示第 $i$ 个词元对第 $j$ 个词元的注意力得分。

$$
S = Q^T K
$$

得到的矩阵图（注意力模式，Attention Pattern）：

<div class="attention-viz" data-attention-viz>
<style>
  .attention-viz { --av-ink:#ecebe6; --av-line:rgba(223,226,219,.30); --av-query:#4bb69c; --av-key:#dfdf30; --av-value:#ed7067; --av-paper:#070908; position:relative; isolation:isolate; margin:2rem 0; overflow:hidden; border:1px solid #262b28; background:var(--av-paper); color:var(--av-ink); font-family:Georgia, "Times New Roman", serif; box-shadow:0 18px 44px rgba(0,0,0,.22); }
  .attention-viz::before { content:""; position:absolute; inset:0; z-index:-1; opacity:.3; background:radial-gradient(ellipse at 30% 15%, rgba(44,93,72,.2), transparent 38%), repeating-linear-gradient(110deg, rgba(255,255,255,.018) 0 1px, transparent 1px 5px); }
  .av-frame { min-width:720px; padding:1.25rem 1.35rem 1.1rem; }
  .av-caption { display:flex; align-items:baseline; justify-content:space-between; gap:1rem; margin:0 0 1rem; color:#d5d6d0; font-size:.86rem; letter-spacing:.04em; }
  .av-caption strong { color:#fff; font-size:1rem; font-weight:normal; }
  .av-caption em { color:#9a9f98; font-style:italic; }
  .av-sentence { display:grid; grid-template-columns:195px repeat(8, minmax(72px, 1fr)); border-bottom:1px solid var(--av-line); }
  .av-corner { min-height:158px; display:grid; place-items:end start; padding:0 0 .7rem .3rem; color:#a6aaa4; font-style:italic; font-size:.85rem; }
  .av-token { min-height:158px; display:flex; flex-direction:column; align-items:center; justify-content:center; border-left:1px solid var(--av-line); color:#e9e9e5; }
  .av-token button { all:unset; cursor:pointer; color:inherit; text-align:center; }
  .av-word { display:inline-block; padding:.08rem .28rem; border:2px solid currentColor; line-height:1; font-size:1rem; text-shadow:0 0 9px currentColor; }
  .av-project-down { display:flex; flex-direction:column; align-items:center; line-height:1; margin:.22rem 0; color:#e9e9e5; font-size:1.35rem; }
  .av-project-down small { color:var(--av-key); font-size:.72rem; font-style:italic; margin-bottom:.02rem; }
  .av-vector { color:var(--av-ink); font-size:1.22rem; font-weight:bold; text-shadow:0 0 10px rgba(255,255,255,.2); }
  .av-vector.q { color:var(--av-query); } .av-vector.k { color:var(--av-key); } .av-vector.v { color:var(--av-value); }
  .av-grid { display:grid; grid-template-columns:195px repeat(8, minmax(72px, 1fr)); }
  .av-row-label { min-height:54px; display:flex; align-items:center; gap:.22rem; padding-left:.32rem; border-bottom:1px solid var(--av-line); color:var(--av-key); white-space:nowrap; }
  .av-row-label .av-arrow { color:#e9e9e5; font-size:1.35rem; line-height:1; }
  .av-row-label .av-project { position:relative; display:inline-flex; align-items:center; color:#e9e9e5; font-size:1.25rem; line-height:1; }
  .av-row-label .av-project small { position:absolute; left:50%; top:-.82rem; transform:translateX(-50%); color:var(--av-key); font-size:.66rem; font-style:italic; }
  .av-cell { position:relative; min-height:54px; display:grid; place-items:center; border-left:1px solid var(--av-line); border-bottom:1px solid var(--av-line); color:rgba(227,229,222,.48); font-size:.86rem; transition:background .28s, color .28s, box-shadow .28s; }
  .av-cell .av-dot { width:15px; height:15px; border-radius:50%; background:#a5a6a3; opacity:.78; box-shadow:0 0 0 1px rgba(255,255,255,.1); }
  .av-cell .av-math { position:absolute; color:var(--av-query); font-size:.76rem; }
  .av-cell .av-math span { color:var(--av-key); }
  .av-cell.active { background:radial-gradient(circle, rgba(223,223,48,.22), transparent 62%); color:#fff; box-shadow:inset 0 0 0 1px rgba(223,223,48,.65); }
  .av-cell.active .av-dot { transform:scale(1.45); background:#e3e4dd; box-shadow:0 0 16px rgba(223,223,48,.7); }
  .av-cell.focus-row { background:rgba(255,255,255,.025); }
  .av-footer { display:flex; justify-content:space-between; gap:1rem; padding:.85rem .25rem 0; color:#a5aaa2; font-size:.78rem; }
  .av-footer .av-formula { color:#e7e7e3; font-size:1rem; }
  .av-footer .q { color:var(--av-query); } .av-footer .k { color:var(--av-key); } .av-footer .v { color:var(--av-value); }
  .av-token.active { background:linear-gradient(to bottom, rgba(223,223,48,.14), transparent 70%); box-shadow:inset 0 3px 0 var(--av-key); }
  .av-token.active .av-word { color:#fff; border-color:var(--av-key); box-shadow:0 0 15px rgba(223,223,48,.24); }
  @media (max-width:760px) { .attention-viz { overflow-x:auto; } .av-caption { min-width:800px; } }
</style>
  <div class="av-frame">
    <div class="av-caption"><strong>Query · Key 的相似度矩阵</strong><em>点击上方任一词元，观察它作为 Query 时与所有 Key 的点积</em></div>
    <div class="av-sentence av-kq-tokens"></div>
    <div class="av-grid av-kq-grid"></div>
    <div class="av-footer"><span class="av-formula">S<sub>ij</sub> = <span class="q">q<sub>i</sub></span><sup>T</sup> · <span class="k">k<sub>j</sub></span></span><span>亮点 = 当前 Query 最关心的 Key</span></div>
  </div>
</div>

### 第2步：缩放 + Softmax（按行做 Softmax，使每一行之和为 1）

$$
A = \text{softmax}\left(\frac{S}{\sqrt{d_k}}\right)
$$

A是注意力权重矩阵，$A \in \mathbb{R}^{n \times n}$，其中 $A_{ij}$ 表示第 $i$ 个词元对第 $j$ 个词元的注意力权重。

### 第3步：加权求和(对应的Value向量)

对于每个词元 $i$，其输出向量 $\mathbf{z_i}$ 是所有 **值向量** 以 **注意力权重** 为系数的加权和：

$$
\mathbf{z_i} = \sum_{j=1}^{n} A_{ij} \mathbf{v_j}
$$

<div class="attention-viz av-value-viz" data-value-viz>
  <div class="av-frame">
    <div class="av-caption"><strong>用注意力权重读取 Value</strong><em>选择一个 Query，查看它如何从所有 Value 中汇聚信息</em></div>
    <div class="av-sentence av-value-tokens"></div>
    <div class="av-grid av-value-grid"></div>
    <div class="av-footer"><span class="av-formula"><span class="v">z<sub>i</sub></span> = Σ<sub>j</sub> α<sub>ij</sub><span class="v">v<sub>j</sub></span></span><span class="av-value-readout">当前：q<sub>4</sub> 读取 v<sub>2</sub>、v<sub>3</sub></span></div>
  </div>
</div>

<script>
(() => {
  const words = ["a", "fluffy", "blue", "creature", "roamed", "the", "verdant", "forest"];
  const colors = ["#dadada", "#66d5ee", "#37c6e9", "#cabfaf", "#a9a9a9", "#e2e2e2", "#9de36c", "#c7beb6"];
  const weights = [
    [.28,.14,.12,.06,.05,.11,.10,.14], [.08,.24,.21,.05,.06,.09,.12,.15],
    [.07,.20,.28,.08,.05,.06,.13,.13], [.00,.42,.58,.00,.00,.00,.00,.00],
    [.10,.08,.13,.20,.19,.05,.12,.13], [.14,.08,.09,.04,.06,.26,.12,.21],
    [.08,.11,.16,.06,.09,.10,.28,.12], [.06,.09,.12,.08,.16,.13,.18,.18]
  ];
  const sub = n => `<sub>${n + 1}</sub>`;
  const vector = (name, i, color) => `<span class="av-vector ${color}">𝐱${sub(i)}</span>`.replace("𝐱", { q: "𝐪", k: "𝐤", v: "𝐯" }[name] || "𝐱");
  const tokenMarkup = (selected, mode) => `<div class="av-corner">${mode === "kq" ? "每列：嵌入向量左乘 W_Q，得到 Query" : "每列：词元的嵌入向量"}</div>${words.map((word, i) => `<div class="av-token ${i === selected ? "active" : ""}"><button type="button" data-index="${i}" aria-label="选择 ${word}"><span class="av-word" style="color:${colors[i]}">${word}</span><span class="av-project-down">↓</span>${vector("x", i, "x")}${mode === "kq" ? `<span class="av-project-down"><small>W<sub>Q</sub></small>↓</span>${vector("q", i, "q")}` : ""}</button></div>`).join("")}`;
  const rowProjection = (row, matrix, result, color) => `<div class="av-row-label"><span class="av-word" style="color:${colors[row]}">${words[row]}</span><span class="av-arrow">→</span>${vector("x", row, "x")}<span class="av-project"><small>W<sub>${matrix}</sub></small>→</span>${vector(result, row, color)}</div>`;
  const kq = document.querySelector("[data-attention-viz]");
  const value = document.querySelector("[data-value-viz]");
  if (!kq || !value || kq.dataset.ready) return;
  kq.dataset.ready = "true";
  let selected = 3;
  function render() {
    kq.querySelector(".av-kq-tokens").innerHTML = tokenMarkup(selected, "kq");
    kq.querySelector(".av-kq-grid").innerHTML = words.map((_, row) => `${rowProjection(row, "K", "k", "k")}${words.map((__, col) => `<div class="av-cell ${col === selected ? "focus-row" : ""} ${row === weights[selected].indexOf(Math.max(...weights[selected])) && col === selected ? "active" : ""}"><span class="av-math">k${sub(row)} · <span>q${sub(col)}</span></span><span class="av-dot"></span></div>`).join("")}`).join("");
    value.querySelector(".av-value-tokens").innerHTML = tokenMarkup(selected, "value");
    value.querySelector(".av-value-grid").innerHTML = words.map((word, row) => { const weight = weights[selected][row]; const intensity = Math.max(.08, weight); return `${rowProjection(row, "V", "v", "v")}${words.map((_, col) => `<div class="av-cell ${col === selected ? "focus-row" : ""} ${col === selected && weight === Math.max(...weights[selected]) ? "active" : ""}" style="${col === selected ? `background:radial-gradient(circle, rgba(237,112,103,${intensity * .75}), transparent 70%)` : ""}">${col === selected ? `<span class="av-math" style="color:#eee">${weight.toFixed(2)} <span style="color:var(--av-value)">v${sub(row)}</span></span><span class="av-dot" style="transform:scale(${.65 + weight * 1.7})"></span>` : ""}</div>`).join("")}`; }).join("");
    value.querySelector(".av-value-readout").innerHTML = `当前：q${sub(selected)} 以权重加总所有 v${sub(0)}…v${sub(7)}`;
    document.querySelectorAll("[data-index]").forEach(button => button.addEventListener("click", () => { selected = Number(button.dataset.index); render(); }));
  }
  render();
})();
</script>

这个向量 $\mathbf{z_i}$ 是第 $i$ 个 token 从上下文读取到的 **单头自注意力输出**，维度为 $d_v$。它描述了其他 token 应向当前位置传递什么信息；但它一般还不是可以直接加到 $\mathbf{x_i}\in\mathbb{R}^d$ 上的更新量，因为通常 $d_v\neq d$。标准多头注意力会先拼接所有头的输出，再通过 $W_O$ 映射回 $d$ 维，随后才进行残差相加。

只有在单头且明确取 $d_v=d$、并省略输出投影时，才可以把它简化理解为：

$$
\mathbf{x_i}\leftarrow\mathbf{x_i}+\mathbf{z_i}
$$

写成矩阵形式：

$$
Z = VA^T\in \mathbb{R}^{d_v \times n}
$$

### 矩阵形式

$$
Z = VA^T = V \cdot \text{softmax}\left(\frac{Q^T K}{\sqrt{d_k}}\right)^T
$$

## 多头注意力机制（Multi-Head Attention）

**多头** 指的是：将查询、键、值向量分别映射到 **多个子空间** 中，进行多次注意力计算，然后将结果拼接起来。

>有点类似于CNN中的多通道卷积，每个通道可以学习到不同的特征表示。这里每个头也可以看作是一个独立的注意力机制，它们可以关注输入序列的不同方面。

除了每个头各自拥有的 $W_Q^r,W_K^r,W_V^r$ 外，**整个多头注意力模块**还有一套 **共享** 参数 $W_O$。它不是第四种 Q/K/V 投影，也不直接作用于输入 $X$：每个头先完成注意力加权并得到低维输出，所有头的输出拼接后，才由 $W_O$ 将它们混合并写回原始嵌入空间。

整体数据流可以概括为：

$$
X\xrightarrow{W_Q^r,W_K^r,W_V^r}
Q^r,K^r,V^r
\xrightarrow{\mathrm{Attention}}
Z^r
\xrightarrow{\mathrm{Concat}}
Z_{concat}
\xrightarrow{W_O}
\Delta X
\xrightarrow{+X}
X_{\mathrm{attn}}
$$

其中 $r=1,\ldots,h$ 表示第 $r$ 个头；前三个投影矩阵决定每个头“如何查询、如何匹配、如何传递内容”，而 $W_O$ 决定如何将所有头读出的信息重新组合成对嵌入的更新。

### 每个头的QKV以及输出

对于每个头 $r$，有独立的权重矩阵 $W_Q^r, W_K^r, W_V^r$，

维度：$W_Q^r,W_K^r\in\mathbb R^{d_k\times d}$，$W_V^r\in\mathbb R^{d_v\times d}$。

对于上下文中的每个位置，也就是每个 token 的嵌入，**每个头**都会计算自己的低维上下文信息 $Z^r\in\mathbb{R}^{d_v\times n}$：

- 行数 $d_v$：这个头为每个 token 读出的特征；
- 列数 $n$：序列中的 token 位置。

$$
Z^r = V^r A^{rT} = V^r  \cdot \text{softmax}\left(\frac{(Q^r )^T (K^r )}{\sqrt{d_k}}\right)^T
$$

### 拼接（Concatenate）所有头的输出

将 h 个头的输出矩阵在行方向（特征维度）上堆叠：$d_v$ 维的输出向量拼接成 $hd_v$ 维的向量，列数仍然是 $n$：

$$
Z_{concat} = [Z^1; Z^2; ...; Z^h] \in \mathbb{R}^{hd_v \times n}
$$

也就是说：token 的位置（列）不动，只把不同头为这个 token 提供的特征接在一起。

:::tip

在常见的行优先代码表示中，张量形状是 $n\times d_v$，所以会说“沿最后一个维度 拼接”；本质完全相同：固定 token 维度，拼接特征维度。

:::

### 输出回到原始维度，并通过残差更新

需要一个新参数矩阵 $W_O \in \mathbb{R}^{d \times hd_v}$，将拼接后的输出映射回原始嵌入空间。将这个映射结果记为注意力子层提供的更新量 $\Delta X$：

$$
\Delta X=W_OZ_{concat}\in\mathbb{R}^{d\times n}
$$

因此，对第 $i$ 个位置，有：

$$
\Delta\mathbf{x_i}=W_O
\begin{bmatrix}
\mathbf{z_i}^{(1)}\\
\vdots\\
\mathbf{z_i}^{(h)}
\end{bmatrix},\qquad
\mathbf{x_i}^{\mathrm{attn}}=\mathbf{x_i}+\Delta\mathbf{x_i}
$$

这里 $W_O$ 会混合各个头读出的信息，并将其翻译回原始的 $d$ 维嵌入空间；残差连接则保留原始表示，只叠加注意力带来的上下文增量。实际 Transformer Block 还会结合归一化层：原始 Transformer 常写为 $\operatorname{LayerNorm}(X+\Delta X)$（Post-Norm），现代 LLM 中更常见的是先归一化再计算注意力，即 $X+\operatorname{MHA}(\operatorname{Norm}(X))$（Pre-Norm）。

### 小巧思

对于嵌入维度 $d$，通常选择 $d_k = d_v = d/h$，这样每个头的输出维度为 $d_v$，拼接后总维度为 $hd_v = d$，与输入维度一致。

- 不增加总参数量。
- 这种“降维投影 + 多头并行”的设计，强迫每个头必须在低维空间（64 维）里寻找特征。由于每个头的初始权重随机且独立训练，它们会自然演化出不同的关注重点（有的擅长局部纹理，有的擅长全局形状）。

## 工程实现中的参数化变体

上文使用的是最清晰、也是原始 Transformer 中最常见的写法：每个词嵌入向量 $\mathbf{x_i}\in\mathbb{R}^{d}$ 分别经过三套独立参数，得到 Query、Key 和 Value：

$$
\mathbf{q_i}=W_Q\mathbf{x_i},\qquad
\mathbf{k_i}=W_K\mathbf{x_i},\qquad
\mathbf{v_i}=W_V\mathbf{x_i}
$$

这里 $W_Q\in\mathbb{R}^{d_k\times d}$、$W_K\in\mathbb{R}^{d_k\times d}$、$W_V\in\mathbb{R}^{d_v\times d}$，三者互不共享参数。实际工程中，为了降低参数量、计算量或 KV Cache 的显存占用，常会改变 **QKV 的参数化方式**；但注意力的基本计算逻辑仍是“用 $Q$ 与 $K$ 计算权重，再用权重加权 $V$”。

### 每头 Value 的低秩分解与输出矩阵

在单头的直观理解中，可以把 Value 看成一个从嵌入空间映射回嵌入空间的完整线性变换。但在标准多头注意力中，每个头不会先产生 $d$ 维 Value 再加权求和，而是先投影到较小的 $d_v$ 维空间。对于第 $r$ 个头，记这个下投影为：

$$
W_{V\downarrow}^{(r)}\in\mathbb{R}^{d_v\times d},\qquad
V^{(r)}=W_{V\downarrow}^{(r)}X
$$

其注意力加权结果为：

$$
H^{(r)}=V^{(r)}(A^{(r)})^T
=W_{V\downarrow}^{(r)}X(A^{(r)})^T
\in\mathbb{R}^{d_v\times n}
$$

若从“每个头都提出一个 $d$ 维嵌入更新”的角度理解，还可以为该头引入一个上投影：

$$
W_{V\uparrow}^{(r)}\in\mathbb{R}^{d\times d_v},\qquad
\Delta X^{(r)}=W_{V\uparrow}^{(r)}H^{(r)}
$$

于是这个头概念上的完整 Value 映射是：

$$
W_{V,\mathrm{full}}^{(r)}=W_{V\uparrow}^{(r)}W_{V\downarrow}^{(r)}
\in\mathbb{R}^{d\times d}
$$

由于中间维度 $d_v$ 通常远小于 $d$，这个完整映射的秩最多为 $d_v$；这就是常说的“Value 的低秩分解”。它并不改变语义：$W_{V\downarrow}^{(r)}$ 负责从词嵌入中抽取该头需要传递的内容，$W_{V\uparrow}^{(r)}$ 负责把这份内容映射为对原始嵌入空间的更新。

实际实现不会为每个头分别执行上投影。先将所有头的低维输出在特征维度拼接：

$$
H_{\mathrm{concat}}=[H^{(1)};H^{(2)};\ldots;H^{(h)}]
\in\mathbb{R}^{hd_v\times n}
$$

再使用一个整个多头模块共享的输出矩阵：

$$
\Delta X=W_OH_{\mathrm{concat}},\qquad
W_O\in\mathbb{R}^{d\times hd_v}
$$

将 $W_O$ 按列分块，可把它理解为把各头的上投影“钉”在一起：

$$
W_O=[W_{V\uparrow}^{(1)}\;W_{V\uparrow}^{(2)}\;\ldots\;W_{V\uparrow}^{(h)}]
$$

因此，上式等价于 $\Delta X=\sum_{r=1}^{h}W_{V\uparrow}^{(r)}H^{(r)}$。论文和代码中，单个头的 $W_V^{(r)}$ 通常就是这里的 $W_{V\downarrow}^{(r)}$；所有“Value-up”合并后对应的是 $W_O$。这也解释了为什么前文的标准写法是先得到 $Z_{concat}$，再乘一次 $W_O$，而不是为每个头单独乘一个 $d\times d_v$ 矩阵。

### 共享 QKV 的低秩中间投影（可选变体）

一种可选的低秩参数化是先把词嵌入压缩到一个维度较小的中间表示：

$$
\mathbf{c_i}=B\mathbf{x_i},\qquad B\in\mathbb{R}^{r\times d},\qquad r\ll d
$$

再从这个共享表示分别生成三类向量：

$$
\mathbf{q_i}=A_Q\mathbf{c_i},\qquad
\mathbf{k_i}=A_K\mathbf{c_i},\qquad
\mathbf{v_i}=A_V\mathbf{c_i}
$$

其中 $A_Q\in\mathbb{R}^{d_k\times r}$、$A_K\in\mathbb{R}^{d_k\times r}$、$A_V\in\mathbb{R}^{d_v\times r}$。把两步合并后，有：

$$
W_Q=A_QB,\qquad W_K=A_KB,\qquad W_V=A_VB
$$

因此，$Q$、$K$、$V$ 共享的是右侧的低维基底 $B$，即它们都先从 $\mathbf{x_i}$ 中抽取同一个压缩特征 $\mathbf{c_i}$，再由不同的 $A_Q,A_K,A_V$ 赋予“查询 / 匹配 / 传递内容”三种语义。

$W_Q,W_K,W_V$ 共同采用了一个共享的低秩分解。这样能节省参数，但也会限制三种投影可独立表达的信息，因此是否采用取决于模型规模和效果需求。

### 共享 KV：MQA 与 GQA

另一个常见工程优化并不是低秩分解，而是减少多头注意力中 Key 和 Value 的副本数。设有 $h$ 个 Query 头：

$$
\mathbf{q_i}^{(r)}=W_Q^{(r)}\mathbf{x_i},\qquad r=1,\ldots,h
$$

- **MQA（Multi-Query Attention）**：所有 Query 头共用同一组 $K,V$，即 $\mathbf{k_i}=W_K\mathbf{x_i}$、$\mathbf{v_i}=W_V\mathbf{x_i}$。这样解码时只需缓存一份 K/V。
- **GQA（Grouped-Query Attention）**：将 $h$ 个 Query 头分成若干组；同一组共享一组 $K,V$。它在 MHA（每头独立 KV）与 MQA（全部头共享 KV）之间折中。

两者中，Query 仍然由自己的 $W_Q^{(r)}$ 产生；被共享的是 K/V。主要收益是降低自回归推理时的 KV Cache 显存和带宽开销。

### 潜变量 KV 压缩

还有一类做法会把每个词的 Key/Value 先压缩为潜变量，例如：

$$
\mathbf{c_i}^{KV}=W_{DKV}\mathbf{x_i},\qquad
\mathbf{k_i}=W_{UK}\mathbf{c_i}^{KV},\qquad
\mathbf{v_i}=W_{UV}\mathbf{c_i}^{KV}
$$

其中 $\mathbf{c_i}^{KV}\in\mathbb{R}^{r_{KV}}$ 是用于缓存的低维 KV 潜变量，$W_{DKV}$ 是下投影矩阵，$W_{UK}$ 与 $W_{UV}$ 分别恢复 Key 和 Value。这类设计的重点是缓存 $\mathbf{c_i}^{KV}$ 而非完整的 $\mathbf{k_i},\mathbf{v_i}$，从而降低 KV Cache。Query 可以保持独立投影，也可以使用另一套低秩分解。
