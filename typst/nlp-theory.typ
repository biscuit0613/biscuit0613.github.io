#import "@preview/boxed-sheet:0.1.0": cheatsheet
#import "@preview/tablem:0.3.0": *
#import "@preview/cetz:0.5.2": canvas, draw

#set text(font: ("Noto Serif CJK SC", "New Computer Modern"), size: 8pt, lang: "zh")
#set par(justify: true, leading: 0.52em, spacing: 0.72em)
#set math.equation(numbering: none)

#let accent = rgb("#1f3a5f")
#let accent2 = rgb("#3b6ea5")
#let pale = rgb("#eef3f9")
#let src(body) = text(size: 6.3pt, fill: luma(95))[#body]
#let tag(body) = box(
  fill: luma(236),
  inset: (x: 2.6pt, y: 0.6pt),
  radius: 1.5pt,
  text(size: 6.3pt, fill: luma(70))[#body],
)

#let section(title) = block(
  width: 100%,
  fill: accent,
  inset: (x: 6pt, y: 3pt),
  radius: 2pt,
  above: 9pt,
  below: 4pt,
  text(fill: white, weight: "bold", size: 9.6pt)[#title],
)

#let th(id, title, body) = block(
  width: 100%,
  breakable: true,
  stroke: 0.5pt + rgb("#a9bdd6"),
  radius: 2.5pt,
  inset: 6pt,
  above: 5pt,
  below: 2pt,
  [
    #grid(
      columns: (auto, 1fr),
      column-gutter: 5pt,
      align: horizon,
      box(
        fill: accent2,
        inset: (x: 3.5pt, y: 1.2pt),
        radius: 2pt,
        text(fill: white, weight: "bold", size: 7.4pt)[#id],
      ),
      text(weight: "bold", size: 8.3pt, fill: accent)[#title],
    )
    #v(2.4pt)
    #body
  ],
)

#show: cheatsheet.with(
  title: "自然语言处理 · 理论公式与推导速查",
  authors: "HIT-NLP 复习",
  homepage: "biscuit0613.github.io",
  write-title: true,
  title-align: center,
  num-columns: 2,
  column-gutter: 7pt,
  font-size: 8pt,
  line-skip: 6pt,
  x-margin: 15pt,
  y-margin: 11pt,
  numbered-units: false,
)

#block(
  width: 100%,
  fill: pale,
  stroke: 0.5pt + accent2,
  radius: 3pt,
  inset: 7pt,
  [
    #text(weight: "bold", fill: accent, size: 9pt)[使用说明]
    #v(2pt)
    - 符号定义、目标函数、推导步骤、算法递推、复杂度与实现细节；概念问答见同目录的《课后习题 QA 速查》。

    - 笑脸页索引：L2 P28–32（机器学习史）；L3 P18（Good-Turing）、P32–43（最大匹配逐步扫描例）、P52–54（CRF 训练推理）、P56（神经网络 NER）、P80–82（PCFG/CYK）、P112–115（关系抽取分类器细节）、P131–140（MT 史与难点）；L4 P58–88（经典 CNN 架构）、P100–101（LSTM 门细节）、P113、P132–147（Transformer 分步实例）；L6 P98–104（深入理解 BERT 补充）、P127（T5 任务形式）。
  ]
)

#section("0 · 符号、恒等式与答题骨架")

#th("0.1", "符号约定", [
  #tablem[
    | 记号 | 含义 | 记号 | 含义 |
    |---|---|---|---|
    | $V$ | 词表大小 | $d$ | 隐藏/嵌入维度 |
    | $N$ / $T$ | 样本数 / 序列长度 | $L$ | 层数 |
    | $H$ | 注意力头数 | $d_k$ | 单头 key/value 维度 |
    | $C(dot)$ | 出现次数 | $p, q$ | 真实分布 / 模型分布 |
    | $theta$ | 模型参数 | $pi$ | 策略 |
    | $beta$ | KL 系数 / 温度参数 | $gamma, lambda$ | 折扣因子 / GAE 系数 |
    | $dot$ | 逐元素乘 | $sigma$ | sigmoid 函数 |
    | $bb(1)[dot]$ | 指示函数 | $"softmax"$ | 归一化指数 |
    | $cal(V)$ | 词表集合 | $cal(D)$ | 训练/偏好数据集 |
  ]
  - *维度检查*：向量默认列向量；$W in RR^(m times n)$ 作用在 $RR^n$ 上得到 $RR^m$；批量为 $B$ 时矩阵形状常写 $(B, T, d)$。
  - *概率检查*：任何条件概率对同一条件下的所有取值求和必须为 1；写完公式先验一遍归一化。
])

#th("0.2", "常用恒等式与不等式", [
  - 对数运算：$log(a b) = log a + log b$，$log(a\/b) = log a - log b$；约定 $0 log 0 = 0$。
  - 概率归一化：$sum_x p(x) = 1$，$sum_y P(y divides x) = 1$。
  - 贝叶斯公式：$P(y divides x) = (P(x divides y) P(y)) \/ P(x)$。
  - 交叉熵分解：$H(p,q) = H(p) + D_"KL"(p,q)$，其中 $H(p,q) = -sum_x p(x) log q(x)$。
  - KL 非负（Jensen）：
    $
      -D_"KL"(p,q) = sum_x p(x) log(q(x)/p(x))
      <= log sum_x p(x) (q(x)/p(x)) = log 1 = 0
    $
    取等当且仅当 $p=q$（几乎处处）。
  - 熵的链式法则：$H(X,Y) = H(X) + H(Y divides X) = H(Y) + H(X divides Y)$。
  - 互信息：$I(X;Y) = H(X) - H(X divides Y) = H(X) + H(Y) - H(X,Y) >= 0$。
  - Softmax 的导数：$partial s_i \/ partial z_j = s_i (delta_(i j) - s_j)$，其中 $s = "softmax"(z)$。
  - Sigmoid 的导数：$sigma'(z) = sigma(z)(1 - sigma(z))$。
  - 数值稳定 softmax：$"softmax"(z)_i = exp(z_i - max_j z_j) \/ sum_j exp(z_j - max_j z_j)$。
])

#section("1 · 第 2 讲：信息论与学习范式")

#th("2.1", "熵、联合熵与条件熵", [
  - *熵*（不确定性/平均信息量）：
    $
      H(X) = -sum_(x in cal(X)) p(x) log p(x) = bb(E)_(x ~ p)[-log p(x)]
    $
  - *联合熵*：$H(X,Y) = -sum_(x,y) p(x,y) log p(x,y)$。
  - *条件熵*：
    $
      H(Y divides X) = -sum_(x,y) p(x,y) log p(y divides x) = H(X,Y) - H(X)
    $
  - *链式法则推导*：
    $
      H(X,Y) &= -sum_(x,y) p(x,y) log[p(x) p(y divides x)] \
             &= -sum_(x,y) p(x,y) log p(x) - sum_(x,y) p(x,y) log p(y divides x) \
             &= H(X) + H(Y divides X)
    $
  - *性质*：
    - 非负：$H(X) >= 0$；确定事件熵为 0；
    - 最大熵：$|cal(X)|$ 个取值上均匀分布时 $H(X) = log |cal(X)|$；
    - 独立时 $H(X,Y) = H(X) + H(Y)$，$H(Y divides X) = H(Y)$；
    - 条件降低不确定性：$H(Y divides X) <= H(Y)$。
  - *单位*：$log_2$ 为比特（bit），$ln$ 为奈特（nat）；$1$ nat $= 1\/ln 2$ bit。
  #src[依据：L2 P4–18；博客《统计语言模型》《KL 散度与交叉熵》。]
])

#th("2.2", "交叉熵、KL 散度与互信息", [
  - *交叉熵*（用 $q$ 编码真实分布 $p$ 的平均代价）：
    $
      H(p,q) = -sum_x p(x) log q(x)
    $
  - *KL 散度*（相对熵）：
    $
      D_"KL" (p||q) = sum_x p(x) log(p(x)/q(x)) = H(p,q) - H(p)
    $
  - 因此 *最小化交叉熵 = 最小化 KL*（当 $p$ 固定时 $H(p)$ 是常数）。这是语言模型、分类模型都用 CE 的理论依据。
  - *性质*：
    - $D_"KL" (p||q) >= 0$，取等当且仅当 $p=q$；
    - 不对称：$D_"KL" (p||q) != D_"KL" (q||p)$，所以不是距离；
    - 不满足三角不等式；$D_"KL" (p||q)$ 可无界。
  - *互信息*（两个变量共享的信息量）：
    $
      I(X;Y) = D_"KL" (p(x,y), p(x)p(y)) = sum_(x,y) p(x,y) log(p(x,y)/(p(x)p(y)))
    $
    - 等价形式：$I(X;Y) = H(X) - H(X divides Y) = H(X) + H(Y) - H(X,Y)$；
    - $I(X;Y) = 0$ 当且仅当 $X,Y$ 独立；
    - 对称：$I(X;Y) = I(Y;X)$。
  - *条件 KL*：$D_"KL" (p(y divides x)|| q(y divides x)) = sum_x p(x) sum_y p(y divides x) log(p(y divides x)/q(y divides x))$。
  #src[依据：L2 P4–18；博客《KL 散度与交叉熵》。]
])

#th("2.3", "困惑度 PPL 与交叉熵的关系", [
  - 给定测试序列 $w_1, dots, w_N$，模型 $P$ 的困惑度：
    $
      "PPL" = P(w_1, dots, w_N)^(-1\/N)
      = exp(-1/N sum_(i=1)^N ln P(w_i divides w_(<i)))
    $
  - 若测试集的真实经验分布为 $p$，模型为 $q$，则：
    $
      "PPL" = exp(H(p,q)) = 2^(H_2(p,q))
    $
    即 PPL 是交叉熵的指数；$H$ 用 nat 时取 $exp$，用 bit 时取 $2^(dot)$。
  - *分解式*（L2 P18）：$2^(H(p,q)) = 2^(H(p)) dot 2^(D_"KL"(p,q))$，即 PPL 由「真实语言的熵」+「模型的相对熵」两部分构成；模型越好 KL 越小，PPL 越接近 $2^(H(p))$。
  - *均匀模型*：若词表大小 $V$，每步均匀预测 $1\/V$，则
    $
      "PPL" = exp(-1/N sum ln(1\/V)) = exp(ln V) = V
    $
  - *性质与易错点*：
    - PPL 越低越好，下界为 1（完美预测）；
    - 它按 *token* 平均，不同 tokenizer/词表下的 PPL 不可直接比较；
    - 序列概率连乘会下溢，实现时在对数空间求和再取指数；
    - 句子级 PPL 与语料级 PPL 不同：前者只对单句平均，后者对所有 token 平均。
  #src[依据：L2 P4–18、L3 P5–17；博客《统计语言模型》《困惑度》。]
])

#th("2.4", "学习范式与生成/判别模型", [
  #tablem[
    | 范式 | 数据形式 | 优化目标 | 典型例子 |
    |---|---|---|---|
    | 监督学习 | $(x,y)$ 成对标注 | 拟合 $P(y divides x)$ 或 $f(x)$ | 分类、NER、POS |
    | 无监督学习 | 只有 $x$ | 发现结构/密度 | 聚类、共现矩阵、PCA |
    | 自监督学习 | 从 $x$ 自动构造标签 | 预测被掩/下一项 | MLM、下一词预测 |
    | 强化学习 | 状态、动作、奖励 | 最大化期望回报 | RLHF、游戏、机器人 |
  ]
  - *有监督学习按标签类型三分*（L2 P38–39）：回归模型（连续标签）、分类模型（离散标签）、*结构预测模型*（标签本身是结构，如序列标注、句法树、序列生成——NLP 大量任务属于此类特例）。
  - *自监督学习属于无监督学习*（L2 P33）：监督信号由数据自身构造。两大范式（L2 P42–45）：*自预测学习*（去噪自编码器、掩码预测 MLM、自回归预测）与*对比学习*（三步：构建正负样本对 → 对比损失拉近正例推开负例 → 优化参数）。
  - *生成式模型*：建模 $P(x,y) = P(y)P(x divides y)$，可采样、可处理缺失数据；需要较强独立性假设；例：朴素贝叶斯、HMM。
  - *判别式模型*：直接建模 $P(y divides x)$ 或学习决策边界；通常精度更高、特征更灵活；例：逻辑回归、CRF、神经网络分类器。
  - *取舍*：生成式在数据少时可以利用先验，判别式在标注充足时通常更强；二者不是互斥的，许多模型同时具有生成和判别解释。
  #src[依据：L2 课件；博客《词法分析》《句法分析与语义角色标注》。]
])

#section("2 · 第 3 讲：统计 NLP")

#th("3.1", "n-gram 语言模型与极大似然估计", [
  - *链式法则*：
    $
      P(w_1, dots, w_N) = product_(i=1)^N P(w_i divides w_1, dots, w_(i-1))
    $
  - *马尔可夫假设*（$n-1$ 阶）：
    $
      P(w_i divides w_1, dots, w_(i-1)) approx P(w_i divides w_(i-n+1), dots, w_(i-1))
    $
  - *n-gram 模型*：
    $
      P(w_1, dots, w_N) approx product_(i=1)^N P(w_i divides w_(i-n+1), dots, w_(i-1))
    $
  - *MLE*：
    $
      P(w_i divides w_(i-n+1)^(i-1)) = (C(w_(i-n+1), dots, w_i)) / (C(w_(i-n+1), dots, w_(i-1)))
    $
    - $n=1$：unigram；$n=2$：bigram；$n=3$：trigram。
    - 参数规模约 $O(V^n)$，随阶数指数增长；高阶模型稀疏严重。
  - *零概率问题*：训练集未出现的 n-gram 计数为 0，整句概率为 0，PPL 为无穷；必须平滑。
  - *实现*：概率连乘改在对数空间求和；用 \<s>、</s> 处理句首句尾；未登录词映射为 \<UNK>。
  #src[依据：L3 P5–17；博客《统计语言模型：n-gram 与数据平滑》。]
])

#th("3.2", "平滑：加 k、插值与回退", [
  - *加 k 平滑*（Laplace 是 $k=1$）：
    $
      P_"add-k"(w_i divides w_(i-1)) = (C(w_(i-1), w_i) + k) / (C(w_(i-1)) + k V)
    $
    - 分母加 $k V$ 是为了让所有 $V$ 个候选词的概率和为 1；
    - $k$ 常取 $0 < k < 1$；加一在大词表上会过度平滑。
  - *插值*（以 trigram 为例）：
    $
      P(w_i divides w_(i-2), w_(i-1)) =
      lambda_3 P(w_i divides w_(i-2), w_(i-1))
      + lambda_2 P(w_i divides w_(i-1))
      + lambda_1 P(w_i)
    $
    - 约束 $lambda_1 + lambda_2 + lambda_3 = 1$，$lambda_j >= 0$；
    - 权重可用 EM 在验证集上学习，也可固定。
  #src[依据：L3 P5–17；博客《统计语言模型：n-gram 与数据平滑》。]
])


#th("3.3", "分词、朴素贝叶斯与 TF-IDF", [
  - *两类切分歧义*（必背名词）：*交集型歧义*——串 $"AJB"$ 中 $"AJ"$、$"JB"$ 同时成词（如「研究生命的起源」中「研究生」）；*组合型歧义*——$"A"$、$"B"$、$"AB"$ 同时成词，是否合并取决于上下文（如「将来」）。
  - *最大匹配*：FMM 从前往后、BMM 从后往前，每次取词典中最长可匹配词；复杂度约 $O(n L)$（$L$ 为最大词长）。
    - BiMM：分别做 FMM/BMM，按“词数少优先、单字词少优先”选择。（PPT P32–43 的逐轮扫描演示带笑脸不考，记原理即可。）
    - 局限：无法处理歧义和未登录词，依赖词典。
  - *其他机械分词法*：*最短路径/最少分词法*（把分词转为图上最短路径，动态规划求解，目标词数最少）与*最大词频分词法*（在候选切分中选词频乘积最大的切分）——与后面 HMM/CRF 的「按概率选最优切分」同思路。
  - *BMES 序列标注*：B 词首、M 词中、E 词尾、S 单字词；合法转移如 B→M/E、M→M/E、E→B/S、S→B/S。注意：分词用 BMES，而 L3 P49 的 NER 标注体系是 BIOES（B/I/O/E/S），两个任务的标签集不同。
  - *朴素贝叶斯文本分类*：
    $
      P(c divides d) prop P(c) product_(w in d) P(w divides c)
    $
    - 拉普拉斯平滑：$P(w divides c) = (C(w,c) + 1)/(C(c) + V)$；
    - 在 log 空间计算，避免下溢；假设词条件独立（bag-of-words）。
  - *TF-IDF*：
    $
      "tf-idf"(t,d) = "tf"_(t,d) dot log(N / "df"_t)
    $
    - $N$ 文档总数，$"df"_t$ 含词 $t$ 的文档数；常用 $log((N+1)/("df"_t+1)) + 1$ 等变体；
    - 向量归一化后用余弦相似度：$cos(d_1,d_2) = (d_1 dot d_2)/(norm(d_1) norm(d_2))$。
  - *评价*：分词用词级 P/R/F1；NER 用实体级 F1（边界和类别都对才算对）。
  #src[依据：L3 P47–54、P114；博客《词法分析》《经典 NLP 任务》。]
])

#th("3.4", "句法分析概念与语义角色标注", [
  - *句法分析两类输出*：短语结构分析（短语结构树/成分树）与*依存句法分析*（词与词之间的二元支配关系）。依存关系术语：支配词（head/ governing word）与从属词（dependent）；常见关系如 SBV 主谓、VOB 动宾。依存树与短语树可相互转换。
  - *完全分析 vs 局部分析*：完全句法分析给出整棵句法树；局部分析（如 SRL、依存弧抽取）只关心目标片段的结构。
  - *语义角色标注 SRL*（L3 P84–87）：以*谓词*（Predicate，通常是动词，标注集如 ChinesePropBank / NomBank）为中心，识别其*论元结构*：谓词本身记 REL，核心论元 ARG0（施事）、ARG1（受事）等，辅助论元统一以 ARGM- 前缀（ARGM-TMP 时间、ARGM-LOC 地点、ARGM-NEG 否定…）。
  - SRL 定位：介于句法分析与语义分析之间的浅层语义分析；把「谁、对谁、在何时何地做了什么」结构化，是信息抽取/问答的基础。
  - *最大熵分类模型*（L3 P112–113 细节带笑脸不考，概念可考）：在经验约束 $bb(E)_"data"[f_k] = bb(E)_(P)[f_k]$ 下选熵最大的条件分布，解为对数线性模型 $P(y|x) = exp(sum_k lambda_k f_(k)(x,y))/Z(x)$——CRF 是其序列版推广。
  #src[依据：L3 P72、P79、P84–87；博客《句法分析与语义角色标注》。]
])

#section("3 · 第 4 讲：深度学习与 Transformer")

#th("4.1", "感知机与激活函数", [
  - *感知机*：$y = "sign"(w dot x + b)$；PPT（L4 P10）给出的误差驱动更新：
    $
      w <- w + eta (y - hat(y)) x, quad b <- b + eta (y - hat(y))
    $
    （$y in {-1,+1}$；误分类时 $(y-hat(y))x$ 把 $w$ 拉向正确一侧。）若数据线性可分，感知机收敛；否则不保证。*局限*：单层感知机无法解决 XOR 等线性不可分问题（L4 P11–14 数值例），需多层+非线性激活。
  - *常见激活*：
    #tablem[
      | 函数 | 定义 | 导数 | 特点 |
      |---|---|---|---|
      | Sigmoid | $sigma(z) = 1/(1+exp(-z))$ | $sigma(1-sigma)$ | 输出 (0,1)，饱和区梯度消失 |
      | Tanh | $tanh(z)$ | $1 - tanh^2 z$ | 零中心，仍会饱和 |
      | ReLU | $max(0,z)$ | $1$（$z>0$）否则 $0$ | 计算快，可能“死亡” |
      | LeakyReLU | $max(alpha z, z)$ | $alpha$ 或 $1$ | 缓解死亡 ReLU |
      | GELU | $z dot Phi(z)$ | 光滑近似 | Transformer 常用 |
      | Softmax | $exp(z_i)/(sum_j exp(z_j))$ | $s_i (delta_(i j)-s_j)$ | 输出概率分布 |
    ]
  - *选择*：隐藏层常用 ReLU/GELU；二分类输出用 sigmoid；多分类输出用 softmax；回归输出用线性。
  #src[依据：L4 P9、P39–40；博客《NLP 评价指标》相关章节。]
])

#th("4.2", "损失函数与 softmax 梯度", [
  - *交叉熵*（one-hot 标签 $y$）：
    $
      cal(L)_"CE" = -sum_(c=1)^C y_c log hat(y)_c = -log hat(y)_(c^*)
    $
  - *均方误差*：$cal(L)_"MSE" = 1/n sum_i (y_i - hat(y)_i)^2$。
  - *softmax*：
    $
      hat(y)_i = (exp(z_i)) / (sum_j exp(z_j))
    $
  - *关键推导*（softmax + CE）：
    $
      (partial cal(L))/(partial z_i) = hat(y)_i - y_i
    $
    推导要点：先对 $log hat(y)_(c^*)$ 求导得到 $-1/hat(y)_(c^*)$，再乘 softmax 的雅可比，利用 $sum_j y_j = 1$ 化简。
  - *为什么分类用 CE 而不是 MSE*：
    - CE 对 logits 的梯度是线性的误差 $hat(y)-y$，饱和时仍能学习；
    - MSE + sigmoid 的梯度含 $sigma'(z)$，饱和区接近 0，学得慢且非凸；
    - CE 衡量概率分布差异，与最大似然一致。
    - CE 对高自信的错误预测惩罚更大
  - *实现*：用 log-sum-exp 稳定计算；标签平滑为 $y_i' = (1-epsilon)y_i + epsilon/C$，缓解过自信。
  #src[依据：L4 P39–40；博客《KL 散度与交叉熵》。]
])

#th("4.3", "反向传播（BP）", [
  - *前向*：对第 $l$ 层
    $
      z^((l)) = W^((l)) a^((l-1)) + b^((l)), quad a^((l)) = f(z^((l)))
    $
  - *反向定义误差* $delta^((l)) = (partial cal(L))/(partial z^((l)))$，则
    $
      delta^((L)) &= nabla_a cal(L) dot f'(z^((L))) \
      delta^((l)) &= ((W^((l+1)))^T delta^((l+1))) dot f'(z^((l)))
    $
    $
      (partial cal(L))/(partial W^((l))) = delta^((l)) (a^((l-1)))^T, quad
      (partial cal(L))/(partial b^((l))) = delta^((l))
    $
  - *维度检查*：$delta^((l)) in RR^(n_l)$，$W^((l)) in RR^(n_l times n_(l-1))$，所以 $delta^((l))(a^((l-1)))^T$ 形状一致。
  - *softmax + CE 的特例*：$delta^((L)) = hat(y) - y$。
  - *梯度消失/爆炸*：深层连乘 $product_l W^((l)) f'(z^((l)))$；用 ReLU/残差/归一化/梯度裁剪缓解。
  - *计算成本*：反向约是前向的 2 倍；需要缓存前向激活（或用重计算换显存）。
  #src[依据：L4 P31–43；博客《反向传播》。]
])

#th("4.4", "CNN 的尺寸与参数量", [
  - *一维卷积*（文本常用）：输入长度 $n$，卷积核宽度 $k$，步长 $s$，填充 $p$：
    $
      n_"out" = floor((n + 2p - k)/s) + 1
    $
  - *二维卷积*：$H_"out" = floor((H + 2p - k_h)/s) + 1$，$W_"out"$ 同理。
  - *参数量*（单个卷积层）：
    $
      (k_h k_w C_"in" + 1) C_"out"
    $
    其中 $+1$ 是每个输出通道一个偏置；池化层无参数。
  - *CNN 四特性*（L4 P53–57）：局部连接、参数共享（同一卷积核扫全图）、多核（多个滤波器提取不同特征）、池化降采样。*池化三作用*：降维减少计算、获得平移不变性、扩大感受野。经典架构 LeNet→AlexNet→VGG→GoogLeNet→ResNet（L4 P58–88）#tag("PPT不考")（带笑脸，属纯 CV 内容；只需知道 ResNet 残差缓解梯度消失即可）。
  - *文本 CNN*：用不同宽度（如 3/4/5）的 1D 卷积核提取 n-gram 特征，每个特征图做 max-pooling，再拼接：
    $
      hat(v)_w = [max(f_1); max(f_2); dots; max(f_m)]
    $
  - *感受野*：堆叠卷积时感受野逐层扩大；膨胀卷积可指数扩大而不增加参数。
  - *复杂度*：卷积层约 $O(n k C_"in" C_"out")$；池化 $O(n C)$。
  #src[依据：L4 P47–60；博客《子词分词》《经典 NLP 任务》。]
])

#th("4.5", "RNN、LSTM 与 GRU", [
  - *RNN*：
    $
      h_t = tanh(W_x x_t + W_h h_(t-1) + b), quad y_t = W_y h_t + b_y
    $
    - 参数在所有时间步共享；BPTT 沿时间展开求梯度；
    - 梯度连乘 $product_t W_h dot "diag"(f')$，谱半径小于 1 时消失、大于 1 时爆炸。
  - *LSTM*：
    $
      f_t &= sigma(W_f [h_(t-1), x_t] + b_f) \
      i_t &= sigma(W_i [h_(t-1), x_t] + b_i) \
      g_t &= tanh(W_g [h_(t-1), x_t] + b_g) \
      c_t &= f_t dot c_(t-1) + i_t dot g_t \
      o_t &= sigma(W_o [h_(t-1), x_t] + b_o) \
      h_t &= o_t dot tanh(c_t)
    $
    - 细胞状态 $c_t$ 的加法更新让梯度可以较稳定地回传；门控控制遗忘/写入/输出。
  - *GRU*（简化版 LSTM）：
    $
      z_t &= sigma(W_z [h_(t-1), x_t]) \
      r_t &= sigma(W_r [h_(t-1), x_t]) \
      tilde(h)_t &= tanh(W_h [r_t dot h_(t-1), x_t]) \
      h_t &= (1-z_t) dot h_(t-1) + z_t dot tilde(h)_t
    $
  - *双向 RNN*：正向和反向隐藏状态拼接 $h_t = [arrow(h)_t; arrow.l(h)_t]$，用于序列标注。
  - *复杂度*：每层每步 $O(d^2)$，整序列 $O(T d^2)$；串行计算，难以并行。
  #src[依据：L4 课件、L6；博客《NNLM 与 RNNLM》《LSTM 与 GRU》。]
])

#th("4.6", "注意力机制与多头注意力", [
  - *注意力*是软查表：query 与 key 算相似度，softmax 归一化后加权 value。
    $
      e_(i j) = (q_i^T k_j) / sqrt(d_k), quad
      alpha_(i j) = "softmax"_(j)(e_(i j)), quad
      o_i = sum_j alpha_(i j) v_j
    $
  - *两种打分函数*（L4 P115–117）：加性注意力 $e_(i j) = v^T "tanh"(W_q q_i + W_k k_j)$ 与缩放点积注意力。课后题「为什么 Transformer 选点积」：点积可用高度优化的矩阵乘法实现、时间与空间效率都远高于加性注意力（L4 P148 习题）。
  - *缩放点积注意力*：
    $
      "Attention"(Q,K,V) = "softmax"((Q K^T)/sqrt(d_k)) V
    $
    - 除以 $sqrt(d_k)$ 的原因：若 $q,k$ 各分量独立、方差为 1，点积方差为 $d_k$；不缩放会使 softmax 饱和、梯度变小。
  - *多头*：
    $
      "head"_i = "Attention"(Q W_i^Q, K W_i^K, V W_i^V)
    $
    $
      "MHA"(Q,K,V) = "Concat"("head"_1, dots, "head"_H) W^O
    $
    - 每个头维度 $d_k = d/H$；总计算量与单头 $d$ 维相近；
    - 不同头可以关注不同位置/关系。
  - *掩码*：
    - padding mask：把填充位置的得分置 $-infinity$；
    - causal mask：解码器只能看 $j <= i$，上三角置 $-infinity$。
  - *复杂度*：$O(n^2 d)$ 时间、$O(n^2)$ 注意力矩阵（FlashAttention 可避免显式存储）。
  #src[依据：L4 P115–131；博客《Transformer》《现代 LLM 组件》。]
])

#th("4.7", "Transformer 结构与复杂度", [
  #text(fill: accent, size: 7.2pt)[注：L4 P132–147 的逐 Step 数值实例与注意力可视化带笑脸不考；本节结构与公式经 L7 重复讲解，属重点。]
  - *编码器层*：多头自注意力 → 残差 + LayerNorm → FFN → 残差 + LayerNorm。
  - *解码器层*：带 causal mask 的自注意力 → 交叉注意力（attend 编码器输出）→ FFN，各有残差 + 归一化。
  - *LayerNorm*：
    $
      "LN"(x) = gamma dot (x - mu) / sqrt(sigma^2 + epsilon) + beta
    $
    其中 $mu, sigma^2$ 在特征维上统计；与 BatchNorm 不同，不依赖批次。
  - *位置编码*（正弦）：
    $
      "PE"("pos", 2i) = sin("pos" / 10000^(2i/d)), quad
      "PE"("pos", 2i+1) = cos("pos" / 10000^(2i/d))
    $
    - 允许模型通过线性变换表达相对位置；也可用可学习位置嵌入/RoPE。
  - *FFN*：$"FFN"(x) = max(0, x W_1 + b_1) W_2 + b_2$，中间维度通常 $4d$。
  - *参数量（每层，$d_"ff" = 4d$）*：
    - 注意力：$W_Q, W_K, W_V, W_O$ 各 $d times d$，共 $4d^2$；
    - FFN：$d times 4d + 4d times d = 8d^2$；
    - 合计约 $12d^2$（再加 LayerNorm 的 $4d$ 和偏置）。
  - *复杂度*：自注意力 $O(n^2 d)$，FFN $O(n d^2)$；短序列时 FFN 主导，长序列时注意力主导；训练可并行，推理 decode 串行。
  - *Pre-LN vs Post-LN*：
    - Post-LN：$x + "Sublayer"(x)$ 后再 LN，深层需 warmup；
    - Pre-LN：$x + "Sublayer"("LN"(x))$，残差通路干净，训练更稳定；
    - Sandwich-LN：子层前后都 LN，适合超深模型。
  #src[依据：L4 P122–142；博客《Transformer》《大模型预训练：整体框架与模型架构》。]
])

#section("4 · 第 5 讲：评价指标")

#th("5.1", "混淆矩阵、P/R/F1", [
  - 二分类混淆矩阵：
    #tablem[
      | 真实 vs 预测 | 预测正 | 预测负 |
      |---|---|---|
      | 真实正 | TP | FN（漏报） |
      | 真实负 | FP（误报） | TN |
    ]
  - *准确率*：$"Acc" = ("TP" + "TN")/("TP" + "TN" + "FP" + "FN")$。
  - *精确率*：$P = "TP"/("TP" + "FP")$，判为正的样本里有多少是真的。
  - *召回率*：$R = "TP"/("TP" + "FN")$，真正的正例里找回了多少。
  - *F1*：$F_1 = (2 P R)/(P + R)$；更一般地
    $
      F_beta = ((1 + beta^2) P R) / (beta^2 P + R)
    $
    - $beta > 1$ 更看重召回，$beta < 1$ 更看重精确；
    - F1 是 P 和 R 的调和平均，任一为 0 则 F1 为 0。
  - *易错*：类别不平衡时准确率会误导；多分类要先明确宏/微平均。
  #src[依据：L5 P14；博客《NLP 评价指标》。]
])

#th("5.2", "宏平均、微平均与 ROC/AUC", [
  - 对 $C$ 个类别，分别算 $P_i, R_i, F_(1,i)$：
    - *宏平均*：$"Macro-P" = 1/C sum_i P_i$，每个类别等权，小类别影响被放大；
    - *微平均*：先汇总 $"TP", "FP", "FN"$ 再算
      $
        "Micro-P" = (sum_i "TP"_i)/(sum_i ("TP"_i + "FP"_i)), quad
        "Micro-R" = (sum_i "TP"_i)/(sum_i ("TP"_i + "FN"_i))
      $
      每个样本等权，大类别主导；
    - *加权平均*：$sum_i w_i P_i$，$w_i$ 为类别样本占比。
  - *ROC*：横轴 $"FPR" = "FP"/("FP" + "TN")$，纵轴 $"TPR" = "TP"/("TP" + "FN") = R$；改变阈值得到曲线。
  - *AUC*：ROC 曲线下面积；0.5 随机、1 完美；等价于随机取一正一负、正例得分高于负例的概率。
  - *PR 曲线*：类别极不平衡时比 ROC 更敏感；平均精度 AP 是 PR 曲线下面积。
  - *易错*：多分类 AUC 需要 one-vs-rest 或 one-vs-one 的具体定义；AUC 与准确率不是一回事。
  #src[依据：L5 P14；博客《NLP 评价指标》。]
])

#th("5.3", "回归指标与相关系数", [
  - *MAE*：$1/n sum_i |y_i - hat(y)_i|$，对离群点不敏感，单位与原数据一致。
  - *MSE*：$1/n sum_i (y_i - hat(y)_i)^2$；*RMSE* 为其平方根，单位与原数据一致。
  - *R²*：$1 - (sum_i (y_i - hat(y)_i)^2)/(sum_i (y_i - bar(y))^2)$。
  - *Pearson*：
    $
      r = ("cov"(X,Y))/(sigma_X sigma_Y)
      = (sum_i (x_i - bar(x))(y_i - bar(y))) /
        (sqrt(sum_i (x_i - bar(x))^2) sqrt(sum_i (y_i - bar(y))^2))
    $
    衡量线性相关，$r in [-1,1]$；对离群点敏感。
  - *Spearman*：对秩求 Pearson，$rho = r("rank"(X), "rank"(Y))$；衡量单调关系，对异常值更稳健。*Kendall τ*（L5 P42）：基于一致对/不一致对的秩相关，$tau = (C-D)/(C+D)$，小样本更稳。
  - *Pearson 性质*（L5 P40–41）：对称、对线性变换不变（尺度不变）、$r in [-1,1]$；$|r|$ 分段解读：0.8 以上高度相关、0.4–0.8 中度、低于 0.4 较弱。
  - *评价三核心问题*（L5 P3）：用什么数据（测试集构建）、用什么方法（自动/人工）、用什么指标；Benchmark（GLUE/SuperGLUE/SQuAD 等）把三者标准化，使不同系统可比较。
  - *选择*：关注绝对误差用 MAE；关注大误差惩罚用 RMSE；关注排序/一致性用 Spearman/Kendall。
  #src[依据：L5 课件；博客《NLP 评价指标》。]
])

#th("5.4", "BLEU：截断精确率与长度惩罚", [
  - g 是候选译文 $hat(Y)$ 或参考译文 $Y$ 的 n-gram，$"count"_(C)(g)$ 是该 n-gram 出现次数，$cal(C)$、$cal(R)$ 分别是候选译文集合和参考译文集合。
  - 对每个 $n$，候选译文 $C$ 的 *截断精确率*：
    $
      p_n = (sum_(C in cal(C)) sum_(g in C) min("count"_(C)(g), max_(R in cal(R)) "count"_(R)(g))) /
            (sum_(C in cal(C)) sum_(g in C) "count"_(C)(g))
    $
    - 只考虑匹配上的，没匹配的不算
    - 分子把候选中的 n-gram 匹配次数截断到参考译文中该 n-gram 的最大出现次数，防止重复词刷分；
    - 分母是 *候选* 译文的 n-gram 总数。
  - *长度惩罚*（Brevity Penalty）：
    $
      "BP" = cases(
        1 & "若 " c > r,
        exp(1 - r/c) & "若 " c <= r
      )
    $
    $c$ 为候选长度，$r$ 为参考长度（多参考时取最接近候选长度的参考长度）。
  - *BLEU*：
    $
      "BLEU" = "BP" dot exp(sum_(n=1)^N w_n log p_n), quad w_n = 1/N
    $
    通常 $N=4$；任一 $p_n=0$ 会使几何平均为 0，实际实现加平滑。等价对数形式：$log "BLEU" = min(1 - r/c, 0) + sum_n w_n log p_n$。
  - *PPT 例题*（补充材料《BLEU》）：
    - 截断动机：候选全是 “the”×7，朴素 unigram 精度 $7/7$，clip 后 $2/7$；modified n-gram：两个候选分别得 $10/17$ 与 $1/13$，重复刷分被压下去；
    - 短句反例：候选 “of the”，$p_1 = 2/2$、$p_2 = 1/1$ 全对但极短 → 必须配 BP；
    - 满分例：候选 “the book is on the desk” 与参考完全一致，$p_1=p_2=p_3=1$、$c=r=6$、$"BP"=e^0=1$，BLEU$=1$；
    - guard 例（L5 P49）：$p_1 = 4/9$、$p_2 = 2/8$。
  - *解释*：unigram 精度近似衡量*忠实度 adequacy*（内容对不对），较长 n-gram 衡量*流利度 fluency*（顺序对不对）。
  - *局限*：只看表面 n-gram，忽略语义、词序和长距离调序；依赖参考译文质量。数据：IWSLT2004 中 MT 系统输出在 13/20 句上胜过人工译文；单参考与人工判断的字面相关性 0.573，4 参考升到 0.684。改进指标：NIST（信息加权、n-gram 分数求和、$N=5$）、SNR、LTE（按字母 6-gram）。
  #src[依据：L5 P49–55；补充材料《案例-BLEU》；博客《NLP 评价指标》。]
])

#th("5.5", "ROUGE、BERTScore 与 COMET", [
  - *ROUGE-N*（召回导向）：分子为候选与参考 n-gram 的*裁剪匹配数*（匹配次数截断到参考中的出现次数），分母为*参考* n-gram 总数：
    $
      "ROUGE-N" = (sum_(R in cal(R)) sum_(g in R) min("count"_(hat(Y))(g), "count"_(Y)(g))) /
                  (sum_(R in cal(R)) sum_(g in R) "count"_(Y)(g))
    $
    - PPT 例（L5 P59/62）：参考 8 个 unigram、候选与之匹配 4 个 → ROUGE-1$=4/8$；bigram 匹配 2/7 → ROUGE-2$=2/7$；LCS 长度 4。
  - *ROUGE-L*（基于最长公共子序列 LCS）：
    $
      R_"LCS" = ("LCS"(hat(Y), Y))/ (|Y|), quad
      P_"LCS" = ("LCS"(hat(Y), Y))/(|hat(Y)|)
    $
    $
      F_"LCS" = ((1 + beta^2) R_"LCS" P_"LCS") / (R_"LCS" + beta^2 P_"LCS")
    $
    $beta$ 通常取较大值，使指标偏向召回。
  - *BERTScore*：用预训练编码器得到上下文向量，做贪心最大匹配：
    $
      R_"BERT" = 1/(|x|) sum_(x_i in x) max_(hat(x)_j in hat(x)) cos(h_i, hat(h)_j)
    $
    $
      P_"BERT" = 1/(|hat(x)|) sum_(hat(x)_j in hat(x)) max_(x_i in x) cos(h_i, hat(h)_j)
    $
    常加 IDF 权重降低停用词影响：$w_i = log(N/(n_i + 1))$。PPT 例（L5 P73）：「weather/freezing」字面零重叠但上下文向量相似度高——BERTScore 能捕捉语义改写。
  - *COMET*：输入源文、候选、参考，输出质量分数；
    - estimator：回归人工分数，MSE 训练；
    - ranking：用三元组（参考、较好、较差）和 Triplet Margin Loss 训练：
      $
        L = max(0, m + d(v_"ref", v_"pos") - d(v_"ref", v_"neg"))
      $
      （$m$ 为间隔 margin，$d$ 为表示空间距离。）
  - *对比*：BLEU/ROUGE 是字符串重叠；BERTScore 是语义相似度；COMET 是学习到的翻译质量模型，通常与人工评价相关性更高。
  #src[依据：L5 P49–56；博客《NLP 评价指标》。]
])

#th("5.6", "LLM-as-a-Judge 的偏差与控制", [
  - *常见形式*：1–10 打分、成对比较、多项选择/是非判断。
  - *流程*：设计指令模板 → 选择评委模型 → 解析输出 → 后处理汇总。
  - *已知偏差*：
    - 位置偏差：偏爱某个位置的答案；
    - 长度偏差：偏爱更长答案；
    - 自我偏差：偏爱自己或同源模型的输出；
    - 稳定性：模型版本更新导致结果不可复现；
    - 隐私：待评价内容发送给外部模型可能泄露。
  - *缓解*：交换 A/B 顺序、控制长度、多个评委投票、人工抽检校准、固定评委版本。
  - *指标*：成对比较用胜率 $"win rate" = W/(W+L)$（平局可单列）；多人/多模型排名可用 Elo/Bradley–Terry。*MT-Bench 数据*（L5 P95）：GPT-4 评委与人类偏好一致率 85%，而人与人之间仅 81%——这是 LLM-as-judge 可信度的核心论据。
  #src[依据：L5、L10 P75；博客《NLP 评价指标》《大语言模型的评价》。]
])

#section("5 · 第 6 讲：词表示与预训练模型")

#th("6.1", "共现矩阵、PMI 与 SVD", [
  - *one-hot*：$x_w in {0,1}^V$，任意两个不同词内积为 0，无法表达相似性。
  - *分布式假设*：上下文相似的词语义相似。
  - *共现矩阵*：$C_(i j)$ 为词 $j$ 出现在词 $i$ 窗口中的次数；可按距离加权：
    $
      C_(i j) = sum_(d(w_i,w_j)) 1/(d(w_i,w_j))
    $
  - *PMI*：
    $
      "PMI"(w_i,w_j) = log(P(w_i,w_j)/(P(w_i)P(w_j)))
      = log((C_(i j) dot |cal(C)|)/(C_i C_j))
    $
    - $C_i = sum_j C_(i j)$；$|cal(C)|$ 为总词数；
    - PMI 可为负、对低频词不稳定；PPMI 取 $max("PMI",0)$。
  - *SVD 降维*：
    $
      C = U Sigma V^T approx U_k Sigma_k V_k^T
    $
    - 词向量可取 $U_k$ 的第 $i$ 行，或 $U_k Sigma_k^(1/2)$ 的第 $i$ 行；
    - $k << V$，得到稠密低维表示。
  - *局限*：共现矩阵 $V times V$ 构造和分解成本高；新词需重新分解；静态向量无法区分多义词。
  - *词向量的评价*（L6 P39–46）：
    - *内部评价*：在特定 NLP 任务上评测（性能即证据）；*外部评价*：用与任务无关的心理语言学测试直接评估表示质量。实践中内部评价更常用（与下游目标一致）；
    - 词义相似度：$cos(v_1,v_2) = (v_1^T v_2)/(norm(v_1) norm(v_2))$，基准 WordSim-353、SimLex-999（人工相似度打分），用 Spearman/Pearson 相关系数衡量与人工判断的一致性；
    - 类比检索：$w^* = op("argmax")_w cos(v_b - v_a + v_c, v_w)$（king−man+woman≈queen）。
  #src[依据：L6；博客《词向量基础》。]
])

#th("6.2", "Word2Vec：Skip-gram、CBOW 与梯度", [
  - *参数*：输入嵌入 $W_"in" in RR^(d times V)$（列是中心词向量 $v_w$），输出嵌入 $W_"out" in RR^(V times d)$（行是上下文向量 $u_w$）；总参数 $2 V d$。
  - *Skip-gram*：用中心词预测窗口内上下文：
    $
      max_theta sum_(t=1)^T sum_(-m <= j <= m, j != 0) log P(w_(t+j) divides w_t)
    $
    $
      P(w_o divides w_c) = (exp(u_(w_o)^T v_(w_c))) / (sum_(w in cal(V)) exp(u_w^T v_(w_c)))
    $
  - *梯度*：
    $
      (partial cal(L))/(partial v_(w_c)) = -u_(w_o) + sum_(w in cal(V)) P(w divides w_c) u_w
    $
    $
      (partial cal(L))/(partial u_w) = (P(w divides w_c) - delta_(w,w_o)) v_(w_c)
    $
    - 第一项把中心词拉向真实上下文，第二项按预测分布“推开”其他词；
    - 每次更新要对全词表求和，复杂度 $O(V d)$，这是瓶颈。
  - *CBOW*：上下文向量平均后预测中心词：
    $
      h = 1/(|cal(C)_t|) sum_(w in cal(C)_t) v_w, quad
      P(w_t divides cal(C)_t) = (exp(u_(w_t)^T h))/(sum_w exp(u_w^T h))
    $
    - 训练更快，但上下文被平均稀释，稀有词效果通常不如 Skip-gram。
  - *对比*：
    #tablem[
      | 维度 | CBOW | Skip-gram |
      |---|---|---|
      | 输入 | 多个上下文词 | 一个中心词 |
      | 预测 | 一个中心词 | 多个上下文词 |
      | 速度 | 快 | 慢 |
      | 稀有词 | 较弱 | 较好 |
    ]
  #src[依据：L6；博客《Word2Vec：Skip-gram、CBOW 与负采样》。]
])

#th("6.3", "负采样与层次 Softmax", [
  - *负采样*：把“从 $V$ 个词中选正确上下文”变成“判断词对是否真实共现”的二分类。
    - 对正样本 $(w_c, w_o)$ 采 $k$ 个负例 $(w_c, w_i^-)$；
    - 单样本损失：
      $
        cal(L) = -log sigma(u_(w_o)^T v_(w_c)) - sum_(i=1)^k log sigma(-u_(w_i^-)^T v_(w_c))
      $
    - 复杂度从 $O(V)$ 降到 $O(k)$；$k$ 常取 5–20（小语料）或 2–5（大语料）。
  - *噪声分布*：PPT（L6 P24）表述为「从原始词分布 $P(w) prop "count"(w)$ 中随机采 $K$ 个负例」；原论文用 $P(w) prop "count"(w)^(3/4)$——3/4 次幂压低高频词、提升低频词，避免负例几乎全是 “the”“a”。简答按 PPT 写均匀/词频采样即可，注明改进来自原文。
  - *层次 Softmax*：用 Huffman 树组织词表，每个词对应一条根到叶路径：
    $
      P(w_o divides w_c) = product_(l=1)^(L(w_o)-1) sigma(s_l dot u_(n(w_o,l))^T v_(w_c))
    $
    - $L(w_o)$ 路径长度，$n(w_o,l)$ 路径节点，$s_l in {+1,-1}$ 表示左右分支；
    - 高频词路径短，平均 $O(log V)$ 次二分类；树结构依赖词频、难以并行。
  - *训练技巧*：动态窗口、高频词下采样、学习率衰减。
  #src[依据：L6；博客《Word2Vec：Skip-gram、CBOW 与负采样》。]
])

#th("6.4", "GloVe：共现概率的加权回归", [
  - 设 $C_(i j)$ 为词 $j$ 出现在词 $i$ 上下文的共现次数（可按距离加权 $C_(i j) = sum_d 1/d(w_i,w_j)$），$p_(i j) = P(w_j divides w_i) = C_(i j) / (sum_((j'=1))^(|V|) C_(i j'))$。
  - *符号约定*：$v_i$ 是词 $w_i$ 作*中心词*的向量，$u_j$ 是词 $w_j$ 作*上下文词*的向量（与 Word2Vec 的 $v_c/u_o$ 记号一致）。
  - *加权最小二乘目标*（规范形式；PPT P27 的负号与下标顺序系排版问题，按此写）：
    $
      J = sum_(i=1)^(|V|) sum_(j=1)^(|V|) f(C_(i j)) (u_i^T v_j + b_i + c_j - log C_(i j))^2
    $
    - $f(x) = cases((x/x_"max")^alpha & "若 " x < x_"max", 1 & "若 " x >= x_"max")$，$alpha = 0.75$，$x_"max" = 100$；
    - $C_(i j)=0$ 时 $f(0)=0$，未共现词对不参与损失；低频共现权重小，高频截断为 1；
    - $b_i, c_j$ 分别是中心词/上下文词偏置，保证 $i,j$ 交换时形式对称；
    - 直觉：让向量点积 $u_i^T v_j$ 回归共现次数的对数 $log C_(i j)$。
  - *对称性*：共现矩阵对称 ⇒ 理论上中心词向量与上下文词向量相等；实际因随机初始化不同，*最终词向量取两者之和* $e_i = u_i + v_i$，偏置丢弃。
  - *对比*：SVD/LSA 分解共现矩阵提取潜在语义；Word2Vec 只看局部窗口做预测；GloVe 用全局共现统计做加权回归，兼取两者优点。
  #src[依据：L6 P25–27（PPT 公式有排版瑕疵，本表按规范记号）；博客《GloVe：全局共现与加权最小二乘》。]
])

#th("6.5", "子词：BPE、WordPiece 与 Unigram", [
  - *fastText*：词向量为整词向量加字符 n-gram 向量：
    $
      v_w = v_w + sum_(g in "ngrams"(w)) v_g
    $
    - 首尾加 `<`、`>`，常取字符 3–6 gram；未登录词可由 n-gram 拼出向量。
  - *BPE 训练*：
    1. 预分词并统计词频；
    2. 每个词拆成字符序列，词尾加 `</w>`；
    3. 统计相邻符号对，计数乘以词频，不跨词；
    4. 合并频率最高的对，加入词表并记录规则；
    5. 重复直到词表达到目标大小。
    - 分词时按学到的合并规则*从长到短*贪心匹配，输出按 `</w>` 位置合并回原词；GPT-2 用字节级 BPE，先转 UTF-8 字节，无 OOV。
  - *WordPiece*：与 BPE 框架相同，但合并依据是*似然增益/互信息*：选使语料似然提升最大的一对，近似打分 $"score"(a,b) = ("count"("ab")) / ("count"(a) dot "count"(b))$（即 $P("ab")/(P(a)P(b))$，对应互信息 $log P("ab")/(P(a)P(b))$ 最大）；
    - 非词首子词用 `##` 标记；分词时最长匹配优先，匹配不到回退 `[UNK]`。
  - *Unigram*：先构造大候选词表，用 EM 估计每个子词概率，再逐步删除“删掉后语料似然损失最小”的子词。
    - 切分概率 $P(S) = product_(t in S) P(t)$；
    - 分词用 Viterbi 找 $op("argmax")_S P(S)$。
  - *SentencePiece*：直接处理原始文本，空格记为 `▁`，可逆；支持 BPE/Unigram 两种模型。
  - *词表大小取舍*：词表小→序列长、注意力成本高；词表大→嵌入矩阵大、低频 token 训练不足。
  #src[依据：L6；博客《子词分词：BPE、WordPiece 与 SentencePiece》。]
])

#th("6.6", "NNLM 与 RNNLM 的公式与参数量", [
  - *NNLM*（固定窗口 $n-1$）：
    $
      v &= [v_(w_(i-n+1)); dots; v_(w_(i-1))] in RR^((n-1)d) \
      h &= f(W_"hid" v + b_"hid") \
      y &= W_"out" h + b_"out", quad P(w_i = k divides "history") = (exp(y_k))/(sum_j exp(y_j))
    $
  - *参数量*：
    $
      V d + m(n-1)d + m + V m + V = V(d+m+1) + m((n-1)d+1)
    $
    - 各项依次为：嵌入 $V d$、隐藏层权重 $m(n-1)d$、隐藏层偏置 $m$、输出层权重 $V m$、输出层偏置 $V$；
    - 随 $V$ 和 $n-1$ 线性增长；n-gram 条件表约 $V^(n-1)$，指数增长。
  - *训练目标*：
    $
      cal(L) = -sum_(i=1)^T log P(w_i divides w_(i-n+1), dots, w_(i-1))
    $
  - *RNNLM*：
    $
      x_i &= [v_(w_(i-1)); h_(i-1)] in RR^(d+m) \
      h_i &= tanh(U v_(w_(i-1)) + V h_(i-1) + b) \
      y_i &= W_"out" h_i + b_"out"
    $
    - 参数跨时间共享；理论上可携带任意长历史；BPTT 训练，存在梯度消失/爆炸。
  - *PPL*：$exp(-1/T sum_i log P(w_i divides w_(<i)))$。
  #src[依据：L6；博客《神经网络语言模型：NNLM 与 RNNLM》。]
])

#th("6.7", "预训练语言模型总览：一条统一答题框架", [
  - *核心思想*：大规模无标注语料*自监督预训练* → 学习通用语言表示 → *微调*（或特征接入）适配下游任务。
  - *按预训练目标四分*（教材 6.3 组织思路，也是考试分类口径）：*动态词向量*（ELMo，双向 LM + 任务层加权）、*自回归*（GPT，单向 next-token）、*掩码*（BERT，MLM+NSP）、*去噪重建*（BART，seq2seq 原文复原）。
  - *逐模型背三件事*（教材对每个模型都按此展开）：① 结构（输入层/编码层/输出层）；② 自监督预训练目标（公式）；③ 下游任务适配方式（取哪个表示、接什么头、损失）。
  - *预训练模型三要素*（L6 P140 结语）：训练目标（预测什么）、数据（无标注语料）、架构（如何编码上下文）。
  - *选型直觉*：理解任务要双向 → BERT；生成任务要因果顺序 → GPT；既要理解又要生成 → BART；把 LLM 当固定特征用 → ELMo。
  - *快速对比*（T5 不考，已略）：
    #tablem[
      | 模型 | 结构 | 预训练目标 | 下游取哪个表示 |
      |---|---|---|---|
      | ELMo | 双向 LSTM | 双向 LM | 各层加权和（冻结接入） |
      | GPT | decoder-only | 自回归 LM | 末位置 $h_n^((L))$ + $W_y$ |
      | BERT | encoder-only | MLM + NSP | $h_[["CLS"]]$ 或各位置 $h_i$ |
      | BART | encoder-decoder | 加噪→重建 | 解码器末状态 / 自回归生成 |
    ]
  #src[依据：教材 6.3 节；L6 P70–141；博客《预训练语言模型：四种范式速览》。]
])

#th("6.8", "ELMo：动态词向量（双向 LM）", [
  - *动机*：Word2Vec/GloVe 一词一向量（静态），无法区分多义词；ELMo 按上下文*动态计算*词表示（上下文相关词向量）。
  - *结构*（教材 6.3.1）：
    - 输入层：字符嵌入 $v^"_char"_(c_j) = W_"char" e_(c_j)$ → 多尺度 CNN 组合 + 最大池化得词级表示 $hat(v)_i$ → Highway 网络 $v_i = g dot hat(v)_i + (1-g) dot "ReLU"(W hat(v)_i + b)$，门控 $g = "sigmoid"(W_g hat(v)_i + b_g)$（缓解梯度消失/爆炸）；
    - 编码层：两个*独立*的多层双向 LSTM 分别前向/后向建模，方向间*共享输出层参数*；对词 $w_i$，$L$ 层模型给出 $2L+1$ 个表示：输入层上下文无关向量 $v_i$ 加上每层的 $h_(i,j)^"LM"$（$j = 1, dots, L$），其中 $h_(i,j)^"LM"$ 是第 $j$ 层前向与后向隐状态的拼接。
  - *预训练目标*：双向语言模型，两个方向分别最大化
    $
      sum_(i=1)^N [log P(w_i divides w_1, dots, w_(i-1)) + log P(w_i divides w_(i+1), dots, w_N)]
    $
  - *下游适配*：任务层加权 $text("ELMo")_i^"task" = gamma^"task" sum_(j=0)^L s_j^"task" h_(i,j)^"LM"$；$s_j$ softmax 归一化、在*下游任务*中学习，$gamma$ 为缩放系数；预训练编码器整体*冻结*。低层偏语法、高层偏语义。
  - *意义*：首个深度上下文相关词向量模型，预训练语言模型的早期尝试。
  #src[依据：教材 6.3.1；L6；博客《ELMo》。]
])

#th("6.9", "GPT：自回归预训练语言模型", [
  - *结构*（教材 6.3.2）：decoder-only、单向（约束自注意力，每位置只看左侧，保证因果性）。
    - 输入层：$v_i = v_i^t + v_i^p$（词嵌入 + *可学习*位置嵌入；GPT 无段嵌入）；
    - 编码层：$h^((L)) = "Transformer-Block"^(L)(h^((0)))$，$L$ 层堆叠；
    - 输出层：$P(w_i divides w_1, dots, w_(i-1)) = "softmax"(W_e h_i^((L)) + b^"out")$，$W_e in RR^(|cal(V)| times d)$ 与词嵌入矩阵共享。
  - *预训练目标*：单向 LM 最大似然 $cal(L)_"PT" = -sum_i log P(w_i divides w_1, dots, w_(i-1))$。
  - *下游适配*（L6 P110–112）：取最后一层*最后一个词元*表示 $h_n^((L))$，$P(y|x) = "softmax"(W_y h_n^((L)) + b)$，$W_y in RR^(d times k)$，$k$ 为标签数；微调损失 $cal(L)^"FT" = sum_(x,y) log P(y|x)$。
  - *灾难性遗忘与混合目标*：微调数据远小于预训练语料，易遗忘通用表示 → $cal(L) = cal(L)^"FT" + lambda cal(L)^"PT"$，$lambda in [0,1]$ 调节预训练损失占比。
  - *优缺点*：因果结构天然适合逐 token 生成；但每位置看不到右侧上下文，语义整体性不足，理解任务不如 BERT。
  #src[依据：教材 6.3.2；L6 P105–112；博客《GPT》。]
])

#th("6.10", "BERT：掩码预训练语言模型", [
  - *结构*（教材 6.3.3）：encoder-only，双向多头自注意力（每位置同时看左右，故不适合生成）。
    - 输入层：WordPiece 子词分词（缓解 OOV，如 highest 切成 high 与子词 est，子词以双井号标记）；$v = v^t + v^s + v^p$ —— 词元嵌入 + 段嵌入（句 A 全 0、句 B 全 1，服务 NSP）+ *可学习*位置嵌入（非正弦函数），三者维度相同、逐元素相加；
    - 编码层：$h^((l)) = "Transformer-Block"(h^((l-1)))$，$h = h^((L)) in RR^(N times d)$；
    - 输出层：MLM 在掩码位置 $P_i = "softmax"(h_(m_i) W_t + b_0)$；分类/句对任务取 $h_[["CLS"]]$，$P = "softmax"(h_[["CLS"]] W_p + b_o)$。
  - *预训练目标*（两任务联合，交叉熵）：
    - MLM（完形填空）：随机掩 15% 子词，其中 80% 换 `[MASK]`、10% 换随机词、10% 保持不变（后两者缓解预训练/下游的 `[MASK]` 分布不一致）；$cal(L)_"MLM" = -sum_(i in cal(M)) log P(w_i divides "context")$；
    - NSP：判断 B 是否为 A 的真实下一句；正负样本 $1:1$，负样本从其他段落随机选取。
  - *规模*：BERT-BASE $L=12, H=768, A=12$，110M；BERT-LARGE $L=24, H=1024, A=16$，340M。
  - *下游适配三分*（教材 6.3.5）：单句分类 $[["CLS"]]x[["SEP"]]$、句对分类 $[["CLS"]]x^((1))[["SEP"]]x^((2))[["SEP"]]$ 均取 $h_[["CLS"]]$ + 全连接分类器；序列标注取各位置 $h_i$ + 分类器（子词对齐：全子词共享标签或仅首子词参与），可再叠 CRF。
  - *优缺点*：双向上下文、理解任务强；但生成能力弱，且 `[MASK]` 造成训练/推理不一致。
  #src[依据：教材 6.3.3/6.3.5；L6 P89–97（P98–104「深入理解 BERT」带笑脸不考）；博客《BERT》。]
])

#th("6.11", "BART：序列到序列的去噪自编码器", [
  - *定位*：「BERT 的双向编码器 + GPT 的自回归解码器」，同时满足 NLG 与 NLU。
  - *结构*：标准 Transformer encoder-decoder，两处工程改动——激活函数用 GeLU（比 ReLU 梯度更平滑）；参数初始化 $N(0, 0.02^2)$。
  - *预训练目标*：对输入加噪、解码器自回归*重建原文*（编码最后一层直接进解码器 cross-attention，与 BERT 只独立预测掩码位置不同）。五种加噪（可组合，覆盖词/句/篇三层）：
    #tablem[
      | 方式 | 操作 | 模型需学到 |
      |---|---|---|
      | 单词掩码 | 随机 token 换 `[MASK]` | 按上下文填词 |
      | 文本填充 | 连续片段换*单个* `[MASK]`，片段长度服从泊松 $lambda = 3$ | 判断长度并重建（下游最有效） |
      | 单词删除 | 随机删 token | 缺失词*及其位置* |
      | 句子排列 | 打乱句序 | 句间关系并还原 |
      | 文档旋转 | 随机选词作新开头 | 定位原文起点 |
    ]
  - *下游适配*：
    - 理解（序列分类）：输入同时送编码器与解码器，取*解码器最后时刻*隐状态（句末特殊标记处）+ 线性分类器，微调方式类似 BERT；
    - 生成（摘要/问答）：解码器自回归输出，损失为生成文本与目标文本的差异；
    - 机器翻译：输入层前加一个小型 Transformer 编码器映射到目标语言空间，*分阶段训练*（先训小编码器，再联合微调）。
  #src[依据：教材 6.3.4；L6 P120–126；博客《BART》。]
])

#section("6 · 第 7 讲：LLM 预训练与训练系统")

#th("7.1", "三阶段训练与预训练目标", [
  #tablem[
    | 阶段 | 数据 | 目标 | 作用 |
    |---|---|---|---|
    | 预训练 | 海量无标注文本 | 下一 token 预测 | 语言能力与世界知识 |
    | SFT | 指令—回答对 | 拟合目标回答 | 学会遵循指令 |
    | RLHF/DPO | 人类偏好数据 | 最大化奖励/偏好 | 更有用、更诚实、更无害 |
  ]
  - *预训练损失*：
    $
      cal(L)_"pretrain" = -sum_(t=1)^T log P(w_t divides w_1, dots, w_(t-1))
    $
  - *decoder-only*：每层带 causal mask，位置 $t$ 只能看到 $<= t$ 的 token；训练时所有位置并行计算，推理时逐 token 生成。
  - *自监督*：标签来自文本本身，不需要人工标注；下一词预测迫使模型学习语法、事实和推理模式。
  - *缩放*：固定计算预算下，参数量和数据量应同步增长；单纯放大一项收益递减。
  - *模型演进关键数字*（L7 P8–19）：GPT-1 117M；GPT-2 起用 Pre-LN、残差分支按 $1/sqrt(N)$ 缩放初始化、词表 50257（字节级 BPE）、上下文 512→1024；GPT-3 96 层 / 96 头 / 嵌入维 12288 / 长 2048，采用 Sparse Transformer（稀疏/局部自注意力）降低长序列成本；BERT-Base 预训练约 10B 词元，ChatGPT 约 500B；另有 SSM/Mamba 等非注意力架构方向。
  - *训练超参数*（L7 P42–45）：Adam 系（Adam/AdamW/Adafactor，大模型用 Adafactor 省优化器显存）；学习率 *预热（warmup）+ 衰减*（线性/余弦/平方根倒数）；GPT-3 动态批次：从 32K 词元逐步升到 3.2M。
  #src[依据：L7；博客《大模型预训练：整体框架与模型架构》。]
])

#th("7.2", "RoPE、RMSNorm 与 SwiGLU", [
  - *RoPE*：把 query/key 按位置旋转。二维情形：
    $
      R_m = mat(cos m theta, -sin m theta; sin m theta, cos m theta), quad
      tilde(q)_m = R_m q, quad tilde(k)_n = R_n k
    $
    - 旋转后点积：
      $
        tilde(q)_m^T tilde(k)_n = q^T R_(n-m) k
      $
      只依赖相对位置（相对距离），与绝对位置无关；
    - 多维时每两维一组，频率 $theta_i = 10000^(-2i/d)$。
  - *RMSNorm*（不减均值）：
    $
      "RMSNorm"(x) = x / sqrt(1/d sum_(i=1)^d x_i^2 + epsilon) dot g
    $
    - PPT 表述：与*批次归一化*相比避免了期望（均值）的计算，只保留均方根缩放，速度更快；$g$ 是可学习的逐维缩放。
  - *归一化位置*：
    - Post-Norm：$"LN"(x + "Sublayer"(x))$，原始 Transformer，深层需 warmup；
    - Pre-Norm：$x + "Sublayer"("LN"(x))$，残差通路干净，现代 LLM 默认；
    - Sandwich-Norm：子层前后都 LN。
  - *SwiGLU*：
    $
      "FFN"(x) = ("Swish"(x W_1) dot x W_3) W_2, quad "Swish"(z) = z sigma(z)
    $
    - 门控结构选择性传递信息；为控制参数量，中间维度常取 $8/3 d$ 而非 $4d$。
  #src[依据：L7；博客《大模型预训练：整体框架与模型架构》《现代 LLM 组件》。]
])

#th("7.3", "MHA、MQA、GQA 与 KV Cache", [
  - *MHA*：每个头有独立 $Q,K,V$；$H$ 个头，每头维度 $d_k = d/H$。
  - *MQA*：所有 query 头共享一组 $K,V$，KV Cache 降为 MHA 的 $1/H$。
  - *GQA*：把 $H$ 个 query 头分成 $G$ 组，每组共享一组 $K,V$，KV Cache 约为 MHA 的 $G/H$。
  - *KV Cache 大小*（每序列）：
    $
      "KV bytes" = 2 dot L dot H_"kv" dot d_"head" dot n_"tok" dot b_"bytes"
    $
    - 因子 2 是 K 和 V；$H_"kv"$ 为 KV 头数（MHA 为 $H$，MQA 为 1，GQA 为 $G$）；
    - 例：Llama2-70B（$L=80$，$H=64$，$d_"head"=128$，$n=4096$，fp16）MHA 约 $10.7$ GB/序列；GQA 取 $G=8$ 时约 $1.34$ GB。
  - *带 cache 的注意力*：
    $
      "Attn"_t = "softmax"( (q_t [K_(1:t)]^T)/sqrt(d_k) ) [V_(1:t)]
    $
    每步只算新 token 的 $q_t,k_t,v_t$ 并追加，避免重算历史。
  - *易错*：KV Cache 随 $n_"tok"$ 和并发数线性增长，长上下文时可能超过模型权重；GQA 省的是 KV 头数，不是层数。
  #src[依据：L7、L11；博客《大模型预训练：整体框架与模型架构》《推理框架与部署》。]
])

#th("7.4", "混合精度、显存与重计算", [
  - *混合精度*：前向/反向用 FP16 或 BF16，参数更新保留 FP32 主权重。
    - FP16 表示范围窄，梯度小会下溢，需要 *动态损失缩放*：先放大 loss，反向得到放大梯度，更新前再缩回；
    - BF16 指数范围与 FP32 相同，通常不需要 loss scaling。
  - *显存构成*（每参数粗略字节数）：
    #tablem[
      | 项目 | 精度 | 字节/参数 |
      |---|---|---|
      | 模型权重（计算） | FP16/BF16 | 2 |
      | 梯度 | FP16/BF16 | 2 |
      | FP32 主权重 | FP32 | 4 |
      | Adam 一阶矩 | FP32 | 4 |
      | Adam 二阶矩 | FP32 | 4 |
    ]
    合计约 16 B/参数；激活值另计，随 $B, T$ 增长。
  - *梯度累加*：把大批次拆成 micro-batch，累加梯度后统一更新：
    $
      B_"effective" = B_"micro" dot "accum" dot "DP"
    $
  - *激活重计算*：前向不保存全部激活，反向需要时重算；可省 90% 以上激活显存，代价是额外计算。
  - *FlashAttention*：分块计算注意力，避免显式存 $n times n$ 矩阵；显存从 $O(n^2)$ 降到 $O(n)$，计算仍是精确注意力。
  #src[依据：L7；博客《大模型训练系统：显存、并行与数据》。]
])

#th("7.5", "数据并行、张量并行、流水线并行与 ZeRO", [
  - *数据并行（DP）*：每卡完整模型，输入不同数据，反向 all-reduce 同步梯度；简单、吞吐高，但每卡要放下完整模型和优化器状态。
  - *张量并行（TP）*：把单层权重矩阵切到多卡；列切分/行切分，卡间 all-reduce 汇总；通信频繁，通常放节点内（NVLink）。
  - *流水线并行（PP）*：按层切段，微批次依次流过；会产生流水线气泡，增大微批次可减小气泡；通信量较小，适合节点间。
  - *ZeRO*（参数切片）：
    #tablem[
      | 阶段 | 切分内容 | 显存节省 |
      |---|---|---|
      | ZeRO-1 | 优化器状态 | 约 4 倍 |
      | ZeRO-2 | 优化器状态 + 梯度 | 约 8 倍 |
      | ZeRO-3 | 优化器状态 + 梯度 + 参数 | 随 DP 度线性 |
    ]
    - ZeRO-3 计算某层时临时收集参数，算完释放，用通信换显存。
  - *混合并行*：节点内 TP、节点间 PP、全局 DP + ZeRO；具体切分取决于集群拓扑和带宽。
  - *通信量直觉*：DP 每步同步全部梯度；TP 每层都要通信；PP 只在段边界传激活。
  #src[依据：L7；博客《大模型训练系统：显存、并行与数据》。]
])

#th("7.6", "缩放律与数据配比", [

  - *计算量*：训练一个 $N$ 参数模型、$D$ 个 token，前向+反向约
    $
      C approx 6 N D
    $
    （前向 2ND，反向 4ND）。
  - *幂律*：测试损失随参数量、数据量、计算量呈幂律下降；在固定计算预算下存在最优 $N^*, D^*$。
  - *Chinchilla 经验*：计算最优时数据量约为参数量的 20 倍（$D approx 20N$）；但推理成本高时，实际会选更小的模型、更多的数据。
  - *数据配比*：
    - 多样性：网页、书籍、百科、代码、论文、对话等；
    - 平衡性：避免单一来源主导；
    - 针对性：面向目标任务调整比例。
  - *清洗与配比*（L7 P47–48）：来源四类以上（网页、书籍、百科、代码、论文、对话，各有代表数据集如 Common Crawl、The Pile、GitHub）；配比三种定法：*按自然分布、按质量分级、按下游性能调参*；质量过滤、去重（MinHash）、标准化、人工抽检；合成数据补充，但要控制分布偏移和重复。
  - *显存实例*（L7 P40）：Llama2-70B 全量训练按约 16 B/参数估算，合计约 1152 GB——这就是必须做并行/切分的直接理由。
  #src[依据：L7；博客《大模型预训练》《大模型训练系统》。]
])

#section("7 · 第 8 讲：SFT 与参数高效微调")

#th("8.1", "SFT 损失与损失屏蔽", [
  - 指令数据 $cal(D) = {(x_i, y_i)}_(i=1)^N$，$x_i$ 指令，$y_i$ 目标回答。
  - *SFT 损失*：
    $
      cal(L)_"SFT" = -sum_(i=1)^N sum_(t=1)^(|y_i|) log P_theta (y_(i,t) divides x_i, y_(i,<t))
    $
  - *损失屏蔽*：只对回答 token 计算损失，指令 token 的标签设为 ignore；模型学“看到指令如何回答”，而不是复述指令。
  - *多轮对话*：整段对话拼成一个序列，只对助手回复的 token 计算损失；可用 packing 拼到固定长度提高效率。
  - *提示学习*（不更新参数）：
    $
      hat(z) = op("argmax")_(z in cal(Z)) P_theta (f_"fill"(x', z) divides x')
    $
    再把答案词 $hat(z)$ 映射回标签；软提示则在嵌入空间学习可训练向量。
  - *ICL vs SFT*：
    #tablem[
      | 方式 | 更新参数 | 数据 | 特点 |
      |---|---|---|---|
      | 提示工程 | 否 | 手工模板 | 灵活，依赖设计 |
      | ICL | 否 | 少量示例 | 无需训练，占上下文 |
      | SFT | 是 | 指令—回答对 | 行为稳定，需标注 |
    ]
  - *灾难性遗忘*：SFT 数据分布窄，全量微调可能损害通用能力；缓解：低学习率、少轮数、混入预训练数据、LoRA、正则、通用能力监控。
  #src[依据：L8；博客《LLM 有监督微调》。]
])

#th("8.2", "指令数据构建：LIMA 与 Self-Instruct", [
  - *LIMA*（L8 P34–37）：「Less Is More for Alignment」——65B LLaMA 基座 + *仅 1000 条*精选指令、*不做 RLHF*，证明对齐质量主要取决于数据质量而非数量（表面对齐假设）。来源：高质量问答社区（StackExchange/wikiHow）+ Super-Natural Instructions + 人工撰写；过滤规则：排名高、AI 助手风格、删过长/过短、去第一人称开头、去含链接样本。
  - *Self-Instruct*（L8 P39–50）：让模型自己造指令数据。流程：175 条人工种子任务 → 每轮随机抽 8 条（6 人工 + 2 模型自产）作 few-shot 生成新任务 → 区分*分类任务*（用 12 指令+19 示例的专用模板）与*生成任务* → 用*输入优先*（先指令后实例，适合常规任务）或*输出优先*（先实例反推指令，适合推理类）生成实例 → *ROUGE-L < 0.7* 去重过滤 + 启发式规则剔除坏样本。Alpaca 即用它对 LLaMA 自举 52K 条。
  - *开源指令集*（L8 P51）：Dolly、Stanford Alpaca、 BELLE（中文 150 万，ChatGPT 蒸馏）、Flan（2021 年 44 万任务模板化收集）等——记住「规模/语言/构建方式」三列的对应关系。
  #src[依据：L8 P31–51；博客《LLM 有监督微调》。]
])

#th("8.3", "提示、上下文学习与软提示", [
  - *硬提示*：用自然语言模板，包含角色、任务、输入、示例、输出格式、约束。
  - *软提示*：在嵌入空间学习一组连续向量，不对应真实词；通过反向传播优化。
  - *ICL*：在提示中给若干示例，让模型类比完成新样本，不更新参数；效果依赖示例质量、数量、顺序和相关性。
  - *提示学习答案搜索*：
    $
      hat(z) = op("argmax")_(z in cal(Z)) P_theta (f_"fill"(x', z) divides x')
    $
  - *软提示的代表*：Prefix Tuning 在每层 K/V 前拼接可训练前缀；P-Tuning 在输入嵌入中插入可训练 prompt。
  - *取舍*：硬提示可读、可迁移、无需训练；软提示效果更好但需要训练数据、可解释性弱、跨任务迁移差。
  #src[依据：L8；博客《提示工程》《参数高效微调》。]
])

#th("8.4", "Prefix Tuning 与 Adapter", [
  - *Prefix Tuning*：每层为 key/value 增加可训练前缀：
    $
      K' = [P_K; K], quad V' = [P_V; V]
    $
    - 前缀矩阵由小 LM 头*经线性变换生成*（不直接优化 $P$ 本身），初始化可随机或取预训练嵌入（L8 P57）；真实 token 的 query 可以关注前缀；不改变原模型参数；
    - 参数量约 $2 L d l$（$l$ 为前缀长度）；前缀占用输入长度，过长会挤占真实上下文。
  - *Adapter*：在 Transformer 子层后插入瓶颈模块：
    $
      h' = h + f(h W_"down") W_"up"
    $
    - $W_"down" in RR^(d times m)$，$W_"up" in RR^(m times d)$，$m << d$；
    - 每层参数量约 $2 d m$；残差保证初始接近恒等映射；
    - 推理延迟「略增加」（L8 P65 原话），换来性能接近全量微调。
  - *对比*（L8 P65 表）：
    #tablem[
      | 方法 | 训练参数 | 是否改结构 | 推理延迟 | 计算开销 |
      |---|---|---|---|---|
      | Prompt Tuning | 极少（\<0.1%） | 否 | 无 | 无 |
      | Prefix Tuning | 约 0.1%–3% | 否（改 K/V） | 略增 | 略增 |
      | Adapter | 约 2%–5% | 是（插模块） | 略增 | 增加 |
      | LoRA | 约 0.1%–1% | 否（可合并） | 几乎无 | 合并后无 |
    ]
  #src[依据：L8 P52–65；博客《参数高效微调：LoRA、Adapter 与 Prefix Tuning》。]
])

#th("8.5", "LoRA、AdaLoRA 与 QLoRA", [
  - *低秩假设*：权重更新量可近似为低秩矩阵：
    $
      W = W_0 + Delta W = W_0 + B A
    $
    - $W_0 in RR^(d times k)$ 冻结；$B in RR^(d times r)$，$A in RR^(r times k)$，$r << min(d,k)$。
  - *前向*：
    $
      h = W_0 x + (alpha/r) B A x
    $
    - $alpha/r$ 是缩放因子，使不同秩下更新幅度可比；
    - 初始化 $A$ 为随机高斯、$B=0$，训练开始时 $Delta W=0$。
  - *参数量*：从 $d k$ 降到 $r(d+k)$；例 $d=k=1000, r=10$：100 万 → 2 万。
  - *推理*：可把 $B A$ 合并回 $W_0$，无额外延迟；多任务只保存低秩增量。
  - *QLoRA*：
    - NF4：4-bit NormalFloat，针对正态分布权重的信息论最优 4-bit 数据类型；
    - 双重量化：对量化常数再量化，进一步压缩；
    - 分页优化器：优化器状态在显存/CPU 间分页，避免峰值溢出；
    - 效果（L8 P67）：单张 48GB 卡即可微调 65B 模型。
  - *AdaLoRA*（L8 P66）：LoRA 所有矩阵共用固定秩 $r$ 的问题——更新重要性分布并不均匀；AdaLoRA 把 $Delta W$ 参数化为 $P Lambda Q$（SVD 形式），按*奇异值重要性分数* $S_i = ||P_{:,i}|| ||Lambda_i|| ||Q_{:,i}||$ 动态分配/剪除秩预算，同等参数量下更接近最优更新。
  - *特定能力精调*（L8 P68）：长上下文扩展、推理能力、格式输出（如 JSON/表格）可通过专门构造 SFT 数据强化。
  - *超参数*：$r$ 常取 8/16/32/64；$alpha$ 常取 $r$ 或 $2r$；通常作用于 attention 的 Q/V 投影，也可扩展到所有线性层。
  #src[依据：L8；博客《参数高效微调：LoRA、Adapter 与 Prefix Tuning》。]
])

#section("8 · 第 9 讲：RLHF、PPO 与 DPO，考试不考推导")

#th("9.1", "MDP、回报与策略梯度（RLHF 的背景板）", [
  #text(fill: accent, size: 7.2pt)[注：纯 RL 推导（轨迹概率、回报梯度定理证明）不考]
  - *MDP*：$(cal(S), cal(A), P, r, gamma)$；策略 $pi(a divides s)$；轨迹 $tau = (s_0,a_0,s_1,dots)$。
  - *回报*：$G_t = sum_(k=0)^infinity gamma^k r_(t+k)$。
  - *状态价值*：$V^(pi)(s) = bb(E)_(pi)[G_t divides s_t=s]$；*动作价值*：$Q^(pi)(s,a) = bb(E)_(pi)[G_t divides s_t=s, a_t=a]$。
  - *优势*：$A^(pi)(s,a) = Q^(pi)(s,a) - V^(pi)(s)$，表示动作比平均水平好多少。
  - *策略梯度*：
    $
      nabla_theta J(theta) = bb(E)_(tau ~ pi_theta)[sum_t nabla_theta log pi_theta (a_t divides s_t) dot A_t]
    $
    - 用基线 $b(s)$ 不改变期望、只降方差（$A = R - b$）；*基线选择*：回报恒正时不减基线会让所有动作概率都被推高、分布被扭曲（L9 P7）；
    - REINFORCE 用蒙特卡洛回报估计 $A_t$，方差大。
  #src[依据：L9 P1–8；博客《RLHF 与 PPO》。]
])

#th("9.2", "RLHF 目标与奖励模型", [
  - *目标*：最大化奖励，同时约束策略不偏离参考模型：
    $
      max_(pi_theta) bb(E)_(x ~ cal(D), y ~ pi_(theta)(dot divides x))[r(x,y)]
      - beta D_"KL" (pi_theta (dot divides x), pi_"ref" (dot divides x))
    $
  - *逐 token KL 奖励*：
    $
      tilde(r)_t = -beta log (pi_theta (y_t divides x, y_(<t)))/(pi_"ref" (y_t divides x, y_(<t)))
    $
    最后一个 token 再加奖励模型的整段分数，便于 PPO 每步都有反馈。
  - *偏好数据*：$(x, y_w, y_l)$，$y_w$ 优于 $y_l$。*收集方式*（L9 P19–21）：Amazon Mechanical Turk 标注平台，标注员对同一指令的两个回答做*二选一对比评估*，*仅保留明确偏好（排除平局）*；代表数据集：SfF 19.4 万、WebGPT 1.9 万、HH-RLHF 17 万、SHP 38.5 万（Reddit 高赞回复对）。
  - *3H 原则*（L9 P2/P9）：对齐目标 = Helpful（有用，助人解决问题）、Honest（诚实，不确定时承认而非编造）、Harmless（无害，拒绝有害请求）。*有用性数据*用「模型回答 + 人改写更好版本」构造；*无害性数据*用「标注者刻意诱导模型生成有害内容 + 安全拒绝回复」构造。
  - *Bradley–Terry 奖励模型*：
    $
      P(y_w succ y_l divides x) = sigma(r_phi (x,y_w) - r_phi (x,y_l))
    $
    $
      cal(L)_"RM" = -bb(E)_((x,y_w,y_l)) log sigma(r_phi (x,y_w) - r_phi (x,y_l))
    $
  - *奖励模型结构*（L9 P22）：取预训练 LM *删去最后一个非嵌入层（词元嵌入头）*，在最后一个 Transformer 层的输出上加一个线性回归头，对*序列最后一个词元*的表示输出标量分数 $r_phi (x,y)$。
  - *KL 约束的语义*（L9 P16）：KL 约束的是*新旧策略在每个动作上的概率分布*，不是参数空间的距离；防止策略为刷奖励漂移到不可控区域。
  - *四个模型*：策略 $pi_theta$、评论 $V_psi$、奖励 $r_phi$、参考 $pi_"ref"$。
  - *奖励劫持*：策略可能利用奖励模型漏洞；KL 约束和持续人工评估是必要的；改进方向之一是*自奖励*（用模型自身生成/评估奖励信号）。
  #src[依据：L9；博客《RLHF 与 PPO：用人类偏好对齐语言模型》。]
])

#th("9.3", "GAE 与 PPO 裁剪目标", [
  - *TD 误差*：
    $
      delta_t = tilde(r)_t + gamma V_psi (s_(t+1)) - V_psi (s_t)
    $
  - *GAE*：
    $
      hat(A)_t = sum_(l=0)^(T-t) (gamma lambda)^l delta_(t+l)
    $
    - $lambda=0$：单步 TD，偏差大方差小；$lambda=1$：蒙特卡洛，方差大偏差小；$0<lambda<1$ 折中。
  - *概率比*：
    $
      rho_t (theta) = (pi_theta (y_t divides s_t))/(pi_(theta_"old") (y_t divides s_t))
    $
  - *PPO 裁剪目标*：
    $
      cal(L)_"clip"(theta) = -bb(E)_t [min(rho_t hat(A)_t, "clip"(rho_t, 1-epsilon, 1+epsilon) hat(A)_t)]
    $
    - 优势为正时提高动作概率，为负时降低；
    - 裁剪阻止 $rho_t$ 偏离 1 太远，避免一次更新把策略带崩。
  - *总损失*：
    $
      cal(L) = cal(L)_"clip" + c_1 cal(L)_V - c_2 cal(H)(pi_theta)
    $
    $
      cal(L)_V = bb(E)_t [(V_(psi)(s_t) - hat(R)_t)^2]
    $
    熵奖励鼓励探索，防止策略过早坍塌。
  - *流程*：采样轨迹 → 估计优势 → 更新策略/评论若干轮 → 重新采样；旧数据只能有限次复用。
  #src[依据：L9；博客《RLHF 与 PPO：用人类偏好对齐语言模型》。]
])

#th("9.4", "DPO：闭式解、损失与梯度", [
  - 从带 KL 约束的 RLHF 目标出发，固定 $x$ 时最优策略为
    $
      pi^*(y divides x) = 1/Z(x) pi_"ref" (y divides x) exp(r(x,y)/beta)
    $
    其中 $Z(x) = sum_y pi_"ref" (y divides x) exp(r(x,y)/beta)$。
  - 反解奖励：
    $
      r(x,y) = beta log (pi^*(y divides x))/(pi_"ref" (y divides x)) + beta log Z(x)
    $
    说明最优策略本身隐含奖励，奖励是相对参考模型的 log-ratio。
  - 代入 Bradley–Terry，$Z(x)$ 在相减时抵消：
    $
      P(y_w succ y_l divides x) = sigma( beta log (pi_theta (y_w divides x))/(pi_"ref" (y_w divides x))
      - beta log (pi_theta (y_l divides x))/(pi_"ref" (y_l divides x)) )
    $
  - *DPO 损失*：
    $
      cal(L)_"DPO" = -bb(E)_((x,y_w,y_l)) log sigma( beta log (pi_theta (y_w divides x))/(pi_"ref" (y_w divides x))
      - beta log (pi_theta (y_l divides x))/(pi_"ref" (y_l divides x)) )
    $
  - *梯度*：
    $
      nabla_theta cal(L)_"DPO" = -beta sigma(-(Delta_w - Delta_l))
      [nabla_theta log pi_theta (y_w divides x) - nabla_theta log pi_theta (y_l divides x)]
    $
    - $Delta_w, Delta_l$ 为偏好/较差回答的隐式奖励；
    - 梯度提高 $y_w$ 的似然、降低 $y_l$ 的似然；
    - 权重 $sigma(-(Delta_w-Delta_l))$：模型判断错得越离谱，梯度越大；
    - $beta$ 越大，约束越强；$beta$ 越小，越激进拟合偏好数据。
  - *PPO vs DPO*：
    #tablem[
      | 维度 | PPO + RLHF | DPO |
      |---|---|---|
      | 奖励模型 | 需要 | 不需要 |
      | 在线采样 | 需要 | 不需要 |
      | 模型数 | 策略/评论/奖励/参考 | 策略/参考 |
      | 训练形式 | 强化学习 | 二分类式监督 |
      | 稳定性 | 较低 | 较高 |
      | 约束 | 显式 KL/裁剪 | 隐式 log-ratio |
    ]
  #src[依据：L9；博客《DPO：跳过奖励模型的直接偏好优化》。]
])

#section("9 · 第 10 讲：知识图谱与知识增强，书上抄的")

#th("10.1", "知识表示：从一阶逻辑到 OWL", [
  - *经典知识表示四法*（L10 P4）：一阶谓词逻辑（形式化强、自然性差）、语义网络（节点+弧的网状表示）、产生式规则（IF-THEN，专家系统基础）、框架理论（槽-值结构表示定型对象）。
  - *语义网脉络*（L10 P5）：1989 Berners-Lee 提出 WWW；1998 提出 Semantic Web——让机器能理解网页含义，给 Web 数据加*结构化语义*，RDF/OWL 是其技术栈。
  - *RDF 三元组*：$(s, p, o)$，主语、谓语、宾语；主语/谓语通常是 URI，宾语可为 URI 或字面量。
    - 例：`(姚明, 出生地, 上海)`、`(上海, 类型, 城市)`；
    - 多个三元组构成有向标记图。
  - *RDFS*：定义类、属性及其层次：
    - `rdf:type`：个体属于类；
    - `rdfs:subClassOf`：类层次；
    - `rdfs:domain` / `rdfs:range`：属性的定义域/值域；
    - 支持传递推理，例如 $A$ `subClassOf` $B$，$B$ `subClassOf` $C$ ⇒ $A$ `subClassOf` $C$。
  - *OWL*：更强的本体语言，支持：
    - `owl:sameAs`（个体等价）、`owl:equivalentClass`（类等价）；
    - 属性特性：传递、对称、函数性、逆属性；
    - 基数约束、存在/全称限制等；
    - 推理复杂度更高，可判定性取决于片段（OWL 2 EL/QL/RL 等）。
  - *知识图谱*：$cal(G) = (cal(E), cal(R), cal(T))$，$cal(E)$ 实体、$cal(R)$ 关系、$cal(T) subset.eq cal(E) times cal(R) times cal(E)$ 三元组；常区分 schema/ontology 层与实例层。
  - *对比*：
    #tablem[
      | 语言 | 表达能力 | 主要用途 |
      |---|---|---|
      | RDF | 三元组事实 | 数据表示/交换 |
      | RDFS | 类/属性层次、domain/range | 轻量本体 |
      | OWL | 等价、约束、属性特性 | 强表达本体/推理 |
    ]
  #src[依据：L10；博客《知识图谱》。]
])

#th("10.2", "知识图谱构建与知识抽取", [
  - *构建四环节*（L10 P17，按 PPT 术语作答）：*知识定义*（schema/本体设计：实体类型、关系类型、约束，Protégé 等工具）→ *知识抽取*（实体/关系/事件/属性）→ *知识补全*（链接预测、知识推理、新实体发现、歧义消解）→ *知识存储*（三元组库/图数据库，Neo4j 属性图：节点带标签与属性、边带类型与属性，查询语言 Cypher）。另区分*领域图谱*（垂直、精度高）与*通用图谱*（Freebase/Wikidata，覆盖广）。
  - *知识抽取按来源三分*（L10 P25）：非结构化（纯文本→NER/RE/事件抽取）、半结构化（表格/HTML→模式匹配+弱监督）、结构化（数据库→ETL 转换）。
  - *实体抽取三方法*（L10 P28–30）：规则+词典（精确但迁移差）、统计模型=序列标注 HMM/CRF/MaxEnt（需标注、泛化好）、深度学习 BiLSTM-CRF 等（自动特征、少人工但需数据与算力）。
  - *远程监督关系抽取*（L10 P32–34，简答级）：Mintz et al. 2009；*基本假设*：若知识库三元组 $(e_1, r, e_2)$ 的两个实体共现于一句，则该句表达关系 $r$。做法：用知识库（Freebase）对齐语料自动造训练集 → 句级多标签分类；*缺点*：假设过强引入大量噪声（实体共现≠表达该关系）→ 需去噪/多实例学习。预测时对新实体对抽取关系。
  - *事件抽取*（L10 P35–37）：从文本中识别*事件触发词*（往往是主要动词，标明事件类型）与*事件论元*（时间、地点、参与者等，各带论元角色），构成结构化事件。*开域*（不限事件类型）vs *闭域*（预定义事件类型表，如 ACE-2005 的 8 大类 33 子类、中文 ACE 数据集）。*流水线式*：触发词检测与分类 → 论元抽取，两步可共享编码层。
  - *结构化→图谱*（L10 P38）：MySQL 转 Neo4j 四法：ETL 工具（Kettle/Spoon、Talend）、CSV + neo4j-admin import、生成 Cypher 脚本、APOC 过程（`apoc.load.jdbc`）。半结构化例：电子病历表格→按列映射实体与属性。
  - *ERNIE 的联合掩码*：
    - 文本侧掩蔽 token，知识侧掩蔽对应实体/三元组；
    - 让模型在文本与结构化知识之间建立对应，学习实体和关系的表示；
    - 目标仍是去噪/预测被掩内容，但加入知识级约束。
  - *评价*：抽取用 P/R/F1；链接用 accuracy/MRR；图谱用覆盖率、一致性、查询成功率。
  #src[依据：L10 P17–40；博客《知识图谱》《知识增强的大语言模型》。]
])

#th("10.3", "知识内化与知识外用", [
  - *知识内化*（预训练阶段）：
    - 词法知识：WordNet 同义/反义/上下位，设计词关系分类、掩盖词还原；
    - 语义知识：去掉连词，构造蕴含/因果/转折分类任务；
    - 世界知识：文本与知识图谱三元组联合掩码；
    - 优点：推理时无需检索、速度快；
    - 局限：更新成本高、事实难追溯、仍可能幻觉。
  - *知识外用*（推理阶段）：
    - 内容规划：理解意图 → 判断是否检索 → 检索候选 → 排序/去重/截断；
    - 生成：显式知识（检索文本/三元组）与隐式知识（参数）相互验证，而不是简单拼接；
    - 冲突消解：比较来源可信度、时间、证据一致性；无法确认时说明不确定性。
  - *常用方法*：RAG、CoT、ICL；RAG 负责事实新鲜度，CoT 负责多步推理，ICL 负责格式和类比。
  - *对比*：
    #tablem[
      | 维度 | 知识内化 | 知识外用 |
      |---|---|---|
      | 时机 | 预训练/继续预训练 | 推理时 |
      | 更新 | 需重训 | 更新外部库即可 |
      | 可追溯 | 弱 | 强（可引用来源） |
      | 成本 | 训练成本高 | 检索/上下文成本高 |
    ]
  #src[依据：L10；博客《知识增强的大语言模型》《RAG》。]
])

#th("10.4", "LLM 评测：体系、MMLU、AlpacaEval 与 Arena", [
  - *评价体系三层*（L10 P60–69，习题直接考）：
    - *基础能力*：自然语言理解（阅读理解）、自然语言生成（文本生成）、代码（生成/补全/翻译/修复）、逻辑推理、数学推理、长期记忆；
    - *应用能力*：指令遵循、工具使用、多智能体协作、角色扮演；
    - *安全可靠*：伦理道德（偏见、价值观）、真实可信（幻觉、事实性）、安全（有害内容、鲁棒性/越狱）。
  - *MMLU*（L10 P70–71）：57 个学科、约 15908 题、四选项多项选择；从每题学科的开发集抽 5 题作示例（5-shot），报告全部科目*平均准确率*；随机基线 $1/4 = 25%$。
  - *AlpacaEval*：成对比较，模型回答与基线回答由 GPT-4 评委比较，报告胜率：
    $
      "win rate" = W/(W + L)
    $
    平局通常单列或按 0.5 计入；*长度控制胜率*（length-controlled）用逻辑回归把「更长」的影响从胜率中剥离，防止靠灌水长度刷分；参考回复版本（text-davinci-003 / GPT-4 Preview）必须固定才可比。
  - *Chatbot Arena*：人类对匿名模型两两投票，用 Elo/Bradley–Terry 估计排名：
    $
      P(A " beats " B) = 1/(1 + 10^((R_B - R_A)/400))
    $
    - 胜者加分、败者减分，更新幅度与预期胜率有关；
    - 偏好数据多、覆盖真实用户，但成本高、可能存在位置/风格偏差。
  - *事实性与安全性*：事实性可用 EM/F1、人工核验、引用准确率；安全性看有害率、拒答率、越狱成功率。
  - *注意*：基准污染、指标饱和、评委偏差会让分数虚高；最终仍需人工评价。
  #src[依据：L10 P60–75；博客《大语言模型的评价》《NLP 评价指标》。]
])

#section("10 · 第 11 讲：推理、量化与蒸馏")

#th("11.0", "推理芯片与推理框架（L11 P5–24）", [
  - *四类芯片*：CPU（通用、串行强，推理吞吐低）、GPU（大规模并行张量核心，训练+推理主力，CUDA 生态）、TPU（Google ASIC，脉动阵列做矩阵乘，v1 2015→v4/Trillium 2024，仅 TensorFlow/JAX）、NPU/DCU（华为昇腾 910 系列、寒武纪 MLU290 等，面向端侧/集群推理）。选型三问：算力够不够、编程生态难不难、场景是训练还是推理。
  - *六个框架*：vLLM（PagedAttention + 连续批处理，吞吐标杆）、Ollama（单机易用、模型分发）、TGI（HuggingFace，Safetensors 权重 + Flash Attention + 流式生成）、TensorRT-LLM（编译优化 + In-flight Batching，NVIDIA 卡上极致性能）、DeepSpeed-MII（deepfusion 内核、自动张量切片 ATS 省显存、ZeroQuant 即时量化）、llama.cpp（GGUF 量化 1.5–8 bit，CPU+GPU 混合推理，端侧）。
  - *框架性能对比三指标*（L11 P24）：解码速度（tokens/s）、显存占用、内存占用。
  - *量化粒度边界*（L11 P32）：per-group 的 group_size 取 1 时退化为逐元素、取整通道大小时等价于逐通道——粒度越细缩放因子越多、开销越大。
  - *GPTQ 谱系*（L11 P37）：OBD→OBS→OBQ→GPTQ：逐层「量化 + 用未量化列补偿误差」的近似二阶方法一脉相承。
])

#th("11.1", "Prefill/Decode 与 KV Cache 显存", [
  - *Prefill*：整段提示并行计算，生成首个 token 和 KV Cache；矩阵乘规模大，通常算力受限。
  - *Decode*：每次生成一个 token，新 token 的 query 与历史 K/V 做注意力；每次只处理一个位置，通常显存带宽受限。
  - *指标*：
    - TTFT（Time To First Token）：请求到首 token 的延迟，主要由 Prefill 决定；
    - TPOT/ITL（每 token 时间/间隔）：Decode 阶段每 token 耗时；
    - 吞吐：每秒 token 数或请求数；与延迟经常权衡。
  - *KV Cache*：保存历史 K/V，避免每步重算；显存随 $L, H_"kv", d_"head", n_"tok", B$ 线性增长。
  - *注意力计算*：
    $
      k_t = x_t W_K, quad v_t = x_t W_V
    $
    $
      "Attn"_t = "softmax"( (q_t [K_(1:t)]^T)/sqrt(d_k) ) [V_(1:t)]
    $
  - *易错*：Prefill 是 compute-bound，Decode 是 memory-bound；优化手段不同（前者算子效率/并行，后者 KV Cache/批处理/量化）。
  #src[依据：L11；博客《大模型推理部署：KV Cache、PagedAttention 与推理框架》。]
])

#th("11.2", "PagedAttention 与连续批处理", [
  - *传统 KV Cache*：每个请求预分配连续显存，按最大长度预留 → 内部碎片；请求长度不一 → 外部碎片。
  - *PagedAttention*：把 KV Cache 切成固定大小 block，用页表把逻辑位置映射到不连续物理 block：
    - 按需分配，减少预留浪费；
    - 不同请求可共享物理 block（相同系统提示），实现前缀共享；
    - 显存利用率提高后可容纳更多并发。
  - *连续批处理*（continuous/in-flight batching）：每个 decode step 检查请求状态，完成的立即移出，新请求随时加入；避免短请求被长请求拖住。
  - *实现要点*：
    - block table 记录每个序列的逻辑块到物理块映射；
    - 引用计数支持共享前缀；写时复制（copy-on-write）保证隔离；
    - 调度器按 token 预算组批，而不是按请求数。
  - *效果*：吞吐显著提升，但单请求延迟可能受批内其他请求影响；需要平衡吞吐与尾延迟。
  #src[依据：L11；博客《大模型推理部署：KV Cache、PagedAttention 与推理框架》。]
])

#th("11.3", "量化基础：仿射映射、粒度与 QAT/PTQ", [
  - *均匀仿射量化*：
    $
      q = "clip"(round(r/S) + Z, q_"min", q_"max"), quad r approx S(q - Z)
    $
    - $r$ 浮点值，$S$ 缩放因子，$Z$ 零点，$q_"min"/q_"max"$ 为整数范围（int8：$-128$ 到 $127$）；
    - 对称量化 $Z=0$，适合权重；非对称保留零点偏移，适合偏斜的激活。
  - *缩放因子*：由校准范围决定，例如
    $
      S = (r_"max" - r_"min")/(q_"max" - q_"min"), quad
      Z = round(q_"min" - r_"min"/S)
    $
    对称时 $S = max(|r_"min"|, |r_"max"|)/q_"max"$。
  - *粒度*：
    #tablem[
      | 粒度 | 每组参数 | 特点 |
      |---|---|---|
      | Per-tensor | 整个张量一组 $S,Z$ | 简单，精度低 |
      | Per-channel | 每个通道一组 | 权重常用，精度高 |
      | Per-token | 每个 token 一组 | 激活常用 |
      | Per-group | 每 $g$ 个元素一组 | 精度/开销折中，$g$ 常取 32/64/128 |
    ]
  - *QAT*：训练时插入伪量化（前向量化、反向 STE 近似直通），让模型适应低精度；*QAF* 在微调阶段做；*PTQ* 直接量化训练好的模型，简单但可能掉点。
  - *误差来源*：截断误差、舍入误差、离群值拉伸范围；激活比权重更难量化。
  #src[依据：L11；博客《模型压缩：量化与蒸馏》。]
])

#th("11.4", "GPTQ、SmoothQuant、SpQR 与 AWQ", [
  - *LLM.int8()*：激活中存在少量大幅离群特征；对离群特征所在列保持 FP16，其余列 int8 矩阵乘，最后反量化相加：
    $
      Y = X_"outlier" W_"outlier" + "dequant"(X_"int8" W_"int8")
    $
  - *GPTQ*：逐层量化，目标
    $
      min_(hat(W)) norm(X W - X hat(W))_2^2
    $
    - 用 Hessian $H = 2 X^T X$ 估计每个权重对输出的影响；
    - 按列量化，量化后用剩余列补偿误差；可压到 3–4 bit，推理时反量化。
  - *SmoothQuant*：等效变换
    $
      Y = (X W) = (X "diag"(s)^(-1))("diag"(s) W)
    $
    - 激活除以 $s$ 缩小离群点，权重乘以 $s$ 承担难度；
    - 常用 $s_j = max(|X_j|)^alpha / max(|W_j|)^(1-alpha)$，$alpha$ 约 0.5；
    - 把“激活难量化、权重易量化”变成两者都较容易。
  - *SpQR*：识别对量化误差特别敏感的少量权重（约 top 1%），用稀疏高精度保存，其余压到 3–4 bit；敏感度可理解为“该权重被量化后对层输出的最小误差”。
  - *AWQ*：根据激活和权重大小识别关键通道，学习逐通道缩放因子保护重要通道；不单独存储离群权重，实现简单、推理高效。
  - *对比*：
    #tablem[
      | 方法 | 核心 | 精度 | 实现 |
      |---|---|---|---|
      | LLM.int8 | 离群列 FP16 | 高 | 混合精度 |
      | GPTQ | Hessian 误差补偿 | 3–4 bit 可用 | 逐层量化 |
      | SmoothQuant | 等效缩放迁移离群 | W8A8 | 需校准 |
      | SpQR | 敏感权重稀疏保留 | 近无损 | 稀疏+低位 |
      | AWQ | 激活感知保护通道 | 4 bit | 逐通道缩放 |
    ]
  #src[依据：L11；博客《模型压缩：量化与蒸馏》。]
])

#th("11.5", "知识蒸馏：温度、损失与白盒/黑盒", [
  - *软标签*：教师输出概率分布包含类别间相似性；学生同时学习真实标签和教师分布。
  - *温度 softmax*：
    $
      p_i^((tau)) = (exp(z_i/tau))/(sum_j exp(z_j/tau))
    $
    $tau > 1$ 软化分布，让学生看到“哪些错误答案也比较接近”。
  - *蒸馏损失*：
    $
      cal(L) = (1-alpha) "CE"(y, p_S) + alpha tau^2 D_"KL" (p_T^((tau)), p_S^((tau)))
    $
    - 第一项是学生损失，第二项是蒸馏损失；
    - $alpha$ 平衡真实标签与教师；$tau^2$ 补偿温度缩放导致的梯度缩小；
    - 教师损失通常只用于监控，不直接更新学生。
  - *白盒蒸馏*：可访问教师内部结构/中间层；MiniLLM 用反向 KL 让学生匹配教师分布，避免学生在教师低概率区域分配过多概率。
  - *黑盒蒸馏*：只能访问教师输入/输出；GKD 对学生生成的序列采样，用教师打分构造训练信号。
  - *能力蒸馏*：除最终答案，还可迁移推理过程（CoT）、示例使用方式（ICL）、指令遵循行为（IF）。
  - *量化 vs 蒸馏*：
    #tablem[
      | 方法 | 对象 | 是否训练 | 优点 | 局限 |
      |---|---|---|---|---|
      | 量化 | 权重/激活 | 通常否 | 降显存/带宽 | 低位掉点 |
      | 蒸馏 | 模型规模 | 是 | 小模型、低延迟 | 需教师和数据 |
    ]
  #src[依据：L11；博客《模型压缩：量化与蒸馏》。]
])

#section("11 · 第 12 讲：提示、推理、RAG 与智能体")

#th("12.1", "提示工程、APO 与 APE", [
  - *起源*：「Prompt 一词进入 NLP」约 2020 年（Brown GPT-3 / Schütz 术语），先驱为 2021 年《Exploiting Cloze Questions》（EACL，提出 PromptTuning）；提示工程 = 在不改参数的前提下设计输入以激发模型能力。
  - *提示组成*：角色/背景、任务指令、输入数据、示例、输出格式、约束。
  - *离散型 vs 连续型提示*（PPT 术语）：
    - 离散型：自然语言模板/词元序列，可读、可迁移、需手工调试；
    - 连续型：嵌入空间可训练向量（P-Tuning 为典型代表），需训练数据、可解释性弱。
  - *ICL*：提供示例让模型类比，不更新参数；效果依赖示例质量、数量、顺序、相关性。
  - *APO（Automatic Prompt Optimization，含 Beam Search 变体 APO-B\*/贝叶斯搜索）*：从初始提示迭代：
    1. 用当前提示生成输出；
    2. 与标准答案比较，得到误差/失败原因；
    3. 让大模型根据失败原因改写提示（「自然语言梯度」）；
    4. 验证集评估，保留更好版本（beam 保留 top-k）。
    - 局限：容易局限在初始提示邻域（局部最优）。
  - *APE（Automatic Prompt Engineer）三阶段*：Inference——让 LLM 根据输入输出示例*生成*候选指令；Scoring——验证集打分保留 top-K；Resampling——以高分候选为父本重采样/改写再评分。探索广但生成与评估成本高。
  - *对比*：
    #tablem[
      | 方法 | 搜索方式 | 优点 | 局限 |
      |---|---|---|---|
      | 手工 | 人工试错 | 灵活可解释 | 难规模化 |
      | APO | 初始提示迭代改写 | 有误差反馈 | 易局部最优 |
      | APE | 生成候选+打分+重采样 | 探索广 | 成本高 |
    ]
  #src[依据：L12.1；博客《提示工程：从手工模板到自动优化》。]
])

#th("12.2", "CoT、自一致性、ToT 与 GoT", [
  - *CoT*：让模型写出中间推理步骤，再给答案。
    - few-shot CoT：示例中包含推理链；
    - zero-shot CoT：在提示后加“Let's think step by step”；
    - *Auto-CoT*：无需人工示例——对问题集合做聚类 → 每类取距中心最近的 $K$ 个问题 → 用 zero-shot CoT 生成推理链作为示例 → 拼入 few-shot 提示；兼顾多样性与准确性。
    - 作用：把多步计算外显，降低一次性推理难度。*搜索视角*：CoT 是单链*贪心搜索*。
  - *自一致性*（Self-Consistency）：采样多条推理路径，对最终答案投票：
    $
      hat(y) = op("argmax")_y sum_(r in cal(R)) bb(1)["answer"(r) = y]
    $
    - 用答案边缘化代替单条路径；多数投票是近似；
    - 采样温度较高以增加多样性，成本随采样数线性增长。
  - *ToT*（Tree of Thoughts）：把问题建模为树搜索：
    - 状态：部分解/思路；
    - 动作：生成下一步想法；
    - 评估器：给状态打分或投票；
    - 搜索：BFS/DFS + 剪枝，可回退；*搜索视角*：ToT ≈ 束搜索（每步保留 $K$ 个候选思路）；
    - 适合需要探索和回溯的规划问题，成本高于 CoT。
  - *GoT*（Graph of Thoughts）：把想法组织成*图*——节点是思路，边表示依赖/聚合/改进；一个节点可有*多个父节点*（合并/精炼多个分支结果），允许环状复用；表达力强于树，但调度和评估更复杂。
  - *测试时计算*：增加采样数、搜索深度、验证器调用次数，通常能提升难题表现，但收益递减、成本上升。
  #src[依据：L12；博客《CoT、ToT 与 GoT》。]
])

#th("12.3", "RAG：BM25、稠密检索与评价", [
  - *三阶段架构演进*（L12.2 P8–20）：
    - *Naive RAG*：索引→检索→生成；四大局限：检索精度有限、上下文窗口塞不下、生成幻觉、质量难评估；
    - *Advanced RAG*：检索前（查询改写/扩展、路由）+ 检索后（重排、压缩、过滤）；
    - *Modular RAG*：把流程抽象为可换模块——搜索、路由、融合、记忆、预测（先猜后检，如 Generate-Then-Read）、任务适配（如 UPRISE 选示例）、迭代/递归检索（Iter-RetGen）。
  - *流程*：文档切块（chunk 常取 128/256/512 token，滑动窗口重叠切分；粒度影响召回与噪声）→ 向量化/建索引 → 检索 top-k → 重排 → 拼上下文生成。
  - *BM25*：
    $
      "score"(D,Q) = sum_(q in Q) "IDF"(q) dot (f(q,D)(k_1+1))/(f(q,D) + k_1(1 - b + b (|D|) /"avgdl"))
    $
    $
      "IDF"(q) = ln( (N - n(q) + 0.5)/(n(q) + 0.5) + 1 )
    $
    - $f(q,D)$ 词频，$|D|$ 文档长度，$"avgdl"$ 平均长度；
    - $k_1$ 控制词频饱和，$b$ 控制长度归一化（常取 $k_1=1.2$–$2.0$，$b=0.75$）。
  - *稀疏 vs 稠密*：稀疏（TF-IDF/BM25）有「语义鸿沟」（同义词不匹配）与高维稀疏存储问题；稠密检索用编码器把查询/文档压成低维向量，余弦/内积匹配，ANN 加速（KD-tree、LSH、HNSW、IVF）。*混合检索*：分数加权或 RRF 融合，兼顾关键词与语义；检索器可用 LSR（最小化检索失败案例）微调。
  - *查询改写*：HyDE 先生成假设答案再检索；多查询扩展、指代消解、分解子问题；LLMLingua 等提示压缩缓解「长上下文稀释」（模型对超长上下文*首尾关注多、中间关注少*）。
  - *RAG 三优势*（PPT）：*灵活*（随时更新知识库不重训）、*安全*（私有数据可控、可权限化）、*可解释*（可引用来源、可追溯）。
  - *进阶方向*：元数据过滤、图结构检索（GraphRAG）、迭代/递归/自适应检索（Self-RAG 让模型自判是否检索）；*多模态 RAG*：把图像/音频经 OCR/转写*转成文本*再入库，或用跨模态编码器做*模态表示*对齐；*Agentic RAG*：单智能体自主决定检索时机/工具、多智能体分工、分层编排。
  - *RAG 评价*：
    - 检索：Recall\@k、MRR、nDCG；
    - 生成：faithfulness（是否忠于上下文）、answer relevance、context precision/recall；
    - 端到端：人工/LLM-as-judge 正确性、引用准确率。
  - *失败模式*：检索不到、上下文噪声、长上下文稀释、模型忽略证据、错误拼接。
  #src[依据：L12.2《检索增强 RAG》；博客《RAG》。]
])

#th("12.4", "Agent：组成与 ReAct 循环", [
  - *组成*：
    - profile：角色、目标、约束；
    - memory：短期对话记忆 + 长期向量库/数据库；
    - planning：任务分解、计划、反思；
    - action：工具调用、代码执行、检索、API。
  - *ReAct 循环*：
    1. Thought：分析当前状态、决定下一步；
    2. Action：选择工具和参数；
    3. Observation：读取工具返回；
    4. 重复直到给出答案或达到步数上限。
  - *工具 schema*：名称、描述、参数 JSON Schema、返回值格式；描述质量直接影响工具选择。
  - *反思*（Reflection）：执行后评估结果，失败则修正计划；可配合重试、回退、人工确认。
  - *多智能体*：分工（规划者/执行者/评审者）或辩论；优点是并行与专精，缺点是通信成本、错误传播、协调复杂。
  - *评价*：任务成功率、步骤数、工具调用准确率、成本、延迟；安全上要限制危险工具、沙箱执行、权限最小化。
  #src[依据：L12；博客《基于大语言模型的智能体》。]
])

#section("12 · 绪论、教材应用篇与课程实验，应该不考")

#th("12.1", "绪论：概念、任务与发展脉络（L1）", [
  - *语言的定义与性质*（L1 P12）：语言是人类最重要的交际工具（符号系统），具有*符号性、系统性、生成性、动态性*；自然语言处理 = 让计算机理解并生成自然语言。
  - *语言学分支*（P16–20）：语音学/音系学（语音层面）、 morphology 词法与 syntax 句法（语法层面）、semantics 语义、pragmatics 语用。
  - *NLP 五个处理层面*（P26）：字/词元 → 词法 → 句法 → 语义 → 语用，各层对应典型任务（分词/POS → 短语结构/依存 → WSD/SRL/消歧 → 篇章/推理）。
  - *五大挑战*（P27–30）：歧义（词义/句义/结构）、常识与世界知识、语言多样性（多语言/低资源）、数据噪声与一词多义动态性、跨模态与推理。
  - *数据集四类型*（P33–38）：通用语料（WikiText——语言建模）、领域语料、对话语料（SQuAD——阅读理解、MultiWOZ——对话）、平行语料（WMT——机器翻译）；GLUE/SuperGLUE 为综合任务套件。记「数据集 ↔ 任务」配对。
  - *发展四阶段*（P73–87）：*规则方法*（1940s–60s，乔姆斯基形式语言、PSG/LFG，ELIZA）→ *统计方法*（1990s，HMM/最大熵/SVM/朴素贝叶斯，语料库兴起）→ *深度学习*（2010s，词嵌入 W2V/GloVe 静态 → ELMo/BERT 动态；CNN/RNN/Transformer）→ *大模型时代*（2018–，GPT 单向自回归生成、BERT 双向 MLM+NSP 偏理解；预训练+微调范式）。
  - *三范式对比*（P83）：规则（可解释性强、覆盖差）、统计（数据驱动、需标注）、深度学习（自动特征、可解释性弱、算力依赖）。
  - *典型应用*：机器翻译三代（SMT→NMT→大模型）、信息检索（TF-IDF→语义/BERT 排序）、问答（IBM Watson 2011 战胜 Jeopardy 人类冠军）、对话（Character.AI 等）。
  - *展望五点*（P90）：统一模型、多模态、更深推理、知识与可信、具身/代理。
  #src[依据：L1 课件；教材第 1 章。]
])

#th("12.2", "教材第 13 章：文本分类与情感分析", [
  - *分类流程*：预处理（分词/去停用词）→ 特征工程 → 分类器 → 评估。文档用向量空间模型（VSM）/词袋表示：$vec(d) = (w_1, dots, w_n)$，$"tfidf"_(t,d) = "tf" times log(N/"df")$；缺点：稀疏、忽略词序与语义。
  - *降维两路*：特征*提取*（LSA/PLSA/LDA，映射到低维语义空间）vs 特征*选择*（保留原词、按评估函数挑子集）：互信息 MI、信息增益 IG、卡方统计量 $chi^2$、文档频率 DF。
  - *贝叶斯路线*：$P(c divides d) = P(c)product_w P(w divides c)/P(d)$（两假设：条件独立、词序无关）；生成式（朴素贝叶斯）vs 判别式（感知机/最大熵/SVM，都是线性模型族）。
  - *深度模型*：文本 CNN ≈ 多窗口 n-gram 特征 + max-pooling；RNN 取最后隐状态分类；Bi-LSTM 双向拼接。
  - *情感分析四概念*：情感倾向（正/负）、情感强度、情感词典、情感特征。*词级词典法五步*：找情感词→按程度副词（如「非常」×2）与否定词（翻转极性）修正→统计总分→比较正负词和→判定极性；词典来源：人工（NTUSD、HowNet）vs 自动构建（种子词+聚类/互信息扩展）。
  - *句级/篇级*：本质是分类/回归，但需处理否定、转折、比较等语义组合；*ABSA（基于方面的情感分析）四子任务*：方面词抽取 ATE、方面类别检测 ACD、观点词抽取 OTE、情感分类 ASC——流水线解法用 BIO 序列标注、TD-LSTM（目标-上下文双 LSTM）、GCN（句法图卷积）、约束注意力。
  - *聚类*：距离度量（欧氏/余弦/曼哈顿）+ K-means（选 $k$、初始化敏感）。
  #src[依据：教材第 13 章；实验一。]
])

#th("12.4", "三次课程实验考点", [
  - *实验一 · 文本分类与情感分析*：MARC 中文电商评论二分类（1–2 星→负、4–5 星→正，3 星弃用）。两条路线：① 词频/TF-IDF + 经典分类器（NB/LR/SVM/集成）——考点：特征工程、`max_df/min_df/ngram` 调参、*训练/验证/测试三分*（验证集选模型，测试只报一次）；② 预训练模型 UER-RoBERTa-Medium 微调——考点：*tokenizer 必须与模型配套*、[CLS] 表示 + 分类头、学习率要小。指标：Accuracy、*Macro-F1*、P/R。
  - *实验二 · Transformer 神经机器翻译*：WMT 英→中约 25 万句对，*BPE 32000 子词*（动机：缓解 OOV、平衡词表与序列长）；流程：清洗对齐→训练（teacher forcing）→*beam search* 解码→*sacreBLEU/mosesdetokenize 后算 BLEU*（先还原再匹配）。考点：影响翻译质量的因素（数据规模与领域、BPE 粒度、束宽、模型容量）、BLEU 各 n 的含义。
  - *实验三 · 对话大模型微调*：Qwen2-7B-Instruct + *LoRA*（r、alpha、target=attention 投影；可训练参数约 0.53% \<1%）在 DISC-Med-SFT 医疗指令数据上 SFT；流程：数据转单轮问答→训练→*LoRA 权重合并导出*→推理服务。评价：Chinese-medical-dialogue 测试集 ROUGE-1/2/L（*中文需 jieba 分词后算*）+ CMMLU 医学选择题正确率。考点：SFT 损失屏蔽（只对回答算损失）、领域能力提升 vs *通用能力回退（灾难性遗忘）*的权衡、LoRA 合并后零推理开销。
])

#section("13 · 推导模板与高频易错点")

#th("13.1", "高频易错点清单", [
  - *log 底*：熵/交叉熵用 bit 还是 nat；PPL 用 $2^(dot)$ 还是 $exp(dot)$。
  - *PPL 可比性*：不同 tokenizer、词表、是否含句首句尾符号，PPL 不可直接比较。
  - *BLEU*：截断精确率是“候选计数截断到参考最大计数”，不是普通 precision；BP 用最接近候选长度的参考长度；语料级与句级不同。
  - *宏/微平均*：宏平均类别等权，微平均样本等权；多分类 F1 的宏平均有两种定义（先平均 P/R 再调和 vs 直接平均 F1）。
  - *PCFG/CYK*：$max$ 用于最优树，$sum$ 用于句子概率（inside）；CYK 要求 Chomsky 范式或二元化。
  - *注意力*：缩放因子是 $sqrt(d_k)$ 不是 $d_k$；mask 要在 softmax 前置 $-infinity$。
  - *LoRA*：参数量是 $r(d+k)$ 不是 $r d k$；缩放是 $alpha/r$；初始化 $B=0$ 保证初始恒等。
  - *DPO*：$beta$ 越大约束越强；梯度权重取决于隐式奖励差；参考模型不能省。
  - *RLHF*：KL 是策略相对参考模型，不是奖励模型损失；逐 token KL 与整段 KL 的实现不同。
  - *量化*：对称量化 $Z=0$；非对称才有 zero point；per-group 的 $g$ 越小越精细但缩放因子更多。
  - *KV Cache*：因子 2（K 和 V）；GQA 省的是 KV 头数；长上下文/高并发时 KV 可能超过权重。
  - *蒸馏*：教师和学生都要用同一温度；$tau^2$ 不能漏；软标签不是 one-hot。
  - *RAG*：BM25 有长度归一化；Recall\@k 的分母是相关文档数；上下文越长不一定越好。
  - *评测*：MMLU 随机基线是 $1/"选项数"$；Arena 是成对偏好，不是绝对打分。
  - *感知机更新式*：仅当预测错时更新，$w <- w + eta (y - hat(y)) x$；$hat(y) eq y$ 时不动，别写成对每个样本都加 $eta y x$。
  - *GloVe 记号*：PPT P27 的负号与下标顺序系排版问题；规范式是加权最小二乘 $f(C_(i j)) (u_i^T v_j + b_i + c_j - log C_(i j))^2$，且约定 $v$=中心词、$u$=上下文词、$e_i = u_i + v_i$。
  - *分词歧义*：交集型（“研究生命”中“研究生/究生命”交叠）与组合型（“乒乓球拍卖完了”）不要混；BMES 与 BIOES 是两套标记集，别混用。
  - *BPE*：编码时从长到短匹配规则；还原词元靠 `</w>` 边界符。
  - *RMSNorm*：PPT 对比的对象是批次归一化（BatchNorm），不是 LayerNorm；RMSNorm 省去均值与偏移项。
  - *指令微调数字*：LIMA 是 1000 条精标数据 + 65B 模型；Self-Instruct 用 175 条种子、每批 8 条（6 生成 + 2 种子）、ROUGE-L < 0.7 去重——别把两者数据量互换。
  - *偏好数据*：成对二选一、平局样本要排除；RM 打分取最后一个 token 的标量输出。
])



#th("13.2", "核心公式清单", [
  - *熵与 KL*：$H(p) = -sum_x p(x) log p(x)$，$D_"KL"(p, q) = sum_x p(x) log (p(x)\/q(x)) >= 0$。
  - *交叉熵与 PPL*：$H(p,q) = -sum_x p(x) log q(x)$，$"PPL" = exp(-1/N sum_i ln P(w_i divides w_(<i)))$。
  - *n-gram MLE*：$P(w_i divides w_(i-n+1)^(i-1)) = C(w_(i-n+1)^i) \/ C(w_(i-n+1)^(i-1))$。
  - *加 k 平滑*：$P_"add-k" (w divides h) = (C(h w) + k) \/ (C(h) + k V)$。
  - *BLEU*：$"BLEU" = "BP" dot exp(sum_(n=1)^N w_n ln p_n)$。
  - *注意力*：$"Attn"(Q,K,V) = "softmax"(Q K^top \/ sqrt(d_k) + M) V$。
  - *蒸馏*：$cal(L) = (1-alpha)"CE"(y,p_S) + alpha tau^2 D_"KL" (p_T^((tau)), p_S^((tau)))$。
  - *LoRA*：$W = W_0 + (alpha\/r) B A$，参数量 $r(d+k)$。
  - *PPO*：$cal(L)^"clip" = bb(E)[min(rho A, "clip"(rho, 1-epsilon, 1+epsilon) A)]$。
  - *DPO*：$hat(r)_(theta)(x,y) = beta log (pi_theta (y divides x) \/ pi_"ref" (y divides x))$，$cal(L) = -log sigma(hat(r)(x,y_w) - hat(r)(x,y_l))$。
  - *量化*：$q = "clip"(round(r\/S) + Z, q_min, q_max)$，$S = (r_max - r_min) \/ (q_max - q_min)$。
  - *KV Cache 显存*：$2 dot L dot n_"kv" dot d_"head" dot n_"ctx" dot "bytes"$。
  #src[用途：进场前快速过一遍；每个公式的符号含义、推导与易错点见对应小节。]
])
