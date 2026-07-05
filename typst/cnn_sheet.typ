#import "@preview/ilm:2.1.0": *

#set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: 10pt)
#show raw: set text(font: ("JetbrainsMono NF"))
#set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
#set heading(numbering: none)
#set math.equation(numbering: none)

#let img(name) = image("../src/content/posts/ML/assets/" + name)

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
  title: [卷积神经网络 开卷考试速查手册],
  authors: "CNN 系列文章汇总",
  date: datetime(year: 2026, month: 07, day: 05),
  abstract: [
    本文档整理自《模式识别与机器学习》课程中 CNN 系列博文，涵盖：卷积神经网络概述、LeNet5、AlexNet、VGGNet、GoogLeNet (Inception V1)、ResNet、DenseNet、U-Net、Batch Normalization、通道注意力机制 (SENet)、空域注意力机制。适合开卷考试快速查阅。
  ],
  chapter-pagebreak: false,
)

// ================================================================
// CNN 概述
// ================================================================

= CNN：卷积神经网络概述

MLP 要求输入是固定维度的向量，且所有特征之间是全连接关系，这带来了两个问题：图像中的局部空间结构被破坏，参数量随图像尺寸增长极快。

卷积神经网络（CNN）通过#strong[局部连接]（每个神经元只响应一个局部区域）和#strong[权重共享]（同一个卷积核在图像各处复用）解决了这些问题——参数量与图像尺寸基本解耦，同时保留了像素间的空间关系。

== CNN 和传统神经网络

对比一般神经网络的结构和计算方式：

一般神经网络的一个神经元：

#figure(img("image.png"), caption: [neuron])

神经元的输出为（一次前向传播）：

$ y = f(sum_(i=1)^n w_i x_i + b) $

$f$ 是激活函数，$w_i$ 是权重，$x_i$ 是输入，$b$ 是偏置。

CNN 的一个卷积层：

#figure(img("image-1.png"), caption: [convolutional layer])

单纯卷积得到特征图 Feature Map：

$ z_(i,j) = sum_(m=1)^M sum_(n=1)^N w_(m,n) x_(i+m-1, j+n-1) $

CNN 一次的输出为（一次前向传播）：

$ y_(i,j) = f( sum_(m=1)^M sum_(n=1)^N w_(m,n) x_(i+m-1, j+n-1) + b ) $

其中 $f$ 是激活函数，$w_(m,n)$ 是卷积核的权重，$x_(i+m-1, j+n-1)$ 是输入图像的像素值，$b$ 是偏置，和卷积核一样是共享的，在计算时会自动广播加到每个输出像素上。

卷积过程也是一种加权求和，但权重是共享的，并且只关注局部区域。

完全等价于一个神经元的前向计算。

卷积核在输入图像上滑动，每走一步：
- 就会计算一个新的输出
- $<=>$ 应用#strong[同一个神经元]在不同位置进行计算
- $<=>$ 产生特征图中的一个#strong[新像素]。
- 一张特征图 = 很多神经元（同参数）组成的空间结构

在深度学习 中，训练步骤是：
- 前向传播（forward）
- 计算损失（loss）
- 反向传播（BP）
- 参数更新（梯度下降）

卷积层在这个流程里：
- 卷积核 $<=>$ 权重 W
- bias = 偏置 b

== CNN 的特点

=== 1. 局部连接（稀疏交互）

感受野：指卷积核在输入图像上覆盖的区域。

每个卷积核只关注输入图像的一个局部区域（#strong[感受野]），而不是全局连接。

1. CNN 能够捕捉局部特征，如边缘、纹理等。
2. 大大减少了全连接网络中的参数数量，降低了过拟合的风险。

=== 2. 权重（参数）共享

卷积核在整个输入图像上滑动，卷积核元素不变，所以网络使用#strong[相同的权重（包括偏置）]进行计算。

例如上图中 3x3 卷积核有 9 个权重参数，对于生成的特征图的每个像素，在神经网络结构里就有 9 条边，连接感受野内的输入像素。

然后统一加上一个偏置参数。

#tip[偏置项的数量和卷积核的数量是一样的，每个卷积核对应一个偏置参数。]

=== 3. 多 channel 特征提取（多卷积核）

CNN 通常使用多个卷积核来提取#strong[不同类型的特征]：

- 卷积核数量 = 输出通道数 = 特征图数量 = 特征维度
- 每个卷积核提取一种特征，生成一个#strong[特征图]（通道）。$C$ 个卷积核就生成 $C$ 个#strong[特征图]，形成一个 $C$ #strong[通道]的输出。
- 结果天然是一个高维#strong[张量]：H(图像高度) x W(图像宽度) x C(通道数)

=== 4. 池化层（Pooling Layer）/ 降采样层（Subsampling Layer）

池化是对"卷积层输出的特征图"做的操作，而且是对每个通道分别进行的：

- 输入：一组特征图（H x W x C）
- 池化：在每一张特征图上独立进行
- 输出：尺寸（H, W）变小，通道数 C 不变

常见的#strong[池化操作]：

池化窗口：定义一个固定大小的窗口（如 2x2），在特征图上滑动，对不同位置的特征进行聚合统计：

- #strong[最大池化（Max Pooling）]：取窗口内的最大值，保留最显著的特征。
- #strong[平均池化（Mean Pooling）]：取窗口内的平均值，平滑特征图，减少噪声。

#figure(img("image-2.png"), caption: [池化示意图])

池化的作用：

1. #strong[降维]：减少特征图的#strong[空间尺寸]，降低计算量和内存使用。
2. #strong[增加]卷积核的#strong[感受野]，使模型能够捕捉更大范围的特征。
3. 降低模型的复杂度，能够在一定程度上控制过拟合，提高分类器的泛化能力。
4. #strong[增强特征的平移旋转不变性]：通过聚合局部特征，池化可以使模型对输入图像的小变形、旋转和位移具有更好的鲁棒性。

=== 5. 等变表示和不变表示

- 等变表示：对平移等变（输入平移，输出也平移）。
- 不变表示：通过池化等操作实现平移、旋转、光照等不变性。

== CNN 的主要流程

#raw("输入图像 → 卷积层 → 激活函数 → 池化层 → 归一化层
        ...
        → 卷积层 → 激活函数 → 池化层 → 归一化层
        ...                                → 全连接层 → 输出
        提取特征             降 维    多用BN
        （学参数）          （无参数）", lang: "plaintext")

== 做题区

标准二维卷积（无分组、无膨胀、无深度可分离等变体）

#strong[特征图尺寸计算公式：]

$ H_("out") = (H_("in") + 2 times "padding" - ("kernel_size" - 1) - 1)/("stride") + 1 $

$ W_("out") = (W_("in") + 2 times "padding" - ("kernel_size" - 1) - 1)/("stride") + 1 $

#strong[参数量计算公式：]

卷积核尺寸：$M times N$，输入通道数：$C_("in")$，输出通道数（卷积核数量）：$C_("out")$，每个卷积核对应一个偏置参数：

$ "参数量" = (M times N times C_("in") + 1) times C_("out") $

#strong[连接数（乘加运算次数）计算公式：]

每个输出像素需要 $M times N times C_("in")$ 次乘加运算，输出特征图的尺寸为 $H_("out") times W_("out")$，输出通道数为 $C_("out")$：

#tip[bias 不参与连接数！]

$ "连接数" = M times N times C_("in") times H_("out") times W_("out") times C_("out") $

// ================================================================
// LeNet5
// ================================================================

= 卷积神经网络：LeNet5

== 结构

LeNet5 是 Yann LeCun 等人在 1998 年提出的卷积神经网络架构，主要用于手写数字识别。它由以下层次结构组成：

#figure(img("image-3.png"), caption: [LeNet5 结构图])

=== C1 卷积层

- 输入：32x32 灰度图像
- 卷积核：6 个 5x5 的卷积核
- 输出：6 个 28x28 的特征图

回顾 CNN 的特点：

- 参数共享：这里总共 $(5 times 5 + 1) times 6 = 156$ 个参数（卷积核权重 + 偏置），相比全连接层大大减少了参数数量。
- 局部连接：每个卷积核 26 个参数，输出 28x28=784 个像素，每个像素六次卷积，总共 $156 times 28 times 28 = 122,472$ 次乘加运算（连接）。

=== S2 池化层

滑动窗口大小：2x2，输出尺寸：6 个 14x14 的特征图

=== C3 卷积层

- 输入：6 个 14x14 的特征图
- 卷积核：16 个 5x5 的卷积核
- 输出：16 个 10x10 的特征图

注意这一步卷积核的连接方式：

- 前 6 个输出通道：各连接 3 个输入通道
- 中间 9 个输出通道：各连接 4 个输入通道
- 最后 1 个输出通道：连接全部 6 个输入通道

#figure(img("image-4.png"), caption: [C3 连接方式])

这一层的参数量，根据公式：

$ sum_(i=1)^(16) (M times N times C_(in,i) + 1) $

其中 $C_(in,i)$ 是第 $i$ 个输出通道连接的输入通道数，总共 1516 个参数。

连接数：$(5 times 5 times 3 times 6 + 5 times 5 times 4 times 9 + 5 times 5 times 6 times 1) times 10 times 10 = 151600$

=== S4 池化层

滑动窗口大小：2x2，输出尺寸：16 个 5x5 的特征图

=== C5 卷积层

- 输入：16 个 5x5 的特征图
- 卷积核：120 个 5x5 的卷积核
- 输出：120 个 1x1 的特征图（全连接层）

参数量：$(5 times 5 times 16 + 1) times 120 = 48120$ 个参数

连接数：$48120 times 1 times 1 = 48120$

=== F6 全连接层

- 输入：120 个 1x1 的特征图
- 输出：84 个神经元
- 参数量：$(120 + 1) times 84 = 10164$ 个参数

这一层类似于多层感知机神经网络的全连接层，参数量较大。用反向传播算法训练。

=== 输出层

- 输入：84 个神经元
- 输出：10 个神经元（对应 10 个数字类别）
- 参数量：$(84 + 1) times 10 = 850$ 个参数

// ================================================================
// AlexNet
// ================================================================

= 卷积神经网络：AlexNet

== 结构

AlexNet 是 Alex Krizhevsky 等人在 2012 年提出的卷积神经网络架构，主要用于图像分类。

一共 8 层有参数：

- 5 层卷积（Conv）：一个 11x11 卷积，一个 5x5 卷积，三个 3x3 卷积
- 3 层全连接（FC）

结构可以压缩成一行：

#raw("Conv → Pool → Conv → Pool → Conv → Conv → Conv → Pool → FC → FC → FC", lang: "plaintext")

=== Conv1 卷积层

- 输入：227 x 227 x 3 的 RGB 图像
- 卷积核：96 个 11 x 11 x 3 的卷积核（注意这里卷积核的深度是 3，和输入图像的通道数相同）
- 补边（padding）为 0
- 步长为 4
- 输出：55 x 55 x 96 的特征图

卷积完后进行 ReLU + Local Response Normalization（LRN）

#tip[
  LRN：局部响应归一化，模仿生物神经系统中的侧抑制机制，即对局部神经元的活动建立竞争机制（放到卷积里面就是相邻特征图的对应像素），抑制反馈较小的神经元，以增强模型的泛化能力。

  局部响应归一化的原因。尽管 ReLU 激活函数具有一定优势，但与传统的激活函数 tanh 和 sigmoid 相比，ReLU 的输出范围是 $[0, +∞)$，可能导致某些神经元的输出过大。

  LRN 的计算细节：记为 $a_(x,y)^i$ 表示第 $i$ 个特征图（也就是由第 $i$ 个卷积核生成的）在位置 $(x,y)$ 的激活值，LRN 的输出 $b_(x,y)^i$ 可以表示为：

  $ b_(x,y)^i = a_(x,y)^i / (k + alpha sum_(j=max(0, i-n/2))^(min(N-1, i+n/2)) (a_(x,y)^j)^2)^beta $

  其中超参数：$k$ 是一个常数，通常设置为 2；$alpha$ 是一个缩放参数，通常设置为 $10^(-4)$；$beta$ 是一个指数参数，通常设置为 0.75；$n$ 是参与归一化的相邻特征图数量，通常设置为 5；$N$ 是总的特征图数量（总卷积核数量）。

  图解如下：

  #figure(img("image-5.png"), caption: [LRN 示意图])
]

=== Pool1 池化层：重叠最大池化（overlapping max pooling）

#tip[
  重叠池化是指池化步长比池化核的尺寸小，从而使池化的输出特征图之间有重叠，目的是使特征更丰富，减少信息丢失。
]

- 滑动窗口大小：3 x 3，步长为 2
- max pooling
- 输出：27 x 27 x 96 的特征图

=== Conv2 卷积层

- 卷积核：256 个 5 x 5 的卷积核
- 补边（padding）为 2
- 步长为 1
- 输出：27 x 27 x 256 的特征图

使用分组卷积（group=2）（历史原因：GPU 不够）

然后进行 ReLU + LRN，再进行 Pooling，输出尺寸：13 x 13 x 256 的特征图

=== Conv3 卷积层

- 卷积核：384 个 3 x 3 的卷积核
- 补边（padding）为 1
- 步长为 1
- 输出：13 x 13 x 384 的特征图

处理完后进行 ReLU + LRN，输出尺寸：13 x 13 x 384 的特征图

注意：Conv3 卷积层没有池化层 pooling

=== Conv4 卷积层

- 卷积核：384 个 3 x 3 的卷积核
- 补边（padding）为 1
- 步长为 1
- 输出：13 x 13 x 384 的特征图

处理完后进行 ReLU + LRN，同 Conv3 这里也没有 pooling

=== Conv5 卷积层

- 卷积核：256 个 3 x 3 的卷积核
- 补边（padding）为 1
- 步长为 1
- 输出：13 x 13 x 256 的特征图

处理完后进行 ReLU + LRN

再进行 Pooling，输出尺寸：6 x 6 x 256 的特征图

=== FC6 全连接层

- 输入：6 x 6 x 256 的特征图（展平为 9216 维的向量，nn.Flatten）
- 卷积核：4096 个 1 x 1 的卷积核（全连接层等价于卷积核大小为输入特征图大小的卷积层）
- 输出：4096 维的特征向量

Dropout 是一种正则化方法，在训练过程中以一定概率随机丢弃部分神经元（将其输出置为 0），从而减少神经元之间的依赖关系，防止过拟合。在测试阶段不使用 Dropout。AlexNet 在全连接层（FC6、FC7）中使用了 Dropout（p=0.5 9216 -> 4096）。

然后 ReLU + LRN，输出尺寸：4096 维的特征向量

=== FC7 全连接层

- 输入：4096 维的特征向量
- 全连接
- 输出：4096 维的特征向量

也用了 Dropout，输出尺寸：4096 维的特征向量

=== FC8 输出层

- 输入：4096 维的特征向量
- 全连接
- Softmax 输出：1000 维的特征向量（对应 ImageNet 的 1000 个类别）

== 对比 LeNet5

1. Conv 层更多
2. 激活函数不同：AlexNet 用 ReLU，LeNet5 用 Sigmoid。
   - 算得更快
   - 缓解梯度消失问题
3. 使用了 LRN（卷积层）和 Dropout（全连接层）来提高泛化能力，减少过拟合。
4. 池化层的设计不同：重叠最大池化（overlapping max pooling）vs 非重叠池化（non-overlapping pooling）
   - AlexNet 使用最大池化处理，以避免平均池容易导致的模糊化问题。
   - 重叠池化是指池化步长比池化核的尺寸小，从而使池化的输出特征图之间有重叠，目的是使特征更丰富，减少信息丢失。
5. 图像增强处理：有利于扩大训练数据集，缓解过拟合，提升泛化能力。
   1. 对图像进行翻转，裁剪和颜色调整等处理，使图像特征发生变化
   2. 图像数据进行主成分（PCA）处理，并对主成分施加一个标准差为 0.1 的高斯扰动
6. GPU 加速。

// ================================================================
// VGGNet
// ================================================================

= 卷积神经网络：VGGNet

#figure(img("image-9.png"), caption: [VGGNet 结构图])

== VGGNet 结构

其对输入图像（224 x 224 x 3）的逐层处理过程为：

1) 两次卷积+ReLU。两次卷积都使用了 64 个 3x3 的卷积核，且输出特征图的尺寸都为 224 x 224 x 64（即高和宽不变，但通道数变为 64）；而后进行最大化池化处理：池化核的尺寸为 2x2，其效果为图像尺寸减半，因此输出特征图的尺寸变为 112 x 112 x 64；

2) 两次卷积+ReLU。两次卷积都使用 128 个 3x3 的卷积核，输出特征图的尺寸变为 112 x 112 x 128；而后最大化池化处理：池化核的尺寸为 2x2，其效果为图像尺寸减半，因此输出特征图的尺寸变为 56 x 56 x 128；

3) 三次卷积+ReLU。三次卷积都使用 256 个 3x3 的卷积核，输出特征图的尺寸变为 56 x 56 x 256；而后最大化池化处理，尺寸再次减半变为 28 x 28 x 256；

4) 三次卷积+ReLU。三次卷积都使用 512 个 3x3 的卷积核，输出特征图的尺寸变为 28 x 28 x 512；而后最大化池化处理，尺寸再次减半变为 14 x 14 x 512；

5) 三次卷积+ReLU。三次卷积都使用 512 个 3x3 的卷积核，尺寸变为 14 x 14 x 512；而后最大化池化处理，尺寸再次减半变为 7 x 7 x 512；

6) 三次全连接+ReLU。前两层的输出特征图尺寸为 1 x 1 x 4096，最后一层的输出特征图尺寸为 1 x 1 x 1000；

7) Softmax 层。得到输入图像在 1000 个类别上的预测概率。

== VGG vs AlexNet

=== 1. 卷积核大小和卷积层数量（深度）

- AlexNet 使用了不同大小的卷积核（11x11, 5x5, 3x3）
- VGGNet 则统一使用了 3x3 的卷积核。
- AlexNet：共 8 层（5 个卷积层 + 3 个全连接层）。
- VGG：深度大幅提升至 16~19 层（VGG-16 / VGG-19），全部由连续的 3x3 卷积层堆叠而成。

优势：

1. VGG 通过增加卷积子层数来达到同样的性能。这种设置相当于进行更多的非线性映射，以增加网络的拟合能力。
2. 在#strong[相同感受野]（7x7 相当于 3 个 3x3；5x5 相当于 2 个 3x3）下，堆叠的小卷积核参数量更少。
3. VGG 用实验证明了"深度比宽度更重要"，增加层数可以显著提升特征抽象能力，这一发现直接启发了后来的 ResNet。

=== 2. 通道数变化：逐步翻倍

- AlexNet：通道数跳跃较大（如从 3 直接到 96）。
- VGG：池化后通道数规整地翻倍（如 64 → 128 → 256 → 512）。

通道数的增加，可以理解为通过更多的不同方式提取特征。

=== 3. 池化层（Pooling）的大小及位置

池化核：
- AlexNet 的 3x3 池化核
- VGGNet 采用 2x2 的池化核

位置：
- AlexNet：在卷积层后进行池化，池化最早出现在第一层卷积之后
- VGGNet：在连续的卷积层堆叠后再进行池化，让卷积层在较大的特征图上充分提取特征后再压缩。

=== 4. 对归一化（Normalization）的态度

- AlexNet：使用了局部响应归一化（LRN）。
- VGG："归一化没有效果"（LRN 在 VGG 的深度结构中没有带来性能提升），因此 VGG 放弃了 LRN，转而依赖网络初始化和结构本身。

=== 5. 初始化策略的重要性

- AlexNet：初始化问题不太突出。
- VGG：由于网络太深，VGG 特别依赖良好的权重初始化（如 Xavier 初始化和后来的 Kaiming/何恺明初始化），否则深层网络难以收敛。

=== 6. 全连接层转为卷积层（测试阶段）

VGGNet 在测试阶段将模型的最后三个全连接层转换为三个卷积层进行处理。这样做可以使得在测试阶段输入的图像尺寸与训练阶段不同。例如 VGGNet 在训练阶段的默认输入图像为宽和高为 224 x 224 的图像，而测试阶段则可以输入其它尺寸的图像。

// ================================================================
// GoogLeNet (Inception V1)
// ================================================================

= 卷积神经网络：GoogLeNet（Inception V1）

GoogLeNet 的核心理念就是"更宽、更高效"。它是为了解决 VGG 最大的痛点——参数量过大、计算成本极高——而生的。

GoogLeNet 参数约为 500 万个，约为 AlexNet 参数个数的 1/12、VGGNet 参数个数的 1/36。

核心操作是分治+因式分解。

== Inception 卷积模块的分治

GoogLeNet 的灵魂在于其独创的 Inception 模块。在传统的卷积网络中，往往面临一个难题：该用多大的卷积核？3x3 的感受野太小，5x5 的又太贵。

Inception 给出的答案是：小孩子才做选择，我全都要！

在一个 Inception 模块中，输入特征图会并行地经过四条不同的路径：

#figure(img("image-10.png"), caption: [Inception 模块])

但如果直接堆叠这么多卷积（尤其是昂贵的 5x5），计算量会非常大。CNN 的计算量主要来源于特征维数（$C_("in")$，输入图像的#strong[通道数]）。为了解决这个问题，GoogLeNet 引入了革命性的"瓶颈层（Bottleneck）"。具体做法是：在 3x3 和 5x5 的卷积操作之前，先加一个#strong[1x1 的卷积层]：

#figure(img("image-11.png"), caption: [加入 1x1 瓶颈层的 Inception 模块])

于是四条#strong[并行]分支的计算过程变为：

- 分支 1：1x1 卷积
- 分支 2：#strong[1x1 卷积] + 3x3 卷积
- 分支 3：#strong[1x1 卷积] + 5x5 卷积
- 分支 4：最大池化 + #strong[1x1 卷积]

最后，将这四条路径的输出在#strong[通道维度]上拼接（Concatenate）在一起，作为下一层的输入。

这种设计被称为#strong["分治"]思想——让网络自己决定在这一层关注哪些特征（哪些 channels）。

=== 关于 1x1 卷积的作用

- 这里分支 2、3，以及池化后的 1x1 卷积层起到了#strong[降低通道维度]的作用，输出特征图的尺寸不变，但是#strong[通道数]大幅下降，从而显著降低了计算量。（池化操作作用在空间维度（HxW），不改变通道数，如果不降维，pooling 分支会带着一大坨通道冲进下一层。）
- 增加非线性：1x1 卷积后接 ReLU 激活函数，增加了网络的非线性表达能力。
- 融合跨通道信息：1x1 卷积可以看作是对不同通道 $C_("in")$ 的同位置像素点进行线性组合，从而实现跨通道的信息融合。（对于原图和池化后的特征图）
- 池化本身不可学习，1x1 卷积可以让池化后的特征图也能参与学习。

== Inception 卷积模块的因式分解

后来（v2 / v3）的改动：大卷积核贵，我们就用小卷积核堆叠凑出同等的感受野。

=== 1. 将大卷积拆成多个小卷积（如 5x5 → 2x3x3）

用 2 个堆叠的 3x3 卷积替代 1 个 5x5。感受野相同（都是 5x5），但参数量从 25 降到了 18（3x3+3x3=18 `\<` 25），计算量也大幅降低。

对于一个输入 $H times W$ 的图像，通道数为 $C_("in")$，输出通道数为 $C_("out")$ 的 5x5 卷积层：

- 参数量：$5 times 5 times C_("in") times C_("out") + C_("out")$
- 计算量 FLOPs：$H times W times C_("in") times C_("out") times 5 times 5$

对于两个堆叠的 3x3 卷积层：假设第一个 3x3 卷积层输出通道数为 $C_("mid")$，第二个 3x3 卷积层输出通道数为 $C_("out")$：

- 参数量：$3 times 3 times C_("in") times C_("mid") + 3 times 3 times C_("mid") times C_("out") + C_("mid") + C_("out")$
- 计算量 FLOPs：$H times W times C_("in") times C_("mid") times 3 times 3 + H times W times C_("mid") times C_("out") times 3 times 3$

此外，Conv3x3 → ReLU → Conv3x3 → ReLU 比单纯的 Conv5x5 → ReLU 多了一层非线性映射，提升了模型的表达能力。

=== 2. 将卷积分解为非对称形式（3x3 → 1x3 + 3x1）

用一个 1x3 卷积 + 一个 3x1 卷积替代一个 3x3 卷积。感受野相同（都是 3x3），但参数量从 9 降到了 6（1x3+3x1=6 `\<` 9）。而且中间的 1x3 卷积和 3x1 卷积之间加了一层 ReLU，增加了网络的非线性表达能力。

// ================================================================
// ResNet
// ================================================================

= 卷积神经网络：残差网络 ResNet

网络越深，真的越好吗？

符号定义：

- $x$ 是即将输入到新增层堆叠部分的"原始底层特征"，例如浅层网络 B 输出后的特征图
- 映射：$cal(H)(x)$ 表示深层网络 A 最终希望的理想输出映射。也就是我们期望新增的那些层，在 $x$ 的基础上，能提炼出的最终高级特征。
- $cal(F)(x)$：A 比 B 新增的那些层，理论上要学习的潜在映射关系。
- $y$：整个残差块的输出（传统网络就是每一层的输出），未经过激活函数，经过 ReLU 激活函数后传递给下一层。

#figure(img("image-13.png"), caption: [残差学习：building block])

理论上来说，越深的网络只要学习到更多层恒等映射，就能获得至少和浅层网络一样的性能，甚至更好。

- 如果新增的这几层（虚线框）是冗余的，我们并不指望它提取新特征，只希望它"原封不动"地把浅层特征传过去。
- 这等价于我们强行要求新层的实际输出 $y = cal(F)(x)$ 等于输入 $x$：
- 此时，深层网络 A 的最终映射 $cal(H)(x)$ 就等于浅层网络 B 的映射 $x$，也就是恒等映射 $cal(H)(x) = x$。
- 但优化器需要把虚线框内所有卷积层的权重矩阵 W 全部训练为 0，在高维空间中，强迫一个复杂的非线性映射退化为严格的恒等函数，极其困难。

== 实践中网络层加深可能会带来两大问题

#strong[问题一：梯度消失与梯度爆炸问题]

简单地增加深度可能会导致梯度消失或梯度爆炸。二者产生的根本原因都是在反向传播训练过程中，低隐层（接近输入层）上的梯度是来自后面高隐层（接近输出层）上梯度的乘积。当存在过多的层时，多次连乘可能会出现梯度越来越小或者逐步放大，并分别导致梯度消失或梯度爆炸。对于该问题的解决方法包括正则化层（Batch Normalization）处理。

#strong[问题二：退化问题]

简单地增加深度可能还会导致退化（Degradation）。在 ImageNet 和 CIFAR-10 图像分类任务上的研究发现，随着网络层的加深，模型在训练集上的准确率开始的趋势是不断提高，并在达到峰值（准确率饱和）后开始大幅度降低，即网络的加深反而导致预测能力降低，与人们的印象相背离。这一现象被称之为网络退化。

退化的原因不能归结为模型过拟合，因为过拟合是指在训练集上表现更好而在测试集上效果较差。

对退化现象原因的一个解释是，现有的多层非线性神经网络结构难以拟合恒等映射函数（即 $y = x$）。

== 从直接拟合到拟合残差

不再直接学习映射 $cal(H)(x)$，而是学习残差函数 $cal(F)(x) = cal(H)(x) - x$。

此时输出 $cal(H)(x) = cal(F)(x) + x$。

对于冗余层来说，理想的情况是 $cal(H)(x) = x$，此时残差函数 $cal(F)(x) = 0$。相比于直接学习恒等映射，学习残差函数更容易优化，因为它只需要将残差函数的输出调整为零，而不是强迫整个网络学习一个复杂的恒等映射。

== 一个经典的残差块

#figure(img("image-14.png"), caption: [残差块结构])

一个基本的残差单元（Basic Block）：

x → Conv → BN → ReLU → Conv → BN → (+ x) → ReLU

#strong[主路径]：输入 x → 卷积（3x3）→ BN → ReLU → 卷积（3x3）→ BN。

#strong[捷径路径]（Shortcut / Skip Connection）：输入 x 直接通过恒等映射（Identity Mapping），不经过任何计算，直接与主路径的输出相加（Addition）。

相加后，再过一次 ReLU 激活函数。

#warn[注意：ResNet 使用的是#strong[加和（Add）]，而不是 U-Net 的#strong[串联（Concat）]。加法不增加通道数，计算量极小，仅传递梯度信号。]

=== 何恺明的优化：预激活（Pre-activation）

#figure(img("image-15.png"), caption: [预激活残差块])

原来的结构：

Conv → BN → ReLU → Conv → BN → (+ x) → ReLU

$ x_(l+1) = "ReLU"(y_l) = "ReLU"(cal(F)(x_l) + x_l) $

改成（注意：加完后不再跟 ReLU）：

BN → ReLU → Conv → BN → ReLU → Conv → (+ x)

$ x_(l+1) = y_l = cal(F)(x_l) + x_l $

即把 BN 和 ReLU 挪到卷积层之前，而不放在相加之后。这种结构让跨层捷径彻底变成了纯粹的恒等映射（没有任何 BN 或 ReLU 阻碍）。

== 梯度推导分析

对于一个残差单元，输入为 $x_l$，输出为 $y_l$，捷径的恒等映射为 $cal(I)(x_l) = x_l$，残差函数为 $cal(F)(x_l)$，则有：

$ y_l = cal(F)(x_l) + cal(I)(x_l) $

给下一层输入 $x_(l+1) = f(y_l)$，忽略激活函数 $f$ 的影响。

#strong[正向传播]：浅层 $x_l$ 经过残差块后得到深层的输入 $x_L$：

$ x_L = sum_(i=l)^(L-1) cal(F)(x_i,W_i) + x_l $

#strong[反向传播]：对于损失函数 $cal(E)$，计算相对于输入 $x$ 的梯度：

$ (partial cal(E))/(partial x_l) = (partial cal(E))/(partial y_l) dot (partial y_l)/(partial x_l) = (partial cal(E))/(partial y_l) dot ( sum_(i=l)^(L-1) (partial cal(F)(x_i,W_i))/(partial x_l) + I ) $

这个式子表明，输入 $x_l$ 的梯度由两部分组成：

1. 来自残差函数 $cal(F)(x_i,W_i)$ 的梯度 $sum_(i=l)^(L-1) (partial cal(F)(x_i,W_i))/(partial x_l)$，这部分可能会出现梯度消失或爆炸。
2. 来自捷径路径的梯度 $I$，这是一个恒定的项，不会随着网络深度增加而消失或爆炸。

// ================================================================
// DenseNet
// ================================================================

= 卷积神经网络：DenseNet

既然跨层连接效果这么好，那为什么不把前面所有层的特征图都直接拿过来用呢？

ResNet 只是把前面一层的特征图拿过来用，DenseNet 则是把前面所有层的特征图都拿过来用。

在同一个#strong[密集块]（Dense Block）内，每一#strong[层]的输入，来自前面所有#strong[层]的输出（特征图）的#strong[串联/拼接]（Concatenation）。

符号定义：

- 原始输入：$x_0$ 是输入到一个 Dense Block 的初始特征图。该 Block 内有 $L$ 层
- $x_l$ 是第 $l$ 层的输出特征图，$l = 1, 2, ..., L$

$ x_l = H_l([x_0, x_1, ..., x_(l-1)]) $

- $[dot]$ 表示在#strong[通道维度]（Channel）上进行的串联/拼接（Concatenation）操作。
- $H_l(dot)$ 是第 $l$ 层的非线性变换，通常是：
  - BN → ReLU → Conv（1x1）→ BN → ReLU → Conv（3x3）（带 bottleneck 结构）
  - 或 BN → ReLU → Conv（3x3）（不带 bottleneck 结构）

== DenseNet 结构简介

#figure(img("image-16.png"), caption: [DenseNet 结构图])

== 关键超参数：增长率（Growth Rate）

如果每一层都把前面所有层的特征图拼起来，那通道数不是爆炸了吗？

解决方法：每一层只输出固定数量的特征图（例如 k=32）（新增固定数量的通道），这个数量被称为增长率（Growth Rate）。

不管这个 Dense Block 收到的 $[dot]$ 里面有多少个特征图，经过 $H_l(dot)$ 都只输出 k 个特征图。每层只"贡献"k 个新通道，但"消费"所有历史通道。

// ================================================================
// U-Net
// ================================================================

= 卷积神经网络：跨层连接 U-Net

U-Net（Ronneberger et al., 2015）是最具影响力的语义分割架构之一。它用完全对称的编码器-解码器结构和密集的跳跃连接，在医学图像分割等小样本精细分割任务中表现出色。

== 整体结构

U-Net 的结构形如大写字母 U，由对称的两半组成：

#figure(img("image-12.png"), caption: [U-Net 结构图])

=== 编码器（收缩路径）

编码器逐层下采样，捕获多尺度上下文语义。每一层的操作序列：

$ "Conv"_(3 times 3) -> "ReLU" -> "Conv"_(3 times 3) -> "ReLU" -> "Pooling"_(2 times 2) $

两次 $3 times 3$ 卷积提取局部特征，步长为 2 的 $2 times 2$ 最大池化将空间尺寸减半、感受野扩大一倍。通道数逐层加倍（64 → 128 → 256 → 512 → 1024），用更多的卷积核编码更丰富的语义信息。空间分辨率 $H times W$ 逐层减半。

=== 解码器（扩张路径）

解码器将低分辨率特征图逐步恢复到原始输入尺寸，同时融合编码器各层的空间细节。

每一层的操作序列：

$ "UpConv"_(2 times 2) -> ["concat with encoder features"] -> "Conv"_(3 times 3) -> "ReLU" -> "Conv"_(3 times 3) -> "ReLU" $

首先用 $2 times 2$ 上采样（UpConv）将特征图尺寸翻倍、通道数减半。然后将上采样后的特征图与编码器对应层的特征图沿通道维度拼接（concatenation），叠加后的通道数经过两次 $3 times 3$ 卷积恢复为减半后的值。

最后一层用 $1 times 1$ 卷积将通道数映射到类别数 $C$，输出 $H times W times C$ 的逐像素分类结果。

=== 上采样的两种实现

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([方式], [实现], [特点]),
    table.hline(stroke: 0.4pt),
    [转置卷积（Transposed Conv / UpConv）], [在输入元素间插入 0，再用标准卷积。核可学习], [能学到上采样参数，但棋盘伪影风险],
    [上采样+卷积], [先双线性插值放大，再 3x3 卷积], [无伪影，参数量少，但插值方式固定],
    table.hline(stroke: 1.2pt),
  ),
  caption: [上采样方式对比],
  kind: table,
)

原始 U-Net 使用转置卷积。实践中上采样+卷积更常用，因为双线性插值固定且稳定，后续可学习的卷积层能对上采样结果做纠偏。

=== 拼接 vs 逐元素相加

U-Net 的跳跃连接使用#strong[拼接（concat）]而非 ResNet 式的逐元素相加（add）：

- #strong[concat]：保留两份完整的信息，让解码器自行选择从浅层取多少细节、从深层取多少语义。通道数翻倍，参数量更大。
- #strong[add]：对两张特征图做加权平均，隐式地控制融合比例，参数量更节约。FPN 等后续工作证明了 add 在特定场景下同样有效。

U-Net 选择 concat 的原因在于分割任务需要精确定位，浅层边缘信息以原始形式保留得更完整。

== 损失函数

=== FCN 式逐像素交叉熵

对每个像素位置 $(x,y)$，计算预测类别分布与真实标签的交叉熵：

$ cal(L)_"CE" = - sum_(x,y) sum_(c=1)^C hat(y)_c(x,y) log y_c(x,y) $

$hat(y)$ 是 one-hot 标签，$y$ 是 softmax 输出。在类别不平衡时（背景像素远多于前景），CE 会偏向背景类。

=== Dice loss

Dice 系数衡量两个集合的相似度。对于二值分割，真实掩码 $G$ 和预测掩码 $P$ 的 Dice 系数为：

$ "Dice"(G, P) = (2 |G inter P|) / (|G| + |P|) $

Dice loss 定义为 $1 - "Dice"$，可微形式的近似（逐像素计算）：

$ cal(L)_"Dice" = 1 - (2 sum_(x,y) G_(x,y) P_(x,y) + epsilon) / (sum_(x,y) G_(x,y) + sum_(x,y) P_(x,y) + epsilon) $

$epsilon$ 是平滑项，防止除零。Dice loss 对小区域敏感——即使漏检了很小的病灶区域，Dice 系数也会明显下降。但梯度在区域很小时不稳定，因此通常与 CE 联合使用。

=== CE + Dice 联合损失

$ cal(L) = lambda cal(L)_"CE" + (1-lambda) cal(L)_"Dice" $

$lambda in [0,1]$ 平衡两项，通常取 $lambda = 0.5$。CE 提供稳定的梯度信号，Dice 聚焦于区域匹配质量，两者互补。

== 数据增强：弹性变形

U-Net 发表的医学分割场景普遍面临训练数据少（数十张标注）的问题。Ronneberger 使用了大量的实时数据增强，尤其是#strong[弹性变形]：

1. 随机初始化 $Delta x, Delta y$ 的随机场（标准差为 $sigma$ 的二维高斯分布）。
2. 对位移场用 $s$ 做缩放（控制变形幅度）。
3. 对图像和标注做相同的变形（保持对应关系）。

参数 $sigma$ 和 $s$ 控制变形的平滑度和幅度。典型值 $sigma = 4, s = 34$。此外还配合旋转 $+45度 ~ -45度$、缩放 $0.7$–$1.3$、灰度偏移等常规增强。

== Overlap-tile 策略

U-Net 使用 overlap-tile 策略处理大图。对于超过输入尺寸的图像，以滑动窗口方式分块预测，相邻块之间重叠部分（tile）的边缘因填充损失而精度较低，但中心区域的预测可靠。取每个 tile 的中心区域拼接，边缘丢弃。

#tip[
  U-Net 是语义分割的经典架构。详细的分割任务定义、FCN 起源、DeepLab 系列、Mask R-CNN 等现代方法，以及它与传统分割方法的衔接，参见 CV 篇 `CV-Seg-DeepLearning.md`。
]

// ================================================================
// Batch Normalization
// ================================================================

= CNN：Batch Normalization

这一部分单独拿出来讲讲，因为后面和 Transformer 的 Layer Normalization 有些类似。

→ 卷积层 → 激活函数 → 池化层 → 归一化层（多用 batch norm 实现）

== 关于 norm

一般 norm 都遵循下面的计算公式：

$ hat(x) = (x - mu) / sqrt(sigma^2 + epsilon) quad y = gamma hat(x) + beta $

== Batch Normalization

输入特征图 $X in bb(R)^(B, C, H, W)$，其中 $B$ 是 batch size，表示喂了多少样本（特征图数量），$C$ 是特征维度（通常指通道数），$H$ 是高度，$W$ 是宽度。

对于每个特征维度 $c$，跨 batch 计算均值和方差：

$ mu_c = 1 / (B H W) sum_(i=1)^B sum_(j=1)^H sum_(k=1)^W X_(i,c,j,k), quad sigma_c^2 = 1 / (B H W) sum_(i=1)^B sum_(j=1)^H sum_(k=1)^W (X_(i,c,j,k) - mu_c)^2 $

得到两个 $C$ 维向量 $mu in bb(R)^C$ 和 $sigma^2 in bb(R)^C$，然后广播成 $B times C times H times W$ 的矩阵，进行归一化：

$ hat(X)_(i,c,j,k) = (X_(i,c,j,k) - mu_c) / sqrt(sigma_c^2 + epsilon) quad Y_(i,c,j,k) = gamma_c hat(X)_(i,c,j,k) + beta_c $

=== Batch size

BN 强依赖 Batch 中其他样本（跨样本统计）。一般来说，Batch size 越大，BN 的效果越好。Batch size 太小，BN 的效果会变差，甚至可能不收敛。

// ================================================================
// 通道注意力机制 SENet
// ================================================================

= 卷积神经网络：通道注意力机制

#strong[通道注意力机制（Channel Attention）]：

让模型学会在#strong[通道维度]上（C）给不同的特征通道分配不同的权重。让网络动态地学习每个通道的"门控值（Gate）"，用 0~1 的标量去放大有用通道、抑制无用通道。

== 以 SENet 为例

（Squeeze-and-Excitation）

符号定义：

- 最后一层卷积特征图 $bold(X) in bb(R)^(C times H times W)$，其中 $C$ 是通道数，$H$ 是高度，$W$ 是宽度
- $bold(X)_c in bb(R)^(H times W)$：第 $c$ 个通道的特征图

#figure(img("image-17.png"), caption: [SENet 结构图])

=== Squeeze（压缩）

将每个通道的空间信息（HxW）压缩成一个全局标量，捕捉该通道的"全局响应强度"。

操作：全局平均池化（Global Average Pooling，GAP）对于第 $c$ 个通道的特征图 $bold(X)_c$：

$ z_c = 1 / (H times W) sum_(i=1)^H sum_(j=1)^W X_c(i,j) $

得到一个长度为 $C$ 的向量 $bold(z) = [z_1, z_2, ..., z_C]$，表示每个通道的全局统计信息（Global Descriptor）。

=== Excitation（激励）

利用压缩后的 $z_c$，学习每个通道的门控权重（Gating Weights）。这一步必须能够捕捉通道间的非线性交互（而非独立判断）。

操作：使用一个两层的全连接网络（FC）来学习通道间的依赖关系。具体步骤如下：

1. #strong[降维]：将 $C$ 维的向量 $bold(z)$ 映射到一个较低维度的空间（通常是 $C/r$，其中 $r$ 是一个缩放因子，常用值为 16），以减少参数量和计算量。使用 ReLU 激活函数。
2. #strong[升维]：将降维后的向量映射回 $C$ 维空间，得到每个通道的门控权重。使用 sigmoid 激活函数，确保权重 $s_c$ 在 0~1 之间。

$ bold(s) = sigma(W_2 dot "ReLU"(W_1 dot bold(z))) $

#tip[
  因为两层全连接引入了跨通道的交互（参数矩阵 $W$ 是全连接，每个通道的权重都受其他所有通道影响），而不是孤立地看单个通道。
]

=== Scale（缩放）

将学习到的门控权重 $s_c$ 应用于原始特征图 $bold(X)_c$，实现通道的自适应重标定（Recalibration）：

$ hat(bold(X))_c = s_c dot bold(X)_c $

对于多通道，就是逐元素相乘：

$ hat(bold(X)) = bold(s) dot bold(X) $

可以看作是对输入特征图进行了一次自适应的缩放。

== 与主流网络结构结合

#figure(img("image-18.png"), caption: [SENet 与网络结构结合])

// ================================================================
// 空域注意力机制
// ================================================================

= 卷积神经网络：空域注意力机制

CNN 里的注意力机制，和 Transformer 里的 QKV 自注意力机制，虽然在"注意力"这个大框架下，但它们的实现逻辑和数学本质有着根本的不同。简单来说，CNN 注意力是"加权选择"，而 QKV 自注意力是"两两交互"。

卷积神经网络的注意力机制（Attention）解决的是"选择性关注"——告诉网络在提取特征时，哪些位置更重要，以及哪些通道更重要。

#strong[空域注意力机制（Spatial Attention）]：

让模型学会在#strong[空间维度]上（高x宽）给不同的像素区域分配不同的权重。

== 类激活映射（Class Activation Mapping，CAM）

CVPR 2016 Learning Deep Features for Discriminative Localization，一开始没打算做注意力，是可解释性方法 → 后来被当成 attention 的原型。

核心思想：通过#strong[全局平均池化]（Global Average Pooling，GAP）将卷积得到的第 $k$ 个特征图 $f_k$ 压缩为一个数值，然后用全连接层学习到的权重，对卷积特征图进行加权求和。

Conv → Conv → ... → Feature Map → #box[GAP] → FC → Softmax

用 GAP（Global Average Pooling）代替 FC 前的 flatten。

类别 $c$ 的预测分数：

$ S_c = sum_k w_k^c dot "GAP"(f_k) = sum_k w_k^c ( sum_(x,y) f_k(x,y) ) $

CAM 的输出是一个热力图（heatmap），表示每个空间位置对最终分类结果的贡献大小：

$ M_c(x,y) = sum_k w_k^c f_k(x,y) $

CAM = 一种"被动产生"的空间注意力：

- attention #strong[不是]"可学习模块"
- 只能用于特定结构（必须 GAP）
- 是事后解释，不参与决策

== 软注意力（Soft Attention）

符号定义：

- 最后一层卷积特征图 $bold(F) in bb(R)^(C times H times W)$，其中 $C$ 是通道数，$H$ 是高度，$W$ 是宽度
- $bold(F) = {bold(a)_1, bold(a)_2, ..., bold(a)_N} in bb(R)^C$：特征图展平成 $N = H times W$ 个 $C$ 维向量的集合。$bold(a)_i$ 表示第 $i$ 个空间位置的特征向量。
- $t$ 下标，表示时间步解码（生成文本）的时间步。
- $bold(h)_(t-1) in bb(R)^d$：解码器上一时间步的隐藏状态向量，$d$ 是隐藏状态的维度。
- $e_(t,i)$：在第 $t$ 步，模型对第 $i$ 个图像区域的#strong[注意力得分]（Attention Score），也叫#strong[对齐得分]（Alignment Score）。
- $alpha_(t,i)$：在第 $t$ 步，模型对第 $i$ 个图像区域的#strong[注意力权重]（Attention Weight），是对注意力得分 $e_(t,i)$ 进行归一化后的结果，是一个#strong[概率值]。
- $bold(z)_t in bb(R)^C$：在第 $t$ 步，模型根据注意力权重 $alpha_(t,i)$ 对图像特征进行加权求和得到的#strong[上下文向量]（Context Vector）。

== 软注意力的前向传播流程

=== 1. 计算注意力得分（Alignment Score）

打分由当前时间步的解码器隐藏状态 $bold(h)_(t-1)$ 和图像特征向量 $bold(a)_i$ 共同决定。

$ e_(t,i) = f_"score"(bold(h)_(t-1), bold(a)_i) $

常见形式：

$ e_(t,i) = bold(v)^T tanh(bold(W)_h bold(h)_(t-1) + bold(W)_a bold(a)_i + bold(b)) $

=== 2. 计算注意力权重（Attention Weight）

这一步对注意力得分 $e_(t,i)$ 进行归一化，得到每个图像区域（空间位置 i 对应的特征向量）的注意力权重 $alpha_(t,i)$：

$ alpha_(t,i) = exp(e_(t,i)) / sum_(j=1)^N exp(e_(t,j)) $

=== 3. 计算上下文向量（Context Vector）

对所有图像区域的特征向量 $bold(a)_i$ 按照注意力权重 $alpha_(t,i)$ 进行加权求和，得到上下文向量 $bold(z)_t$：

$ bold(z)_t = sum_(i=1)^N alpha_(t,i) bold(a)_i $

=== 4. 将上下文向量与解码器隐藏状态结合

喂给解码器的输入通常是上下文向量 $bold(z)_t$ 和解码器上一时间步的隐藏状态 $bold(h)_(t-1)$ 的结合。常见的做法是将它们拼接或加权融合，然后输入到解码器中生成下一个词。

== 软注意力的反向传播

解码器的损失函数记作 $cal(L)$，我们需要计算 $ (partial cal(L)) / (partial e_(t,i)) $ 和 $ (partial cal(L)) / (partial bold(a)_i) $ 来更新注意力机制的参数。

计算 $ (partial cal(L)) / (partial bold(z)_t) $：首先计算损失函数对上下文向量的梯度。

$ delta_(bold(z)_t) = (partial cal(L)) / (partial bold(z)_t) $

=== 梯度分流：传播到注意力权重

$ delta_(alpha_(t,i)) = (partial cal(L)) / (partial alpha_(t,i)) = (partial cal(L)) / (partial bold(z)_t) dot (partial bold(z)_t) / (partial alpha_(t,i)) = delta_(bold(z)_t)^T dot bold(a)_i $

这是一个标量，表示如果把第 $i$ 个位置的注意力权重提高一点点，损失会如何变化。

=== 梯度分流：传播到图像特征向量

$ delta_(bold(a)_i) = (partial cal(L)) / (partial bold(a)_i) = (partial cal(L)) / (partial bold(z)_t) dot (partial bold(z)_t) / (partial bold(a)_i) = delta_(bold(z)_t) dot alpha_(t,i) $

这是一个向量，对于第 i 个位置的图像特征向量 $bold(a)_i$，注意力越大，梯度越大，模型学习更多。

=== 经过 softmax：从权重传播到注意力得分

$ delta_(e_(t,i)) = (partial cal(L)) / (partial e_(t,i)) = sum_(j=1)^N (partial cal(L)) / (partial alpha_(t,j)) dot (partial alpha_(t,j)) / (partial e_(t,i)) = sum_(j=1)^N delta_(alpha_(t,j)) dot (partial alpha_(t,j)) / (partial e_(t,i)) $

softmax 的梯度公式：

$ (partial alpha_(t,j)) / (partial e_(t,i)) = alpha_(t,j) (delta_(i j) - alpha_(t,i)) $

== vs 硬注意力（Hard Attention）

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([对比维度], [软注意力（Soft Attention）], [硬注意力（Hard Attention）]),
    table.hline(stroke: 0.4pt),
    [选择方式], [对所有位置加权平均（求期望）], [从分布中随机采样 1 个或极少数位置（概率选点）],
    [数学性质], [确定性（Deterministic），给定输入，输出固定], [随机性（Stochastic），每次运行可能关注不同位置],
    [是否可微], [完全可微，可直接用标准反向传播], [不可微，需要引入强化学习（REINFORCE）或重参数化技巧],
    [训练难度], [易于收敛，训练稳定], [方差高，训练不稳定，需要额外技巧（如方差衰减）],
    [计算成本], [计算量大（所有位置都要算加权和）], [计算量小（只处理选中的 1 个位置）],
    [应用场景], [主流的机器翻译、图像描述（Transformer、ViT）], [早期的视觉推理、目标检测中的区域提议],
    table.hline(stroke: 1.2pt),
  ),
  caption: [软注意力 vs 硬注意力],
  kind: table,
)
