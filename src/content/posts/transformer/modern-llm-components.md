---
title: '现代 LLM 组件：RoPE、RMSNorm、SwiGLU、GQA 与 KV Cache'
published: 2026-07-19
description: '从公式、张量形状与计算代价出发，解释现代 Decoder-only LLM 中 RoPE、RMSNorm、SwiGLU、GQA 和 KV Cache 的作用及协作方式'
image: ''
tags: [Transformer, LLM, Pre-training]
category: '05-注意力与Transformer'
order: 38
draft: true
lang: ''
---

:::tip[本文定位]

上一篇 [Decoder-only Transformer](/posts/transformer/decoder-only-transformer/) 建立了语言模型的通用骨架：

~~~text
Token Embedding
→ Decoder Block × L
→ Final Norm
→ LM Head
→ Vocabulary Logits
~~~

本文进一步解释现代 LLM 如何改造骨架内部的组件。RMSNorm 稳定子层输入，RoPE 向 Attention 注入位置信息，SwiGLU 改造 FFN，GQA 减少 K/V 头，KV Cache 则复用生成过程中的历史 K/V。

这些组件并不改变 Next-Token Prediction 的训练目标，而是改变模型表达位置、变换特征以及使用计算资源的方式。

:::

## 1. 现代 Decoder Block 的组件演进

原始 Transformer 已经具备 Self-Attention、位置编码、LayerNorm、FFN 和残差连接。现代 Decoder-only LLM 保留总体数据流，但经常替换内部实现：

| 原始或通用组件       | 现代常见实现 | 主要目的                 |
| -------------------- | ------------ | ------------------------ |
| LayerNorm            | RMSNorm      | 简化归一化，稳定子层输入 |
| 正弦绝对位置编码     | RoPE         | 在 Q/K 中表达相对位移    |
| ReLU/GELU FFN        | SwiGLU       | 使用门控调节特征通过量   |
| Multi-Head Attention | GQA / MQA    | 减少 K/V 参数和缓存      |
| 每步重算历史 K/V     | KV Cache     | 复用历史结果，加速生成   |

这些变化分布在同一个 Block 的不同位置：


<figure id="modern-decoder-block-components" class="mlc-visual" aria-labelledby="mlc-visual-caption">
<style>
  .mlc-visual {
    --mlc-paper: oklch(98% 0.014 92);
    --mlc-ink: oklch(34% 0.025 255);
    --mlc-muted: oklch(55% 0.025 255);
    --mlc-line: oklch(42% 0.025 255);
    --mlc-green: oklch(69% 0.17 130);
    --mlc-green-soft: oklch(95% 0.09 126);
    --mlc-blue-soft: oklch(93% 0.05 238);
    --mlc-peach-soft: oklch(95% 0.055 70);
    --mlc-pink: oklch(73% 0.18 344);
    --mlc-pink-soft: oklch(94% 0.07 344);
    --mlc-violet: oklch(63% 0.13 304);
    margin: 1.8rem 0 2rem;
  }
  .mlc-visual * {
    box-sizing: border-box;
  }
  .mlc-visual__viewport {
    overflow-x: auto;
    padding: 0.25rem 0.15rem 0.8rem;
    scrollbar-width: thin;
  }
  .mlc-visual__canvas {
    width: 100%;
    min-width: 680px;
    max-width: 780px;
    margin: 0 auto;
    padding: 22px 28px 26px;
    color: var(--mlc-ink);
    background:
      linear-gradient(oklch(100% 0 0 / 0.58), oklch(100% 0 0 / 0.58)),
      var(--mlc-paper);
    border: 1px solid oklch(76% 0.06 140);
    border-radius: 26px;
    box-shadow: 0 16px 42px oklch(35% 0.03 140 / 0.08);
    font-family: inherit;
  }
  .mlc-visual__header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 18px;
    margin-bottom: 18px;
    padding: 0 4px 12px;
    border-bottom: 1px solid oklch(82% 0.035 140);
  }
  .mlc-visual__eyebrow {
    color: oklch(52% 0.1 142);
    font-size: 12px;
    font-weight: 750;
    letter-spacing: 0.14em;
  }
  .mlc-visual__header strong {
    color: var(--mlc-ink);
    font-size: 19px;
    letter-spacing: 0.01em;
  }
  .mlc-visual__stage {
    position: relative;
    width: min(100%, 620px);
    margin: 0 auto;
    padding-left: 68px;
  }
  .mlc-visual__stage + .mlc-visual__stage {
    margin-top: 8px;
  }
  .mlc-visual__stage--ffn .mlc-visual__skip {
    bottom: 88px;
  }
  .mlc-visual__skip {
    position: absolute;
    top: 20px;
    bottom: 18px;
    left: 12px;
    width: 44px;
    border-top: 2px dashed var(--mlc-line);
    border-bottom: 2px dashed var(--mlc-line);
    border-left: 2px dashed var(--mlc-line);
    border-radius: 14px 0 0 14px;
    opacity: 0.78;
  }
  .mlc-visual__skip::after {
    content: "";
    position: absolute;
    right: -3px;
    bottom: -5px;
    width: 0;
    height: 0;
    border-top: 5px solid transparent;
    border-bottom: 5px solid transparent;
    border-left: 8px solid var(--mlc-line);
  }
  .mlc-visual__skip-label {
    position: absolute;
    top: 50%;
    left: -4px;
    padding: 3px 5px;
    color: var(--mlc-muted);
    background: var(--mlc-paper);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    transform: translate(-50%, -50%) rotate(-90deg);
  }
  .mlc-visual__state {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 11px;
    min-height: 38px;
  }
  .mlc-visual__state-name {
    color: oklch(57% 0.16 132);
    font-size: 15px;
    font-weight: 750;
    white-space: nowrap;
  }
  .mlc-visual__vector {
    display: grid;
    grid-template-columns: repeat(6, 18px);
    overflow: hidden;
    border: 1px solid oklch(55% 0.06 145);
  }
  .mlc-visual__vector i {
    width: 18px;
    height: 18px;
    background: oklch(84% 0.13 132);
    border-right: 1px solid oklch(55% 0.06 145);
  }
  .mlc-visual__vector i:nth-child(2n) {
    background: oklch(90% 0.11 126);
  }
  .mlc-visual__vector i:last-child {
    border-right: 0;
  }
  .mlc-visual__arrow {
    position: relative;
    width: 2px;
    height: 23px;
    margin: 3px auto;
    background: var(--mlc-line);
  }
  .mlc-visual__arrow::after {
    content: "";
    position: absolute;
    bottom: -1px;
    left: 50%;
    border-top: 7px solid var(--mlc-line);
    border-right: 5px solid transparent;
    border-left: 5px solid transparent;
    transform: translateX(-50%);
  }
  .mlc-visual__module {
    padding: 15px 18px;
    border: 2px solid var(--mlc-line);
    border-radius: 20px;
    background: var(--mlc-blue-soft);
    text-align: center;
  }
  .mlc-visual__module-title {
    display: block;
    margin-bottom: 11px;
    font-size: 16px;
    font-weight: 760;
  }
  .mlc-visual__norm {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 150px;
    padding: 7px 18px;
    border: 2px solid var(--mlc-green);
    border-radius: 999px;
    background: var(--mlc-green-soft);
    font-size: 14px;
    font-weight: 750;
  }
  .mlc-visual__micro-arrow {
    margin: 3px 0;
    color: var(--mlc-muted);
    font-size: 18px;
    line-height: 1;
  }
  .mlc-visual__qkv {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
    max-width: 330px;
    margin: 0 auto;
  }
  .mlc-visual__qkv span {
    padding: 6px 8px;
    border: 1px solid oklch(63% 0.08 340);
    background: var(--mlc-pink-soft);
    font-size: 12px;
    font-weight: 750;
  }
  .mlc-visual__attention-detail {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 126px;
    align-items: stretch;
    gap: 10px;
    margin-top: 8px;
  }
  .mlc-visual__attention-main {
    display: grid;
    grid-template-columns: 1fr 1.2fr;
    align-items: center;
    gap: 8px;
  }
  .mlc-visual__rope,
  .mlc-visual__gqa,
  .mlc-visual__cache {
    display: flex;
    min-height: 58px;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 8px;
    border-radius: 12px;
    font-size: 13px;
    font-weight: 760;
  }
  .mlc-visual__rope {
    border: 1px solid oklch(63% 0.11 342);
    background: var(--mlc-pink-soft);
  }
  .mlc-visual__gqa {
    border: 1px solid oklch(60% 0.07 60);
    background: var(--mlc-peach-soft);
  }
  .mlc-visual__cache {
    position: relative;
    border: 1px dashed var(--mlc-violet);
    background: oklch(94% 0.04 304);
    color: oklch(47% 0.11 304);
  }
  .mlc-visual__cache::before {
    content: "⇄";
    position: absolute;
    top: 50%;
    left: -15px;
    color: var(--mlc-violet);
    font-size: 17px;
    transform: translate(-50%, -50%);
  }
  .mlc-visual small {
    display: block;
    margin-top: 2px;
    color: var(--mlc-muted);
    font-size: 10px;
    font-weight: 650;
    line-height: 1.25;
  }
  .mlc-visual__add {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    min-height: 42px;
    border: 2px solid var(--mlc-green);
    border-radius: 999px;
    background: var(--mlc-green-soft);
    font-size: 14px;
    font-weight: 760;
  }
  .mlc-visual__plus {
    display: inline-grid;
    width: 23px;
    height: 23px;
    place-items: center;
    border: 2px solid currentColor;
    border-radius: 50%;
    font-size: 16px;
    line-height: 1;
  }
  .mlc-visual__ffn-path {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    align-items: center;
    gap: 8px;
    margin-top: 10px;
  }
  .mlc-visual__ffn-path span:not(.mlc-visual__times) {
    padding: 7px 8px;
    border: 1px solid oklch(62% 0.08 235);
    border-radius: 8px;
    background: oklch(96% 0.035 235);
    font-size: 12px;
    font-weight: 700;
  }
  .mlc-visual__times {
    display: grid;
    width: 25px;
    height: 25px;
    place-items: center;
    border-radius: 50%;
    background: var(--mlc-pink);
    color: white;
    font-weight: 800;
  }
  .mlc-visual__legend {
    display: flex;
    flex-wrap: wrap;
    gap: 8px 16px;
    margin-top: 18px;
    padding: 12px 4px 0;
    border-top: 1px solid oklch(82% 0.035 140);
    color: var(--mlc-muted);
    font-size: 11px;
  }
  .mlc-visual__legend span {
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }
  .mlc-visual__key {
    width: 22px;
    border-top: 2px solid var(--mlc-line);
  }
  .mlc-visual__key--dash {
    border-top-style: dashed;
  }
  .mlc-visual__key--cache {
    border-color: var(--mlc-violet);
    border-top-style: dashed;
  }
  .mlc-visual__scroll-hint {
    display: none;
    margin: 0.25rem 0 0;
    color: var(--mlc-muted);
    font-size: 0.75rem;
    text-align: center;
  }
  .mlc-visual figcaption {
    margin-top: 0.65rem;
    color: var(--mlc-muted);
    font-size: 0.86rem;
    line-height: 1.65;
    text-align: center;
  }
  .dark .mlc-visual {
    --mlc-paper: oklch(24% 0.018 255);
    --mlc-ink: oklch(91% 0.018 255);
    --mlc-muted: oklch(73% 0.025 255);
    --mlc-line: oklch(74% 0.025 255);
    --mlc-green-soft: oklch(31% 0.055 132);
    --mlc-blue-soft: oklch(29% 0.035 238);
    --mlc-peach-soft: oklch(31% 0.04 70);
    --mlc-pink-soft: oklch(31% 0.05 344);
  }
  .dark .mlc-visual__canvas {
    background: var(--mlc-paper);
    border-color: oklch(45% 0.055 140);
    box-shadow: 0 18px 48px oklch(10% 0.02 255 / 0.28);
  }
  .dark .mlc-visual__skip-label {
    background: var(--mlc-paper);
  }
  .dark .mlc-visual__cache {
    background: oklch(30% 0.045 304);
    color: oklch(80% 0.09 304);
  }
  .dark .mlc-visual__ffn-path span:not(.mlc-visual__times) {
    background: oklch(30% 0.035 235);
  }
  @media (max-width: 720px) {
    .mlc-visual__canvas {
      margin: 0;
    }
    .mlc-visual__scroll-hint {
      display: block;
    }
  }
</style>
<span class="mlc-visual__scroll-hint">移动端可横向滚动查看完整结构</span>
<div class="mlc-visual__viewport">
  <div class="mlc-visual__canvas">
    <div class="mlc-visual__header">
      <span class="mlc-visual__eyebrow">MODERN DECODER BLOCK</span>
      <strong>同一条主干上的五个现代组件</strong>
    </div>
    <div class="mlc-visual__stage">
      <div class="mlc-visual__skip" aria-hidden="true">
        <span class="mlc-visual__skip-label">RESIDUAL</span>
      </div>
      <div class="mlc-visual__state">
        <span class="mlc-visual__state-name">H<sup>l</sup></span>
        <span class="mlc-visual__vector" aria-label="输入隐藏向量">
          <i></i><i></i><i></i><i></i><i></i><i></i>
        </span>
      </div>
      <div class="mlc-visual__arrow" aria-hidden="true"></div>
      <div class="mlc-visual__module">
        <span class="mlc-visual__module-title">Causal Self-Attention</span>
        <span class="mlc-visual__norm">RMSNorm</span>
        <div class="mlc-visual__micro-arrow" aria-hidden="true">↓</div>
        <div class="mlc-visual__qkv">
          <span>Q Projection</span>
          <span>K Projection</span>
          <span>V Projection</span>
        </div>
        <div class="mlc-visual__attention-detail">
          <div class="mlc-visual__attention-main">
            <div class="mlc-visual__rope">RoPE<small>只旋转 Q / K</small></div>
            <div class="mlc-visual__gqa">GQA<small>因果注意力</small></div>
          </div>
          <div class="mlc-visual__cache">KV Cache<small>仅自回归推理</small></div>
        </div>
      </div>
      <div class="mlc-visual__arrow" aria-hidden="true"></div>
      <div class="mlc-visual__add"><span class="mlc-visual__plus">+</span>Residual Add</div>
    </div>
    <div class="mlc-visual__stage mlc-visual__stage--ffn">
      <div class="mlc-visual__skip" aria-hidden="true">
        <span class="mlc-visual__skip-label">RESIDUAL</span>
      </div>
      <div class="mlc-visual__state">
        <span class="mlc-visual__state-name">U</span>
        <span class="mlc-visual__vector" aria-label="注意力子层输出">
          <i></i><i></i><i></i><i></i><i></i><i></i>
        </span>
      </div>
      <div class="mlc-visual__arrow" aria-hidden="true"></div>
      <div class="mlc-visual__module">
        <span class="mlc-visual__module-title">Feed Forward</span>
        <span class="mlc-visual__norm">RMSNorm</span>
        <div class="mlc-visual__ffn-path">
          <span>SiLU(W<sub>gate</sub>U)</span>
          <span class="mlc-visual__times">×</span>
          <span>W<sub>up</sub>U</span>
        </div>
        <small>逐元素门控后，经 W<sub>down</sub> 投影回隐藏维度</small>
      </div>
      <div class="mlc-visual__arrow" aria-hidden="true"></div>
      <div class="mlc-visual__add"><span class="mlc-visual__plus">+</span>Residual Add</div>
      <div class="mlc-visual__arrow" aria-hidden="true"></div>
      <div class="mlc-visual__state">
        <span class="mlc-visual__state-name">H<sup>l+1</sup></span>
        <span class="mlc-visual__vector" aria-label="下一层隐藏向量">
          <i></i><i></i><i></i><i></i><i></i><i></i>
        </span>
      </div>
    </div>
    <div class="mlc-visual__legend" aria-label="图例">
      <span><i class="mlc-visual__key"></i>前向主干</span>
      <span><i class="mlc-visual__key mlc-visual__key--dash"></i>残差直连</span>
      <span><i class="mlc-visual__key mlc-visual__key--cache"></i>推理期缓存支路</span>
      <span>绿色：隐藏状态</span>
      <span>粉色：Q / K 位置变换</span>
    </div>
  </div>
</div>
<figcaption id="mlc-visual-caption">现代 Pre-Norm Decoder Block：RMSNorm 位于子层之前，RoPE 只作用于 Q/K，GQA 决定 K/V 头的共享方式，KV Cache 只在逐 Token 生成时复用历史 K/V。</figcaption>
</figure>

理解单个组件时，需要始终知道它位于这条数据流的哪个位置。RMSNorm 和 SwiGLU 处理隐藏状态；RoPE 只变换 Query 和 Key；GQA 改变注意力头的共享方式；KV Cache 只保存推理所需的 Key 和 Value。

## 2. RMSNorm 与特征尺度

归一化的输入通常是某个 Token 的隐藏向量：

$$
x=(x_1,x_2,\ldots,x_d)\in\mathbb{R}^{d}
$$

LayerNorm 会先减去均值，再按照标准差缩放：

$$
\mu=\frac{1}{d}\sum_{i=1}^{d}x_i,
\qquad
\sigma^2=\frac{1}{d}\sum_{i=1}^{d}(x_i-\mu)^2
$$

$$
\operatorname{LayerNorm}(x)
=
\gamma\odot
\frac{x-\mu}{\sqrt{\sigma^2+\epsilon}}
+
\beta
$$

RMSNorm 保留尺度归一化，但省略去均值过程：

$$
\operatorname{RMS}(x)
=
\sqrt{\frac{1}{d}\sum_{i=1}^{d}x_i^2+\epsilon}
$$

$$
\operatorname{RMSNorm}(x)
=
\gamma\odot\frac{x}{\operatorname{RMS}(x)}
$$

其中 $\gamma\in\mathbb{R}^{d}$ 是可训练缩放参数。常见 RMSNorm 没有偏移参数 $\beta$，因此可训练参数通常只有 $d$ 个，而带缩放和偏移的 LayerNorm 通常有 $2d$ 个。

RMSNorm 对每个 Token 独立地沿最后一个特征维度计算：

$$
[B,T,d]\longrightarrow[B,T,d]
$$

它不会混合不同 Token，也不会改变张量形状。它控制的是向量整体尺度，使 Attention 和 FFN 接收到数值范围更稳定的输入。

在 Pre-Norm Decoder Block 中，RMSNorm 通常出现在 Attention 前和 FFN 前：

$$
U=H+\operatorname{Attention}(\operatorname{RMSNorm}(H))
$$

$$
H_{\mathrm{next}}
=
U+\operatorname{FFN}(\operatorname{RMSNorm}(U))
$$

RMSNorm 没有替代残差连接，也不负责表达位置信息。它只是把每个子层的输入尺度重新调整到更稳定的范围。LayerNorm、Pre-Norm 与残差路径的基础可以回看 [Add & Norm](/posts/transformer/Trasformer-OtherPartsInEncoder-AddAndNorm/)。

## 3. RoPE 与相对位移

Self-Attention 只根据向量内容计算相似度，本身不知道 Token 顺序。原始 Transformer 把正弦位置向量直接加到 Token Embedding 上；RoPE（Rotary Position Embedding）则在 Query 和 Key 投影完成后，对它们进行与位置相关的旋转。

先看二维向量。位置 $m$ 对应的旋转矩阵为：

$$
R(m\theta)
=
\begin{bmatrix}
\cos(m\theta)&-\sin(m\theta)\\
\sin(m\theta)&\cos(m\theta)
\end{bmatrix}
$$

对于同一对特征，位置 $m$ 的 Query 和位置 $n$ 的 Key 分别变换为：

$$
\widetilde q_m=R(m\theta)q,
\qquad
\widetilde k_n=R(n\theta)k
$$

计算点积：

$$
\begin{aligned}
\widetilde q_m^\top\widetilde k_n
&=
q^\top R(m\theta)^\top R(n\theta)k\\
&=
q^\top R((n-m)\theta)k
\end{aligned}
$$

最终结果依赖位置差 $n-m$，而不是分别依赖两个绝对位置。这就是 RoPE 能把相对位移引入 Attention Score 的核心原因。

实际注意力头的维度 $d_h$ 远大于 2。RoPE 将向量拆成多个二维子空间，并为每对子空间使用不同频率：

$$
\theta_i
=
\operatorname{base}^{-\frac{2i}{d_h}},
\qquad
i=0,1,\ldots,\frac{d_h}{2}-1
$$

不同频率负责不同尺度的位置变化，再组合成一个分块对角旋转矩阵 $R_m$：

$$
\widetilde Q_m=R_mQ_m,
\qquad
\widetilde K_m=R_mK_m
$$

RoPE 通常只作用于 Q 和 K，不作用于 V。原因是位置关系需要影响注意力权重 $QK^\top$；Value 负责提供被加权汇总的内容，不需要通过旋转参与相似度计算。

RoPE 不会改变张量形状，也没有可训练参数。工程上一般预计算各个位置和频率对应的 $\cos$、$\sin$，前向传播时通过逐元素乘法和维度旋转施加到 Q/K。

训练长度之外的位置虽然仍能计算旋转角度，但模型未必学会在这些位置上稳定工作，因此“公式能外推”不等于“模型能力能无损外推”。NTK-aware Scaling、YaRN 等方法会调整频率或插值策略，以改善长上下文外推。正弦位置编码的基础可以回看[位置编码笔记](/posts/transformer/Trasformer-OtherPartsInEncoder/)。

## 4. SwiGLU 与门控前馈网络

Attention 负责在不同 Token 之间交换信息，FFN 则对每个 Token 的特征独立进行非线性变换。传统两层 FFN 可以写成：

$$
\operatorname{FFN}(x)
=
W_{\mathrm{down}}
\phi(W_{\mathrm{up}}x)
$$

其中 $\phi$ 可以是 ReLU 或 GELU。SwiGLU 增加一条门控分支：

$$
g=W_{\mathrm{gate}}x,
\qquad
u=W_{\mathrm{up}}x
$$

$$
\operatorname{SwiGLU}(x)
=
W_{\mathrm{down}}
\left[
\operatorname{SiLU}(g)\odot u
\right]
$$

$\odot$ 表示逐元素乘法。$u$ 提供候选特征，$\operatorname{SiLU}(g)$ 决定每个中间特征应该通过多少。与固定激活函数相比，门控分支让模型可以根据输入动态调节信息流。

假设模型隐藏维度为 $d$、SwiGLU 中间维度为 $m$：

$$
W_{\mathrm{gate}},W_{\mathrm{up}}\in\mathbb{R}^{m\times d},
\qquad
W_{\mathrm{down}}\in\mathbb{R}^{d\times m}
$$

忽略 bias 时，SwiGLU 的主要参数量约为：

$$
3dm
$$

普通两层 FFN 的参数量约为 $2dd_{\mathrm{ff}}$。为了保持相近的参数预算，SwiGLU 往往选择比传统 $d_{\mathrm{ff}}$ 更小的中间维度。例如传统 FFN 使用 $d_{\mathrm{ff}}=4d$ 时，参数量相近的 SwiGLU 可以取 $m\approx\frac{8}{3}d$，实际模型还会根据硬件对齐和实验效果调整。

SwiGLU 与普通 FFN 一样逐 Token 计算：

$$
[B,T,d]\longrightarrow[B,T,m]\longrightarrow[B,T,d]
$$

它不混合序列位置，也不改变 Causal Mask。FFN 的逐位置性质可以回看 [Transformer FFN](/posts/transformer/Trasformer-OtherPartsInEncoder-FFN/)。

## 5. GQA 与 K/V 共享

标准 Multi-Head Attention（MHA）为每个 Query 头配置独立的 Key 和 Value 头。如果 Query 头数为 $h_q$，通常有：

$$
h_{kv}=h_q
$$

Multi-Query Attention（MQA）让所有 Query 头共享同一组 K/V：

$$
h_{kv}=1
$$

Grouped-Query Attention（GQA）位于二者之间：

$$
1<h_{kv}<h_q
$$

并让每组 Query 头共享一组 K/V。三者可以对比如下：

| 方式 | Query 头数 | K/V 头数 | 关系                  |
| ---- | ---------: | -------: | --------------------- |
| MHA  |      $h_q$ |    $h_q$ | 每个 Q 头拥有独立 K/V |
| GQA  |      $h_q$ | $h_{kv}$ | 一组 Q 头共享一组 K/V |
| MQA  |      $h_q$ |      $1$ | 所有 Q 头共享一组 K/V |

当 $h_q=8$、$h_{kv}=4$ 时，每两个 Query 头共享一组 Key 和 Value：

~~~text
Q0, Q1 → K/V 0
Q2, Q3 → K/V 1
Q4, Q5 → K/V 2
Q6, Q7 → K/V 3
~~~

设每个头维度为 $d_h$，拆分多头后的形状为：

$$
Q\in\mathbb{R}^{B\times h_q\times T\times d_h}
$$

$$
K,V\in\mathbb{R}^{B\times h_{kv}\times T\times d_h}
$$

每个 K/V 头服务的 Query 头数量为：

$$
g=\frac{h_q}{h_{kv}}
$$

实现中可以在逻辑上把每个 K/V 头复制 $g$ 次以匹配 Query 头，也可以让 Attention Kernel 直接处理这种共享关系。所谓“复制”通常是张量视图或计算逻辑上的扩展，不代表必须永久保存多份 K/V Cache。

如果 $h_qd_h=d$，标准 MHA 的 Q/K/V/O 投影参数量约为 $4d^2$。GQA 中 Q 和 O 仍约为 $2d^2$，K 和 V 则缩小为：

$$
2d^2\frac{h_{kv}}{h_q}
$$

因此注意力投影总参数量近似为：

$$
N_{\mathrm{GQA}}
\approx
2d^2
+
2d^2\frac{h_{kv}}{h_q}
$$

GQA 最重要的收益通常出现在推理阶段：需要保存的 K/V 头更少，KV Cache 更小，从显存读取 K/V 的带宽压力也更低。相比 MQA，GQA 又保留了多组 K/V，通常能在模型质量和推理效率之间取得更平衡的折中。

## 6. KV Cache 与自回归解码

自回归生成第 $t$ 个 Token 时，第 $1$ 到 $t-1$ 个历史 Token 已经在之前步骤中计算过。模型参数不变时，这些历史位置在每一层产生的 Key 和 Value 也不会改变。

如果不使用缓存，每生成一个 Token 都要重新对整个前缀计算 K/V：

~~~text
第 1 步：计算 [x1] 的 K/V
第 2 步：重新计算 [x1, x2] 的 K/V
第 3 步：重新计算 [x1, x2, x3] 的 K/V
...
~~~

KV Cache 保存每层已经计算出的历史 K/V。生成新 Token 时，只计算当前位置的新 Q/K/V，把新 K/V 追加到缓存，再让新 Q 与全部缓存 K 做 Attention：

~~~text
Past K/V Cache + Current K/V → Updated Cache
Current Q × All Cached K/V   → Current Output
~~~

生成通常分为两个阶段：

| 阶段    | 输入                   | 主要操作                                        |
| ------- | ---------------------- | ----------------------------------------------- |
| Prefill | 完整 prompt            | 并行计算 prompt 的隐藏状态，并建立初始 KV Cache |
| Decode  | 每次一个或少量新 Token | 读取历史 Cache，追加当前 K/V，生成后续 Token    |

单层 K/V Cache 的典型形状为：

$$
K_{\mathrm{cache}},V_{\mathrm{cache}}
\in
\mathbb{R}^{B\times T\times h_{kv}\times d_h}
$$

若模型有 $L$ 层，每个元素占 $s$ 字节，Cache 大小近似为：

$$
M_{\mathrm{KV}}
\approx
2LBTh_{kv}d_hs
$$

最前面的 2 分别表示 Key 和 Value。Cache 大小随批次、层数和上下文长度线性增长。以 MiniMind 默认的 $L=8$、$h_{kv}=4$、$d_h=96$ 为例，当 $B=1$、$T=2048$、使用 BF16（$s=2$ 字节）时：

$$
M_{\mathrm{KV}}
\approx
2\times8\times1\times2048\times4\times96\times2
\approx24\ \mathrm{MiB}
$$

这个数字只计算 K/V 张量本身，不包括框架管理、临时张量和其他显存。

KV Cache 用显存换取计算复用。它省去了历史 Token 的 K/V 投影和中间层重复计算，但当前 Query 仍然要与全部历史 Key 计算注意力，所以单步 Decode 的 Attention 工作量仍随上下文长度增长。KV Cache 主要用于自回归推理，标准全序列训练通常不会使用它。

## 7. 五个组件的协作关系

把五个组件放回同一个 Pre-Norm Decoder Block，可以写成：

$$
\widehat H
=
\operatorname{RMSNorm}(H)
$$

$$
Q=\widehat HW_Q,
\qquad
K=\widehat HW_K,
\qquad
V=\widehat HW_V
$$

$$
\widetilde Q=\operatorname{RoPE}(Q),
\qquad
\widetilde K=\operatorname{RoPE}(K)
$$

$$
U
=
H
+
\operatorname{GQA}(\widetilde Q,\widetilde K,V;\mathrm{KVCache})
$$

$$
H_{\mathrm{next}}
=
U
+
\operatorname{SwiGLU}(\operatorname{RMSNorm}(U))
$$

训练时，GQA 对完整序列执行因果 Attention，KV Cache 不参与；推理时，当前 K/V 会被追加到 Cache，当前 Q 则读取历史 Cache。无论处于哪个阶段，RoPE 都在 Q/K 进入 Attention 前注入位置，RMSNorm 都在子层前稳定输入，SwiGLU 都位于 Attention 之后的 FFN 子层。

因此五个组件解决的是五类不同问题：

| 组件     | 直接处理的对象    | 核心问题               |
| -------- | ----------------- | ---------------------- |
| RMSNorm  | Hidden States     | 数值尺度与训练稳定性   |
| RoPE     | Query、Key        | 位置和相对位移         |
| SwiGLU   | 每个 Token 的特征 | 非线性变换与门控       |
| GQA      | Attention Heads   | K/V 共享与推理效率     |
| KV Cache | 历史 Key、Value   | 自回归生成中的计算复用 |

## 8. MiniMind 实现映射

MiniMind 将这些组件直接实现于 `model/model_minimind.py`：

| 理论组件        | MiniMind 实现                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------------ |
| RMSNorm         | `RMSNorm`；Block 中的 `input_layernorm` 与 `post_attention_layernorm` |
| RoPE 频率表     | `precompute_freqs_cis`                                                                      |
| RoPE 施加到 Q/K | `apply_rotary_pos_emb`                                                                      |
| GQA 头配置      | `num_attention_heads` 与 `num_key_value_heads`                                   |
| GQA K/V 扩展    | `repeat_kv`                                                                                 |
| SwiGLU          | `FeedForward` 中的 gate、up、down 三个投影                                                  |
| KV Cache        | `past_key_value`、`use_cache` 与 `past_key_values`                    |

默认配置中，MiniMind 使用隐藏维度 $d=768$、8 个 Query 头、4 个 K/V 头和头维度 $d_h=96$，所以每两个 Query 头共享一组 K/V。SwiGLU 中间维度按照：

$$
m
=
\left\lceil
\frac{d\pi}{64}
\right\rceil
\cdot64
$$

对齐到 64 的倍数；当 $d=768$ 时得到 $m=2432$。RoPE 默认使用 $\theta_{\mathrm{base}}=10^6$，并预计算最大位置范围内的 $\cos$ 和 $\sin$。

MiniMind 的 Attention 还包含 Q/K Norm 和 Flash Attention。Q/K Norm 是在 RoPE 与 Attention 前进一步控制 Query、Key 的尺度；Flash Attention 则改变 Attention 的计算 Kernel 和内存访问方式。它们不属于本文五个核心组件，后续阅读代码时再结合具体前向传播分析。

## 9. 计算代价与概念边界

五个组件对参数、计算和显存的主要影响可以归纳为：

| 组件     | 额外参数                  | 主要计算影响           | 主要显存影响            |
| -------- | ------------------------- | ---------------------- | ----------------------- |
| RMSNorm  | 每层若干个 $d$ 维缩放向量 | 增加少量归一化计算     | 很小                    |
| RoPE     | 无                        | Q/K 上的旋转运算       | 预计算的 $\cos/\sin$ 表 |
| SwiGLU   | 三个线性投影              | FFN 参数和计算占比较大 | 中间激活                |
| GQA      | 减少 K/V 投影参数         | 减少 K/V 计算与带宽    | 缩小 KV Cache           |
| KV Cache | 无模型参数                | 避免重算历史 K/V       | 随上下文长度线性增长    |

几个概念边界尤其重要：RMSNorm 不会让 Token 之间交换信息；RoPE 不直接修改 Value；SwiGLU 不负责注意力；GQA 不改变因果掩码；KV Cache 不改变模型输出的概率分布，也不会加速普通全序列训练。

