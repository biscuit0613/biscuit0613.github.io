// ==================================================================
//  强化学习 · 练习题题解（一、二）
//  记号与博客 RL 系列一致：大写随机变量、小写取值；
//  p(s'|s,a) 为转移概率，矩阵记 bold(P)；期望记 bb(E)
// ==================================================================

#let accent = rgb("#1f3a5f")
#let accent2 = rgb("#3b6ea5")
#let pale = rgb("#eef3f9")
#let f-eq = rgb("#eef6fb")
#let s-eq = rgb("#a9cce3")

#set document(title: "强化学习 · 练习题题解")
#set page(paper: "a4", margin: (x: 6mm, y: 6mm, top: 7mm), header: none, footer: none)
#set text(font: ("Noto Sans CJK SC", "DejaVu Sans"), size: 7.3pt, lang: "zh", region: "cn")
#set par(justify: false, leading: 0.42em, spacing: 0.45em)
#set list(indent: 0.9em, spacing: 0.4em)
#set enum(indent: 0.9em, spacing: 0.4em)
#set table(stroke: 0.3pt + rgb("#c8d6e5"), inset: 2pt, fill: (x, y) => if y == 0 { rgb("#d6eaf8") } else { white })
#set heading(numbering: none)

#let section(title) = block(
  width: 100%,
  fill: accent,
  inset: (x: 4pt, y: 2.2pt),
  radius: 1.5pt,
  above: 5pt,
  below: 2pt,
  text(fill: white, weight: "bold", size: 8.2pt)[#title],
)
#let qa(id, title, body) = block(
  width: 100%,
  breakable: true,
  stroke: (left: 2pt + accent2, rest: 0.4pt + rgb("#c8d6e5")),
  radius: 2pt,
  inset: (x: 4pt, y: 3pt),
  above: 4pt,
  below: 1pt,
  [
    #grid(
      columns: (auto, 1fr),
      column-gutter: 4pt,
      align: horizon,
      box(fill: accent2, inset: (x: 3pt, y: 0.8pt), radius: 1.5pt,
          text(fill: white, weight: "bold", size: 7pt)[#id]),
      text(weight: "bold", size: 7.6pt, fill: accent)[#title],
    )
    #v(1.4pt)
    #body
  ],
)
#let q(body) = block(width: 100%, fill: rgb("#f4f7fb"), inset: (x: 3pt, y: 1.8pt), radius: 1.2pt, [*问｜*#body])
#let opts(body) = block(width: 100%, fill: rgb("#f8f9f9"), inset: (x: 3pt, y: 1.6pt), radius: 1.2pt, stroke: 0.3pt + rgb("#d5dbdb"), body)
#let ans(body) = box(fill: rgb("#e8f6ef"), inset: (x: 3pt, y: 0.8pt), radius: 1.2pt, text(weight: "bold", fill: rgb("#1e8449"))[答案｜#body])
#let src(body) = text(size: 6.2pt, fill: luma(100))[#body]
#let tag(body) = box(fill: luma(235), inset: (x: 2.2pt, y: 0.4pt), radius: 1.2pt, text(size: 6.1pt, fill: luma(70))[#body])
#let eq(body) = block(width: 100%, fill: f-eq, inset: (x: 3pt, y: 1.6pt), radius: 1.2pt, stroke: 0.3pt + s-eq, body)
#let key(body) = text(weight: "bold", fill: rgb("#7d3c98"), body)
#let warn(body) = block(width: 100%, fill: rgb("#fdedec"), inset: (x: 3pt, y: 1.8pt), radius: 1.2pt, stroke: 0.3pt + rgb("#e6b0aa"), body)

#align(center)[
  #text(12.5pt, weight: "bold", fill: accent)[强化学习 · 练习题题解]
  #v(0.4pt)
  #text(6.9pt, fill: luma(90))[练习题（一）10 题 + 练习题（二）9 题 · 选择/判断/简答全解 · 记号与博客一致]
]
#v(1.5pt)

#block(width: 100%, fill: pale, stroke: 0.4pt + accent2, radius: 2pt, inset: 4pt, [
  #text(weight: "bold", fill: accent)[记号约定]：$S_t, A_t, R_t$ 是随机变量，$s_t, a_t, r_t$ 是其具体取值；$G_t = R_t + gamma G_(t+1)$。转移概率记 $p(s'|s,a)$，矩阵记 $bold(P)$；奖励函数记 $R(s,a)$。期望统一写 $bb(E)$。PPO 概率比统一写 $rho_t$；博客 PPO 篇记 $r_t (theta)$，这里改名以免与奖励混淆。模型误差用 $epsilon_t$；ε-greedy 探索率也用 $epsilon$，PPO 裁剪半径用 $epsilon.alt$。
])
#v(1.5pt)

#block(width: 100%, fill: rgb("#fef9e7"), stroke: 0.4pt + rgb("#f1c40f"), radius: 2pt, inset: 4pt, [
  #text(weight: "bold", fill: rgb("#9a7d0a"))[答案速查（练习题一）]：
  #table(columns: (0.55fr, 1fr, 1fr, 1fr, 1fr, 1fr), table.header([*题号*], [1], [2], [3], [4], [5]),
    [*答案*], [A], [B], [B], [B、C、D], [D],
  )
  #v(1pt)
  #table(columns: (0.55fr, 1fr, 1fr, 1fr, 1fr, 1fr), table.header([*题号*], [6], [7], [8], [9], [10]),
    [*答案*], [A], [D], [A], [正确], [错误],
  )
])
#v(1.5pt)

#columns(2, gutter: 4mm)[

#section[练习题（一）　选择与判断]

#qa("1", "DQN 中经验回放的主要目的", [
  #tag[选择]
  #q[引入 Experience Replay 的主要目的是什么？]
  #opts[
    A. 降低连续样本之间的时间相关性，并提高历史经验的利用率\
    B. 让智能体只使用最新的交互样本进行学习\
    C. 用经验池代替目标网络计算 Bellman Target\
    D. 保证每个 Mini-batch 都是一段完整连续轨迹
  ]
  #ans[A]
  + 在线采样得到的相邻 transition $(s_t,a_t,r_t,s_(t+1))$ 高度相关，破坏随机梯度下降的 i.i.d. 假设。经验回放把历史 transition 存入池 $cal(D)$，训练时*均匀随机抽 mini-batch*，从而打破时间相关性。
  + 同一条经验可以被反复使用，提高昂贵交互数据的利用率。DQN 损失为
    #eq[$L(theta) = bb(E)_((s,a,r,s') tilde cal(D)) [(y - Q(s,a;theta))^2], quad y = r + gamma (1-d) max_(a') Q(s',a';theta^-)$]
    期望是对回放池 $cal(D)$ 取的，而不是对当前轨迹取的；DQN 是 off-policy，所以旧策略的数据仍然有效。
  + B 错：回放不是只用最新样本；C 错：回放池负责存数据，TD 目标由目标网络算；D 错：mini-batch 是随机打散的，不要求是完整连续轨迹。
  #src[练习题（一）1；博客《DQN》]
])

#qa("2", "DQN 中目标网络的主要作用", [
  #tag[选择]
  #q[Target Network 的主要作用是什么？]
  #opts[
    A. 把离散动作空间转换成连续动作空间\
    B. 提供相对稳定的 TD 目标，减少训练目标随在线网络快速变化\
    C. 保存智能体过去的所有状态转移\
    D. 负责执行 ε-greedy 动作探索
  ]
  #ans[B]
  + 若目标和预测共用同一套参数 $theta$，每次梯度更新都会同时移动回归目标，形成"追移动靶"，容易震荡甚至发散。目标网络用延迟参数 $theta^-$ 计算目标：
    #eq[$Y_t = R_t + gamma (1-d_t) max_(a') Q(S_(t+1),a';theta^-)$]
  + $theta^-$ 每隔 $M$ 步从在线网络复制一次（或做 Polyak 软更新），在一个更新周期内把目标暂时固定，降低目标方差。
  + A 错：目标网络不改变动作空间；C 错：存 transition 的是 replay buffer；D 错：探索由行为策略（如 ε-greedy）负责。
  #src[练习题（一）2；博客《DQN》]
])

#qa("3", "REINFORCE 中 $G_t nabla_theta log pi_theta$ 的含义", [
  #tag[选择]
  #q[项 $G_t nabla_theta log pi_theta (a_t|s_t)$ 最合理的解释是什么？]
  #opts[
    A. 两者的乘积只用于估计环境状态转移概率\
    B. $G_t$ 评价当前动作之后的结果好坏，对数策略梯度给出改变该动作概率的参数方向\
    C. $G_t$ 决定动作概率，策略对数梯度决定环境奖励\
    D. $G_t$ 用于训练 Critic，而对数策略梯度只用于计算状态价值
  ]
  #ans[B]
  + 策略梯度定理：
    #eq[$nabla_theta J(theta) = bb(E)_(tau tilde pi_theta) [sum_t G_t nabla_theta log pi_theta (a_t|s_t)]$]
    其中 $G_t$ 是回报，作为 $Q^pi (s_t,a_t)$ 的单样本估计，评价“在 $s_t$ 选 $a_t$ 之后结果好不好”；$nabla_theta log pi_theta (a_t|s_t)$ 是提高该动作概率的参数方向。两者相乘就是“方向 × 权重”。
  + $G_t > 0$ 时提高该动作概率，$G_t < 0$ 时降低；幅度随 $|G_t|$ 增大。
  + A 错：与转移概率估计无关；C 错：奖励由环境给出，不由梯度决定；D 错：REINFORCE 没有 Critic 和价值网络。
  #src[练习题（一）3；博客《策略学习》]
])

#qa("4", "Baseline 与 Advantage 的正误判断", [
  #tag[多选]
  #q[关于策略梯度中的 Baseline 和 Advantage，下列哪些说法正确？请选择所有正确项。]
  #opts[
    A. Baseline 必须依赖当前动作 $a$，否则无法降低方差\
    B. 状态价值 $V^pi (s)$ 可以作为不依赖当前动作的 Baseline\
    C. 优势函数可写为 $A^pi (s,a) = Q^pi (s,a) - V^pi (s)$\
    D. 减去合适的 Baseline 可以在不改变期望策略梯度的情况下降低梯度估计方差
  ]
  #ans[B、C、D]
  + 基线 $b(s)$ 必须*与动作 $a$ 无关*。因为
    #eq[$bb(E)_(a tilde pi_theta (dot|s)) [b(s) nabla_theta log pi_theta (a|s)] = b(s) nabla_theta sum_a pi_theta (a|s) = b(s) nabla_theta 1 = 0$]
    所以减去它不改变梯度期望，却能降低方差。A 正好说反了。
  + B 正确：$V^pi (s)$ 只依赖状态，是标准基线。C 是优势函数定义。D 正确：合适的基线在无偏前提下降方差。
  + 常用估计：$G_t - V^pi (s_t)$（MC 优势）、$delta_t$（TD 优势）或 GAE。
  #src[练习题（一）4；博客《Actor-Critic》]
])

#qa("5", "Actor-Critic 中 Critic 学习什么", [
  #tag[选择]
  #q[在典型的 Actor-Critic、A2C、A3C 和 PPO 中，Critic 网络最主要学习什么？]
  #opts[
    A. 每个动作被选择的概率 $pi(a|s)$\
    B. 环境的完整状态转移概率 $p(s'|s,a)$\
    C. 旧策略与新策略之间的概率比\
    D. 当前策略下的状态价值 $V^pi (s)$
  ]
  #ans[D]
  + Critic 学习当前策略下的价值函数（通常是 $V^pi (s)$，也可用 $Q^pi (s,a)$），为 Actor 提供基线或优势。TD 形式：
    #eq[$delta_t = R_t + gamma V_phi (S_(t+1)) - V_phi (S_t), quad L_"critic" = bb(E)[delta_t^2]$]
  + A 是 Actor 的输出；B 是环境模型（MBRL 才显式学）；C 是 PPO 用旧策略概率算出来的比值，不是 Critic 的学习目标。
  #src[练习题（一）5；博客《Actor-Critic》《PPO》]
])

#qa("6", "A2C 的参数更新方式", [
  #tag[选择]
  #q[A2C 中有多个并行环境时，最典型的参数更新方式是什么？]
  #opts[
    A. 多个环境完成一批 Rollout 后汇总样本或梯度，再进行同步批量更新\
    B. 每个 Worker 完成局部采样后立即独立修改全局参数\
    C. 每个环境长期维护完全独立且互不共享的 Actor\
    D. 必须把所有历史经验长期保存到 ReplayBuffer 中再更新
  ]
  #ans[A]
  + A2C 是*同步* Advantage Actor-Critic：多个环境副本各采一段 rollout，等这一批全部完成后，汇总样本/梯度做一次更新：
    #eq[$theta <- theta + alpha frac(1,N) sum_(i=1)^N delta_t^((i)) nabla_theta log pi_theta (a_t^((i))|s_t^((i)))$]
  + B 描述的是 A3C 的异步更新；C 错：A2C 的 worker 共享同一套全局参数；D 错：A2C 是 on-policy，通常不需要 replay buffer。
  #src[练习题（一）6；博客《Actor-Critic》]
])

#qa("7", "A3C 中 Worker 与全局网络的关系", [
  #tag[选择]
  #q[A3C 中多个 Worker 与全局 Actor-Critic 网络之间的典型关系是什么？]
  #opts[
    A. 每个 Worker 只训练自己的局部网络，训练结束后随机选择一个作为最终网络\
    B. 所有 Worker 必须等待其他 Worker 完成后才能统一更新一次\
    C. Worker 只负责计算奖励，Actor 和 Critic 全部在环境内部更新\
    D. Worker 从全局网络同步局部参数，采样并计算局部梯度后异步更新共享全局参数
  ]
  #ans[D]
  + A3C 的每个 worker 先从全局网络拉取当前参数，局部采样、计算梯度，再把梯度异步推回共享全局网络（Hogwild 风格）。worker 之间不互相等待。
  + 并行 worker 的轨迹天然去相关，所以通常不需要经验回放；B 描述的是 A2C 的同步屏障。
  #src[练习题（一）7；博客《Actor-Critic》]
])

#qa("8", "PPO-Clip 中概率比 $rho_t$ 的作用", [
  #tag[选择]
  #q[PPO-Clip 中新旧策略概率比 $rho_t = pi_theta (a_t|s_t) / pi_(theta_"old") (a_t|s_t)$ 的主要作用是什么？]
  #opts[
    A. 衡量当前策略相对于产生当前 Rollout 的旧策略变化了多少\
    B. 估计环境状态转移的随机程度\
    C. 计算 Critic 的状态价值函数\
    D. 保证新策略与旧策略的所有动作概率完全相同
  ]
  #ans[A]
  + $rho_t$ 衡量新策略相对旧策略的变化：$rho_t = 1$ 表示没变，$rho_t > 1$ 表示新策略更倾向该动作。PPO 用它给旧策略数据做重要性加权，并用 clip 限制更新：
    #eq[$L^"CLIP" (theta) = bb(E)_t [min(rho_t A_t, "clip"(rho_t, 1 - epsilon.alt_"clip", 1 + epsilon.alt_"clip") A_t)]$]
  + B 是环境模型/随机性；C 是 Critic 的目标；D 错：ratio 允许偏离 1，只是被限制在信任域附近。
  #src[练习题（一）8；博客《PPO》]
])

#qa("9", "PPO 首次更新前的概率比", [
  #tag[判断]
  #q[在 PPO 的一次 Rollout 采样结束后，如果 Actor 尚未进行任何参数更新，那么首次用同一 Actor 重新计算动作概率时，新策略与旧策略相同，因此相应的概率比初始为 1。]
  #ans[正确]
  + 采样刚结束时 $theta = theta_"old"$，同一网络对同一 $(s_t,a_t)$ 算出的概率相同：
    #eq[$rho_t = frac(pi_theta (a_t|s_t), pi_(theta_"old") (a_t|s_t)) = 1$]
  + 这正是 PPO 能在同一批 rollout 上做多个 epoch 的起点；第一次梯度更新后 $rho_t$ 就偏离 1，clip 才开始生效。
  #src[练习题（一）9；博客《PPO》]
])

#qa("10", "DQN Mini-batch 是否必须时间连续", [
  #tag[判断]
  #q[标准 DQN 从经验回放池随机抽取的一个 Mini-batch 中，各 transition 必须按照时间连续排列，并共同构成同一条轨迹的一部分。]
  #ans[错误]
  + 标准 DQN 从 replay buffer 中*均匀随机*抽取 transition，样本不必时间连续，也不必来自同一条轨迹。回放的目的正是打破相邻样本的相关性；若强制每个 mini-batch 都是完整连续轨迹，就失去了这一点。
  + 只有 n-step DQN 等变体会存连续片段，但标准 DQN 的 target 是单步的：
    #eq[$y = r + gamma (1-d) max_(a') Q(s',a';theta^-)$]
  #src[练习题（一）10；博客《DQN》]
])

#section[练习题（二）　简答]

#qa("1", "策略学习与价值学习的区别", [
  #tag[简答]
  #q[策略学习与价值学习的区别是什么？]
  + #key[价值学习]：学 $V^pi (s)$ 或 $Q^pi (s,a)$，用 Bellman 误差/TD 更新；策略是隐式的，如 $a = arg max_a Q(s,a)$ 或 ε-greedy。离散动作方便，可 off-policy，收敛相对稳定。
  + #key[策略学习]：直接参数化 $pi_theta (a|s)$，优化
    #eq[$J(theta) = bb(E)_(tau tilde pi_theta) [R(tau)], quad R(tau) = sum_t gamma^t r_t$]
    用策略梯度更新：
    #eq[$nabla_theta J(theta) = bb(E)_(tau tilde pi_theta) [sum_t G_t nabla_theta log pi_theta (a_t|s_t)]$]
    可直接处理连续动作和随机策略，通常 on-policy，方差较大。
  + 一句话：价值学习学"评分"，策略学习直接学"动作分布"；Actor-Critic 把两者结合。
  #src[练习题（二）1；博客《策略学习》《Actor-Critic》]
])

#qa("2", "REINFORCE 的基本思想", [
  #tag[简答]
  #q[REINFORCE 的基本思想是什么？]
  + 用当前策略采一条完整轨迹 $tau$，算每个时刻的回报 $G_t$，然后把各时间步累加做梯度上升：
    #eq[$theta <- theta + alpha sum_(t=0)^(T-1) G_t nabla_theta log pi_theta (a_t|s_t)$]
  + 直观：$G_t$ 大（结果好）就提高这条动作的概率，$G_t$ 小或为负就降低。$G_t$ 是对 $Q^pi (s_t,a_t)$ 的 Monte Carlo 估计，$nabla log pi$ 是提高动作概率的方向。
  + 它是对 $nabla_theta J$ 的无偏估计，不需要环境模型，也不做 bootstrapping；但必须等完整 episode，方差大。
  #src[练习题（二）2；博客《策略学习》]
])

#qa("3", "REINFORCE 方差大的原因与缓解", [
  #tag[简答]
  #q[为什么 REINFORCE 的方差较大？缓解这一问题的方法是什么？]
  + #key[原因]：$G_t$ 只是 $Q^pi (s_t,a_t)$ 的单样本估计，包含环境转移、奖励、动作采样以及长时程的全部随机性；不同轨迹的回报波动很大，方差随 horizon 增长。
  + #key[减基线]：令 $b(s_t)$ 与动作无关，
    #eq[$nabla_theta J = bb(E)_(tau tilde pi_theta) [sum_t (G_t - b(s_t)) nabla_theta log pi_theta (a_t|s_t)]$]
    因为 $bb(E)[b(s) nabla log pi] = 0$，不引入偏差；常取 $b(s_t) = V^pi (s_t)$。
  + 其他：用 reward-to-go $G_t$；Actor-Critic 用 $delta_t$ 代替 $G_t$（偏差换方差）；GAE 用 $lambda$ 调偏差-方差；工程上做回报/优势归一化、增大 batch、并行采样。
  #src[练习题（二）3；博客《策略学习》《Actor-Critic》]
])

#qa("4", "优势函数的定义与含义", [
  #tag[简答]
  #q[什么是优势函数？优势函数的含义是什么？]
  + 定义：
    #eq[$A^pi (s,a) = Q^pi (s,a) - V^pi (s)$]
  + 含义：在状态 $s$ 下选动作 $a$，比"按当前策略 $pi$ 平均选动作"好多少。$A^pi > 0$ 优于平均水平，$A^pi < 0$ 更差。
  + 因为 $V^pi (s) = sum_a pi(a|s) Q^pi (s,a)$，所以 $bb(E)_(a tilde pi (dot|s)) [A^pi (s,a)] = 0$。
  + 策略梯度中用 $A^pi$ 作权重比用 $G_t$ 方差更小；最优策略下 $A^* = Q^* - V^* >= 0$。实际可用 $G_t - V(s_t)$、$delta_t$ 或 GAE 估计。
  #src[练习题（二）4；博客《Actor-Critic》]
])

#qa("5", "A2C、A3C 与 PPO 的关系", [
  #tag[简答]
  #q[A2C、A3C 与 PPO 的关系是什么？]
  + #key[Actor-Critic 框架]：Actor $pi_theta (a|s)$ 选动作，Critic $V_phi (s)$ 评价；$delta_t = R_t + gamma V_phi (S_(t+1)) - V_phi (S_t)$，Actor 用 $delta_t nabla log pi$ 更新，Critic 最小化 $delta_t^2$。
  + #key[A2C]：同步版 Advantage Actor-Critic，多环境并行采样，汇总梯度后一次更新；常用 n-step 优势或 GAE。
  + #key[A3C]：异步版，多 worker 从全局网络复制参数，各自采样并异步更新全局参数；靠并行去相关，通常不用 replay。
  + #key[PPO]：在 AC/A2C 基础上加入重要性比 $rho_t$ 和 clip，限制每次策略更新幅度，使同一批 rollout 可以安全地做多个 epoch；通常用 GAE 估优势。
  + 关系概括：AC 是框架，A2C/A3C 是并行实现，PPO 是带策略更新约束的 AC 变体。
  #src[练习题（二）5；博客《Actor-Critic》《PPO》]
])

#qa("6", "PPO 的 Clip 机制及作用", [
  #tag[简答]
  #q[PPO 的 Clip 机制及其作用是什么？]
  #eq[$rho_t (theta) = frac(pi_theta (a_t|s_t), pi_(theta_"old") (a_t|s_t))$]
  #eq[$L^"CLIP" (theta) = bb(E)_t [min(rho_t A_t, "clip"(rho_t, 1 - epsilon.alt_"clip", 1 + epsilon.alt_"clip") A_t)]$]
  + $A_t > 0$：若 $rho_t <= 1 + epsilon.alt_"clip"$，取 $rho_t A_t$；若 $rho_t > 1 + epsilon.alt_"clip"$，取 $(1 + epsilon.alt_"clip") A_t$，不再奖励继续抬高该动作概率。
  + $A_t < 0$：若 $rho_t >= 1 - epsilon.alt_"clip"$，取 $rho_t A_t$；若 $rho_t < 1 - epsilon.alt_"clip"$，取 $(1 - epsilon.alt_"clip") A_t$，不再奖励继续压低该动作概率。
  + #key[作用]：把一次更新的策略变化限制在信任域附近，避免步长过大导致性能崩溃；clip 后越界方向梯度为 0，因此同一批 rollout 可以多 epoch 复用。clip 只移除"越界继续改"的激励，不是硬约束；实践中常配合目标 KL 早停。
  + 采样刚结束时 $rho_t = 1$，此时 $L^"CLIP" = A_t$，与普通策略梯度一致。
  #src[练习题（二）6；博客《PPO》]
])

#qa("7", "基于模型的强化学习", [
  #tag[简答]
  #q[什么是基于模型的强化学习？]
  + 先从真实交互数据中学一个环境模型：
    #eq[$f_theta (s,a) approx s', quad R_theta (s,a) approx R(s,a)$]
    再用模型做规划或生成"想象轨迹"来更新策略/价值，如 Dyna、MPC、MB-PPO。
  + 优点：提高真实样本效率；可预演、可利用先验。缺点：模型偏差、误差累积、可能被模型利用（model exploitation）。
  #src[练习题（二）7；博客《基于模型的强化学习》]
])

#qa("8", "残差动力学模型学什么", [
  #tag[简答]
  #q[残差动力学模型学习的是什么？]
  + 把动力学拆成"已知名义模型 + 待学残差"：
    #eq[$hat(s)_(t+1) = f_0 (s_t,a_t) + g_theta (s_t,a_t)$]
    训练 $g_theta$ 拟合 $s_(t+1) - f_0 (s_t,a_t)$。增量形式是 $Delta s_t = s_(t+1) - s_t$，名义模型给 $Delta s_t^0$，网络学 $Delta s_t - Delta s_t^0$。
  + 残差通常更小、更平滑、物理意义更集中，比从零学整个动力学容易，也能保留已知物理规律。
  #src[练习题（二）8；博客《基于模型的强化学习》]
])

#qa("9", "模型误差为什么会累积", [
  #tag[简答]
  #q[模型误差为什么会累积？]
  + 一步误差 $epsilon_t = f_theta (s_t,a_t) - f(s_t,a_t)$。把下一步误差在当前状态附近一阶展开：
    #eq[$e_(t+1) = f_theta (hat(s)_t,a_t) - f(s_t,a_t) approx epsilon_t + J_t e_t$]
    其中 $J_t = frac(partial f, partial s)$ 是雅可比矩阵。旧误差经 $J_t$ 传到下一步，再叠加新误差；多步展开后越早的误差传播次数越多。
  + 若 $norm(J) <= L$，则
    #eq[$norm(e_H) <= epsilon frac(L^H - 1, L - 1) quad (L != 1)$]
    $L > 1$ 时指数放大。除数值传播外，策略更新会把智能体带到模型训练数据之外的状态（分布偏移），规划器又倾向选择模型高估的动作（model exploitation），两者都会进一步放大误差。
  + 缓解：短 rollout/MPC 重规划、ensemble 不确定性、残差模型、持续用新策略数据更新模型、模型-free 校正。
  #src[练习题（二）9；博客《基于模型的强化学习》]
])

]
