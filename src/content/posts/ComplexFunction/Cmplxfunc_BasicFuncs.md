---
title: 复变函数：初等函数
published: 2025-08-19
description: '初等函数：幂指对三角以及他们的简单性质'
tags: [复变函数]
category: '复变函数'
author: biscuit
draft: false
---
## 指数函数

指数函数从实数集拓展到复数集的过程应满足同态，
$$
e^x\cdot e^y=e^{x+y}
$$
寻找满足这条关系的，性质尽可能好的函数，作为“指数”这个概念合理的外延。

### 指数函数定义

对于$z=x+iy$，称函数$f(z)=e^x(\cos y+i\sin y)$为复变数z的指数函数，记作$exp z$

根据欧拉公式
$$
e^{ix}=\cos x+i\sin x
$$
有
$$
e^z=e^{x+iy}=e^x\cdot e^{iy}=e^x(\cos y+i\sin y)
$$

:::tip
如果对z进行任意分解，$z=z_1+z_2,z_j=x_j+iy_j$
$$
\begin{align*}
e^z=e^{z_1+z_2}&=e^{x_1+x_2}(\cos(y_1+y_2)+i\sin(y_1+y_2))\\
&=e^{x_1+x_2}(\cos y_1\cos y_2-\sin y_1\sin y_2+i(\sin y_1\cos y_2-\cos y_1\sin y_2))\\
&=e^{x_1+x_2}(\cos y_1+i\sin y_1)(\cos y_2+i\sin y_2)\\
&=e^{z_1}\cdot e^{z_2}
\end{align*}
$$
显然这个定义满足指数运算的同态。
:::

+ 这里的z不再具有实函数中“幂”的意义，只作为expz的简写

### 指数函数的性质

1. $\forall z\in C,e^z\neq 0$

2. $e^z$在整个复平面$C$上**解析**且在$C$上无穷次可导，导数不变$\frac{de^z}{dz}=e^z$

3. 满足同态式$e^{z_1+z_2}=e^{z_1}\cdot e^{z_2}$

4. $e^z$是以$2k\pi i$为周期的**周期函数**  
   + $e^{2k\pi i}=1$
5. 辐角函数$arg(e^z)=y+2k\pi$

## 对数函数

### 对数函数定义

$\forall z\neq 0$，满足方程$e^\omega =z$的函数$\omega=f(z)$称为复变数z的对数函数，记作$\omega=Ln z$

令$\omega=u+iv$
$$
z=e^{u+iv}=e^u\cdot e^{iv}\\
\Leftrightarrow|z|=e^u;Argz= v\\
\therefore Ln z=\ln|z|+iArgz
$$
由于$Argz$是多值函数，$Ln z$也是多值函数，每两个值相差$2k\pi$的整数倍

### 对数函数的主值

$z$的辐角取主值$argz$时$Ln z$的取值称为$Ln z$ 的**主值**。记作：
$$
\ln z=\ln|z|+iargz
$$
其余值称为**分支**

+ 复变函数中，负数可以取对数
+ 当$z=x>0$时，$\ln z=\ln |z|+iargz=\ln x；\\Ln z=\ln z+2k\pi=\ln x+2k\pi$回到了正实数的对数函数。发现正实数的对数函数也是无穷多值的。

### 对数函数的性质

1. 运算性质：
   $$
    \ln z_1z_2=\ln z_1+\ln z_2\\[5bp]
    \ln {\frac{z_1}{z_2}}=\ln z_1-\ln z_2\\[5bp]
    \text{但是
   $\ln z^n=n\ln z$不再成立}
   $$
2. 连续性（对于主值，辐角$(-\pi,\pi]$，对于每一个支，辐角$(-\pi+2k\pi,\pi+2k\pi]$）
   $\ln z=\ln|z|+iargz$，在**去除原点和负实轴**的平面内连续(对数函数的连续性取决于辐角函数)

3. 解析性（对于主值，辐角$(-\pi,\pi]$，对于每一个支，辐角$(-\pi+2k\pi,\pi+2k\pi]$）
   $\ln z=\ln|z|+iargz$，$\omega=\ln z$是$e^z$的反函数，结合反函数求导法则，$\ln z$**去除原点和负实轴**的平面内解析，且
   $$
   \frac{d\ Ln z}{dz}=\frac{d\ln z}{dz}=\frac{1}{\frac{de^\omega}{d\omega}}=\frac{1}{e^\omega}=\frac{1}{z}
   $$

+ 2,3对于其分支亦成立。

## 幂函数

### 复数的幂乘

类比实数
$$
a^b=e^{b\ln a}
$$
在复数里规定幂乘：
$$
\begin{align*}
a^b=e^{b\ Ln a}&=e^{b[\ln|a|+i(\arg a+2k\pi )]}\\[5bp]
&=e^{b\ln|a|+ib\arg a+ib2k\pi}\\[5bp]
&=e^{b\ln a}e^{ib2k\pi}
\end{align*}
$$
当b为任意整数时，$b2k\pi$为$2k\pi$的整数倍，$a^b$为单值。

当$b=\frac{p}{q}\ (p,q$互质)时，$k$可以取$0,1,2,3,...q-1,a^b$总共有$q$个取值。

对于其他情况，有无穷多值。

e.g.求$i^i$
$$
i^i=e^{i\ Lni}=e^{i[\ln|i|+i(\arg i+2k\pi )]}\\
=e^{-(\pi /2+2k\pi )]}\\
$$

### 幂函数的定义

形如$z^b=e^{b\ Ln z},z\neq0,b$为任意复常数的函数称为幂函数
$$
z^b=e^{b\ Ln z}=e^{b(\ln |z|+i(\arg z+2k\pi))}\\[5bp]
=e^{b\ln|z|}\cdot [\cos b(\arg z+2k\pi)+i\cos b(\arg z+2k\pi)]
$$

当 $Argz=\arg z\in(-\pi,\pi]$ 时，类比对数函数，得到主值幂函数，其余值成为分支

### 幂函数的性质

1. 四则运算类比指数函数
2. 连续性和解析性：幂函数是由 $e^\omega$ （处处解析）和 $\omega=b\ Lnz$（去掉原点和负实轴解析）复合而成。所以幂函数在**去掉原点和负实轴**的平面内连续且解析
3. 求导：
   $$
   \begin{align*}
    (z^b)^\prime&= (e^{b\ Lnz})^\prime\\
    &=(e^{b\ Lnz})\cdot b\cdot\frac{1}{z}\\
    &=z^b\cdot b\cdot \frac{1}{z}\\
    &=bz^{b-1}
    \end{align*}
   $$

## 三角函数

### 复数三角函数的定义

由欧拉公式：
$$
\begin{align*}
  
\left\{\begin{matrix}
\begin{align*}
  e^{i\theta}=\cos \theta+i\sin \theta\\
  e^{-i\theta}=\cos \theta-i\sin \theta
\end{align*}
\end{matrix}
\right.\\
\Leftrightarrow
\left\{\begin{matrix}
\begin{align*}
 \cos\theta=\frac{e^{i\theta}+e^{-i\theta}}{2}\\[10bp]
 \sin\theta=\frac{e^{i\theta}-e^{-i\theta}}{2i}
\end{align*}
\end{matrix}
\right.\\
\end{align*}
$$
现将欧拉公式中的$\theta$推广到复数：
对任意复数z
$$
\left\{\begin{matrix}
\begin{align*}
 \cos z=\frac{e^{iz}+e^{-iz}}{2}\\[10bp]
 \sin z=\frac{e^{iz}-e^{-iz}}{2i}
\end{align*}
\end{matrix}
\right.\\
$$
称为z的正弦函数和余弦函数

### 复数三角函数的性质

1. $cos z$ 和$sinz$ 都是以$2\pi$为周期的函数

2. $\cos(-z)=\cos z$；$\sin(-z)=-\sin z$
3. $cos z$ 和$sinz$ 都是复平面内的解析函数（本质是指数函数相加减），且求导（用欧指数形式推导）：
   $$
   \begin{align*}
    (\cos z)^\prime&=-\sin z\\
   (\sin z)^\prime&= \cos z
   \end{align*}

   $$
4. $\cos ^2z+\sin^2z=1$
5. 两角和差公式和实变函数完全一致
6. **$|\cos z|\leq 1$,$|\sin z|\leq 1$在复数域内不成立**

### 双曲正弦和双曲余弦

推导过程：展开$\cos(x+iy)$和$\sin(x+iy)$。
$$
\begin{align*}
\cos z&=\cos(x+iy)\\
&=\cos x\cos iy-\sin x\sin iy\\
&=\cos x\cdot \frac{e^{-y}+e^y}{2}-\sin x\cdot \frac{e^{-y}-e^y}{2i}\\
&=\cos x\cdot \frac{e^y+e^{-y}}{2}+\sin x\cdot \frac{e^y-e^{-y}}{2}i\\
&=\cos x\cdot \ch y-i\sin x\sh y\\
\text{类似地}\\
\sin z&=\sin x\cdot \ch y+ i\cos x\sh y
\end{align*}\\
$$

## 反三角函数
