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

#let qa(id, title, body) = block(
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
  title: "自然语言处理 · 课后习题 QA 速查",
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
    #text(weight: "bold", fill: accent, size: 9pt)[考前速记]
    #v(2pt)
    - 语言模型：$"PPL" = 2^(H(p,q)) = exp(-1/N sum_(i=1)^N ln P(w_i mid w_(<i)))$；均匀预测时 $"PPL" approx V$。
    - n-gram 的零概率靠平滑解决：加一/加 k、Good-Turing、插值/回退、Kneser-Ney。
    - Sigmoid/Tanh 会饱和；ReLU 缓解梯度消失但可能 Dead；分类优先交叉熵，梯度是 $hat(y)-y$。
    - LSTM 三门：遗忘 $f_t$、输入 $i_t$、输出 $o_t$；GRU 两门：更新 $z_t$、重置 $r_t$。
    - 自注意力用点积：矩阵乘友好、无额外参数；$1/sqrt(d_k)$ 缩放防止 softmax 饱和。
    - Skip-gram 图题：4 个上下文共享分母，最少 $100$ 次点积；独立算则 $4 times 100 = 400$。
    - Prompt/ICL 不更新参数；SFT 更新。全量微调效果最好但贵；LoRA/QLoRA 适合多任务/小显存。
    - PPO：奖励模型 + 在线采样 + 4 个模型；DPO：偏好对 + 离线 + 2 个模型。
    - RLHF 的 KL 是“别偏离参考模型太远”，防 reward hacking；PPO 另有新旧策略的 KL/裁剪。
    - 知识内化：预训练联合掩码；知识外用：RAG/知识图谱检索。选择题选“知识图谱 + 融合学习机制”。
  ]
)

#v(3pt)
#text(size: 6.6pt, fill: luma(85))[
  说明：第 1、5、7、11、12 讲课件末尾无课后习题；本表覆盖第 2、3、4、6、8、9、10 讲，共 39 题。答案以课件主线为准，博客文章用于展开；页码为 PDF 页码。
]

#section[第 2 讲 · 基础理论（L2 P55–56）]

#qa("2.1", "困惑度的意义及其与交叉熵的关系", [
  #text(style: "italic", fill: luma(75))[题目：简述困惑度的意义以及它与交叉熵的关系。]
  *答：*
  - *意义*：困惑度衡量语言模型对测试序列的“平均不确定性”，可理解为每一步平均在多少个等概率候选词中犹豫；越低越好。
  - *定义*：$"PPL"(W) = P(W)^(-1/N) = exp(-1/N sum_(i=1)^N ln P(w_i mid w_(<i)))$。
  - *与交叉熵*：测试集上的平均负对数似然就是交叉熵 $H(p,q)$，所以 $"PPL" = 2^(H(p,q))$（以 2 为底）或 $e^(H(p,q))$（以 $e$ 为底）。
  - *分解*：$H(p,q) = H(p) + D_"KL"(p,q)$，因此 $"PPL" = 2^(H(p)) dot 2^(D_"KL")$；真实熵 $H(p)$ 是下界，KL 是模型相对真实分布多付出的代价。
  - *直觉*：词表大小为 $V$ 且预测均匀时，$"PPL" approx V$；完美预测时 $"PPL" = 1$。
  - *注意*：PPL 只在相同词表、分词方式和测试集下可比；不同 tokenizer 的 PPL 不能直接比较。
  #src[依据：L2 P55；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]；#link("https://biscuit0613.github.io/posts/dl-basics/perplexity/")[《困惑度》]。]
])

#qa("2.2", "PPL 趋近词表大小：可能的问题与改进", [
  #text(style: "italic", fill: luma(75))[题目：如果语言模型的困惑度逐渐趋近词汇表大小，结合预测概率分布推测发生了什么问题？如何改进？]
  *答：*
  - *含义*：预测分布接近均匀分布，模型几乎没有学到比词频更强的上下文信息；若 PPL 停在 $V$ 附近不下降，通常不是好模型。
  - *可能原因*：
    - 欠拟合：训练不足、学习率/初始化不当、模型容量太小、数据少或噪声大；
    - 过度平滑：加一平滑过强、插值权重偏向 unigram、回退失效，把概率抹平；
    - 数据/评估问题：测试集与训练领域不匹配、OOV 多、分词/词表不一致、句子过短；
    - 训练故障：logits 坍缩、死神经元、损失屏蔽/标签错位、数值问题。
  - *诊断*：
    - 对比训练/验证 PPL 与 unigram 基线；
    - 看 top-k 预测是否集中、预测熵是否接近 $log V$；
    - 统计 OOV 率、句长、领域差异；
    - 检查 loss 曲线、梯度、激活值和标签对齐。
  - *改进*：
    - 增强模型/数据：更多高质量数据、领域适配、更强结构（RNN/Transformer）；
    - 调整平滑：减小加一强度，改用 KN/插值/回退并调权重；
    - 处理 OOV：子词、字符级、BPE；
    - 优化训练：学习率、正则、归一化、初始化、batch size；
    - 统一评估：固定分词/测试集，报告 bits/token。
  #src[依据：L2 P55；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]。]
])

#qa("2.3", "计算英语字母与汉字的熵", [
  #text(style: "italic", fill: luma(75))[题目：收集尽量多的英语和汉语文本，编写程序计算英语字母和汉字的熵。]
  *答：*
  - *步骤*：
    1. 语料：英文取新闻/书籍/网页等多领域文本；中文取多领域语料；统一编码、去重、清洗。
    2. 规范化：英文统一大小写；明确是否保留空格/标点；中文明确是否保留标点、是否区分简繁。
    3. 统计频数：$c_i$ 为符号 $i$ 的出现次数，$p_i = c_i \/ sum_j c_j$。
    4. 一元熵：$H_1 = -sum_i p_i log_2 p_i$，单位 bit/symbol。
    5. 条件熵（可选）：统计 bigram/trigram，计算 $H(X_t mid X_(t-1))$ 或更高阶，观察上下文带来的下降。
    6. 报告：同时给出语料规模、符号集、是否含空格/标点，否则数值不可比。
  - *参考量级*（只作 sanity check，不要死记）：
    - 英文 26 字母一元熵约 4.1–4.2 bit/字母；含空格略低；考虑上下文后可降到约 1–2 bit/字母（Shannon 的估计）。
    - 汉字一元熵常见约 9–10 bit/汉字，依赖字表和语料；条件熵明显更低。
  - *实现要点*：对数以 2 为底；未见符号做平滑或并入 `<unk>`；大语料用哈希计数；留出数据估计偏差；对比不同语料。
  - *解释*：汉字单字信息量大但每词字数少；按字母和按汉字直接比较会受单位影响，最好再按词/句比较。
  ```text
  for token in corpus: count[token] += 1
  H = -sum((c/N) * log2(c/N) for c in count.values())
  ```
  #src[依据：L2 P55；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]；Shannon (1951)；Jurafsky & Martin 第 3 章。]
])

#qa("2.4", "设计并实现句子相似性算法", [
  #text(style: "italic", fill: luma(75))[题目：根据本章内容设计并实现一种算法，计算任意两个句子之间的相似性。]
  *答：*
  - *先定义相似*：字面重叠、语义相近、任务相关（检索/聚类/判重）不同，方法也不同。
  - *方案 A：TF-IDF + 余弦（快速基线）*
    - 预处理：分句、分词、去停用词、归一化；
    - 表示：$"tfidf"(t,d) = "tf"(t,d) dot log(N\/"df"(t))$；
    - 打分：$cos(x,y) = (x dot y)\/(norm(x) norm(y))$。
    - 优点：简单、可解释、无需训练；缺点：忽略词序/语义，OOV 敏感。
  - *方案 B：字面匹配*：Jaccard 词集合、字符 n-gram Jaccard、编辑距离/LCS；适合短文本/拼写差异。
  - *方案 C：语义向量*：词向量平均后余弦；或 Sentence-BERT/SimCSE 句向量后余弦；跨语言用多语言模型。
  - *方案 D：交叉编码器*：把两句拼接送入 BERT 分类/回归，或 LLM 打分；准确但慢，适合精排。
  - *方案 E：检索系统*：BM25/双塔向量召回，再用 cross-encoder 精排。
  - *实现步骤*：
    1. 预处理（分词、归一化、去噪）；
    2. 选择表示（稀疏/稠密/交叉编码）；
    3. 打分（余弦/点积/分类概率）；
    4. 用人工标注对校准阈值（PR/ROC）；
    5. 评估（Spearman 相关、Accuracy/F1、Recall\@k）。
  - *例子*：“猫坐在垫子上”与“垫子上有一只猫”：词重叠低但语义高；TF-IDF 分数低，句向量分数高。
  - *注意*：否定、语序、长度、领域、多语言；线上还要考虑延迟和成本。
  #src[依据：L2 P56；博客 #link("https://biscuit0613.github.io/posts/nlp/05-02-embedding-evaluation/")[《词向量的评价》]、#link("https://biscuit0613.github.io/posts/nlp/03-04-classic-tasks/")[《经典 NLP 任务》]、#link("https://biscuit0613.github.io/posts/nlp/12-03-rag/")[《RAG》]。]
])

#qa("2.5", "NLP 中常见机器学习任务及其区别", [
  #text(style: "italic", fill: luma(75))[题目：简述 NLP 任务中常见的机器学习任务有哪些？它们之间有什么区别？]
  *答：*
  - *有监督学习*：
    - 回归：输出连续值（质量分、相似度分），损失 MSE/MAE，指标 MSE/MAE/相关系数。
    - 分类：输出离散类别（情感、主题、意图、NLI），损失交叉熵，指标 Accuracy/F1/AUC。
    - 结构化预测：输出带依赖结构的对象：
      - 序列标注（分词/POS/NER）：每个 token 一个标签；
      - 序列生成（MT/摘要/对话）：输出 token 序列；
      - 树/图预测（句法分析、SRL、共指）：输出树、图或跨度。
  - *无监督学习*：聚类、主题模型、降维、密度估计、词向量；无标签，发现数据结构。
  - *自监督学习*：从数据自身构造标签（next token、MLM、对比学习），是预训练的主流。
  - *强化学习*：智能体与环境交互，优化延迟奖励；对话策略、RLHF、Agent。
  - *区别维度*：
    - 标签类型：连续/离散/结构/无标签/奖励；
    - 输出空间：固定类别 vs 指数级序列/结构；
    - 损失与评价：MSE/CE/序列级指标/累积奖励；
    - 数据依赖：结构化预测要建模输出间依赖；RL 要探索和信用分配。
  - *关系*：分类是结构化预测的特例；序列生成可看作自回归分类；自监督常作预训练，再接监督任务。
  #src[依据：L2 P56；博客 #link("https://biscuit0613.github.io/posts/nlp/03-04-classic-tasks/")[《经典 NLP 任务》]、#link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]、#link("https://biscuit0613.github.io/posts/nlp/07-01-llm-architecture/")[《大模型预训练》]。]
])

#section[第 3 讲 · 统计建模与经典技术（L3 P143）]

#qa("3.1", "n-gram 模型：优缺点、长文本与稀疏挑战", [
  #text(style: "italic", fill: luma(75))[题目：解释 n-gram 模型，讨论优缺点；处理长文本和稀疏性问题时面临哪些挑战？有哪些改进方法？]
  *答：*
  - *定义*：用马尔可夫假设把历史截断到最近 $n-1$ 个词：
    $P(w_i mid w_1 dots w_(i-1)) approx P(w_i mid w_(i-n+1) dots w_(i-1))$；
    序列概率为各条件概率之积，参数用 MLE 计数比估计。
  - *优点*：简单、可解释、训练/推理快；局部语序建模强；数据充分时是强基线。
  - *缺点*：
    - 固定窗口，无法建模长距离依赖和篇章结构；
    - 参数量/存储随 $n$ 指数增长（约 $V^(n-1)$）；
    - 数据稀疏：未见 n-gram 概率为 0；
    - 离散符号，无法利用词义相似性；
    - 对领域、分词、大小写敏感。
  - *长文本挑战*：$n$ 固定导致跨句/跨段信息丢失；主题、指代、逻辑关系难捕捉；直接增大 $n$ 又加剧稀疏和存储。
  - *改进*：
    - 平滑：加一/加 k、Good-Turing、Katz 回退、插值、Kneser-Ney；
    - 结构：变阶/跳过 n-gram、缓存/触发模型、类/聚类 n-gram、主题模型；
    - 表示：NNLM/RNNLM/Transformer，参数共享缓解稀疏并建模长程；
    - 工程：子词、数据清洗/增强、领域适配、剪枝/分布式存储。
  - *一句话*：n-gram 用“局部独立”换数据效率；平滑和神经模型分别从统计与表示两侧补短板。
  #src[依据：L3 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]。]
])

#qa("3.2", "平滑技术：问题、方法和工作原理", [
  #text(style: "italic", fill: luma(75))[题目：平滑技术为了解决什么问题？列举几种常见平滑方法并解释工作原理；为什么平滑技术对提高语言模型性能重要？]
  *答：*
  - *问题*：MLE 对训练集未出现的 n-gram 给 0 概率；测试句只要含一个未见 n-gram，整句概率为 0、PPL 无穷；模型过拟合训练计数，缺乏泛化。
  - *目标*：从高频事件“借”概率质量给未见/低频事件，保证所有事件正概率且总和为 1。
  - *常见方法*：
    - 加一/加 k（Laplace）：$P = (c+k)\/(N+k V)$；简单，但大词表上过度平滑。
    - Good-Turing：用 $N_(r+1)\/N_r$ 调整计数；理论优雅，稀疏时 $N_r$ 不稳定。
    - 插值：$P = lambda_3 P_3 + lambda_2 P_2 + lambda_1 P_1$；权重可固定或用 EM 学习。
    - 回退（Katz）：高阶为 0 时退到低阶，并用折扣因子保证归一化。
    - 绝对折扣/Kneser-Ney：每个计数减 $D$，低阶用接续计数；实践中效果最好。
    - Witten-Bell/Dirichlet：按“见到的不同上下文数”分配概率质量。
  - *为什么重要*：
    - 避免零概率和无穷 PPL，使模型能处理未见事件；
    - 改善泛化/校准，提升 ASR、MT、拼写纠错等下游任务；
    - 平衡偏差-方差：平滑太弱→过拟合，太强→欠拟合（PPL 趋近 $V$）。
  - *例子*：bigram“喜欢 苹果”未出现，加一后仍有正概率；KN 会用“苹果”出现在多少种上下文中估计低阶概率。
  #src[依据：L3 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]。]
])

#qa("3.3", "句法分析的类型与区别", [
  #text(style: "italic", fill: luma(75))[题目：句法分析方法有哪些类型？它们之间有什么区别？]
  *答：*
  - *短语结构分析（constituency）*：
    - 输出短语结构树：节点是 S/NP/VP 等非终结符，叶子是词/词性；
    - 文法：CFG/PCFG；算法：CYK、Chart、转移式；
    - 可分为完全句法分析与局部句法分析（shallow/chunking）。
  - *依存句法分析（dependency）*：
    - 输出词与词的支配关系（head→dependent）及关系标签；
    - 方法：规则、转移式（arc-standard/eager）、图式（MST）、神经网络；
    - 不要求短语节点，结构紧凑，适合自由语序和信息抽取。
  - *按方法分*：
    - 规则：可解释，但覆盖有限、维护成本高；
    - 统计：PCFG、HMM/CRF、转移分类器，数据驱动；
    - 神经：BiLSTM/Transformer，精度高但依赖数据/算力。
  - *区别*：
    #tablem[
      | 维度 | 短语结构 | 依存 |
      |---|---|---|
      | 输出 | 短语树 | 依存弧/标签 |
      | 节点 | 词 + 短语 | 词 |
      | 约束 | 文法产生式 | 单根、投射性等 |
      | 评价 | PARSEVAL/括号 F1 | UAS/LAS |
      | 应用 | 语法分析/教学 | IE/QA/知识图谱 |
    ]
  - *注意*：语义角色标注不是句法分析，而是浅层语义分析，常以句法树/依存为特征。
  #src[依据：L3 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-03-syntax-semantics/")[《句法分析与语义角色标注》]。]
])

#qa("3.4", "统计 NLP 的典型应用与解决方式", [
  #text(style: "italic", fill: luma(75))[题目：统计 NLP 技术有哪些典型应用场景？讨论统计方法如何解决特定问题。]
  *答：*
  - *典型应用*：
    - 文本分类：垃圾邮件、情感、主题、意图；
    - 信息检索与排序；
    - 机器翻译、语音识别；
    - 分词、POS、NER、句法分析；
    - 拼写纠错/输入法；
    - 语言模型、摘要、对话。
  - *通用套路*：
    1. 把任务写成概率模型或决策问题；
    2. 从标注/未标注语料估计参数；
    3. 设计特征（词、n-gram、词典、句法）并选模型（NB、LR、SVM、HMM、CRF、PCFG、IBM 模型）；
    4. 用概率/分数处理歧义，做最大后验或最大似然决策；
    5. 用交叉验证和任务指标评估。
  - *具体例子*：
    - 垃圾邮件：$P("spam" mid x) prop P("spam") product P(w mid "spam")$（朴素贝叶斯）。
    - NER：HMM/CRF 建模标签转移和发射特征，Viterbi 解码。
    - 拼写纠错：噪声信道 $P(c mid t) prop P(t mid c) P(c)$，语言模型提供 $P(c)$。
    - 机器翻译：噪声信道/对数线性模型 $P(y mid x) prop P(x mid y) P(y)$；短语/神经 MT。
    - 句法分析：PCFG 为产生式赋概率，选最大概率树。
  - *优势*：数据驱动、能处理不确定性/歧义、可扩展；*局限*：特征工程、数据稀疏、长距离依赖；神经方法用表示学习缓解。
  #src[依据：L3 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-04-classic-tasks/")[《经典 NLP 任务》]、#link("https://biscuit0613.github.io/posts/nlp/03-03-syntax-semantics/")[《句法分析与语义角色标注》]、#link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]。]
])

#section[第 4 讲 · 深度学习基础（L4 P148）]

#qa("4.1", "人工神经元的生物学灵感与未体现的特性", [
  #text(style: "italic", fill: luma(75))[题目：人工神经元如何从生物神经元汲取灵感？除了输入-权重-输出模式，还有哪些生物特性尚未充分体现？未来如何融合？]
  *答：*
  - *灵感映射*：
    - 树突接收信号 → 输入 $x_i$；
    - 突触强度 → 权重 $w_i$；
    - 胞体整合 → 加权和 $sum_i w_i x_i + b$；
    - 阈值/发放 → 激活函数 $f$；
    - 突触可塑性/学习 → 权重更新（感知机/反向传播）。
  - *尚未充分体现的特性*：
    - 脉冲与时间编码：生物用 spike 的时间/频率传递信息；ANN 多为连续激活、同步计算，缺少精确时序和不应期。
    - 突触可塑性：STDP（前后脉冲时序决定增强/减弱）、短/长时程可塑性、神经调质；BP 是全局误差驱动，不是局部时序规则。
    - 兴奋/抑制平衡：生物有兴奋性和抑制性突触（Dale 法则）、抑制性中间神经元；ANN 权重可正可负，但没有显式 E/I 种群和平衡约束。
    - 树突计算：树突分支可做非线性整合/局部计算；点神经元模型忽略。
    - 结构可塑性：生长、修剪、稀疏连接；ANN 结构多为固定稠密。
    - 能量与异步：事件驱动、低功耗、稳态调节、胶质细胞调控。
  - *未来融合*：
    - 脉冲神经网络（SNN）+ 代理梯度/ANN2SNN；
    - 神经形态硬件（Loihi、SpiNNaker）做事件驱动低功耗；
    - 局部学习规则（Hebbian、STDP、feedback alignment）补充/替代 BP；
    - E/I 平衡网络、树突神经元模型、结构可塑性/稀疏训练；
    - 把生物约束作为归纳偏置（时序、稀疏、模块化）提升鲁棒性和能效。
  - *注意*：不必完全仿生；目标是借鉴有用的计算原理，而非复刻每个生物细节。
  #src[依据：L4 P148；课件 P6–14；外部 #link("https://biscuit0613.github.io/posts/cnn/cnn/")[《CNN》]、#link("https://biscuit0613.github.io/posts/rnn/rnn-basic/")[《RNN 基础》] 笔记。]
])

#qa("4.2", "常见激活函数的优缺点与选择", [
  #text(style: "italic", fill: luma(75))[题目：列举常见激活函数（ReLU、Sigmoid、Tanh），分析优缺点；如何根据具体问题选择？激活函数如何影响训练效率和最终性能？]
  *答：*
  - *Sigmoid*：$sigma(z) = 1\/(1+e^(-z))$；输出 $(0,1)$，可解释为概率；缺点：饱和导致梯度消失、非零中心、exp 计算；适合二分类输出层/门控。
  - *Tanh*：输出 $(-1,1)$，零中心，梯度比 sigmoid 强；仍会饱和/梯度消失；适合浅层网络和 RNN 隐藏单元。
  - *ReLU*：$max(0,z)$；计算快、正区间不饱和、稀疏；缺点：Dead ReLU、非零中心、无上界；适合深层 CNN/MLP；变体有 LeakyReLU/PReLU/ELU/GELU/SiLU。
  - *如何选择*：
    - 输出层：回归→linear；二分类→sigmoid；多分类→softmax；
    - 隐藏层：默认 ReLU/GELU；深层网络优先 ReLU 家族；
    - RNN/LSTM：tanh + sigmoid 门；
    - 小数据/小网络：tanh/sigmoid 也可，需调初始化；
    - 最终用验证集比较，并结合归一化和学习率。
  - *对训练和性能的影响*：
    - 非线性决定表达能力；没有激活等价于线性模型；
    - 导数性质影响梯度消失/爆炸、收敛速度和死亡神经元；
    - 输出范围和零中心影响优化条件；
    - 饱和会减慢学习；ReLU 稀疏可能提升效率，但可能死神经元。
  #tablem[
    | 函数 | 输出 | 优点 | 缺点 |
    |---|---|---|---|
    | Sigmoid | $(0,1)$ | 概率解释、平滑 | 饱和、非零中心、计算贵 |
    | Tanh | $(-1,1)$ | 零中心、梯度较强 | 仍饱和/梯度消失 |
    | ReLU | $[0,infinity)$ | 快、缓解梯度消失 | Dead ReLU、非零中心 |
  ]
  #src[依据：L4 P148；课件 P31–40；外部 #link("https://biscuit0613.github.io/posts/cnn/cnn/")[《CNN》] 笔记。]
])

#qa("4.3", "分类为什么用交叉熵而不是平方损失", [
  #text(style: "italic", fill: luma(75))[题目：分析为什么分类问题常采用交叉熵损失而不是平方损失。]
  *答：*
  - *概率解释*：分类标签是离散分布；交叉熵是负对数似然，最小化 CE 等价于最大似然；MSE 对应高斯噪声回归，不适合离散标签。
  - *梯度更有效*：
    - sigmoid/softmax + CE：$partial L \/ partial z = hat(y)-y$，误差直接、尺度合适；
    - sigmoid + MSE：梯度含 $sigma'(z)$，饱和时接近 0，学得慢；且非凸。
  - *惩罚性质*：CE 对“自信且错误”的惩罚趋于无穷，促使模型校准；MSE 有界，惩罚较弱。
  - *优化性质*：线性 logits + softmax 的 CE 是凸的；MSE + sigmoid 非凸，容易陷入平台/局部。
  - *度量含义*：CE 衡量概率分布差异（KL），MSE 衡量数值距离；分类更关心概率分布。
  - *例外*：回归/连续标签用 MSE/MAE；标签噪声大时可考虑 label smoothing、focal loss 或 MAE 变体。
  - *一句话*：交叉熵是“为概率分布而生”，MSE 是“为数值回归而生”。
  #src[依据：L4 P148；课件 P39–40；博客 #link("https://biscuit0613.github.io/posts/nlp/05-01-evaluation-metrics/")[《NLP 评价指标》]；#link("https://biscuit0613.github.io/posts/dl-basics/kldivergenceandcrossentropy/")[《KL 散度与交叉熵》]。]
])

#qa("4.4", "RNN 的优势、梯度问题与 LSTM/GRU 门控", [
  #text(style: "italic", fill: luma(75))[题目：RNN 相比前馈网络处理序列数据的主要优势？梯度消失/爆炸如何产生？LSTM/GRU 如何通过门控机制解决？还有其他优化思路吗？]
  *答：*
  - *RNN 的优势*：
    - 处理变长序列，参数跨时间共享；
    - 隐藏状态携带历史，捕捉顺序和长距离依赖；
    - 相比固定窗口 MLP/n-gram，参数量不随历史长度指数增长；
    - 可用于语言模型、序列标注、seq2seq、语音等。
  - *梯度消失/爆炸*：
    - BPTT 沿时间连乘 Jacobian $partial h_t \/ partial h_(t-1)$ 和激活导数；
    - 谱半径 < 1 或饱和激活 → 梯度指数衰减（消失）；> 1 → 指数放大（爆炸）；
    - 长依赖难以学习；爆炸可用梯度裁剪，消失需结构改进。
  - *LSTM*：
    - 细胞状态 $C_t$ 作为“高速公路”；
    - 遗忘门 $f_t = sigma(W_f [h_(t-1), x_t] + b_f)$ 控制保留旧信息；
    - 输入门 $i_t$ 控制写入候选 $tilde(C)_t$；
    - 输出门 $o_t$ 控制暴露的 $h_t$；
    - $C_t = f_t dot C_(t-1) + i_t dot tilde(C)_t$，$h_t = o_t dot tanh(C_t)$；
    - 加法更新 + 门控缓解梯度消失，能学习较长依赖。
  - *GRU*：
    - 更新门 $z_t$、重置门 $r_t$；
    - $h_t = (1-z_t) dot h_(t-1) + z_t dot tilde(h)_t$；
    - 参数更少、训练更快，效果常与 LSTM 相当。
  - *其他思路*：
    - 梯度裁剪（爆炸）、正交/单位初始化、残差/层归一化；
    - 截断 BPTT + 状态传递、课程学习；
    - 注意力/Transformer 提供直接长程路径；
    - 膨胀/Clockwork RNN、记忆网络、Neural ODE、SSM/Mamba。
  - *注意*：门控缓解但不彻底消除消失；极长依赖仍可能丢失。
  #src[依据：L4 P148；课件 P91 起；外部 #link("https://biscuit0613.github.io/posts/rnn/rnn-basic/")[《RNN 基础》]、#link("https://biscuit0613.github.io/posts/rnn/rnn-gru-lstm/")[《GRU 与 LSTM》]、#link("https://biscuit0613.github.io/posts/rnn/rnn-bptt/")[《BPTT》] 笔记。]
])

#qa("4.5", "自注意力为何用点积而非加性打分", [
  #text(style: "italic", fill: luma(75))[题目：分析为什么 Transformer 自注意力选择点积模型而不是加性模型。]
  *答：*
  - *点积*：$s(q,k) = q dot k$；可用矩阵乘法/GEMM，GPU 并行效率高；无额外参数，计算和显存开销小；$d_k$ 大时点积方差大，需要缩放。
  - *加性*：$s(q,k) = v^T tanh(W_q q + W_k k)$；引入可学习参数和非线性，表达更灵活；但计算更慢、参数更多、显存更大。
  - *选择理由*：
    - 效率：点积是硬件友好的批量矩阵乘，适合大规模并行训练；
    - 效果：合理缩放后，点积与加性在多数任务上效果相当，而点积更简单；
    - 缩放点积：$s = q dot k \/ sqrt(d_k)$，保持方差稳定，避免 softmax 饱和和梯度消失。
  - *加性适用*：维度不匹配、分布复杂、小数据或跨模态；Bahdanau attention 常用加性。
  - *结论*：不是“点积绝对更准”，而是在 Transformer 的大规模并行场景下，点积的性价比最高；缩放是关键修正。
  #src[依据：L4 P148；课件 P116–117；博客 #link("https://biscuit0613.github.io/posts/transformer/trasformer-attetion/")[《自注意力》]；Vaswani et al. (2017)。]
])

#section[第 6 讲 · 词向量与神经语言模型（L6 P142–145）]

#qa("6.1", "分布式假设及其对文本分布式表示的意义", [
  #text(style: "italic", fill: luma(75))[题目：请描述分布式假设及其对于文本分布式表示的意义。]
  *答：*
  - *定义*：出现在相似上下文中的词，往往具有相似语义；词义可以由其上下文分布推断（“You shall know a word by the company it keeps”）。
  - *意义*：
    - 为分布式表示提供理论基础：无需人工定义语义，从语料统计/预测中学习；
    - 把词映射为稠密低维向量，可用余弦/距离度量相似性；
    - 具有泛化能力：相似上下文→相似向量，未见组合也能获得合理表示；
    - 支撑 Word2Vec、GloVe、ELMo、BERT 等预训练模型；
    - 能捕捉语义/句法规律（如类比关系）。
  - *实现方式*：共现矩阵/PMI/SVD（计数派）或上下文预测（Word2Vec/GloVe/神经 LM）。
  - *局限*：静态向量无法区分多义词；窗口/语料带来偏差；可能继承社会偏见；需上下文模型改进。
  #src[依据：L6 P142；博客 #link("https://biscuit0613.github.io/posts/nlp/06-01-word-representation/")[《词向量基础》]、#link("https://biscuit0613.github.io/posts/nlp/06-02-word2vec/")[《Word2Vec》]。]
])

#qa("6.2", "Word2Vec 两种模型的核心思想", [
  #text(style: "italic", fill: luma(75))[题目：请简述 Word2vec 两种模型的核心思想。]
  *答：*
  - *共同点*：把词向量学习转化为上下文预测；用浅层网络/embedding lookup，训练完成后嵌入矩阵就是词向量；输出层用 softmax 或负采样/层次 softmax。
  - *Skip-gram*：给定中心词 $w_t$，预测窗口内上下文 $w_(t+j)$：
    $max sum_t sum_(j in [-m,m], j != 0) log P(w_(t+j) mid w_t)$。
    - 每个上下文单独预测；对稀有词更友好；训练较慢。
  - *CBOW*：给定窗口内上下文，预测中心词：
    $max sum_t log P(w_t mid w_(t-m) dots w_(t-1), w_(t+1) dots w_(t+m))$。
    - 上下文向量平均后预测一个词；训练更快；稀有词信息易被稀释。
  - *效率*：全词表 softmax 的 $O(V)$ 开销用负采样 $O(k)$ 或层次 softmax $O(log V)$ 降低。
  - *产物*：输入嵌入矩阵的列（或输入/输出矩阵平均）作为最终词向量；静态、与上下文无关。
  #src[依据：L6 P142；博客 #link("https://biscuit0613.github.io/posts/nlp/06-02-word2vec/")[《Word2Vec》]；Mikolov et al. (2013)。]
])

#qa("6.3", "缓解未登录词（OOV）的方法", [
  #text(style: "italic", fill: luma(75))[题目：在学习单词表示时，有哪些方法可以缓解未登录词的问题？]
  *答：*
  - *子词分词*：BPE、WordPiece、SentencePiece、字节级 BPE；把词拆成子词，未登录词也能由已知子词组成；字节级不存在 OOV。
  - *字符 n-gram*：fastText 用字符 n-gram 向量之和表示词，能处理形态变化和拼写错误。
  - *字符级/混合模型*：字符级 RNN/CNN，或 word+char 混合输入。
  - *词表策略*：增大词表、降低 min count、加入领域词/拼写变体；权衡序列长度和嵌入参数量。
  - *形态处理*：词干化/词形还原、形态分析，适合形态丰富的语言。
  - *上下文/生成策略*：上下文模型通过子词组合表示；生成任务可用 copy/pointer 机制复制原文词。
  - *相似词回退*：用编辑距离/词向量最近邻找替代；未知词映射到 `<unk>` 并利用上下文。
  - *评估*：统计 OOV 率、子词覆盖率、序列长度和下游效果，避免只用词表覆盖率。
  #src[依据：L6 P142；博客 #link("https://biscuit0613.github.io/posts/nlp/06-04-subword-tokenization/")[《子词分词》]、#link("https://biscuit0613.github.io/posts/nlp/06-02-word2vec/")[《Word2Vec》]；Sennrich et al. (2016)；Bojanowski et al. (2017)。]
])

#qa("6.4", "如何评价词向量模型的优劣", [
  #text(style: "italic", fill: luma(75))[题目：怎么评价词向量模型的优劣？]
  *答：*
  - *内在评价（intrinsic）*：直接在向量空间测试语言知识。
    - 相似度：余弦相似度与人工相似度比较，用 Spearman 相关；数据集 WordSim-353、MEN、SimLex-999。
    - 类比：3CosAdd/3CosMul，如 king−man+woman≈queen；Google analogy 集。
    - 聚类/分类：词义聚类、最近邻定性检查。
    - 优点：快、便宜、可解释；缺点：与下游效果不一定一致。
  - *外在评价（extrinsic）*：把词向量用于 NER、POS、文本分类、句法分析、MT 等下游任务，比较最终指标。
    - 优点：贴近实际；缺点：成本高，受下游模型/数据/超参影响。
  - *其他标准*：语料领域/规模、维度、词表覆盖/OOV、训练稳定性（多种子）、偏见/公平性、计算/存储成本、与 tokenizer 的对齐。
  - *实践*：先用内在评价快速筛选，再用外在评价做最终选型；多数据集、多任务，报告基线。
  - *注意*：相似≠相关（car/road）；高频词/hubness 影响最近邻；类比只覆盖少量关系；静态向量无法处理多义词。
  #src[依据：L6 P142；博客 #link("https://biscuit0613.github.io/posts/nlp/05-02-embedding-evaluation/")[《词向量的评价》]。]
])

#qa("6.5", "语言模型的目标", [
  #text(style: "italic", fill: luma(75))[题目：请描述语言模型的目标。]
  *答：*
  - *核心目标*：对语言符号序列的概率分布建模，即估计联合概率 $P(w_1, w_2, dots, w_m)$。
  - *链式分解*：$P(w_1 dots w_m) = product_(i=1)^m P(w_i mid w_1 dots w_(i-1))$，所以核心是估计“给定历史的下一个词概率”。
  - *训练目标*：在语料上最大化对数似然，等价于最小化交叉熵/困惑度；标签就是下一个词，属于自监督学习。
  - *用途*：给句子打分/排序、生成文本、消歧、纠错、ASR/MT 重打分、检索。
  - *评价*：内在用 PPL；外在看下游任务（MT、ASR、生成质量）。
  - *注意*：PPL 需同词表/分词可比；语言模型不等于“事实数据库”，事实性需额外知识/检索。
  #src[依据：L6 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]。]
])

#qa("6.6", "语言模型建模相比句子/篇章分布式表示的优势", [
  #text(style: "italic", fill: luma(75))[题目：相比文本（句子或篇章）的分布式表示，利用语言模型对其建模的主要优点是什么？]
  *答：*
  - *句子/篇章向量*：通常把整段压成一个固定向量，丢失词序、句法、细节和不确定性；需要设计池化/编码器，可能依赖任务标注；难以生成或给序列打分。
  - *语言模型*：
    - 按 token 分解联合概率，保留顺序和组合性；
    - 可处理变长输入，给任意序列打分/排序；
    - 可采样生成，支持开放式任务；
    - 自监督训练，数据易得；
    - 隐藏状态可导出上下文表示，兼顾 token 级和句子级信息；
    - 可计算 PPL 做内在评价，并迁移到多种下游任务。
  - *表达不确定性*：LM 输出概率分布，对歧义、纠错、ASR/MT 重打分有用；句子向量通常只给相似度。
  - *代价*：计算/存储更大，训练更难；句子向量更轻量，适合检索/聚类。
  - *结论*：需要生成、打分、细粒度理解时用 LM；只需固定表示/快速检索时句子向量更经济。
  #src[依据：L6 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]、#link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]。]
])

#qa("6.7", "联合概率能否直接计算？为什么？如何缓解？", [
  #text(style: "italic", fill: luma(75))[题目：给定词序列 $w_1 w_2 dots w_m$，语言模型旨在建模联合概率 $P(w_1 dots w_m)$，能不能直接计算？如果不能，为什么？有什么方法缓解吗？]
  *答：*
  - *不能直接计算*：
    - 直接统计需要枚举所有长度为 $m$ 的序列，共 $V^m$ 种；参数/存储指数爆炸；
    - 绝大多数序列在语料中从未出现，计数为 0；
    - 链式法则虽然精确，但需要估计任意长历史 $P(w_i mid w_(<i))$，同样无法从有限语料可靠估计。
  - *本质问题*：数据稀疏 + 参数空间指数增长 + 长尾分布。
  - *缓解方法*：
    - 马尔可夫假设/n-gram：截断历史；
    - 平滑/回退/插值：给未见事件正概率；
    - 参数共享/神经 LM：NNLM/RNNLM/Transformer 用分布式表示和共享参数泛化；
    - 层次/类别模型：class-based LM、层次 softmax；
    - 子词/字符级建模：减少 OOV；
    - 数据增强/领域适配/检索增强：补充上下文。
  - *权衡*：独立性假设越强，数据效率越高但表达能力越弱；神经模型用表示学习缓解这一矛盾。
  #src[依据：L6 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[《统计语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]。]
])

#qa("6.8", "循环神经网络语言模型的优点", [
  #text(style: "italic", fill: luma(75))[题目：请简述循环神经网络语言模型的优点。]
  *答：*
  - *不限制历史长度*：隐藏状态递推汇总历史，不需要固定 $n$ 的窗口。
  - *参数共享*：所有时间步共享同一组参数，参数量不随序列长度增长。
  - *长距离依赖*：理论上可携带任意远的历史信息，能建模跨句/跨段依赖（受梯度问题限制）。
  - *变长输入/输出*：适合语言模型、序列标注、seq2seq 和生成。
  - *联合学习词向量*：嵌入矩阵随 LM 训练更新，得到任务相关的词表示。
  - *自监督*：直接用原始文本训练，不需要人工标注。
  - *相比 n-gram*：分布式表示缓解稀疏，参数不随阶数指数增长。
  - *局限*：串行计算难并行、梯度消失/爆炸、固定容量瓶颈；LSTM/GRU/Transformer 改进。
  #src[依据：L6 P143；博客 #link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[《NNLM 与 RNNLM》]。]
])

#qa("6.9", "预训练语言模型的类型与优缺点", [
  #text(style: "italic", fill: luma(75))[题目：有哪几类预训练语言模型？它们的优缺点是什么？]
  *答：*
  - *自回归/decoder-only（GPT）*：单向因果注意力，目标是 next token；生成强、结构简单、易扩展；但看不到右侧上下文，理解类任务较弱。
  - *自编码/encoder-only（BERT）*：双向注意力，目标是 MLM（+NSP）；双向理解强，适合分类、抽取、抽取式 QA；不能直接生成，且 `[MASK]` 造成预训练-微调不一致。
  - *编码器-解码器（BART/T5）*：编码器双向、解码器因果；去噪/span corruption；理解+生成兼顾，适合翻译/摘要/seq2seq；参数和计算更大，解码串行。
  - *前缀 LM/混合（UniLM、GLM 等）*：前缀双向、后缀因果；灵活兼顾理解与生成；实现/训练更复杂，非主流。
  - *选择*：生成/对话→decoder-only；分类/抽取→encoder-only；翻译/摘要/seq2seq→encoder-decoder；统一 text-to-text→T5。
  - *趋势*：现代大模型多采用 decoder-only，因为规模扩展和生成统一；BERT 仍是理解类强基线。
  #tablem[
    | 类型（代表） | 结构/目标 | 优点 | 局限 |
    |---|---|---|---|
    | 自回归（GPT） | 单向因果 / next token | 生成强、易扩展 | 无双向上下文 |
    | 自编码（BERT） | 双向 / MLM+NSP | 理解强、分类抽取好 | 不能直接生成 |
    | 编码器-解码器（BART/T5） | 双向编码+因果解码 / 去噪 | 理解生成兼顾 | 更重、解码串行 |
  ]
  #src[依据：L6 P144；博客 #link("https://biscuit0613.github.io/posts/nlp/06-07-bert/")[《BERT》]、#link("https://biscuit0613.github.io/posts/nlp/06-08-gpt-bart-t5/")[《GPT、BART 与 T5》]、#link("https://biscuit0613.github.io/posts/nlp/06-06-elmo/")[《ELMo》]。]
])

#qa("6.10", "BERT 的训练过程", [
  #text(style: "italic", fill: luma(75))[题目：请简述 BERT 模型的训练过程。]
  *答：*
  - *输入表示*：WordPiece 分词；序列 `[CLS] A [SEP] B [SEP]`；token 嵌入 + segment 嵌入 + position 嵌入；最大长度 512。
  - *预训练任务 1：MLM*：
    - 随机选 15% token 作为预测目标；
    - 被选 token 中 80% 替换为 `[MASK]`、10% 替换为随机词、10% 保持不变；
    - 用双向上下文预测原词；只对被选位置计算交叉熵。
  - *预训练任务 2：NSP*：
    - 构造句子对：50% 相邻（IsNext），50% 随机（NotNext）；
    - 用 `[CLS]` 表示做二分类。
  - *总损失*：MLM + NSP；在大规模无标注语料上训练；AdamW、warmup、较大 batch。
  - *下游微调*：加任务头（分类/序列标注/抽取式 QA），端到端更新所有参数；不同任务共享编码器。
  - *后续改进*：RoBERTa 去掉 NSP、动态掩码、更大 batch/数据；ALBERT 参数共享；ELECTRA 改为替换检测。
  - *区分*：BERT 的微调是任务特定微调，不等同于大模型的指令 SFT。
  #src[依据：L6 P144；博客 #link("https://biscuit0613.github.io/posts/nlp/06-07-bert/")[《BERT》]、#link("https://biscuit0613.github.io/posts/nlp/06-09-bert-finetune/")[《BERT 微调实践》]；Devlin et al. (2019)。]
])

#qa("6.11", "Skip-gram 点积次数计算", [
  #text(style: "italic", fill: luma(75))[题目：词表 100 个词，窗口大小 2（左右各 2 个上下文词）。计算图中所有条件概率最少需要多少次向量点积？最耗时的操作是什么？如何解决？展示计算过程。访问词嵌入不计计算。]
  *答：*
  - *图中结构*：中心词“回答”，上下文为“我/稍后/这个/问题”，共 4 个条件概率 $P(c mid "回答")$。
  - *标准 softmax*：$P(c mid w) = "exp"(u_c dot v_w) \/ sum_(w' in cal(V)) "exp"(u_(w') dot v_w)$。
  - *关键观察*：4 个条件概率共享同一个中心词，因此分母（全词表得分）只需算一次。
  - *最少次数*：对 100 个词各算一次 $u_(w') dot v_"回答"$，共 *100 次点积*；4 个分子已包含在这 100 个得分中，不需要额外点积。
  - *对比*：若每个条件概率独立计算、不共享分母，则 $4 times 100 = 400$ 次；这是朴素实现，不是“最少”。
  - *最耗时*：全词表 softmax 归一化（100 次点积 + exp/sum；真实 $V = 10^5–10^6$ 时每步 $O(V d)$），以及梯度更新所有输出向量。
  - *解决*：
    - 层次 softmax：Huffman 树，$O(log V)$ 次二分类；$V=100$ 约 7 层，4 个上下文约 28 次（取决于路径）。
    - 负采样：每个正样本采 $k$ 个负例，$O(k)$；4 个上下文 $times (1+k)$，$k=5$ 时 24 次。
    - 高频词下采样、自适应 softmax、NCE。
  - *计算示例*：$V=100, d=300$ → $100 times 300 = 30,000$ 次乘加/中心词；朴素 $4 times$ 为 120,000；负采样 $k=5$ 为 $4 times 6 times 300 = 7,200$。
  #align(center, canvas({
    import draw: *
    let node(pos, body, fill: white) = content(
      pos,
      text(size: 6.5pt)[#body],
      frame: "rect",
      padding: (x: 3pt, y: 2pt),
      radius: 2pt,
      fill: fill,
      stroke: 0.5pt + rgb("#5b7fa6"),
    )
    node((0, 0), [回答], fill: rgb("#dbe8f7"))
    node((-2.6, 1.2), [我])
    node((-0.9, 1.2), [稍后])
    node((0.9, 1.2), [这个])
    node((2.6, 1.2), [问题])
    for p in ((-2.6, 1.2), (-0.9, 1.2), (0.9, 1.2), (2.6, 1.2)) {
      line((0, 0.25), (p.at(0), p.at(1) - 0.25), mark: (end: "stealth"), stroke: 0.5pt + rgb("#5b7fa6"))
    }
  }))
  #tablem[
    | 方式 | 点积次数 | 说明 |
    |---|---|---|
    | 逐条件独立 | $4 times 100 = 400$ | 每个上下文单独 softmax |
    | 共享分母（最少） | $100$ | 一次算完全词表得分 |
    | 负采样 $k=5$ | $4 times 6 = 24$ | 每对 1 正 + 5 负 |
    | 层次 softmax | 约 $4 times 7 = 28$ | Huffman 路径 |
  ]
  #src[依据：L6 P144–145；博客 #link("https://biscuit0613.github.io/posts/nlp/06-02-word2vec/")[《Word2Vec》]；Mikolov et al. (2013)。]
])

#section[第 8 讲 · 有监督微调（L8 P69–76）]

#qa("8.1", "SFT 与提示学习、上下文学习的关系", [
  #text(style: "italic", fill: luma(75))[题目：简述有监督精调（SFT）与提示学习（Prompt Learning）、上下文学习（In-context Learning）的关系。它们之间有何相似点和不同点？]
  *答：*
  - *共同点*：都不从头训练模型，而是利用预训练语言模型的知识完成特定任务；都可用少量数据/示例适配。
  - *Prompt Learning*：设计提示模板（或软提示），改变输入表达来引导模型；通常不更新参数；灵活但依赖人工设计/调试。
  - *ICL*：在提示中给若干“输入—输出”示例，让模型类比完成新样本；不更新参数；效果依赖示例质量/数量/顺序，受上下文长度限制。
  - *SFT*：用指令—回答标注数据做梯度更新，把任务模式写入参数；行为更稳定，但需要数据/算力。
  - *关系*：Prompt Learning 是更广义的“输入设计”；ICL 是其中用示例的一种；SFT 可看作把“提示+示例”的效果内化到参数。
  - *区别*：
    #tablem[
      | 方式 | 更新参数 | 输入形式 | 特点 |
      |---|---|---|---|
      | Prompt Learning | 否（硬提示）/可训练软提示 | 模板/提示 | 灵活、依赖设计 |
      | ICL | 否 | 示例对 | 无需训练、占上下文 |
      | SFT | 是 | 指令—回答 | 稳定、需要标注 |
    ]
  #src[依据：L8 P69、P71；博客 #link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[《LLM 有监督微调》]、#link("https://biscuit0613.github.io/posts/nlp/12-01-prompt-engineering/")[《提示工程》]。]
])

#qa("8.2", "为什么预训练后还需要 SFT；数据质量的重要性", [
  #text(style: "italic", fill: luma(75))[题目：为什么经过预训练的大语言模型需要通过有监督精调来提升其遵循指令的能力？微调过程中数据质量的重要性体现在哪些方面？]
  *答：*
  - *为什么需要 SFT*：
    - 预训练只学 next-token，模型可能续写/补全而不是“回答指令”；
    - 缺乏任务格式、角色、拒答/不确定性表达；
    - SFT 用指令—回答对激活/整理已有能力，教会“何时回答、按什么格式回答”；
    - 在对齐人类偏好之前，先让模型可用、可控。
  - *数据质量的重要性*：
    - 正确性：错误答案会被模仿，放大幻觉；
    - 一致性：风格/格式统一，避免冲突；
    - 多样性：覆盖任务/领域/长度/难度，避免过拟合；
    - 覆盖面：真实用户分布、长尾、边界/拒答；
    - 标注质量：低质量/噪声/重复会损害泛化；
    - 难度/去重/配比：防止模式坍缩和灾难性遗忘。
  - *结论*：SFT 数据的“质”常比“量”更重要；少量高质量、多样化数据可显著提升指令遵循（LIMA）。
  #src[依据：L8 P69、P72；博客 #link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[《LLM 有监督微调》]；Zhou et al. (2023) LIMA。]
])

#qa("8.3", "SFT 数据集如何保证多样性、准确性和覆盖面", [
  #text(style: "italic", fill: luma(75))[题目：在设计一个用于有监督精调的数据集时，如何保证数据的多样性、准确性和覆盖面？请举例说明具体策略。]
  *答：*
  - *多样性*：
    - 建任务分类体系（分类/抽取/生成/推理/代码/多轮/拒答）；
    - 多领域、多语言、多长度、多难度采样；
    - 不同输入输出格式；人工+合成结合；LIMA 式采样。
  - *准确性*：
    - 明确标注规范和参考答案；专家审核；
    - 自动过滤（格式/事实/重复/毒性）+ 人工抽检；
    - 交叉标注/一致性检查；难例复核；
    - 合成数据用强模型生成 + 验证/投票。
  - *覆盖面*：
    - 对齐真实用户日志/业务场景；覆盖长尾和边界；
    - 多轮上下文、工具调用、拒答/不确定；
    - 留出集评估覆盖缺口；按任务分层统计。
  - *例子*：
    - 医疗：指南问答 + 病历摘要 + 拒答；医生审核；
    - 客服：订单/退换/投诉/多轮；真实日志采样；
    - 代码：生成/解释/调试/单测；执行验证。
  - *迭代*：数据飞轮（线上失败案例回流）、主动学习、难度课程。
  #src[依据：L8 P69、P73；博客 #link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[《LLM 有监督微调》]；Wang et al. (2023) Self-Instruct。]
])

#qa("8.4", "全量微调与参数高效微调（LoRA、Prefix Tuning）", [
  #text(style: "italic", fill: luma(75))[题目：比较全量微调与参数高效微调（如 LoRA 和 Prefix Tuning）的优缺点，并说明在什么情况下更适合使用参数高效微调方法。]
  *答：*
  - *全量微调*：
    - 优点：容量最大、效果通常最好；可大幅改变行为/注入领域知识；
    - 缺点：显存/存储/计算高；每个任务一份完整副本；小数据易过拟合/灾难性遗忘；多任务部署成本高。
  - *PEFT*：冻结大部分预训练参数，只训练少量新增/低秩参数。
    - LoRA：$Delta W = B A$，低秩增量；可合并回权重，推理几乎无额外延迟；多任务只存增量；
    - Prefix Tuning：每层 K/V 前加可训练前缀；占上下文、略增延迟；
    - Adapter：插入瓶颈模块；增加深度/延迟；
    - 优点：显存小、存储省、多任务共享基座、效果接近全量；
    - 缺点：效果通常略低；部分方法有推理延迟；对秩/超参敏感。
  - *何时 PEFT*：显存/算力有限；多下游任务/多租户；快速迭代/切换；边缘部署；保留基座通用能力；数据量较小。
  - *何时全量*：资源充足；任务与预训练分布差异大；需要极致效果/大幅行为改变；单一任务长期部署。
  - *结论*：先做 LoRA/QLoRA 基线，不够再全量；用验证集比较，不盲目追求参数量。
  #src[依据：L8 P69、P74；博客 #link("https://biscuit0613.github.io/posts/nlp/08-02-peft-lora/")[《参数高效微调》]、#link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[《LLM 有监督微调》]；Hu et al. (2021)；Li & Liang (2021)。]
])

#qa("8.5", "特定功能的 SFT 及其重要性", [
  #text(style: "italic", fill: luma(75))[题目：请举例说明有哪些特定功能的有监督精调？请分析它们在实际应用中的重要性。]
  *答：*
  - *数字/数学推理*：逐步计算、公式、验算；重要性：金融/教育/科学计算需要精确。
  - *代码生成/理解*：函数、调试、单测、注释；重要性：IDE/低代码/运维自动化；可用执行反馈验证。
  - *多轮对话*：上下文保持、指代、任务状态；重要性：客服/助手/教育。
  - *长上下文*：文档问答/摘要；重要性：合同/论文/日志。
  - *格式/工具调用*：JSON、SQL、API 参数；重要性：系统集成/Agent。
  - *领域适配*：医疗/法律/金融；重要性：术语/合规/证据。
  - *安全/拒答*：有害请求、隐私、越权；重要性：合规/品牌风险。
  - *重要性总结*：通用 SFT 只教“听从指令”，特定能力需要针对性数据/目标；能提升可靠性、格式稳定性、领域准确性，减少推理时提示工程和外部校验成本；但窄领域微调可能损害通用能力，需混数据/监控。
  #src[依据：L8 P70、P75；博客 #link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[《LLM 有监督微调》]、#link("https://biscuit0613.github.io/posts/nlp/08-02-peft-lora/")[《参数高效微调》]。]
])

#qa("8.6", "长上下文处理的主流方法、优势与局限", [
  #text(style: "italic", fill: luma(75))[题目：当前长上下文处理的主流方法有哪些？结合实例分析这些方法的优势与局限性。]
  *答：*
  - *扩展窗口 + 继续预训练*：长文档/代码库；调整 RoPE base、位置插值（PI）、NTK-aware、YaRN、ALiBi；例子：128K/1M 上下文模型。
    - 优势：保留细节、单次推理；局限：$O(n^2)$ 计算/KV 显存、训练数据稀缺、外推退化、lost in the middle。
  - *高效注意力/系统*：FlashAttention（IO 优化）、稀疏/滑窗/膨胀注意力、线性注意力、GQA/MQA、Ring Attention/序列并行、KV cache 压缩。
    - 优势：降显存/提吞吐；局限：精确召回/长程依赖可能下降，实现复杂。
  - *检索/记忆*：RAG、外部记忆、层次摘要、分块 map-reduce。
    - 优势：便宜、可更新、可溯源、可扩展；局限：检索错误、分块丢上下文、多跳难。
  - *数据/训练*：长上下文 SFT、packing + attention mask、课程学习、合成任务；评估 Needle-in-a-Haystack、LongBench、RULER。
  - *推理策略*：分治、迭代阅读、Agent 工具调用。
  - *结论*：没有单一最优；按任务组合“窗口 + 检索 + 压缩 + 评测”，并验证有效上下文而非只看标称长度。
  #src[依据：L8 P70、P76；博客 #link("https://biscuit0613.github.io/posts/nlp/07-01-llm-architecture/")[《大模型预训练》]、#link("https://biscuit0613.github.io/posts/nlp/12-03-rag/")[《RAG》]、#link("https://biscuit0613.github.io/posts/nlp/11-01-inference-frameworks/")[《推理框架与部署》]；RoPE/YaRN/FlashAttention/LongBench。]
])

#section[第 9 讲 · 大语言模型的强化学习（L9 P25）]

#qa("9.1", "3H 原则及其在 RLHF 中的作用", [
  #text(style: "italic", fill: luma(75))[题目：简述 3H 原则及其在 RLHF 中的作用。]
  *答：*
  - *Helpful（有用）*：正确理解并解决用户问题，回答相关、完整、可操作。
  - *Honest（诚实）*：不编造、不误导；不确定时承认，必要时给出来源/依据。
  - *Harmless（无害）*：不产生有害、歧视、违法、侵犯隐私或危险内容；拒绝不当请求并给安全替代。
  - *在 RLHF 中的作用*：
    - 价值准则：定义“好回答”的多目标标准；
    - 数据：指导偏好数据收集/标注（有用性、无害性、诚实性）；
    - 奖励模型：学习按 3H 打分；
    - 策略优化：PPO/DPO 最大化奖励；
    - 评估/红队：安全检查与迭代；
    - 权衡：有用 vs 无害可能冲突（如医疗/安全建议），需要规则和人类监督。
  - *例子*：有害请求→拒绝并给安全替代（harmless + helpful）；不知道→承认（honest）。
  - *局限*：3H 抽象、文化/场景依赖、标注者分歧、reward hacking；需细化为 rubric 并持续评估。
  #src[依据：L9 P25；博客 #link("https://biscuit0613.github.io/posts/nlp/09-01-rlhf-ppo/")[《RLHF 与 PPO》]。]
])

#qa("9.2", "PPO 与 DPO 的优缺点对比", [
  #text(style: "italic", fill: luma(75))[题目：对比 PPO 与 DPO 的优缺点。]
  *答：*
  - *PPO + RLHF*：
    - 流程：SFT → 奖励模型 → PPO 在线采样优化；维护策略、评论、奖励、参考 4 个模型。
    - 优点：可在线探索、适应复杂/多轮奖励；能用新采样修正偏好；灵活。
    - 缺点：贵、显存大、训练不稳定、调参敏感、易 reward hacking、采样成本高。
  - *DPO*：
    - 流程：SFT + 偏好对 $(x, y_w, y_l)$ 直接优化；只用策略和参考 2 个模型；离线。
    - 优点：简单、稳定、便宜；无需奖励模型/在线采样；接近普通 SFT。
    - 缺点：离线不能探索；对偏好数据质量/噪声敏感；可能过拟合、降低多样性；长度/风格偏差；依赖参考模型。
  - *对比*：
    #tablem[
      | 维度 | PPO | DPO |
      |---|---|---|
      | 奖励模型 | 需要 | 不需要 |
      | 采样 | 在线 | 离线 |
      | 模型数 | 4 | 2 |
      | 稳定性/成本 | 较低/高 | 较高/低 |
      | 约束 | 显式 KL/裁剪 | 隐式 KL（log-ratio） |
    ]
  - *选择*：资源充足、需要在线探索/复杂奖励→PPO；固定偏好数据、快速低成本→DPO；也可用 online DPO/迭代混合。
  #align(center, canvas({
    import draw: *
    let node(pos, body, fill) = content(
      pos,
      text(size: 6.2pt)[#body],
      frame: "rect",
      padding: (x: 3pt, y: 2.2pt),
      radius: 2pt,
      fill: fill,
      stroke: 0.5pt + rgb("#5b7fa6"),
    )
    node((0, 1.0), [SFT 模型], rgb("#e8f0fe"))
    node((2.7, 1.0), [奖励模型 RM], rgb("#fff3e0"))
    node((5.5, 1.0), [PPO 策略], rgb("#e8f5e9"))
    line((0.85, 1.0), (1.85, 1.0), mark: (end: "stealth"))
    line((3.55, 1.0), (4.65, 1.0), mark: (end: "stealth"))
    node((0, 0), [SFT 模型], rgb("#e8f0fe"))
    node((2.7, 0), [偏好数据], rgb("#f3e5f5"))
    node((5.5, 0), [DPO 策略], rgb("#e8f5e9"))
    line((0.85, 0), (1.85, 0), mark: (end: "stealth"))
    line((3.55, 0), (4.65, 0), mark: (end: "stealth"))
    content((2.75, 1.55), text(size: 5.8pt, fill: luma(80))[在线采样 · 4 个模型])
    content((2.75, -0.55), text(size: 5.8pt, fill: luma(80))[离线偏好对 · 2 个模型])
  }))
  #src[依据：L9 P25；博客 #link("https://biscuit0613.github.io/posts/nlp/09-01-rlhf-ppo/")[《RLHF 与 PPO》]、#link("https://biscuit0613.github.io/posts/nlp/09-02-dpo/")[《DPO》]；Schulman et al. (2017)；Rafailov et al. (2023)。]
])

#qa("9.3", "奖励模型中 KL 散度的作用", [
  #text(style: "italic", fill: luma(75))[题目：奖励模型中 KL 散度的作用是什么？]
  *答：*
  - *先澄清*：奖励模型的监督损失（Bradley–Terry）本身通常不含 KL；KL 出现在 RLHF 的优化目标/奖励信号里。
  - *KL₁：策略 vs 参考模型*：$max E[r] - beta "KL"(pi_theta, pi_"ref")$。
    - 防止策略偏离 SFT 模型太远，避免 reward hacking；
    - 保持语言质量/多样性/已有知识，防止退化或模式坍缩；
    - $beta$ 控制对齐强度：大→保守、可能欠拟合偏好；小→激进、可能跑偏。
  - *KL₂：PPO 新旧策略*：约束 $pi_theta$ 与 $pi_(theta_"old")$ 的差异（KL 或 clip），稳定更新、防止一次更新崩掉。
  - *DPO*：KL 隐式包含在 $log(pi_theta\/pi_"ref")$ 的 log-ratio 中；$beta$ 同样控制偏离程度。
  - *作用总结*：KL 不是提高奖励，而是“信任域/正则化”；它让模型在追求奖励时保持接近参考行为，降低过优化不完美奖励模型的风险。
  - *注意*：KL 不能替代高质量奖励模型/偏好数据；太强会欠拟合，太弱会 reward hacking。
  #src[依据：L9 P25；博客 #link("https://biscuit0613.github.io/posts/nlp/09-01-rlhf-ppo/")[《RLHF 与 PPO》]、#link("https://biscuit0613.github.io/posts/nlp/09-02-dpo/")[《DPO》]。]
])

#qa("9.4", "标注成本高时构建奖励模型的替代方案", [
  #text(style: "italic", fill: luma(75))[题目：若标注成本过高，有哪些替代方案构建奖励模型？]
  *答：*
  - *AI 反馈（RLAIF/Constitutional AI）*：用强 LLM 按 rubric 打分/成对比较；便宜可扩展；需防偏见/奖励劫持，可集成多评委。
  - *可验证奖励（RLVR）*：代码单测、数学精确匹配、格式/schema 校验、检索证据；客观但只适合可验证领域。
  - *隐式/弱信号*：用户点赞/点踩、编辑、重新生成、点击、A/B 测试；便宜但有噪声，需去偏。
  - *公开数据/迁移*：HH-RLHF、WebGPT、Summarize from Feedback；先预训练 RM 再领域微调。
  - *主动学习*：挑模型不确定/标注者分歧大的样本做人工标注，最大化标注价值。
  - *合成/增强偏好对*：扰动、回译、模型生成候选 + 启发式排序；需人工抽检。
  - *降低标注成本*：成对比较代替绝对打分、rubric、众包 + gold 质检、仅安全场景用专家。
  - *多目标代理奖励*：长度/毒性/重复/格式分类器组合；便宜但易被 gaming。
  - *直接对齐 + AI 偏好*：用 AI 生成的偏好对做 DPO，仍可避免显式 RM。
  - *混合策略*：小规模人工 + 大规模 AI/代理信号；用留出人工评估校准。
  - *风险*：代理奖励可被利用、偏见/分布漂移；必须用人类评估验证，不能只看代理指标。
  #src[依据：L9 P25；博客 #link("https://biscuit0613.github.io/posts/nlp/09-01-rlhf-ppo/")[《RLHF 与 PPO》]、#link("https://biscuit0613.github.io/posts/nlp/09-02-dpo/")[《DPO》]；Bai et al. (2022) Constitutional AI；Lee et al. (2023) RLAIF。]
])

#section[第 10 讲 · 知识增强与模型评价（L10 P75）]

#qa("10.1", "知识内化选择题", [
  #text(style: "italic", fill: luma(75))[题目：在大语言模型知识增强时，以下哪种方法通常用于将知识融入模型参数中？]
  - (1) 简单地增加训练数据的数量。
  - (2) 把结构化知识转换成纯文本数据并参与模型训练过程。
  - (3) 引入知识图谱并设计知识与文本的融合学习机制。
  - (4) 调整模型的超参数以改善性能。
  *答：选（3）。*
  - *(1) 增加数据*：规模扩展有帮助，但没有显式的知识融合机制；稀有/结构化事实仍可能学不到。
  - *(2) 知识转文本*：继续预训练可以注入部分事实，但会丢失实体/关系的结构信息，且不是“融合学习机制”；是弱基线。
  - *(3) 知识图谱 + 融合学习*：对应“知识内化”；例如联合掩码文本实体与图谱三元组、知识感知的预训练目标，把结构化知识压进参数。
  - *(4) 调超参数*：只优化训练过程，不增加知识内容。
  - *课件依据*：L10 P42 明确“知识内化：预训练过程中，从知识与数据中融合学习，把知识内化到模型参数”；P46 讲“融合世界知识的预训练：联合掩码策略”。
  #src[依据：L10 P75、P42、P46；博客 #link("https://biscuit0613.github.io/posts/nlp/10-02-knowledge-enhanced-llm/")[《知识增强的大语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/10-01-knowledge-graph/")[《知识图谱》]。]
])

#qa("10.2", "预训练模型融合知识的类型举例", [
  #text(style: "italic", fill: luma(75))[题目：请举例说明预训练模型融合知识的类型。]
  *答：*
  - *词法知识*：WordNet 同义词集合、同义/反义/上下位关系；任务如掩盖词还原、词汇关系分类。
  - *语义/逻辑知识*：蕴含、因果、转折；去掉“因为……所以”“虽然……但是”等连词，构造关系分类任务。例：“因为乱砍滥伐，所以洪涝不断”→因果。
  - *世界知识*：知识图谱三元组，如（姚明，出生地，上海）、（爱因斯坦，出生年份，1879）；预训练时联合掩码文本实体与对应三元组。
  - *常识知识*：ConceptNet/ATOMIC 的事件因果、意图、前提；辅助任务/对比学习。
  - *句法知识*：词性、依存、短语结构；多任务辅助损失。
  - *领域知识*：医疗指南、法律条文、金融报告；继续预训练/SFT/RAG。
  - *数值/时间知识*：日期、数量、单位、表格；专门分词/数据增强/结构化编码。
  - *本体/类型知识*：实体类型、分类体系、约束；知识感知嵌入/图编码器。
  - *融合方式*：联合掩码、辅助分类、对比学习、知识增强注意力/图编码器、adapter、知识转文本/合成 QA、检索增强。
  - *注意*：内化与外用不同；纯文本转换会丢结构，知识图谱/图编码器保留关系。
  #src[依据：L10 P75；课件 P43–46；博客 #link("https://biscuit0613.github.io/posts/nlp/10-02-knowledge-enhanced-llm/")[《知识增强的大语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/10-01-knowledge-graph/")[《知识图谱》]、#link("https://biscuit0613.github.io/posts/nlp/03-04-classic-tasks/")[《经典 NLP 任务》]；Sun et al. (2019) ERNIE。]
])

#qa("10.3", "知识增强的意义与两个应用场景", [
  #text(style: "italic", fill: luma(75))[题目：试论述在大语言模型中进行知识增强的意义，并给出至少两个实际应用场景。]
  *答：*
  - *意义*：
    - 事实性/降幻觉：外部证据/结构化知识补足参数记忆，减少冷门实体和精确数值错误；
    - 时效性：知识库/API 可更新，无需重新训练；
    - 可追溯/可解释：引用来源，便于审计；
    - 领域专业/合规：权威指南、法规、文献；
    - 推理：结构化知识支持多跳查询/关系推理；
    - 成本：小模型 + 检索可接近大模型效果，知识更新更便宜；
    - 个性化/实时：用户数据、订单、行情、天气。
  - *应用场景（至少两个）*：
    1. *搜索/问答*：实时票房/新闻/天气；检索后生成并注明来源；企业知识库问答。
    2. *医疗*：临床指南、药品相互作用、文献；辅助决策并引用证据；需医生复核。
    3. *金融*：公告/研报/行情；合规问答、风控；实时数据接入。
    4. *客服*：产品手册、订单、用户画像；多轮支持，降低幻觉。
    5. *法律*：法条/判例；合同审查；引用来源。
    6. *教育*：教材/题库；个性化辅导。
  - *例子*：“这个国庆档票房排行前十的电影”——模型参数知识过时，接入实时票房库/RAG，检索后生成并注明来源。
  - *局限*：检索质量、知识冲突、延迟/成本、引用忠实性、隐私/安全；知识增强不能完全消除幻觉。
  #src[依据：L10 P75；博客 #link("https://biscuit0613.github.io/posts/nlp/10-02-knowledge-enhanced-llm/")[《知识增强的大语言模型》]、#link("https://biscuit0613.github.io/posts/nlp/12-03-rag/")[《RAG》]、#link("https://biscuit0613.github.io/posts/nlp/10-01-knowledge-graph/")[《知识图谱》]。]
])

#qa("10.4", "LLM 基础能力评估包含哪些方面", [
  #text(style: "italic", fill: luma(75))[题目：大语言模型的基础能力评估包含哪些方面？请列举出至少 3 个方面，并且加以简单说明。]
  *答：*
  - *阅读理解*：读一段/多段文本并准确回答问题；如 SQuAD、RACE、LongBench。
  - *文本生成*：生成符合语义逻辑和语言规范的文本，关注准确性、多样性、一致性；摘要/翻译用 BLEU/ROUGE/BERTScore/LLM 评委。
  - *代码生成*：生成语法正确、可执行、性能合理的代码；如 HumanEval、MBPP、SWE-bench。
  - *逻辑推理*：基于事实和逻辑关系进行演绎/归纳/溯因；如 BBH、ARC、AGIEval。
  - *数学推理*：理解问题、多步推理、数值计算；如 GSM8K、MATH。
  - *记忆/长上下文*：在长上下文中保持并调用信息；如 Needle-in-a-Haystack、RULER、LongBench。
  - *指令遵循*：按指定格式/语言/长度完成任务；如 IFEval、MT-Bench、AlpacaEval。
  - *工具使用*：调用搜索、计算器、代码执行器、API；Agent 基准。
  - *角色扮演*：模仿指定人物/性格并保持设定。
  - *安全与伦理*：冒犯性、偏见、公平性、隐私、非法活动；如 ToxiGen、RealToxicityPrompts、红队测试。
  - *真实与可信*：事实准确性、前后一致性、来源可靠性、抗提示注入/越狱；如 TruthfulQA。
  - *知识广度*：MMLU、MMLU-Pro、GPQA、C-Eval。
  - *评价方式*：自动指标、LLM-as-a-Judge、人工评价；注意测试集污染、基准饱和、评委偏见、成本。报告要说明“测了什么、没测什么”。
  #src[依据：L10 P75；博客 #link("https://biscuit0613.github.io/posts/nlp/10-03-llm-evaluation/")[《大语言模型的评价》]、#link("https://biscuit0613.github.io/posts/nlp/05-01-evaluation-metrics/")[《NLP 评价指标》]；MMLU/AlpacaEval/Chatbot Arena。]
])

#section[答案来源与延伸阅读]

#block(
  width: 100%,
  fill: pale,
  stroke: 0.5pt + accent2,
  radius: 3pt,
  inset: 7pt,
  [
    *课件*
    - 第 2 讲《自然语言处理基础理论》P55–56；第 3 讲《自然语言的统计建模与经典技术》P143。
    - 第 4 讲《自然语言处理的深度学习基础》P148；第 6 讲《词向量及神经语言模型》P142–145。
    - 第 8 讲《大模型的有监督微调》P69–76；第 9 讲《大语言模型的强化学习》P25；第 10 讲《大语言模型知识增强与模型评价》P75。

    *博客索引*
    - 总览：#link("https://biscuit0613.github.io/posts/nlp/00-course-map/")[《NLP 课程复习索引》]。
    - 统计与经典：#link("https://biscuit0613.github.io/posts/nlp/03-01-language-model/")[统计语言模型]、#link("https://biscuit0613.github.io/posts/nlp/03-03-syntax-semantics/")[句法分析]、#link("https://biscuit0613.github.io/posts/nlp/03-04-classic-tasks/")[经典 NLP 任务]。
    - 词向量与预训练：#link("https://biscuit0613.github.io/posts/nlp/06-01-word-representation/")[词向量基础]、#link("https://biscuit0613.github.io/posts/nlp/06-02-word2vec/")[Word2Vec]、#link("https://biscuit0613.github.io/posts/nlp/06-04-subword-tokenization/")[子词分词]、#link("https://biscuit0613.github.io/posts/nlp/06-05-nnlm-rnnlm/")[NNLM/RNNLM]、#link("https://biscuit0613.github.io/posts/nlp/06-07-bert/")[BERT]、#link("https://biscuit0613.github.io/posts/nlp/06-08-gpt-bart-t5/")[GPT/BART/T5]。
    - 微调与对齐：#link("https://biscuit0613.github.io/posts/nlp/08-01-llm-sft/")[SFT]、#link("https://biscuit0613.github.io/posts/nlp/08-02-peft-lora/")[PEFT/LoRA]、#link("https://biscuit0613.github.io/posts/nlp/09-01-rlhf-ppo/")[RLHF/PPO]、#link("https://biscuit0613.github.io/posts/nlp/09-02-dpo/")[DPO]。
    - 知识、评价与应用：#link("https://biscuit0613.github.io/posts/nlp/10-01-knowledge-graph/")[知识图谱]、#link("https://biscuit0613.github.io/posts/nlp/10-02-knowledge-enhanced-llm/")[知识增强]、#link("https://biscuit0613.github.io/posts/nlp/10-03-llm-evaluation/")[LLM 评价]、#link("https://biscuit0613.github.io/posts/nlp/12-01-prompt-engineering/")[提示工程]、#link("https://biscuit0613.github.io/posts/nlp/12-03-rag/")[RAG]。

    *关键论文/教材*
    - Shannon (1951), Prediction and Entropy of Printed English；Jurafsky & Martin, Speech and Language Processing.
    - Mikolov et al. (2013), word2vec；Sennrich et al. (2016), BPE；Bojanowski et al. (2017), fastText.
    - Hochreiter & Schmidhuber (1997), LSTM；Cho et al. (2014), GRU；Vaswani et al. (2017), Transformer.
    - Devlin et al. (2019), BERT；Radford et al. (2018), GPT；Lewis et al. (2020), BART；Raffel et al. (2020), T5.
    - Hu et al. (2021), LoRA；Dettmers et al. (2023), QLoRA；Li & Liang (2021), Prefix Tuning.
    - Ouyang et al. (2022), InstructGPT；Schulman et al. (2017), PPO；Rafailov et al. (2023), DPO.
    - Sun et al. (2019), ERNIE；Lewis et al. (2020), RAG；Hendrycks et al. (2021), MMLU；Li et al. (2023), AlpacaEval；Chiang et al. (2024), Chatbot Arena.

    #text(size: 6.4pt, fill: luma(90))[页码以课件 PDF 为准，不同版本可能略有偏移。]
  ],
)
