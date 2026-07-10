#import "@preview/ilm:2.1.0": *

#set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: 10pt)
#show raw: set text(font: ("JetbrainsMono NF"))
#set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
#set heading(numbering: none)
#set math.equation(numbering: none)

#let tip(body) = {
  block(
    fill: rgb("#FFF8E1"),
    stroke: (left: 3pt + rgb("#FFA000")),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body
  )
}

#let warn(body) = {
  block(
    fill: rgb("#FFEBEE"),
    stroke: (left: 3pt + red),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body
  )
}

#let formula(body) = {
  block(
    fill: luma(245),
    inset: (x: 12pt, y: 6pt),
    radius: 4pt,
    width: 100%,
    body
  )
}

#show: ilm.with(
  title: [计算机视觉 & 深度学习 开卷考试速查手册 — ML 基础篇],
  authors: "Biscuit · Alkaid",
  date: datetime(year: 2026, month: 07, day: 05),
  abstract: [
    本文档包含《计算机视觉》课程中涉及的机器学习与深度学习基础内容，涵盖：ML 基础概念、回归与分类、正则化、贝叶斯决策、神经网络基础与激活函数、优化算法与反向传播、训练范式（监督/无监督/迁移/元学习等）、生成对抗网络（GAN）、生成模型（VAE/扩散模型）、视觉先验与损失函数、数据增强、深度学习框架与 PyTorch API 速查。适合开卷考试快速查阅。
  ],
  chapter-pagebreak: false,
)


= 人工智能、机器学习与深度学习

#strong[1. 人工智能（AI）：]通过计算机程序或机器来模拟、实现人类智能的技术和方法。
#strong[2. 机器学习（ML）：]在无需明确编程的情况下，赋予计算机学习能力的研究领域。它通过数据驱动来总结规律。
#strong[3. 深度学习（DL）：]基于#strong[深度神经网络]的学习方法。由较多的网络层组成，因高度非线性的结构而具备极强的函数拟合能力。
#strong[4. 传统编程 vs 机器学习：]
- 传统编程：Data + Program → 计算机 → Output
- 机器学习：Data + Output → 计算机 → Program（自动从数据中总结规则）

= 机器学习要素

#strong[1. 模型：]从输入到输出的映射函数集合 $F = {f(x; theta) | theta in RR^D}$，$theta$ 为可学习参数。

#strong[2. 训练数据集：]监督学习中，给定带标签的数据集 $cal(D) = {(x^((n)), y^((n)))}_(n=1)^N$。

#strong[3. 损失函数：]

- 回归问题：均方误差（MSE）$L(y, f(x; theta)) = 1/2 (y - f(x; theta))^2$
- 分类问题：交叉熵损失 $L(y, f(x; theta)) = -y^T log f(x; theta) = -sum_(c=1)^C y_c log f_(c)(x; theta)$

#strong[4. 优化算法：]通过梯度下降及变体更新参数，常用算法包括 SGD、AdaGrad、RMSProp、Adam 等。

= 机器学习基本任务

== 线性回归

模型形式：$y = w_0 x + w_1$。优化目标是最小化平方误差：$min_w norm(X w - y)^2$。

== 多项式回归

理论基础：泰勒公式。任意函数都可以用多项式近似逼近。

模型形式：$f(X) = b + sum w_i^((1)) X_i + sum w_(i,j)^((2)) X_i X_j + dots$（包含特征的高阶交互项）。

== 逻辑回归（二分类）

本质是将线性回归的输出通过 #strong[Sigmoid 函数] 映射到 $(0, 1)$ 区间，表示为样本属于某一类的概率。

#formula[
  Sigmoid 函数：$ sigma(z) = 1 / (1 + e^(-z)) $，其中 $z = w^T x + b$

  决策规则：$ hat(y) = cases(1 "if" sigma(z) >= 0.5, 0 "otherwise") $
]

= 过拟合与正则化

== 欠拟合 vs 过拟合

- #strong[欠拟合（Underfitting）：]模型过于简单，训练集和测试集上的表现都较差。
- #strong[过拟合（Overfitting）：]模型过于复杂，将训练数据中的噪声也学进去了，训练集表现极好，但测试集表现很差（泛化能力弱）。

== 正则化（防止过拟合）

在原始损失函数上加入对模型权重 $w$ 的惩罚项，限制权重大小。

- #strong[L2 正则化（岭回归 Ridge Regression）：]$min_w norm(X w - y)^2 + lambda norm(w)^2$。倾向于让权值接近于0但非0，使模型平滑。
- #strong[L1 正则化（套索回归 Lasso Regression）：]$min_w norm(X w - y)^2 + lambda norm(w)_1$。倾向于产生#strong[稀疏]的权重（许多权值变为0），常用于特征选择。
- #strong[弹性回归（ElasticNet）：]同时引入 L1 和 L2：$min_w norm(X w - y)^2 + lambda_1 norm(w)_1 + lambda_2 norm(w)^2$。


= 贝叶斯决策理论与参数估计

== 贝叶斯公式

#formula[$ P(w_i | x) = (P(x | w_i) P(w_i)) / (P(x)) $]

- #strong[先验（Prior）$P(w_i)$：]观察数据前，对标签分布的认知。
- #strong[似然（Likelihood）$P(x | w_i)$：]给定特定类别 $w_i$，观察到数据 $x$ 的倾向性。
- #strong[后验（Posterior）$P(w_i | x)$：]观察到数据 $x$ 后，对标签分布的修正认知。
- #strong[证据（Evidence）$P(x)$：]数据本身的分布，在特定问题中通常固定。

== 最小错误率判别

判别准则：后验概率最大的类别即为预测类别。

#formula[$ w^* = "arg max"_(w) P(w | x) = "arg max"_(w) P(x | w) P(w) $]

忽略分母则等价于比较"似然 $times$ 先验"。

== 最小平均风险判别

引入代价函数 $lambda_(i j)$（将 $w_i$ 类误判为 $w_j$ 类的代价）。选择#strong[平均风险]最小的类别：

#formula[$ gamma_(j)(bold(x)) = sum_(i=1)^c lambda_(i j) P(w_i | bold(x)) $]

== 极大似然估计（MLE）

目标：寻找参数 $theta$，使得观测到给定数据集的#strong[概率最大]：$"arg max"_(w) P(x | w)$。

== 最大后验估计（MAP）

目标：寻找参数 $theta$，使得在观测到数据的条件下，#strong[后验概率最大]：

$"arg max"_(w) P(w | x) = "arg max"_(w) P(x | w) P(w)$（#strong[MAP 比 MLE 多乘了一个先验项 $P(w)$]）。


#pagebreak()

= 人工神经网络基础

== 神经网络与感知器

- 神经网络基本构成单元是#strong[神经元]：将输入 $x_i$ 与权重 $w_i$ 相乘并求和，再通过非线性激活函数 $f$ 得到输出：

#formula[$ y = f(sum_i w_i x_i + b) = f(w^T x + b) $]

- #strong[感知器算法：]1957 年由 Rosenblatt 提出。是一个单层线性分类器。更新规则：

#formula[$ w_(t+1) = w_t + eta (y - hat(y)) x $]

其中 $eta$ 为学习率，$y$ 为真实标签，$hat(y)$ 为预测输出。

#strong[感知器的局限性：]

- 需要#strong[手工提取特征]，极其依赖人工经验。
- 只能解决#strong[线性可分]问题。著名例子是#strong[XOR（异或）问题]，单层感知器无法区分异或数据，直接导致第一次神经网络寒冬。

== 多层感知器（MLP）解决 XOR 问题

- #strong[解决思路：]引入#strong[隐藏层]。通过增加网络层数，将原始输入空间通过非线性变换映射到新的、容易线性区分的高维特征空间。
- #strong[结构：]输入层 → 隐藏层（含非线性激活函数） → 输出层。

#strong[MLP 前向传播公式：]

#formula[
  隐藏层：$ h = f(W_1 x + b_1) $

  输出层：$ y = f(W_2 h + b_2) $
]

- 每层引入非线性激活函数 $f$，使得网络能逼近任意复杂函数（万能逼近定理）。

= 激活函数

激活函数引入非线性，使神经网络能够逼近任意复杂函数。

#strong[1. Sigmoid：]

#formula[$ sigma(x) = 1 / (1 + e^(-x)) $]

- 映射到 $(0, 1)$。存在#strong[梯度消失]问题（饱和区导数趋近于 0）。

#strong[2. tanh（双曲正切）：]

#formula[$ tanh(x) = (e^x - e^(-x)) / (e^x + e^(-x)) $]

- 映射到 $(-1, 1)$，输出以 0 为中心（优于 Sigmoid），但仍存在梯度消失。

#strong[3. ReLU（Rectified Linear Unit）：]

#formula[$ "ReLU"(x) = max(0, x) $]

- 计算极其高效，能有效缓解梯度消失问题。是目前最常用的激活函数。
- 缺点：存在#strong[神经元死亡]问题（输入小于 0 时，梯度为 0，神经元永远不会被激活）。

#strong[4. ReLU 变体：]

- #strong[Leaky ReLU：]$y = max(alpha x, x)$，其中 $alpha = 0.01$。输入小于 0 时给予微小斜率。
- #strong[PReLU：]斜率 $alpha$ 作为可学习参数在训练中自动更新。
- #strong[ELU：]$ f(x) = cases(x "if" x > 0, alpha(e^x - 1) "if" x <= 0) $，输出均值接近 0，收敛更快。
- #strong[GELU：]$ "GELU"(x) = x Phi(x) $，其中 $Phi(x)$ 为标准正态分布的 CDF，近似于 ReLU 的平滑版本，常用于 Transformer。


#pagebreak()

= 优化算法：梯度下降与学习率

== 梯度下降法

#formula[$ w(k+1) = w(k) - eta(k) nabla J(w(k)) $]

- 沿着损失函数 $J(w)$ 的负梯度方向迭代更新参数。
- $eta(k)$ 称为#strong[学习率（步长）]，是影响收敛速度和稳定性的最关键超参数。

== 学习率问题

- #strong[过小：]收敛极慢，需要大量迭代次数。
- #strong[合适：]目标函数平稳、快速下降至最小值。
- #strong[过大：]在最小值附近剧烈震荡，甚至#strong[发散]（无法收敛）。

== 震荡效应

在损失函数的"峡谷"地形中，梯度下降容易在峡谷两壁间来回震荡，难以快速到达谷底。

== 常用优化器

- #strong[SGD：]随机梯度下降。$g_t = nabla_(theta_(t-1)) f(theta_(t-1))$
- #strong[Momentum（动量法）：]引入历史梯度累积项，抑制震荡。$m_t = mu m_(t-1) + g_t$
- #strong[AdaGrad / RMSprop：]根据参数梯度大小，#strong[自适应调整各自的学习率]。适合稀疏梯度场景。
- #strong[Adam：]结合#strong[动量法（一阶矩估计）]和 #strong[RMSprop（二阶矩估计）]的优点。计算 $m_t, n_t$，经偏差校正后更新：

#formula[$ Delta theta_t = -eta dot hat(m)_t / (sqrt(hat(n)_t) + epsilon) $]

Adam 是目前深度学习中最常用的优化器之一。

== 停止策略

理论上梯度范数 $norm(nabla f) <= epsilon$ 时可停止，但实践中通常通过#strong[验证集（Validation Set）]的性能表现来选择最佳模型参数。

== 反向传播（Backpropagation）

利用链式法则逐层计算梯度，更新网络参数：

#formula[
  链式法则：$ (partial L)/(partial w_(i j)^(l)) = (partial L)/(partial a_j^(l)) (partial a_j^(l))/(partial z_j^(l)) (partial z_j^(l))/(partial w_(i j)^(l)) $

  其中 $a_j^(l)$ 为第 $l$ 层激活输出，$z_j^(l) = sum_i w_(i j)^(l) a_i^(l-1) + b_j^(l)$
]

== Softmax + 交叉熵损失（多分类）

#formula[
  Softmax：$ p_c = e^(z_c) / sum_(j=1)^C e^(z_j) $

  交叉熵损失：$ L = -sum_(c=1)^C y_c log p_c $

  Softmax + 交叉熵的梯度：$ (partial L)/(partial z_c) = p_c - y_c $（简洁形式，非常常用）
]


= Lecture 06 核心速查（开卷考试直接抄用）

#strong[1. 贝叶斯公式：]$P(w_i | x) = P(x | w_i) P(w_i) / P(x)$

#strong[2. MLE vs MAP：]MLE 最大化 $P(x | w)$，MAP 最大化 $P(x | w) P(w)$。

#strong[3. 正则化对比：]

- L2（岭回归）：$+ lambda norm(w)^2$，平滑
- L1（套索）：$+ lambda norm(w)_1$，稀疏（特征选择）

#strong[4. 激活函数：]

- Sigmoid：$sigma(x) = 1/(1+e^(-x))$，有梯度消失
- tanh：$tanh(x) = (e^x - e^(-x))/(e^x + e^(-x))$，输出零中心
- ReLU：$max(0, x)$，最常用，但有神经元死亡
- Leaky ReLU / PReLU / ELU / GELU：ReLU 改进变体

#strong[5. 损失函数：]

- MSE（回归）：$L = 1/2 (y - hat(y))^2$
- 交叉熵（分类）：$L = -sum y_c log p_c$
- Softmax：$p_c = e^(z_c) / sum e^(z_j)$，梯度 $partial L / partial z_c = p_c - y_c$

#strong[6. CNN 核心特性：]稀疏交互、参数共享、平移等变性

#strong[7. 特征图尺寸：]$W' = (W - K + 2P) / S + 1$

#strong[8. 池化：]最大池化 $max$ / 平均池化 "mean"，无参数，增大感受野

#strong[9. 网络结构演化关键点：]

- LeNet：奠基
- AlexNet：ReLU + Dropout + GPU
- VGGNet：$3 times 3$ 小卷积堆叠
- GoogLeNet：Inception 模块 + $1 times 1$ 降维
- ResNet：残差学习（$F(x) + x$）解决退化
- DenseNet：密集连接，特征重用
- U-Net：编码器-解码器 + 跳跃连接，适合分割

#strong[7. 常用优化器：]SGD → Momentum → AdaGrad / RMSprop → Adam（最常用）


#pagebreak()

= 神经网络典型训练范式

== 监督学习（Supervised Learning）

给定带标签数据集 $cal(D) = {(x_i, y_i)}_(i=1)^N$，最小化经验风险：

#formula[$ L = 1/N sum_(i=1)^N ell(f(x_i), y_i) $]

其中 $ell$ 为损失函数（如交叉熵或均方误差）。

== 无监督学习（Unsupervised Learning）

仅在无标签数据 ${x_i}_(i=1)^N$ 上训练。对比学习的 InfoNCE 损失：

#formula[$ L_"SSL" = -log (exp("sim"(bold(z)_i, bold(z)_j) / tau)) / (sum_(k != i) exp("sim"(bold(z)_i, bold(z)_k) / tau)) $]

其中 $"sim"$ 为相似度度量，$tau$ 为温度系数。

== 半监督学习（Semi-Supervised Learning）

结合少量有标签数据 $D_l$ 和大量无标签数据 $D_u$：

#formula[$ L = L_("sup")(D_l) + lambda L_("unsup")(D_u) $]

== 弱监督学习（Weakly Supervised Learning）

标签不完全、不精确（仅粗粒度标签 $hat(y)_i$），损失加入约束项：

#formula[$ L = 1/N sum_(i=1)^N ell(f(x_i), hat(y)_i) + L_"constraint" $]

== 主动学习（Active Learning）

从无标注池 $cal(U)$ 中挑选对模型提升最大的样本：

#formula[$ x^* = "arg max"_(x in cal(U)) Q(x) $]

（如选择模型置信度最低的样本进行人工标注）

== 多任务学习（Multi-Task Learning）

底层共享特征表示 $phi(x)$，上层分支为各任务设计特定层：

#formula[$ L_"MTL" = sum_(t=1)^T alpha_t L_(t)(W_t^T phi(x), y^((t))) $]

其中 $alpha_t$ 为任务权重。

== 迁移学习（Transfer Learning）

从源域 $D_s$ 学习知识并迁移到目标域 $D_t$，使用源域预训练参数 $theta_s$ 初始化后微调：

#formula[$ theta^* = "arg min"_(theta) L_(t)(theta; D_t) quad "s.t." quad theta "初始化自" theta_s $]

== 元学习（Meta-Learning / MAML）

训练元参数 $theta$，使其能快速适应新任务。核心一步梯度更新目标：

#formula[$ theta^* = "arg min"_(theta) sum_k L_k^("test")(theta - alpha nabla L_k^("train")(theta)) $]

其中 $alpha$ 为快速适应阶段的学习率，元参数 $theta$ 被优化为对大多数任务都容易微调的状态。

== 在线学习（Online Learning）

在时间步 $t$ 收到新样本 $(x_t, y_t)$ 后立即更新模型：

#formula[$ theta_(t+1) = theta_t - eta_t nabla ell(theta_t, x_t, y_t) $]

== 增量学习 / 持续学习（Continual Learning）

在已有模型基础上学习新数据，防止灾难性遗忘：

#formula[$ theta_t = "arg min"_(theta) [L_("new")(theta; D_t) + lambda L_("old")(theta; M_(1:t-1))] $]

其中 $L_"old"$ 为保留旧知识的损失（如知识蒸馏或记忆重放正则项）。

== 集成学习（Ensemble Learning）

组合 $M$ 个基模型 $h_m$ 联合预测，常用简单平均（Bagging）：

#formula[$ f_("ens")(bold(x)) = 1/M sum_(m=1)^M h_(m)(bold(x)) $]

== 联邦学习（Federated Learning / FedAvg）

数据保留在客户端本地，服务器聚合各客户端模型更新：

#formula[$ theta_(t+1) = sum_(k=1)^K n_k/n theta_(t+1)^((k)) $]

其中 $K$ 为客户端数，$n_k$ 为客户端 $k$ 的样本数，$n$ 为全局总样本数。

== 对比学习（Contrastive Learning）

对正样本对拉近距离，负样本对推远距离。InfoNCE 损失：

#formula[$ L_"InfoNCE" = -sum_i log (exp(bold(z)_i dot bold(z)_(i^+) / tau)) / (sum_(j != i) exp(bold(z)_i dot bold(z)_j / tau)) $]

其中 $bold(z)$ 为归一化特征向量，$tau$ 为温度超参数。

== 课程学习（Curriculum Learning）

按从易到难的策略逐步引入样本：

#formula[$ cal(D)^((t)) subset {bold(x) | d(bold(x)) <= epsilon_t}, quad epsilon_t "逐步增大" $]

其中 $d(bold(x))$ 为样本难度测度。


= 【补7】数据增强（Data Augmentation）

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

数据增强通过人工扩增训练集多样性，缓解过拟合，提升模型泛化能力。

== 几何增强

- #strong[随机裁剪（Random Crop）]与#strong[中心裁剪（Center Crop）]。
- 随机水平/垂直#strong[翻转（Flip）]。
- 随机#strong[旋转（Rotation）]（如 ±10°）。
- 随机#strong[缩放（Resize）]与#strong[仿射变换（Affine）]。

== 色彩/光度增强

- 随机调整#strong[亮度、对比度、饱和度、色调]。
- 随机添加#strong[高斯噪声]或#strong[模糊]。
- 色彩#strong[通道重排（Channel Shuffle）]。

== 高级增强方法

- #strong[MixUp：]两张图加权混合：$tilde(x) = lambda x_i + (1-lambda) x_j$，标签同理。$lambda tilde "Beta"(alpha, alpha)$（如 $alpha=0.2$）。
- #strong[CutMix：]将图 A 的随机矩形区域替换为图 B 的对应区域，标签按面积比例混合。
- #strong[CutOut：]随机遮挡图像的矩形区域（置零），强制网络不依赖局部特征。
- #strong[Mosaic（YOLOv4）：]4 张图拼接为 1 张，增加小目标比例和上下文多样性。
- #strong[RandAugment：]搜索一组最优增强操作组合，减少手动调参。


#pagebreak()

= 典型深度学习框架

== 三个抽象层

- #strong[张量（Tensor）：]数据容器，本质为多维矩阵（标量 0D、向量 1D、矩阵 2D、图像 3D/4D），支持 GPU 加速。
- #strong[计算图（Computational Graph）：]将数学表达式转化为有向无环图（DAG）记录张量间的计算依赖关系。
- #strong[模块（Module）：]将神经网络层封装成可复用对象，支持参数自动管理。

== 静态图 vs 动态图

- #strong[静态图（如 TensorFlow 1.x）：]先定义完整计算图，编译优化后送入数据执行（Define-and-Run）。便于底层部署，不利于调试。
- #strong[动态图（如 PyTorch）：]边执行代码边动态构建计算图（Define-by-Run）。代码直观、易于调试，极大提升研究效率。

== PyTorch 核心 API 速查

PyTorch 是计算机视觉研究领域最常用的深度学习框架。

```python
# 基础张量操作（torch）
torch.zeros/ones/eye/rand/randn/randperm(shape)  # 创建张量
t.cuda() / t.to(device) / t.is_cuda()             # 设备迁移
t.transpose(dim0, dim1) / t.permute(*dims)        # 维度变换
t.view(*shape) / t.contiguous()                   # 形状重塑
torch.cat/split/squeeze/unsqueeze/stack           # 切分、连接与维度变换
torch.mean/sum/max/min/std/var/eq/lt/gt           # 归约与比较运算
```

```python
# 神经网络层（torch.nn）
nn.Module                                        # 所有网络层的基类
nn.Sequential / nn.ModuleList                    # 容器封装多层
nn.Conv2d / ConvTranspose2d / MaxPool2d / AvgPool2d  # 卷积与池化
nn.ReLU / ELU / LeakyReLU / PReLU / Sigmoid / GELU   # 激活函数
nn.BatchNorm2d / LayerNorm / InstanceNorm2d       # 归一化层
nn.Linear / nn.Dropout / nn.LSTM / nn.RNN / nn.GRU  # 全连接/RNN
nn.L1Loss / MSELoss / CrossEntropyLoss / NLLLoss  # 损失函数
nn.functional.*                                  # 函数式接口
```

```python
# 优化器（torch.optim）
optim.SGD(model.parameters(), lr=0.01, momentum=0.9)
optim.Adam(model.parameters(), lr=1e-3)
```

```python
# 数据加载（torch.utils）
utils.data.Dataset       # 自定义数据集的基类
utils.data.DataLoader    # 批量加载、打乱、多线程读取
utils.model_zoo.load_url # 在线加载预训练模型参数
```

```python
# 视觉工具包（torchvision）
torchvision.datasets.MNIST / CIFAR10 / COCO / VOC
torchvision.models.AlexNet / VGG / ResNet / DenseNet
torchvision.transforms.Compose / CenterCrop / RandomCrop /
    RandomHorizontalFlip / ToTensor / Normalize
torchvision.utils.save_image
```

== 自动求导原理

计算图记录前向传播中间结果，调用 `.backward()` 后，PyTorch 从末端节点开始利用链式法则沿拓扑序反向传播梯度，累加到各节点的 `.grad` 属性。

== 模型部署与推理优化框架

- #strong[TensorRT（NVIDIA）：]极致性能优化，支持高度量化，适用于 NVIDIA GPU。
- #strong[OpenVINO（Intel）：]针对 Intel 硬件优化，跨平台生态好。
- #strong[ONNX（Microsoft）：]跨平台硬件兼容性强，可对接各种推理后端。
- #strong[vLLM：]针对 LLM 设计，PageAttention 技术提升显存利用率和吞吐量。
- #strong[vLLM-Omni：]首个支持文图音视频统一生成的开源框架。
- #strong[LMDeploy（上海 AI Lab）：]专为 LLM 设计，解码速度快，量化支持好。

= Lecture 06_2 核心速查（开卷考试直接抄用）

#strong[1. 自注意力公式：]$"Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V$

#strong[2. 多头注意力：]将 $Q, K, V$ 拆分为多头并行计算，最后拼接。

#strong[3. 视觉 Transformer 代表模型：]

- ViT：Patch 划分 + [class] token + Transformer Encoder
- DeiT：数据增广 + 正则化，无需超大规模预训练
- PVT：特征金字塔，多阶段分辨率递减
- Swin：移动窗口注意力，兼顾全局与局部

#strong[4. ConvNeXt：]CNN 结构 + Transformer 训练技巧（AdamW、GELU、LN）

#strong[5. RepLKNet：]大卷积核 + 结构重参数化（训练多分支、推理融合）

#strong[6. 监督学习：]$L = 1/N sum ell(f(x_i), y_i)$

#strong[7. 对比学习 InfoNCE：]$L_"InfoNCE" = -sum_i log (exp(bold(z)_i dot bold(z)_(i^+) / tau)) / (sum_(j != i) exp(bold(z)_i dot bold(z)_j / tau))$

#strong[8. 元学习 MAML：]$theta^* = "arg min"_(theta) sum_k L_k^("test")(theta - alpha nabla L_k^("train")(theta))$

#strong[9. 联邦学习 FedAvg：]$theta_(t+1) = sum_(k=1)^K n_k/n theta_(t+1)^((k))$

#strong[10. 深度学习框架：]PyTorch（动态图）、TensorFlow（静态图）


#pagebreak()

= 生成对抗网络（GAN）

== 基本定义

GAN 由两个神经网络相互博弈构成：

- #strong[生成器 $G$：]从噪声分布 $p_(z)(z)$ 采样生成假样本 $G(z)$。
- #strong[判别器 $D$：]判断输入来自真实分布 $p_("data")(x)$ 还是生成器。

#strong[目标函数（极小极大博弈）：]

#formula[$ min_G max_D V(D, G) = EE_(x tilde p_("data")(x))[log D(x)] + EE_(z tilde p_(z)(z))[log(1 - D(G(z)))] $]

- $D$ 最大化 $V(D, G)$（正确区分真实/生成）。
- $G$ 最小化 $V(D, G)$（让 $D$ 无法分辨）。

== 标准训练算法

+ 判别器更新（梯度#strong[上升]）：从 $p_(z)(z)$ 采样 $m$ 个噪声，从 $p_("data")(x)$ 采样 $m$ 个真实样本。

  #formula[$ nabla_(theta_d) 1/m sum_(i=1)^m [log D(x^((i))) + log(1 - D(G(z^((i)))))] $]

+ 生成器更新（梯度#strong[下降]）：采样 $m$ 个噪声样本。

  #formula[$ nabla_(theta_g) 1/m sum_(i=1)^m log(1 - D(G(z^((i))))) $]

== 理论收敛性

- #strong[定理 1（全局最小值）：]当且仅当 $p_g = p_"data"$ 时，$C(G)$ 达到最小值 $-log 4$。
- 此时最优判别器 $D_G^*(x) = 1/2$，$C(G) = log 1/2 + log 1/2 = -log 4$。

== GAN 经典演进

- #strong[Progressive GAN：]渐进式增长，从低分辨率逐步生成高分辨率。
- #strong[StyleGAN：]映射网络 $z -> W$ + AdaIN 风格注入 + 截断技巧。
- #strong[StyleGAN2：]去 AdaIN，路径长度正则化 + 权重解调，消除水滴伪影。
- #strong[StyleGAN3：]平移/旋转不变性设计，避免纹理粘连。
- #strong[BigGAN：]大规模训练，残差块 + 谱归一化，极高分辨率高质量。

= Lecture 09 核心速查（开卷考试直接抄用）

#strong[1. Snell 定律：]$n_1 sin theta_i = n_2 sin theta_t$

#strong[2. 像差：]色差（折射率随波长变）、几何畸变（桶形/枕形）

#strong[3. 噪声模型：]

- 散粒噪声 $N_"shot" ~ cal(N)(0, beta_"shot" I)$
- 读出噪声 $N_"read" ~ cal(N)(0, sigma_"read"^2)$
- 量化噪声 $N_q ~ U(-q/2, q/2)$

#strong[4. 去反光模型：]$I = B + R$

#strong[5. GAN 目标函数：]$min_G max_D EE[log D(x)] + EE[log(1 - D(G(z)))]$

#strong[6. GAN 收敛条件：]$p_g = p_"data"$ 时 $D_G^*(x) = 1/2$，$C(G) = -log 4$

#strong[7. GAN 演进：]Progressive → StyleGAN（映射+AdaIN）→ StyleGAN2（路径正则化）→ StyleGAN3（平移不变）→ BigGAN（谱归一化）


#pagebreak()

= 视觉先验基本概念

== 先验定义

先验是在观测数据之前，对未知变量已有的假设、约束或概率分布。

== 贝叶斯框架

#formula[$ P(theta | X) prop P(X | theta) P(theta) $]

- $P(theta | X)$：后验（要的结果）
- $P(X | theta)$：似然（观测数据证据）
- $P(theta)$：先验（提前知道的规律）

== 视觉先验来源

- #strong[物理几何约束：]物体不能悬空、两面墙互相垂直。
- #strong[数据统计约束：]天空是蓝色的、草是绿色的。
- #strong[人为偏好：]图像梯度稀疏（平滑先验）、L2 正则化。

= 传统底层视觉先验

== 图像去噪先验

- #strong[平滑性先验（TV 范数）：]惩罚相邻像素差异，但会抹平边缘。
- #strong[非局部自相似性（NLM）：]同一幅图中的重复斑块取平均，噪声抵消（BM3D 基础）。
- #strong[稀疏表示先验：]图像块在过完备字典下可用少数非零系数表示，噪声无法被稀疏表示。

== 图像超分先验

- #strong[边缘方向先验：]沿边缘方向取点插值，避免锯齿。
- #strong[梯度轮廓先验：]边缘梯度的统计分布规律（高斯混合模型）。
- #strong[跨尺度重复性先验：]斑块在不同尺度下重复出现。
- #strong[自相似性先验：]利用图像自身的相似结构生成高频细节。

= 自监督与零样本图像复原

== Noise2Noise（ICML 2018）

使用同场景的另一张独立噪声图像作为监督目标，无需清晰参考图。

#formula[$ "arg min"_(theta) sum_i L(f_(theta)(hat(x)_i), hat(y)_i) $]

其中 $hat(x)_i, hat(y)_i$ 为同一场景的两张独立噪声图像。当噪声均值为零时，等价于学习到清晰图像。

== Noise2Void（CVPR 2019）

盲点网络（Blind Spot Network），通过周围像素预测中心像素，防止恒等映射。

== Neighbor2Neighbor（CVPR 2021）

利用同一张噪声图像中相邻的子采样对进行自监督学习。

== Zero-shot SR（ZSSR）

图像内部训练的超分网络，从#strong[测试图像本身]提取高/低分辨率对训练。

= 网络结构先验与归纳偏置

== 归纳偏置

算法隐含的"性格偏好"或先验假设。

== CNN vs ViT

- #strong[CNN：]强归纳偏置（局部连接 + 权重共享 + 平移等变性），少量数据即可，数据少时强。
- #strong[ViT：]弱归纳偏置（无局部连接，全局注意力），需海量数据，数据充足时上限极高。
- U-Net 编码器-解码器天然具备#strong[低频偏好]，跳跃连接保留高分辨率细节。

== 深度图像先验（DIP）

网络天生更容易学习图像中的低频、有结构的部分。无需训练数据、无需参考图像。适合单张退化图像场景（老照片修复）。局限：需手动选停止点，每张图从头训练。


= 损失函数中的先验

== 感知损失（Perceptual Loss）

利用预训练网络（VGG）的多层特征计算损失，保留结构和语义。

#formula[$ L_"style" = sum w_k E_(k)(bar(I), I^t) $]

其中 $E_k$ 为特征图间的距离（如 Gram 矩阵距离）。

== 全变分损失（TV Loss）

惩罚邻域像素差异，促进图像平滑。

#formula[
  一维：$ "TV"(x) = sum_n |x_(n+1) - x_n| $

  二维：$ "TV"(x) = sum_(i,j) (|x_(i+1,j) - x_(i,j)| + |x_(i,j+1) - x_(i,j)|) $
]

= GAN 反演（GAN Inversion）与图像编辑

== GAN 反演目标

将真实图像 $x$ 反向映射回 GAN 的隐空间，找到潜码 $w$ 使 $G(w) approx x$，实现对图像的语义编辑。

== Image2StyleGAN++

引入 W+ 空间和 N 空间，通过潜空间优化重建图像。支持图像交叉、修复、局部编辑、风格迁移。

== In-domain GAN Inversion（ECCV 2020）

编码器 $E$ 获取初始潜码，再优化：

#formula[$ z^* = "arg min"_(z) (norm(G(z) - x) + lambda_"perc" norm(F(x) - F(G(z))) + lambda_"reg" norm(z)) $]

== pSp（CVPR 2021）

基于学习型编码器：$"pSp"(x) approx G(E(x) + bar(w))$。ResNet-50 映射到 W+ 空间。损失：L2 + LPIPS + W 正则化 + ArcFace ID 损失。

== GPEN（CVPR 2021）

盲人脸恢复。同时利用 W+ 和 N 空间，同步优化生成器。

#formula[
  $ L_G = min_G norm(X - hat(X))_1 $

  $ L_G = min_G max_D EE [log(1 + exp(-D(G(hat(X)))))] $

  $ L_D = min_D EE [sum norm(D(X) - D(G(hat(X))))_1] $
]

退化模型：$I^d = ((I star k)_"下采样" + n)_"JPEG"$。

= GAN 隐空间分析与条件控制

== GANSpace（CVPR 2020）

在 W 空间采样大量随机向量，对 $w$ 做#strong[主成分分析（PCA）]，找出导致图像显著变化的控制方向：$w' = w + V x$。

== SeFa（Closed-Form Factorization）

寻找隐空间语义方向的#strong[解析解]。隐特征变化 $Delta y = alpha A n$，目标是找到使 $|A n|$ 最大的方向 $n$：

#formula[$ n^* = "arg max"_(n) |A n| $]

通过拉格朗日乘数法解析求解。

== StyleCLIP（ICCV 2021）

利用 #strong[CLIP] 模型寻找文本指引的方向。潜码映射器 + CLIP 损失 $L_("clip")(w)$ 衡量生成图像与文本提示的对齐程度。

== CLIP（OpenAI）

视觉-语言预训练模型，4 亿对（图像, 文本）数据训练。通过#strong[对比学习]将图像和文本编码到同一特征空间。

== LoRA（Low-Rank Adaptation）

参数高效微调技术。冻结预训练权重 $W_0$，添加低秩矩阵 $A, B$：

#formula[$ h = W_0 x + Delta W x = W_0 x + B A x $]

其中 $A tilde cal(N)(0, sigma^2)$，$B = 0$。训练只更新 $A, B$，极大减少参数量和显存占用。

= Lecture 16 核心速查（开卷考试直接抄用）

#strong[1. 贝叶斯先验：]$P(theta | X) prop P(X | theta) P(theta)$

#strong[2. 传统先验：]TV 范数（平滑）、NLM 非局部自相似性（BM3D）、稀疏表示

#strong[3. Noise2Noise：]$"arg min" sum L(f(hat(x)), hat(y))$，噪声零均值时等价于学习清晰图

#strong[4. 归纳偏置：]CNN 强局部性、ViT 全局注意力（需海量数据）

#strong[5. DIP：]网络天生偏好低频，单张图即可，无需预训练

#strong[6. TV 损失：]$"TV"(x) = sum |x_(i+1) - x_i|$，惩罚邻域差异促进平滑

#strong[7. 感知损失：]预训练 VGG 特征图距离，保留语义结构

#strong[8. GAN 反演：]$G(w) approx x$，W+ / N 空间，pSp（编码器）、GPEN（盲人脸恢复）

#strong[9. GANSpace：]PCA 找语义方向；SeFa 解析解 $n^* = "arg max" |A n|$

#strong[10. LoRA：]$h = W_0 x + B A x$，冻结 $W_0$ 只更新低秩矩阵


#pagebreak()

= 自编码器（AE）及其变体

== 自编码器（AE）

编码器将输入压缩为低维隐变量 $z$，解码器重建输出。目标：最小化重建损失。用途：降维、特征压缩。

== 去噪自编码器（DAE）

输入加噪 $x + n$，恢复原始 $x$。强制学习对噪声不敏感的鲁棒特征，避免恒等映射。

== 变分自编码器（VAE）

引入概率分布 $P(x)$。隐变量后验 $p(z|x) = p(x|z)p(z)/p(x)$，用 $q(z|x) tilde cal(N)(mu, sigma)$ 近似。

#strong[重参数化技巧：]将采样 $z tilde cal(N)(mu, sigma)$ 改写为可导形式：

#formula[$ z = mu + sigma dot epsilon, quad epsilon tilde cal(N)(0, 1) $]

#strong[损失函数：]重建损失 + KL 散度。KL 项防止方差退化为 0，迫使隐分布接近标准正态。

== VQ-VAE

放弃连续隐空间，维护#strong[离散嵌入空间（Codebook）]。

- 匹配 Code：$"encoding_index" = "arg min"("distances")$
- 量化：$z_q = "embedding"("encoding_index")$
- 直通梯度：$z_q_"st" = z_e + (z_q - z_e)."detach"()$
- Codebook 损失：$L_"codebook" = "MSE"(z_q, z_e."detach"())$
- 承诺损失：$L_"commit" = 0.25 times "MSE"(z_q."detach"(), z_e)$
- 重建损失：$L_"recon" = "MSE"("decoder"(z_q_"st"), x)$

= 归一化流（Normalizing Flow）

通过一系列可逆变换，将简单分布映射为复杂分布。

#strong[变量变换公式：]

#formula[$ p_(x)(x) = p_(z)(f^(-1)(x)) dot |det J_(f^(-1))(x)| $]

其中 $det J$ 为雅可比行列式。

#strong[耦合层（Coupling Layer）：]

- #strong[NICE（加性耦合）：]$y_1 = x_1,; y_2 = x_2 + m(x_1)$
- #strong[RealNVP（仿射耦合）：]$y_1 = x_1,; y_2 = s(x_1) dot x_2 + t(x_1)$

逆变换可直接解析求解。


= 扩散模型与基于得分的模型

== 基于得分的模型（Score-based Models）

建模得分函数 $s(x) = nabla_x log p_("data")(x)$，通过朗之万动力学采样。

#strong[去噪得分匹配（DSM）：]

#formula[$ J_(D)(theta) = EE_(p_("data")(x)) EE_(p(tilde(x)|x)) [norm(s_(theta)(tilde(x)) - nabla_(tilde(x)) log p(tilde(x)|x))^2] $]

由于 $p(tilde(x)|x)$ 为高斯分布，得分有解析解。

== 扩散模型（Diffusion Models）

前向加噪：$x_t = sqrt(alpha_t) x_(t-1) + sqrt(1 - alpha_t) z_(t-1)$

单步直接采样：

#formula[$ x_t = sqrt(bar(alpha)_t) x_0 + sqrt(1 - bar(alpha)_t) z, quad z tilde cal(N)(0, 1), quad bar(alpha)_t = product_(i=1)^t alpha_i $]

#strong[简化训练目标（预测噪声）：]

#formula[$ L_"simple" = EE_(t, x_0, z) [norm(z - z_(theta)(sqrt(bar(alpha)_t) x_0 + sqrt(1 - bar(alpha)_t) z, t))^2] $]

#strong[分类器指导（ADM）：]

#formula[$ p_(theta)(x_t | x_(t+1), y) prop p_(theta)(x_t | x_(t+1)) p(y | x_t) $]

= 主流文本生成图像模型

#strong[DALL-E 2 (unCLIP)：]两阶段：先验模型将文本编码映射到 CLIP 图像嵌入，解码器基于嵌入生成图像。

#formula[$ P("Image" | "Text") approx P("Image" | "CLIP Emb") times P("CLIP Emb" | "Text") $]

#strong[Imagen：]使用通用大语言模型（T5）作为文本编码器 + 级联扩散模型超分。

#strong[Stable Diffusion (LDM)：]将扩散过程从像素空间转移到#strong[潜在空间]（VAE 将 512×512 压缩为 64×64），大幅降低计算量。生成器中加入#strong[交叉注意力]实现条件控制。

= 视觉自回归模型 & 定制化生成

#strong[视觉自回归模型：]通过 VQ-VAE 将图像量化为离散 Token 序列，按光栅扫描顺序自回归预测下一个 Token。

#strong[定制化生成：]在少量主体图像下保留特定身份生成新图像。代表：Elite（0.05s）、MasterWeaver（属性编辑）、PLACE（空间布局控制）。

#strong[长视频生成 LoVIC：]上下文压缩 + FlexFormer，支持超 100 帧视频的前向/反向/插入生成。

#strong[物理一致性视频生成 DreamPhysics：]整合 3D 表示 + 视频扩散 + 物理运动方程（MPM），生成符合物理规律的动态视频。

#strong[图像编辑应用：]FramePainter（视频先验编辑）、ScrollScape（无限卷轴全景）、DreamLite（手机端 < 1s 生成 1024×1024）。

= 生成模型核心速查（开卷考试直接抄用）

#strong[1. VAE 重参数化：]$z = mu + sigma dot epsilon$，使采样可导

#strong[2. VQ-VAE：]离散 Codebook + 直通梯度（Straight-Through Estimator）

#strong[3. 归一化流：]$p_(x)(x) = p_(z)(f^(-1)(x)) dot |det J|$

#strong[4. NICE：]$y_1 = x_1,; y_2 = x_2 + m(x_1)$；RealNVP：$y_2 = s(x_1) dot x_2 + t(x_1)$

#strong[5. 扩散模型前向：]$x_t = sqrt(bar(alpha)_t) x_0 + sqrt(1 - bar(alpha)_t) z$

#strong[6. 扩散训练目标：]$L_"simple" = EE [norm(z - z_(theta)(sqrt(bar(alpha)_t) x_0 + sqrt(1 - bar(alpha)_t) z, t))^2]$

#strong[7. Stable Diffusion：]像素扩散 → 潜在扩散（VAE 压缩），加交叉注意力实现文本条件

#strong[8. 视觉自回归：]VQ-VAE 量化图像为 Token，自回归预测


