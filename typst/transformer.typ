#import "@preview/ilm:2.1.0": *

#set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: 10pt)
#show raw: set text(font: ("JetbrainsMono NF"))
#set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
#set heading(numbering: none)
#set math.equation(numbering: none)

#let tip(body) = {
  block(
    fill: rgb("#FFF8E1"),
    stroke: (left: 3pt + rgb("#FFA000")),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body
  )
}

#let warn(body) = {
  block(
    fill: rgb("#FFEBEE"),
    stroke: (left: 3pt + red),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body
  )
}

#let formula(body) = {
  block(
    fill: luma(245),
    inset: (x: 12pt, y: 6pt),
    radius: 4pt,
    width: 100%,
    body
  )
}

#show: ilm.with(
  title: [计算机视觉 & 深度学习 开卷考试速查手册 — Transformer 篇],
  authors: "Biscuit · Alkaid",
  date: datetime(year: 2026, month: 07, day: 05),
  abstract: [
    本文档包含 Vision Transformer 相关内容，涵盖：Transformer 基础结构（自注意力机制、多头注意力、位置编码、编码器-解码器）、ViT（图像分块、Patch Embedding、[CLS] Token）、DeiT、PVT、Swin Transformer、ConvNeXt、RepLKNet。适合开卷考试快速查阅。
  ],
  chapter-pagebreak: false,
)


#pagebreak()

= 视觉 Transformer（ViT）详解

ViT 的问题就是如何让 Transformer 像处理 NLP 任务一样处理图像任务。ViT 的输入是图像，输出是分类结果。ViT 的核心思想就是把图像切成小块（patch），然后把这些小块当作一个序列输入到 Transformer 中进行处理。

== 图像 Tokenization

+ #strong[图像分块与序列化：]将输入图像（如 224x224x3）均匀划分为一组固定大小的、不重叠的图像块（Patches），通常为 16x16 像素。例如，一张 224x224 的图像会被切分成 $(224/16) times (224/16) = 196$ 个图像块。每个图像块会被展平（Flatten）成一个一维向量。

+ #strong[线性投影（Patch Embedding）：]使用一个可训练的线性层，将每个展平后的图像块向量，映射到一个维度为 $D$ 的嵌入空间（Embedding Space）。这个操作与 NLP 中将词转换为词向量的过程类似。经过这一步，我们得到了一个由 $N$ 个向量（$N$ 等于图像块数量）组成的序列，每个向量的维度都是 $D$。

+ #strong[添加位置编码（Positional Encoding）：]由于 Transformer 本身不具备处理顺序的能力，需要加入位置编码来保留每个图像块在原始图像中的空间位置信息。ViT 通常使用可学习的 1D 位置编码，与图像块嵌入相加后输入编码器。

+ #strong[添加 [CLS] 标记：]借鉴 BERT，ViT 会在序列最前面添加一个特殊的可学习 [CLS] token。经过编码器后，这个 token 的最终输出状态会被用作整个图像的聚合表示，用于后续的分类等任务。

== Transformer 编码器处理图像块序列

依旧是使用标准的 Transformer 编码器结构，包括多头自注意力机制（Multi-Head Self-Attention）、前馈神经网络（Feed Forward Network，FFN）、残差连接（Residual Connection）和层归一化（Layer Normalization）。这些组件的作用和在 NLP 任务中是类似的，只是输入变成了图像块序列。

需要注意的是，最后送进分类器的不是所有图像块的输出，而是 [CLS] token 的输出。这个输出向量会被送入一个线性分类器（通常是一个全连接层），用于预测图像的类别。

== ViT vs CNN

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([特性], [#strong[ViT (Vision Transformer)]], [#strong[CNN (卷积神经网络)]]),
    table.hline(stroke: 0.4pt),
    [核心机制], [自注意力机制 (Self-Attention)], [卷积操作 (Convolution)],
    [感受野], [全局 (Global)，第一层即可看到所有图像块], [局部 (Local)，需堆叠多层才能扩大视野],
    [归纳偏置], [较弱，没有内置"空间邻近"或"平移不变"的假设], [很强，内置"平移不变性"和"局部性"等先验],
    [数据效率], [较低，极度依赖海量数据预训练], [较高，在小数据集上也能有效训练],
    [计算复杂度], [与图像块数量的平方成正比 $(O(N^2))$], [与图像尺寸线性相关 $O(H W)$],
    [全局建模], [天生具备，直接建模长距离依赖], [能力较弱，需要通过深层网络间接实现],
    [高分辨率], [计算量随分辨率平方级增长，可能成为瓶颈], [计算量随分辨率线性增长，相对友好],
    table.hline(stroke: 1.2pt),
  ),
  caption: [ViT vs CNN 核心对比],
  kind: table,
)

== ViT 的优势与局限

=== 优势：更强的全局理解能力

- #strong[强大的全局建模能力]：ViT 能够从第一层开始就捕捉图像中远距离像素或区域之间的关系。在处理需要理解全局上下文的任务时，这种能力尤其关键。
- #strong[打破 CNN 的性能瓶颈]：当拥有海量训练数据时，ViT 可以通过在大规模数据集上的预训练，学习到超越 CNN 的表示能力。

=== 局限：更高的数据门槛与计算成本

- #strong[对数据量的要求极高]：由于缺乏 CNN 那样的#strong[归纳偏置（Inductive Bias）]，ViT 无法高效地从有限的数据中学习空间结构。它在 ImageNet-1k（130 万张图）这样的数据集上，性能可能不如同等规模的 CNN。
- #strong[计算复杂度较高]：自注意力的计算复杂度与图像块数量的平方成正比。处理高分辨率图像时，计算量和内存消耗会急剧增加。
- #strong[训练成本高昂]：为了达到最佳性能，ViT 通常需要在上亿量级的超大规模数据集（如 JFT-300M）上进行预训练，这对计算资源是巨大的挑战。

== 改进与变体：解决 ViT 的局限性

为了解决上述问题，研究者们提出了大量的改进方案：

- #strong[数据高效型 ViT（Data-Efficient Image Transformers, DeiT）]：通过引入知识蒸馏等训练策略，降低 ViT 对超大规模数据的需求。
- #strong[层次化 ViT]：如 Swin Transformer，引入类似 CNN 的层级结构（金字塔结构），在降低计算复杂度的同时，也获得了更好的多尺度特征。
- #strong[混合架构]：在 ViT 的早期阶段使用卷积层来提取局部特征，再将特征序列送入 Transformer 层，以结合两者的优势。

ViT 的成功证明了，在拥有足够数据的前提下，#strong[全局的自注意力机制是一种比局部卷积更强的视觉建模方式]。

#pagebreak()
= 视觉 Transformer

== Transformer 基础结构

Transformer 包含编码器（Encoder）和解码器（Decoder），主要由注意力机制和前馈神经网络构成。核心操作是将输入转为词嵌入（Word Embedding）与位置嵌入（Position Embedding）的和作为模型输入。

#strong[位置嵌入的作用：]由于自注意力机制本身不具备顺序感知能力，位置嵌入用于表示词或图像块在序列中的位置，以保留全局结构信息。

== 自注意力（Self-Attention）公式

#formula[$ "Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V $]

- $Q, K, V$ 通过将输入矩阵分别乘以三个可学习的线性变换矩阵得到。
- $d_k$ 为 $Q$ 和 $K$ 的列数（向量维度）。
- 除以 $sqrt(d_k)$ 是为了防止 $Q K^T$ 的内积结果过大，导致 softmax 梯度消失。
- #strong[多头注意力（Multi-Head Attention）：]将 $Q, K, V$ 拆分为多个头并行计算注意力，最后拼接并经过线性层输出。

== 编码器与解码器的区别

- #strong[编码器：]看到输入的完整序列信息，每层包含多头自注意力、残差连接、层归一化（Add & Norm）和前馈网络（Feed Forward）。
- #strong[解码器：]包含#strong[掩码多头自注意力（Masked Multi-Head Attention）]，训练时只能看到当前时刻及之前的信息。同时包含交叉注意力层（Cross-Attention），以编码器输出为 $K, V$，解码器自身输入为 $Q$。

== 代表性视觉 Transformer 模型

- #strong[ViT (Vision Transformer)：]将图片切分为固定大小（如 $16 times 16$）的 Patch，线性投影为向量，加入可学习的 `[class]` token，送入标准 Transformer Encoder，最后通过 MLP Head 输出分类结果。
- #strong[DeiT：]通过引入更优的优化算法、超参数搜索、更强的数据增广（Rand-Augment、Mixup、Cutmix）和正则化（随机深度 Stochastic Depth），使 Transformer 能在 ImageNet-1k 上直接训练。
- #strong[PVT (Pyramid Vision Transformer)：]引入#strong[特征金字塔]结构，将 Transformer 分为多个阶段，每阶段输出特征图分辨率逐渐缩小，类似 CNN 的多尺度特征提取。
- #strong[LocalViT：]将 FFN 中的全连接层替换为#strong[深度可分离卷积（Depthwise Convolution）]，在保留全局建模能力的同时注入局部空间上下文信息。
- #strong[Swin Transformer：]引入#strong[移动窗口注意力（Shifted Window Attention）]。每层划分为局部窗口进行自注意力计算，下一层将窗口平移，实现跨窗口信息交互，兼顾全局建模和计算效率。


= Transformer 向 CNN 回归（ConvNeXt & RepLKNet）

#strong[ConvNeXt：]完全采用 CNN 结构，但借鉴 Transformer 的训练技巧。

- 网络模块数从 ResNet 的 `(3,4,6,3)` 变为 `(3,3,9,3)`。
- #strong[Patchify 处理：]使用 $4 times 4$ 卷积，步长为 4 替代传统 $7 times 7$ 卷积加最大池化。
- #strong[ResNeXt 化：]采用深度可分离卷积（Depthwise Conv）并增加网络宽度。
- #strong[倒瓶颈结构（Inverted Bottleneck）：]维度 $96 -> 384 -> 96$（类似 MobileNetV2）。
- #strong[大卷积核：]深度可分离卷积核从 $3 times 3$ 提升至 $7 times 7$。
- #strong[微设计：]激活函数替换为 #strong[GELU]，BN 替换为 #strong[LayerNorm (LN)]，下采样与通道变换解耦。
- #strong[优化器：]采用 #strong[AdamW]。

#strong[RepLKNet：]通过#strong[大卷积核深度可分离卷积]获取更大感受野，提出#strong[结构重参数化]技术。

#formula[
  重参数化：$ bold(F)(bold(x)) + bold(x) = bold(x) star bold(w)' $

  其中 $bold(w)' = bold(w) + mat(0, 0, 0; 0, 1, 0; 0, 0, 0)$（训练多分支，推理融合为单一卷积核）
]


#pagebreak()

= Lecture 06_2 核心速查（开卷考试直接抄用）

#strong[1. 自注意力公式：]$"Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V$

#strong[2. 多头注意力：]将 $Q, K, V$ 拆分为多头并行计算，最后拼接。

#strong[3. 视觉 Transformer 代表模型：]

- ViT：Patch 划分 + [class] token + Transformer Encoder
- DeiT：数据增广 + 正则化，无需超大规模预训练
- PVT：特征金字塔，多阶段分辨率递减
- Swin：移动窗口注意力，兼顾全局与局部

#strong[4. ConvNeXt：]CNN 结构 + Transformer 训练技巧（AdamW、GELU、LN）

#strong[5. RepLKNet：]大卷积核 + 结构重参数化（训练多分支、推理融合）

#strong[6. 监督学习：]$L = 1/N sum ell(f(x_i), y_i)$

#strong[7. 对比学习 InfoNCE：]$L_"InfoNCE" = -sum_i log (exp(bold(z)_i dot bold(z)_(i^+) / tau)) / (sum_(j != i) exp(bold(z)_i dot bold(z)_j / tau))$

#strong[8. 元学习 MAML：]$theta^* = "arg min"_(theta) sum_k L_k^("test")(theta - alpha nabla L_k^("train")(theta))$

#strong[9. 联邦学习 FedAvg：]$theta_(t+1) = sum_(k=1)^K n_k/n theta_(t+1)^((k))$

#strong[10. 深度学习框架：]PyTorch（动态图）、TensorFlow（静态图）

