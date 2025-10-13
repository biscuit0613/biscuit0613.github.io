---
title: 复变函数：级数
published: 2025-09-02
description: '复变函数的级数基础知识，幂级数的收敛半径与和函数的分析续性质，泰勒级数，洛朗级数'
image: ''
tags: [复变函数, 级数]
category: '复变函数'
draft: false 
lang: ''
---
## 复变函数级数的基本概念

:::note
复变函数的级数可以以由实变函数直接推广而来,因此与实变函数有相似的定理和结论
:::

### 复数列的极限

复数列{ $z_n=a_n+ib_n$ }的极限：复数列收敛到某个复数 $z=a+bi$ ，记作
$$
\lim_{n\to\infin}z_n=a+bi
$$
形式化定义为：
$$
\forall \epsilon>0,\exist N\in\mathbb{N},when\;n>N,|z_n-z|<\epsilon
$$

+ 复数列极限存在则唯一
+ 复数列的极限满足实数列极限的四则运算
+ 复数列收敛判定定理：复数列收敛当且仅当它的实部和虚部分别收敛。$z_n=x_n+iy_n,\lim_{n\to\infin}z_n=a+bi\iff\lim_{n\to\infin}x_n=a,\lim_{n\to\infin}y_n=b$

### 复级数及其部分和，敛散性

复级数： $\sum_{k=1}^{\infin}z_k=z_1+z_2+z_3+\ldots$

部分和：与实级数一样，复级数的关键在于**部分和列** $S_n=\sum_{k=1}^{n}z_k$

复级数收敛与发散的定义：复级数 $\sum z_n$ 收敛 $\iff\lim_{n\to\infin}S_n=S$ 。也就是说，如果复级数的**部分和**{$S_n$}收敛到某复数S（部分和数列的极限存在），则称复级数收敛到S。否则发散

## 复级数收敛的判定与性质

### 收敛的充要条件

充要条件1（**部分和**）：复级数 $\sum_{k=1}^{\infin}z_k$ 收敛 $\iff S_n=\sum_{k=1}^{n}z_k$存在极限。

充要条件2（**实虚部级数**）：复级数 $\sum_{k=1}^{\infin}z_k$ 收敛 $\iff\sum_{k=1}^{\infin}x_k\,,\sum_{k=1}^{\infin}y_k$ 均收敛。

充要条件3（**柯西收敛准则**）：复级数 $\sum_{k=1}^{\infin}z_k$ 收敛 $\iff\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,\;\forall p\geq 1,|S_{n+p}-S_n|<\varepsilon\text{或}|z_{n+p}-z_n|<\varepsilon$，满足柯西收敛准则的数列称为**柯西列**。

+ 由充要条件2可推出充要条件1：$S=S^\prime+iS^{\prime\prime}$，其中 $S^\prime$ ,$S^{\prime\prime}$ 分别为实部虚部级数的部分和极限。
+ 充要条件3在复函数项级数中也成立

:::note[柯西收敛准则的证明]

先证必要性：
$$
\begin{align*}
&\text{设}\sum_{k=1}^\infty z_k\text{收敛于}S\\
&\iff\forall\varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,|S_n-S|<\frac{\varepsilon}{2}\dotsb(1)\\
&\forall p\geq 1\\
&|S_{n+p}-S|<\frac{\varepsilon}{2}\dotsb(2)\\
&\therefore|S_{n+p}-S_n|\\
&=|S_{n+p}-S+S-S_n|\\
&<|S_{n+p}-S|+|S-S_n|\\
&<\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon
\end{align*}
$$
再证充分性：

设数列 $\{a_n\}$ 是一个柯西列，即：

$$
\forall \varepsilon > 0,\; \exists N,\; \text{使得当 } m,n > N \text{ 时，} |a_m - a_n| < \varepsilon\\

\therefore - \varepsilon < a_m - a_n < \varepsilon \Rightarrow a_n - \varepsilon < a_m < a_n + \varepsilon\\
$$

由于 $n$ 是大于 $N$ 的任意正整数，是一个定值，所以对任意固定的 $n_0$，都有：
$$
a_n - \varepsilon < a_{n_0} < a_n + \varepsilon
$$

说明 $\{a_n\}$ 有上界和下界 ⇒ 是**有界数列**。

又因为 $\{a_n\}$ 是柯西列 ⇒ 有界 ⇒ 根据**Bolzano-Weierstrass定理**，它存在一个收敛子列。

设收敛子列为 $\{a_{n_k}\}$，其极限为 $a$，则：

$$
\forall \varepsilon > 0,\; \exists N_1,\; \text{使得当 } k > N_1 \text{ 时，} |a_{n_k} - a| < \varepsilon/2\dotsb(1)
$$

又因为原列是柯西列，存在 $N_2$，使得当 $m,n > N_2$ 时：

$$
|a_m - a_n| < \varepsilon/2\dotsb(2)
$$

令 $N = \max\{N_1, N_2\}$，当 $n > N$ 时，取 $m = n_k > N$，则有：

$$
|a_n - a| = |a_n - a_m + a_m - a| \leq |a_n - a_m| + |a_m - a| < \varepsilon/2 + \varepsilon/2 = \varepsilon
$$

因此：

$$
\forall \varepsilon > 0,\; \exists N,\; \text{使得当 } n > N \text{ 时，} |a_n - a| < \varepsilon
$$

即：

$$
\lim_{n \to \infty} a_n = a
$$

:::

### 收敛的必要条件

复级数 $\sum_{k=1}^{\infin}z_k$ 收敛 $\Rightarrow\lim_{n\to\infin}z_n=0$

:::warning

和实级数一样，只是必要条件，典型反例是调和级数 $\sum\frac{1}{n}$

:::

### 绝对收敛与条件收敛

复级数的绝对收敛就是取模然后判断敛散性，转化为实数级数。(和实数项级数差不多，但注意复数的条件收敛对项的排列顺序敏感)

绝对收敛：若复级数 $\sum_{n=1}^{\infin}z_n=\sum_{n=1}^{\infin}a_n+ib_n$ 满足 $\sum_{n=1}^{\infin}|z_n|$ 收敛，则称该级数绝对收敛，并且有

$$
\sum_{n=1}^{\infin}|z_n|\text{收敛}\iff\sum_{n=1}^{\infin}|a_n|\text{和}\sum_{n=1}^{\infin}|b_n|\text{均收敛}\iff\sum_{n=1}^{\infin}z_n\text{收敛}
$$

:::note[证明]

利用柯西收敛准则
$$
\begin{align*}
&\text{令}\tilde{S}=\sum_{n=1}^\infty|z_n|\,,\sum_{n=1}^\infty|z_n|\text{收敛}\\
&\iff\forall\varepsilon>0,\exist N,\;s.t.\;n,m>N,\;|\tilde{S_m}-\tilde{S_n}|<\varepsilon\\
&\iff\sum_{k=n}^m|z_k|<\varepsilon\dotsb(1)\\
&\text{令}S＝\sum_{n=1}^\infty z_n\,,\sum_{n=1}^\infty z_n\text{收敛}\\
&\iff\forall\varepsilon>0,\exist N \,,s.t.\;\forall n,m>N,\;|S_m-S_n|<\varepsilon\\
&\iff|\sum_{k=n}^m z_k|<\varepsilon\dotsb(2)\\
&\text{根据复数模长的三角不等式：}(2)\leq(1)\\
\therefore&\sum_{n=1}^\infty|z_n|\text{收敛}\Rightarrow\sum_{n=1}^\infty z_n\text{收敛}
\end{align*}
$$
:::

### 敛散性判别法

:::warning

除了**柯西收敛准则**是**充分必要条件**，其他判别法都是**充分条件**

:::

复级数的敛散性判别法和实级数差不多，但此时是通过**取模** $|z_n|$ 转化成实级数来研究。

1. 比较判别法（充分条件）

    若 $|z_n|<a_n$ ,而 $\sum a_n$ 收敛，则 $z_n$ 绝对收敛。

2. 比值判别法（充分条件）

    若 $\lim_{n\to\infin}\frac{|z_{n+1}|}{|z_n|}$ 存在，记为$L$，则

    $$
    \lim_{n\to\infin}\frac{|z_{n+1}|}{|z_n|}=\begin{cases}
        L<1\;, z_n\text{绝对收敛}\\
        L>1\;,z_n\text{发散}\\
        L=1\;\text{无法判别}
    \end{cases}
    $$

3. 根植判别法（充分条件）

    若 $\lim_{n\to\infin}\sqrt[n]{|z_n|}$ 存在，记为$L$，则

    $$
    \lim_{n\to\infin}\sqrt[n]{|z_n|}=\begin{cases}
        L<1\;, z_n\text{绝对收敛}\\
        L>1\;,z_n\text{发散}\\
        L=1\;\text{无法判别}
    \end{cases}
    $$

4. Dirichlet 判别法 （充分条件）

    设有级数  $\sum_{n=1}^\infty a_n b_n,$  ，若满足以下条件：  
    $$
    \begin{align*}
        &1. \{a_n\}\text{单调趋于0}；\\
        &2. \{B_n\} = \left\{\sum_{k=1}^n b_k\right\} \text{有界}  
    \end{align*}
    $$
    则 $\sum a_n b_n$ 收敛。  

    :::tip[例子]  

    $\sum_{n=1}^\infty \frac{1}{n} e^{in\theta}, \quad \theta \not= 2k\pi.$  

    + $a_n = 1/n$，单调趋于 $0$；  
    + $b_n = e^{in\theta}$，它的部分和 $\sum_{k=1}^n e^{ik\theta}$ 是几何级数，和有界；  

    所以根据 Dirichlet 判别法，该级数收敛（条件收敛）。  
    :::

5. Abel 判别法（充分条件）

    设有级数  $\sum_{n=1}^\infty a_n b_n,$  ，若满足：  
    $$
    \begin{align*}
        &1. \sum a_n \text{收敛}\\
        &2. \{b_n\} \text{单调有界}\\
    \end{align*}
    $$
    则 $\sum a_n b_n$ 收敛。  

6. 柯西收敛准则（充要条件）

    设有级数 $\sum_{n=1}^\infty z_n,$  ，若满足：  

   $$
   \begin{align*}
   &\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\\
   &\forall n>N,\;\forall p\geq 1,\\
   &|S_{n+p}(z)-S_n(z)|<\varepsilon\;\text{或}\;|z_{n+p}-z_n|<\varepsilon
    \end{align*}
   $$

    则 $\sum z_n$ 收敛。并称之为**柯西列**。

:::tip

+ **Dirichlet 判别法**：要求 $a_n \to 0$ 且单调，$\sum b_n$ 的部分和有界。  
+ **Abel 判别法**：要求 $\sum a_n$ 收敛，$\{b_n\}$ 单调有界。
  + 它们常用于处理三角函数形式的复数级数，例如傅里叶级数、$\sum \frac{1}{n} e^{in\theta}$。
+ **柯西收敛准则**：核心在于寻找**柯西列**，柯西列可以选择部分和列，也可以选择原级数列，取决于具体问题。在复函数项级数中同样适用。

:::

:::warning
柯西判别法和柯西收敛准则不是一个东西。
:::

## 复函数项级数

### 复函数项级数的定义

设 $\{f_n(z)\}$ 是定义在某区域 $\mathbb{D}$ 上的一列复函数，则称 $\sum_{n=1}^\infty f_n(z)$ 为复函数项级数。

级数的部分和：$S_n(z)=\sum_{k=1}^n f_k(z)$

级数的**和函数**：若 $\forall z\in\mathbb{D},\lim_{n\to\infin}S_n(z)=S(z)$ 存在，则称 $S(z)$ 为级数的**和函数**，记作 $S(z)=\sum_{n=1}^\infty f_n(z)$ ，称为级数 $\sum_{n=1}^\infty f_n(z)$ 收敛于 $S(z)$ 。

### 复函数项级数的敛散性

**单点收敛** ：如果对于 $\mathbb{D}$ 中的**某一点** $z_0$ ,部分和 $\lim_{n\to\infty}S_n(z_0)=S(z_0)$ 极限存在，则称级数在 $\mathbb{D}$ 上 **单点收敛** ，也就是在点 $z_0$ 处收敛。

**逐点收敛** ：如果对于 $\mathbb{D}$ 中的**每一点** $z$ ,部分和 $\lim_{n\to\infty}S_n(z)=S(z)$ 极限均存在，则称级数在 $\mathbb{D}$ 上**逐点收敛** 。

上述逐点收敛的形式化定义如下：
$$
\forall z\in\mathbb{D},\;\forall \varepsilon>0,\exist N=N(\varepsilon,z)\\[4pt]
s.t.\;\forall n>N,\;|S_n(z)-S(z)|<\varepsilon
$$

+ 这里的 $N$ 依赖于 $\varepsilon$ 和 $z$ 。

### 一致收敛

复函数项级数的一致收敛：设有复函数项级数 $\sum_{n=1}^\infty f_n(z)$ ,其前 $n$ 项和记作 $S_n(z)$ ，如果存在一个复函数 $S(z)$ 满足：
$$
\forall \varepsilon>0,\;\exist N=N(\varepsilon)\\
s.t.\;\forall n>N,\;|S_n(z)-S(z)|<\varepsilon,\forall z\in\mathbb{D}
$$
则称级数 $S_n(z)$ 在区域 $\mathbb{D}$ 上一致收敛于 $S(z)$

+ 这里的 $N$ 只依赖于 $\varepsilon$ ，与 $z$ 无关。这是一致收敛与逐点收敛的区别。

### 一致收敛的判定

1. 柯西一致收敛准则：函数项级数 $\sum_{n=1}^\infty f_n(z)$ 在区域 $\mathbb{D}$ 上**一致收敛**的**充分必要条件**是 $\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,\;\forall p\geq 1,\;\forall z\in\mathbb{D}$
    $$
     |S_{n+p}(z)-S_n(z)|=\left| \sum_{k=n+1}^{n+p} f_k(z) \right| < \varepsilon
    $$
    :::tip[证明]

    充分性：设 $S_n(z)$ 在 $\mathbb{D}$ 上一致收敛于 $S(z)$ ,则
    $$
    \begin{align*}
    &\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,\;\forall z\in\mathbb{D}\\
    &|S_n(z)-S(z)|<\frac{\varepsilon}{2}\dotsb(1)\\
    &\forall p\geq 1\\
    &|S_{n+p}(z)-S(z)|<\frac{\varepsilon}{2}\dotsb(2)\\
    &|S_{n+p}(z)-S_n(z)| \\
    &=|S_{n+p}(z)-S(z)+S(z)-S_n(z)|\\
    &=|(2)-(1)|\\
    &\text{根据三角不等式：}\\
    &\leq|S_{n+p}(z)-S(z)|+|S_n(z)-S(z)|<\varepsilon  
    \end{align*}
    $$
    必要性：由定理假设：
    $$\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,\;\forall p\geq 1,\;\forall z\in\mathbb{D}\\
    |S_{n+p}(z)-S_n(z)|=\left| \sum_{k=n+1}^{n+p} f_k(z) \right| < \varepsilon
    $$
    由柯西判别法，部分和函数 $S_n(z)=\sum_{k=1}^n f_k(z)$ 构成柯西列，故存在一个函数 $S(z)$ 使得 $S_n(z)=\sum_{k=1}^n f_k(z)$ 收敛于 $S(z)$

    :::
2. Weierstrass判别法：如果存在一系列实数 $M_n$ 使得 $\forall z\in\mathbb{D},|f_n(z)|\leq M_n$ ，且 $\sum M_n$ 收敛，则 $\sum f_n(z)$ 在 $\mathbb{D}$ 上一致收敛。

   :::tip[证明]

    由 $\sum M_n$ 收敛，$\sum M_n$ 满足柯西判定定理(这里取部分和形式)，
    $$
    \begin{align*}
    &\forall \varepsilon>0,\;\exist N=N(\varepsilon),s.t.\;\forall n>N,\;\forall p\geq 1\\
    &|M_{n+1}+M_{n+2}+\dotsb+M_{n+p}|=|\sum_{k=n+1}^{n+p} M_k|<\varepsilon\\
    &\text{又由 $|f_n(z)|\leq M_n$ ,所以}\\
    &|\sum_{k=n+1}^{n+p} f_k(z)|\leq\sum_{k=n+1}^{n+p}|f_k(z)|\leq\sum_{k=n+1}^{n+p}M_k<\varepsilon\\[4pt]
    &\text{中间用了一步三角不等式}
    \end{align*}
    $$
    再由柯西一致收敛准则，$\sum f_n(z)$ 在 $\mathbb{D}$ 上一致收敛。
    :::

+ 柯西一致收敛准则其实是**柯西收敛准则**在复函数项级数上的推广，这里的柯西列取**部分和列**。
+ Weierstrass判别法是**比较判别法**在复函数项级数上的推广，比较的对象是实数级数。可以理解为**用一个收敛的实数级数去控制复函数项级数的每一项**，从而保证复函数项级数的一致收敛。

### 一致收敛的性质

1. 一致收敛与逐点收敛的关系：一致收敛 $\Rightarrow$ 逐点收敛，反之不成立
2. 一致收敛与连续性：如果 $\{f_n(z)\}$ 在 $\mathbb{D}$ 上连续，且 $\sum f_n(z)$ 在 $\mathbb{D}$ 上一致收敛于 $S(z)$ ，则其和函数 $S_n(z)$（也是 $S(z)$ ） 在 $\mathbb{D}$ 上连续
3. 一致收敛与积分：如果 $\{f_n(z)\}$ 在 $\mathbb{D}$ 上连续，且 $\sum f_n(z)$ 在 $\mathbb{D}$ 上一致收敛于 $S(z)$ ，则对 $\mathbb{D}$ 上的任意光滑曲线 $\gamma$ ，其和函数有
    $$
    \int_\gamma S(z)\,dz=\sum_{n=1}^\infty \int_\gamma f_n(z)\,dz
    $$
4. 一致收敛与解析：如果 $\{f_n(z)\}$ 在 $\mathbb{D}$ 上解析，且 $\sum f_n(z)$ 在 $\mathbb{D}$ 上一致收敛于 $S(z)$ ，则 $S(z)$ 在 $\mathbb{D}$ 上解析，且对 $\mathbb{D}$ 上的任意光滑曲线 $\gamma$ ，有
    $$
    S^{(m)}(z)=\sum_{n=1}^\infty f_n^{(m)}(z),\quad m=1,2,3,\ldots
    $$

简而言之，一致收敛可以保证**函数序列**与**和函数**的连续性、可积性、可微性（解析性）

## 幂级数

定义：形如 $\sum_{n=0}^{\infty}a_n(z-z_0)^n$ 的复函数项级数称为**幂级数**，其中 $a_n$ 和 $z_0$ 为复常数，$a_n$ 不全为零，$z_0$ 称为幂级数的**展开中心**。

**收敛点**：使幂级数对应的常数项级数收敛的点称为收敛点

**收敛区间/收敛圆盘**：一个关于展开中心 $z_0$ 对称的开圆盘 $|z-z_0|<R$ 称为幂级数的收敛区间。类比于实级数，这个圆盘不包括边界

**收敛域**：幂级数的收敛域是指所有使级数收敛的复数 $z$ 的集合。

:::tip
在实级数里面是一个区间，在复级数里面是一个圆盘
:::

### 幂级数的收敛半径与敛散性

>abel定理：如果幂级数 $\sum_{n=0}^{\infty} a_nz^n$ 在 $z_0 \neq 0$ 处收敛，那么对满足 $|z| < |z_0|$ 的一切 $z$ ，该级数绝对收敛；如果在 $z_0$ 处发散，那么对满足 $|z| > |z_0|$ 的一切 $z$ ，级数一定发散。

和实级数类似，阿贝尔定理也给出了**收敛半径**的概念，指出幂级数的收敛区域恰好是一个以 $z_0$ 展开中心为圆心的圆盘。幂级数的敛散性只与 $|z-z_0|$ 和圆盘半径$R$有关。**圆盘上的点需要单独考虑**。

**收敛半径**：幂级数 $\sum_{n=0}^{\infty}a_n(z-z_0)^n$ 的收敛半径 $R$ 定义为收敛圆盘的半径。

:::note[证明]
abel引理的证明：
$$
\begin{align*}
(1)&\text{设幂级数 $\sum_{n=0}^{\infty} a_nz^n$ 在}z_0\text{处收敛}\\
&\therefore\lim_{n\to\infty}a_nz_0^n=0\\
&\therefore\{a_nz_0^n\}\text{是有界的}\\
&\therefore\exist M>0,\text{s.t.}\forall n,|a_nz_0^n|<M\\
&\therefore|a_n|<\frac{M}{|z_0|^n}\\
&\text{又设$|z|<|z_0|$}\\
&\therefore\exist r,\;\text{s.t.}\;|z|<r<|z_0|\\
&\therefore|a_nz^n|=|a_n||z|^n<\frac{M}{|z_0|^n}r^n\cdot\left(\frac{|z|}{r}\right)^n<M\left(\frac{|z|}{r}\right)^n\\
&\text{由比值判别法，}\sum M\left(\frac{|z|}{r}\right)^n\text{收敛}\\
&\therefore\text{再由比较判别法，}\sum |a_nz^n|\text{收敛}\\
&\therefore\sum a_nz^n\text{绝对收敛}\\
(2)&\text{设幂级数 $\sum_{n=0}^{\infty} a_nz^n$ 在}z_0\text{处发散}\\
&\text{设$|z|>|z_0|$}\\
&\therefore\exist r,\;\text{s.t.}\;|z_0|<r<|z|\\
&\therefore|a_nz^n|=|a_n||z|^n>|a_n||z_0|^n\cdot\left(\frac{r}{|z_0|}\right)^n\\
&\text{由比值判别法，}\sum |a_n||z_0|^n\cdot\left(\frac{r}{|z_0|}\right)^n\text{发散}\\
&\therefore\sum |a_nz^n|\text{发散}\\
&\therefore\sum a_nz^n\text{发散}
\end{align*}
$$
:::

### 收敛半径的求法

#### 1. 根据定义

由收敛的判别法（比值，根值）算出 $L$ ，然后和1比较；必要时单独考虑圆周上的点。该方法最保险

:::tip[两个特殊极限]

1. $\lim_{n\to\infty}(1+\frac{1}{n})^n=e$
2. $\lim_{x\to 0}\frac{\sin x}{x}=1$，$\lim_{x\to \infty}\frac{\sin x}{x}=0$

:::

#### 2. 公式法

:::tip[上极限]

首先定义一下**上极限**(这一块应该在离散数学里的严格定义)

对于实序列$\{x_n\}_{n=0}^\infin$，定义其上极限为
$$
\limsup_{n\to\infin}x_n=\lim_{n\to\infin}(\sup_{m\geq n}x_m)
$$
简记为 $\limsup x_n$

含义：设 $x_0=\limsup x_n$ ,那么

1. $\forall s<x_0\;,\exist n_1,n_2,\dotsb n_k\;,k\to\infin$，使得 $x_n>x_0$

2. $\forall t>x_0,\exist n_0$ 使得 $\forall n\geq n_0,x_n<t$

:::

有了上极限的定义，给出Cauchy–Hadamard 公式

$$
\frac{1}{R}=\limsup_{n\to\infin}\sqrt[n]{|a_n|}
$$

### 收敛半径内,幂级数的和函数的分析学性质

收敛圆内幂级数一致收敛：设和函数 $f(z)=\sum_{n=0}^{\infin}a_n(z-z_0)^n$ ,收敛半径是R，那么在收敛圆内（不包括圆周）$|z-z_0|<R$，幂级数是**一致收敛**的，可以**逐项求导/积分、仍为幂级数，收敛半径不变**。

:::note[证明]

由Weierstrass判别法，$\forall z$ 满足 $|z-z_0|<R$ ,取 $r$ 使得 $|z-z_0|<r<R$ ,则
$$
|a_n(z-z_0)^n|=|a_n||z-z_0|^n
\leq|a_n|r^n\cdot\left(\frac{|z-z_0|}{r}\right)^n<|a_n|r^n
$$
由此构造了一个实数级数 $\sum M_n=\sum |a_n|r^n$ ，这是实幂级数 $\sum M_n=\sum |a_n|x^n$ 中 $x=r$ 的情况。

由Cauchy–Hadamard 公式，$R^\prime=\frac{1}{\limsup_{n\to\infin}\sqrt[n]{|a_n|}}=R>r$ ,所以 $\sum M_n$ 收敛。

从而由Weierstrass判别法，幂级数在 $|z-z_0|<R$ 上一致收敛。

:::

在收敛圆内可以无限求导，体现幂级数和函数的**解析性**。在复分析中，**解析** 与 **局部可由幂级数表示**是等价的。更具体地：

+ 如果 $f$ 在一个**开邻域内可表示为幂级数**，则由一致收敛与逐项求导 $f$ 必为**解析**函数。

+ 反过来，如果 $f$ 在**开邻域解析**，则对任意点 $z_0$，存在 $R>0$ 使得 $f$ 在 $|z-z_0|<R$ 等于其**泰勒级数**（由 Cauchy 积分公式的展开证明）。

:::tip

这与实函数的情形不同——实函数可微并不一定能展开为幂级数（analytic 与 smooth 在实分析中并不等价），但在复分析中 holomorphic ⇒ analytic（解析）

:::

## 泰勒级数

在复分析中，由于幂级数所表示的函数是解析函数。我们把**解析函数**在某点所对应的**幂级数展开**称为**泰勒级数**

### 泰勒级数定义

设函数 $f(z)$ 在点 $z_0$ 的邻域内解析，则 $f(z)$ 在点 $z_0$ 处的泰勒展开式为：

$$
f(z)=\sum_{n=0}^{\infin}\frac{f^{(n)}(z_0)}{n!}(z-z_0)^n\;,|z-z_0|<R
$$

收敛半径的几何意义：从展开中心 $z_0$ 到函数最近奇点的距离。

![image.png](/public/RUNOOB-SVG-IMAGE.png)

例如 $e^z$ 在整个平面都解析，则 $R=\infin$ ,$\frac{1}{1-z}$
在 $z_0=0$ 处展开，奇点在z=1,那么R=1

### 泰勒级数的系数公式

方法1：由幂级数的系数公式

$$
\begin{align*}
&\text{设 }f(z)=\sum_{n=0}^{\infty}a_n(z-z_0)^n\\
&\text{对两边同时求n阶导，得}\\
&f^{(n)}(z)=0+a_nn!+\sum_{k=n+1}^{\infty}a_kn!(z-z_0)^{k-n-1}\\
&\text{令}z=z_0\text{，得}\\
&f^{(n)}(z_0)=a_nn!\\
&\therefore a_n=\frac{f^{(n)}(z_0)}{n!}
\end{align*}
$$
方法2：由柯西积分公式
$$
\begin{align*}
&\text{设 }f(z)=\sum_{n=0}^{\infty}a_n(z-z_0)^n\\
&\text{两边同时除以}(z-z_0)^{n+1}\text{，得}\\
&\frac{f(z)}{(z-z_0)^{n+1}}=\sum_{k=0}^{\infty}a_k(z-z_0)^{k-n-1}\\
&\text{对两边同时沿闭曲线}\gamma\text{积分，得}\\
&\int_\gamma\frac{f(z)}{(z-z_0)^{n+1}}\,dz=\sum_{k=0}^{\infty}a_k\int_\gamma(z-z_0)^{k-n-1}\,dz\\
&\text{由柯西积分公式，}\int_\gamma(z-z_0)^{k-n-1}\,dz=\begin{cases}
    2\pi i\;,k=n\\
    0\;,k\neq n
\end{cases}\\
&\therefore\int_\gamma\frac{f(z)}{(z-z_0)^{n+1}}\,dz=a_n\cdot 2\pi i\\
&\therefore a_n=\frac{1}{2\pi i}\int_\gamma\frac{f(z)}{(z-z_0)^{n+1}}\,dz
\end{align*}
$$

### 常见函数的泰勒级数展开

还是分两种，直接法和间接法

常见的泰勒展开式就是实函数把自变量从x换成z即可

## 洛朗级数

:::tip
泰勒级数的收敛圆比较捞，从零开始逐渐拓展到最近的奇点。而奇点外的区域就无法表示了。

洛朗级数是泰勒级数更一般的推广，直观上看是从解析圆域推广到解析圆环。
:::

:::tip[基本概念回顾]

解析点：函数在该点的某个邻域内解析。

奇点：函数在该点不解析，但在该点的某个去心邻域内解析。

:::

如果在某个邻域中，只有 $z_0$ 这一处是奇点，我们称它为**孤立奇点**。

### 洛朗级数定义

定义：设函数 $f(z)$ 在孤立奇点附近的**环形区域**
$A = \{z: r < |z-z_0| < R\}$ 内解析，则它可以展开为洛朗级数：  

:::tip[环形区域]

环形区域是指两个同心圆之间的区域，内圆半径为 $r$ ，外圆半径为 $R$ 。
$r$ 可以为 $0$ ，此时内圆退化为一个点。
$R$ 可以为 $\infty$ ，此时外圆退化为半径为 $R$，圆心为展开中心的圆外的复平面。

:::

$$
f(z) = \sum_{n=-\infty}^\infty c_n (z-z_0)^n, \quad r<|z-z_0|<R
$$

其中包含了 **正幂部分** 和 **负幂部分**：  

+ 正幂部分：$\sum_{n=0}^\infty c_n (z-z_0)^n$，类似泰勒级数，收敛于外圆内 $|z-z_0|<R$ 的区域  
+ 负幂部分：$\sum_{n=1}^\infty c_{-n} (z-z_0)^{-n}$，体现奇点的性质，收敛于内圆外 $|z-z_0|>r$ （也就是$\frac{1}{|z-z_0|}<r$）的区域  
+ 综合起来：整个洛朗级数收敛于环形区域 $r<|z-z_0|<R$。

洛朗级数的**系数公式**与泰勒级数类似(同样来自柯西积分公式)

$$
c_n = \frac{1}{2\pi i} \int_\gamma \frac{f(\zeta)}{(\zeta-z_0)^{n+1}}\, d\zeta
$$

其中 $\gamma$ 是任意一个围绕 $z_0$ 的闭合曲线，且位于环形区域内。

但是，在洛朗级数中，$c_n\text{不一定等于}\frac{f^{(n)}(z_0)}{n!}$

### 洛朗展开与奇点分类

在孤立奇点附近，函数总能展开成 **洛朗级数**：  

$$
f(z) = \sum_{n=-\infty}^{\infty} c_n (z-z_0)^n, \quad 0<|z-z_0|<R
$$

根据 **负幂部分（principal part）** 的情况，可以把孤立奇点分为三类：  

1. **可去奇点**：  
   如果负幂部分全为零，即 $c_{-n}=0$，$n\geq 1$。  
   + 本质上函数在 $z_0$ 处是“无害”的，可以通过赋值使之解析。  
   + 例如：$\frac{\sin z}{z}$ 在 $z=0$ 是可去奇点（定义为 $\sin z / z = 1$ 即解析）。  

2. **极点**：  
   如果负幂部分只有有限项，即存在 $m$ 使得  
   $$
   \begin{align*}
   f(z) &= \frac{c_{-m}}{(z-z_0)^m} + \cdots + \frac{c_{-1}}{z-z_0} + \text{(正幂部分)}\\
   &= \frac{g(z)}{(z-z_0)^m}
   \end{align*}
   $$
    其中 $g(z)$ 在 $z_0$ 解析且 $g(z_0)\neq 0$，
   那么 $z_0$ 是一个 **$m$ 阶极点**。 
   **极点阶数定理**：设 $f(z)$ 在 $0<|z-z_0|<\delta$ 范围内解析，则 $z_0$ 是 $f(z)$ 的m阶极点的充要条件是存在 $g(z)$，在$0<|z-z_0|<\delta$ 范围内解析且 $g(z_0)\neq 0$，并且有：

   $$
    f(z)=\frac{1}{(z-z_0)^m}g(z)
   $$ 

3. **本性奇点**：  
   如果负幂部分有无限项，即展开式有无穷多个 $c_{-n}$ 非零。  
   + 例如：$f(z)=e^{1/z}$ 在 $z=0$ 就是本性奇点。  
   + 在本性奇点附近，函数表现极端复杂，密集取遍复平面上的值（皮卡定理）。  

### 孤立奇点种类的判别方法

1. **可去奇点**：如果 $\lim_{z\to z_0} f(z)=c_0$ 存在，则 $z_0$ 是可去奇点。

2. **极点**：如果 $\lim_{z\to z_0} f(z)=\infty$，则 $z_0$ 是极点。  
   + 进一步，如果 $\lim_{z\to z_0} (z-z_0)^m f(z)=c_{-m}\neq 0$ 存在，则 $z_0$ 是 $m$ 阶极点。
3. **本性奇点**：如果 $\lim_{z\to z_0} f(z)$ 不存在且不为 $\infty$，则 $z_0$ 是本性奇点。

### 零点与奇点的关系

零点的定义：设 $f(z)$ 在点 $z_0$ 的某个邻域内解析，且 $f(z_0)=0$，如果存在 $m$ 使得
$$
\begin{align*}
f(z) &= \sum_{n=0}^{\infty} a_n (z-z_0)^n\\
&= a_0 + a_1 (z-z_0) + a_2 (z-z_0)^2 + \cdots
\end{align*}
$$
其中 $a_0=a_1=\cdots=a_{m-1}=0$，$a_m\neq 0$，则称 $z_0$ 是 $f(z)$ 的一个**m阶零点**。

也就是
$$\begin{align*}
\text{$z_0$ 是 $f(z)$ 的 $m$ 阶零点}&\iff f(z)=(z-z_0)^m g(z),\quad g(z_0)\neq 0\\
&\iff\begin{cases}
    f^{(n)}(z_0)=0\;,n=0,1,2,\ldots,m-1\\
    f^{(m)}(z_0)\neq 0
\end{cases}
\end{align*}
$$

:::tip
简单来讲，m阶零点就是函数在该点处有m-1个连续的导数为0，直到第m阶导数不为0。
:::

零点与奇点的关系：如果 $f(z)$ 在 $z_0$ 处有一个 $m$ 阶零点，则 $\dfrac{1}{f(z)}$ 在 $z_0$ 处有一个 $m$ 阶极点，反之亦然。

## 留数

### 留数的定义

设 $z_0$ 是 $f(z)$ 的一个孤立奇点，在 $z_0$ 附近有洛朗展开：
$$
f(z) = \sum_{n=-\infty}^{\infty} c_n (z-z_0)^n, \quad 0<|z-z_0|<R
$$
则 $f(z)$ 在 $z_0$ 的留数（Residue） 定义为：
$$
Res(f,z_0)=c_{-1}
$$
也就是说，留数就是 洛朗级数中 $(z-z_0)^{-1}$ 项的系数。

### 留数的计算方法

根据奇点的不同情况，留数有不同的计算技巧：  

1. 可去奇点

    如果 $z_0$ 是可去奇点，则  $\operatorname{Res}(f, z_0) = 0$

2. 单极点

    若 $z_0$ 是一阶极点，则
    $$
    \operatorname{Res}(f, z_0) = \lim_{z \to z_0} (z-z_0) f(z)
    $$

    :::tip[例子]  

    $f(z)=\dfrac{1}{z-1}$ 在 $z=1$ 的留数 ,则
    $\operatorname{Res}\Big(\frac{1}{z-1}, 1\Big) = \lim_{z\to 1} (z-1)\frac{1}{z-1} = 1$

    :::

3. 高阶极点

    若 $z_0$ 是 $m$ 阶极点，则  

    $$
    \operatorname{Res}(f, z_0) = \frac{1}{(m-1)!} \lim_{z\to z_0} \frac{d^{\,m-1}}{dz^{\,m-1}} \left[ (z-z_0)^m f(z) \right]
    $$

4. 商的形式（实用公式）

    若 $f(z) = \dfrac{g(z)}{h(z)}$，其中 $g(z)$、$h(z)$ 在 $z_0$ 解析，且 $h(z_0)=0$，$h'(z_0)\neq 0$（即 $z_0$ 是 $h(z)$ 的单零点 → $f(z)$ 的单极点），则  

    $$
    \operatorname{Res}(f, z_0) = \frac{g(z_0)}{h'(z_0)}
    $$
    :::tip[例子]

    $f(z)=\dfrac{1}{(z-1)(z+2)}$ 在 $z=1$ 的留数  
    $\operatorname{Res}\Big(f, 1\Big) = \frac{1}{(z+2)'}\Big|_{z=1} = \frac{1}{3}$

    :::

5. 对于无穷远点的留数：
    $\operatorname{Res}[f(z),\infty]=-\operatorname{Res}\frac{1}{c}\frac{1}{c^2},0$

### 留数的几何/积分意义

由柯西积分公式的推广可以得出：  

$$
\operatorname{Res}(f, z_0) = \frac{1}{2\pi i} \oint_\gamma f(z)\, dz
$$

其中 $\gamma$ 是 $z_0$ 的一个小闭合圈。  
也就是说：**留数就是函数在奇点周围积分的“贡献值”**。  

## 留数定理

### 留数定理的内容

设函数 $f(z)$ 在某个单连通区域 $D$ 内解析，除了有限个孤立奇点 $z_1, z_2, \dots, z_n$。设 $\gamma$ 是一条正向（逆时针）绕这些奇点的闭合曲线，且 $\gamma$ 不经过任何奇点，则：

$$
\oint_\gamma f(z)\, dz = 2 \pi i \sum_{k=1}^n \operatorname{Res}(f, z_k)
$$

也就是说：**闭合曲线积分等于曲线内部所有奇点留数之和乘以 $2\pi i$**。

### 几何意义

+ 每个孤立奇点对曲线积分的贡献量就是它的留数乘 $2\pi i$  

+ 留数定理把 **曲线积分** 变成了 **奇点局部信息** 的求和，极大简化了积分计算  

### 留数定理的常见应用

#### 1 计算闭合曲线积分

例如，计算围绕单位圆 $|z|=1$ 的积分：
$\oint_{|z|=1} \frac{dz}{z^2+1}$

步骤：  

1. 分解因子：$z^2+1 = (z-i)(z+i)$  
2. 奇点在 $z=i, z=-i$，单位圆内仅 $z=i$  
3. 单极点留数：$\operatorname{Res}\Big(\frac{1}{z^2+1}, i\Big) = \lim_{z\to i} (z-i)\frac{1}{(z-i)(z+i)} = \frac{1}{2i}$  
4. 积分：$\oint_{|z|=1} \frac{dz}{z^2+1} = 2\pi i \cdot \frac{1}{2i} = \pi$

#### 2 计算实积分

许多实积分可以通过构造复函数，并使用留数定理计算，例如：

$\int_{-\infty}^{\infty} \frac{dx}{x^2+1} = \pi$

形如 $\int_0^{2\pi}R(\sin\theta,\cos\theta)d\theta$，其中R表示有理式

$$
\text{令}z=e^{i\theta},\;\frac{1}{z}=e^{-i\theta}\\
\iff \begin{cases}
    \cos\theta=\frac{z+\frac{1}{z}}{2}\\
    \sin\theta=\frac{z-\frac{1}{z}}{2i}\\
    dz=izd\theta
\end{cases}\\
\iff \oint_{|z|=1} R(\frac{z+\frac{1}{z}}{2},\frac{z-\frac{1}{z}}{2i})\frac{1}{iz}dz
$$

:::note
注意theta的积分区域，这里是0到 $2\pi$，需要挪到这个区间里面才能套公式

可以根据三角函数的奇偶性扩充积分区间长度到 $2\pi$，区间长为周期的时候可以挪到 $(0,2\pi)$
:::

形如 $\int_{-\infty}^{+\infty}\frac{P(x)}{Q(x)}dx$，上下都是多项式，$Q(x)$ 的次数比 $P(x)$ 至少高两次且 $Q(x)=0$ 无实根

$$
\int_{-\infty}^{+\infty}\frac{P(x)}{Q(x)}dx=2\pi i\sum_{k=1}^{n}\operatorname{Res}[\frac{P(z)}{Q(z)},z_k]\\
\text{这里 $z_k$ 是 $\frac{P(x)}{Q(x)}$ 在上半平面内的奇点}
$$

#### 3 高阶极点和多极点积分

对于 $m$ 阶极点，可以用高阶极点公式计算留数，然后直接套用留数定理求积分：  

$\oint_\gamma f(z)\, dz = 2\pi i \sum \operatorname{Res}(f, z_k)$

### 公公又式式

+ 核心步骤：**找奇点 → 判定类型 → 计算留数 → 求和 × 2πi**
