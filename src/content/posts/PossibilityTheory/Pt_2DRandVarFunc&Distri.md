---
title: 二维随机变量函数的分布
published: 2025-08-17
description: '二维随机变量函数的分布'
tags: [随机变量函数]
category: '概率论'
author: biscuit
draft: false
---

## 离散型随机变量函数的分布

设离散型随机变量 $(X,Y)$ 的分布列为 $P(X=x_i,Y=y_j)=p_{ij}$,$Z=g(X,Y)$ 是一维离散型随机变量，用 $z_k=g(x_i,y_j)$ 表示 $Z$ 的取值，则Z的分布列
$$
P(Z=z_k)=\sum_{g(X,Y)=z_k}P(X=x_i,Y=y_j)
$$

eg:$(X,Y)$ 分布列

|X\Y|0|1|2|
|---|---|---|---|
|-1|0.1|0.15|0.2|
|1|0.15|0.1|0.3|

$Z=2X+Y$ Z=-2,-1,0,2,3,4

|Z|-2|-1|0|2|3|4|
|---|---|---|---|---|---|
|P|0.1|0.12|0.2|0.15|0.1|0.3|

eg2：$X\sim P(\lambda_1),Y\sim P(\lambda_2),Z=X+Y$

$$
P(X=i)=\frac{\lambda_1^i}{i!}e^{-\lambda_1},P(Y=j)=\frac{\lambda_2^j}{j!}e^{-\lambda_2}\\
Z=0,1,2,3...\\
P(Z=k)=P(X+Y=K)\\
=P(\underset{i=0}{\cup}(X=i,Y=k-i))\\
=\sum_{i=0}^k P(X=i,Y=k-i)\\
$$
根据独立性，可以写成两个概率之积

$$
=\sum_{i=0}^kP(X=i)P(Y=k-i)\\
=\frac{\lambda_1^i}{i!}e^{-\lambda_1}\cdot\frac{\lambd_2^{k-i}}{(k-i)!}e^{-\lambda_2}\\
=\frac{(\lambda_1+\lambda_2)^k}{k!}e^{-(\lambda_1+\lambda_2)}
$$

:::tip
再生性：同类型的随机变量，在独立的情况下，其联合分布依然是该类型，并且参数为各自参数之和
:::