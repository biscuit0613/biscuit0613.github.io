#import "@preview/boxed-sheet:0.1.0": cheatsheet, concept-block, inline

#set text(font: ("Noto Serif CJK SC",), size: 7.5pt)

#show: cheatsheet.with(
  title: "模式识别与机器学习 · 公式证明",
  authors: "",
  write-title: true,
  title-align: center,
  num-columns: 2,
  column-gutter: 6pt,
  font-size: 12pt,
  line-skip: 6pt,
  x-margin: 20pt,
  y-margin: 10pt,
  numbered-units: false,
)

#concept-block(body: [
  *符号约定*：$bold(x)$ 向量／$bold(X)$ 矩阵／$x, n$ 标量 · $n$ 样本数，$d$ 维数 · 行向量样本，列向量特征？本文按列向量记
])

#inline[① OLS 闭式解推导]

#concept-block(body: [
  *目标*：$L(bold(w)) = ||bold(y) - bold(X)bold(w)||_2^2$ \
  *展开*：$L = (bold(y)-bold(X)bold(w))^T (bold(y)-bold(X)bold(w))$ \
  $= bold(y)^T bold(y) - 2 bold(w)^T bold(X)^T bold(y) + bold(w)^T bold(X)^T bold(X) bold(w)$ \

  *求导*（标量对向量）：
  $nabla L = - 2 bold(X)^T bold(y) + 2 bold(X)^T bold(X) bold(w)$ \

  *令梯度为零*：
  $bold(X)^T bold(X) bold(w) = bold(X)^T bold(y)$ \
  $=> bold(hat(w)) = (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)$ \
  *前提*：$bold(X)^T bold(X)$ 可逆（列满秩）
])

#inline[② Ridge 闭式解推导]

#concept-block(body: [
  *目标*：$J(bold(w)) = ||bold(y)-bold(X)bold(w)||_2^2 + lambda ||bold(w)||_2^2$ \
  *展开求导*同理：
  $nabla J = -2 bold(X)^T (bold(y)-bold(X)bold(w)) + 2 lambda bold(w)$ \
  $= 2(bold(X)^T bold(X)bold(w) - bold(X)^T bold(y) + lambda bold(w))$ \

  *令为零*：
  $(bold(X)^T bold(X) + lambda bold(I)) bold(w) = bold(X)^T bold(y)$ \
  $=>  bold(hat(w)) = (bold(X)^T bold(X) + lambda bold(I))^(-1) bold(X)^T bold(y)$ \

  *对比 OLS*：即使 $bold(X)^T bold(X)$ 奇异，加上 $lambda bold(I)$ 后恒可逆
])

#inline[③ Sigmoid 导数]

#concept-block(body: [
  $sigma(z) = 1/(1 + "e"^{-z})$ \

  $sigma'(z) = d/(d z) (1 + "e"^(-z))^(-1)$ \
  $= -(1 + "e"^(-z))^(-2) times (-"e"^(-z))$ \
  $= ("e"^(-z))/((1 + "e"^(-z))^2)$ \

  分子分母同乘 $("e"^z)^2$：
  $= ("e"^z)/((1 + "e"^z)^2)$ \

  改写为 $sigma$ 形式：
  $sigma'(z) = 1/(1+"e"^{-z}) times ("e"^{-z})/(1+"e"^{-z})$ \
  $= sigma(z) times (1 - sigma(z))$ \
  *关键性质*：$sigma'(z) = sigma(z)(1-sigma(z))$，峰顶 $z=0$ 处导数为 $1/4$
])

#inline[④ 逻辑回归梯度推导]

#concept-block(body: [
  *交叉熵损失*（单个样本 $bold(x)_i, y_i in {0,1}$）：

  $J_i = -[y_i log sigma(bold(w)^T bold(x)_i) + (1-y_i) log(1 - sigma(bold(w)^T bold(x)_i))]$ \

  *求梯度*（链式法则）：
  $(partial J_i)/(partial bold(w)) = (partial J_i)/(partial sigma) times (partial sigma)/(partial z) times (partial z)/(partial bold(w))$ \
  其中 $z = bold(w)^T bold(x)_i$，$hat(y)_i = sigma(z)$

  *三项分别计算*：

  $(partial J_i)/(partial sigma) = -(y_i/sigma - (1-y_i)/(1-sigma))$ \

  $(partial sigma)/(partial z) = sigma (1-sigma)$ \

  $(partial z)/(partial bold(w)) = bold(x)_i$ \

  *代入链式*：

  $= -(y_i/sigma - (1-y_i)/(1-sigma)) times sigma(1-sigma) times bold(x)_i$ \
  $= -(y_i(1-sigma) - (1-y_i)sigma) times bold(x)_i$ \
  $= -(y_i - y_i sigma - sigma + y_i sigma) times bold(x)_i$ \
  $= -(y_i - sigma) times bold(x)_i$ \

  *结果*：$nabla J_i = (sigma(bold(w)^T bold(x)_i) - y_i) bold(x)_i$ \
  *解释*：梯度 = 预测误差 $times$ 输入特征（与 OLS 形式完全相同！）
])

#inline[⑤ Softmax + 交叉熵梯度]

#concept-block(body: [
  *Softmax*（$p_k = "exp"(bold(w)_k^T bold(x)) / (sum_(j=1)^K "exp"(bold(w)_j^T bold(x)))$）\

  *交叉熵*（$y in {1,...,K}$ 为真实类别，独热编码 $t_k = 1_{y=k}$）：

  $L = - sum_(k=1)^K t_k log p_k = - log p_y$ \

  *关键结论*（$k=y$ 和 $k != y$ 分开讨论）：

  当 $k = y$（真实类）：
  $(partial L)/(partial bold(w)_y) = (p_y - 1) bold(x)$

  当 $k != y$（非真实类）：
  $(partial L)/(partial bold(w)_k) = p_k bold(x)$ \

  *统一形式*：$(partial L)/(partial bold(w)_k) = (p_k - t_k) bold(x)$ \

  *推导要点*：$(partial p_k) / (partial bold(w)_y) = p_k (1 - p_k)$ 当 $k=y$；$(partial p_k) / (partial bold(w)_j) = -p_k p_j$ 当 $k!=j$
])

#inline[⑥ SVM 原始 → 对偶]

#concept-block(body: [
  *原始问题*：
  $min 1/2 ||bold(w)||^2$ s.t. $y_i (bold(w)^T bold(x)_i + b) >= 1$ \

  *Lagrange 函数*（$alpha_i >= 0$）：
  $cal(L) = 1/2 ||bold(w)||^2 - sum alpha_i [y_i (bold(w)^T bold(x)_i + b) - 1]$ \

  *对 $bold(w), b$ 求偏导为零*：

  $(partial cal(L))/(partial bold(w)) = bold(w) - sum alpha_i y_i bold(x)_i = 0 =>  bold(w) = sum alpha_i y_i bold(x)_i$ \
  $(partial cal(L))/(partial b) = -sum alpha_i y_i = 0 =>  sum alpha_i y_i = 0$ \

  *代入消去 $bold(w), b$*：
  $cal(L)(bold(alpha)) = sum alpha_i - 1/2 sum_i sum_j alpha_i alpha_j y_i y_j bold(x)_i^T bold(x)_j$ \

  *KKT 条件*（$alpha_i [y_i(bold(w)^T bold(x)_i + b) - 1] = 0$）：
  - $alpha_i = 0$：非支持向量，不影响分类面
  - $alpha_i > 0$：支持向量（恰在间隔边界上）
])

#inline[⑦ PCA 最大方差推导]

#concept-block(body: [
  *目标*：找 $||bold(w)||=1$ 的方向使投影方差最大 \
  *投影方差*：$"Var"(bold(w)^T bold(x)) = bold(w)^T bold(Sigma) bold(w)$（$bold(Sigma)$ 是协方差矩阵）\

  *约束优化*（拉格朗日乘数法）：
  $cal(L) = bold(w)^T bold(Sigma) bold(w) - lambda(bold(w)^T bold(w) - 1)$ \

  *对 $bold(w)$ 求导为零*：
  $(partial cal(L))/(partial bold(w)) = 2 bold(Sigma) bold(w) - 2 lambda bold(w) = 0$ \
  $=>  bold(Sigma) bold(w) = lambda bold(w)$ \

  *结论*：最优方向是 $bold(Sigma)$ 的特征向量，对应方差 = 特征值 $lambda$ \
  *取前 $k$ 大特征值* → 前 $k$ 个主成分
])

#inline[⑧ LDA 瑞利商推导]

#concept-block(body: [
  *Fisher 准则*（二分类）：
  $J(bold(w)) = (bold(w)^T bold(S)_B bold(w)) / (bold(w)^T bold(S)_W bold(w))$ \

  *令分母 $bold(w)^T bold(S)_W bold(w) = c$（常数一般用1），最大化分子*：

  *拉格朗日函数*：
  $cal(L) = bold(w)^T bold(S)_B bold(w) - lambda(bold(w)^T bold(S)_W bold(w) - c)$ \

  *求导为零*：
  $(partial cal(L))/(partial bold(w)) = 2 bold(S)_B bold(w) - 2 lambda bold(S)_W bold(w) = 0$ \
  $=>  bold(S)_B bold(w) = lambda bold(S)_W bold(w)$（广义特征值问题）\

  *二类特例*：$bold(S)_B bold(w) = lambda bold(S)_W bold(w)$，且 $bold(S)_B bold(w) ∝ (bold(mu)_1 - bold(mu)_2)$ \
  *代入可得*：$bold(w) ∝ bold(S)_W^(-1) (bold(mu)_1 - bold(mu)_2)$
])

#inline[⑨ 偏差-方差分解]

#concept-block(body: [
  *设定*：真实模型 $y = f(bold(x)) + epsilon$，$bb(E)[epsilon]=0$，$"Var"(epsilon)=sigma_epsilon^2$ \
  *预测 $hat(f)(bold(x))$* 的 MSE：

  $"MSE" = bb(E)[(y - hat(f)(bold(x)))^2]$ \

  *分解*（加一项减一项 $bb(E)[hat(f)(bold(x))]$）：
  $= bb(E)[(f + epsilon - hat(f))^2]$ \
  $= bb(E)[(f - hat(f))^2] + bb(E)[epsilon^2] + 2 bb(E)[epsilon(f - hat(f))]$

  由于 $epsilon$ 与 $hat(f)$ 独立且 $bb(E)[epsilon]=0$，交叉项为零：

  $= underbrace((f - bb(E)[hat(f)])^2)_("Bias"^2) + underbrace(bb(E)[(hat(f) - bb(E)[hat(f)])^2])_("Var") + underbrace(sigma_epsilon^2)_("噪声")$ \

  *结论*：MSE = Bias² + Variance + 噪声，三者不可兼得
])

#inline[⑩ EM 算法推导框架]

#concept-block(body: [
  *问题*：含隐变量 $z$，最大化 $ln p(bold(x) | theta)$

  *ELBO 分解*（引入 $q(z)$ 任意分布）：
  $ln p(bold(x)|theta) = cal(L)(q, theta) + "KL"(q || p(z|bold(x),theta))$ \
  其中 $cal(L)(q, theta) = sum_z q(z) ln (p(bold(x), z | theta) / q(z))$ \

  *E 步*：固定 $theta^((t))$，取 $q(z) = p(z | bold(x), theta^((t)))$ → KL = 0 → ELBO = 似然

  *M 步*：固定 $q(z)$，最大化 $cal(L)(q, theta)$（等价于极大化 Q 函数）：
  $Q(theta, theta^((t))) = bb(E)_(z|bold(x), theta^((t)))[ln p(bold(x), z | theta)]$ \

  *收敛性*：E 步使 KL=0 → M 步增 ELBO → 每次迭代似然不减（单调收敛到局部最优）
])

#inline[⑪ 熵-交叉熵-KL 关系]

#concept-block(body: [
  *熵*：$H(P) = -sum P(i) log P(i)$ \
  *交叉熵*：$H(P,Q) = -sum P(i) log Q(i)$ \
  *KL 散度*：$D_("KL")(P || Q) = sum P(i) log(P(i)/Q(i))$ \

  *关系推导*：
  $H(P,Q) = -sum P(i) log Q(i)$ \
  $= -sum P(i) [log P(i) - log(P(i)/Q(i))]$ \
  $= -sum P(i) log P(i) + sum P(i) log(P(i)/Q(i))$ \
  $= H(P) + D_("KL")(P || Q)$ \

  *意义*：交叉熵 = 熵（数据固有不确定性）+ KL（模型与真实分布的额外代价）\
  *非对称性*：$D_("KL")(P||Q) != D_("KL")(Q||P)$，所以交叉熵也不对称
])

#inline[⑫ CNN 输出尺寸公式]

#concept-block(body: [
  输入 $W times H$，卷积核 $K$，步长 $S$，Padding $P$：

  *一维推导*（以宽为例）：
  - 第一个卷积核中心位置：$0$（贴左边界）
  - 最后一个卷积核中心位置：$W_("in") - 1$（贴右边界）
  - 但考虑 padding 后，实际有效输入宽度为 $W_("in") + 2P$
  - 每滑动一次位移 $S$，从 $0$ 到 $W_("in") + 2P - K$ \
  *公式*：
  $W_("out") = floor((W_("in") + 2P - K)/S) + 1$ \

  *Same Padding*：$P = K/2$, $S = 1$ → $W_("out") = W_("in" + K - K)/1 + 1 = W_("in")$ \
  *Valid Padding*：$P = 0$ → $W_("out") = (W_("in") - K)/S + 1$
])

#inline[⑬ K-means 收敛性]

#concept-block(body: [
  *目标函数*（SSE）：
  $J = sum_(k=1)^K sum_(i in C_k) ||bold(x)_i - bold(mu)_k||^2$ \

  *分配步*（固定 $bold(mu)_k$）：每点分配到最近质心 → $J$ 下降或不变 \
  因为 $c_i^(t+1) = op("argmin")_k ||bold(x)_i - bold(mu)_k^(t)||^2$ 是逐点最小化 $J$

  *更新步*（固定 $C_k$）：更新 $bold(mu)_k$ 为簇内均值 → $J$ 下降或不变 \
  因为 $bold(mu)_k = (1/(|C_k|)) sum_(i in C_k) bold(x)_i$ 是 $sum||bold(x)_i - bold(mu)_k||^2$ 的全局最小值 \

  *结论*：每步单调不增 + $J$ 有下界(0) → 必收敛到局部最优 \
  *局限*：非凸，依赖初始化（K-means++ 缓解）
])

#inline[⑭ 信息增益 vs 增益率 vs Gini]

#concept-block(body: [
  *熵*：$H(D) = -sum p_k log_2 p_k$（不确定性度量）\

  *条件熵*：$H(D|A) = sum_j (|D_j|)/(|D|)  H(D_j)$ \

  *信息增益*：$"Gain"(D, A) = H(D) - H(D|A)$ \
  - ID3 使用，偏好取值多的特征（天然"分得细"的信息增益大）

  *增益率*：$"GainRatio" = "Gain" / "IV"(A)$ \
  
  - $"IV"(A) = -sum_j (|D_j|)/(|D|) log_2 (|D_j|)/(|D|)$（特征自身熵）\
  - C4.5 使用，惩罚多值特征，先选 Gain 高于平均的再选 GainRatio 最大

  *Gini*：$"Gini"(D) = 1 - sum p_k^2$ \
  - CART 使用，计算快（无需 log），与熵单调关系
  - 二分类时 $"Gini" = 2p(1-p)$，熵 $approx 1.39 times$ Gini（泰勒展开）
])

#inline[⑮ MLE / MAP / 贝叶斯关系]

#concept-block(body: [
  *MLE*（最大似然估计）：
  $hat(theta)_"MLE" = op("argmax")_theta p(D | theta)$ \
  - 视 $theta$ 为未知常数，仅由数据驱动 \
  - 小样本易过拟合（如抛 3 次硬币都正面 → 估计 $p=1$）

  *MAP*（最大后验估计）：
  $hat(theta)_"MAP" = op("argmax")_theta p(D | theta) p(theta)$ \
  - 引入先验 $p(theta)$ 作为正则项 \
  - 仍是点估计，但先验拉偏（如 Beta(2,2) 先验 → 抛 3 次正面估计 $p=0.8$）

  *全贝叶斯*：
  $p(theta | D) = p(D | theta) p(theta) / p(D)$ \
  - 得到后验*分布*而非点估计 \
  - 预测时对 $theta$ 积分：$p(y|D) = integral p(y|theta) p(theta|D) d theta$ \
  - 计算复杂，通常用共轭先验或 MCMC 近似

  *渐近一致性*：$n -> infinity$ 时，MLE, MAP, 贝叶斯后验均值趋于一致
])
