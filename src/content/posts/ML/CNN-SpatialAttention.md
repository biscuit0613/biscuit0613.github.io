---
title: 卷积神经网络：空域注意力机制
published: 2026-06-22
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
draft: false 
lang: ''
---

CNN里的注意力机制，和Transformer里的QKV自注意力机制，虽然在“注意力”这个大框架下，但它们的实现逻辑和数学本质有着根本的不同。简单来说，CNN注意力是“加权选择”，而QKV自注意力是“两两交互”。

卷积神经网络的注意力机制（Attention） 解决的是“选择性关注”——告诉网络在提取特征时，哪些位置更重要，以及哪些通道更重要。

**空域注意力机制（Spatial Attention）**：

让模型学会在 **空间维度** 上（高×宽）给不同的像素区域分配不同的权重。

## 类激活映射（Class Activation Mapping，CAM）

CVPR 2016 Learning Deep Features for Discriminative Localization，一开始没打算做注意力，是可解释性方法 → 后来被当成 attention 的原型

核心思想：通过**全局平均池化**（Global Average Pooling，GAP）将卷积得到的第 $k$ 个特征图 $f_k$ 压缩为一个数值，然后用全连接层学习到的权重，对卷积特征图进行加权求和。

Conv → Conv → ... → Feature Map → $\boxed{GAP}$ → FC → Softmax

用 GAP（Global Average Pooling）代替 FC 前的 flatten

类别 $c$ 的预测分数：

$$
S_c = \sum_k w_k^c \cdot \text{GAP}(f_k) = \sum_k w_k^c \left( \sum_{x,y} f_k(x,y) \right)
$$

CAM 的输出是一个热力图（heatmap），表示每个空间位置对最终分类结果的贡献大小：

$$
M_c(x,y) = \sum_k w_k^c f_k(x,y)
$$

CAM = 一种“被动产生”的空间注意力

- attention **不是**“可学习模块”
- 只能用于特定结构（必须 GAP）
- 是事后解释，不参与决策

## 软注意力（Soft Attention）

符号定义：

- 最后一层卷积特征图 $\mathbf{F} \in \mathbb{R}^{C \times H \times W}$，其中 $C$ 是通道数，$H$ 是高度，$W$ 是宽度
- $\mathbf{F}=\{\mathbf{a}_1, \mathbf{a}_2, \ldots, \mathbf{a}_N\} \in \mathbb{R}^{C}$：特征图展平成$N=H \times W$个$C$维向量的集合。$\mathbf{a}_i$ 表示第 $i$ 个空间位置的特征向量。
- $t$ 下标，表示时间步解码（生成文本）的时间步。当我们生成了第 t 个单词时，模型需要决定“现在该看图像的哪个部分”。
- $\mathbf{h}_{t-1} \in \mathbb{R}^{d}$：解码器上一时间步的隐藏状态向量，$d$ 是隐藏状态的维度。它代表了模型在生成当前词之前，已经“读过”了哪些文本信息。
- $e_{t,i}$：在第 $t$ 步，模型对第 $i$ 个图像区域的 **注意力得分**（Attention Score），也叫 **对齐得分**（Alignment Score）。这个值衡量了“当前要写第 $t$ 个词时，第 $i$ 个图像区域有多重要”。
- $\alpha_{t,i}$：在第 $t$ 步，模型对第 $i$ 个图像区域的**注意力权重**（Attention Weight），是对注意力得分 $e_{t,i}$ 进行归一化后的结果。是一个**概率值**，它表示了“当前要写第 $t$ 个词时，第 $i$ 个图像区域被关注的程度”。
- $\mathbf{z}_t \in \mathbb{R}^{C}$：在第 $t$ 步，模型根据注意力权重 $\alpha_{t,i}$ 对图像特征进行加权求和得到的 **上下文向量**（Context Vector）。它是对图像信息的“压缩表示”，用于辅助生成当前词。

## 软注意力的前向传播流程

### 1. 计算注意力得分（Alignment Score）

打分由当前时间步的解码器隐藏状态 $\mathbf{h}_{t-1}$ 和图像特征向量 $\mathbf{a}_i$ 共同决定。

$$
e_{t,i} = f_{\text{score}}(\mathbf{h}_{t-1}, \mathbf{a}_i)
$$

常见形式：

$$
e_{t,i} = \mathbf{v}^T \tanh(\mathbf{W}_h \mathbf{h}_{t-1} + \mathbf{W}_a \mathbf{a}_i + \mathbf{b})
$$

### 2. 计算注意力权重（Attention Weight）

这一步对注意力得分 $e_{t,i}$ 进行归一化，得到每个图像区域(空间位置i对应的特征向量)的注意力权重 $\alpha_{t,i}$：

$$
\alpha_{t,i} = \frac{\exp(e_{t,i})}{\sum_{j=1}^{N} \exp(e_{t,j})}
$$

### 3. 计算上下文向量（Context Vector）

对所有图像区域的特征向量 $\mathbf{a}_i$ 按照注意力权重 $\alpha_{t,i}$ 进行加权求和，得到上下文向量 $\mathbf{z}_t$：

$$
\mathbf{z}_t = \sum_{i=1}^{N} \alpha_{t,i} \mathbf{a}_i
$$

### 4. 将上下文向量与解码器隐藏状态结合

喂给解码器的输入通常是上下文向量 $\mathbf{z}_t$ 和解码器上一时间步的隐藏状态 $\mathbf{h}_{t-1}$ 的结合。常见的做法是将它们拼接或加权融合，然后输入到解码器中生成下一个词。

## 软注意力的反向传播

解码器的损失函数记作 $\mathcal{L}$，我们需要计算 $\dfrac{\partial \mathcal{L}}{\partial e_{t,i}}$ 和 $\dfrac{\partial \mathcal{L}}{\partial \mathbf{a}_i}$ 来更新注意力机制的参数。

计算 $\dfrac{\partial \mathcal{L}}{\partial \mathbf{z}_t}$：首先计算损失函数对上下文向量的梯度。

$$
\delta_{\mathbf{z}_t} = \frac{\partial \mathcal{L}}{\partial \mathbf{z}_t}
$$

### 梯度分流：传播到注意力权重

$$
\delta_{\alpha_{t,i}} =\frac{\partial \mathcal{L}}{\partial \alpha_{t,i}} =\frac{\partial \mathcal{L}}{\partial \mathbf{z}_t} \cdot \frac{\partial \mathbf{z}_t}{\partial \alpha_{t,i}} =  \delta_{\mathbf{z}_t}^T \cdot \mathbf{a}_i
$$

这是一个标量，表示如果把第 $i$ 个位置的注意力权重提高一点点，损失会如何变化

### 梯度分流：传播到图像特征向量

$$
\delta_{\mathbf{a}_i} = \frac{\partial \mathcal{L}}{\partial \mathbf{a}_i} = \frac{\partial \mathcal{L}}{\partial \mathbf{z}_t} \cdot \frac{\partial \mathbf{z}_t}{\partial \mathbf{a}_i} = \delta_{\mathbf{z_t}} \cdot \alpha_{t,i}
$$

这是一个向量，对于第i个位置的图像特征向量 $\mathbf{a}_i$，注意力越大，梯度越大，模型学习更多

### 经过softmax: 从权重传播到注意力得分

$$
\delta_{e_{t,i}} = \frac{\partial \mathcal{L}}{\partial e_{t,i}} = \sum_{j=1}^{N} \frac{\partial \mathcal{L}}{\partial \alpha_{t,j}} \cdot \frac{\partial \alpha_{t,j}}{\partial e_{t,i}}= \sum_{j=1}^{N} \delta_{\alpha_{t,j}} \cdot \frac{\partial \alpha_{t,j}}{\partial e_{t,i}}
$$

softmax的梯度公式：

$$
\frac{\partial \alpha_{t,j}}{\partial e_{t,i}} = \alpha_{t,j} (\delta_{ij} - \alpha_{t,i})
$$

## vs 硬注意力（Hard Attention）

| 对比维度 | 软注意力（Soft Attention）                     | 硬注意力（Hard Attention）                            |
| -------- | ---------------------------------------------- | ----------------------------------------------------- |
| 选择方式 | 对 所有 位置加权平均（求期望）。               | 从分布中 随机采样 1 个或极少数位置（概率选点）。      |
| 数学性质 | 确定性（Deterministic），给定输入，输出固定。  | 随机性（Stochastic），每次运行可能关注不同位置。      |
| 是否可微 | 完全可微，可直接用标准反向传播。               | 不可微，需要引入强化学习（REINFORCE）或重参数化技巧。 |
| 训练难度 | 易于收敛，训练稳定。                           | 方差高，训练不稳定，需要额外技巧（如方差衰减）。      |
| 计算成本 | 计算量大（所有位置都要算加权和）。             | 计算量小（只处理选中的 1 个位置）。                   |
| 应用场景 | 主流的机器翻译、图像描述（Transformer、ViT）。 | 早期的视觉推理、目标检测中的区域提议。                |
