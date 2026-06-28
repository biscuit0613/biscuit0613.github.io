---
title: 深度学习的基本结构：层，块，组件，网络
published: 2026-06-20
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 12
draft: false 
lang: ''
---

之前一直苦恼于抽象的概念，层，块，组件，网络之间的关系。
<div class="pe-viz" style="margin:2rem 0">

<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--font-sans)}
.wrap{padding:1.5rem 0}
.section-label{font-size:11px;font-weight:500;letter-spacing:.06em;text-transform:uppercase;color:var(--text-muted);margin-bottom:10px}
.cols{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-bottom:10px}
.col-head{font-size:12px;color:var(--text-muted);text-align:center;margin-bottom:6px;padding-bottom:6px;border-bottom:0.5px solid var(--border)}

.level-row{display:grid;grid-template-columns:80px 1fr 1fr 1fr;gap:10px;align-items:center;margin-bottom:8px}
.level-label{font-size:12px;color:var(--text-muted);text-align:right;padding-right:8px;line-height:1.4}

.chip{border-radius:8px;padding:8px 12px;text-align:center;border:0.5px solid}
.chip-title{font-size:13px;font-weight:500;line-height:1.3}
.chip-sub{font-size:11px;margin-top:3px;line-height:1.4}

.amber-chip{background:#FAEEDA;border-color:#EF9F27}
.amber-chip .chip-title{color:#633806}
.amber-chip .chip-sub{color:#854F0B}
.blue-chip{background:#E6F1FB;border-color:#85B7EB}
.blue-chip .chip-title{color:#0C447C}
.blue-chip .chip-sub{color:#185FA5}
.teal-chip{background:#E1F5EE;border-color:#5DCAA5}
.teal-chip .chip-title{color:#085041}
.teal-chip .chip-sub{color:#0F6E56}
.purple-chip{background:#EEEDFE;border-color:#AFA9EC}
.purple-chip .chip-title{color:#26215C}
.purple-chip .chip-sub{color:#3C3489}

@media(prefers-color-scheme:dark){
.amber-chip{background:#412402;border-color:#BA7517}
.amber-chip .chip-title{color:#FAC775}
.amber-chip .chip-sub{color:#EF9F27}
.blue-chip{background:#042C53;border-color:#378ADD}
.blue-chip .chip-title{color:#B5D4F4}
.blue-chip .chip-sub{color:#85B7EB}
.teal-chip{background:#04342C;border-color:#1D9E75}
.teal-chip .chip-title{color:#9FE1CB}
.teal-chip .chip-sub{color:#5DCAA5}
.purple-chip{background:#26215C;border-color:#7F77DD}
.purple-chip .chip-title{color:#CECBF6}
.purple-chip .chip-sub{color:#AFA9EC}
}

.arrow-col{display:grid;grid-template-columns:80px 1fr 1fr 1fr;gap:10px;margin-bottom:4px;align-items:center}
.arrow-label{font-size:11px;color:var(--text-muted);text-align:right;padding-right:8px}
.arrow-cell{display:flex;flex-direction:column;align-items:center;gap:2px}
.arrow-line{width:0.5px;height:16px;background:var(--border-strong)}
.arrow-head{width:0;height:0;border-left:4px solid transparent;border-right:4px solid transparent;border-top:5px solid var(--border-strong)}
.arrow-note{font-size:11px;color:var(--text-muted)}

.divider{border:none;border-top:0.5px solid var(--border);margin:20px 0}

.topo-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px}
.topo-card{background:var(--surface-1);border:0.5px solid var(--border);border-radius:10px;padding:12px}
.topo-card h4{font-size:13px;font-weight:500;color:var(--text-primary);margin-bottom:4px}
.topo-card .topo-formula{font-size:13px;color:var(--text-secondary);font-family:var(--font-mono);margin:6px 0;padding:5px 8px;background:var(--surface-0);border-radius:6px;border:0.5px solid var(--border)}
.topo-card .topo-eg{font-size:11px;color:var(--text-muted)}
.topo-badge{display:inline-block;font-size:11px;font-weight:500;padding:2px 7px;border-radius:100px;margin-bottom:6px}
.b-seq{background:#E1F5EE;color:#0F6E56}
.b-par{background:#EEEDFE;color:#3C3489}
.b-skip{background:#FAEEDA;color:#854F0B}
@media(prefers-color-scheme:dark){
.b-seq{background:#04342C;color:#9FE1CB}
.b-par{background:#26215C;color:#CECBF6}
.b-skip{background:#412402;color:#FAC775}
}

.formula-box{background:var(--surface-0);border:0.5px dashed var(--border-strong);border-radius:10px;padding:14px 16px;margin-top:4px}
.formula-row{font-size:13px;color:var(--text-secondary);font-family:var(--font-mono);padding:5px 0;border-bottom:0.5px solid var(--border);line-height:1.7}
.formula-row:last-child{border-bottom:none}
.formula-note{font-size:11px;color:var(--text-muted);margin-top:10px;line-height:1.6}
.hl-amber{color:#854F0B;font-weight:500}
.hl-blue{color:#185FA5;font-weight:500}
.hl-teal{color:#0F6E56;font-weight:500}
.hl-purple{color:#3C3489;font-weight:500}
@media(prefers-color-scheme:dark){
.hl-amber{color:#FAC775}
.hl-blue{color:#B5D4F4}
.hl-teal{color:#9FE1CB}
.hl-purple{color:#CECBF6}
}
.iface-note{font-size:12px;color:var(--text-secondary);background:var(--surface-1);border:0.5px solid var(--border);border-radius:8px;padding:8px 12px;margin-top:10px;line-height:1.7}
</style>

<div class="wrap">

<div class="section-label">纵向：抽象层级</div>

<div class="arrow-col">
  <div></div>
  <div class="arrow-cell"><div class="col-head" style="width:100%">通用</div></div>
  <div class="arrow-cell"><div class="col-head" style="width:100%">CNN（ResNet）</div></div>
  <div class="arrow-cell"><div class="col-head" style="width:100%">Transformer（BERT）</div></div>
</div>

<div class="level-row">
  <div class="level-label">M<br>模型</div>
  <div class="chip purple-chip"><div class="chip-title">模型 / Model</div><div class="chip-sub">完整可训练对象</div></div>
  <div class="chip purple-chip"><div class="chip-title">ResNet-50</div><div class="chip-sub">4 stage × N ResBlock</div></div>
  <div class="chip purple-chip"><div class="chip-title">BERT-base</div><div class="chip-sub">12 × EncoderBlock</div></div>
</div>

<div class="arrow-col">
  <div class="arrow-label">堆叠 ↑</div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
</div>

<div class="level-row">
  <div class="level-label">B<br>块</div>
  <div class="chip teal-chip"><div class="chip-title">块 / Block</div><div class="chip-sub">可复用子图</div></div>
  <div class="chip teal-chip"><div class="chip-title">ResBlock</div><div class="chip-sub">Conv+BN+ReLU + 跳跃</div></div>
  <div class="chip teal-chip"><div class="chip-title">EncoderBlock</div><div class="chip-sub">MHA + AddNorm + FFN</div></div>
</div>

<div class="arrow-col">
  <div class="arrow-label">组合 ↑</div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
</div>

<div class="level-row">
  <div class="level-label">ℓ<br>层</div>
  <div class="chip blue-chip"><div class="chip-title">层 / Layer</div><div class="chip-sub">原子算子单元</div></div>
  <div class="chip blue-chip"><div class="chip-title">Conv2d, BN, ReLU</div><div class="chip-sub">单个卷积或激活</div></div>
  <div class="chip blue-chip"><div class="chip-title">Linear, LayerNorm</div><div class="chip-sub">单个线性变换</div></div>
</div>

<div class="arrow-col">
  <div class="arrow-label">拥有 ↑</div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
  <div class="arrow-cell"><div class="arrow-line"></div><div class="arrow-head"></div></div>
</div>

<div class="level-row">
  <div class="level-label">θ<br>参数</div>
  <div class="chip amber-chip"><div class="chip-title">参数 / Parameter</div><div class="chip-sub">可学习张量</div></div>
  <div class="chip amber-chip"><div class="chip-title">W, b</div><div class="chip-sub">卷积核权重与偏置</div></div>
  <div class="chip amber-chip"><div class="chip-title">W_Q, W_K, W_V</div><div class="chip-sub">注意力投影矩阵</div></div>
</div>

<div class="iface-note">层、块、模型共享同一接口：<strong>forward(x) → y</strong>　　<strong>parameters() → {θ}</strong>　　粒度不同，行为协议相同。</div>

<div class="divider"></div>

<div class="section-label">横向：同一层级内的三种拓扑</div>

<div class="topo-grid">
  <div class="topo-card">
    <span class="topo-badge b-seq">Sequential</span>
    <h4>顺序</h4>
    <div class="topo-formula">B₁ → B₂ → … → Bₙ</div>
    <div class="topo-eg">VGG 各阶段、GPT 主干</div>
  </div>
  <div class="topo-card">
    <span class="topo-badge b-par">Parallel</span>
    <h4>并行</h4>
    <div class="topo-formula">x → B₁ ⊕ B₂ ⊕ B₃</div>
    <div class="topo-eg">Inception Module、多头注意力</div>
  </div>
  <div class="topo-card">
    <span class="topo-badge b-skip">Skip</span>
    <h4>跳跃</h4>
    <div class="topo-formula">y = F(x) + x</div>
    <div class="topo-eg">ResBlock、Transformer AddNorm</div>
  </div>
</div>

<div class="divider"></div>

<div class="section-label">自相似性：递推定义</div>

<div class="formula-box">
  <div class="formula-row"><span class="hl-purple">M</span>(x) = <span class="hl-teal">B</span>_N ∘ <span class="hl-teal">B</span>_{N−1} ∘ … ∘ <span class="hl-teal">B</span>_1(x)</div>
  <div class="formula-row"><span class="hl-teal">B</span>_i(x) = <span class="hl-blue">ℓ</span>_k ∘ … ∘ <span class="hl-blue">ℓ</span>_1(x) + skip(x)</div>
  <div class="formula-row"><span class="hl-blue">ℓ</span>(x) = σ( <span class="hl-amber">W</span> x + <span class="hl-amber">b</span> )　,　<span class="hl-amber">W, b</span> ∈ θ</div>
  <div class="formula-note">每一层都可以被当作"更小的模型"；每一个模型都可以被当作"更大的块"。层次之间没有本质不同，只有粒度之分。</div>
</div>

</div>

用一张结构图来展示这些关系。图里有三条主线，顺着读下来会比较清楚。

**纵向：抽象阶梯。** 从 θ（参数）到 ℓ（层）到 B（块）到 M（模型），是一条单向的"拥有/组合/堆叠"关系链。每往上一级，粒度变粗，表达能力变强，但接口不变——对外都是 forward(x) → y 这一个动作。CNN 和 Transformer 只是在每一级填了不同的名字，结构是完全同构的。

**横向：同一层级内的三种拓扑。** 块之间（以及层之间）的组合方式只有三种：顺序（Sequential，输出串行往下传）、并行（Parallel，同一个输入喂给多路，输出拼/加在一起）、跳跃（Skip，绕过某些变换把输入直接加回来）。VGG 纯顺序，Inception 是并行，ResNet 和 Transformer 的 AddNorm 是跳跃。现实的网络就是这三种拓扑的嵌套组合。

**底部：自相似性的数学形式。** 最底下三行递推式是整个体系的核心——模型是块的复合，块是层的复合加上可选的跳跃连接，层是参数的仿射变换加激活。这个递推可以在任意层级展开：可以把 ResNet 整个当作一个块嵌进更大的架构，也可以把一个 Linear 层当作退化的"零层块"。层次之间没有本质不同，只有粒度之分。
