#import "@preview/boxed-sheet:0.1.0": cheatsheet, concept-block, inline
#import "@preview/tablem:0.3.0": *

#set text(font: ("Noto Serif CJK SC",), size: 7.5pt)

#show: cheatsheet.with(
  title: "模式识别与机器学习 · 简答题总纲",
  authors: "",
  write-title: true,
  title-align: center,
  num-columns: 2,
  column-gutter: 6pt,
  font-size: 12pt,
  line-skip: 6.5pt,
  x-margin: 20pt,
  y-margin: 10pt,
  numbered-units: false,
)

#inline[绪论与基础]

#concept-block(body: [
  *监督/无监督/半监督*：
  - 监督：输入输出对 $(bold(x)_i, y_i)$，回归/分类
  - 无监督：仅有 $bold(x)_i$，聚类/降维/密度估计
  - 半监督：少量标注 + 大量未标注

  *过拟合 vs 欠拟合*：
  - 过拟合：训练误差低、测试误差高 → 模型太复杂（减小容量、正则化、更多数据）
  - 欠拟合：训练误差高 → 模型太简单（增加容量、特征工程）
  - 如何判断：看训练/验证误差曲线

  *偏差-方差分解*：
  - $"MSE" = "Bias"^2 + "Var" + sigma_epsilon^2$
  - Bias 高 → 欠拟合（模型太简单）
  - Var 高 → 过拟合（模型对数据太敏感）
  - tradeoff：复杂度增加 → Bias ↓ Var ↑
])

#concept-block(body: [
  *交叉验证对比*：
#tablem[
  | 方法 | 优点 | 缺点 |
  |---|---|---|
  | Hold-out 7:3 | 快、一次训练 | 评估不稳定、浪费数据 |
  | k-fold CV | 稳定、充分利用数据 | 训练 k 次 |
  | LOOCV | 确定性强（$n$ 次训练） | 计算量大（$n$ 大时不可行） |
]
  *如何选择 k*？通常 $k=5$ 或 $10$，折中偏差和方差。
])

#inline[线性模型]

#concept-block(body: [
  *OLS vs Ridge vs Lasso*：

#tablem[
  | 方法 | 正则项 | 特点 |
  |---|---|---|
  | OLS | 无 | 无偏但方差大，$bold(X)^T bold(X)$ 不可逆时无解 |
  | Ridge | $lambda ||bold(w)||_2^2$ | 压缩系数但不稀疏，保证可逆 |
  | Lasso | $lambda ||bold(w)||_1$ | 自动特征选择（稀疏解），不可微 |
]
  *Ridge 的几何解释*：L2 球约束 + 误差等值线切点
  *Lasso 的几何解释*：L1 菱形约束 → 切点在坐标轴 → 稀疏
])

#concept-block(body: [
  *逻辑回归为何用交叉熵而非 MSE？*：
  - MSE + Sigmoid → 非凸（梯度消失，$sigma'(z) approx 0$ 时梯度几乎为零）
  - 交叉熵 + Sigmoid → 凸优化（梯度 $= hat(y) - y$，与线性回归形式相同）
  - 交叉熵有概率解释：最大化对数似然

  *感知机 vs 逻辑回归*：

#tablem[
  | 维度 | 感知机 | 逻辑回归 |
  |---|---|---|
  | 激活函数 | sign（阶跃） | Sigmoid（平滑） |
  | 输出 | 离散 $+1/-1$ | 概率 $[0,1]$ |
  | 损失 | 错分类驱动 $sum -bold(w)^T bold(x)$ | 交叉熵 |
  | 决策边界 | 线性 | 线性 |
  | 是否概率模型 | 否 | 是 |
]

  *多类分类*：
  - OVA：$K$ 个二分类器，参数 $K times d$，可能有不可分区域
  - OVO：$K(K-1)/2$ 个二分类器，投票决策
  - Softmax：一个统一模型，参数 $K times d$，输出概率和为 1
])

#inline[SVM]

#concept-block(body: [
  *最大化间隔的几何含义*：
  - 间隔 $= 2 / ||bold(w)||$，最大化间隔等价于最小化 $||bold(w)||^2$
  - 大间隔 → 对训练数据扰动不敏感 → 泛化能力好
  - 支持向量：决定分类面的少数样本（$alpha_i > 0$）

  *原始 vs 对偶*：
  - 原始：直接优化 $bold(w), b$，约束条件 $y_i(bold(w)^T bold(x)_i + b) >= 1$
  - 对偶：消除 $bold(w), b$，转化为 $alpha$ 的二次规划
  - 对偶优势：核技巧（仅需内积 $bold(x)_i^T bold(x)_j$）、支持向量稀疏性

  *KKT 条件意义*：
  - $alpha_i [y_i(bold(w)^T bold(x)_i + b) - 1] = 0$
  - $alpha_i > 0 <=>$ 该样本是支持向量（恰好在间隔边界上）
  - $alpha_i = 0$：该样本不影响分类面
])

#concept-block(body: [
  *核函数的本质*：
  - 隐式将数据映射到高维空间 $phi(bold(x))$，在特征空间做内积
  - 无需显式计算 $phi(bold(x))$，只需核函数 $kappa(bold(x)_i, bold(x)_j)$
  - Mercer 条件：核矩阵半正定 $<=>$ 存在某个 $phi$

  *常用核函数*：

#tablem[
  | 核 | 参数 | 适用场景 |
  |---|---|---|
  | 线性核 | — | 线性可分、文本分类（高维稀疏） |
  | 多项式核 | $c, d$ | 有先验知识（如图像特征交互） |
  | RBF 核 | $gamma$ | 最常用，无先验时默认选择 |
  | Sigmoid 核 | $beta, theta$ | 相当于单隐层神经网络 |
]
  *RBF 参数 $gamma$ 作用*：
  - $gamma$ 大 → 高斯分布尖窄 → 每个样本影响范围小 → 易过拟合（决策边界复杂）
  - $gamma$ 小 → 高斯分布扁平 → 每个样本影响范围大 → 易欠拟合（近似线性）
  - 与 SVM 的 $C$ 参数协同调节

  *软间隔 SVM*：
  - 引入松弛变量 $xi_i$ 允许部分样本错分或落在间隔内
  - $C$ 越大→对错分惩罚越重→间隔越窄（硬分类）
  - $C$ 越小→容忍更多错分→间隔越宽（软分类）
])

#inline[神经网络与CNN]

#concept-block(body: [
  *激活函数对比*：

#tablem[
  | 函数 | 公式 | 优点 | 缺点 |
  |---|---|---|---|
  | Sigmoid | $1/(1+"e"^{-z})$ | 光滑、概率解释 | 梯度消失、非零中心、指数运算 |
  | Tanh | $("e"^z-"e"^{-z})/("e"^z+"e"^{-z})$ | 零中心 | 梯度消失仍存在 |
  | ReLU | $max(0,z)$ | 不饱和、计算快、稀疏 | 神经元死亡（$z<0$ 梯度=0） |
  | LeakyReLU | $max(alpha z,z)$ | 缓解神经元死亡 | 超参数 $alpha$ |
]

  *梯度消失*：Sigmoid/Tanh 在饱和区导数近零 → 深层梯度连乘 → 浅层几乎不更新
  *ReLU 优势*：正区间导数恒为 1，梯度传播不受层数影响

  *BP 核心思想*：链式法则，从输出层向输入层逐层传播误差梯度
  - 输出层 $delta^((L)) = partial J / partial a^((L))$（损失对激活的导数）
  - 隐层 $delta^((l)) = (bold(W)^((l+1)))^T delta^((l+1)) ⊙ sigma'(bold(z)^((l)))$
])

#concept-block(body: [
  *CNN 核心思想*：
  - *局部连接*：每个神经元只连接输入的一小块区域（感受野）
  - *权值共享*：同一个卷积核滑过整个图像 → 参数量大降
  - *池化*：降采样 + 平移不变性（最大值/平均值）
  - 相比全连接：参数更少、平移等变、适合网格结构数据

  *卷积核/池化/步长/Padding 的作用*：
  - 卷积核大小 $K$：感受野大小，$K$ 越大感受野越大
  - 步长 $S$：每次滑动的像素数，$S > 1$ 可降采样
  - Padding $P$：保持边界信息，$P=K/2$ 时输出尺寸不变
  - 池化：降低分辨率、减少参数量、抗轻微平移
  - 输出尺寸公式：$W_("out") = floor((W_("in") + 2P - K)/S) + 1$

])

#inline[Batch Norm vs Layer Norm]

#concept-block(body: [
  *Batch Normalization（BN）*：
  - 对每个特征维度 $j$，在 mini-batch 上做标准化：
  $hat(x)_j = (x_j - mu_(cal(B), j)) / sqrt(sigma_(cal(B), j)^2 + epsilon)$
  - 再缩放平移：$y_j = gamma_j hat(x)_j + beta_j$
  - BN 在训练时用 batch 统计量，推理时用全局移动平均

  *BN 的作用*：
  - 缓解内部协变量偏移（Internal Covariate Shift）
  - 允许更大学习率，加速收敛
  - 有轻微正则化效果（每个 batch 的统计量有噪声）
  - 减少对初始化敏感度
])

#concept-block(body: [
  *Layer Normalization（LN）*：
  - 对每个样本 $i$，跨所有特征维度做标准化：
  $hat(x)_i = (x_i - mu_i) / sqrt(sigma_i^2 + epsilon)$
  - 其中 $mu_i = (1/d) sum_(j=1)^d x_(i j)$, $sigma_i^2 = (1/d) sum_(j=1)^d (x_(i j) - mu_i)^2$

  *BN vs LN 对比*：

#tablem[
  | 维度 | BN | LN |
  |---|---|---|
  | 标准化方向 | 跨样本（同一特征） | 跨特征（同一样本） |
  | 依赖 batch size | 是（小 batch 不稳定） | 否（不受 batch 影响） |
  | 训练/推理差异 | 有（batch vs 全局） | 无（相同） |
  | 适用场景 | CNN（固定尺寸） | RNN/Transformer（变长序列） |
]

  *为什么 RNN 用 LN 不用 BN*：
  - RNN 序列长度可变，batch 统计不稳定
  - LN 每个时间步独立标准化，不跨时间步
  - LN 不依赖 batch 大小，适合在线学习
])

#inline[核方法]

#concept-block(body: [
  *核技巧 vs 直接特征映射*：
  - 直接映射：显式计算 $phi(bold(x))$，高维时维度爆炸
  - 核技巧：隐式计算内积 $kappa(bold(x)_i, bold(x)_j) = chevron.l phi(bold(x)_i), phi(bold(x)_j) chevron.r$，计算量 $O(d)$
  - 核 PCA 与 PCA：PCA 在原始空间做特征分解；核 PCA 先在核空间映射再做 PCA，可提取非线性主成分

  *RBF 参数 $gamma$ 实验分析*：
  - $gamma$ 太小（如 $10^{-3}$）：所有样本相似度接近，模型近似线性 → 欠拟合
  - $gamma$ 适中（如 $10^{-1}$）：合理的非线性拟合能力
  - $gamma$ 太大（如 $10$）：只有极近的点才相似 → 每个点自成区域 → 过拟合（决策边界极其曲折）

  *Mercer 条件*：核函数对应的 Gram 矩阵半正定，保证存在某个希尔伯特空间和映射 $phi$。
])

#inline[无监督学习]

#concept-block(body: [
  *K-means 优缺点*：
  - 优点：简单、快速（$O(n K d T)$）、适合大数据
  - 缺点：需预设 $K$、初始化敏感、只发现凸簇、对异常点敏感（用 K-medoids 改进）
  - 改进：K-means++ 初始化、手肘法选 $K$

  *K-means vs GMM*：
  - K-means：硬分配（每个点只属一个簇），假设各向同性（球形簇）
  - GMM：软分配（概率 $gamma_(i k)$），可拟合椭圆簇（不同 $Sigma_k$）
  - K-means 是 GMM 的特例（$Sigma_k = sigma^2 bold(I)$，$sigma -> 0$ 时退化为硬分配）

  *PCA 本质*：
  - 最大方差视角：找到数据方差最大的方向投影
  - 最小重构误差视角：投影后再还原的误差最小
  - 用途：降维、去噪、可视化、压缩
  - 局限：线性方法、对异常值敏感、PCA 方向不可解释
])

#concept-block(body: [
  *PCA vs LDA*：

#tablem[
  | 维度 | PCA | LDA |
  |---|---|---|
  | 类型 | 无监督 | 有监督 |
  | 目标 | 最大化方差 | 最大化类间/类内比 |
  | 约束 | 无 | 至多 $K-1$ 维 |
  | 适用 | 无标签/压缩/去噪 | 分类/降维 |
]

  *Fisher 准则思想*：
  - 同时最大化类间散布 $bold(S)_B$ 和最小化类内散布 $bold(S)_W$
  - 瑞利商 $J(bold(w)) = (bold(w)^T bold(S)_B bold(w)) / (bold(w)^T bold(S)_W bold(w))$
  - 最优方向 $bold(w) ∝ bold(S)_W^(-1) (bold(mu)_1 - bold(mu)_2)$
])

#inline[EM 算法与 GMM]

#concept-block(body: [
  *EM 核心思想*：
  - 处理含隐变量 $z$ 的似然最大化 $p(bold(x) | theta) = sum_z p(bold(x), z | theta)$
  - E 步：固定 $theta$，计算隐变量后验 $p(z | bold(x), theta^((t)))$
  - M 步：用后验构造 Q 函数 $Q(theta, theta^((t))) = bb(E)_(z|bold(x), theta^((t)))[ln p(bold(x), z | theta)]$，最大化求 $theta^((t+1))$
  - 收敛性：每次迭代保证似然不降（单调收敛到局部最优）

  *EM vs K-means*：
  - E 步类似分配：K-means 硬分配（1-of-K），GMM 软分配（$gamma_(i k)$）
  - M 步类似更新：K-means 更新中心，GMM 更新 $pi_k, mu_k, Sigma_k$
  - K-means 是 GMM 用 EM 求解的特例（假设等球形协方差）
])

#concept-block(body: [
  *GMM 参数含义*：
  - $pi_k$：第 $k$ 分量的混合权重，$sum pi_k = 1$
  - $bold(mu)_k$：第 $k$ 分量的均值向量（中心位置）
  - $bold(Sigma)_k$：第 $k$ 分量的协方差矩阵（形状和方向）
  - 不同 $Sigma_k$ 约束：全矩阵 / 对角 / 球面 → 参数复杂度递减

  *如何选择 $K$*：
  - AIC：$-2 ln L + 2m$（$m$ 参数个数）
  - BIC：$-2 ln L + m ln n$（对复杂模型惩罚更大）
])

#inline[决策树]

#concept-block(body: [
  *ID3 / C4.5 / CART 对比*：

#tablem[
  | 维度 | ID3 | C4.5 | CART |
  |---|---|---|---|
  | 分裂准则 | 信息增益 | 增益率 | 基尼指数 / MSE |
  | 树结构 | 多叉 | 多叉 | 二叉树 |
  | 连续值 | 不支持 | 支持 | 支持 |
  | 缺失值 | 不支持 | 支持 | 支持 |
  | 剪枝 | 无 | PEP | CCP |
  | 输出 | 分类 | 分类 | 分类+回归 |
]
  *预剪枝 vs 后剪枝*：
  - 预剪枝：建树时提前停止（限制深度、最小样本数、增益阈值）
  - 优点：效率高
  - 缺点：可能过早停止（视界局限效应）
  - 后剪枝：充分生长后自底向上合并叶子（CCP）
  - 优点：效果通常更好
  - 缺点：计算开销大
])

#concept-block(body: [
  *决策树优缺点*：
  - 优点：可解释性极强（if-then 规则）、无需特征缩放、天然处理混合特征
  - 缺点：易过拟合（必须剪枝）、不稳定（数据微小变化导致树结构大变）、决策边界平行于坐标轴、贪婪搜索非全局最优

  *改进方法*：
  - Bagging + 随机森林（降低方差）
  - Boosting（降低偏差）
  - 限制树深度 / 最小叶子样本数
])

#inline[集成学习]

#concept-block(body: [
  *Bagging vs Boosting*：

#tablem[
  | 维度 | Bagging | Boosting |
  |---|---|---|
  | 样本权重 | 均匀采样（有放回） | 调整权重（加大错分样本） |
  | 基学习器关系 | 并行独立 | 串行依赖 |
  | 目标 | 降低方差 | 降低偏差 |
  | 代表 | 随机森林 | AdaBoost / GBDT |
  | 对异常点 | 鲁棒 | 敏感（会放大异常点权重） |
]

  *随机森林为何有效*：
  1. Bagging：降低方差（多个树的投票/平均）
  2. 随机特征选择：进一步降低树之间的相关性
  3. OOB 估计：袋外数据可做验证，不需额外验证集

  *AdaBoost 核心*：每一轮加大错分样本权重，让下一轮分类器更关注难分样本
  *GBDT 核心*：每一轮拟合前一轮残差（梯度负方向）
])

#inline[信息论与模型评估]

#concept-block(body: [
  *熵 / 交叉熵 / KL 散度的关系*：
  - 熵 $H(P) = -sum P(i) log P(i)$：不确定性度量
  - KL 散度 $D_("KL")(P || Q) = sum P(i) log(P(i)/Q(i))$：$P$ 与 $Q$ 的差异（非对称）
  - 交叉熵 $H(P, Q) = -sum P(i) log Q(i) = H(P) + D_("KL")(P || Q)$：编码代价

  *ROC 与 AUC*：
  - ROC 曲线：横轴 FPR，纵轴 TPR，反映分类器在不同阈值下的表现
  - AUC = ROC 下面积，值越接近 1 越好
  - AUC = 0.5 → 随机分类，AUC < 0.5 → 比随机差（反着用）
  - 适用场景：类别不平衡时 AUC 比 Accuracy 更可靠
])

#concept-block(body: [
  *混淆矩阵指标*：

#tablem[
  | 指标 | 公式 | 含义 |
  |---|---|---|
  | Accuracy | $("TP"+"TN")/("TP"+"TN"+"FP"+"FN")$ | 整体正确率 |
  | Precision | $"TP"/("TP"+"FP")$ | 预测为正的样本中真正为正的比例 |
  | Recall | $"TP"/("TP"+"FN")$ | 真正的正样本中被找出的比例 |
  | $F_1$ | $2 P R/(P + R)$ | Precision 与 Recall 的调和平均 |
]

  *何时用哪个*：
  - 医疗筛查：高 Recall（宁可误报也不要漏诊）
  - 垃圾邮件：高 Precision（宁可漏过也不要误判为垃圾）
  - 综合评估：$F_1$ / AUC
])

#inline[朴素贝叶斯]

#concept-block(body: [
  *"朴素"体现在哪里？*：
  - 假设各特征在给定类别下*条件独立*
  - 现实中很少完全独立，但实践效果往往不错
  - 独立性假设使联合概率分解为边缘概率乘积，参数量从指数级降到线性级

  *拉普拉斯平滑的动机*：
  - 避免零概率陷阱（测试样本出现训练集中未见的特征-类别组合）
  - 分子 $+1$、分母 $+v$（$v$ 为该特征取值数）
  - 相当于给每个特征值一个伪计数（先验 Dirichlet 分布）

  *生成式 vs 判别式*：
  - 生成式（NB）：建模联合分布 $P(bold(x), y) = P(y)P(bold(x) | y)$，再从 $P(y | bold(x))$ 决策
  - 判别式（逻辑回归）：直接建模 $P(y | bold(x))$
  - 生成式优点：可生成样本、对缺失值天然处理
  - 判别式优点：分类边界更准确（聚焦于决策面）
  - 数据少时生成式好，数据多时判别式好
])

#inline[贝叶斯估计（仅概念）]

#concept-block(body: [
  *贝叶斯估计 vs 极大似然*：
  - MLE：$hat(theta) = op("argmax")_theta P(D | theta)$，点估计
  - 贝叶斯：$p(theta | D) ∝ P(D | theta) p(theta)$，后验分布
  - MLE 容易过拟合（小样本），贝叶斯通过先验正则化
  - 当样本 $n -> infinity$ 时，两者趋于一致

  *共轭先验*：先验和后验属于同一分布族
  - Beta（伯努利/二项）、Dirichlet（多项）、Gaussian-Gaussian
  - 优点：后验有闭式解，迭代更新方便
])
