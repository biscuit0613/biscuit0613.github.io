---
title: "[工科概率论] 速记表"
published: 2025-11-27 20:01:00
tags: [概率论,数学]
category: 概率论与数理统计
---
## 事件运算

$$
P(A+B) = P(A) + P(B) - P(AB) \\[1em]
P(A-B) = P(A) - P(AB)=P(A\overline{B})\\[1em]
$$

## 独立性条件

- 独立和不相容是互斥的。两个事件不可能既独立又不相容（除非有一个概率为0）。

- 独立不相关，相关不独立；但正态分布下独立 $\iff$ 不相关。

$$
\begin{aligned}
P(AB) = P(A)P(B) \\
f(x,y) = f_X(x) f_Y(y) \\
F(x,y) = F_X(x) F_Y(y) \\  
\end{aligned}
$$

- 两两独立不一定相互独立。相互独立一定两两独立。

相互独立的额外条件：

$$
P(ABC)=P(A)P(B)P(C) \\[1em]
$$

- 随机变量X,Y独立，则$g(X)$和$h(Y)$也独立；但如果两个变量都依赖于同一个原始变量（比如 $X$ 和 $X^2$），则它们通常不独立。

联合概率密度也能反应**独立性和同分布性**：（参见综合10选择）

- 独立：联合等于边缘乘积（综合14）；同分布：边缘相等

- x,y独立 $\iff$ $f(x,y)=f_X(x)f_Y(y)$ $\iff$ x,y的支撑集是矩形区域；反之，支撑集不是矩形区域则不独立

- x,y同分布 $\iff$ $f_X(x)=f_Y(y)$ $\iff$ x,y的支撑集关于y=x对称；反之，支撑集不对称则不同分布

## 全概率公式

$$
P(B) = \sum_{i=1}^{n} P(A_i) P(B|A_i)
$$

## 贝叶斯公式

$$
P(A_i|B) = \frac{P(A_i) P(B|A_i)}{\sum_{j=1}^{n} P(A_j) P(B|A_j)}
$$

## 条件分布

一句话：条件分布就是**联合除以边缘**(参考深圳17秋选择最后一道和大题最后一道)

在**Y确定**的条件下X的分布情况；

对于连续型随机变量(注意F的积分变量)

$$
f_{X|Y}(x|y) = \frac{f_{X,Y}(x,y)}{f_Y(y)} \\[1em]
F_{X|Y}(x|y) =P(X \leq x | Y = y) = \frac{F_{X,Y}(x,y)}{F_Y(y)}=\int_{-\infty}^{x} f_{X|Y}(t|y) \, dt
$$

对于离散型随机变量

$$
P(X=x_i|Y=y_j) = \frac{P(X=x_i,Y=y_j)}{P(Y=y_j)}=\frac{p_{ij}}{p_{\cdot j}}
$$

## 离散分布

:::note
抽签具有公平性和独立性。
:::

### 二项分布

$$
X \sim B(n,p) \\[1em]
E(X) = np \\[1em]
D(X) = np(1-p)
$$

### 泊松分布

$$
X \sim Po(\lambda) \\[1em]
f(x) = \frac{\lambda^x e^{-\lambda}}{x!} \quad x = 0,1,2,\ldots \\[1em]
E(X) = \lambda \\[1em]
D(X) = \lambda
$$

### 几何分布

几何分布是对于重复的伯努利试验，直到第一次成功所需的试验次数，参数其实就是 $B(n,p)$ 里的 $p$。

$$
X \sim G(p) \\[1em]
P(X=k)=(1-p)^{k-1}p \quad k=1,2,3,\ldots \\[1em]
E(X) = \frac{1}{p} \\[1em]
D(X) = \frac{1-p}{p^2} \\[1em]
\text{E和D的推导需要级数求导}
$$

### 超几何分布

$$
X \sim H(N,M,n) \\[1em]
E(X) = n \frac{M}{N} \\[1em]
D(X) = n \frac{M}{N} \frac{N-M}{N} \frac{N-n}{N-1}
$$

## 泊松近似二项分布

在题目里面出现奇奇怪怪的 $\lambda$ 的时候可以考虑是否用到了近似，当 $n$很大且 $p$ 很小时，$np = \lambda$，则有

$$
P(X=k) \approx \frac{\lambda^k e^{-\lambda}}{k!}
$$

查表得

## 连续分布

### 正态分布

$$
X \sim N(\mu, \sigma^2) \\[1em]
f(x) = \frac{1}{\sqrt{2 \pi} \sigma} \exp \left( -\frac{(x-\mu)^2}{2 \sigma^2} \right) \\[1em]
E(X) = \mu \\[1em]
D(X) = \sigma^2
$$

### 指数分布

$$
X \sim E(\lambda) \\[1em]
f(x) = \lambda e^{-\lambda x} \quad x \geq 0 \\[1em]
F(x) = 1 - e^{-\lambda x} \quad x \geq 0 \\[1em]
E(X) = \frac{1}{\lambda} \\[1em]
D(X) = \frac{1}{\lambda^2}
$$

### 均匀分布

$$
X \sim U(a,b) \\[1em]
f(x) = \frac{1}{b-a} \\[1em]
E(X) = \frac{a+b}{2} \\[1em]
D(X) = \frac{(b-a)^2}{12}
$$

### 具有独立可加性的分布

正态分布，泊松分布，$\chi^2$ 分布 都具有独立可加性

### 具有无记忆性的分布

指数分布具有无记忆性

## 二维正态分布

$$
\begin{aligned}
f(x,y) &= \frac{1}{2 \pi \sigma_X \sigma_Y \sqrt{1-\rho^2}} \exp \left( -\frac{1}{2(1-\rho^2)} \left[ \frac{(x-\mu_X)^2}{\sigma_X^2} - \frac{2 \rho (x-\mu_X)(y-\mu_Y)}{\sigma_X \sigma_Y} + \frac{(y-\mu_Y)^2}{\sigma_Y^2} \right] \right) \\[1em]
E(X) &= \mu_X \\[1em]
E(Y) &= \mu_Y \\[1em]
D(X) &= \sigma_X^2 \\[1em]
D(Y) &= \sigma_Y^2 \\[1em]
Cov(X,Y) &= \rho \sigma_X \sigma_Y
\end{aligned}
$$

## 分布函数与概率密度函数

### 分布函数需要满足的条件

1. $F(x)$ 单调不减

2. $F(-\infty) = 0, \quad F(+\infty) = 1$
3. $F(x)$ **右连续**，等价于**区间左闭右开**。（参考综合13选择2）

### 概率密度函数需要满足的条件

1. $f(x) \geq 0$ 恒大于等于0

2. $\int_{-\infty}^{+\infty} f(x) \, dx = 1$ 积分为1
3. $F(x) = \int_{-\infty}^{x} f(t) \, dt$
4. $f(x) = \frac{d}{dx} F(x)$

## 随机变量的函数

### 公式法

$y = g(x)$ 在 $(a,b)$ 单调, $x = h(y)$ 为其反函数, 则

$$
f_Y(y) = f_X(h(y)) |h'(y)|, \quad y \in (\min \left \{g(a), g(b) \right \} , \max \left \{g(a), g(b) \right \})
$$

## 二维随机变量的函数

### 卷积法

$$
f_{X+Y}(z) = \int_{-\infty}^{+\infty} f_X(x) f_Y(z-x) \, dx\;\;\text{前提是XY独立} \\[1em]
f_{X+Y}(z) = \int_{-\infty}^{+\infty} f_{X,Y}(x, z-x) \, dx
$$

### 二重积分法

省略

## 数字特征

### 期望

$$
E(X) = \int_{-\infty}^{+\infty} x f(x) \, dx
$$

#### 期望运算

$$
E[aX + bY + c] = aE(X) + bE(Y) + c
$$

当 $X$ 和 $Y$ 独立时，（或者宽松一点不相关时）有

$$
E(XY) = E(X) E(Y)
$$

### 方差

$$
D(X) = E[(X - E(X))^2] = \boxed{E(X^2) - [E(X)]^2} \\[1em]
D(X) = \int_{-\infty}^{+\infty} (x - E(X))^2 f(x) \, dx
$$

#### 方差运算

$$
D[aX \pm bY + c] = a^2 D(X) + b^2 D(Y) \pm 2ab Cov(X,Y)
$$

### 协方差

$$
Cov(X,Y) = E[(X - E(X))(Y - E(Y))] = \boxed{E(XY) - E(X)E(Y)}
$$

类似于方差，加减常数不影响

$$
Cov(aX+b, cY+d) = ac Cov(X,Y)
$$

协方差的分配律

$$
Cov(X_1 + X_2, Y_1 + Y_2) = Cov(X_1, Y_1) + Cov(X_1, Y_2) + Cov(X_2, Y_1) + Cov(X_2, Y_2)
$$

方差是协方差的特例

$$
D(X) = Cov(X,X)
$$

### 相关系数

$$
\rho_{XY} = \frac{Cov(X,Y)}{\sqrt{D(X)} \sqrt{D(Y)}}
$$

- 如果 $Cov(X,Y) = 0$，则 $\rho_{XY} = 0$

- $\rho=1\iff Y=aX+b$ ，遇到 $XY$ 线性关系可以直接写出相关系数为1。但是曲线关系**不能**直接说相关系数=0。
- $Y=aX+b$ 且 $\rho_{ZY}$ 已知时，可以快速得到 $\rho_{ZX}=\operatorname{sgn}(a) \rho_{ZY}$

## 大数定律

### 马尔可夫不等式

$$
P(X \geq \varepsilon) \leq \frac{E(X)}{\varepsilon}
$$

### 切比雪夫不等式

纯套公式，看见 $P(|X - E(X)| \geq \varepsilon)$ 的形式就想这个，有的时候期望是0会比较隐蔽，如果给的是 $<$ 号，就用1减去

$$
P(|X - E(X)| \geq \varepsilon) \leq \frac{D(X)}{\varepsilon^2} \\[1em]
$$

### 伯努利大数定律

看见 $n$ 重伯努利试验的时候用，$Y_n$ 表示成功次数，$p$ 表示成功概率

$$
\lim_{n \to \infty} P \left( \left| \frac{Y_n}{n} - p \right| \ge \varepsilon \right) = 0
$$

### 切比雪夫大数定律

如果有大量同分布且独立的随机变量 $X_1, X_2, \ldots, X_n$ 就用这个

$$
\lim_{n \to \infty} P \left( \left| \frac{1}{n} \sum_{i=1}^{n} X_i - \mu \right| \ge \varepsilon \right) = 0
$$

### 辛钦大数定律

其实跟切比雪夫大数定律是一样的，只不过放宽了条件，只要有相同的期望就行，不要求方差相等
，实际上是因为上面的切比雪夫大数定律的推论证明的过程中假定了方差相等

## 中心极限定理

### 独立同分布中心极限定理

独立同分布的随机变量 $X_1, X_2, \ldots, X_n$，期望为 $\mu$，方差为 $\sigma^2$，则当 $n$ 充分大时，随机变量就近似服从正态分布

### 棣莫弗-拉普拉斯中心极限定理（n重伯努利试验）

$n$ 重伯努利分布 $B(n,p)$ 近似服从正态分布 $N(np, np(1-p))$

## 三大分布

### $\chi^2$分布

有 $n$ 个相互独立的标准正态分布随机变量 $X_1, X_2, \ldots, X_n$，则随机变量
$$
Y = \sum_{i=1}^{n} X_i^2 \sim \chi^2(n)
$$

$\chi^2(n)$ 表示自由度为 $n$ 的卡方分布

重要结论：均值和方差

$$
E(Y) = n \\[1em]
D(Y) = 2n
$$

#### 概率怎么看

$$
P(\chi^2 (n) > \chi^2_{\alpha}(n)) = \alpha \\[1em]
\chi^2_{\alpha}(n) \text{通过查表得到， 是横轴上的值}
$$

### $t$分布

由$X \sim N(0,1)$和$Y \sim \chi^2(n)$构成

$$
T = \frac{X}{\sqrt{Y/n}} \sim t(n)
$$

$t(n)$表示自由度为$n$的t分布

重要性质：**对称** $t_{\alpha}(n) = -t_{1-\alpha}(n)$

$$
P(t(n) > t_{\alpha}(n)) = \alpha \\[1em]
t_{\alpha}(n) \text{通过查表得到}
$$

### $F$分布

由 $X \sim \chi^2(n_1)$ 和 $Y \sim \chi^2(n_2)$ 构成

$$
F = \frac{(X/n_1)}{(Y/n_2)} \sim F(n_1, n_2)
$$

重要性质：

$$
F_{1-\alpha}(n_1, n_2) = \frac{1}{F_{\alpha}(n_2, n_1)}
$$

$F(n_1, n_2)$ 表示自由度为 $(n_1, n_2)$ 的 F 分布，$n_1$ 叫第一(分子)自由度，$n_2$ 叫第二（分母）自由度

$$
P(F(n_1, n_2) > F_{\alpha}(n_1, n_2)) = \alpha \\[1em]
F_{\alpha}(n_1, n_2) \text{通过查表得到}
$$

## 统计量

### $k$ 阶矩

$$
A_k = \frac{1}{n} \sum_{i=1}^{n} X_i^k
$$

$k=1$ 时为样本均值

#### 样本均值

无论总体分布如何，样本均值都是总体均值的无偏估计量

并且满足

$$
E(\overline{X}) = \mu\;\;;\;\;D(\overline{X}) = \frac{\sigma^2}{n}
$$

而当总体恰好为正态分布时，这两个作为正态分布的参数。

如果总体不满足正态分布，样本均值$\overline{X}$也近似服从正态分布（中心极限定理）

### $k$ 阶中心距

$$
B_k = \frac{1}{n} \sum_{i=1}^{n} (X_i - \overline{X})^k
$$

$k=2$ 时不是样本方差，称为样本二阶中心距，表示为 $S^{*2}$

#### 样本方差

$$
S^2 = \frac{1}{n-1} \sum_{i=1}^{n} (X_i - \overline{X})^2
$$

无论总体分布如何，样本方差 $S^2$ 都是总体方差 $\sigma^2$ 的无偏估计量，满足：

$$
E(S^2) = \sigma^2
$$

$D(S^2)$ 超纲了，不记。感兴趣搜四阶矩。

注意是除以 $n-1$，而不是 $n$

:::warning
接下来这两个必须得背，没法现推；同时注意前提是总体服从正态分布
:::

### 样本方差和样本均值的独立性

当在**总体服从正态分布**的前提下，样本方差 $S^2$ 和样本均值 $\overline{X}$ 是独立的。否则这俩不一定独立（参考综合11选择5）

### 正态总体的样本方差的分布

$$
\frac{(n-1)S^2}{\sigma^2} \sim \chi^2(n-1)
$$

可用这个稍微变形得到样本**二阶中心距**的分布：

$$
(n-1)S^2=n S^{*2}\\[1em]
\frac{n S^{*2}}{\sigma^2} \sim \chi^2(n-1)
$$

### 正态总体的样本标准差的分布

$$
\frac{(\overline{X} - \mu)}{S/ \sqrt{n}} \sim t(n-1)
$$

## 参数估计

### 矩估计法

算一、二...阶矩 $\alpha_1，\alpha_2, \ldots$ ，然后解方程组就能得到参数估计值，注意利用题里给的已知信息如均值、方差等，矩中间接包含了这些信息可用于解方程

$$
D(X) = E(X^2) - [E(X)]^2= \alpha_2 - \alpha_1^2
$$

### 最大似然估计法

先写出似然函数 $L(\theta)$

$$
L(\theta) = \prod_{i=1}^{n} f(x_i; \theta)
$$

如果似然函数不连续，则应根据极大值出现在区间端点的原则，分别求出各个端点处的函数值，再比较大小，取最大值对应的 $\theta$ 值

若似然函数中无 $x$，则根据 $x$ 的取值范围，直接写出 $\theta$ 的取值范围，取最大值对应的 $\theta$ 值

其余情况，取对数似然函数并对 $\theta$ 求导，令导数为0，解方程得到参数估计值

$$
\text{解该方程} \quad \frac{d}{d\theta} \ln L(\theta) = 0
$$

总之是求让 $L(\theta)$ 最大的 $\theta$ 值作为估计 $\hat{\theta}$

有时候需要估计的可能是 $\alpha^2$ 这种参数，就要把 $\alpha^2$ 作为整体参数来估计：$\dfrac{d}{d\alpha^2}$ （参见综合9倒数第二题）

## 估计评定

### 无偏性

算估计量的均值，如果正好等于 $\theta$，则该估计量是无偏的

$$
E(\hat{\theta}) = \theta
$$

常见的无偏估计量：

- 样本均值 $\overline{X}$ 是总体均值 $\mu$ 的无偏估计量

- 样本方差 $S^2$ 是总体方差 $\sigma^2$ 的无偏估计量

### 有效性

需要无偏性作为前提，如果不是无偏的谈有效性没意义

设有两个估计 $\theta_1$ 和 $\theta_2$，如果对于所有的 $\theta$ 都有

$$
D_{\theta}(\theta_1) \le D_{\theta}(\theta_2)
$$

且至少有一个参数值 $\theta$ 使小于号成立，则称估计量 $\theta_1$ 比估计量 $\theta_2$ 更有效

直观上理解就是方差更小的估计量更有效

### 相合性

有 $n$ 个估计量 $\hat{\theta}_n$，如果

$$
\forall \varepsilon > 0, \quad \lim_{n \to \infty} P(|\hat{\theta}_n - \theta| \ge \varepsilon) = 0
$$

则称估计量 $\hat{\theta}_n$ 是参数 $\theta$ 的相合（一致）估计量

## 区间估计

$1-\alpha$ 叫置信水平，$\alpha$ 叫显著性水平
区间估计就三种情况：

### 已知$\sigma^2$求$\mu$

用正态分布

$$
u = \frac{\overline{x} - \mu}{\sigma / \sqrt{n}} \sim N(0,1)\\[1em]
P \left( -u_{\alpha/2} < u < u_{\alpha/2} \right) = 1 - \alpha\\[1em]
\overline{X}\pm u_{\alpha/2} \frac{\sigma}{\sqrt{n}}
$$

把已知的全代入解出 $\mu$ 的范围就是置信区间，$u_{\alpha/2}$ 通过查表得到

### 未知$\sigma^2$求$\mu$

用t分布

$$
t = \frac{\overline{x} - \mu}{s / \sqrt{n}} \sim t(n-1)\\[1em]
P \left( -t_{\alpha/2}(n-1) < t < t_{\alpha/2}(n-1) \right) = 1 - \alpha\\[1em]
\overline{X}\pm t_{\alpha/2}(n-1) \frac{s}{\sqrt{n}}
$$

同样都代进去查表

### 求$\sigma^2$

用卡方分布

$$
\chi^2 = \frac{(n-1)s^2}{\sigma^2} \sim \chi^2(n-1)\\[1em]
P \left(  \chi^2_{1-\alpha/2}(n-1) < \chi^2 < \chi^2_{\alpha/2}(n-1)  \right) = 1 - \alpha \\[1em]
$$

## 双样本均值差的区间估计

### 已知$\sigma_1^2$ = $\sigma_2^2$求$\mu_1 - \mu_2$

用t分布

$$
\large t = \frac{(\overline{x}_1 - \overline{x}_2) - (\mu_1 - \mu_2)}{\sqrt{\dfrac{\sigma_1^2}{n_1} + \dfrac{\sigma_2^2}{n_2}}} \sim t(n_1 + n_2 - 2 )\\[1em]
P \left( -t_{\alpha/2}(n_1 + n_2 - 2) < t < t_{\alpha/2}(n_1 + n_2 - 2) \right) = 1 - \alpha
$$

### 求$\dfrac{\sigma_1^2}{\sigma_2^2}$

用F分布

$$
\large F = \dfrac{s_1^2 / \sigma_1^2}{s_2^2 / \sigma_2^2} \sim F(n_1 - 1, n_2 - 1)\\[1em]
P \left( F_{1-\alpha/2}(n_1 - 1, n_2 - 1) < F < F_{\alpha/2}(n_1 - 1, n_2 - 1) \right) = 1 - \alpha
$$

## 重要结论

### 标准正态分布的奇数阶矩

因为标准正态 $\phi(x)$ 是偶函数，所以奇数阶矩全为0

$$
E(X^{2k+1}) = 0
$$

### 标准正态分布的偶数阶矩

$$
E(X^{2k}) = (2k-1)!! = \frac{(2k)!}{2^k k!}
$$

:::warning
 !!是双阶乘，5!! = 5 × 3 × 1
:::

### 标准正态分布的矩母函数

$M_X(t)$ 的含义是 $E(e^{tX})$。

$$
M_X(t) = E(e^{tX}) = e^{\mu t + \frac{\sigma^2 t^2}{2}} \\[1em]
$$

顾名思义，矩母函数就是用来求矩的，展开成泰勒级数后系数就是各阶矩：

$$
e^{tX}= \sum_{n=0}^{\infty} \frac{(tX)^n}{n!} \\[1em]
E(e^{tX}) = E(1)+t\cdot E(X)+\frac{t^2}{2!}E(X^2)+\frac{t^3}{3!}E(X^3)+ \cdots \\[1em]
$$

计算k阶原点矩就是对$M_X(t)$对t求k阶导数再带入t=0：

$$
E(X^k) = \frac{d^k M_X(t)}{dt^k} \bigg|_{t=0}
$$

### 快速求$aX$的概率密度函数

$$
f_{aX}(\omega) = \frac{1}{|a|} f_X \left( \frac{\omega}{a} \right)
$$

### 高斯积分

$$
\int_{-\infty}^{+\infty} e^{- \lambda x^2} \,dx = \sqrt{\frac{\pi}{\lambda}} \quad (\lambda > 0) \\[1em]
\int_{-\infty}^{+\infty} e^{- \lambda x^2} \,dx = \Gamma \left( \frac{1}{2} \right) \lambda^{-\frac{1}{2}} \quad (\lambda > 0) \\[1em]
\text{两边对}\lambda\text{求导可以得到x的偶数次幂乘e}\\[1em]
\Gamma \left( \frac{1}{2} \right) = \sqrt{\pi} \qquad n\Gamma(n) = \Gamma(n+1)
$$
