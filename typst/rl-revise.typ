// ==================================================================
//  强化学习 · 期末复习指南（网站版）
//  依据：强化学习复习.pdf 15 条要点、讲义二~七与九、练习题（一）（二）
//  说明：第八讲 VLA 与图强化学习不在考察范围，本文件不收录
// ==================================================================

#let c-head = rgb("#1a5276")
#let c-sub = rgb("#2874a6")
#let c-key = rgb("#7d3c98")
#let f-eq = rgb("#eaf2f8")
#let s-eq = rgb("#a9cce3")
#let f-ex = rgb("#fef9e7")
#let s-ex = rgb("#f1c40f")
#let f-warn = rgb("#fdedec")
#let s-warn = rgb("#e6b0aa")
#let f-tip = rgb("#eafaf1")
#let s-tip = rgb("#a9dfbf")

#set document(title: "强化学习 · 期末复习指南")
#set page(paper: "a4", margin: (x: 6mm, y: 6mm, top: 7mm), header: none, footer: none)
#set text(font: ("Noto Sans CJK SC", "DejaVu Sans"), size: 7.4pt, lang: "zh", region: "cn")
#set par(justify: false, leading: 0.42em, spacing: 0.45em)
#set list(indent: 0.9em, spacing: 0.45em)
#set enum(indent: 0.9em, spacing: 0.45em)
#set table(stroke: 0.3pt + rgb("#c8d6e5"), inset: 2pt, fill: (x, y) => if y == 0 { rgb("#d6eaf8") } else { white })
#set heading(numbering: none)

#let eq(body) = block(width: 100%, fill: f-eq, inset: (x: 3pt, y: 2pt), radius: 1.5pt, stroke: 0.3pt + s-eq, body)
#let ex(head, body) = block(width: 100%, fill: f-ex, inset: (x: 3pt, y: 2.2pt), radius: 1.5pt, stroke: 0.4pt + s-ex, [
  #text(weight: "bold", fill: rgb("#9a7d0a"))[例｜#head] #v(-0.15em)
  #body
])
#let warn(body) = block(width: 100%, fill: f-warn, inset: (x: 3pt, y: 2pt), radius: 1.5pt, stroke: 0.4pt + s-warn, body)
#let tip(body) = block(width: 100%, fill: f-tip, inset: (x: 3pt, y: 2pt), radius: 1.5pt, stroke: 0.4pt + s-tip, body)
#let chip(body) = box(fill: c-head, radius: 1.5pt, inset: (x: 2.2pt, y: 0.6pt), text(6.6pt, white, weight: "bold", body))
#let k(body) = text(weight: "bold", fill: c-key, body)
#let t(body) = text(fill: c-sub, body)

#show heading.where(level: 1): it => {
  v(1.2pt)
  block(width: 100%, fill: c-head, inset: (x: 4pt, y: 2pt), radius: 1.5pt,
        text(8.2pt, white, weight: "bold", it.body))
  v(1.6pt)
}
#show heading.where(level: 2): it => {
  v(0.8pt)
  text(7.6pt, weight: "bold", fill: c-head, "▎" + it.body)
  v(0.8pt)
}

#align(center)[
  #text(13pt, weight: "bold", fill: c-head)[强化学习 · 期末复习指南]
  #v(0.5pt)
  #text(7pt, fill: luma(90))[按复习课 15 条要点组织 · 第八讲 VLA 与图强化学习不在考察范围]
]
#v(2pt)

#columns(2, gutter: 4mm)[

= 0　考前速览：考什么、怎么背

#chip[复习要点 15] #chip[题型：50 + 50]

+ *题型与分值*：填空 / 选择 / 判断 *50 分*；计算 / 简答 *50 分*。
+ *复习单点名的三个最难点*：① *Q 表 / 价值函数 / Q 函数的手算*；② *对数概率策略梯度的证明*；③ *贝尔曼方程与矩阵形式*。
+ *命题范围*：上课反复强调、PPT 加粗或标红的内容。第八讲（VLA 与图强化学习）*不考*。
+ *计算题得分格式*：先写公式 → 代入数字 → 得结果 → 补一句结论/比较。

*15 条要点与本指南对应*：

#table(columns: (0.1fr, 0.72fr, 0.18fr),
  table.header([*\#*], [*要点*], [*见*]),
  [1], [状态、动作、奖励、回报、策略、价值；奖励 vs 回报；V vs Q], [§1],
  [2], [强化学习、监督学习、无监督学习的区别与联系], [§2],
  [3], [MDP 五要素、转移矩阵、折扣因子、马尔可夫性], [§3],
  [4], [贝尔曼方程及其矩阵形式], [§4],
  [5], [轨迹表示与轨迹概率], [§5],
  [6], [TD 目标/误差、SARSA vs Q-learning、同策略/异策略], [§6],
  [7], [DQN 两个网络、经验回放], [§8],
  [8], [Q 表计算], [§7],
  [9], [策略学习、对数概率梯度推导、θ 与 J(θ) 的证明], [§9],
  [10], [Actor-Critic、优势函数、PPO 特点、ρ、截断、稳定性措施], [§10],
  [11], [模型学习的优点/作用/局限、与无模型区别、一步估计误差], [§11],
  [12], [ε-greedy、LCB、Thompson Sampling 的区别与计算], [§12],
  [13], [内在奖励与外在奖励、典型方法、Noisy-TV], [§12],
  [14], [大模型与强化学习的关系、任务设计], [§13],
  [15], [考试题型与难点], [§0],
)

*全篇符号约定*（讲义记号不一致处，本指南统一如下）：

#table(columns: (0.26fr, 1fr), table.header([*符号*], [*含义*]),
  [$S_t, A_t, R_t, S_(t+1)$], [随机变量：第 $t$ 步状态、动作、即时奖励、下一状态],
  [$s_t, a_t, r_t, s'$], [随机变量的具体取值],
  [$gamma$], [折扣因子，$0 <= gamma <= 1$],
  [$G_t$], [回报 $= R_t + gamma R_(t+1) + gamma^2 R_(t+2) + dots.c = R_t + gamma G_(t+1)$],
  [$tau$], [轨迹 $(s_0, a_0, r_0, s_1, dots.c, s_T)$],
  [$p(s'|s,a)$], [状态转移概率；矩阵 $bold(P)$],
  [$R(s,a), R(s,a,s')$], [奖励函数；策略诱导的即时奖励期望 $r_pi (s) = sum_a pi(a|s) R(s,a)$],
  [$cal(S), cal(A)$], [状态空间、动作空间],
  [$pi(a|s)$], [策略；参数化策略 $pi_theta (a|s)$],
  [$V^pi (s), Q^pi (s,a)$], [状态价值、动作价值],
  [$V^*, Q^*, pi^*$], [最优价值函数与最优策略],
  [$A^pi (s,a)$], [优势函数 $= Q^pi (s,a) - V^pi (s)$],
  [$Y_t, delta_t$], [TD 目标、TD 误差 $delta_t = Y_t - Q(s_t,a_t)$],
  [$theta, phi$], [Actor 参数、Critic 参数],
  [$theta^-$], [DQN 目标网络参数],
  [$theta_"old"$], [PPO 采样时的旧策略参数],
  [$rho_t$], [PPO 新旧策略概率比（博客记 $r_t (theta)$，本指南改名）],
  [$alpha, epsilon, epsilon.alt$], [学习率；ε-greedy 探索率；PPO 裁剪半径 $epsilon.alt_"clip"$],
)

#warn[
  *记号冲突，答题时先声明*：讲义二的回报首项写作 $r_(t+1)$，讲义三/五/六写作 $r_t$，两者只差一次下标平移；本指南按随机变量统一记 $R_t$。*同一份答卷必须自始至终用同一种*。PPO 概率比讲义写 $r_t (theta)$，复习单写 $rho_t$，本指南统一用 $rho_t$，避免与奖励混淆。
]

= 1　基本概念：一条因果链与两组易混概念

#chip[复习要点 1]

*一条链*：状态 $S_t$ → 策略 $pi$ 选动作 $A_t$ → 环境给奖励 $R_t$、转移到 $S_(t+1)$ → 把未来奖励折扣求和得*回报* $G_t$ → 对回报取*期望*得*价值* $V^pi (s)$ 或 $Q^pi (s,a)$。

#eq[$
  G_t = R_t + gamma G_(t+1), quad
  V^pi (s) = bb(E)_pi [G_t | S_t = s], quad
  Q^pi (s,a) = bb(E)_pi [G_t | S_t = s, A_t = a]
$]

== 奖励 vs 回报（必考区分）

+ *奖励 $R_t$*：环境给的一步即时反馈，当场可得，可能稀疏、延迟、有噪声。
+ *回报 $G_t$*：从 $t$ 开始的折扣奖励和，是智能体真正最大化的量，需要"往后看"。
+ *关系*：$G_t = R_t + gamma G_(t+1)$，回报把远期目标传回早期决策。
+ *为什么优化回报*：只贪即时奖励会短视；折扣让远期奖励仍有权重，同时保证无限时域下级数收敛。

== V 与 Q（必考区分）

#table(columns: (0.22fr, 1fr, 1fr), table.header([*维度*], [$V^pi (s)$], [$Q^pi (s,a)$]),
  [*评价对象*], [状态], [状态—动作对],
  [*输入*], [$s$], [$(s,a)$],
  [*含义*], [从 $s$ 出发按 $pi$ 行动的期望回报], [从 $(s,a)$ 出发再按 $pi$ 行动的期望回报],
  [*能否比较动作*], [不能直接比较], [*能*：$a^* = arg max_a Q(s,a)$],
  [*关系*], [$V^pi (s) = sum_a pi(a|s) Q^pi (s,a)$], [$Q^pi (s,a) = R(s,a) + gamma sum_(s') p(s'|s,a) V^pi (s')$],
)

#tip[
  *一句话*：$V$ 评价"这个状态好不好"，$Q$ 评价"在这个状态下做这个动作好不好"。*决策看 Q，评价状态看 V*。
]

== 策略与价值：为什么是期望

+ *策略*是从状态到动作规则的映射。确定性策略每个状态只给一个动作；随机策略给动作分布 $pi(a|s)$。
+ 离散动作下分布必须满足*非负性* $pi(a|s) >= 0$ 与*归一性* $sum_a pi(a|s) = 1$。
+ *价值是回报的期望*：策略和环境都有随机性，同一起点多次交互得到的 $G_t$ 不同；价值衡量"平均长期收益"，不是某一次运气。

#ex[折扣回报手算][
  一维链 $s_1 dots.c s_7$，$R(s_1) = 5$、$R(s_7) = 10$、其余为 0；回合长 4 步，$gamma = 0.5$。
  $
    G(s_4 -> s_5 -> s_6 -> s_7) = 0 + 0.5 dot 0 + 0.25 dot 0 + 0.125 dot 10 = 1.25
  $
  $
    G(s_4 -> s_3 -> s_2 -> s_1) = 0 + 0.5 dot 0 + 0.25 dot 0 + 0.125 dot 5 = 0.625
  $
  没走到奖励点则 $G = 0$。*结论：回报取决于这条路径最终能拿到多少奖励、以及拿到的早晚。*
]

= 2　强化学习 vs 监督学习 vs 无监督学习

#chip[复习要点 2]

#table(columns: (0.2fr, 1fr, 1fr, 0.9fr), table.header([*维度*], [*监督学习*], [*无监督学习*], [*强化学习*]),
  [*数据来源*], [训练集事先给定], [训练集事先给定], [*智能体与环境交互自己产生*],
  [*数据分布*], [通常 i.i.d.], [通常 i.i.d.], [*非 i.i.d.*：策略决定见到什么数据],
  [*监督信号*], [精确标签 $y$], [无标签，只有 $x$], [*标量奖励 $r$*：模糊、延迟、可能稀疏],
  [*目标*], [拟合输入→输出], [发现结构/表示/密度], [*最大化长期折扣回报*],
  [*是否决策*], [一次预测], [不涉及决策], [*序贯决策*：动作改变未来状态分布],
  [*探索*], [不需要], [不需要], [*必须平衡探索与利用*],
)

*三个本质差异*：

+ *没有逐步标签*：一条轨迹只有一串奖励，500 步后到达终点时，前 499 步没有"这个动作对不对"的答案 → *信用分配问题*。
+ *数据分布随策略变化*：$(s,a) arrow.squiggly d^pi (s) pi(a|s)$；策略一更新，状态访问分布就变，*数据分布本身是优化过程的一部分*。
+ *必须主动探索*：最优动作可能从未被当前策略试过；不探索就永远得不到"它更好"的数据。

*联系*：

+ RL 内部大量使用*监督学习组件*：环境模型回归 $(s,a) -> s'$、价值网络回归 TD 目标、行为克隆、奖励模型训练。
+ RL 内部也使用*无监督/自监督组件*：状态表示学习、计数/聚类、RND 的特征预测、世界模型潜编码。
+ 大模型训练把三者串起来：预训练（自监督）→ SFT（监督）→ 奖励模型（监督）→ RLHF/PPO/GRPO（强化学习）；DPO 是偏好优化，介于 SL 与 RL 之间。

#warn[
  *判断口诀*：只要同时出现"动作改变未来分布 + 延迟奖励 + 需要探索"，就是 RL。DQN 的损失看起来像回归，但*标签由网络自己算出、数据非 i.i.d.*，所以不是普通监督学习。
]

= 3　MDP：五要素、马尔可夫性与转移矩阵

#chip[复习要点 3]

*五元组*：$M = (cal(S), cal(A), p, R, gamma)$

+ $cal(S)$：状态空间；$cal(A)$：动作空间。
+ $p(s'|s,a)$：状态转移概率，描述环境动力学。
+ $R(s,a) = bb(E)[R_t | S_t = s, A_t = a]$：奖励函数；也可写成与下一状态绑定的 $R(s,a,s')$。
+ $gamma in [0,1]$：折扣因子。

*马尔可夫性*：

#eq[$
  p(S_(t+1) = s' | S_t = s_t, S_(t-1) = s_(t-1), dots.c, S_0 = s_0)
  = p(S_(t+1) = s' | S_t = s_t)
$]

文字表述：*下一时刻状态只依赖当前状态（和当前动作），与更早的历史无关*——"未来与过去相对现在条件独立"。因此历史信息可全部压缩进 $s_t$，价值函数才有递推结构。

*转移矩阵*：$P_(i j) = p_pi (s_j|s_i) = sum_a pi(a|s_i) p(s_j|s_i,a)$，第 $i$ 行是"从 $s_i$ 出发到所有后继的概率分布"。

#eq[$
  0 <= P_(i j) <= 1, quad sum_j P_(i j) = 1 quad "（每行和为 1）"
$]

*折扣因子的作用*：

+ 让越远的奖励权重越小，体现"现在的奖励更可靠"。
+ 使无限时域回报有界、级数收敛。
+ 把优化目标限制在有限时间尺度内。数值感受：$gamma = 0.99$ 时 $gamma^(1000) approx 4.3 times 10^(-5)$。
+ 极端：$gamma = 0$ *极度短视*，只优化 $R_t$；$gamma -> 1$ *极度远视*，未来与现在等价，可能发散、迭代不收敛。

#ex[读图写转移矩阵][
  4 状态图：$s_1$ 自环 0.1、$s_1 -> s_2$ 0.2、$s_1 -> s_4$ 0.7；$s_2 -> s_1$ 1；$s_4$ 自环 0.5、$s_4 -> s_2$ 0.3、$s_4 -> s_3$ 0.2；$s_3 -> s_2$ 1。
  $
    bold(P) = mat(0.1, 0.2, 0, 0.7; 1, 0, 0, 0; 0, 1, 0, 0; 0, 0.3, 0.2, 0.5, delim: "(")
  $
  逐行检查：$0.1 + 0.2 + 0.7 = 1$，$0.5 + 0.3 + 0.2 = 1$。*给描述能写矩阵；给矩阵能读轨迹概率（连乘）。*
]

= 4　贝尔曼方程与矩阵形式

#chip[复习要点 4] #chip[计算题高频]

== 贝尔曼期望方程

*核心思想*：价值 = 即时奖励 + 折扣后的后继价值期望，用后继估计更新当前估计，称为*自举*（bootstrapping）。$V^pi$ 与 $Q^pi$ 各有一条期望方程。

*状态价值*（① 平均奖励 $R(s,a)$）：

#eq[$
  V^pi (s) = sum_a pi(a|s) [R(s,a) + gamma sum_(s') p(s'|s,a) V^pi (s')]
$]

加权顺序不能反：外层 $pi(a|s)$ 是*策略随机性*，内层 $p(s'|s,a)$ 是*环境随机性*。若奖励写成 $R(s,a,s')$，$p$ 的加权要放进奖励内层。

*推导链*（以 $V^pi$ 为例，考试可默写）：

#eq[$
  V^pi (s) &= bb(E)_pi [G_t | S_t = s] \
  &= bb(E)_pi [R_t + gamma G_(t+1) | S_t = s] \
  &= r_pi (s) + gamma bb(E)_pi [V^pi (S_(t+1)) | S_t = s] \
  &= r_pi (s) + gamma sum_(s') p_pi (s'|s) V^pi (s')
$]

*$r_pi$ 与 $p_pi$ 的含义*：把策略的动作随机性吸收进奖励和转移，MDP 就退化成 MRP：

#eq[$
  r_pi (s) = sum_a pi(a|s) R(s,a), quad
  p_pi (s'|s) = sum_a pi(a|s) p(s'|s,a)
$]

$r_pi (s)$ 是在 $s$ 按策略行动的一步期望奖励；$p_pi (s'|s)$ 是按策略行动后从 $s$ 到 $s'$ 的转移概率。矩阵中 $r_i = r_pi (s_i)$，$P_(i j) = p_pi (s_j|s_i)$。

*动作价值*：条件固定 $A_t=a$，同样有 $Q^pi (s,a) = bb(E)_pi [R_t + gamma Q^pi (S_(t+1), A_(t+1)) | S_t = s, A_t = a]$，展开时少一层对动作的策略加权：

#eq[$
  Q^pi (s,a) = R(s,a) + gamma sum_(s') p(s'|s,a) V^pi (s')
  = R(s,a) + gamma sum_(s') p(s'|s,a) sum_(a') pi(a'|s') Q^pi (s',a')
$]

*奖励的另两种等价写法*（② 奖励与下一状态绑定，③ 奖励也随机；① 见上式）：

#eq[$
  V^pi (s) &= sum_a pi(a|s) sum_(s') p(s'|s,a) [R(s,a,s') + gamma V^pi (s')] \
  &= sum_a pi(a|s) sum_(s') sum_r p(r,s'|s,a) [r + gamma V^pi (s')]
$]

三者由全期望公式换算：$R(s,a) = sum_(s') p(s'|s,a) R(s,a,s') = sum_r r p(r|s,a)$。给哪种奖励表示，就把奖励放到对应求和的内层。

== 矩阵形式

令 $bold(v), bold(r)$ 为 $N$ 维列向量，$bold(P)$ 为固定策略诱导的 $N times N$ 转移矩阵：$v_i = V^pi (s_i)$，$r_i = r_pi (s_i)$，$P_(i j) = p_pi (s_j|s_i)$，每行和为 1。

#eq[$
  bold(v) = bold(r) + gamma bold(P) bold(v)
  -> (bold(I) - gamma bold(P)) bold(v) = bold(r)
  -> bold(v) = (bold(I) - gamma bold(P))^(-1) bold(r)
$]

*为什么不用直接求逆*：求逆复杂度 $O(N^3)$，大规模状态空间不可接受；而且 $p$ 往往未知、$bold(P)$ 又太大。改用*迭代法*：反复做贝尔曼更新，直到价值不再变化。

#eq[$
  v_(k+1) (s) <- r_pi (s) + gamma sum_(s') p_pi (s'|s) v_k (s'), quad "收敛判据" norm(v_(k+1) - v_k) <= epsilon
$]

== 贝尔曼最优方程

最优价值函数满足把"策略加权"换成"对动作取最大"：

#eq[$
  V^* (s) = max_a [R(s,a) + gamma sum_(s') p(s'|s,a) V^* (s')]
$]
#eq[$
  Q^* (s,a) = R(s,a) + gamma sum_(s') p(s'|s,a) max_(a') Q^* (s',a')
$]
#eq[$
  pi^* (s) = arg max_a Q^* (s,a)
$]

#warn[
  *期望方程 vs 最优方程*：期望方程描述"给定策略 $pi$ 的价值"；最优方程描述"所有策略中最好的价值"，因此对动作取 $max$ 而不是按 $pi$ 加权。
]

#tip[
  *存在性与唯一性*：有限 MDP 且 $gamma<1$ 时，Bellman 最优算子是 $gamma$-压缩映射，$V^*$ 存在且唯一；最优策略可能不唯一，但最优价值唯一。
]

#ex[解贝尔曼方程：直接法 vs 迭代法][
  两状态 MRP：$R(s_1) = 5$, $R(s_2) = 10$, $gamma = 0.5$；$p(s_1|s_1) = 0.5$, $p(s_2|s_1) = 0.5$, $p(s_2|s_2) = 1$。
  + *列方程*：$V_1 = 5 + 0.5(0.5 V_1 + 0.5 V_2)$，$V_2 = 10 + 0.5 V_2$。
  + *解*：$V_2 = 20$；$V_1 = 5 + 0.25 V_1 + 2.5 -> 0.75 V_1 = 7.5 -> V_1 = 10$。
  + *矩阵验证*：$bold(I) - gamma bold(P) = mat(0.75, -0.25; 0, 0.5)$，解 $(bold(I) - gamma bold(P)) bold(v) = bold(r)$ 得同一结果。
  + *迭代*：$V^((0)) = (0,0) -> V^((1)) = (5,10) -> V^((2)) = (8.75,15) -> dots.c -> (10,20)$。每轮只做"奖励 + 折扣后继"。
]

= 5　轨迹与轨迹概率

#chip[复习要点 5]

*轨迹*：$tau = (s_0, a_0, r_0, s_1, a_1, r_1, dots.c, s_T)$，是一串状态—动作—奖励。

*轨迹概率*：初始分布 × 每步策略概率 × 每步转移概率的连乘：

#eq[$
  p(tau | theta) = rho(s_0) product_(t=0)^(T-1) pi_theta (a_t | s_t) p(s_(t+1) | s_t, a_t)
$]

*关键观察*：只有 $pi_theta$ 依赖参数 $theta$；初始分布 $rho(s_0)$ 与转移概率 $p$ 由环境决定。*这就是策略梯度中环境项求导为 0 的根源。*

#ex[轨迹概率连乘][
  三步轨迹 $s_0 ->^(a_0) s_1 ->^(a_1) s_2$，$rho(s_0) = 1$，$pi(a_0|s_0) = 0.6$，$p(s_1|s_0,a_0) = 0.8$，$pi(a_1|s_1) = 0.3$，$p(s_2|s_1,a_1) = 0.5$。
  $
    p(tau) = 1 times 0.6 times 0.8 times 0.3 times 0.5 = 0.072
  $
  *策略把某动作概率翻倍，轨迹概率按该动作出现次数成倍变化*——取对数后变成逐项相加，这是策略梯度能逐时间步分解的原因。
]

= 6　TD 目标、TD 误差与 SARSA / Q-learning

#chip[复习要点 6]

*所有表格算法的统一形式*：

#eq[$
  Q(s_t,a_t) <- Q(s_t,a_t) + alpha [Y_t - Q(s_t,a_t)], quad delta_t = Y_t - Q(s_t,a_t)
$]

*算法之间的差别几乎全在目标 $Y_t$ 怎么取*。

== DP / MC / TD 三种策略评价

#table(columns: (0.18fr, 1fr, 0.32fr, 0.32fr), table.header([*方法*], [*更新式*], [*要模型?*], [*等回合结束?*]),
  [DP], [$V_(k+1) (s) = r_pi (s) + gamma sum_(s') p_pi (s'|s) V_k (s')$], [需要 $p_pi, r_pi$], [否],
  [MC], [$V(s_t) <- V(s_t) + alpha[G_t - V(s_t)]$], [不需要], [*是*],
  [TD(0)], [$V(s_t) <- V(s_t) + alpha[r_t + gamma V(s_(t+1)) - V(s_t)]$], [不需要], [否],
)

*TD 目标与误差*：

#eq[$
  underbrace(Y_t = r_t + gamma V(s_(t+1)), "TD 目标"), quad
  underbrace(delta_t = r_t + gamma V(s_(t+1)) - V(s_t), "TD 误差")
$]

*为什么可以只用一步*：$G_t = R_t + gamma G_(t+1)$，真正的 $G_(t+1)$ 要等未来全部发生才知道，但已有估计 $V(S_(t+1))$，于是用 $R_t + gamma V(S_(t+1))$ 近似 $G_t$。这就是*自举*：用别的估计值更新当前估计值。

+ $delta_t > 0$：实际比预期好 → 上调 $V(s_t)$。
+ $delta_t < 0$：实际比预期差 → 下调 $V(s_t)$。
+ 只更新*被经历过的状态*；没访问过的状态价值不动。

*MC vs TD*：MC *低偏差、高方差*，必须等完整回合；TD *引入偏差、低方差*，走一步即可更新。

== SARSA vs Q-learning

#table(columns: (0.2fr, 1fr, 1fr), table.header([*算法*], [*TD 目标 $Y_t$*], [*下一动作*]),
  [SARSA], [$r_t + gamma Q(s_(t+1), a_(t+1))$], [$a_(t+1)$ 由*真正执行的行为策略*选出，可能是探索动作],
  [Q-learning], [$r_t + gamma max_(a') Q(s_(t+1), a')$], [不选实际动作，直接取 $max$（假想贪心）],
)

*同策略 on-policy*：行为策略与目标策略*同一个*（$mu = pi$）。SARSA 学的是"我按当前带探索的策略继续走，值多少"。

*异策略 off-policy*：*用行为策略 $mu$ 探索、用另一目标策略 $pi$ 评价与改进*（$mu != pi$）。Q-learning 的行为策略是 ε-greedy，目标策略是纯贪心。

#warn[
  *高频判断*：SARSA 同策略；Q-learning 异策略；DQN 异策略（回放池里是旧策略数据）。Q-learning 的 $max$ 会把估计噪声系统性放大 → *过估计*，这也是 DQN 需要目标网络的原因之一。
]

*Cliff Walking 的直觉*：Q-learning 学出*贴崖的最优路径*（贪心执行时容易掉崖）；SARSA 把探索代价算进目标，学出*绕开的保守路径*。

#ex[TD(0) 一步手算][
  $alpha = 0.1$，$gamma = 1$，$V(s_t) = 0$，$V(s_(t+1)) = 1.9$，$r_t = 0$。
  $
    delta_t = 0 + 1 times 1.9 - 0 = 1.9, quad V(s_t) <- 0 + 0.1 times 1.9 = 0.19
  $
  *先算目标、再算误差、最后乘学习率更新*，三步不能跳。
]

#ex[SARSA 与 Q-learning 同经验对比][
  $Q(s,a) = 3.0$；执行 $a$ 得 $r = 2$，到达 $s'$；$Q(s',a_1) = 5.0$，$Q(s',a_2) = 1.0$；行为策略这次实际选了探索动作 $a_2$。$gamma = 0.9$，$alpha = 0.5$。
  + SARSA：$Y = 2 + 0.9 times 1.0 = 2.9$，$Q <- 3 + 0.5(2.9 - 3) = 2.95$。
  + Q-learning：$Y = 2 + 0.9 times 5.0 = 6.5$，$Q <- 3 + 0.5(6.5 - 3) = 4.75$。
  *同一份经验，Q-learning 更新得更乐观*，因为它假设下一步一定拿到最好的 $a_1$。
]

= 7　Q 表计算专项（最像大题）

#chip[复习要点 8] #chip[复习单点名难点]

== 五步模板

+ *读题建表*：列出所有状态—动作对，写出初值 $Q_0$、$alpha$、$gamma$、$epsilon$。
+ *算目标*：按算法选 $Y_t$：SARSA 用实际 $a_(t+1)$，Q-learning 用 $max_(a') Q(s_(t+1),a')$。
+ *算 TD 误差*：$delta_t = Y_t - Q(s_t,a_t)$。
+ *更新表项*：$Q(s_t,a_t) <- Q(s_t,a_t) + alpha delta_t$；*没被经历的表项保持不变*。
+ *导出策略*：$pi(s) = arg max_a Q(s,a)$；若题目给 $epsilon$，再算动作概率。

== 综合手算

#ex[Q 表综合手算（最像考题）][
  状态 $A,B$；动作 {左, 右}；$gamma = 0.9$，$alpha = 0.5$；初值 $Q(A,"左") = 1$，$Q(A,"右") = 2$，$Q(B,"左") = 3$，$Q(B,"右") = 0.5$。
  采集到经验：在 $A$ 执行"右"，得 $r = +5$，到达 $B$（非终止）。
  + ① 目标：$Y = 5 + 0.9 times max(3, 0.5) = 5 + 2.7 = 7.7$。
  + ② 误差：$delta = 7.7 - 2 = 5.7$。
  + ③ 更新：$Q(A,"右") = 2 + 0.5 times 5.7 = 4.85$；其余表项不变。
  + ④ 新贪心策略：$pi(A) = "右"$（$4.85 > 1$）。
  + ⑤ 若 $epsilon = 0.2$，$|cal(A)| = 2$：$P("右") = 1 - 0.2 + 0.1 = 0.9$，$P("左") = 0.1$。
]

#warn[
  *Q 表计算四个坑*：① 忘记乘 $gamma$；② 把 SARSA 的 $a_(t+1)$ 当成 $max$；③ 更新了未被经历的表项；④ 算概率时把 $epsilon$ 直接当成"非贪心动作概率"。ε 是*进入随机模式的概率*。
]

= 8　DQN：从查表到函数逼近

#chip[复习要点 7]

== Q 表为什么失效

+ *内存爆炸*：CartPole 四维连续状态，每维离散 100 档 → $10^8$ 个状态，两个动作 → 约两亿个 Q 值。
+ *没有泛化能力*：一个状态上的学习无法迁移到相似状态。*这才是本质缺陷*，不只是内存。
+ *离散化太细也不行*：维度灾难；相似状态仍被当成不同格子；离散化误差无法消除。

== DQN 的结构与损失

*核心*：用神经网络 $Q(s,a;theta)$ 近似 Q 表；输入*一个状态*，输出*该状态下所有动作的 Q 值*。

+ *为什么一次输出所有动作*：一次前向即可比较所有动作，避免为每个动作单独跑网络。
+ *输出层为什么不接 Softmax*：Q 值不是概率，不要求非负，也不要求和为 1。
+ *泛化来源*：参数共享——很多状态共用同一套网络参数。

#eq[$
  y_i = r_i + gamma (1 - d_i) max_(a') Q(s_i', a'; theta^-), quad
  L(theta) = frac(1, N) sum_(i=1)^N [y_i - Q(s_i,a_i;theta)]^2
$]
#eq[$
  theta <- theta - alpha nabla_theta L(theta), quad theta^- <- theta quad "每 M 步复制一次"
$]

*TD 损失从哪来*：把 Q-learning 的表格更新目标 $r + gamma max_(a') Q(s',a')$ 当作回归标签，用 MSE 让网络输出靠近它。*更新结构完全一样，只是"改表项"变成"改参数"。*

== 三个不稳定来源与三个对策

#table(columns: (0.42fr, 1fr), table.header([*问题*], [*对策与理由*]),
  [连续样本高度相关，破坏 i.i.d.], [*经验回放*：随机抽 mini-batch，打破时间相关性，并复用昂贵经验],
  [目标值随网络快速变化，像追移动靶], [*目标网络* $theta^-$：隔 $M$ 步才复制，让目标暂时固定],
  [参数共享导致一处更新扰动全局], [小步长 + Huber 损失 + 周期复制，抑制单步冲击],
)

*Huber 损失*：小误差用二次项（梯度平滑），大误差用线性项（抗离群值、防梯度爆炸）。

== DQN 完整训练流程

+ 用 ε-greedy 与环境交互，得到 $(s,a,r,s',d)$，存入回放池。
+ 从回放池随机抽一个 mini-batch。
+ 用目标网络算 $y = r + gamma(1-d) max_(a') Q(s',a';theta^-)$。
+ 用 MSE/Huber 损失对在线网络求梯度并更新 $theta$。
+ 每隔 $M$ 步把 $theta$ 复制给 $theta^-$。
+ 重复；训练后期衰减 $epsilon$。

== DQN 与监督学习、Q-learning 的对比

#table(columns: (0.2fr, 1fr, 1fr), table.header([*项*], [*Q-learning*], [*DQN*]),
  [Q 函数], [Q 表], [神经网络 $Q(s,a;theta)$],
  [状态空间], [小规模离散], [高维或连续],
  [更新], [直接改表项], [反向传播改 $theta$],
  [稳定机制], [通常较简单], [经验回放 + 目标网络],
  [泛化], [弱], [强],
)

#warn[
  *六个高频判断*：① DQN *不是*普通监督学习——目标由网络自己算、随参数移动；② mini-batch 样本*不必*时间连续；③ 目标网络*不是每步更新*；④ DQN 仍是 off-policy；⑤ DQN 仍需要 ε-greedy，网络只给最优估计，探索靠外部随机性；⑥ DQN 不直接用于连续动作，因为 $max_a Q(s,a)$ 在连续动作上不可解。
]

#ex[DQN 一次参数更新][
  目标网络在 $s'$ 输出 $[0.4, 1.2]$；$r = 1$，$d = 0$，$gamma = 0.99$；在线网络 $Q(s,a;theta) = 1.5$，$alpha = 0.01$，$frac(partial Q, partial theta) = 0.2$。
  + ① $y = 1 + 0.99 times 1.2 = 2.188$。
  + ② $delta = y - Q = 0.688$，$L = frac(1,2) delta^2 = 0.2367$。
  + ③ $frac(partial L, partial theta) = -delta frac(partial Q, partial theta) = -0.1376$。
  + ④ $theta <- theta + 0.01 times 0.1376 = theta + 0.001376$。
  *$y > Q$ 时更新使 Q 上升*，方向与表格 Q-learning 一致。
]

= 9　策略学习与 REINFORCE

#chip[复习要点 9] #chip[证明题：对数概率技巧]

== 间接学习 vs 直接学习

+ *值函数方法（间接）*：先学 $Q(s,a)$，再 $a = arg max_a Q(s,a)$ 导出策略。目标清晰、离散动作方便，但不直接输出动作概率，连续动作与随机策略不自然。
+ *策略梯度（直接）*：把策略写成参数化分布 $pi_theta (a|s)$，直接优化长期回报。天然支持随机策略、连续动作和概率化决策。

== 策略的参数化

*Softmax 策略*（离散动作）：网络输出 logits $z_i$，

#eq[$
  pi_theta (a_i|s) = frac(exp(z_i), sum_j exp(z_j)), quad 0 < pi_theta (a_i|s) < 1, quad sum_i pi_theta (a_i|s) = 1
$]

*高斯策略*（连续动作）：$pi_theta (a|s) = cal(N)(mu_theta (s), sigma_theta^2 (s))$，网络输出均值 $mu$ 与标准差 $sigma$（通常输出 $log sigma$ 保证正性）,

#eq[$
  pi_theta (a|s) = frac(1, sqrt(2 pi) sigma_theta (s)) exp(-frac((a - mu_theta (s))^2, 2 sigma_theta^2 (s)))
$]

== 目标函数

#eq[$
  J(theta) = bb(E)_(tau tilde pi_theta) [R(tau)] = sum_tau p_theta (tau) R(tau), quad
  R(tau) = sum_(t=0)^(T-1) gamma^t r_t
$]

因为要*最大化* $J$，参数用*梯度上升*：$theta <- theta + alpha nabla_theta J(theta)$。

== 对数导数技巧

对任意可微正值函数 $f(theta)$：

#eq[$
  nabla_theta log f(theta) = frac(nabla_theta f(theta), f(theta))
  quad -> quad nabla_theta f(theta) = f(theta) nabla_theta log f(theta)
$]

*作用*：把"对分布求导"改写成"对对数概率求导"，从而可以把梯度写成期望、用采样估计。

== 策略梯度完整推导（考试重点）

#eq[$
  nabla_theta J(theta) &= nabla_theta sum_tau p_theta (tau) R(tau) \
  &= sum_tau R(tau) nabla_theta p_theta (tau) \
  &= sum_tau R(tau) p_theta (tau) nabla_theta log p_theta (tau) \
  &= bb(E)_(tau tilde pi_theta) [R(tau) nabla_theta log p_theta (tau)]
$]

注意 $E_(tau tilde pi_theta)$ 的分布本身依赖 $theta$，*不能直接把 $nabla_theta$ 挪进期望*；先把期望写成 $sum_tau p_theta (tau) R(tau)$，再对 $p_theta$ 求导，才是上面这条链。

轨迹对数概率：

#eq[$
  log p_theta (tau) = log rho(s_0) + sum_t log pi_theta (a_t|s_t) + sum_t log p(s_(t+1)|s_t,a_t)
$]

*初始分布项与环境转移项都不含 $theta$，梯度为 0*，所以：

#eq[$
  nabla_theta log p_theta (tau) = sum_t nabla_theta log pi_theta (a_t|s_t)
$]

把整条回报 $R(tau)$ 换成从 $t$ 起的回报 $G_t$（过去奖励与当前动作梯度无关，替换后期望不变、方差更小）：

#eq[$
  nabla_theta J(theta) = bb(E)_(tau tilde pi_theta) [sum_(t=0)^(T-1) G_t nabla_theta log pi_theta (a_t|s_t)]
$]

*REINFORCE 更新式*（一条完整轨迹累加后更新一次）：

#eq[$
  theta <- theta + alpha sum_(t=0)^(T-1) G_t nabla_theta log pi_theta (a_t|s_t)
$]

标准 REINFORCE 是*回合级*更新（逐时间步在线更新只是变体）。

*直观含义*：$G_t$ 为正（结果好）就提高该动作概率；为负就降低。*奖励是评价，不是指令*。

*REINFORCE 算法流程*：输入回合数 $N$、$alpha$、$gamma$，初始化 $theta$；每个回合用 $pi_theta$ 采样完整轨迹 $tau$，从末尾倒推 $G_T=0$、$G_t=r_t+gamma G_(t+1)$，累加 $g=sum_(t=0)^(T-1) G_t nabla_theta log pi_theta (a_t|s_t)$，再更新 $theta <- theta + alpha g$。必须走完整条轨迹才更新一次。

== 方差与 Baseline

*为什么方差大*：① 策略随机性；② 状态转移随机性；③ 奖励随机性；④ 长期累积（轨迹越长方差越大）。

#eq[$
  nabla_theta J = bb(E)_(tau tilde pi_theta) [sum_t (G_t - b(s_t)) nabla_theta log pi_theta (a_t|s_t)]
$]

只要 $b(s_t)$ *与动作无关*，$bb(E)_(a_t tilde pi (dot|s_t)) [b(s_t) nabla log pi] = 0$，所以减它*不改变梯度期望*，却能显著降低方差。最常用 $b(s_t) = V(s_t)$，此时 $G_t - V(s_t)$ 是优势 $A(s,a) = Q(s,a) - V(s,a)$ 的估计。

#ex[REINFORCE 一步更新][
  $z = [1.0, 2.0, 0.5]$ → $pi = [0.231, 0.629, 0.140]$；本次选 $a_2$，$G_t = 4$，$alpha = 0.1$。
  + Softmax 对数梯度：$nabla log pi(a_2) = [ -0.231, 1 - 0.629, -0.140 ] = [-0.231, 0.371, -0.140]$。
  + $Delta z = 0.1 times 4 times [-0.231, 0.371, -0.140] = [-0.0924, 0.1484, -0.0560]$。
  + $z' = [0.908, 2.148, 0.444]$ → $pi' = [0.183, 0.694, 0.123]$。
  *被选中且回报为正的动作概率上升，其余下降*——这就是"成功则强化"。
]

#warn[
  *Softmax 对数梯度速记*：对 logits 求导时，被选动作分量是 $1 - pi(a_t|s)$，未选动作分量是 $-pi(a|s)$。所有分量之和为 0。
]

= 10　Actor-Critic、A2C、A3C 与 PPO

#chip[复习要点 10]

== Actor-Critic 的分工

+ *Actor*（策略网络 $pi_theta (a|s)$）：负责选动作。
+ *Critic*（价值网络 $V_phi (s)$）：负责评价状态。
+ *信号传递*：Critic 用 TD 误差 $delta_t$ 告诉 Actor"这一步比预期好还是差"。

#eq[$
  y_t &= R_t + gamma (1 - d_t) V_phi (S_(t+1)) \
  delta_t &= R_t + gamma (1 - d_t) V_phi (S_(t+1)) - V_phi (S_t) \
  L_"critic" &= frac(1,2)[V_phi (S_t) - "sg"(y_t)]^2 \
  L_"actor" &= -"sg"(delta_t) log pi_theta (a_t|s_t) \
  theta &<- theta + alpha_theta delta_t nabla_theta log pi_theta (a_t|s_t)
$]

#warn[
  *严谨表述*：不能说"TD 误差等于优势"。正确说法是：*在价值函数准确的前提下，TD 误差在给定 $(S_t,A_t)=(s_t,a_t)$ 下的条件期望等于优势函数*，即 $bb(E)[delta_t | S_t = s_t, A_t = a_t] = A^pi (s_t,a_t)$，所以可用 $A_t approx delta_t$。
]

*REINFORCE vs Actor-Critic*：

#eq[$
  "REINFORCE：" theta &<- theta + alpha sum_(t=0)^(T-1) G_t nabla log pi && "（MC，回合级更新，低偏差高方差）" \
  "Actor-Critic：" theta &<- theta + alpha delta_t nabla log pi && "（TD，单步在线更新，引入偏差、降方差）"
$]

== n-step 与 GAE

#eq[$
  G_t^((n)) = sum_(k=0)^(n-1) gamma^k R_(t+k) + gamma^n V_phi (S_(t+n)), quad A_t = G_t^((n)) - V_phi (S_t)
$]
#eq[$
  A_t^("GAE") = sum_(l=0)^(T-t-1) (gamma lambda)^l delta_(t+l), quad delta_t = R_t + gamma V(S_(t+1)) - V(S_t)
$]

递推形式 $A_t = delta_t + gamma lambda A_(t+1)$。$lambda = 0$ 退化为一步 TD（方差小、偏差大）；$lambda = 1$ 退化为 MC（偏差小、方差大）。

== A2C 与 A3C

#table(columns: (0.2fr, 1fr, 1fr), table.header([*项*], [*A2C（同步）*], [*A3C（异步）*]),
  [全称], [Advantage Actor-Critic], [Asynchronous Advantage Actor-Critic],
  [并行单位], [$N$ 个环境共享同一套 $theta, phi$], [$K$ 个 Worker，各有局部参数],
  [更新时机], [等所有环境采完 $n$ 步，汇总后一次更新], [Worker 采完立刻把梯度推给全局网络],
  [参数流动], [一份参数被所有环境共用], [rollout 前 pull，算完 push],
  [优势], [稳定、易实现、易批归一化], [无需等待、CPU 利用率高、梯度多样],
  [代价], [被最慢环境拖住], [参数陈旧、实现复杂],
)

*共同点*：都用 n-step 回报构造优势，总损失带熵正则：

#eq[$
  L = L_"actor" + c_1 L_"critic" - beta H(pi_theta), quad H = -sum_a pi log pi
$]

*熵正则的作用*：鼓励动作分布保持随机性，防止策略过早变成 $[0.999, 0.001]$ 而失去探索。

== PPO：概率比与裁剪

*要解决的问题*：普通策略梯度*知道方向，却规定不了一次能变多大*。步长太小学习慢，太大可能把好策略一次冲垮。PPO 的目标：*让 Actor 的更新既有效，又不要一次变化太大*。

*概率比*：

#eq[$
  rho_t (theta) = frac(pi_theta (a_t|s_t), pi_(theta_"old") (a_t|s_t))
$]

含义：*新策略选该动作的概率是旧策略的多少倍*。$rho_t = 1$ 表示还没变化；$rho_t > 1$ 表示新策略更倾向该动作。*刚采完样、尚未更新时，用同一网络重算必有 $rho_t = 1$*。

*代理目标与裁剪*：

#eq[$
  L^("PG") (theta) = bb(E)_t [rho_t (theta) A_t]
$]
#eq[$
  L^("CLIP") (theta) = bb(E)_t [min(rho_t A_t, "clip"(rho_t, 1 - epsilon.alt_"clip", 1 + epsilon.alt_"clip") A_t)]
$]

#eq[$
  "clip"(rho, 1 - epsilon.alt, 1 + epsilon.alt) =
  mat(1 - epsilon.alt, "若" rho < 1 - epsilon.alt; rho, "若" 1 - epsilon.alt <= rho <= 1 + epsilon.alt; 1 + epsilon.alt, "若" rho > 1 + epsilon.alt, delim: "{")
$]

*为什么取 min*：这是*悲观/保守*目标。只有"改进且尚未越界"才被奖励；一旦越界，梯度为 0，不再给继续变化的动机。

#ex[PPO 裁剪四种情形（$epsilon.alt_"clip" = 0.2$，区间 $[0.8,1.2]$）][
  #table(columns: (0.14fr, 0.14fr, 0.2fr, 0.22fr, 0.3fr), table.header([$A_t$], [$rho_t$], [$rho_t A_t$], [$"clip" A_t$], [*结果与解释*]),
    [$+2$], [$1.5$], [$3.0$], [$1.2 times 2 = 2.4$], [*取 2.4：裁剪*，概率已抬得过高],
    [$+2$], [$0.5$], [$1.0$], [$0.8 times 2 = 1.6$], [*取 1.0：不裁剪*，方向对且未越界],
    [$-2$], [$0.5$], [$-1.0$], [$0.8 times (-2) = -1.6$], [*取 -1.6：裁剪*，概率已压得过低],
    [$-2$], [$1.5$], [$-3.0$], [$1.2 times (-2) = -2.4$], [*取 -3.0：不裁剪*，继续压低是好事],
  )
  *规律*：裁剪只在"更新方向对自己有利、且已经越过 $1 ± epsilon.alt_"clip"$"时生效。
]

*PPO 保持策略稳定的措施*（简答题按点写）：

+ *概率比 + 裁剪*：把单步更新限制在 $1 ± epsilon.alt_"clip"$ 内。
+ *取 min 的保守目标*：越界即零梯度。
+ *冻结旧策略* $theta_"old"$：分母在整个 rollout 内是常数。
+ *一批数据多 epoch + mini-batch*：复用样本，但每轮 rollout 重新采样形成新的 $pi_"old"$。
+ *熵正则* $-beta H$：防止策略过早确定。
+ *Critic 目标 stop-gradient*：避免自举目标随参数漂移。

#warn[
  *PPO 与 DQN 的类比*：DQN 的 $theta^-$ 与 PPO 的 $theta_"old"$ 起同一类作用——*给被优化量提供一个"暂时不动"的参照*。若参照量每步即时更新，裁剪/稳定性约束就失效。
]

= 11　基于模型的强化学习（MBRL）

#chip[复习要点 11]

== 什么是环境模型

*无模型*：只从真实经验直接学 $V\/Q\/pi$，不显式建立环境模型。
*基于模型*：额外学一个环境模型 $M_theta$，用它生成虚拟经验或做规划。*判断标准不是有没有神经网络，而是算法是否显式建立并利用环境变化模型*。

#eq[$
  M_theta: (s_t,a_t) -> (s_(t+1), r_t, d_t), quad
  hat(s)_(t+1) = f_theta (s_t,a_t) approx f_"true" (s_t,a_t)
$]

#table(columns: (0.2fr, 1fr, 1fr), table.header([*对比项*], [*Model-Free*], [*Model-Based*]),
  [学什么], [$V\/Q\/pi$ 本身], [环境模型，再在其上规划或造经验],
  [样本效率], [低], [*高*：虚拟经验可反复用],
  [误差来源], [估计误差（方差）], [*模型偏差 + 误差累积*],
  [理论保证], [较完整], [受模型质量限制],
  [代表], [Q-learning、DQN、PPO], [Dyna、残差动力学、MB-PPO],
)

*为什么需要模型*：真实机器人每次交互都有时间、电能、磨损成本；MBRL 用*更多内部计算换取更少真实交互*，提高真实环境样本效率。

*环境模型学习与系统辨识*：都从输入—输出数据估计动力学；但系统辨识关心"预测准不准"，MBRL 最终关心"模型能否支持正确的长期决策"。

*与监督学习的关系*：模型学习子问题本身是监督学习（输入 $(s,a)$，标签 $s'$ 或 $r$）；整个系统仍是 RL。*RL 系统内部可以包含一个监督学习模块*。

#tip[
  *策略变化带来的分布偏移*：模型训练数据由旧策略产生；策略更新后会访问新状态，模型在那些区域没有数据，预测不可信。对策：持续用新策略数据更新模型、用 ensemble 估计不确定性、限制模型使用范围。
]

== 残差动力学模型

真实动力学 = 已知名义模型 + 未知残差：

#eq[$
  delta_t^"dyn" = s_(t+1) - f_0 (s_t,a_t), quad
  hat(delta)_t^"dyn" = g_theta (s_t,a_t), quad
  hat(s)_(t+1) = f_0 (s_t,a_t) + g_theta (s_t,a_t)
$]

*为什么更容易学*：残差通常数值更小、复杂度更低、变化更平滑、物理意义更集中。网络只需学"名义模型没解释掉的那部分"，不必重新学整个动力学。

*增量残差形式*：$Delta s_t = s_(t+1) - s_t$，名义模型预测 $Delta s_t^0$，学 $delta_t = Delta s_t - Delta s_t^0$，则 $hat(s)_(t+1) = s_t + Delta s_t^0 + g_theta (s_t,a_t)$。

*概率残差与 Ensemble*：$delta_t tilde cal(N)(mu_theta (s_t,a_t), Sigma_theta (s_t,a_t))$；或用 $K$ 个模型取均值，*模型间分歧*表示认知不确定性，可直接作为内在奖励。

== 误差传播：为什么一步准不代表多步准

*一步估计误差*：

#eq[$
  e_t = hat(s)_t - s_t
$]

对模型做一阶 Taylor 展开：

#eq[$
  e_(t+1) &= f_theta (hat(s)_t,a_t) - f(s_t,a_t) \
  &= [f_theta (hat(s)_t,a_t) - f(hat(s)_t,a_t)] + [f(hat(s)_t,a_t) - f(s_t,a_t)] \
  &approx underbrace(epsilon_t, "本步新产生的模型误差") + underbrace(J_t e_t, "旧误差继续传播")
$]

其中 $J_t = frac(partial f_theta (s,a_t), partial s)$ 是雅可比矩阵，决定旧误差被放大还是收缩。

*多步展开*：$e_(t+2) approx J_(t+1) J_t e_t + J_(t+1) epsilon_t + epsilon_(t+1)$。越早产生的误差经历越多次传播。

*Lipschitz 上界*：若 $norm(f_theta (s_1,a) - f_theta (s_2,a)) <= L norm(s_1 - s_2)$，且一步误差 $norm(epsilon_t) <= epsilon$，则

#eq[$
  norm(e_(t+H)) <= epsilon frac(L^H - 1, L - 1) quad (L != 1)
$]

+ $L < 1$：误差*有界*，长期预测可靠。
+ $L = 1$：误差*线性增长* $H epsilon$。
+ $L > 1$：误差*指数放大*，一步很准也可能规划出大错。

*误差传播链*：状态误差 → 奖励误差（$|Delta r| <= L_r norm(e)$）→ 累计回报误差（$|Delta J_H| <= L_r sum_k gamma^k norm(e_(t+k))$）→ 价值函数误差。

== 动作选择为什么可能突然翻转

规划器比较 $Q$ 值选动作。设最优与次优动作的真实价值间隔为

#eq[$
  Delta_Q (s) = Q(s,a^*) - max_(a != a^*) Q(s,a)
$]

若 $max_a |hat(Q)(s,a) - Q(s,a)| < Delta_Q (s)/2$，动作排序不变；*一旦误差超过这个尺度，最优动作可能直接翻转*。两个动作价值越接近，一点小误差就越容易改变决策。

== Model Exploitation：规划器主动放大模型误差

规划器不是随机用模型，而是在模型中找"最优"动作：

#eq[$
  a^* = arg max_(a_(0:H-1)) hat(J)(a_(0:H-1)), quad hat(J) = J + eta
$]

即使平均误差 $bb(E)[eta] = 0$，*被选中的动作序列也更容易对应 $eta > 0$ 的区域*——模型高估的动作更容易被选中，低估的不会。所以 MBRL 的误差不是被动传播，而可能被优化器主动筛选和放大。

#ex[Model Exploitation 数值例][
  真实回报 $J(a_1) = 10, J(a_2) = 9, J(a_3) = 8$（应选 $a_1$）；模型估计 $hat(J)(a_1) = 9.8, hat(J)(a_2) = 9.1, hat(J)(a_3) = 12$。规划器选 $a_3$——真实最差的动作。*平均预测误差小，不能保证最优规划结果可靠。*
]

== MBRL 六步闭环与优缺点

+ 真实交互采集 $(s_t,a_t,r_t,s_(t+1))$。
+ 学习环境模型。
+ 模型生成虚拟经验/轨迹。
+ 训练价值函数 $V$ 或 $Q$。
+ 优化策略 $pi$。
+ 新策略回到真实环境采集新数据，重新优化模型。

#tip[
  *优点/作用*：样本效率高；可预演与规划；能给罕见状态造数据；提供不确定性来源。
  *局限*：误差累积；模型被利用；高维观测/复杂动力学难建模；*平均预测误差小 ≠ 控制效果好*。
]

= 12　探索机制与内在奖励

#chip[复习要点 12 + 13]

== 探索—利用权衡

+ *利用*：用当前知识选预计回报最高的动作。
+ *探索*：主动尝试尚未充分了解的动作/状态，用短期收益换信息。
+ *只利用*：可能长期错过真正最优动作（早期估计来自少量样本）。
+ *只探索*：反复选已确认较差的动作，浪费样本。
+ *后悔值*：$cal(R)_T = T q^* - bb(E)[sum_(t=1)^T R_t]$，衡量"如果一开始就知道最优动作，会少拿多少"；$q^*$ 是最优动作的期望奖励。

*为什么主动 RL 必须探索*：最优动作可能从未被尝试；不探索就永远得不到"它更好"的数据。*为什么被动 RL 没有这个问题*：策略固定，只需评价，不需要改进动作选择。

== ε-greedy（必须会算）

#eq[$
  a_t = mat("随机选一个动作", "概率" epsilon; arg max_a Q(s_t,a), "概率" 1 - epsilon, delim: "{")
$]

*关键*：$epsilon$ 是"*进入随机模式的概率*"，不是"选某个非贪心动作的概率"。$|cal(A)|$ 个动作时：

#eq[$
  P("贪心动作") = 1 - epsilon + frac(epsilon, |cal(A)|), quad
  P("某个非贪心动作") = frac(epsilon, |cal(A)|), quad
  P("非贪心合计") = epsilon (1 - frac(1, |cal(A)|))
$]

#ex[ε-greedy 概率计算][
  四个动作价值 $Q = 8.0, 3.0, 5.0, 2.0$，贪心为"向上"（8.0），$epsilon = 0.2$。
  $
    P("向上") = 1 - 0.2 + 0.2/4 = 0.85, quad P("其余每个") = 0.2/4 = 0.05
  $
  检查：$0.85 + 3 times 0.05 = 1$。
]

*衰减*：$epsilon_t = max(epsilon_"min", epsilon_0 lambda^t)$。衰减过快过早停止探索，容易陷入次优；衰减过慢训练后期仍有大量无意义随机动作。*训练时通常不让 $epsilon$ 变成 0*，保留最低探索率以应对估计误差和环境变化。

*局限*：一视同仁——试过 1000 次已确认较差的动作和只试过 1 次的动作获得同样的探索机会；它不回答"哪个未知动作最值得试"。

== 乐观初始化

把未知动作初值设高（如真实奖励在 $[0,1]$，初值设 5）。贪心会先试未知动作，真实数据把它修正下来，于是自然转向其他未试动作。*链条：未知 → 乐观估计 → 主动尝试 → 数据修正*。局限：深度 RL 中难以对所有未见状态—动作维持合理乐观值；奖励尺度未知时难设初值。

== UCB / LCB

#eq[$
  a_t = arg max_a underbrace(Q_t (a), "利用项") + underbrace(c sqrt(frac(ln t, N_t (a))), "探索项")
$]

$t$ 是已选总次数，$N_t (a)$ 是动作 $a$ 被选次数。$N_t (a)$ 越小，探索项越大；随着反复尝试，探索项逐渐下降。$c = 0$ 退化为纯贪心；$c$ 越大越偏向探索。

*LCB*：把加号换成减号，$Q_t (a) - c sqrt(ln t / N_t (a))$，取"下界里最好的"，是*悲观/保守*准则，常用于基于模型与鲁棒规划。

#ex[UCB / LCB 计算][
  $t = 100$，$ln 100 = 4.605$，$c = 1$；$(Q,N) = (0.9,50), (0.8,10), (0.6,2)$。
  #table(columns: (0.2fr, 0.35fr, 0.35fr, 0.35fr), table.header([*动作*], [*探索项*], [*UCB*], [*LCB*]),
    [$a_1$], [$sqrt(4.605/50) = 0.304$], [$1.203$], [$0.597$],
    [$a_2$], [$sqrt(4.605/10) = 0.679$], [$1.479$], [$0.121$],
    [$a_3$], [$sqrt(4.605/2) = 1.517$], [$2.117$], [$-0.917$],
  )
  *UCB 选 $a_3$*（访问最少、不确定性最大）；*LCB 选 $a_1$*（下界最高、最稳）；纯贪心选 $a_1$。
]

== Thompson Sampling

*伯努利奖励*：$R_t tilde "Bernoulli"(theta_a)$，$bb(E)[R_t|theta_a] = theta_a$。用 Beta 分布做共轭先验：

#eq[$
  theta | D tilde "Beta"(alpha_0 + S, beta_0 + F), quad
  bb(E)[theta] = frac(alpha, alpha+beta), quad
  "Var"(theta) = frac(alpha beta, (alpha+beta)^2 (alpha+beta+1))
$]

*更新规则*：成功 $alpha <- alpha + 1$，失败 $beta <- beta + 1$。

*算法*：① 每个动作初始化 $"Beta"(1,1)$；② 对每个动作从后验*各采一个样本* $tilde(theta)_a$；③ 选 $tilde(theta)_a$ 最大的动作；④ 执行、观察真实奖励；⑤ 更新所选动作的 $alpha$ 或 $beta$；⑥ 重复。

#ex[两台老虎机][
  A：10 次 7 成 3 败 → $"Beta"(8,4)$，$bb(E) = 0.667$，$"Var" = 0.0171$。
  B：5 次 4 成 1 败 → $"Beta"(5,2)$，$bb(E) = 0.714$，$"Var" = 0.0255$。
  按均值该选 B；但某次采样 $tilde(theta)_A = 0.72 > tilde(theta)_B = 0.61$，*本轮选 A*。B 方差大，所以它偶尔会被选中——这就是自动探索。若本轮选 B 且成功，$"Beta"(6,2)$，均值 0.75；若失败，$"Beta"(5,3)$，均值 0.625。
]

*为什么能自动平衡*：后验均值高的动作更容易胜出（利用）；后验分布宽的动作仍有机会采到高值（探索）；数据积累使后验逐渐集中，探索自动减少。

== 四种探索方法对比

#table(columns: (0.2fr, 1fr, 1fr), table.header([*方法*], [*核心思想*], [*特点/局限*]),
  [ε-greedy], [以固定概率随机试], [简单；不区分不确定性程度；需退火],
  [乐观初始化], [初值高估，靠贪心去试], [直观；深度 RL 难设定；依赖奖励尺度],
  [UCB/LCB], [价值 ± 置信界], [显式利用不确定性；需计数；$c$ 要调],
  [Thompson], [从后验采样再贪心], [贝叶斯解释清晰；探索随数据自动减少],
)

== 外在奖励与内在奖励

+ *外在奖励* $r_t^"ext"$：任务定义，如到达 +100、碰撞 -10、每步 -0.01。
+ *内在奖励* $r_t^"int"$：算法根据新颖性、预测误差、不确定性、信息增益构造。
+ *总奖励*：$r_t = r_t^"ext" + beta r_t^"int"$，$beta$ 控制内在奖励强度。

*为什么稀疏奖励需要内在奖励*：50×50 迷宫只有终点给 1，失败轨迹 500 步全是 0；仅靠外在奖励无法区分"发现新走廊"和"原地绕圈"。内在奖励提供方向性更强的学习信号。

== 五种典型内在奖励

#eq[$
  "① 计数型：" &r_t^"int" = frac(eta, sqrt(N_t (s_(t+1)) + 1)) \
  "② 预测误差：" &r_t^"int" = eta norm(s_(t+1) - hat(s)_(t+1))^2 \
  "③ ICM：" &r_t^"int" = eta norm(phi(s_(t+1)) - f(phi(s_t),a_t))^2 \
  "④ RND：" &r_t^"int" = eta norm(f_"pred" (s_t) - f_"target" (s_t))^2 \
  "⑤ 信息增益：" &"IG" = D_"KL" (p(theta|D,o) parallel p(theta|D))
$]

+ *计数型*：访问越少奖励越大；连续状态不能直接计数，需要离散化、聚类、哈希或伪计数。
+ *预测误差*：模型预测不准 → 值得探索；但随机噪声会导致误差永远高。
+ *ICM*：在*特征空间*预测下一状态特征，避免像素噪声；经典形式还带逆向模型。
+ *RND*：用固定随机网络做"状态指纹"，预测网络拟合它；新状态误差大。
+ *信息增益*：选择能最大程度减少环境不确定性的动作；理论清晰但计算复杂。
+ *Ensemble 分歧*：$U_t = frac(1,K) sum_k norm(hat(s)_(t+1)^((k)) - bar(s)_(t+1))^2$，$r_t^"int" = eta U_t$；模型间分歧表示认知不确定性。

== Noisy-TV 与奖励错位

#warn[
  *Noisy-TV*：机器人旁边有随机闪烁的电视。若用原始像素预测误差作内在奖励，电视画面永远预测不准 → 内在奖励恒高 → 智能体盯着电视看。*本质：不可预测 ≠ 值得学习*。对策：在特征空间预测（ICM/RND）、使用学习进度 $"LP"_t = e_(t-k) - e_t$（误差是否在下降）、用集成分歧而非原始误差。
]

#warn[
  *奖励错位*：$beta$ 太大 → 智能体把"寻找新颖状态"当最终目的，甚至学会"不结束任务"以持续获得内在奖励。*对策*：减小 $beta$；衰减 $beta_t = beta_0 e^(-k t)$；归一化内在奖励；分开估计 $V^"ext"$ 与 $V^"int"$，只用外在价值决定终止。*原则：内在奖励不能反客为主。*
]

*熵奖励 ≠ 内在奖励*：熵奖励让*动作分布*保持随机；内在奖励让*状态*被真正访问。讲义原话：*策略随机性 ≠ 有效状态空间探索*。

*Episodic vs Lifelong Novelty*：前者在单回合内计数，鼓励单次任务覆盖更多区域；后者在整个训练历史中计数，鼓励长期发现新状态。

== 如何评价探索算法

+ *任务性能*：外在奖励、成功率、最终路径质量。
+ *探索效率*：状态覆盖率、新状态发现速度、信息增益。
+ *样本效率*：达到某性能需要多少真实交互。
+ *鲁棒性*：不同随机种子、地图、参数下是否稳定。
+ *必须分开报告* $R_"ext"$、$R_"int"$、$R_"total"$；总奖励高不等于任务表现好。
+ 至少用 5 个随机种子，报告均值 $plus.minus$ 标准差，不能拿一次成功证明算法有效。

= 13　大模型 × 强化学习（通用版）

#chip[复习要点 14]

*两条路线*：

+ *大模型作为策略/组件*：LLM/VLM 提供语义理解、常识先验、动作先验或奖励信号；RL 负责长期回报优化与试错。
+ *大模型作为被优化对象*：RLHF / PPO / GRPO / DPO 直接优化语言模型的生成策略。

*RLHF 三阶段*：

+ *SFT*：用人工示范做监督微调。
+ *奖励模型*：用人类偏好比较训练打分器，输出标量奖励。
+ *RL 优化*：用 PPO/GRPO 最大化奖励，同时加 KL 约束防止偏离参考模型太远。

*PPO vs GRPO*：PPO 需要 Critic 估计优势；GRPO 对同一问题采样一组回答，用组内相对得分构造优势，*省掉 Critic*。

*DPO*：直接用偏好对优化策略，不显式训练奖励模型、不做在线采样，属于偏好优化，介于监督学习与 RL 之间。

*设计一个“大模型 + RL”任务的六步模板*：

+ *任务与观测*：环境是什么？观测 $o_t$ 包含什么？为什么需要语义先验或长期决策？
+ *动作空间*：让大模型输出*高层、离散*动作（目标、指令、选项），底层连续控制交给控制器/规划器。
+ *奖励设计*：写成可加形式：任务进度 + 重复惩罚 + 风险/代价项，并说明每一项为什么这样设。
+ *大模型的角色*（三选一或组合）：a. 表征器（编码状态）；b. 先验/教师（给动作先验或 logits）；c. 奖励设计者（把偏好/指令转成奖励）。
+ *RL 的角色*：用 PPO/GRPO/Actor-Critic 优化长期回报；说明为什么不能只靠大模型（它不知道自己决策的长期后果，缺少试错）。
+ *耦合与评价*：先验权重退火、KL/一致性约束防崩溃；给出基线、消融、指标、多随机种子均值 ± 标准差。

#warn[
  *范围提醒*：第八讲的 VLA / 图强化学习具体架构不考。若题目问“大模型与 RL 的通用关系”，按 RLHF 三阶段 + 上述六步模板回答即可；不要展开 VLA 的图节点特征、frontier 等细节。
]

= 14　公式速查与高频判断

== 全篇更新式速查

#table(columns: (0.3fr, 1.15fr, 0.3fr), table.header([*算法*], [*公式*], [*见*]),
  [回报], [$G_t = R_t + gamma G_(t+1)$], [§1],
  [价值], [$V^pi (s) = bb(E)_pi [G_t|S_t=s]$, $Q^pi (s,a) = bb(E)_pi [G_t|S_t=s,A_t=a]$], [§1],
  [贝尔曼], [$bold(v) = (bold(I) - gamma bold(P))^(-1) bold(r)$], [§4],
  [MC], [$V(s_t) <- V(s_t) + alpha[G_t - V(s_t)]$], [§6],
  [TD(0)], [$V(s_t) <- V(s_t) + alpha[r_t + gamma V(s_(t+1)) - V(s_t)]$], [§6],
  [SARSA], [$Q <- Q + alpha[r + gamma Q(s',a') - Q]$], [§6],
  [Q-learning], [$Q <- Q + alpha[r + gamma max_(a') Q(s',a') - Q]$], [§6],
  [策略改进], [$pi'(s) = arg max_a Q^pi (s,a)$], [§6],
  [值迭代], [$V_(k+1) (s) = max_a [R(s,a) + gamma sum_(s') p(s'|s,a) V_k (s')]$], [§4],
  [DQN 目标], [$y = r + gamma(1-d) max_(a') Q(s',a';theta^-)$], [§8],
  [策略梯度], [$theta <- theta + alpha sum_t G_t nabla log pi_theta (a_t|s_t)$], [§9],
  [Actor-Critic], [$theta <- theta + alpha delta_t nabla log pi$], [§10],
  [GAE], [$A_t = sum_l (gamma lambda)^l delta_(t+l)$], [§10],
  [PPO], [$bb(E)_t [min(rho_t A_t, "clip"(rho_t,1 plus.minus epsilon.alt) A_t)]$], [§10],
  [残差模型], [$hat(s)' = f_0 (s,a) + g_theta (s,a)$], [§11],
  [UCB/LCB], [$Q_t (a) plus.minus c sqrt(ln t / N_t (a))$], [§12],
  [Thompson], [$alpha <- alpha + 1$（成功），$beta <- beta + 1$（失败）], [§12],
  [内在奖励], [$r_t = r_t^"ext" + beta r_t^"int"$], [§12],
)

== 高频判断 / 选择 20 条

+ 奖励是*即时*信号；回报是*累积*量。
+ $V$ 评价状态，$Q$ 评价状态—动作对；决策看 $Q$。
+ 价值函数是*期望*，一次探索结果不改变期望本身。
+ 转移矩阵*每行和为 1*，$0 <= P_(i j) <= 1$。
+ $gamma = 0$ 短视；$gamma -> 1$ 远视且可能发散。
+ MC *必须等完整回合*；TD *一步即可*。
+ TD 目标 $r + gamma V(s')$ 是*自举*估计，不是真实回报。
+ SARSA *同策略*；Q-learning *异策略*；DQN *异策略*。
+ DQN 输出层*不接 Softmax*：Q 值不是概率。
+ 经验回放解决*样本相关性*；目标网络解决*目标移动*。
+ 目标网络*不是每步更新*；否则目标与预测同源。
+ DQN 仍需要 ε-greedy；网络只给最优估计，探索靠外部随机性。
+ DQN 不直接用于连续动作，因为 $max_a Q(s,a)$ 不可解。
+ REINFORCE 是*蒙特卡洛*策略梯度，方差大，需要 baseline。
+ Baseline 必须*与动作无关*，否则改变梯度期望。
+ TD 误差*不等于*优势，只在价值准确时条件期望相等。
+ PPO 的 $rho_t = 1$ 表示新旧策略*此刻相同*。
+ PPO 裁剪只在“方向有利且越过 $1 plus.minus epsilon.alt$”时生效。
+ 一步预测准 ≠ 长期规划准；平均误差小 ≠ 控制效果好。
+ 内在奖励过强 → 奖励错位；熵奖励 ≠ 状态空间探索。

#tip[
  *最后 10 分钟背什么*：① 贝尔曼期望/最优方程与矩阵形式；② TD 目标/误差；③ SARSA 与 Q-learning 的目标差异；④ DQN 两个稳定机制；⑤ 策略梯度四行推导；⑥ PPO 的 $rho_t$ 与 clip；⑦ MBRL 误差传播 $e_(t+1) approx J_t e_t + epsilon_t$；⑧ UCB/Thompson 公式；⑨ 内在奖励五种形式；⑩ RLHF 三阶段。
]

]
