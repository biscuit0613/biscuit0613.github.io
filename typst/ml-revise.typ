#import "@preview/boxed-sheet:0.1.0": cheatsheet, concept-block, inline

#import "@preview/tablem:0.3.0": *


#set text(font: ("Noto Serif CJK SC",), size: 7.5pt)

#show: cheatsheet.with(
  title: "模式识别与机器学习 · 复习总纲",
  // 符号约定：bold(x) 向量 | bold(X) 矩阵 | x,n 标量 | cal(X) 集合/函数
  authors: "",
  write-title: true,
  title-align: center,
  num-columns: 2,
  column-gutter: 6pt,
  font-size: 12pt,
  line-skip: 5.8pt,
  x-margin: 20pt,
  y-margin: 10pt,
  numbered-units: false,
)

#concept-block(body: [
  *符号约定*：$bold(x)$ 向量／$bold(X)$ 矩阵／$x, n$ 标量／$cal(X)$ 集合 ·
  所有样本数 $n$，特征维数 $d$，类别数 $K$，聚类/分量数 $K$ · 上标 $((l))$ 表示第 $l$ 层
])

#inline[线性回归]

#concept-block(body: [

  回归虽然叫回归，但本质是解决分类问题，只是给分类问题提供了数学方法。

  $bold(y) = bold(X) bold(w) + bold(epsilon)$ 
  
  *损失函数*用最小二乘法（均方误差MSE）

  $L(bold(w)) = sum_(i=1)^n (y_i - bold(w)^T bold(x)_i)^2$

  （$bold(X) in bb(R)^(n times d)$ 设计矩阵，$bold(y)$ 输出向量$y_i$是真实标签）

  *OLS 闭式解*：
  $bold(hat(w)) = (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)$

  *梯度下降法*：
  $nabla L(bold(w)) = - bold(X)^T (bold(y) - bold(X) bold(w))$

    - 更新规则（SGD）：
      $bold(w) <- bold(w) - eta nabla L(bold(w))$

  *Ridge 回归*（L2 正则化）：
  $J(bold(w)) = sum_(i=1)^n (y_i - bold(w)^T bold(x)_i)^2 + lambda ||bold(w)||_2^2$ $arrow$
  $bold(hat(w)) = (bold(X)^T bold(X) + lambda bold(I))^(-1) bold(X)^T bold(y)$

  *Lasso 回归*（L1 正则化）：
  $J(bold(w)) = sum_(i=1)^n (y_i - bold(w)^T bold(x)_i)^2 + lambda ||bold(w)||_1$ 还做特征选择，把不重要的权重压成0

  *偏差-方差分解*：
  $ "MSE"(bold(x)) = "Bias"^2(hat(f)(bold(x))) + "Var"(hat(f)(bold(x))) + sigma_epsilon^2 $
])

#concept-block(body: [
  *典型计算题*：给定 3-5 个样本 $(x_i, y_i)$（$x_i$ 为标量输入），手算一元 OLS 系数 $hat(w)_0, hat(w)_1$。
 
  步骤：
  $bar(x) = frac(sum x_i, n), bar(y) = frac(sum y_i, n)$
  $hat(w)_1 = frac(sum (x_i - bar(x))(y_i - bar(y)),sum (x_i - bar(x))^2)$
  $hat(w)_0 = bar(y) - hat(w)_1 bar(x)$
])

#inline[📗 逻辑回归]

#concept-block(body: [
  *Sigmoid 函数*把回归的输出压缩到 $(0, 1)$ 区间：

  $sigma(z) = frac(1, 1 + "e"^(-z));z=bold(w)^T bold(x)$

  两个重要的对数：

  $log sigma(z) = -log(1 + "e"^(-z))=z-log(1 + "e"^z)\
  log(1 - sigma(z)) = -log(1 + "e"^z) = -log(1 + "e"^z) 
  $

  *模型输出*（2类，$y_i in {0,1}$ 真实标签，$P(y_i=1|bold(x)_i)$ 预测概率）：

  $P(y_i = 1 | bold(x)_i) = sigma(bold(w)^T bold(x)_i)$ ;

  $P(y_i = 0 | bold(x)_i) = 1 - sigma(bold(w)^T bold(x)_i)$

  MLE损失函数（需要最大化，对数似然再添负号得到交叉熵）：

  $L(bold(w)) = Pi_(i=1)^n P(y_i|bold(x)_i)=Pi_(i=1)^n [P(y_i=1|bold(x)_i)^{y_i} P(y_i=0|bold(x)_i)^{1-y_i}]$

  *交叉熵损失*（需要最小化）：

  $J(w)=- log L(bold(w))
  =- sum_(i=1)^n [y_i log sigma(bold(w)^T bold(x)_i) + (1 - y_i) log(1 - sigma(bold(w)^T bold(x)_i))] \
  =- sum_(i=1)^n [y_i bold(w)^T bold(x)_i - log(1 + "e"^(bold(w)^T bold(x)_i))]
  $

  *梯度*（估计-真实,是预测误差）
  
  - 对于单个样本：

    $nabla J(bold(w)) = (sigma(bold(w)^T bold(x)_i) - y_i) bold(x)_i$

  - 对于多个样本(批量梯度,有没有 1/n无所谓)：

    $nabla J(bold(w)) = sum_(i=1)^n (sigma(bold(w)^T bold(x)_i) - y_i) bold(x)_i$

  - *更新规则*（SGD）：

    $bold(w) <- bold(w) - eta nabla J(bold(w))$

  *多类 Softmax*（$bold(w)_k$ 为第 $k$ 类权重向量）：
  $P(y = k | bold(x)) = frac("exp"(bold(w)_k^T bold(x)),sum_(j=1)^K "exp"(bold(w)_j^T bold(x)))$
])

#concept-block(body: [
  *典型计算题*：给定 2-3 个样本，学习率$eta$ + 初始 $bold(w)$，手算一次梯度下降更新。

  步骤：
  1. 计算 $sigma(bold(w)^T bold(x)_i)$
  2. 计算梯度 $nabla J = sum (sigma(bold(w)^T bold(x)_i) - y_i) bold(x)_i$
  3. 更新 $bold(w) <- bold(w) - eta nabla J$
])

#inline[🧠 感知机(只会线性可分，Xor不会)]

#concept-block(body: [

  逻辑回归的激活函数是平滑的 Sigmoid 函数；而感知机用的是非此即彼的 符号函数（sign），输出是离散的类别标签（+1或-1），而不是概率。

  *决策函数*（增广+规范化）：
  $g(bold(x)) = bold(w)^T bold(x)$

  *增广操作*：将原特征增广 $tilde(bold(x)) = (x_1,dots,x_d,1)^T$，使得决策函数变为 $g(bold(x)) = bold(w)^T tilde(bold(x))$，其中 $bold(w)$ 的最后一维是偏置项。

  *规范化操作*：将原特征增广 $tilde(bold(x)) = (x_1,dots,x_d,1)^T$，再将 *负类*（$y=-1$）样本的 $tilde(bold(x))$ 取反成为 $-tilde(bold(x))$。使得正确分类时恒有 $bold(w)^T bold(x) > 0$，准则函数简化为 $J_p = sum_(bold(x) in cal(X)) - bold(w)^T bold(x)$（仅对错分类样本求和）。

  *准则函数*（错分类驱动+增广+规范化）：
  $J_p(bold(w)) = sum_(bold(x) in cal(X)) - bold(w)^T bold(x)$

  *梯度*（增广+规范化）：
  $nabla J_p(bold(w)) = sum_(bold(x) in cal(X)) - bold(x)$

  *更新规则*（单样本 SGD+增广+规范化）：
  $bold(w) <- bold(w) + eta bold(x)_i quad (text("当") bold(w)^T bold(x)_i <= 0)$

  ps:如果不规范化的话，规则变成 $bold(w) <- bold(w) + eta y_i bold(x)_i quad (text("当") y_i bold(w)^T bold(x)_i <= 0)$

  *典型计算题*：给定 4 个 2D 点 + 初始 $bold(w)$，手算 2-3 轮感知机迭代。注意需要先增广+规范化，再判断 $bold(w)^T bold(x)_i <= 0$
])

#inline[⚡ SVM（线性可分，硬间隔情况下，SVM不用增广）]

#concept-block(body: [
  *间隔*$gamma$：$gamma_i = y_i (bold(w)^T bold(x)_i + b)$，$gamma = min_i gamma_i$ 需要最大化 $gamma$，即最大间隔（极大极小问题）。

  *支持向量*：间隔等于最小间隔的样本点，$gamma_i = gamma$，这些点就是支持向量。

  *原始问题*（$y_i in {-1, +1}$, $bold(w)$ 法向量, $b$ 偏置）：

  $min_(bold(w), b) frac(1, 2) ||bold(w)||^2$
  $text("s.t.") y_i (bold(w)^T bold(x)_i + b) >= 1$

  *拉格朗日函数*（$alpha_i >= 0$ 为 Lagrange 乘子）：
  $cal(L)(bold(w), b, bold(alpha)) = frac(1, 2) ||bold(w)||^2 - sum_(i=1)^n alpha_i [y_i (bold(w)^T bold(x)_i + b) - 1]$

  *KKT 条件*（支持向量条件）：
  $alpha_i >= 0, quad alpha_i [y_i (bold(w)^T bold(x)_i + b) - 1] = 0$

  *对偶问题*（求解$bold(alpha)$）：
  $max_(bold(alpha)) sum_(i=1)^n alpha_i - frac(1, 2) sum_(i=1)^n sum_(j=1)^n alpha_i alpha_j y_i y_j bold(x)_i^T bold(x)_j$
  $text("s.t.") sum_(i=1)^n alpha_i y_i = 0, quad alpha_i >= 0$

  *解形式*：
  - 权重： $bold(w) = sum_(i=1)^n alpha_i y_i bold(x)_i$ 权重是支持向量的线性组合，非支持向量的 $alpha_i = 0$。
  - 偏置： 任意选一个支持向量 $bold(x)_s$，$b = y_s - bold(w)^T bold(x)_s$

  *决策函数*：
  $f(bold(x)) = "sign"(sum_(i=1)^n alpha_i y_i bold(x)_i^T bold(x) + b)$

  *典型计算题*：考试绝对绝对不会让你用拉格朗日对偶法去解那个庞大的二次规划方程组（那是计算机的活，手算能算到交卷铃响）但是可能考
  1. 给定支持向量$bold(x)_s$，求硬间隔超平面（解方程组得到$bold(w), b$）
  2. 给定支持向量$bold(x)_s$和拉格朗日乘子$bold(alpha)$，求硬间隔超平面（向量加法得到$bold(w), b$）
  3. 利用核函数（或内积）直接预测新样本（往决策函数里代数值）
])

#inline[🔷 核方法与核 SVM]

#concept-block(body: [
  *核技巧*：将对偶问题中的 $bold(x)_i^T bold(x)_j$ 替换为 $kappa(bold(x)_i, bold(x)_j)$

  *常用核函数*：
#tablem[
  | 核 | 公式 | 参数 |
  |---|---|---|
  | 线性核 | $kappa(bold(x)_i, bold(x)_j) = bold(x)_i^T bold(x)_j$ | — |
  | 多项式核 | $kappa(bold(x)_i, bold(x)_j) = (bold(x)_i^T bold(x)_j + c)^d$ | $c, d$ |
  | RBF 核(无穷维) | $kappa(bold(x)_i, bold(x)_j) = "exp"(-gamma ||bold(x)_i - bold(x)_j||^2)$ | $gamma$ |
  | Sigmoid 核 | $kappa(bold(x)_i, bold(x)_j) = tanh(beta bold(x)_i^T bold(x)_j + theta)$ | $beta, theta$ |
]

核函数参数对模型的影响 补充在简答题复习中

  *Mercer 条件*：核矩阵 $K_(i j) = kappa(bold(x)_i, bold(x)_j)$ 半正定,如果核矩阵非半正定，SVM的优化问题将不再是凸优化，无法保证找到全局最优解（会陷入局部最优）。

  *典型计算题*：给定 3 个点，计算 RBF 核矩阵（指定 $gamma$ 值）计算器敲就完事。
])

#inline[📊 神经网络与 BP]

#concept-block(body: [
MLP（Multi-Layer Perceptron，多层感知机）就是神经网络的最初形态。在输入和输出之间塞入了多个隐藏层（Hidden Layers），并且每层都带着非线性的激活函数（Activation Function）。

  *单隐层 MLP 符号*：
  - 输入 $bold(x) in bb(R)^d$，隐层 $bold(z) = sigma(bold(w)^((1)) bold(x) + bold(b)^((1)))$
  - $bold(w_(i j))$ 为第 $i$ 个隐层神经元对输入第 $j$ 维的权重向量，$bold(b_(i))^((1))$ 为偏置向量
  - 输出 $hat(y) = bold(w)^(2)^T bold(z) + b^((2))$（回归）
  - 或 $hat(y) = sigma(bold(w)^(2)^T bold(z) + b^((2)))$（二分类）

  *Sigmoid导数结论*：$sigma'(z) = sigma(z)(1 - sigma(z))$

  *Tanh*：$tanh'(z) = 1 - tanh^2(z)$

  *ReLU*：$max(0, z)' = cases(1 "if" z > 0, 0 "if" z <= 0)$

  *MSE 损失的 BP*（回归，单个样本）：

  $delta^((2)) = hat(y) - y$

  $delta^((1)) = (bold(w)^((2))^T delta^((2))) ⊙ sigma'(bold(w)^((1)) bold(x) + bold(b)^((1)))$

  考试绝对不会手算多层链式求导（那能算一页纸）
])

#concept-block(body: [
  *参数更新*（学习率 $eta$）：
  $bold(w)^((1)) <- bold(w)^((1)) - eta bold(delta)^((1)) bold(x)^T$
  $bold(b)^((1)) <- bold(b)^((1)) - eta bold(delta)^((1))$
  $bold(w)^((2)) <- bold(w)^((2)) - eta bold(delta)^((2)) bold(z)$

  *典型计算题*：给定一个输入 $bold(x)$，一个单隐层网络（隐层 2 神经元），手算前向 + 一次 BP 更新。
])

#inline[🔲 CNN 卷积计算]

#concept-block(body: [
  *卷积尺寸公式*：

  $W_("out") = floor(frac(W_("in") + 2P - K, S)) + 1$

  $H_("out") = floor(frac(H_("in") + 2P - K, S)) + 1$

  $C_("out") = text("卷积核数量")$

  其中 $W, H$ = 宽高，$K$ = 卷积核尺寸，$S$ = 步长，$P$ = padding，
  $C_("in"), C_("out")$ = 输入/输出通道数

  *参数量计算*：
  卷积层参数 = $(K times K times C_("in") + 1) times C_("out")$
  全连接层参数 = $n_("in") times n_("out") + n_("out")$（$n_("in"), n_("out")$ 为输入/输出神经元数）

  *池化输出尺寸*（$K$ = 池化窗口，$S$ = 步长）：
  $W_("out") = floor(frac(W_("in") - K, S)) + 1$

  *典型计算题*：给定 input $(3, 224, 224)$，Conv(64, 3x3, S=1, P=1)，求输出尺寸 + 参数量。
])

#inline[📉 PCA 主成分分析]

#concept-block(body: [
  *中心化*（$bar(bold(x))$ 为样本均值向量）：
  $tilde(bold(x))_i = bold(x)_i - bar(bold(x))$

  *协方差矩阵*（$d times d$，$tilde(bold(X))$ 为中心化数据矩阵，构造的时候尽量让$d times d$小一点方便计算）：

  $bold(Sigma) = frac(1, n) sum_(i=1)^n tilde(bold(x))_i tilde(bold(x))_i^T$
  或 $bold(Sigma) = frac(1, n) tilde(bold(X))^T tilde(bold(X))$

  *目标*：求 $bold(Sigma)$ 的前 $k$ 大特征值对应的特征向量

  步骤：
  1. 中心化数据
  2. 计算协方差矩阵 $bold(Sigma)$
  3. 特征值分解 $bold(Sigma) bold(v) = lambda bold(v)$
  4. 取前 $k$ 个最大特征值对应的 $bold(v)_1, ..., bold(v)_k$
  5. 归一化后组成投影矩阵 $bold(V)_k = [bold(v)_1, ..., bold(v)_k]$ 每一列是一个特征向量。
  6. 投影：$bold(z)_i = bold(V)_k^T tilde(bold(x))_i$

  *方差贡献率*：
  $frac(lambda_j, sum_(i=1)^d lambda_i)$
])

#concept-block(body: [
  *典型计算题*：给定 4 个 2D 点，手算 PCA 第一主成分方向。

  步骤：
  1. 计算均值 $bar(bold(x))$
  2. 中心化
  3. 构造 $2 times 2$ 协方差矩阵
  4. 特征值分解（或直接用 $bold(Sigma) bold(v) = lambda bold(v)$ 解出 $lambda, bold(v)$）
  5. 取最大特征值对应的特征向量
])

#inline[🎯 LDA 线性判别分析]

#concept-block(body: [
  *类内散布矩阵*（$cal(C)_k$ 为第 $k$ 类样本集）：
  $bold(S)_W = sum_(k=1)^K sum_(bold(x) in cal(C)_k) (bold(x) - bold(mu)_k)(bold(x) - bold(mu)_k)^T$

  *类间散布矩阵*（$n_k$ 为第 $k$ 类样本数, $bold(mu)$ 为总体均值）：
  $bold(S)_B = sum_(k=1)^K n_k (bold(mu)_k - bold(mu))(bold(mu)_k - bold(mu))^T$

  *广义瑞利商*（二分类）：$bold(w)$ 是投影方向，$bold(S)_B$ 是类间散布矩阵，$bold(S)_W$ 是类内散布矩阵

  $J(bold(w)) = frac(bold(w)^T bold(S)_B bold(w),bold(w)^T bold(S)_W bold(w))$


  *LDA 最优问题*等价于广义特征值分解（固定分母用拉格朗日乘数法）：
  $bold(S)_B bold(w) = lambda bold(S)_W bold(w)$

  *最优投影方向*（两类问题二级结论）：
  $bold(w) ∝ bold(S)_W^(-1) (bold(mu)_1 - bold(mu)_2)$

  *多类扩展*：$K$ 类至多投影到 $K-1$ 维（因为 $bold(S)_B$ 秩 $<= K-1$）

  投影后常用*最近邻*或*阈值*做分类。
])

#concept-block(body: [
  *典型计算题*：两类 2D 点，求最佳投影方向 $bold(w)$。

  数据：$cal(C)_1 = (2,3),(3,4),(4,3)$; $cal(C)_2 = (6,7),(7,8),(8,7)$

  步骤：
  1. 均值：$bold(mu)_1 = (3,3)^T$, $bold(mu)_2 = (7,7)^T$, $bold(mu) = (5,5)^T$
  2. 类内散布：$bold(S)_W = sum_(k=1)^2 sum_(bold(x) in cal(C)_k) (bold(x)-bold(mu)_k)(bold(x)-bold(mu)_k)^T$
  3. 类间散布：$bold(S)_B = sum_(k=1)^2 n_k (bold(mu)_k - bold(mu))(bold(mu)_k - bold(mu))^T$
  4. 投影方向：$bold(w) = bold(S)_W^(-1) (bold(mu)_1 - bold(mu)_2)$
  5.（可选）投影 $y_i = bold(w)^T bold(x)_i$，设阈值分类。
])

#inline[🧮 K-means 聚类]

#concept-block(body: [
  *算法步骤*：
  1. 随机初始化 $K$ 个聚类中心 $bold(mu)_1, ..., bold(mu)_K$
  2. 分配A：$c_i = op("argmin")_(k) ||bold(x)_i - bold(mu)_k||^2$ 划归到距离最近的质心所在的簇
  3. 更新U：$bold(mu)_k = frac(1, |cal(C)_k|) sum_(bold(x)_i in cal(C)_k) bold(x)_i$ 新的质心等于簇内所有点的坐标平均值。
  4. 重复 2-3 直到收敛

   *目标函数*（SSE，$cal(C)_k$ 为第 $k$ 簇样本集）：
  $J = sum_(k=1)^K sum_(bold(x)_i in cal(C)_k) ||bold(x)_i - bold(mu)_k||^2$

  *典型计算题*：给定 6 个 2D 点 + 初始中心，手算 2 轮 K-means 迭代（K=2）。
])

#inline[🔄 EM 算法与 GMM，考计算就是扫了马了]

#concept-block(body: [
  K-means 是 GMM 在“方差 Σ→0”且“硬分配”时的特殊极端情况。

  给定样本集 $bold(X) = {bold(x)_1, bold(x)_2, ..., bold(x)_n}$，EM 算法用于估计 GMM 的参数。

  - 下标 $i$ 表示第 $i$ 个样本$bold(x)_i$
  - $k,j$ 表示第 $k$ 和 $j$ 个*高斯*分量。

  *GMM*（$pi_k$ 混合系数, $bold(mu)_k, bold(Sigma)_k$ 第 $k$ 高斯分量均值和协方差）：

  $p(bold(x)_i) = sum_(k=1)^K pi_k cal(N)(bold(x)_i | bold(mu)_k, bold(Sigma)_k)$

  *E 步*（$gamma_(i k) = P(z_i = k | bold(x)_i)$ 第$i$个样本属于第$k$个高斯分量的后验概率）：

  $gamma_(i k) = frac(pi_k cal(N)(bold(x)_i | bold(mu)_k, bold(Sigma)_k),sum_(j=1)^K pi_j cal(N)(bold(x)_i | bold(mu)_j, bold(Sigma)_j))$

  *M 步*：

  更新混合系数 $hat(pi)_k = frac(1, n) sum_(i=1)^n gamma_(i k)$

  更新均值 $hat(bold(mu))_k = frac(sum_(i=1)^n gamma_(i k) bold(x)_i,sum_(i=1)^n gamma_(i k))$

  更新协方差 $hat(bold(Sigma))_k = frac(sum_(i=1)^n gamma_(i k) (bold(x)_i - hat(bold(mu))_k)(bold(x)_i - hat(bold(mu))_k)^T,sum_(i=1)^n gamma_(i k))$

  *典型计算题*：算你吗
])

#inline[🌳 决策树]

#concept-block(body: [
  *熵*（$D$ 数据集，$K$ 类别数，$p_k$ 第 $k$ 类占比）：
  $H(D) = - sum_(k=1)^K p_k log_2 p_k$

  *条件熵*（$A$ 特征，将 $D$ 分为 $v$ 个子集 $D_1 dots D_v$）：
  $H(D | A) = sum_(j=1)^v frac(|D_j|, |D|) H(D_j)$

  *信息增益*：
  $op("Gain")(D, A) = H(D) - H(D | A)$

  *增益率*：
  $op("GainRatio")(D, A) = frac(op("Gain")(D, A), op("IV")(A))$
  $op("IV")(A) = - sum_(j=1)^v frac(|D_j|, |D|) log_2 frac(|D_j|, |D|)$

  *基尼值*：
  $op("Gini")(D) = 1 - sum_(k=1)^K p_k^2$

  *基尼指数*：
  $op("GiniIndex")(D, A) = sum_(j=1)^v frac(|D_j|, |D|) op("Gini")(D_j)$

  *典型计算题*：给一个分类小数据集（如天气 PlayTennis），手算某个特征的信息增益，选出最佳分裂特征。
])

#concept-block(body: [
  *典型计算题·详解*（决策树信息增益 — 经典 PlayTennis 完整手算）：

  *数据集*（14 天，4 特征 → 是否打网球）：

#tablem[
  | Day | Outlook | Temperature | Humidity | Wind | Play |
  |---|---|---|---|---|---|
  | 1 | Sunny | Hot | High | Weak | No |
  | 2 | Sunny | Hot | High | Strong | No |
  | 3 | Overcast | Hot | High | Weak | Yes |
  | 4 | Rain | Mild | High | Weak | Yes |
  | 5 | Rain | Cool | Normal | Weak | Yes |
  | 6 | Rain | Cool | Normal | Strong | No |
  | 7 | Overcast | Cool | Normal | Strong | Yes |
  | 8 | Sunny | Mild | High | Weak | No |
  | 9 | Sunny | Cool | Normal | Weak | Yes |
  | 10 | Rain | Mild | Normal | Weak | Yes |
  | 11 | Sunny | Mild | Normal | Strong | Yes |
  | 12 | Overcast | Mild | High | Strong | Yes |
  | 13 | Overcast | Hot | Normal | Weak | Yes |
  | 14 | Rain | Mild | High | Strong | No |
]

  *用到的公式*：
  - $H(D) = - sum_(k=1)^K p_k log_2 p_k$（熵）
  - $H(D|A) = sum_(j=1)^v (|D_j|) / (|D|) H(D_j)$（条件熵）
  - $"Gain"(D, A) = H(D) - H(D|A)$（信息增益）

  *符号对应关系*：
  - $D$ = 当前节点数据集（根节点为全部 14 个样本）
  - $D_j$ = 按特征 $A$ 的第 $j$ 个取值分出的子集
  - $A$ = 候选分裂特征（Outlook / Temperature / Humidity / Wind）
  - $|D_j| / |D|$ = 第 $j$ 个子集的权重（样本占比）
  - $p_k$ = 第 $k$ 类（Yes/No）在当前数据集中的占比

  *Step 1 — 根节点熵 $H(D)$*：
  - $D$ = 全部 14 个样本，$K = 2$ 类 {Yes, No}
  - $|D| = 14$，Yes 有 9 个，No 有 5 个

  $H(D) = - 9/14 log_2 (9/14) - 5/14 log_2 (5/14)$ \
  $= -0.6429 times (-0.6375) - 0.3571 times (-1.4855)$ \
  $= 0.4098 + 0.5305 = 0.9403$

  *Step 2 — 按 $A$ = Outlook 分裂*：
  - 取值 $j = 1,2,3$：Sunny($|D_1|=5$), Overcast($|D_2|=4$), Rain($|D_3|=5$)
  - 公式：$H(D | "Outlook") = sum_(j=1)^3 (|D_j| / |D|) H(D_j)$

  ① $D_1$ = Sunny（5 天），Yes=2, No=3：
  $H(D_1) = -2/5 log_2 (2/5) - 3/5 log_2 (3/5)$ \
  $= -0.4 times (-1.3219) - 0.6 times (-0.7370)$ \
  $= 0.5288 + 0.4422 = 0.9710$

  ② Overcast（Yes=4, No=0）：
  $H("Overcast") = -1 log_2 1 - 0 log_2 0 = 0$

  ③ Rain（Yes=3, No=2）：
  $H("Rain") = -3/5 log_2 (3/5) - 2/5 log_2 (2/5) = 0.9710$（对称）

  $H(D | "Outlook") = 5/14 times 0.9710 + 4/14 times 0 + 5/14 times 0.9710$ \
  $= 0.3468 + 0 + 0.3468 = 0.6936$ \
  $"Gain"(D, "Outlook") = 0.9403 - 0.6936 = 0.2467$

  *Step 3 — 按 $A$ = Temperature 分裂*：
  - $j=1,2,3$：Hot($|D_1|=4$), Mild($|D_2|=6$), Cool($|D_3|=4$)

  ① Hot（Yes=2, No=2）：
  $H("Hot") = -2/4 log_2 (2/4) - 2/4 log_2 (2/4) = 2 times (-0.5 times -1) = 1.0$

  ② Mild（Yes=4, No=2）：
  $H("Mild") = -4/6 log_2 (4/6) - 2/6 log_2 (2/6)$ \
  $= -0.6667 times (-0.5850) - 0.3333 times (-1.5850)$ \
  $= 0.3900 + 0.5283 = 0.9183$

  ③ Cool（Yes=3, No=1）：
  $H("Cool") = -3/4 log_2 (3/4) - 1/4 log_2 (1/4)$ \
  $= -0.75 times (-0.4150) - 0.25 times (-2) = 0.8113$

  $H(D | "Temp") = 4/14 times 1.0 + 6/14 times 0.9183 + 4/14 times 0.8113$ \
  $= 0.2857 + 0.3936 + 0.2318 = 0.9111$ \
  $"Gain"(D, "Temp") = 0.9403 - 0.9111 = 0.0292$

  *Step 4 — 按 $A$ = Humidity 分裂*：
  - $j=1,2$：High($|D_1|=7$), Normal($|D_2|=7$)

  ① High（Yes=3, No=4）：
  $H("High") = -3/7 log_2 (3/7) - 4/7 log_2 (4/7)$ \
  $= -0.4286 times (-1.2224) - 0.5714 times (-0.8074)$ \
  $= 0.5239 + 0.4614 = 0.9852$

  ② Normal（Yes=6, No=1）：
  $H("Normal") = -6/7 log_2 (6/7) - 1/7 log_2 (1/7)$ \
  $= -0.8571 times (-0.2224) - 0.1429 times (-2.8074)$ \
  $= 0.1906 + 0.4011 = 0.5917$

  $H(D | "Humidity") = 7/14 times 0.9852 + 7/14 times 0.5917$ \
  $= 0.4926 + 0.2959 = 0.7885$ \
  $"Gain"(D, "Humidity") = 0.9403 - 0.7885 = 0.1518$

  *Step 5 — 按 $A$ = Wind 分裂*：
  - $j=1,2$：Weak($|D_1|=8$), Strong($|D_2|=6$)

  ① Weak（Yes=6, No=2）：
  $H("Weak") = -6/8 log_2 (6/8) - 2/8 log_2 (2/8)$ \
  $= -0.75 times (-0.4150) - 0.25 times (-2) = 0.8113$

  ② Strong（Yes=3, No=3）：
  $H("Strong") = -3/6 log_2 (3/6) - 3/6 log_2 (3/6) = 2 times (-0.5 times -1) = 1.0$

  $H(D | "Wind") = 8/14 times 0.8113 + 6/14 times 1.0$ \
  $= 0.4636 + 0.4286 = 0.8922$ \
  $"Gain"(D, "Wind") = 0.9403 - 0.8922 = 0.0481$

  *汇总对比*：

  $"Gain"(D, "Outlook") = 0.2467$ ← 最大！\
  $"Gain"(D, "Humidity") = 0.1518$ \
  $"Gain"(D, "Wind") = 0.0481$ \
  $"Gain"(D, "Temp") = 0.0292$ \

  *结论*：根节点选 *Outlook* 分裂，Yes 集中在 Overcast，完成第一层划分。
])

#inline[📏 模型评估]

#concept-block(body: [
  *交叉验证*：
  - Hold-out：$"train" : "test" = 7:3$ 或 $8:2$
  - $k$-fold CV：分成 $k$ 份，轮流 1 份验证其余训练
  - LOOCV：$k = n$，每次留 1 个样本验证

  *混淆矩阵*（二分类）：
  $ "Accuracy" = ("TP" + "TN") / ("TP" + "TN" + "FP" + "FN") $
  $ "Precision" = "TP" / ("TP" + "FP") $
  $ "Recall" = "TP" / ("TP" + "FN") $
  $ F_1 = 2 times ("Precision" times "Recall") / ("Precision" + "Recall") $

  *AUC*：ROC 曲线下面积，越接近 1 越好

  *典型计算题*：给定混淆矩阵，计算 Acc / Prec / Recall / F1。
])

#inline[🔣 信息论基础]

#concept-block(body: [
  *熵*（$X$ 离散随机变量，$P(x_i)$ 概率质量函数）：
  $H(X) = - sum_(i) P(x_i) log_2 P(x_i)$

  *联合熵*：
  $H(X, Y) = - sum_(i, j) P(x_i, y_j) log_2 P(x_i, y_j)$

  *条件熵*：
  $H(Y | X) = sum_(i) P(x_i) H(Y | X = x_i)$

  *互信息*：
  $I(X; Y) = H(Y) - H(Y | X) = H(X) - H(X | Y)$

  *KL 散度*（$P, Q$ 为两个概率分布）：
  $D_("KL")(P || Q) = sum_(i) P(i) log_2 frac(P(i), Q(i))$

  *典型计算题*：给定联合分布表 $P(X, Y)$，计算 $H(X)$, $H(Y)$, $H(X,Y)$, $I(X;Y)$。
])

#inline[🌊 朴素贝叶斯分类器]

#concept-block(body: [
  *Bayes 定理*（$y=1, dots, c$ 类别, $bold(x) = (x_1,dots,x_d)$ 特征向量）：
  $P(y | bold(x)) = frac(P(bold(x) | y) P(y), P(bold(x))) ∝ P(y) product_(j=1)^d P(x_j | y)$

  *朴素假设*：各特征($x_1, ..., x_d$)在给定类别下*条件独立*
  $P(bold(x) | y) = P(x_1, x_2, dots, x_d | y) = product_(j=1)^d P(x_j | y)$

  *判别规则*（选后验最大的类）：
  $hat(y) = op("argmax")_(k) P(y = k) product_(j=1)^d P(x_j | y = k)$

  *对数形式*（数值稳定）：
  $hat(y) = op("argmax")_(k) [ln P(y = k) + sum_(j=1)^d ln P(x_j | y = k)]$

  *高斯朴素贝叶斯*（连续特征 $x_j$, 每类每特征正态分布）：
  $P(x_j | y = k) = frac(1, sqrt(2 pi sigma_(k j)^2)) "exp"(-frac((x_j - mu_(k j))^2, 2 sigma_(k j)^2))$

  *MLE 参数估计*（第 $k$ 类第 $j$ 个特征）：
  $hat(mu)_(k j) = frac(1, n_k) sum_(i: y_i = k) x_(i j), quad hat(sigma)_(k j)^2 = frac(1, n_k) sum_(i: y_i = k) (x_(i j) - hat(mu)_(k j))^2$
])

#concept-block(body: [
  计算过程: \
  1. *先验估计(数数）*：$P(y = k) = frac(n_k, n)$（$n_k$ 为第 $k$ 类样本数）

  2. *似然估计* 
  - 离散情况（更仔细的数数）*拉普拉斯平滑*（$alpha = 1$，$v$ 为特征取值数）：
  $P(x_j | y = k) = frac(N_(k j) + 1, n_k + v)$
  - 连续情况（高斯分布套概率密度公式）先算第 $k$ 类第 $j$ 个特征的均值和方差(直接算或者用MLE)：
  $P(x_j | y = k) = frac(1, sqrt(2 pi sigma_(k j)^2)) "exp"(-frac((x_j - mu_(k j))^2, 2 sigma_(k j)^2))$

  3. *预测*：新样本$bold(x)$带入似然(样本$bold(x)$有d个特征,类别$y$有$c$个，则有$c times d$个似然值)，再乘以先验（多类问题每个类别需要连乘$d$次，转化成log求和），选后验最大的类。
])

#concept-block(body: [
  *典型计算题①*（天气-风力-活动，3类）：

  训练集 8 样本，特征：天气{晴,阴,雨}（$v=3$），风力{强,弱}（$v=2$）

  先验：$P(R)=3/8$, $P(H)=3/8$, $P(S)=2/8$

  新样本 {阴, 强}，*不加平滑*：

#tablem[
  | 类别 | 先验 | $P(阴\|y)$ | $P(强\|y)$ | 得分 |
  |---|---|---|---|---|
  | Run | 3/8 | 1/3 | 2/3 | 0.0556 |
  | Hike | 3/8 | 2/3 | 0/3 | *0* |
  | Swim | 2/8 | 0/2 | 1/2 | *0* |
]
  *零概率陷阱*：Hike 的"强"和 Swim 的"阴"频数为 0 → 后验归零！

  *拉普拉斯平滑后*（分子 $+1$，天气分母 $+3$，风力分母 $+2$）：

#tablem[
  | 类别 | $P(阴\|y)$ | $P(强\|y)$ | 得分 |
  |---|---|---|---|
  | Run | (1+1)/(3+3)=2/6 | (2+1)/(3+2)=3/5 | $0.375 times 2/6 times 3/5 = 0.075$ |
  | Hike | (2+1)/(3+3)=3/6 | (0+1)/(3+2)=1/5 | $0.375 times 3/6 times 1/5 = 0.0375$ |
  | Swim | (0+1)/(2+3)=1/5 | (1+1)/(2+2)=2/4 | $0.25 times 1/5 times 2/4 = 0.025$ |
]

  *结论*：$0.075 > 0.0375 > 0.025$ → 预测为 *跑步 (Run)* ✅
])

#concept-block(body: [
  *典型计算题②*（高斯 NB 多维特征 — 鸢尾花分类）：

  训练集 150 样本，3 品种（Setosa / Versicolor / Virginica），每品种 $n_k = 50$。
  特征：$x_1$ = 花瓣长度(cm), $x_2$ = 花瓣宽度(cm)。

#tablem[
  | 品种 $k$ | $mu_1$ | $sigma_1^2$ | $mu_2$ | $sigma_2^2$ |
  |---|---|---|---|---|
  | Setosa | 1.5 | 0.10 | 0.3 | 0.01 |
  | Versicolor | 4.5 | 0.30 | 1.5 | 0.08 |
  | Virginica | 6.0 | 0.50 | 2.0 | 0.10 |
]

  测试样本 $bold(x) = (5.0, 1.8)$。

  *关键式子*（朴素假设 → 各维独立，概率密度连乘）：
  $P(y = k | bold(x)) ∝ P(y = k) product_(j=1)^2 frac(1, sqrt(2 pi sigma_(k j)^2)) "exp"(-frac((x_j - mu_(k j))^2, 2 sigma_(k j)^2))$

  *代入 Versicolor,剩下同理*（$k=2$）：
  $P(y=2 | bold(x)) ∝ frac(50, 150) times frac(1, sqrt(2 pi times 0.30)) "exp"(-frac((5.0-4.5)^2, 2 times 0.30)) times frac(1, sqrt(2 pi times 0.08)) "exp"(-frac((1.8-1.5)^2, 2 times 0.08))$

  *决策*：分别代入 $k=1,2,3$ 计算后验（取 log 避免下溢），选最大者。
])

#inline[📐 参数估计 MLE]

#concept-block(body: [
  *MLE 通用步骤*：
  1. 写出似然函数 $L(theta) = product_(i=1)^n p(x_i | theta)$
  2. 取对数 $ln L(theta) = sum ln p(x_i | theta)$（连乘→连加）
  3. 对 $theta$ 求导，令为零 $(partial ln L)/(partial theta) = 0$
  4. 解出 $hat(theta)$
  5.（可选）求二阶导验证最大值

  *① Bernoulli MLE（抛硬币）*：
  - 数据：$x_i in {0,1}$，$P(x=1)=p$，$P(x=0)=1-p$
  - 似然：$L(p) = product p^(x_i) (1-p)^(1-x_i)$
  - 对数似然：$ln L = (sum x_i) ln p + (n - sum x_i) ln(1-p)$
  - 求导：$(partial ln L)/(partial p) = (sum x_i)/p - (n - sum x_i)/(1-p) = 0$
  - 解得：$hat(p)_"MLE" = (1/n) sum x_i = bar(x)$（正面向上的频率）

  *② Gaussian MLE（均值和方差）*：
  - 数据：$x_i ~ cal(N)(mu, sigma^2)$，i.i.d.
  - 似然：$L(mu, sigma^2) = product 1/(sqrt(2 pi sigma^2)) "exp"(-(x_i - mu)^2/(2 sigma^2))$
  - 对数似然：$ln L = -(n/2) ln(2 pi) - (n/2) ln sigma^2 - 1/(2 sigma^2) sum (x_i - mu)^2$
  - 对 $mu$ 求导：$(partial ln L)/(partial mu) = 1/(sigma^2) sum (x_i - mu) = 0 =>  hat(mu) = bar(x)$
  - 对 $sigma^2$ 求导（令 $tau = sigma^2$）：
  $(partial ln L)/(partial tau) = -n/(2 tau) + 1/(2 tau^2) sum (x_i - mu)^2 = 0$
  $=>  hat(sigma)^2_("MLE") = (1/n) sum (x_i - bar(x))^2$（有偏！）
  - *无偏修正*：$s^2 = 1/(n-1) sum (x_i - bar(x))^2$
])

#concept-block(body: [
  *③ Poisson MLE*：
  - 数据：$x_i ~ "Pois"(lambda)$，$P(x) = lambda^x "e"^{-lambda} / x!$
  - 似然：$L(lambda) = product lambda^(x_i) "e"^{-lambda} / x_i!$
  - 对数似然：$ln L = (sum x_i) ln lambda - n lambda - sum ln(x_i!)$
  - 求导：$(partial ln L)/(partial lambda) = (sum x_i)/lambda - n = 0$
  - 解得：$hat(lambda)_"MLE" = (1/n) sum x_i = bar(x)$

  *正态分布 MLE 的有偏性验证*：
  对 $cal(N)(mu, sigma^2)$ 的方差 MLE：
  $bb(E)[hat(sigma)^2_"MLE"] = (n-1)/n sigma^2 != sigma^2$
  说明 MLE 方差估计有偏（低估），小样本时需用 $n-1$ 校正。

  *典型计算题①*（Bernoulli MLE）：
  抛硬币 10 次：正、反、正、正、反、正、正、反、正、正
  → 正面 7 次，反面 3 次
  $hat(p)_"MLE" = 7/10 = 0.7$
  若抛 3 次全是正面：$hat(p)_"MLE" = 1$（明显过拟合！）

  *典型计算题②*（Gaussian MLE）：
  给定 5 个样本：2, 4, 6, 8, 10
  $hat(mu)_"MLE" = (2+4+6+8+10)/5 = 6$
  $hat(sigma)^2_"MLE" = (1/5)[(2-6)^2 + (4-6)^2 + (6-6)^2 + (8-6)^2 + (10-6)^2]$
  $= (1/5)(16+4+0+4+16) = 40/5 = 8$
  无偏修正：$s^2 = 40/4 = 10$
])

#inline[⚙️ 已排除考点提示]

#concept-block(
  fill-color: rgb(255, 230, 230),
  body: [
    *不考*：
    1. 随机优化算法（SGD 动量、Adam 等）
    2. 贝叶斯判别准则（包括贝叶斯公式的判别应用）
    3. Dropout
    4. 循环神经网络（RNN）
    5. Transformer

    但以下仍然会考：
    - 感知机（与线性分类器相关）
    - 逻辑回归 + Softmax（线性模型范畴）
    - 简单的梯度下降（非随机优化，仅用于求解逻辑回归/感知机）
  ],
)
