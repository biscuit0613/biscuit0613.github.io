#import "@preview/boxed-sheet:0.1.0": cheatsheet, concept-block, inline

#set text(font: ("Noto Serif CJK SC",), size: 7pt)

#show: cheatsheet.with(
  title: "模式识别与机器学习 · 考前一张纸",
  authors: "",
  write-title: true,
  title-align: center,
  num-columns: 3,
  column-gutter: 4pt,
  font-size: 11pt,
  line-skip: 5pt,
  x-margin: 14pt,
  y-margin: 8pt,
  numbered-units: false,
)

#inline[线性回归 OLS]

#concept-block(body: [
  $bold(hat(w)) = (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)$ \
  *别名*：最小二乘法、普通最小二乘、Normal Equation、正规方程、闭式解 \
  *推导*：$L = ||bold(y) - bold(X) bold(w)||_2^2$，$nabla L = -2 bold(X)^T(bold(y)-bold(X) bold(w)) = 0$
])

#inline[Ridge 回归]

#concept-block(body: [
  $bold(hat(w)) = (bold(X)^T bold(X) + lambda bold(I))^(-1) bold(X)^T bold(y)$ \
  *别名*：岭回归、L2 正则化、Tikhonov 正则化、权重衰减、Weight Decay \
  *推导*：$L = ||bold(y)-bold(X) bold(w)||_2^2 + lambda ||bold(w)||_2^2$，求导为零 \
  *关键*：加入 $lambda bold(I)$ 使 $bold(X)^T bold(X)$ 奇异时仍可逆
])

#inline[Lasso]

#concept-block(body: [
  $min ||bold(y) - bold(X) bold(w)||_2^2 + lambda ||bold(w)||_1$ \
  *别名*：L1 正则化、套索回归 \
  *特点*：无闭式解，解在坐标轴 → 稀疏（自动特征选择）\
  *求解*：坐标下降法 Coordinate Descent、ISTA
])

#inline[逻辑回归]

#concept-block(body: [
  $P(1|x) = sigma(bold(w)^T bold(x)) = 1/(1+"e"^(-bold(w)^T bold(x)))$ \
  *别名*：Logistic Regression、对数几率回归、logit 回归 \
  *损失*：交叉熵 $L = -sum [y_i log hat(y)_i + (1-y_i) log(1-hat(y)_i)]$ \
  *梯度*：$nabla_w L = sum (hat(y)_i - y_i) bold(x)_i$（与 OLS 梯度形式相同！）\
  *关键*：用交叉熵而非 MSE，因为 MSE+Sigmoid = 非凸
])

#inline[感知机]

#concept-block(body: [
  $hat(y) = "sign"(bold(w)^T bold(x) + b)$ \
  *别名*：Perceptron、阈值逻辑单元 \
  *损失*：$L = -sum_(i in M) y_i (bold(w)^T bold(x)_i + b)$（仅错分样本）\
  *更新*：$bold(w) <- bold(w) + eta y_i bold(x)_i$，$b <- b + eta y_i$
])

#inline[SVM — 原始]

#concept-block(body: [
  $min 1/2 ||bold(w)||^2$ \
  s.t. $y_i(bold(w)^T bold(x)_i + b) >= 1$ \
  *别名*：支持向量机、最大间隔分类器、硬间隔 SVM \
  *关键*：间隔 = $2 / ||bold(w)||$ → 最大化间隔 = 最小化 $||bold(w)||^2$ \
  *软间隔*：引入 $xi_i$，目标 $1/2||bold(w)||^2 + C sum xi_i$
])

#inline[SVM — 对偶]

#concept-block(body: [
  $max sum alpha_i - 1/2 sum_i sum_j alpha_i alpha_j y_i y_j bold(x)_i^T bold(x)_j$ \
  s.t. $sum alpha_i y_i = 0, 0 <= alpha_i <= C$ \
  *KKT*：$alpha_i [y_i (bold(w)^T bold(x)_i+b)-1] = 0$ \
  *决策*：$f(x) = "sign"(sum alpha_i y_i K(bold(x)_i, bold(x)) + b)$
])

#inline[核技巧]

#concept-block(body: [
  $K(bold(x)_i, bold(x)_j) = phi(bold(x)_i)^T phi(bold(x)_j)$ \
  *别名*：Kernel Trick、核方法 \
  *常见核*：
  - 线性：$bold(x)_i^T bold(x)_j$
  - 多项式：$(bold(x)_i^T bold(x)_j + c)^d$
  - RBF：$exp(-gamma ||bold(x)_i - bold(x)_j||^2)$
  *Mercer*：核矩阵半正定 ↔ 存在 $phi$ \
  *优点*：隐式高维映射，计算量 O(d) 不变
])

#inline[BP 反向传播]

#concept-block(body: [
  $delta^((l)) = (bold(W)^((l+1)))^T delta^((l+1)) ⊙ sigma'(bold(z)^((l)))$ \
  *别名*：Backpropagation、误差逆传播、链式法则 \
  *推导*：先正向传播到输出 → 计算 $delta^((L)) = partial L / partial bold(a)^((L))$ → 反向传播到各隐层 \
  *输出层权重*：$partial L / partial w_(i j)^((l)) = delta_i^((l)) a_j^((l-1))$
])

#inline[CNN 输出尺寸]

#concept-block(body: [
  $W_("out") = floor((W_("in") + 2P - K)/S) + 1$ \
  *别名*：卷积输出尺寸公式 \
  *P = K/2, S = 1* → 尺寸不变（Same Padding）\
  *参数量*：$K times K times C_("in") times C_("out")$（+ bias）
])

#inline[PCA]

#concept-block(body: [
  $bold(Sigma) bold(w) = lambda bold(w)$ \
  *别名*：主成分分析、Principal Component Analysis、Karhunen-Loève 变换 \
  *两个视角*：① 最大方差 ② 最小重构误差 \
  *步骤*：中心化 → 协方差矩阵 → 特征分解 → 前 k 个特征向量 \
  *降维*：$bold(z) = bold(W)^T bold(x)$，$bold(W)$ 为 top-k 特征向量矩阵
])

#inline[LDA]

#concept-block(body: [
  $bold(S)_B bold(w) = lambda bold(S)_W bold(w)$ \
  *别名*：线性判别分析、Fisher 线性判别、Linear Discriminant Analysis \
  *准则*：瑞利商 $J = (bold(w)^T bold(S)_B bold(w)) / (bold(w)^T bold(S)_W bold(w))$ \
  *解*：$bold(w) ∝ bold(S)_W^(-1)(bold(mu)_1 - bold(mu)_2)$ \
  *多类*：至多 $K-1$ 维
])

#inline[K-means]

#concept-block(body: [
  $min sum_k sum_(i in C_k) ||bold(x)_i - bold(mu)_k||_2^2$ \
  *别名*：K 均值聚类、Lloyd 算法 \
  *E 步*：$c_i = op("argmin")_k ||bold(x)_i - bold(mu)_k||^2$ \
  *M 步*：$bold(mu)_k = (1/(|C_k|)) sum_(i in C_k) bold(x)_i$ \
  *局限*：需预设 K、只凸簇、异常点敏感、初始化敏感
])

#inline[GMM + EM]

#concept-block(body: [
  *E 步*：$gamma_(i k) = (pi_k cal(N)(bold(x)_i | bold(mu)_k, bold(Sigma)_k)) / (sum_j pi_j cal(N)(bold(x)_i | bold(mu)_j, bold(Sigma)_j))$ \


  *M 步*：$bold(mu)_k = (sum gamma_(i k) bold(x)_i) / (sum gamma_(i k))$ \

  $bold(Sigma)_k = (sum gamma_(i k)(bold(x)_i-bold(mu)_k)(bold(x)_i-bold(mu)_k)^T) / (sum gamma_(i k))$ \
  
  $pi_k = (sum gamma_(i k)) / N$ \
  *别名*：高斯混合模型 + 期望最大化 \
  *EM 思想*：固定 θ 估算隐变量（E）→ 固定隐变量优化 θ（M）→ 单调收敛
])

#inline[决策树分裂准则]

#concept-block(body: [
  *熵*：$H(Y) = -sum p_k log_2 p_k$（ID3：信息增益 $"IG" = H(Y) - H(Y|X)$）\
  *增益率*：$"IG" / H(X)$（C4.5，偏好多值属性问题）\
  *基尼*：$"Gini"(Y) = 1 - sum p_k^2$（CART，计算快 无需 log）\
  *别名*：信息增益 / 增益率 / Gini 指数 \
  *预剪枝*：建树时提前停（效率高但过早停）\
  *后剪枝*：建完再剪（效果更好但慢），CART 用 CCP
])

#inline[信息论三角]

#concept-block(body: [
  *熵 Entropy*：$H(P) = -sum P(i) log P(i)$ \
  *交叉熵 Cross-entropy*：$H(P,Q) = -sum P(i) log Q(i) = H(P) + D_("KL")(P||Q)$ \
  *KL 散度*：$D_("KL")(P||Q) = sum P(i) log(P(i)/Q(i))$，非对称！\
  *关系*：交叉熵 = 熵 + KL 散度
])

#inline[模型评估指标]

#concept-block(body: [
  *混淆矩阵*：
  - Accuracy = (TP+TN)/(TP+TN+FP+FN)
  - Precision = TP/(TP+FP)（预测为正的中有多少真）
  - Recall = TP/(TP+FN)（真正正类找回多少）
  - Specificity = TN/(TN+FP)（真正负类找回多少）
  - $F_1 = 2 P R/(P + R)$（P 和 R 的调和平均）
  *ROC 曲线*：TPR vs FPR，AUC = 下方面积 \
  *TPR = Recall*，*FPR = FP/(FP+TN)*
])

#inline[朴素贝叶斯]

#concept-block(body: [
  $P(y|x) ∝ P(y) product P(x_i | y)$ \
  *别名*：Naive Bayes、朴素贝叶斯、条件独立假设 \
  *"朴素"*：特征在给定类别下条件独立 → 参数量从指数降到线性 \
  *平滑*：$P(x_i=v|y=c) = (N_(v c) + alpha)/(N_c + alpha V)$（拉普拉斯 / Lidstone）\
  *高斯 NB*：$P(x_i | y) = cal(N)(x_i | mu_(i y), sigma_(i y)^2)$
])

#inline[K 近邻]

#concept-block(body: [
  *别名*：KNN、K-Nearest Neighbors、距离分类器、惰性学习、Lazy Learning \
  *核心*：给定 $bold(x)$，找训练集中最近的 $K$ 个邻居，投票（分类）/ 平均（回归）\
  *距离度量*：欧氏距离 $||bold(x)-bold(x)_i||_2$、曼哈顿 $||bold(x)-bold(x)_i||_1$、余弦、马氏 \
  *关键参数*：$K$（小 → 过拟合 / 大 → 欠拟合）、距离权重（等权 / 反距离加权）\
  *特点*：无训练过程（记忆型）、非参数、决策边界非线性、维度灾难（高维需降维）\
  *懒惰vs急切*：KNN 无显式训练/决策函数；SVM/决策树需训练得到模型参数
])

#inline[集成学习]

#concept-block(body: [
  *Bagging*：并行训练、有放回采样、投票/平均 → 降方差 \
  *Boosting*：串行训练、调整样本权重 → 降偏差 \
  *随机森林*：Bagging + 随机特征选择 \
  *AdaBoost*：增加错分样本权重 \
  *GBDT*：每轮拟合前轮残差（负梯度）
])

#inline[Batch/Layer Norm]

#concept-block(body: [
  *BN*（跨样本）：$hat(x)_j = (x_j - mu_(cal(B), j)) / sqrt(sigma_(cal(B))^2 + epsilon)$ \
  *LN*（跨特征）：$hat(x)_i = (x_i - mu_i) / sqrt(sigma_i^2 + epsilon)$ \
  *BN 别名*：Batch Normalization、批归一化 \
  *LN 别名*：Layer Normalization、层归一化 \
  *BN 缺点*：依赖 batch size，小 batch 不稳定 \
  *LN 优点*：不受 batch 影响，适合 RNN/Transformer
])

#inline[MLE vs 贝叶斯]

#concept-block(body: [
  *MLE*：$hat(theta) = op("argmax")_theta P(D | theta)$（点估计，小样本易过拟合）\
  *MAP*：$hat(theta) = op("argmax")_theta P(D | theta) p(theta)$（点估计 + 先验）\
  *贝叶斯*：$p(theta | D) ∝ P(D | theta) p(theta)$（后验分布，全概率积分）\
  *共轭先验*：先验和后验同分布族（Beta-Bernoulli、Dirichlet-Multinomial、Gaussian-Gaussian）
])
