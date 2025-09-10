---
title: 复变函数导数可微解析的例题
published: 2025-09-08
description: ''
image: ''
tags: [复变函数，例题]
category: '复变函数'
draft: false 
lang: ''
---

## 柯西黎曼条件的应用：

### eg1

若$f(z)=x^2+axy+by^2+i(cx^2+dxy+y^2)$在整个复平面内都可导，求参数abcd
:::tip[solution]

:::

### eg2:求共轭调和函数

若$u=x^2+xy-y^2,f(i)=-1+i,f(z)$解析，求$f(z)=u+iv$
:::tip[solution]
>考虑用多种方法做，法一是直接用算u的共轭调和函数，法二是通过表示f的导数（用实部虚部函数偏导的形式），法三（并不算一个单独的方法，凑微分这一块）。
:::

### eg3：典型的根据定义判定解析

 e.g.$f(z)=\overline{z}\cdot z^2$这个函数在z=0处的解析性
:::tip[solution]
$$
f(z)=(x^2+y^2)(x+iy)\\
\text{在$z=0$处}\\[5bp]
\lim_{z\to 0}{\frac{(x^2+y^2)(x+iy)-0}{(x+iy)-0}}=0\\[5bp]
\text{在$z\neq 0$处}\\[5bp]
\lim_{\Delta z\to 0}{\frac{[(x+\Delta x)^2+(y+\Delta y)^2](x+\Delta x+i(y+\Delta y))-(x^2+y^2)(x+iy)}{\Delta z}}\\[5bp]
=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{(\Delta x^2+\Delta y^2+2x\Delta x+2y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+\Delta x^2 +2x\Delta x+y^2+\Delta y^2 +2y\Delta y}\\[5bp]
=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{(\Delta x^2+\Delta y^2)(x+iy)}{\Delta x+i\Delta y}+\frac{2(x\Delta x+y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+ y^2 }\text{第一坨高阶无穷小在上为0}\\[5bp]
=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{2(x\Delta x+y\Delta y)(x+iy)}{\Delta x+i\Delta y}+x^2+ y^2 }\\[5bp]
=\lim_{\Delta x\to 0,\Delta y\to 0}{\frac{2(2xy\Delta x\Delta y+x^2\Delta x^2+y^2\Delta y^2-i(\Delta x\Delta y(x^2-y^2)+xy(\Delta y^2-\Delta x^2)))}{\Delta x^2-\Delta y^2}+x^2+ y^2 }\text{肉眼可见和xy有关}
$$
在z=0邻域内不可导，也就不解析

:::
