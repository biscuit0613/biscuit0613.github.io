---
title: RM_solvePnP
published: 2025-10-09
description: ''
image: ''
tags: [计算机视觉,solvePnP]
category: 'RM'
draft: false 
lang: ''
---

## solvePnP函数介绍

在计算机视觉中，`solvePnP`函数用于解决**位姿估计问题**，即通过已知的3D点和其对应的2D图像点来估计相机的旋转和平移向量。也可以用来反推物体在相机坐标系下的位置。

### 数学原理

`solvePnP`函数基于**透视投影模型**，假设相机可以通过一个投影矩阵将3D点投影到2D图像平面上。给定一组已知的3D点（物体坐标系下）和对应的2D图像点（像素坐标系下），以及相机的内参矩阵和畸变系数，`solvePnP`函数通过最小化重投影误差来估计相机的旋转向量`rvec`和平移向量`tvec`。

### 函数原型

```cpp
bool cv::solvePnP(
    InputArray objectPoints,
    InputArray imagePoints,
    InputArray cameraMatrix,
    InputArray distCoeffs,
    OutputArray rvec,
    OutputArray tvec,
    bool useExtrinsicGuess = false,
    int flags = SOLVEPNP_ITERATIVE
);
```

### 参数说明

- `objectPoints`：输入的3D点坐标，通常为一个Nx3的矩阵，表示N个3D点的(x, y, z)坐标。
- `imagePoints`：输入的2D图像点坐标，通常为一个Nx2的矩阵，表示N个2D点的(u, v)坐标。
- `cameraMatrix`：相机内参矩阵，通常为一个3x3的矩阵，包含焦距和主点坐标。
- `distCoeffs`：相机的畸变系数，通常为一个1x5或1x8的矩阵，表示径向和切向畸变参数。
- `rvec`：输出的旋转向量，表示相机的旋转。
- `tvec`：输出的平移向量，表示相机的平移。
- `useExtrinsicGuess`：布尔值，表示是否使用初始的外参猜测。
- `flags`：用于选择不同的求解方法，如`SOLVEPNP_ITERATIVE`、`SOLVEPNP_P3P`等。

### 不同的求解方法

- `SOLVEPNP_ITERATIVE`：迭代法，适用于大多数情况，精度较高。
- `SOLVEPNP_P3P`：适用于仅有3个点的情况，计算速度快，但对噪声敏感。
- `SOLVEPNP_AP3P`：适用于4个点的情况，计算速度较快。
- `SOLVEPNP_EPNP`：高效的PnP算法，适用于大量点的情况。
- `SOLVEPNP_DLS`：基于直接线性变换的方法，适用于少量点。
- `SOLVEPNP_UPNP`：无约束的PnP算法，适用于任意数量的点。