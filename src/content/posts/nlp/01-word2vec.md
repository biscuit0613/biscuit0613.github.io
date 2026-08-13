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

**词嵌入向量（Word Embedding）** 是将词语映射到低维稠密实数向量空间的一种表示方法，常见模型包括 Word2Vec、GloVe、FastText，以及现在主流的上下文相关嵌入（如 BERT、GPT 系列），后者同一个词在不同上下文中会得到不同的向量表示。

:::tip[符号约定]

| 符号                                                  | 含义                          | 示例                            |
| ----------------------------------------------------- | ----------------------------- | ------------------------------- |
| $\mathcal{V}$                                         | 词汇表                        | $\vert\mathcal{V}\vert = 10^4$  |
| $V$                                                   | 词汇表大小                    | $V = \vert\mathcal{V}\vert$     |
| $d$                                                   | 词嵌入向量维度                | $d = 300$（典型值）             |
| $w_t$                                                 | 位置 $t$ 处的中心词           | $w_t = \text{"apple"}$          |
| $w_{t+j}$                                             | 位置 $t+j$ 处的上下文词       | $w_{t-1} = \text{"eat"}$        |
| $m$                                                   | 上下文窗口大小                | $m = 2$（两侧各 2 个词）        |
| $\mathbf{v}_w \in \mathbb{R}^d$                       | 词 $w$ 作为中心词的嵌入向量   | 输入向量                        |
| $\mathbf{u}_w \in \mathbb{R}^d$                       | 词 $w$ 作为上下文词的嵌入向量 | 输出向量                        |
| $\mathbf{W}_{\text{in}} \in \mathbb{R}^{d \times V}$  | 输入嵌入矩阵                  | 每一列是一个词的 $\mathbf{v}_w$ |
| $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$ | 输出嵌入矩阵                  | 每一行是一个词的 $\mathbf{u}_w$ |

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

下面的**分布式表示**则像是给每个城市一组坐标（经纬度、人口、GDP、气候类型...），语义相近的城市自然在向量空间中靠得更近。

:::

### 1.2 分布式假设

word2vec 的核心思想来自 **分布式假设（Distributional Hypothesis）**：

> "You shall know a word by the company it keeps." — J.R. Firth, 1957

也就是一个词的语义可以由它周围的上下文词来刻画。

考虑以下句子：

> The **cat** sits on the **mat**.

在"cat"的上下文中，我们频繁看到"the"、"sits"、"mat"等词；而在"dog"的上下文中，我们也会频繁看到"the"、"sits"、"mat"、"barks"等词。因为"cat"和"dog"有大量相似的上下文，它们的词向量应当相似。

## 2. Skip-gram 模型

Skip-gram 的目标是：

**给定中心词 $w_t$，预测其上下文窗口内的词 $w_{t+j}$**（$j \in \{-m, \dots, -1, 1, \dots, m\}$）。

Skip-gram 需要训练的参数是两套词嵌入向量矩阵：

- 输入嵌入矩阵 $\mathbf{W}_{\text{in}} \in \mathbb{R}^{d \times V}$（每列是中心词向量 $\mathbf{v}_w$）
- 输出嵌入矩阵 $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$（每行是上下文词向量 $\mathbf{u}_w$）

每个词 $w$ 对应两个嵌入向量：作为中心词时的 $\mathbf{v}_w$ 和作为上下文词时的 $\mathbf{u}_w$。总参数量为 $2 \cdot V \cdot d$。实际使用中通常取 $\mathbf{W}_{\text{in}}$（或 $\frac{\mathbf{v}_w + \mathbf{u}_w}{2}$）作为最终词向量。

### 2.1 模型结构以及前向传播

Skip-gram 是一个极简的两层神经网络：

```
输入层 (one-hot) → 隐藏层 (d维) → 输出层 (V维 softmax)
```

对于隐藏层，设中心词 $w_t$ 的 one-hot 向量为 $\mathbf{x} \in \mathbb{R}^V$（只有 $w_t$ 对应位置为 $1$），则：

$$
\mathbf{h} = \mathbf{W}_{\text{in}}\mathbf{x} = \mathbf{v}_{w_t}
$$

因为 $\mathbf{x}$ 是 one-hot 的，隐藏层向量 $\mathbf{h}$ 本质上就是从 $\mathbf{W}_{\text{in}}$ 中"查表"取出词 $w_t$ 对应的列向量 $\mathbf{v}_{w_t}$。这是 **embedding lookup** 操作。

隐藏层 $\mathbf{h}$ 就是中心词的嵌入向量 $\mathbf{v}_{w_t}$，一个 $d$ 维的稠密向量，
和普通神经网络不同:

- 没有偏置项：$\mathbf{h} = \mathbf{W}_{\text{in}} \mathbf{x}$，无 $+b$
- 没有激活函数：不经过 tanh/ReLU 等非线性变换
- 没有多个隐藏层：就这一层 embedding lookup

它本质上就是一个线性投影：把 $V$ 维的 one-hot 稀疏向量，映射为 $d$ 维的稠密向量。整个模型的非线性只来自 **输出层** 的 softmax（或负采样中的 sigmoid）。

:::tip[embedding-lookup举例]

把矩阵展开来看就清楚了。假设 $V=4, d=3$，词汇表为 {apple, banana, cat, eat}。
$\mathbf{W}_{\text{in}} \in \mathbb{R}^{3 \times 4}$，每一列是一个词的中心词向量：
$$
\mathbf{W}_{\text{in}} =
\begin{bmatrix}
\uparrow & \uparrow & \uparrow & \uparrow \\
\mathbf{v}_{\text{apple}} & \mathbf{v}_{\text{banana}} & \mathbf{v}_{\text{cat}} & \mathbf{v}_{\text{eat}} \\
\downarrow & \downarrow & \downarrow & \downarrow
\end{bmatrix}
=
\begin{bmatrix}
0.2 & 0.5 & 0.1 & 0.8 \\
0.4 & 0.1 & 0.6 & 0.3 \\
0.9 & 0.7 & 0.2 & 0.5
\end{bmatrix}
$$
现在中心词是 cat，其 one-hot 向量为 $\mathbf{x} = [0, 0, 1, 0]^T$（4×1 列向量）。

$$
\mathbf{h} = \mathbf{W}_{\text{in}} \cdot \mathbf{x}
= \begin{bmatrix}
0.2 & 0.5 & \mathbf{0.1} & 0.8 \\
0.4 & 0.1 & \mathbf{0.6} & 0.3 \\
0.9 & 0.7 & \mathbf{0.2} & 0.5
\end{bmatrix}
\cdot
\begin{bmatrix} 0 \\ 0 \\ 1 \\ 0 \end{bmatrix}
= \begin{bmatrix}
\mathbf{0.1} \\
\mathbf{0.6} \\
\mathbf{0.2}
\end{bmatrix}
= \mathbf{v}_{\text{cat}}
$$

:::

对于输出层，每个上下文词 $w_o$ 的得分，就是用$\mathbf{u}_{w_o}$ (是词 $w_o$ 作为上下文词时的 $d$ 维向量，存放在 $\mathbf{W}_{\text{out}}$ 中) 与中心词向量 $\mathbf{v}_{w_t}$ 作 **内积** ：

$$
\text{score}(w_o \mid w_t) = \mathbf{u}_{w_o}^T \mathbf{v}_{w_t}\\
\mathbf{s}=\mathbf{W}_{\text{out}} \cdot \mathbf{h} = \mathbf{W}_{\text{out}} \cdot \mathbf{v}_{w_t}
$$

:::tip[输出举例]

$\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$，每一行是一个词的 $\mathbf{u}_w$。沿用 $V=4, d=3$ 的例子：
$$
\mathbf{W}_{\text{out}} =
\begin{bmatrix}
\leftarrow & \mathbf{u}_{\text{apple}}^T & \rightarrow \\
\leftarrow & \mathbf{u}_{\text{banana}}^T & \rightarrow \\
\leftarrow & \mathbf{u}_{\text{cat}}^T & \rightarrow \\
\leftarrow & \mathbf{u}_{\text{eat}}^T & \rightarrow
\end{bmatrix}
=
\begin{bmatrix}
0.3 & 0.1 & 0.7 \\
0.5 & 0.9 & 0.2 \\
0.4 & 0.6 & 0.1 \\
0.8 & 0.3 & 0.5
\end{bmatrix}
$$
输出层计算所有词的得分，就是矩阵乘：
$$
\mathbf{s} = \mathbf{W}_{\text{out}} \cdot \mathbf{h}
= \mathbf{W}_{\text{out}} \cdot \mathbf{v}_{w_t}
$$
对于 $w_t = \text{"cat"}$，$\mathbf{v}_{\text{cat}} = [0.1, 0.6, 0.2]^T$：
$$
\mathbf{s} =
\begin{bmatrix}
0.3 & 0.1 & 0.7 \\
0.5 & 0.9 & 0.2 \\
0.4 & 0.6 & 0.1 \\
0.8 & 0.3 & 0.5
\end{bmatrix}
\cdot
\begin{bmatrix} 0.1 \\ 0.6 \\ 0.2 \end{bmatrix}
=
\begin{bmatrix}
\text{score}(\text{apple} \mid \text{cat}) \\
\text{score}(\text{banana} \mid \text{cat}) \\
\text{score}(\text{cat} \mid \text{cat}) \\
\text{score}(\text{eat} \mid \text{cat})
\end{bmatrix}
$$
其中 $\text{score}(\text{apple} \mid \text{cat}) = 0.3 \cdot 0.1 + 0.1 \cdot 0.6 + 0.7 \cdot 0.2 = \mathbf{u}_{\text{apple}}^T \mathbf{v}_{\text{cat}}$。

:::

经过 softmax 归一化得到概率：

$$
P(w_o \mid w_t) = \frac{\exp(\mathbf{u}_{w_o}^T \mathbf{v}_{w_t})}{\sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})}
$$

<div class="sg-root">
<style>
.sg-root * { box-sizing: border-box; margin: 0; padding: 0; }
.sg-root { background: #0f1117; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; color: #e8edf5; padding: 1.5rem 1rem; display: flex; justify-content: center; border-radius: 18px; margin: 1.5rem 0 2.5rem; }
.sg-maxw { max-width: 1000px; width: 100%; }
.sg-header { text-align: center; margin-bottom: 1.2rem; }
.sg-header h1 { font-size: 1.5rem; font-weight: 600; letter-spacing: -0.5px; background: linear-gradient(135deg, #f0b3ff, #7dd3fc); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.sg-header p { color: #94a3b8; margin-top: 0.25rem; font-size: 0.9rem; }
.sg-main-grid { display: flex; flex-direction: column; gap: 1rem; }
.sg-canvas-wrap { background: #181c27; border-radius: 18px; padding: 0.8rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); overflow: hidden; }
#sgCanvas { width: 100%; height: auto; display: block; border-radius: 10px; background: #12161f; cursor: pointer; }
.sg-side { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.8rem; }
.sg-step-ctrl { background: #181c27; border-radius: 18px; padding: 1rem 1.2rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); }
.sg-step-ctrl .sg-step-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; margin-bottom: 0.2rem; }
.sg-step-ctrl .sg-step-title { font-size: 1.1rem; font-weight: 600; color: #f1f5f9; margin-bottom: 0.05rem; }
.sg-step-ctrl .sg-step-desc { font-size: 0.85rem; color: #94a3b8; line-height: 1.5; min-height: 2.8rem; }
.sg-step-btns { display: flex; gap: 0.5rem; margin-top: 0.6rem; flex-wrap: wrap; }
.sg-step-btns button { background: #252b3d; border: none; color: #cbd5e1; padding: 0.4rem 0.9rem; border-radius: 40px; font-size: 0.75rem; font-weight: 500; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; flex: 1 0 auto; }
.sg-step-btns button:hover:not(:disabled) { background: #323a52; color: #fff; border-color: #4a5578; }
.sg-step-btns button.active { background: #3b82f6; color: #fff; border-color: #3b82f6; }
.sg-step-btns button:disabled { opacity: 0.3; cursor: not-allowed; }
.sg-vocab { background: #181c27; border-radius: 18px; padding: 0.8rem 1.2rem 1rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); }
.sg-vocab .sg-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.6px; color: #64748b; margin-bottom: 0.5rem; }
.sg-vocab-tags { display: flex; flex-wrap: wrap; gap: 0.4rem; }
.sg-vocab-tag { background: #252b3d; padding: 0.3rem 0.8rem; border-radius: 40px; font-size: 0.8rem; font-weight: 500; color: #cbd5e1; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; }
.sg-vocab-tag:hover { background: #323a52; color: #fff; }
.sg-vocab-tag.active { background: #3b82f6; color: #fff; border-color: #3b82f6; box-shadow: 0 0 20px rgba(59,130,246,0.25); }
.sg-data { background: #181c27; border-radius: 18px; padding: 0.8rem 1.2rem 1rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); flex: 1; min-height: 120px; overflow-y: auto; }
.sg-data .sg-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.6px; color: #64748b; margin-bottom: 0.4rem; }
.sg-data .sg-data-content { font-family: 'JetBrains Mono', 'Fira Code', monospace; font-size: 0.75rem; color: #e2e8f0; line-height: 1.6; white-space: pre-wrap; word-break: break-all; }
.sg-data .sg-data-content .hl { color: #fbbf24; }
.sg-data .sg-data-content .dim { color: #64748b; }
.sg-status { margin-top: 0.6rem; display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem; color: #64748b; border-top: 1px solid #252b3d; padding-top: 0.5rem; }
.sg-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 6px; }
.sg-dot.idle { background: #64748b; }
.sg-dot.active { background: #3b82f6; box-shadow: 0 0 12px rgba(59,130,246,0.5); }
.sg-dot.done { background: #22c55e; box-shadow: 0 0 12px rgba(34,197,94,0.4); }
.sg-data::-webkit-scrollbar { width: 4px; }
.sg-data::-webkit-scrollbar-track { background: transparent; }
.sg-data::-webkit-scrollbar-thumb { background: #3b4a6b; border-radius: 8px; }
@media (max-width: 700px) { .sg-side { grid-template-columns: 1fr 1fr; } }
@media (max-width: 500px) { .sg-root { padding: 1rem 0.5rem; } .sg-header h1 { font-size: 1.2rem; } .sg-side { grid-template-columns: 1fr; } }
</style>

<div class="sg-maxw">

  <div class="sg-main-grid">
    <div class="sg-canvas-wrap">
      <canvas id="sgCanvas" width="900" height="600"></canvas>
      <div class="sg-status">
        <span><span class="sg-dot idle" id="sgDot"></span><span id="sgStatus">就绪 · 选择中心词开始</span></span>
        <span id="sgStepCounter" style="font-feature-settings:'tnum';">步骤 0 / 4</span>
      </div>
    </div>
    <div class="sg-side">
      <div class="sg-step-ctrl">
        <div class="sg-step-label">当前步骤</div>
        <div class="sg-step-title" id="sgStepTitle">选择中心词</div>
        <div class="sg-step-desc" id="sgStepDesc">点击下方词汇表中的词，将其设为 <strong>中心词 w<sub>t</sub></strong>。</div>
        <div class="sg-step-btns">
          <button id="sgBtn1" class="active" data-step="1">one‑hot</button>
          <button id="sgBtn2" data-step="2">嵌入查找</button>
          <button id="sgBtn3" data-step="3">输出得分</button>
          <button id="sgBtn4" data-step="4">Softmax</button>
          <button id="sgBtnReset" style="background:#1e2437;color:#94a3b8;flex:0.6;">重置</button>
        </div>
      </div>
      <div class="sg-vocab">
        <div class="sg-label">词汇表 · 点击选择中心词</div>
        <div class="sg-vocab-tags" id="sgVocabTags"></div>
      </div>
      <div class="sg-data">
        <div class="sg-label">当前数据</div>
        <div class="sg-data-content" id="sgDataContent">点击中心词后，这里将显示各步骤的数值。</div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var VOCAB = ['the', 'cat', 'sits', 'on', 'mat', 'dog', 'barks'];
  var V = VOCAB.length;
  var dim = 4;
  var W_in = [
    [0.12, -0.34, 0.56, -0.78, 0.91, -0.23, 0.45],
    [-0.67, 0.89, -0.12, 0.34, -0.56, 0.78, -0.91],
    [0.45, -0.23, 0.67, -0.89, 0.12, -0.34, 0.56],
    [-0.34, 0.56, -0.78, 0.91, -0.23, 0.45, -0.67]
  ];
  var W_out = [
    [0.23, -0.56, 0.78, -0.91],
    [-0.45, 0.67, -0.89, 0.12],
    [0.56, -0.78, 0.91, -0.23],
    [-0.67, 0.89, -0.12, 0.34],
    [0.78, -0.91, 0.23, -0.56],
    [-0.89, 0.12, -0.34, 0.67],
    [0.91, -0.23, 0.45, -0.78]
  ];
  function getWordVector(idx) { return W_in.map(function(row) { return row[idx]; }); }
  function forwardPass(centerIdx) {
    var oneHot = new Array(V).fill(0); oneHot[centerIdx] = 1;
    var h = getWordVector(centerIdx);
    var scores = W_out.map(function(u_w) {
      var sum = 0;
      for (var j = 0; j < dim; j++) sum += u_w[j] * h[j];
      return sum;
    });
    var maxScore = Math.max.apply(null, scores);
    var expScores = scores.map(function(s) { return Math.exp(s - maxScore); });
    var sumExp = expScores.reduce(function(a, b) { return a + b; }, 0);
    var probs = expScores.map(function(e) { return e / sumExp; });
    return { oneHot: oneHot, h: h, scores: scores, probs: probs };
  }

  var currentCenter = 1;
  var currentStep = 1;
  var cachedResult = null;
  function getResult() {
    if (!cachedResult || cachedResult.centerIdx !== currentCenter) {
      cachedResult = { centerIdx: currentCenter };
      var r = forwardPass(currentCenter);
      cachedResult.oneHot = r.oneHot; cachedResult.h = r.h; cachedResult.scores = r.scores; cachedResult.probs = r.probs;
    }
    return cachedResult;
  }

  var canvas = document.getElementById('sgCanvas');
  var ctx = canvas.getContext('2d');
  var cw = 900, ch = 600;
  canvas.width = cw; canvas.height = ch;
  var LX = { input: 120, hidden: 370, output: 650 };
  var R = 24, SP = 64;

  function getNodeY(layer, index, total) {
    return (ch - (total - 1) * SP) / 2 + index * SP;
  }
  var CE = { default: 'rgba(60,80,120,0.12)', active: 'rgba(59,130,246,0.35)', hl: 'rgba(251,191,36,0.45)' };

  function drawNetwork(step, centerIdx, result) {
    ctx.clearRect(0, 0, cw, ch);
    var grad = ctx.createRadialGradient(450, 300, 100, 450, 300, 540);
    grad.addColorStop(0, '#1a1f2e'); grad.addColorStop(1, '#0d1018');
    ctx.fillStyle = grad; ctx.fillRect(0, 0, cw, ch);

    for (var i = 0; i < V; i++) {
      var x1 = LX.input + R, y1 = getNodeY('input', i, V);
      for (var j = 0; j < dim; j++) {
        var x2 = LX.hidden - R, y2 = getNodeY('hidden', j, dim);
        var alpha = 0.06, color = CE.default;
        if (step >= 2 && i === centerIdx) { alpha = 0.4; color = CE.active; }
        ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
        ctx.strokeStyle = color; ctx.globalAlpha = alpha; ctx.lineWidth = 1.2; ctx.stroke(); ctx.globalAlpha = 1;
      }
    }
    for (var j = 0; j < dim; j++) {
      var x1 = LX.hidden + R, y1 = getNodeY('hidden', j, dim);
      for (var k = 0; k < V; k++) {
        var x2 = LX.output - R, y2 = getNodeY('output', k, V);
        var alpha = 0.06, color = CE.default;
        if (step >= 3) {
          var n = Math.max(0, Math.min(1, (result.scores[k] + 2) / 4));
          alpha = 0.06 + 0.35 * n; color = 'rgba(251,191,36,' + alpha + ')';
        }
        ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
        ctx.strokeStyle = color; ctx.globalAlpha = alpha; ctx.lineWidth = 1.2; ctx.stroke(); ctx.globalAlpha = 1;
      }
    }

    function drawLabel(x, y, text, color) {
      ctx.fillStyle = color || '#64748b'; ctx.font = '600 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom'; ctx.fillText(text, x, y - 10);
    }
    drawLabel(LX.input, 26, '输入层 (one‑hot)', '#60a5fa');
    drawLabel(LX.hidden, 26, '隐藏层 h = v_{w_t}', '#a78bfa');
    drawLabel(LX.output, 26, '输出层 (softmax)', '#4ade80');

    for (var i = 0; i < V; i++) {
      var x = LX.input, y = getNodeY('input', i, V);
      var isC = (i === centerIdx), active = (step >= 1 && isC);
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      ctx.fillStyle = active ? '#3b82f6' : '#2a3a5a'; ctx.fill();
      ctx.strokeStyle = active ? '#60a5fa' : '#3a4a6a'; ctx.lineWidth = active ? 3 : 1.5; ctx.stroke();
      ctx.fillStyle = active ? '#fff' : '#94a3b8'; ctx.font = '500 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(VOCAB[i], x, y);
      if (step >= 1) {
        ctx.fillStyle = isC ? '#fbbf24' : '#4a5a7a'; ctx.font = '10px monospace'; ctx.textBaseline = 'top';
        ctx.fillText(isC ? '1' : '0', x, y + R + 5);
      }
    }
    for (var j = 0; j < dim; j++) {
      var x = LX.hidden, y = getNodeY('hidden', j, dim);
      var active = (step >= 2);
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      ctx.fillStyle = active ? '#8b5cf6' : '#2a3a5a'; ctx.fill();
      ctx.strokeStyle = active ? '#a78bfa' : '#3a4a6a'; ctx.lineWidth = active ? 3 : 1.5; ctx.stroke();
      ctx.fillStyle = active ? '#fff' : '#94a3b8'; ctx.font = '500 12px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText('h' + (j + 1), x, y);
      if (step >= 2) {
        var val = result.h[j];
        ctx.fillStyle = '#fbbf24'; ctx.font = '10px monospace'; ctx.textBaseline = 'top';
        ctx.fillText((val >= 0 ? ' ' : '') + val.toFixed(2), x, y + R + 5);
      }
    }
    for (var k = 0; k < V; k++) {
      var x = LX.output, y = getNodeY('output', k, V);
      var pred = (step >= 4 && k === result.probs.indexOf(Math.max.apply(null, result.probs)));
      var color = '#2a3a5a', border = '#3a4a6a', tc = '#94a3b8';
      if (step >= 3) {
        var prob = result.probs[k], inten = Math.max(0.2, Math.min(0.95, prob * 3));
        color = 'rgba(34,197,94,' + (inten * 0.7) + ')';
        border = 'rgba(74,222,128,' + (inten * 0.5) + ')';
        tc = inten > 0.5 ? '#fff' : '#94a3b8';
        if (pred) { color = '#22c55e'; border = '#fbbf24'; tc = '#fff'; }
      }
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      ctx.fillStyle = color; ctx.fill();
      ctx.strokeStyle = pred ? '#fbbf24' : border; ctx.lineWidth = pred ? 4 : 1.5; ctx.stroke();
      ctx.fillStyle = tc; ctx.font = '500 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(VOCAB[k], x, y);
      if (step >= 3) {
        var val = (step === 4) ? result.probs[k] : result.scores[k];
        var label = (step === 4) ? (val * 100).toFixed(0) + '%' : val.toFixed(2);
        ctx.fillStyle = (step === 4 && pred) ? '#fbbf24' : '#94a3b8'; ctx.font = '9px monospace';
        ctx.textBaseline = 'top'; ctx.fillText(label, x, y + R + 5);
      }
    }
    if (step >= 2) {
      ctx.fillStyle = '#8b5cf6'; ctx.font = '500 11px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('← embedding lookup: v_{' + VOCAB[centerIdx] + '}', LX.hidden, 510);
    }
    if (step >= 3) {
      ctx.fillStyle = '#fbbf24'; ctx.font = '500 11px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('← score = u_w^T · v_{w_t}', LX.output, 510);
    }
    if (step === 4) {
      var predIdx = result.probs.indexOf(Math.max.apply(null, result.probs));
      ctx.fillStyle = '#fbbf24'; ctx.font = '600 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('pred: "' + VOCAB[predIdx] + '" (' + (result.probs[predIdx] * 100).toFixed(1) + '%)', LX.output, 540);
    }
    var legend = ['中心词: "' + VOCAB[centerIdx] + '"', 'd = ' + dim, 'V = ' + V];
    var lx = 16, ly = ch - 12;
    legend.forEach(function(t) {
      ctx.fillStyle = '#4a5a7a'; ctx.fillText('▸', lx, ly);
      ctx.fillStyle = '#94a3b8'; ctx.fillText(t, lx + 12, ly);
      lx += ctx.measureText('▸ ' + t).width + 8;
    });
  }

  function updateUI() {
    var result = getResult(), step = currentStep, centerIdx = currentCenter;
    drawNetwork(step, centerIdx, result);
    var info = {
      1: { title: '① one‑hot 编码', desc: '中心词 "' + VOCAB[centerIdx] + '" 被编码为 one‑hot 向量 x：第 ' + (centerIdx + 1) + ' 位为 1，其余为 0。' },
      2: { title: '② 嵌入查找', desc: '从 W<sub>in</sub> 中取出 "' + VOCAB[centerIdx] + '" 对应的列，得到隐藏层向量 h = v<sub>' + VOCAB[centerIdx] + '</sub> ∈ ℝ<sup>' + dim + '</sup>。' },
      3: { title: '③ 输出得分', desc: '计算每个词的 u<sub>w</sub> 与 v<sub>' + VOCAB[centerIdx] + '</sub> 的内积，得到得分向量 s = W<sub>out</sub> · h ∈ ℝ<sup>' + V + '</sup>。' },
      4: { title: '④ Softmax 归一化', desc: '对得分应用 softmax，得到概率分布 P(w<sub>o</sub> | w<sub>t</sub>)。概率最高的词即为模型预测的上下文词。' }
    };
    document.getElementById('sgStepTitle').textContent = info[step].title;
    document.getElementById('sgStepDesc').innerHTML = info[step].desc;
    document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
      var s = parseInt(btn.dataset.step);
      btn.classList.toggle('active', s === step);
      btn.disabled = (s > step && s !== 1);
    });
    var dot = document.getElementById('sgDot'), st = document.getElementById('sgStatus'), ct = document.getElementById('sgStepCounter');
    dot.className = 'sg-dot ' + (step === 4 ? 'done' : 'active');
    st.textContent = step === 1 ? 'one‑hot · 中心词 "' + VOCAB[centerIdx] + '"' : step === 2 ? '嵌入查找 · v_{' + VOCAB[centerIdx] + '}' : step === 3 ? '输出得分 · 计算内积' : 'Softmax · 预测完成';
    ct.textContent = '步骤 ' + step + ' / 4';
    updateDataPanel(step, result, centerIdx);
    document.querySelectorAll('.sg-vocab-tag').forEach(function(el, idx) { el.classList.toggle('active', idx === centerIdx); });
  }

  function updateDataPanel(step, result, centerIdx) {
    var el = document.getElementById('sgDataContent'), html = '';
    var oneHotStr = result.oneHot.map(function(v, i) { return v === 1 ? '[' + i + '] <span class="hl">1</span>' : '[' + i + '] 0'; }).join('  ');
    var vecStr = result.h.map(function(v, i) { return 'h' + (i + 1) + ' = <span class="hl">' + v.toFixed(3) + '</span>'; }).join('  ');
    var scoreStr = result.scores.map(function(v, i) { return VOCAB[i] + ': <span class="hl">' + v.toFixed(3) + '</span>'; }).join('  ');
    var probStr = result.probs.map(function(v, i) {
      var pct = (v * 100).toFixed(1), bar = '█'.repeat(Math.round(v * 20));
      var isMax = v === Math.max.apply(null, result.probs);
      return VOCAB[i] + ': <span class="' + (isMax ? 'hl' : '') + '">' + pct + '% ' + bar + '</span>';
    }).join('  ');
    switch (step) {
      case 1: html = '<span class="dim">┃ one‑hot 向量 x ∈ ℝ^' + V + '</span>\n' + oneHotStr; break;
      case 2: html = '<span class="dim">┃ 隐藏层 h = v_{' + VOCAB[centerIdx] + '} ∈ ℝ^' + dim + '</span>\n' + vecStr; break;
      case 3: html = '<span class="dim">┃ 得分 s = W<sub>out</sub> · h ∈ ℝ^' + V + '</span>\n' + scoreStr; break;
      case 4: html = '<span class="dim">┃ Softmax 概率分布</span>\n' + probStr; break;
      default: html = '选择中心词开始。';
    }
    el.innerHTML = html;
  }

  var vocabContainer = document.getElementById('sgVocabTags');
  VOCAB.forEach(function(word, idx) {
    var tag = document.createElement('span');
    tag.className = 'sg-vocab-tag' + (idx === currentCenter ? ' active' : '');
    tag.textContent = word;
    tag.dataset.idx = idx;
    tag.addEventListener('click', function() {
      currentCenter = idx; cachedResult = null; currentStep = 1;
      document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
        var s = parseInt(btn.dataset.step); btn.disabled = (s > 1); btn.classList.toggle('active', s === 1);
      });
      updateUI();
    });
    vocabContainer.appendChild(tag);
  });
  document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var step = parseInt(btn.dataset.step);
      if (step > currentStep + 1 && step !== 1) return;
      currentStep = step; updateUI();
    });
  });
  document.getElementById('sgBtnReset').addEventListener('click', function() {
    currentStep = 1; cachedResult = null;
    document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
      var s = parseInt(btn.dataset.step); btn.disabled = (s > 1); btn.classList.toggle('active', s === 1);
    });
    updateUI();
  });

  function resizeCanvas() {
    var wrapper = canvas.parentElement, ww = wrapper.clientWidth - 24;
    var aspect = cw / ch, dw = ww;
    canvas.style.width = dw + 'px'; canvas.style.height = (dw / aspect) + 'px';
  }
  window.addEventListener('resize', resizeCanvas);
  canvas.addEventListener('click', function() {
    if (currentStep < 4) { currentStep++; updateUI(); } else { currentStep = 1; updateUI(); }
  });
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); if (currentStep < 4) { currentStep++; updateUI(); } }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); if (currentStep > 1) { currentStep--; updateUI(); } }
    else if (e.key === 'r') { document.getElementById('sgBtnReset').click(); }
  });
  resizeCanvas();
  updateUI();
})();
</script>
</div>

### 2.2 损失函数与参数更新

Skip-gram 的训练目标很朴素：**让模型看到中心词 $w_t$ 时，预测出真实上下文词 $w_o$ 的概率尽可能大**。

#### 极大似然估计+对数变换

给定一个语料库 $\mathcal{D}$，包含所有 (中心词, 上下文词) 对，我们希望最大化所有观测数据的联合概率，用 **极大似然估计（Maximum Likelihood Estimation, MLE）**

$$
\max \prod_{(w_t, w_o) \in \mathcal{D}} P(w_o \mid w_t)
$$

取对数后，连乘变成连加，单调性不变：

$$
\max \sum_{(w_t, w_o) \in \mathcal{D}} \log P(w_o \mid w_t)
$$

梯度下降默认做**最小化**，所以加个负号，把最大化问题转化为最小化问题：

$$
\min \sum_{(w_t, w_o) \in \mathcal{D}} -\log P(w_o \mid w_t)
$$

对于单对 $(w_t, w_o)$，损失函数为：

$$
J = -\log P(w_o \mid w_t) = -\mathbf{u}_{w_o}^T \mathbf{v}_{w_t} + \log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})
$$

#### 与交叉熵的等价性

负对数似然本质上就是**交叉熵损失**。真实分布 $y$ 是关于 $w_o$ 的 one-hot 向量（$y_{w_o}=1$，其余为 0），模型预测分布 $\hat{y} = P(\cdot \mid w_t)$。交叉熵 $H(y, \hat{y}) = -\sum_w y_w \log \hat{y}_w$ 展开后只有 $w_o$ 那一项非零，恰好等于 $-\log P(w_o \mid w_t)$：

$$
H(y, \hat{y}) = -\sum_{w \in \mathcal{V}} y_w \log P(w \mid w_t) = -\log P(w_o \mid w_t)
$$

所以最小化负对数似然，等价于最小化真实分布与预测分布之间的交叉熵。

:::tip[内积作为相似度]

$\mathbf{u}_{w_o}^T \mathbf{v}_{w_t}$ 是两个向量的内积。如果中心词向量 $\mathbf{v}_{\text{cat}}$ 和上下文词向量 $\mathbf{u}_{\text{sits}}$ 的内积很大，说明模型认为"cat"和"sits"经常共现，softmax 会给 $P(\text{"sits"} \mid \text{"cat"})$ 分配较高的概率。

训练的目标是：让真实共现的词对 $(\mathbf{v}_{w_t}, \mathbf{u}_{w_o})$ 内积变大，让随机词对的内积变小。
:::

#### 梯度推导

对 $\mathbf{v}_{w_t}$（中心词向量）求梯度。损失函数由两项组成：

$$
J = \underbrace{-\mathbf{u}_{w_o}^T \mathbf{v}_{w_t}}_{\text{第一项}} + \underbrace{\log \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})}_{\text{第二项}}
$$

**第一项**直接求导：$\frac{\partial}{\partial \mathbf{v}_{w_t}} (-\mathbf{u}_{w_o}^T \mathbf{v}_{w_t}) = -\mathbf{u}_{w_o}$。

**第二项**需要链式法则。设 $S = \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})$，则第二项为 $\log S$：

$$
\frac{\partial}{\partial \mathbf{v}_{w_t}} \log S = \frac{1}{S} \cdot \frac{\partial S}{\partial \mathbf{v}_{w_t}}
$$

对 $S$ 求导，$\exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})$ 的导数是 $\exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t}) \cdot \mathbf{u}_{w}$：

$$
\frac{\partial S}{\partial \mathbf{v}_{w_t}} = \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t}) \cdot \mathbf{u}_{w}
$$

代回：

$$
\frac{\partial}{\partial \mathbf{v}_{w_t}} \log S = \frac{1}{\sum_{w' \in \mathcal{V}} \exp(\mathbf{u}_{w'}^T \mathbf{v}_{w_t})} \cdot \sum_{w \in \mathcal{V}} \exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t}) \cdot \mathbf{u}_{w}
$$

$$
= \sum_{w \in \mathcal{V}} \frac{\exp(\mathbf{u}_{w}^T \mathbf{v}_{w_t})}{\sum_{w' \in \mathcal{V}} \exp(\mathbf{u}_{w'}^T \mathbf{v}_{w_t})} \cdot \mathbf{u}_{w}
= \sum_{w \in \mathcal{V}} P(w \mid w_t) \cdot \mathbf{u}_{w}
$$

两项合并，得到最终梯度：

$$
\frac{\partial J}{\partial \mathbf{v}_{w_t}} = -\mathbf{u}_{w_o} + \sum_{w \in \mathcal{V}} P(w \mid w_t) \cdot \mathbf{u}_w
$$

第二项是所有输出向量 $\mathbf{u}_w$ 的**加权平均**，权重恰好是模型当前预测的概率分布 $P(w \mid w_t)$。换句话说，它是模型对输出向量的**期望** $\mathbb{E}_{w \sim P(\cdot \mid w_t)}[\mathbf{u}_w]$。第一项 $-\mathbf{u}_{w_o}$ 将中心词向量 $\mathbf{v}_{w_t}$ 「拉向」真实上下文词的向量 $\mathbf{u}_{w_o}$；第二项则将 $\mathbf{v}_{w_t}$ 「推开」所有词（按模型当前置信度加权），防止模型把所有词都预测成高频词。当二者平衡时，梯度为零，模型收敛。

这就是 softmax 的瓶颈所在：**每次更新都需要对全体词汇表 $V$ 求和**，当 $V = 10^5$ 时计算量不可接受。

对输出向量 $\mathbf{u}_w$ 的梯度同样重要，推导过程类似：

$$
\frac{\partial J}{\partial \mathbf{u}_{w}} = \big(P(w \mid w_t) - \delta_{w, w_o}\big) \cdot \mathbf{v}_{w_t}
$$

其中 $\delta_{w, w_o} = 1$ 当 $w = w_o$（真实上下文词），否则为 $0$。

- **对于真实上下文词 $w_o$**：$P(w_o \mid w_t) - 1 < 0$，梯度为负，$\mathbf{u}_{w_o}$ 向 $\mathbf{v}_{w_t}$ 靠拢。
- **对于其他词 $w \neq w_o$**：$P(w \mid w_t) > 0$，梯度为正，$\mathbf{u}_w$ 远离 $\mathbf{v}_{w_t}$。

#### 参数更新

反向传播需要前向传播的中间结果。具体来说：

| 前向输出                                                | 反向传播中的用途                                                                                         |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| $P(w \mid w_t)$（所有词的 softmax 概率）                | 计算 $\frac{\partial J}{\partial \mathbf{v}_{w_t}}$ 和 $\frac{\partial J}{\partial \mathbf{u}_w}$ 都需要 |
| $\mathbf{v}_{w_t}$（中心词向量，即隐藏层 $\mathbf{h}$） | 所有 $\frac{\partial J}{\partial \mathbf{u}_w}$ 的梯度中共用                                             |
| $\mathbf{u}_{w_o}$（真实上下文词的输出向量）            | $\frac{\partial J}{\partial \mathbf{v}_{w_t}}$ 的第一项直接用到                                          |

训练时，对每个 (中心词, 上下文词) 对，用梯度下降同时更新两个矩阵：

$$
\mathbf{v}_{w_t} \leftarrow \mathbf{v}_{w_t} - \eta \cdot \frac{\partial J}{\partial \mathbf{v}_{w_t}}, \qquad
\mathbf{u}_{w} \leftarrow \mathbf{u}_{w} - \eta \cdot \frac{\partial J}{\partial \mathbf{u}_{w}} \quad (\forall w \in \mathcal{V})
$$

注意 $\mathbf{W}_{\text{out}}$ 中的**每一行** $\mathbf{u}_w$ 都会被更新——因为每个词都参与了 softmax 分母的计算。这也是 softmax 计算量大的根源。

<div class="sg-root">
<style>
.sg-root * { box-sizing: border-box; margin: 0; padding: 0; }
.sg-root { background: #0f1117; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; color: #e8edf5; padding: 1.5rem 1rem; display: flex; justify-content: center; border-radius: 18px; margin: 1.5rem 0 2.5rem; }
.sg-maxw { max-width: 1000px; width: 100%; }
.sg-header { text-align: center; margin-bottom: 1rem; }
.sg-header h1 { font-size: 1.4rem; font-weight: 600; letter-spacing: -0.5px; background: linear-gradient(135deg, #f0b3ff, #7dd3fc); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.sg-header p { color: #94a3b8; margin-top: 0.25rem; font-size: 0.9rem; }
.sg-main-grid { display: flex; flex-direction: column; gap: 1rem; }
.sg-canvas-wrap { background: #181c27; border-radius: 18px; padding: 0.8rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); overflow: hidden; }
#bpCanvas { width: 100%; height: auto; display: block; border-radius: 10px; background: #12161f; cursor: pointer; }
.sg-side { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.8rem; }
.sg-step-ctrl { background: #181c27; border-radius: 18px; padding: 1rem 1.2rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); }
.sg-step-ctrl .sg-step-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; margin-bottom: 0.2rem; }
.sg-step-ctrl .sg-step-title { font-size: 1.1rem; font-weight: 600; color: #f1f5f9; margin-bottom: 0.05rem; }
.sg-step-ctrl .sg-step-desc { font-size: 0.85rem; color: #94a3b8; line-height: 1.5; min-height: 2.8rem; }
.sg-step-btns { display: flex; gap: 0.5rem; margin-top: 0.6rem; flex-wrap: wrap; }
.sg-step-btns button { background: #252b3d; border: none; color: #cbd5e1; padding: 0.4rem 0.9rem; border-radius: 40px; font-size: 0.75rem; font-weight: 500; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; flex: 1 0 auto; }
.sg-step-btns button:hover:not(:disabled) { background: #323a52; color: #fff; border-color: #4a5578; }
.sg-step-btns button.active { background: #3b82f6; color: #fff; border-color: #3b82f6; }
.sg-step-btns button:disabled { opacity: 0.3; cursor: not-allowed; }
.sg-data { background: #181c27; border-radius: 18px; padding: 0.8rem 1.2rem 1rem; border: 1px solid #2a2f3f; box-shadow: 0 8px 32px rgba(0,0,0,0.5); flex: 1; min-height: 120px; overflow-y: auto; }
.sg-data .sg-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.6px; color: #64748b; margin-bottom: 0.4rem; }
.sg-data .sg-data-content { font-family: 'JetBrains Mono', 'Fira Code', monospace; font-size: 0.75rem; color: #e2e8f0; line-height: 1.6; white-space: pre-wrap; word-break: break-all; }
.sg-data .sg-data-content .hl { color: #fbbf24; }
.sg-data .sg-data-content .gr { color: #22c55e; }
.sg-data .sg-data-content .rd { color: #ef4444; }
.sg-data .sg-data-content .dim { color: #64748b; }
.sg-status { margin-top: 0.6rem; display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem; color: #64748b; border-top: 1px solid #252b3d; padding-top: 0.5rem; }
.sg-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 6px; }
.sg-dot.idle { background: #64748b; }
.sg-dot.active { background: #3b82f6; box-shadow: 0 0 12px rgba(59,130,246,0.5); }
.sg-dot.done { background: #22c55e; box-shadow: 0 0 12px rgba(34,197,94,0.4); }
.sg-data::-webkit-scrollbar { width: 4px; }
.sg-data::-webkit-scrollbar-track { background: transparent; }
.sg-data::-webkit-scrollbar-thumb { background: #3b4a6b; border-radius: 8px; }
@media (max-width: 700px) { .sg-side { grid-template-columns: 1fr 1fr; } }
@media (max-width: 500px) { .sg-root { padding: 1rem 0.5rem; } .sg-header h1 { font-size: 1.2rem; } .sg-side { grid-template-columns: 1fr; } }
</style>

<div class="sg-maxw">
  <div class="sg-header">
    <h1>Skip-gram 反向传播</h1>
    <p>中心词 "cat" → 目标上下文词 "sits" · 观察前向输出如何驱动梯度计算</p>
  </div>
  <div class="sg-main-grid">
    <div class="sg-canvas-wrap">
      <canvas id="bpCanvas" width="900" height="590"></canvas>
      <div class="sg-status">
        <span><span class="sg-dot idle" id="bpDot"></span><span id="bpStatus">就绪</span></span>
        <span id="bpStepCounter" style="font-feature-settings:'tnum';">步骤 0 / 5</span>
      </div>
    </div>
    <div class="sg-side">
      <div class="sg-step-ctrl">
        <div class="sg-step-label">当前步骤</div>
        <div class="sg-step-title" id="bpStepTitle">前向传播 · softmax 输出</div>
        <div class="sg-step-desc" id="bpStepDesc">模型预测 P(w<sub>o</sub> | "cat")，其中 "sits" 仅得 3.0%，损失 J = 3.50</div>
        <div class="sg-step-btns">
          <button id="bpBtn1" class="active" data-step="1">前向结果</button>
          <button id="bpBtn2" data-step="2">∂J/∂u<sub>w</sub></button>
          <button id="bpBtn3" data-step="3">∂J/∂v<sub>cat</sub></button>
          <button id="bpBtn4" data-step="4">更新 u<sub>w</sub></button>
          <button id="bpBtn5" data-step="5">更新 v<sub>cat</sub></button>
          <button id="bpBtnReset" style="background:#1e2437;color:#94a3b8;flex:0.5;">重置</button>
        </div>
      </div>
      <div class="sg-data" style="grid-column: span 2;">
        <div class="sg-label">当前数据</div>
        <div class="sg-data-content" id="bpDataContent">点击步骤按钮开始。</div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var VOCAB = ['the', 'cat', 'sits', 'on', 'mat', 'dog', 'barks'];
  var V = VOCAB.length, dim = 4;
  var centerIdx = 1, targetIdx = 2;
  var W_in = [
    [0.12, -0.34, 0.56, -0.78, 0.91, -0.23, 0.45],
    [-0.67, 0.89, -0.12, 0.34, -0.56, 0.78, -0.91],
    [0.45, -0.23, 0.67, -0.89, 0.12, -0.34, 0.56],
    [-0.34, 0.56, -0.78, 0.91, -0.23, 0.45, -0.67]
  ];
  var W_out = [
    [0.23, -0.56, 0.78, -0.91],
    [-0.45, 0.67, -0.89, 0.12],
    [0.56, -0.78, 0.91, -0.23],
    [-0.67, 0.89, -0.12, 0.34],
    [0.78, -0.91, 0.23, -0.56],
    [-0.89, 0.12, -0.34, 0.67],
    [0.91, -0.23, 0.45, -0.78]
  ];
  var eta = 0.1;

  function getV(idx) { return W_in.map(function(r) { return r[idx]; }); }
  function getU(idx) { return W_out[idx]; }
  function dot(a, b) { var s = 0; for (var i = 0; i < a.length; i++) s += a[i] * b[i]; return s; }
  function scale(v, k) { return v.map(function(x) { return x * k; }); }
  function add(a, b) { return a.map(function(x, i) { return x + b[i]; }); }
  function sub(a, b) { return a.map(function(x, i) { return x - b[i]; }); }

  function forward() {
    var vc = getV(centerIdx);
    var scores = W_out.map(function(u) { return dot(u, vc); });
    var maxS = Math.max.apply(null, scores);
    var exps = scores.map(function(s) { return Math.exp(s - maxS); });
    var sumExp = exps.reduce(function(a, b) { return a + b; }, 0);
    var probs = exps.map(function(e) { return e / sumExp; });
    var loss = -Math.log(probs[targetIdx]);
    return { vc: vc, scores: scores, probs: probs, loss: loss };
  }

  function backward(fwd) {
    var vc = fwd.vc, probs = fwd.probs;
    var du = [];
    for (var i = 0; i < V; i++) {
      var delta = (i === targetIdx) ? 1 : 0;
      du.push(scale(vc, probs[i] - delta));
    }
    var ut = getU(targetIdx);
    var weighted = new Array(dim).fill(0);
    for (var w = 0; w < V; w++) {
      var u = getU(w);
      for (var d = 0; d < dim; d++) weighted[d] += probs[w] * u[d];
    }
    var dv = sub(weighted, ut);
    var vc_new = sub(vc, scale(dv, eta));
    var u_new = [];
    for (var i = 0; i < V; i++) {
      u_new.push(sub(getU(i), scale(du[i], eta)));
    }
    return { du: du, dv: dv, vc_new: vc_new, u_new: u_new };
  }

  var fwd = forward();
  var bwd = backward(fwd);
  var currentStep = 1;

  var canvas = document.getElementById('bpCanvas');
  var ctx = canvas.getContext('2d');
  var cw = 900, ch = 590;
  canvas.width = cw; canvas.height = ch;
  var LX = { input: 110, hidden: 360, output: 650 };
  var R = 24, SP = 64;

  function getNodeY(layer, index, total) {
    return (ch - (total - 1) * SP) / 2 + index * SP;
  }

  function drawNetwork(step) {
    ctx.clearRect(0, 0, cw, ch);
    var grad = ctx.createRadialGradient(450, 295, 100, 450, 295, 530);
    grad.addColorStop(0, '#1a1f2e'); grad.addColorStop(1, '#0d1018');
    ctx.fillStyle = grad; ctx.fillRect(0, 0, cw, ch);

    function dl(x, y, t, c) {
      ctx.fillStyle = c || '#64748b'; ctx.font = '600 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom'; ctx.fillText(t, x, y - 10);
    }
    dl(LX.input, 26, '输入层 (one‑hot)', '#60a5fa');
    dl(LX.hidden, 26, '隐藏层 h = v_{w_t}', '#a78bfa');
    dl(LX.output, 26, '输出层 (softmax)', '#4ade80');

    for (var i = 0; i < V; i++) {
      for (var j = 0; j < dim; j++) {
        var x1 = LX.input + R, y1 = getNodeY('input', i, V);
        var x2 = LX.hidden - R, y2 = getNodeY('hidden', j, dim);
        var alpha = (i === centerIdx) ? 0.3 : 0.05;
        ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
        ctx.strokeStyle = 'rgba(59,130,246,' + alpha + ')'; ctx.lineWidth = 1; ctx.stroke();
      }
    }
    for (var j = 0; j < dim; j++) {
      for (var k = 0; k < V; k++) {
        var x1 = LX.hidden + R, y1 = getNodeY('hidden', j, dim);
        var x2 = LX.output - R, y2 = getNodeY('output', k, V);
        var alpha = 0.05;
        if (step >= 1) {
          var n = Math.max(0.1, Math.min(0.7, fwd.probs[k] * 2));
          alpha = n;
        }
        ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
        ctx.strokeStyle = 'rgba(251,191,36,' + alpha + ')'; ctx.lineWidth = 1; ctx.stroke();
      }
    }

    if (step >= 2) {
      for (var j = 0; j < dim; j++) {
        for (var k = 0; k < V; k++) {
          var x1 = LX.hidden + R, y1 = getNodeY('hidden', j, dim);
          var x2 = LX.output - R, y2 = getNodeY('output', k, V);
          var duk = bwd.du[k][j];
          var abs = Math.abs(duk);
          var alpha = Math.min(1, abs * 3);
          var isNeg = k === targetIdx;
          ctx.beginPath(); ctx.moveTo(x2, y2); ctx.lineTo(x1, y1);
          ctx.strokeStyle = isNeg ? 'rgba(34,197,94,' + alpha + ')' : 'rgba(239,68,68,' + alpha + ')';
          ctx.lineWidth = 1.5; ctx.setLineDash([4, 4]); ctx.stroke(); ctx.setLineDash([]);
        }
      }
    }

    for (var i = 0; i < V; i++) {
      var x = LX.input, y = getNodeY('input', i, V);
      var isC = (i === centerIdx);
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      ctx.fillStyle = isC ? '#3b82f6' : '#2a3a5a'; ctx.fill();
      ctx.strokeStyle = isC ? '#60a5fa' : '#3a4a6a'; ctx.lineWidth = isC ? 3 : 1.5; ctx.stroke();
      ctx.fillStyle = isC ? '#fff' : '#94a3b8'; ctx.font = '500 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(VOCAB[i], x, y);
      ctx.fillStyle = isC ? '#fbbf24' : '#4a5a7a'; ctx.font = '10px monospace'; ctx.textBaseline = 'top';
      ctx.fillText(isC ? '1' : '0', x, y + R + 5);
    }
    for (var j = 0; j < dim; j++) {
      var x = LX.hidden, y = getNodeY('hidden', j, dim);
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      ctx.fillStyle = '#8b5cf6'; ctx.fill();
      ctx.strokeStyle = '#a78bfa'; ctx.lineWidth = 3; ctx.stroke();
      ctx.fillStyle = '#fff'; ctx.font = '500 12px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText('h' + (j + 1), x, y);
      var val = fwd.vc[j];
      ctx.fillStyle = '#fbbf24'; ctx.font = '10px monospace'; ctx.textBaseline = 'top';
      ctx.fillText((val >= 0 ? ' ' : '') + val.toFixed(2), x, y + R + 5);
      if (step >= 3) {
        ctx.fillStyle = '#ef4444'; ctx.font = 'bold 10px monospace'; ctx.textBaseline = 'bottom';
        ctx.fillText((bwd.dv[j] >= 0 ? '+' : '') + bwd.dv[j].toFixed(2), x, y - R - 5);
      }
      if (step >= 5) {
        ctx.fillStyle = '#22c55e'; ctx.font = 'bold 10px monospace'; ctx.textBaseline = 'bottom';
        ctx.fillText('→' + bwd.vc_new[j].toFixed(2), x + 50, y - R - 5);
      }
    }
    for (var k = 0; k < V; k++) {
      var x = LX.output, y = getNodeY('output', k, V);
      var isTarget = (k === targetIdx);
      ctx.beginPath(); ctx.arc(x, y, R, 0, Math.PI * 2);
      var color = '#2a3a5a', border = '#3a4a6a', tc = '#94a3b8';
      if (step >= 1) {
        var prob = fwd.probs[k], inten = Math.max(0.15, Math.min(0.9, prob * 3));
        color = 'rgba(34,197,94,' + (inten * 0.7) + ')';
        border = 'rgba(74,222,128,' + (inten * 0.5) + ')';
        tc = inten > 0.5 ? '#fff' : '#94a3b8';
        if (isTarget) { border = '#fbbf24'; tc = '#fff'; }
      }
      ctx.fillStyle = color; ctx.fill();
      ctx.strokeStyle = isTarget ? '#fbbf24' : border; ctx.lineWidth = isTarget ? 4 : 1.5; ctx.stroke();
      ctx.fillStyle = tc; ctx.font = '500 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(VOCAB[k], x, y);
      if (step >= 1) {
        ctx.fillStyle = isTarget ? '#fbbf24' : '#94a3b8'; ctx.font = '9px monospace'; ctx.textBaseline = 'top';
        ctx.fillText((fwd.probs[k] * 100).toFixed(0) + '%', x, y + R + 5);
      }
      if (step >= 2) {
        var duNorm = 0;
        for (var d = 0; d < dim; d++) duNorm += bwd.du[k][d] * bwd.du[k][d];
        duNorm = Math.sqrt(duNorm);
        var isNeg = (k === targetIdx);
        ctx.fillStyle = isNeg ? '#22c55e' : '#ef4444'; ctx.font = 'bold 9px monospace';
        ctx.textBaseline = 'bottom';
        ctx.fillText((isNeg ? '▼' : '▲') + duNorm.toFixed(2), x, y - R - 5);
      }
      if (step >= 4) {
        var uo = getU(k), un = bwd.u_new[k];
        var diff = 0;
        for (var d = 0; d < dim; d++) diff += (un[d] - uo[d]) * (un[d] - uo[d]);
        diff = Math.sqrt(diff);
        ctx.fillStyle = '#22c55e'; ctx.font = '9px monospace'; ctx.textBaseline = 'bottom';
        ctx.fillText('Δ=' + diff.toFixed(2), x + 50, y - R - 5);
      }
    }

    if (step >= 1) {
      ctx.fillStyle = '#fbbf24'; ctx.font = '600 13px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('J = -log P("sits"|"cat") = ' + fwd.loss.toFixed(2), LX.output, 530);
    }
    if (step === 2) {
      ctx.fillStyle = '#22c55e'; ctx.font = '500 11px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('← 绿色虚线: 梯度为负 (拉近)  |  红色虚线: 梯度为正 (推开)', LX.hidden, 545);
    }
    if (step >= 3) {
      ctx.fillStyle = '#ef4444'; ctx.font = '500 11px "Segoe UI", system-ui, sans-serif';
      ctx.textAlign = 'center'; ctx.textBaseline = 'bottom';
      ctx.fillText('∂J/∂v_{cat} = -u_{sits} + Σ P(w)·u_w  (红色数值显示在隐藏层节点上方)', LX.hidden, 545);
    }

    var legend = ['w_t = "cat"', 'w_o = "sits"', 'η = ' + eta];
    var lx = 16, ly = ch - 12;
    legend.forEach(function(t) {
      ctx.fillStyle = '#4a5a7a'; ctx.fillText('▸', lx, ly);
      ctx.fillStyle = '#94a3b8'; ctx.fillText(t, lx + 12, ly);
      lx += ctx.measureText('▸ ' + t).width + 8;
    });
  }

  function updateUI() {
    var step = currentStep;
    drawNetwork(step);

    var info = {
      1: { title: '前向传播 · softmax 输出', desc: '模型对 "cat" 预测各上下文词的概率。真实目标 "sits" 仅得 <b style="color:#fbbf24">3.0%</b>，损失 J = <b style="color:#fbbf24">' + fwd.loss.toFixed(2) + '</b>。<br>前向结果留下来：P(w|cat)、v<sub>cat</sub>、u<sub>sits</sub>。' },
      2: { title: '∂J/∂u<sub>w</sub> · 输出向量梯度', desc: 'dJ/du<sub>w</sub> = (P(w|cat) - δ<sub>w,sits</sub>) · v<sub>cat</sub><br><b style="color:#22c55e">▼ 绿色</b>: "sits" 梯度为负 → 拉近<br><b style="color:#ef4444">▲ 红色</b>: 其他词梯度为正 → 推开' },
      3: { title: '∂J/∂v<sub>cat</sub> · 中心词梯度', desc: 'dJ/dv<sub>cat</sub> = -u<sub>sits</sub> + Σ P(w) · u<sub>w</sub><br>第一项拉向 u<sub>sits</sub>，第二项推开所有词（加权平均）。<br>红色数值显示在隐藏层节点上方。' },
      4: { title: '更新 u<sub>w</sub> · 输出矩阵', desc: 'u<sub>w</sub> ← u<sub>w</sub> - η · ∂J/∂u<sub>w</sub><br>"sits" 的 u 向量向 v<sub>cat</sub> 靠拢，其他词远离。<br>每个输出节点上方显示位移量 Δ。' },
      5: { title: '更新 v<sub>cat</sub> · 输入矩阵', desc: 'v<sub>cat</sub> ← v<sub>cat</sub> - η · ∂J/∂v<sub>cat</sub><br>隐藏层节点上方显示更新后的新值（绿色）。' }
    };
    document.getElementById('bpStepTitle').textContent = info[step].title;
    document.getElementById('bpStepDesc').innerHTML = info[step].desc;
    document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
      var s = parseInt(btn.dataset.step);
      btn.classList.toggle('active', s === step);
      btn.disabled = (s > step && s !== 1);
    });
    var dot = document.getElementById('bpDot'), st = document.getElementById('bpStatus'), ct = document.getElementById('bpStepCounter');
    dot.className = 'sg-dot ' + (step === 5 ? 'done' : 'active');
    st.textContent = ['', '前向 · softmax 完成', '梯度 · ∂J/∂u_w', '梯度 · ∂J/∂v_cat', '更新 · u_w', '更新 · v_cat 完成'][step];
    ct.textContent = '步骤 ' + step + ' / 5';

    var el = document.getElementById('bpDataContent'), html = '';
    switch (step) {
      case 1:
        html = '<span class="dim">┃ Softmax 概率分布 P(w | "cat")</span>\n';
        fwd.probs.forEach(function(p, i) {
          var bar = '█'.repeat(Math.round(p * 20));
          html += VOCAB[i] + ': <span class="' + (i === targetIdx ? 'hl' : '') + '">' + (p * 100).toFixed(1) + '% ' + bar + '</span>\n';
        });
        html += '<span class="dim">┃ 损失 J = -log P("sits"|"cat") = ' + fwd.loss.toFixed(4) + '</span>';
        break;
      case 2:
        html = '<span class="dim">┃ ∂J/∂u_w = (P - δ) · v_cat</span>\n';
        for (var i = 0; i < V; i++) {
          var duk = bwd.du[i], norm = Math.sqrt(duk.reduce(function(a, b) { return a + b * b; }, 0));
          var cls = i === targetIdx ? 'gr' : 'rd';
          html += '<span class="' + cls + '">' + VOCAB[i] + ':</span> ||∂J/∂u|| = ' + norm.toFixed(3) + '\n';
        }
        break;
      case 3:
        html = '<span class="dim">┃ ∂J/∂v_cat = -u_sits + Σ P(w)·u_w</span>\n';
        html += 'v_cat = [' + fwd.vc.map(function(x) { return x.toFixed(2); }).join(', ') + ']\n';
        html += '<span class="rd">∂J/∂v_cat = [' + bwd.dv.map(function(x) { return x.toFixed(3); }).join(', ') + ']</span>\n';
        html += '<span class="dim">||∂J/∂v_cat|| = ' + Math.sqrt(bwd.dv.reduce(function(a, b) { return a + b * b; }, 0)).toFixed(3) + '</span>';
        break;
      case 4:
        html = '<span class="dim">┃ u_sits 更新 (η = ' + eta + ')</span>\n';
        html += '更新前: [' + getU(targetIdx).map(function(x) { return x.toFixed(2); }).join(', ') + ']\n';
        html += '<span class="gr">更新后: [' + bwd.u_new[targetIdx].map(function(x) { return x.toFixed(2); }).join(', ') + ']</span>\n';
        html += '<span class="dim">┃ 所有 u_w 位移量 ||Δ||</span>\n';
        for (var i = 0; i < V; i++) {
          var diff = 0;
          for (var d = 0; d < dim; d++) diff += (bwd.u_new[i][d] - getU[i](d)) * (bwd.u_new[i][d] - getU[i](d));
          html += VOCAB[i] + ': ' + Math.sqrt(diff).toFixed(3) + '\n';
        }
        break;
      case 5:
        html = '<span class="dim">┃ v_cat 更新 (η = ' + eta + ')</span>\n';
        html += '更新前: [' + fwd.vc.map(function(x) { return x.toFixed(2); }).join(', ') + ']\n';
        html += '<span class="gr">更新后: [' + bwd.vc_new.map(function(x) { return x.toFixed(2); }).join(', ') + ']</span>\n';
        html += '<span class="dim">┃ 一次迭代完成。重复此过程遍历所有 (w_t, w_o) 对直到收敛。</span>';
        break;
    }
    el.innerHTML = html;
  }

  document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var step = parseInt(btn.dataset.step);
      if (step > currentStep + 1 && step !== 1) return;
      currentStep = step; updateUI();
    });
  });
  document.getElementById('bpBtnReset').addEventListener('click', function() {
    currentStep = 1;
    document.querySelectorAll('.sg-step-btns button[data-step]').forEach(function(btn) {
      var s = parseInt(btn.dataset.step); btn.disabled = (s > 1); btn.classList.toggle('active', s === 1);
    });
    updateUI();
  });
  canvas.addEventListener('click', function() {
    if (currentStep < 5) { currentStep++; updateUI(); } else { currentStep = 1; updateUI(); }
  });
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); if (currentStep < 5) { currentStep++; updateUI(); } }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); if (currentStep > 1) { currentStep--; updateUI(); } }
    else if (e.key === 'r') { document.getElementById('bpBtnReset').click(); }
  });

  function resizeCanvas() {
    var wrapper = canvas.parentElement, ww = wrapper.clientWidth - 24;
    var aspect = cw / ch, dw = ww;
    canvas.style.width = dw + 'px'; canvas.style.height = (dw / aspect) + 'px';
  }
  window.addEventListener('resize', resizeCanvas);
  resizeCanvas();
  updateUI();
})();
</script>
</div>

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

| 模型      | 输入            | 输出            | 适合             | 训练速度 |
| --------- | --------------- | --------------- | ---------------- | :------: |
| Skip-gram | 1 个中心词      | $2m$ 个上下文词 | 稀有词、小数据集 |    慢    |
| CBOW      | $2m$ 个上下文词 | 1 个中心词      | 高频词、大数据集 |    快    |

CBOW 的参数结构与 Skip-gram **完全相同**——仍然需要训练两套词向量：

- $\mathbf{W}_{\text{in}} \in \mathbb{R}^{d \times V}$：**输入嵌入矩阵**，每列是词 $w$ 作为上下文词时的向量 $\mathbf{v}_w$
- $\mathbf{W}_{\text{out}} \in \mathbb{R}^{V \times d}$：**输出嵌入矩阵**，每行是词 $w$ 作为中心词时的向量 $\mathbf{u}_w$

总参数量同样是 $2 \cdot V \cdot d$。

但**更新的对象不同**。一次 CBOW 训练中：

- 对 $\mathbf{W}_{\text{in}}$：更新**上下文窗口内所有 $2m$ 个词**的 $\mathbf{v}_w$（Skip-gram 一次只更新 1 个中心词）
- 对 $\mathbf{W}_{\text{out}}$：只需要更新**中心词 $w_t$** 对应的 $\mathbf{u}_{w_t}$（Skip-gram 需要更新所有 $V$ 个词）

因为 CBOW 的输出端只需要对 1 个词求梯度，而 Skip-gram 需要对 $2m$ 个词分别求梯度并累加，所以 CBOW 训练更快。但代价是 CBOW 对每个上下文词只更新了一次（平均后梯度被稀释），对稀有词的学习不如 Skip-gram 充分。这也解释了为什么 Skip-gram 对稀有词更友好——每个稀有词作为中心词时都会被单独训练。

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

| 方面       | word2vec                         | 现代 LLM (Transformer)                       |
| ---------- | -------------------------------- | -------------------------------------------- |
| 词表示     | **静态**：每个词只有一个固定向量 | **上下文相关**：同一个词在不同句子中向量不同 |
| 多义词处理 | 无法区分"bank"（银行/河岸）      | 根据上下文自动消歧                           |
| 上下文范围 | 固定窗口 $m$                     | 自注意力机制，理论上无限长                   |
| 训练目标   | 预测邻居词                       | 预测下一个 token（语言模型）                 |

具体来说，word2vec 训练出的词向量是**静态的**：无论"bank"出现在"river bank"还是"central bank"中，它都使用同一个向量。而 Transformer 的 self-attention 机制会为每个词生成**上下文相关的表示**——这正是我们已经在 [Transformer 编码器核心：self-attention](/posts/transformer/trasformer-attetion/) 中详细讨论过的。

然而，word2vec 的核心思想——**用低维稠密向量表示词，通过共现信息学习语义**——仍然是所有现代词嵌入方法（包括 BERT、GPT 的 embedding 层）的基础。在下一节中，我们将看到 GloVe 如何改进 word2vec 的统计信息利用，以及 BPE 子词嵌入如何解决 OOV 问题。

## 参考文献

- Mikolov, T., et al. (2013). Efficient Estimation of Word Representations in Vector Space. *arXiv:1301.3781*.
- Mikolov, T., et al. (2013). Distributed Representations of Words and Phrases and their Compositionality. *NIPS 2013*.
- Goldberg, Y., & Levy, O. (2014). word2vec Explained: Deriving Mikolov et al.'s Negative-Sampling Word-Embedding Method. *arXiv:1402.3722*.
