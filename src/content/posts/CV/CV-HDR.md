---
title: HDR-动态范围与高动态范围成像
published: 2026-06-08
description: ''
image: ''
tags: []
category: '计算机视觉'
order: 8
draft: false 
lang: ''
---

## 动态范围 (Dynamic Range)

$$
DR=20\log_2\left(\frac{I_{max}}{I_{min}}\right)
$$

单位：dB

图像灰度级：

- 8位图像：$I_{max}=255$, $I_{min}=1$, $DR=20\log_2(256)=48dB$
- 16位图像：$I_{max}=65535$, $I_{min}=1$, $DR=20\log_2(65536)=96dB$

图像层次：灰度级的数量

灰度级决定了 **动态范围的量化精度**
