---
title: 复变函数：极限与连续
published: 2025-08-19
description: 复变函数的极限与连续,判定方法，相关定理
tags: [复变分析]
category: 复变函数
author: biscuit
draft: false
---
- [复变函数的定义](#复变函数的定义)
- [复变函数的极限](#复变函数的极限)
  - [极限的定义](#极限的定义)
  - [极限相关定理](#极限相关定理)
- [复变函数的连续性](#复变函数的连续性)
  - [连续定义](#连续定义)
  - [连续型相关定理](#连续型相关定理)

## 复变函数的定义

设E是复平面C上的一个点集，如果有一个对应法则f使得
$$\forall z=x+iy\in E, \exist \omega=u+iv\in C$$
和他对应，则$f$称为在$E$上确定的复变函数。
函数$f$表示一种对应关系，记作：
$$
f(z)\text{或者}z\mapsto f(z)
$$

- 在复平面上，每一个$\omega$的称为对应z的**象**，z称为对应的$\omega$的**原象**

- $f$是从$E\text{(x，y坐标系，z复平面)}$到$E^*  \text{(u，v坐标系，}\omega\text{复平面)}$的**映射**（不一定是双射，但一定是单射）

- 对于实变函数，其映射是从**实数集到实数集**；对于复变函数，其映射是从**复平面到复平面**。（理论上$\omega=f(z)$的图像应该是四维的$(x,y,u,v)$，为了描述方便引入两个平面）

$\omega$是$z$关于函数$f$的值，这几个记法等价：
$$
\begin{align*}
&\omega = f(z)\\
\Leftrightarrow &u+iv =f(x+iy)\\
\Leftrightarrow&\left\{\begin{matrix}
  u=u(x,y)\\v=v(x,y)
\end{matrix}
\right.\\[10bp]
\Leftrightarrow &f(z)=u(x,y)+iv(x,y)
\end{align*}
$$

事实上，任给一个复变函数，都确定了**两个**以x,y为变量的**实变二元函数**$u(x,y)$和$v(x,y)$，反之亦然。

$$
f(z)=f(x+iy)\Rightarrow u+iv\\[5bp]
$$

- 求出$u(x,y), v(x,y),$ 根据$x,y$在$z$复平面中的关系，消去$x,y$，得到$u,v$的数量关系，进而可以得到在$\omega$平面下的图形。
- 复变函数可以由两个实函数表示，它的极限与连续性自然也可以通过这两个实变量函数来刻画。

eg1:$x=C_1,$求$w=z^2$
:::note[solution]
$$
\begin{align*}
 w=z^2=x^2-y^2+2ixy\\
 u=x^2-y^2,v=2xy\\
 x=C_1,\text{消去}y\\
 y=\frac{v}{2C_1}\\
 \therefore u={C_1}^2-({\frac{v}{2C_1}})^2
\end{align*}
$$
图像是一个抛物线。
:::

eg2:$x^2-y^2=1,$求$w=\frac{1}{z}$
:::note[solution]
$$
z=re^{i\theta}，w=\rho e^{i\phi}\\
w=\frac{1}{z}=\frac{1}{r}e^{-i\theta}\Rightarrow\rho =\frac{1}{r},\phi=-\theta\\
\begin{cases}
  x=r\cos\theta\\
  y=r\sin\theta
\end{cases}\text{带入}\\
r^2\cdot\cos2\theta=1\\
\therefore \frac{1}{\rho^2}\cdot\cos{-2\phi}=1\\
\rho^2=\cos2\phi,\phi\in[0,2\pi]\\
$$
图像是一个双扭线
:::

## 复变函数的极限

### 极限的定义

类比实变函数的极限定义复变函数的极限：设函数$\omega=f(z)$在点$z_0$的**去心邻域**$0<|z-z_0|<\rho$内有定义。$\exist A$，对$\forall\epsilon>0$，相应存在正数$\delta=\delta(\epsilon)，（0<\delta<\rho）$，使得当$0<|z-z_0|<\delta$时有$|f(z)-A|<\epsilon$，称$A$为$f(z)$当$z$趋向于$z_0$时的极限，记作：
$$\lim_{z\to z_0}{f(z)}=A
$$
等价的形式化定义如下：
$$
\forall\epsilon>0， \exist\delta>0,0<|z-z_0|<\delta， \implies|f(z)-A|<\epsilon\\
\Leftrightarrow \lim_{z\to z_0}{f(z)}=A
$$

- 这个定义不依赖于复数的表示形式。

---

对于**直角坐标系**形式的复数：
$$
z = x + iy, \quad z_0 = x_0 + iy_0\\[5pt]
\lim_{z \to z_0} f(z) = A \iff \lim_{(x,y) \to (x_0,y_0)} f(x+iy) = A
$$
其含义是：  
$$
\forall \, \varepsilon > 0, \exists  \delta > 0,
0 < \sqrt{(x-x_0)^2+(y-y_0)^2} < \delta\\
\implies |f(x+iy) - A| < \varepsilon
$$  

---
对于**极坐标**形式的复数

$$
z - z_0 = r e^{i\theta}, \quad r > 0, \, \theta \in [0,2\pi)\\[5bp]
\lim_{z \to z_0} f(z) = A\iff \lim_{r\to0^+}f(z_0 + r e^{i\theta})=A
$$  

其含义是：
$$
\forall \, \varepsilon > 0, \, \exists \, \delta > 0, 0 < r < \delta \\
\implies |f(z_0 + r e^{i\theta}) - A| < \varepsilon
$$  
并且要求极限值 **与角度 $\theta$ 无关**。

---

- 与实变函数不同的是，复平面内 $z\to z_0$ 可以从无穷多方向趋近，因此极限必须**与路径无关**，否则极限不存在。
  
- 和实变函数一样，极限研究的是某一点**附近**（去心邻域）的变化情况，和**该点取值无关**。研究该点取值的是函数的**连续性**

### 极限相关定理

1. **唯一性**：极限若存在则唯一
2. **实部虚部判定存在性**：极限存在的**充要**条件：$z_0=x+iy，A=a+ib，f(z)=u(x,y)+iv(x,y)$则
   $$
   \lim_{z\to z_0}{f(z)}=A\iff \lim_{(x,y)\to (x_0,y_0)}u(x,y)=a,\;\lim_{(x,y)\to (x_0,y_0)}v(x,y)=b
   $$
   复变函数的极限由两个实变函数的极限确定，反之亦然。
3. 复变函数极限的四则运算：与实变函数完全相同

**例题**：

---
设 $f(z) = \frac{z}{\bar z}$，讨论 $\lim_{z \to 0} f(z)$。

>取 $z = x + iy$，则
>$$
>f(z) = \frac{x+iy}{x-iy}
>$$
>
>- 当沿实轴趋近时：$y=0$，得
>
>$$
>f(x) = \frac{x}{x} = 1 \quad (x \to 0)
>$$
>
>- 当沿虚轴趋近时：$x=0$，得
>
>$$
>f(iy) = \frac{iy}{-iy} = -1 \quad (y \to 0)
>$$
>两条路径极限不一致，故极限 **不存在**。  
>or:取$z=0+re^{i\theta}$
>$$
>f(z)=\frac{re^{i\theta}}{re^{-i\theta}}\\[5bp]
>=e^{2i\theta}
>$$
>取值与$\theta$有关，极限不存在。  
---

## 复变函数的连续性

### 连续定义

**某点处连续**：如果$\lim_{z\to z_0}{f(z)}=A=f(z_0)$，那么$f(z)$在$z_0$点**连续**

**推广**：
若 $f(z)$ 在集合 $E$ 的每一点都连续，则称 $f(z)$ 在 $E$ 上连续。
特殊地，当 $E$ 为一条曲线、一个区域或整个复平面时，可分别称为“在曲线上连续”“在区域上连续”“整函数”等。

**沿曲线C连续**如果$\forall z_0\lim_{z\overset{by\,C}{\to} z_0}{f(z)}=A=f(z_0),z_0\in C$，那么$f(z)$在沿曲线$C$连续。

- 如果$f(z)$在曲线$C$上每一点都连续，则称$f(z)$在曲线$C$上连续，**反之不一定**

- **沿曲线C连续**不代表**曲线C上**处处连续，沿曲线C连续只是说C上的点**沿C的方向**是连续的，而曲线C上处处连续要考虑**曲线外的方向**

### 连续型相关定理

1. **连续性判定**： $z_0=x_0+iy_0,f(z)=u(x,y)+iv(x,y),f(z)$在$z_0$点连续的**充分必要**条件是$u(x,y),v(x,y)$在$(x_0,y_0)$均连续
  
2. **四则运算保持连续性**：如果$f(z)$和$g(z)$在$z_0$点均连续，那么
   1. $f(z)\pm g(z)$
   2. $f(z)\cdot g(z)$
   3. $\frac{f(z)}{g(z)}(g(z)\neq0)$  
   均在$z_0$点均连续
   - 上述定理可以判定复多项式和分式函数的连续性
3. **复合保持连续性**：$h=g(z)$在$z_0$处连续，$\omega=f(h)$在$h=h_0=g(z_0)$时连续，那么复合函数$\omega=f(g(z))$在$z_0$处连续
   - 本质上是实部虚部二元函数复合后保持连续性

4. **模有界性**：若$f(z)$在有界闭区域$D$内连续，则 $|f(z)|$ 在 $D$ 内必有界，且**能取到最大值和最小值**。

$$
\exist M>0,\forall z\in D,|f(z)|\leq M
$$

- 这个本质上是两个连续实函数的有界性导致的

---
**例题**
$f(z)=\frac{\bar{z}}{z}$在z=0处不连续

:::tip[solution]
$$
f(z)=\frac{\bar{z}}{z}=\frac{x-iy}{x+iy}\\
$$

- $y=0,x\to 0$

$$
lim_{z\to0}f(z)=\frac{x}{x}=1
$$

- $x=0,y\to 0$

$$
lim_{z\to0}f(z)=\frac{-iy}{iy}=-1
$$
沿不同曲线趋近 0 得到不同值。

:::

eg2 复数的辐角函数$\arg z$在原点以及复实轴上不连续

:::note[solution]
$$
\lim_{z\to 0}\arg z \,doesn't \;exist\\
y=0,x<0,\forall x_0<0\\
\lim_{(x,y)\to(x_0,0)}\arg z=\lim_{x\to x_0,y\yo 0}\arg z\\
if \lim_{x\to x_0,y\yo 0^+}\arg z=\pi\\
if \lim_{x\to x_0,y\yo 0^-}\arg z=-\pi\\
obviously,not\, continuous
$$
:::
