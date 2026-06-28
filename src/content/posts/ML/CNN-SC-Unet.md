---
title: 卷积神经网络：跨层连接-U-Net
published: 2026-06-22
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 23
draft: false 
lang: ''
---

## U-Net 结构简介

U-Net之所以叫U-Net，是因为它的结构图酷似一个大写的“U”，由完全对称的两半组成：

![alt text](image-12.png)

### 左侧：编码器Encoder（收缩路径 / 下采样）

功能：捕获上下文语义（即“全局视野”），提取高层次特征。

操作：对于每一层：Conv → ReLU → Conv → ReLU → Pooling 重复堆叠 两次 3×3 卷积（+ReLU），然后接一个 2×2 最大池化（步长为2） 进行下采样。

变化：H×W↓，但 C↑。空间变小 → 通道变多

通道数就是特征维度，可以把通道数的增加理解为：通过更多的卷积核提取更多不同类型的特征。

### 右侧：解码器Decoder（扩张路径 / 上采样）

功能：恢复空间位置信息（即“精细定位”），将粗粒度的特征图还原到原始输入尺寸。

操作：对于每一层：UpSampling / Transposed Conv → Conv → Conv 先对特征图进行 2×2 反卷积（转置卷积），使特征图尺寸翻倍、通道数减半。然后将上采样得到的特征图，与左侧编码器对应层的特征图进行 **串联/拼接**（Concatenation）。特征图通道数叠加（例如 256通道 + 256通道 = 512通道）。

- 左右之间有很多“横桥”（skip connection）
- 连接的作用：将Encoder中对应层的特征图直接传递给Decoder，进行拼接
