---
title: Trasformer-编码器的其他部分：位置编码
published: 2026-06-27
description: 'positional encoding位置编码、残差连接、层归一化、前馈神经网络'
image: ''
tags: []
category: '模式识别与机器学习'
order: 33
draft: false 
lang: ''
---

除注意力之外的其他几个组件。本文主要介绍位置编码

由于绝大多数深度学习论文、代码实现（PyTorch/TensorFlow）以及原始 Transformer 论文中的张量布局，默认都是“序列长度 $n$ × 嵌入维度 $d$”（行优先）。这里也遵循一下，不然不好和原文对上

## 位置编码（Positional Encoding）

:::tip
由于transformer并行处理所有词，本身并不像RNN那样天然理解顺序。为了让模型知道“猫追老鼠”和“老鼠追猫”的区别，必须显式地注入位置信息
:::

词嵌入矩阵 $X\in \mathbb{R}^{n \times d}$，生成的位置编码矩阵 $P\in \mathbb{R}^{n \times d}$，则位置编码后的输入为：

$$
X' = X + P
$$

- 嵌入向量中偶数索引的维度使用正弦函数，奇数索引的维度使用余弦函数。
- 加法而不是“拼接”，如果拼接，位置编码的维度会翻倍，导致后续计算复杂度增加。
- 加法相当于把“词义（Content）”和“位置（Position）”两个信号在同一个向量空间里叠加。后续的线性层 $W_Q$ 可以通过训练自动学习如何拆解它们——把一部分维度用于语义，另一部分用于位置。
- 实际上模型最终需要的是“相对位置”——知道词与词之间的距离和方向更重要。绝对位置只是一个中间手段。

后续生成的 $Q,K,V$ 其实都是基于 $X'$ 计算的。

### 设计位置编码的核心矛盾（为什么简单方案不行？）

我们需要构造一个 $P \in \mathbb{R}^{n \times d}$，让它满足以下**相互冲突**的要求：

| 要求               | 含义                                                             | 为什么重要                           |
| :----------------- | :--------------------------------------------------------------- | :----------------------------------- |
| **唯一性**         | 每个位置 $pos$ 的编码必须不同。                                  | 否则两个位置无法区分。               |
| **有界性**         | 每个数值不能太大（不能爆炸）。                                   | 否则加到词嵌入上会破坏训练稳定性。   |
| **泛化性**         | 能处理比训练时更长的序列。                                       | 测试时句子长度可能超过训练时。       |
| **相对位置可表示** | 位置 $pos+k$ 的编码能由 $pos$ 的编码通过一个简单的线性变换得到。 | 模型需要知道“距离 $k$”才有物理意义。 |

让我们看看**简单方案为什么都失败**：

- **方案一：直接用整数下标 $[0, 1, 2, \dots]$**
  - 违反“有界性”：位置1000的数值是1000，词嵌入通常只有几，加在一起语义被淹没。
  - 而且1和2的距离是1，1000和1001的距离也是1，但数值跨度天差地别，模型无法统一理解“距离”。

- **方案二：用 One-hot 编码（每个位置一个 $n$ 维独热向量）**
  - 维度 = 序列长度 $n$。如果序列长度是1000，位置编码就是1000维，远大于词嵌入维度（通常512或768），维度爆炸。
  - 而且无法泛化到更长的序列（训练时 $n=1000$，测试时遇到 $n=1200$ 就无码可用）。

- **方案三：用随机初始化的可学习向量**
  - 这其实在现代模型里常用（Learnable Positional Encoding），但有缺陷：它只能记住“绝对位置”，无法泛化到训练时未见的长度。而且它没有显式地诱导模型去捕捉“相对位置”。

### 正弦/余弦编码的设计出发点

正弦/余弦编码是原始Transformer提出的解决方案。它的核心思想是：

> **把位置编码看作一种“高频振荡信号”，不同维度具有不同的振荡频率，从而让模型可以从编码的数值变化中“读”出位置信息。**

公式（行优先，第 $pos$ 行、第 $2i$ 列和第 $2i+1$ 列）：
$$
\begin{aligned}
P_{pos, \ 2i} &= \sin\left( \frac{pos}{10000^{2i / d}} \right) \\
P_{pos, \ 2i+1} &= \cos\left( \frac{pos}{10000^{2i / d}} \right)
\end{aligned}
$$
其中：

- $pos$ 是位置下标（0, 1, 2, ..., n-1）。
- $i$ 是维度下标（0, 1, 2, ..., d/2 - 1）。
- $d$ 是词嵌入维度。

**关键变量**：分母 $10000^{2i / d}$。

- 当 $i = 0$ 时，分母 = $10000^{0} = 1$，频率最高（$\sin(pos)$），变化最剧烈。
- 当 $i = d/2 - 1$ 时，分母 = $10000^{(d-2)/d} \approx 10000$，频率最低（$\sin(pos/10000)$），变化极缓慢（周期 $2\pi \times 10000 \approx 62832$ 个位置）。

- 低位维度（小 $i$）：编码“局部位置”——相邻几个位置的编码值差异大，能精细区分近距离的词。
- 高位维度（大 $i$）：编码“全局位置”——远距离位置差异小，提供平滑的大尺度位置信号。

### 为什么选“正弦/余弦对”？（数学本质）

因为正弦/余弦函数族具有完美的“线性平移不变性”性质。

高中数学的和差化积公式：
$$
\begin{aligned}
\sin(pos + k) &= \sin(pos)\cos(k) + \cos(pos)\sin(k) \\
\cos(pos + k) &= \cos(pos)\cos(k) - \sin(pos)\sin(k)
\end{aligned}
$$

写成矩阵形式，对于任意固定的偏移 $k$，存在一个**与 $pos$ 无关**的 $2 \times 2$ 旋转矩阵 $\mathbf{R}_k$，使得：
$$
\begin{bmatrix}
\sin(pos + k) \\
\cos(pos + k)
\end{bmatrix}
=
\underbrace{
\begin{bmatrix}
\cos k & \sin k \\
-\sin k & \cos k
\end{bmatrix}
}_{\mathbf{R}_k}
\cdot
\begin{bmatrix}
\sin(pos) \\
\cos(pos)
\end{bmatrix}
$$

**扩展到多维**：对每一对 $(\sin(\omega_i pos), \cos(\omega_i pos))$ 都独立地应用这个旋转矩阵，就能得到：
$$
P_{pos+k} = \mathbf{R}_k \cdot P_{pos}
$$
其中 $\mathbf{R}_k$ 是一个对角块旋转矩阵（每个频率对应一个 $2 \times 2$ 块）。

位置 $pos$ 的编码 $P_{pos}$ 经过一个**与 $pos$ 无关、只与偏移 $k$ 有关的线性变换**，就能变成位置 $pos+k$ 的编码 $P_{pos+k}$。

这意味着：**自注意力机制中的线性层 $\mathbf{W}_Q$ 和 $\mathbf{W}_K$ 只需要学会这个固定的旋转矩阵族，就能计算出任意两个位置之间的相对距离 $k$**，而无需为每个绝对位置单独学习一套规则。

这就是为什么正弦/余弦编码能泛化到比训练时更长的序列——因为“旋转”的规律是普适的，不依赖于训练时见过的具体 $pos$ 范围。

### 行优先下的具体数值示例

取 $n = 3, d = 4$，即总共有三个词元，每个词嵌入只有4维，那么位置编码矩阵 $P$ 的每一行是：

- 位置 $pos= 0$：
  - $P_{0,0} = \sin(0/1) = 0$
  - $P_{0,1} = \cos(0/1) = 1$
  - $P_{0,2} = \sin(0/10000^{2/4}) = \sin(0/100) = 0$
  - $P_{0,3} = \cos(0/100) = 1$
  - 即 $[0, 1, 0, 1]$

- 位置 $pos= 1$：
  - $P_{1,0} = \sin(1) \approx 0.84$
  - $P_{1,1} = \cos(1) \approx 0.54$
  - $P_{1,2} = \sin(0.01) \approx 0.01$
  - $P_{1,3} = \cos(0.01) \approx 0.99995$
  - 即 $[0.84, 0.54, 0.01, 0.99995]$

- 位置 $pos= 2$：
  - $P_{2,0} = \sin(2) \approx 0.91$
  - $P_{2,1} = \cos(2) \approx -0.42$
  - $P_{2,2} = \sin(0.02) \approx 0.02$
  - $P_{2,3} = \cos(0.02) \approx 0.9998$
  - 即 $[0.91, -0.42, 0.02, 0.9998]$

$$
P=\begin{bmatrix}
0 & 1 & 0 & 1 \\
0.84 & 0.54 & 0.01 & 0.99995 \\
0.91 & -0.42 & 0.02 & 0.9998 \\
\vdots & \vdots & \vdots & \vdots
\end{bmatrix}
$$

观察：

- **第0列（$i=0$，频率最高）**：0 → 0.84 → 0.91，变化剧烈，相邻位置区别明显。
- **第2列（$i=1$，频率较低）**：0 → 0.01 → 0.02，变化平缓，远距离位置区别明显。

### 视觉Transformer（ViT）中的位置编码

在ViT中，输入是一串图像块（Patch），每个Patch经过线性投影变成一个行向量。这里的位置编码矩阵 $P$ 有两种常见选择：

- **固定正弦编码（原始ViT）**：直接把1D正弦编码照搬，但这样会忽略图像的2D结构（横纵坐标不等价）。
- **可学习位置编码（更常用）**：把 $P$ 定义为一个可训练的参数矩阵，让模型自己从数据中学。这相当于放弃了“泛化到更长序列”的能力，但换来了更强的数据集适配性（因为图像分辨率通常是固定的）。

此外，像Swin Transformer这类层次化模型，直接不用的位置编码，改用**相对位置偏置（Relative Position Bias）**——在注意力得分矩阵上直接加一个可学习的偏置项 $\mathbf{B}_{ij}$，表示第 $i$ 个Patch和第 $j$ 个Patch之间的空间偏移。

---

### 交互式可视化

拖动滑块改变 $pos$，观察各维度编码值的变化规律——低位维度（小 $i$）振荡快，高位维度（大 $i$）振荡慢。

<div class="pe-viz" style="margin:2rem 0">

<style>
  .pe-viz * { box-sizing:border-box; margin:0; padding:0; }
  .pe-viz .row { display:flex; gap:10px; margin-bottom:10px; }
  .pe-viz .card {
    background:#fff; border:1px solid #e0e0d8; border-radius:8px;
    padding:8px 12px; flex:1;
  }
  .pe-viz .card .lbl { font-size:11px; color:#888; margin-bottom:2px; }
  .pe-viz .card .val { font-size:18px; font-weight:500; }
  .pe-viz .card .mono { font-family:monospace; font-size:11px; color:#666; margin-top:2px; }
  .pe-viz .ctrl {
    display:flex; align-items:center; gap:10px;
    font-size:13px; color:#666; margin-bottom:8px;
  }
  .pe-viz .ctrl input[type=range] { flex:1; accent-color:#185fa5; }
  .pe-viz canvas { width:100%; border-radius:6px; display:block; background:#fff; border:1px solid #e0e0d8; }
  .pe-viz .legend {
    font-size:11px; color:#888; margin-top:6px; text-align:center;
  }
  .pe-viz .tag {
    display:inline-block; padding:1px 6px;
    border-radius:3px; font-size:11px; font-weight:500; margin:0 2px;
  }
  .pe-viz .ts { background:#e6f1fb; color:#185fa5; }
  .pe-viz .tc { background:#eaf3de; color:#3b6d11; }
  .dark .pe-viz .card { background:#252522; border-color:#3a3a36; }
  .dark .pe-viz .card .lbl,
  .dark .pe-viz .card .mono { color:#888; }
  .dark .pe-viz canvas { background:#252522; border-color:#3a3a36; }
  .dark .pe-viz .ts { background:#0c447c; color:#b5d4f4; }
  .dark .pe-viz .tc { background:#173404; color:#c0dd97; }
</style>

<div class="row">
  <div class="card">
    <div class="lbl">位置 pos</div>
    <div class="val" id="pe-pv">0</div>
  </div>
  <div class="card">
    <div class="lbl">d_model</div>
    <div class="val">512</div>
  </div>
  <div class="card">
    <div class="lbl">公式</div>
    <div class="mono">sin/cos(pos / 10000^(2i/d))</div>
  </div>
</div>

<div class="ctrl">
  <span>pos</span>
  <input type="range" min="0" max="49" value="0" id="pe-sl">
  <span id="pe-pl" style="min-width:20px;text-align:right">0</span>
</div>

<canvas id="pe-c"></canvas>

<div class="legend">
  <span class="tag ts">sin 偶数维</span>
  <span class="tag tc">cos 奇数维</span>
  &emsp;横轴 = 维度 i，纵轴 = 编码值
</div>

<script>
(function() {
  var canvas = document.getElementById('pe-c');
  if (canvas.dataset.peInit) return;
  canvas.dataset.peInit = '1';
  var dpr = window.devicePixelRatio || 1;

  function draw() {
    var pos = +document.getElementById('pe-sl').value;
    document.getElementById('pe-pl').textContent = pos;
    document.getElementById('pe-pv').textContent = pos;

    var pw = canvas.parentElement.getBoundingClientRect().width || 640;
    var ph = 160;
    canvas.width = pw * dpr;
    canvas.height = ph * dpr;
    canvas.style.width = pw + 'px';
    canvas.style.height = ph + 'px';

    var ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);

    var isDark = document.documentElement.classList.contains('dark');
    ctx.fillStyle = isDark ? '#252522' : '#ffffff';
    ctx.fillRect(0, 0, pw, ph);

    var pl = 32, pr = 8, pt = 14, pb = 20;
    var W = pw - pl - pr;
    var H = ph - pt - pb;
    var N = 60;

    ctx.lineWidth = 0.5;
    [-1, 0, 1].forEach(function(v) {
      var y = pt + H * (1 - (v + 1) / 2);
      ctx.strokeStyle = isDark ? 'rgba(255,255,255,0.07)' : 'rgba(0,0,0,0.07)';
      ctx.beginPath(); ctx.moveTo(pl, y); ctx.lineTo(pl + W, y); ctx.stroke();
      ctx.fillStyle = isDark ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,0,0.35)';
      ctx.font = '10px sans-serif'; ctx.textAlign = 'right';
      ctx.fillText(v, pl - 4, y + 3);
    });

    for (var i = 0; i < N; i++) {
      var x = pl + (i / (N - 1)) * W;
      var divisor = Math.pow(10000, 2 * Math.floor(i / 2) / 512);
      var val = i % 2 === 0 ? Math.sin(pos / divisor) : Math.cos(pos / divisor);
      var y = pt + H * (1 - (val + 1) / 2);
      ctx.fillStyle = i % 2 === 0
        ? 'rgba(24, 95, 165, 0.85)'
        : 'rgba(15, 110, 86, 0.85)';
      ctx.beginPath();
      ctx.arc(x, y, 2.8, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.fillStyle = isDark ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.3)';
    ctx.textAlign = 'center';
    ctx.font = '10px sans-serif';
    ctx.fillText('\u7EF4\u5EA6 i \u2192', pl + W / 2, ph - 3);
  }

  document.getElementById('pe-sl').addEventListener('input', draw);
  window.addEventListener('resize', draw);
  document.addEventListener('swup:contentReplaced', function() {
    window.setTimeout(draw, 50);
  });
  draw();
})();
</script>

</div>
