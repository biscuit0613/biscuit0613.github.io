---
title: 平滑空间滤波器
published: 2026-05-25
description: ''
image: ''
tags: []
category: '计算机视觉'
draft: false 
lang: ''
---

```mermaid
flowchart LR
    A["空间滤波器<br/>(Spatial filter)"]
    %% 平滑滤波
    subgraph S[" "]
        direction LR
        B["平滑滤波器<br/>(Smoothing spatial filter)"]
        C["线性滤波器<br/>(均值滤波器)"]
        D["非线性滤波器<br/>(中值滤波器)"]
        E["抑制噪声<br/>并保持边缘<br/>模糊掉小物体<br/><b>Blur (smooth)</b>"]
    end
    %% 锐化滤波
    subgraph T[" "]
        direction LR
        F["锐化滤波器<br/>(Sharpening spatial filter)"]
        G["基于二阶导数<br/>(Laplacian)"]
        H["基于一阶导数<br/>(梯度 gradient)"]
        I["强化图像细节<br/><b>deblur (sharpen)</b>"]
    end

    %% 主结构连接
    A --> B
    A --> F

    %% 平滑内部连接
    B --> C
    B --> D
    C --> E
    D --> E

    %% 锐化内部连接
    F --> G
    F --> H
    G --> I
    H --> I
```

分为线性滤波器（均值/加权滤波器）和非线性滤波器（中值/最大值/最小值/双边滤波器）

- 线性的权重是固定的，非线性的权重是动态的（根据像素值差异调整权重）

## 线性滤波器

- **均值滤波器（Mean filter）**：用邻域内像素的平均值替代中心像素，会出现方块状伪阴影。
- **加权滤波器（Weighted filter）**：给邻域内不同位置的像素分配不同的权重，然后计算加权平均值，可以实现更精细的滤波效果。

### 高斯滤波器

一个常见的加权滤波器是高斯滤波器（Gaussian filter），其权重由高斯函数定义：

$$
G(x,y,\sigma) = \dfrac{1}{2\pi\sigma^2} \exp{(-\dfrac{x^2 + y^2}{2\sigma^2})}
$$

$x,y$ 定义为相对于卷积核中心的偏移量，$\sigma$ 是高斯函数的标准差，控制权重的分布范围。

当用高斯核对图像做卷积时：

1. 将高斯核的中心对齐到图像当前像素 $(i,j)$。

2. 对于核上的每一个偏移位置 $(x,y)$，从图像中取出对应像素值 $I(i+x,j+y)$，具体正负需要约定（通常$x$ 向右为正，$y$ 向下为正）

3. 乘以核权重 $G(x,y)$，累加。

$$
g(i,j) = \sum_{x=-3\sigma}^{3\sigma} \sum_{y=-3\sigma}^{3\sigma} G(x,y,\sigma) \cdot I(i+x,j+y)
$$

![alt text](image-2.png)

性质：

- 核心参数 $\sigma$ 控制滤波器的平滑程度，$\sigma$ 越大，滤波效果越强。

- 属于低通滤波器，能有效滤除“高频”分量。

- 高斯核是可分离核：先进行一维横向高斯模糊，再进行一维纵向高斯模糊，计算复杂度从 $O(n^2)$ 降为 $O(n)$。
- 两次使用标准差为 $\sigma$ 的高斯核进行卷积，等价于使用一次标准差为 $\sqrt{2}\sigma$ 的高斯核进行卷积。
- 滤波器尺寸和 $\sigma$ 的关系：$kernel\ size \approx 6\sigma + 1$ 因为高斯分布在 $\pm 3\sigma$ 范围内包含了 99.7% 的能量。
- 有时候使用的权重是 $\frac{G(i,j)}{\sum_{i,j} G(i,j)}$ ， 归一化确保核的亮度不变性（平滑后平均亮度不变）。

基于sigma产生高斯核：

```rust

use std::f64::consts::PI;

/// 生成二维高斯核
/// - `size`: 核尺寸，必须是奇数（如 3, 5, 7）
/// - `sigma`: 高斯标准差 (σ)
/// 返回值：size x size 的二维浮点数组，已归一化（所有元素之和为 1）
fn gaussian_kernel(size: usize, sigma: f64) -> Vec<Vec<f64>> {
    assert!(size % 2 == 1, "核尺寸必须是奇数");
    let radius = (size / 2) as i32;
    let sigma2 = sigma * sigma;
    let denom = 2.0 * sigma2;
    let norm = 1.0 / (2.0 * PI * sigma2);
    
    let mut kernel = vec![vec![0.0; size]; size];
    let mut sum = 0.0;
    
    for i in 0..size {
        let x = (i as i32 - radius) as f64;
        for j in 0..size {
            let y = (j as i32 - radius) as f64;
            let value = norm * (-(x*x + y*y) / denom).exp();
            kernel[i][j] = value;
            sum += value;
        }
    }
    
    // 归一化，使所有权重之和为 1
    for row in &mut kernel {
        for val in row {
            *val /= sum;
        }
    }
    kernel
}

```

## 非线性滤波器

假设滤波器尺寸为 $k \times k,k=2a+1$，以中心像素为基准，定义邻域为 $[x-a, x+a] \times [y-a, y+a]$，其中 $a = \frac{k-1}{2}$。

- **中值滤波器（Median filter）**：用邻域内像素的中位数替代中心像素，能有效去除椒盐噪声，同时保持边缘。

$$
g(x,y) = \text{median}\{f(i,j) | (i,j) \in \text{邻域}\}
$$

- **最大值滤波器（Max filter）**：用邻域内像素的最大值替代中心像素，常用于突出亮区域。

$$
g(x,y) = \max\{f(i,j) | (i,j) \in \text{邻域}\}
$$

- **最小值滤波器（Min filter）**：用邻域内像素的最小值替代中心像素，常用于突出暗区域。

$$
g(x,y) = \min\{f(i,j) | (i,j) \in \text{邻域}\}
$$

### 双边滤波器（Bilateral filter）

高斯滤波只考虑“空间距离”，不考虑“像素值差异”，会模糊边缘

双边滤波只和“距离近 + 像素值相似”的点做加权平均

通过两个高斯函数分别对空间距离和像素值差异进行加权：

用 $i,j$ 表示像素的坐标，用 $f(i,j)$ 表示像素的灰度值，用 $k,l$ 表示核内部的偏移坐标：

Domain Kernel:
$$
d(k,l) = \exp{(-\dfrac{k^2 + l^2}{2\sigma_d^2})}
$$

Range Kernel:
$$
r(k,l) = \exp{(-\dfrac{(f(i,j)-f(i+k,j+l))^2}{2\sigma_r^2})}
$$

$$
g(i,j) = \dfrac{1}{W_p} \sum_{k,l} f(i+k,j+l) \cdot \underbrace{\exp{(-\dfrac{k^2 +l^2}{2\sigma_d^2})}}_{\text{空间距离权重}w_d(x,y,k,l)} \cdot \underbrace{\exp{(-\dfrac{(f(i,j)-f(i+k,j+l))^2}{2\sigma_r^2})}}_{\text{像素值差异权重}w_r(f(x,y), f(i+k,j+l))}
$$

其中 $W_p$ 是归一化因子，$\sigma_d$ 控制空间距离的权重，$\sigma_r$ 控制像素值差异的权重。

- $\sigma_d$ 控制模糊的范围，越大，越多邻域像素参与计算，平滑的范围越广；
- $\sigma_r$ 控制对灰度差异的敏感度，越大，越多像素值差异较大的像素参与计算。

每个像素都要重新计算权重，不能用卷积优化
