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
  title: [计算机视觉 开卷考试速查手册],
  authors: "Biscuit · Alkaid",
  date: datetime(year: 2026, month: 06, day: 30),
  abstract: [
    本文档整理自《计算机视觉》课程内容。Lecture 02 涵盖空间图像增强的核心定义、灰度变换方法、直方图调整技术及图像算术/逻辑运算；Lecture 03 涵盖图像滤波基础、卷积与互相关、平滑/锐化滤波器、边缘检测算子及 Canny 算法完整流程。另在对应章节穿插了【补1】至【补9】共 9 个补充知识章节（频域处理、形态学、KLT 跟踪器、相机标定与三角测量、一阶段检测器与 FPN、彩色空间、数据增强、检测/分割评价指标、图像插值方法），覆盖 PPT 外的高频考点。适合开卷考试快速查阅。
  ],
  chapter-pagebreak: false,
)


= 空间图像增强的基础定义与点操作公式

== 增强的核心目的

利用特定算法优化图像视觉效果，#strong[有选择性地强调有用信息、压制不必要的细节]，将图像转为更适合人类或机器分析的形式。注：此过程#strong[并不在意图像保真度]。

== 空间域点操作公式

#formula[
  空间域变换通用公式：

  $ g(x, y) = T[f(x, y)] $

  $ s = T(r) $
]

- #strong[参数定义：]
  - $f(x, y)$：原始输入图像。
  - $g(x, y)$：变换后输出图像。
  - $T$：作用于图像的变换操作。
  - #strong[$r$：]原始图像 $f(x, y)$ 在任意坐标点 $(x, y)$ 的#strong[灰度级（输入灰度级）]。
  - #strong[$s$：]增强后图像 $g(x, y)$ 在该坐标点 $(x, y)$ 的#strong[灰度级（输出灰度级）]。
  - 对于点操作，灰度变换函数 $T$ 仅取决于灰度值 $r$ 的大小，#strong[与像素点的具体坐标无关]。

= 灰度变换方法（常用点操作）

== 图像反转（负片变换）

#formula[$ s = L - 1 - r $]

- #strong[$L$：]图像的灰度级总数（例如 8 位图像中，$L = 256$）。
- #strong[核心特性：]将图像的黑白反转（黑色变白，白色变黑），产生"负片"效果。
- #strong[典型应用：]在#strong[医学影像]（如乳腺 X 光钼靶图像）中，反转后可使原本不易察觉的#strong[微小病灶（钙化点、肿瘤）在高亮度的背景衬托下显现出来]。

== 对数变换（压缩高动态范围）


图像中最亮与最暗可分辨像素的比值，一般用分贝（dB）表示：
  $"DR" = 20 log_{10}(R_(max)/R_(min))$ 动态范围与灰度级是两个不同的概念。灰度级量化精度，动态范围量化可记录的亮度跨度。一张 8 位图像即使有 256 级灰度，其物理动态范围仍然受限于传感器的能力。

#formula[
  $ s = c dot log(1 + r) $
  $ c = frac(L - 1, log(1 + R_(max))) $
]

其中常数 $c$ 保证最大灰度级映射到 $L-1$：


- #strong[$r$：]输入灰度，$s$：输出灰度，$R_(max)$：输入图像的最大灰度值，$L$：输出灰度总级数。

#strong[一阶导数分析（考试高频考点）：]

对 $r$ 求导数：$ dif(s)/dif(r) = c/(1 + r) $

- 当 #strong[$r$ 很小（暗部区域）：]导数 $approx c$（斜率较大）。特性：放大暗部细节, 将较窄范围的低灰度级映射到较宽范围的灰度级。
- 当 #strong[$r$ 很大（亮部区域）：]导数趋近于 $0$（斜率很小）。特性：压缩亮部，防止过曝丢失细节, 将较宽范围的高灰度级映射到较窄范围，从而抑制高灰度区域

#strong[典型应用场景：]真实世界亮度动态范围可达 $10^7$ 以上，普通 8-bit 图像只能表示 $0~255$ 级别。直接显示会导致#strong[亮部过曝（全白）或暗部欠曝（全黑）]。对数变换能将极大动态范围映射到极窄范围，同时保留明暗细节。

== 幂律（伽马）变换（控制明暗与显示器校正）

#formula[$ s = c dot r^(gamma) $]

- #strong[$c, gamma$：]正常数（工程上通常 $c = 1$）。
- #strong[$r$：]输入灰度（归一化到 $0~1$ 区间）。
- $s$：输出灰度。

#strong[变换曲线特性（必背）：]

- #strong[$gamma < 1$：]将低灰度级大幅提升，曲线位于直线 $s = r$ #strong[上方]。结果：图像#strong[整体变亮]，暗部细节被拉伸放大。$gamma$ 越小越亮。
- #strong[$gamma > 1$：]将高灰度级大幅压低，曲线位于直线 $s = r$ #strong[下方]。结果：图像#strong[整体变暗]，亮部细节被拉伸放大。$gamma$ 越大越暗。

#strong[显示器伽马校正工程应用（必背）：]

- #strong[核心问题：]现实显示设备（CRT/LCD）具有#strong[非线性响应]。物理亮度 $L_"out" prop V_"in"^gamma$（典型 $gamma approx 2.2$）。
- 若直接输入 8-bit 图像 $r$，显示器输出亮度为 $r^(2.2)$，导致图像偏暗或色彩失真。
- #strong[解决办法（预补偿/伽马校正）：]在图像送入显示器前，手动校正：$s = r^(1/gamma)$。
- #strong[数学验证：]显示器接收 $r^(1/gamma)$ 后，输出亮度为 $bold((r^(1/gamma))^gamma = r)$，最终恢复#strong[线性亮度响应]。

#tip[
  #strong[考试对比小贴士：]
  - #strong[对数变换]解决"动态范围太大，亮部和暗部无法同时看清"的问题。
  - #strong[伽马变换]调控"图像整体过暗或过亮"，以及解决"显示器显示偏色"问题。
]

== 线性灰度变换（对比度拉伸）

#formula[
  当原图灰度范围 $[a, b]$ 变换为 $[c, d]$ 时：

  $ g(x, y) = (d-c)/(b-a) dot (f(x, y) - a) + c quad a  <= f(x, y) <= b $
]

- #strong[应用场景：]解决因曝光不足或过度造成的#strong[图像灰度范围过窄（低对比度）]问题。
- #strong[分段线性灰度变换：]将整个灰度区间分割为多段，每段设不同斜率。线性地扩展（增强）感兴趣的灰度范围，并相对压缩（抑制）不感兴趣的灰度区域

#formula[
  $
  g(x, y) = cases(
    c/a dot f(x, y) "if" 0 <= f(x, y) < a ,
    (d-c)/(b-a) dot [f(x, y)-a] + c "if" a <= f(x, y) < b ,
    (L-1-d)/(L-1-b) dot [f(x, y)-b] + d "if" b <= f(x, y) <= L-1
  )
  $
]

相对于连续的对数或幂律变换，分段变换#strong[更为机械、僵硬，但参数精密可控]，适用于输出给计算机进行后续图像识别的场景。

== 灰度级分层（图像区域提取）

- #strong[背景全黑式：]关心范围 $[A, B]$ 映射为最高值（白色），范围外为 $0$（黑色）。用于强调特定灰度范围的#strong[形态轮廓]。
- #strong[背景保留式：]关心范围 $[A, B]$ 映射为最高值，范围外#strong[灰度保持不变]。用于在保持背景的同时，突出显示特定范围（如医学血管造影中凸显造影剂灌注的血管区域）。

== 位平面切片（Bit-plane Slicing）

将 8 位灰度图像的每个像素拆解为 8 个 1 位平面（Bit 0 ~ Bit 7）。

- #strong[Bit 0（最低有效位）：]包含极其细微的高频细节信息。
- #strong[Bit 7（最高有效位）：]包含图像的核心结构信息。
- #strong[应用：]图像压缩、隐写术、特定增强分析。

#tip[
  #strong[工程应用补充：]
  - #strong[医学 CT 窗宽窗位（WW/WL）：]实质为分段线性变换，突出显示特定组织或病灶。
  - #strong[伽马校正：]针对显示器非线性响应进行预补偿（见伽马变换）。
  - #strong[图像降噪：]多幅图像加法求平均，去除随机加性噪声。
  - #strong[CLAHE：]提升局部对比度同时抑制噪声放大。
]

= 直方图调整方法

== 图像直方图的定义与核心局限性

#strong[离散直方图定义一（频数）：]

#formula[$ H(r_k) = n_k $]

其中 $r_k$ 为第 $k$ 个灰度级，$n_k$ 为该图像中灰度值为 $r_k$ 的像素总个数。

#strong[直方图定义二（归一化概率密度 PDF）：]

#formula[$ p(r_k) = n_k / n $]

其中 $n$ 为图像的总像素个数（$M times N$），$n_k/n$ 表示灰度级 $r_k$ 在图像中出现的概率，将直方图数值规范到 $[0, 1]$ 区间。

#strong[直方图的性质与致命局限性（必考简答/辨析）：]

- #strong[性质：]直方图具备#strong[平移不变性、尺度不变性、旋转不变性]。
- #strong[局限性：]直方图#strong[不包含任何像素的空间位置信息]。

#warn[
  #strong[经典反例（课件第 23 页原题）：]
  问："将图像中的所有像素重新打乱，会发生什么？"
  #strong[答：]图像的直方图完全不变。基于直方图的#strong[所有点操作处理结果也完全不受影响]。
]

- #strong[对比度诊断：]曝光不足直方图集中在低灰度区（偏暗），曝光过度集中在高灰度区（偏亮），对比度低集中在极窄区间（细节模糊）。高对比度灰度直方图分布均匀、宽广。

== 直方图均衡化

#strong[变换公式推导（连续域）：]

假设原图 $r$ 的概率密度为 $p_(r)(r)$，目标输出分布 $s$ 是均匀分布，概率密度 $p_(s)(s)$ 恒为 $1$。

#strong[核心准则：]在映射过程中，灰度级对应的像素数量不改变，即曲线下的#strong[面积（概率）守恒]。

#formula[$ p_(s)(s) dif s = p_(r)(r) dif r $]

代入目标 $p_(s)(s) = 1$ 得：

#formula[$ dif s = p_(r)(r) dif r $]

两边积分得到变换函数：

#formula[$ s = T(r) = integral_0^r p_(r)(w) dif w $]

#strong[核心结论：]直方图均衡化的变换函数 $T(r)$，其实就是#strong[原始图像的累积分布函数（CDF）]。

#strong[离散灰度级计算步骤（大题标准答题格式）：]

+ 步骤 1：计算原图概率密度：$p(r_k) = n_k / n$。
+ 步骤 2：计算累积分布函数 CDF：$s_k = sum_(j=0)^k p(r_j)$。
+ 步骤 3：映射到具体灰度级：将累计值乘以最大灰度级并#strong[四舍五入]，得 $hat(s_k) = "round"(s_k times (L-1))$。
+ 步骤 4：合并灰度级并重算频数：将映射到同一个 $hat(s_k)$ 的原灰度级 $r_k$ 对应的像素数 $n_k$ 合并累加。

#strong[计算例题（课件第 32-34 页，考试照抄）：]

题目条件：图像 $64 times 64 = 4096$ 像素，$8$ 个灰度级（$L = 8$，即最大灰度值为 $7$）。

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header(
      [$r_k$], [$n_k$], [$p(r_k)$], [累积 $S_k$], [$S_k times 7$], [$hat(s_k)$], [新直方图归并]
    ),
    table.hline(stroke: 0.4pt),
    [$r_0 = 0$],    [790],  [0.19], [0.19], [1.33], [#strong[1]], [灰度 1：790],
    [$r_1 = 1/7$],  [1023], [0.25], [0.44], [3.08], [#strong[3]], [灰度 3：1023],
    [$r_2 = 2/7$],  [850],  [0.21], [0.65], [4.55], [#strong[5]], [灰度 5：850],
    [$r_3 = 3/7$],  [656],  [0.16], [0.81], [5.67], [#strong[6]], [灰度 6：985（合并）],
    [$r_4 = 4/7$],  [329],  [0.08], [0.89], [6.23], [#strong[6]], [],
    [$r_5 = 5/7$],  [245],  [0.06], [0.95], [6.65], [#strong[7]], [灰度 7：448（合并）],
    [$r_6 = 6/7$],  [122],  [0.03], [0.98], [6.86], [#strong[7]], [],
    [$r_7 = 1$],    [81],   [0.02], [1.00], [7.00], [#strong[7]], [],
    table.hline(stroke: 1.2pt),
  ),
  caption: [直方图均衡化完整计算表格 — $n = 4096$, $L = 8$],
  kind: table,
) <tbl-equalization>

#warn[
  #strong[均衡化的潜在副作用（考场简答题答案）：]
  直方图均衡化虽然能提高全局对比度，但也存在严重缺陷。由于离散化处理，#strong[原直方图中频数较低的灰度级会在舍入过程中被合并到极少数的几个新灰度级中]。后果：原本有丰富层次变化的细节区域，因灰度级合并，出现#strong["马赛克"伪影]，丢失微小细节。
]

== 限制对比度自适应直方图均衡化（CLAHE）

为弥补直方图均衡化造成的局部伪影，引入 CLAHE。

#strong[核心思想：]对图像分块，每个块单独做直方图均衡化，但加入#strong[对比度限幅]抑制噪声放大。

#strong[计算流程：]

#strong[步骤 1：分块。]将图像 $I$ 划分为 $T_x times T_y$ 个#strong[不重叠的块]（tile），单个块尺寸 $M_B = M/T_x$，$N_B = N/T_y$。记 tile $(i,j)$ 内灰度级 $r_k$ 的像素数为 $n_k^(i j)$。

#strong[步骤 2：设定裁剪阈值。]对每个 tile 计算裁剪阈值：

#formula[$ beta = (M_B dot N_B)/L dot alpha $]

$L$ 为灰度级数（256），$alpha$ 为 clip factor（典型值 2–4）。$beta$ 的物理意义：若每个灰度级恰好分到 $N_"tile"/L$ 个像素，直方图本身均匀。

#strong[步骤 3：直方图裁剪与重分配。]对每个 tile：

+ 3a. 统计原始直方图 $H_(i j)(r_k) = n_k^(i j)$。
+ 3b. 计算超出 $beta$ 的过剩像素总数：
  #formula[$ N_"excess"^(i j) = sum_(k=0)^(L-1) max(0, n_k^(i j) - beta) $]
+ 3c. 裁剪并均摊：将 $N_"excess"^(i j)$ 平均分配给所有 $L$ 个灰度级：
  #formula[$ n_k^(i j) arrow min(n_k^(i j), beta) + N_"excess"^(i j)/L $]
+ 3d. 可选迭代：若分配后某些灰度级再次超限，重复至收敛（通常 1–2 轮）。
+ 3e. 归一化得 PDF：$p_(i j)(r_k) = n_k^(i j) / (M_B dot N_B)$。

#strong[步骤 4：计算各 tile 的 CDF。]对每个 tile 计算累积分布函数并映射到整数灰度：

#formula[
  $ s_k^(i j) = T_(i j)(r_k) = sum_(x=0)^k p_(i j)(r_x) $
  $ r_k^(i j) = "round"((L-1) dot s_k^(i j)) $
]

实际运行时仅需保留 CDF 查找表 $T_(i j)(r_k)$。

#strong[步骤 5：双线性插值消除块间接缝。]对任意像素 $I(x,y) = r_k$：

+ 5a. 定位包围它的 4 个相邻 tile：左上 $(i,j)$、右上 $(i,j+1)$、左下 $(i+1,j)$、右下 $(i+1,j+1)$。
+ 5b. 计算插值权重 $w_x$（水平）、$w_y$（垂直），分别表示像素到左侧/上方 tile 中心的相对距离，取值范围 $[0,1]$。
+ 5c. 查 4 个 tile 的 CDF 得 $T_(t l), T_(t r), T_(b l), T_(b r)$，做双线性加权：
  #formula[
    $ "middle" = (1-w_x)(1-w_y)T_(t l) + w_x(1-w_y)T_(t r) + (1-w_x)w_y T_(b l) + w_x w_y T_(b r) $
    $ r'_k = "round"((L-1) dot "middle") $
  ]
+ 5d. 图像边缘像素退化到线性插值或直接取单 tile 变换。

$"分块" arrow "clip 限幅" arrow "HE" arrow "双线性插值"$

#tip[
  #strong[参数建议：]Tile 大小 $8 times 8$（细节密集图像）或 $16 times 16$（大尺度结构）；clip factor $alpha in [2, 4]$；bins 数通常 256。
]

== 直方图匹配（规定化）

将原始图像的直方图变换为#strong[指定的目标直方图形状]，用于更精准地控制图像增强效果。

#tip[
  #strong[与均衡化的区别：]均衡化将直方图变为均匀分布（自动）；匹配将直方图变为任意指定形状（可控）。
]

= 图像的基本运算

算术运算的结果可能超 $0~255$ 范围，显示时通常需做截断或偏移。

== 图像算术运算

=== 加法（+）

#formula[$ C(x, y) = A(x, y) + B(x, y) $]

- #strong[典型应用：]图像叠加（二次曝光效果）；对多张同类图像求#strong[平均值]，用于#strong[去除叠加性随机噪声]。

=== 减法（−）

#formula[$ C(x, y) = A(x, y) - B(x, y) $]

- #strong[典型应用：]去除背景（绿幕抠图 / 蓝屏抠图技术）；检测同一场景序列两幅图像间的#strong[变化/残差（运动物体检测）]。
- #strong[显示要点：]减法结果范围为 $[-255, 255]$，需做#strong[绝对化]或#strong[加 128 偏移]，才能在 8-bit 显示器上看到完整差值图像。

=== 乘法（×）

#formula[$ C(x, y) = A(x, y) times B(x, y) $]

- #strong[典型应用：]图像的局部显示（ROI 提取）。将一幅#strong[二值掩膜图像]（Mask，背景 $= 0$，感兴趣区 $= 1$）与原始图像相乘，屏蔽背景，只保留感兴趣区域。

=== 除法（÷）

#formula[$ C(x, y) = A(x, y) / B(x, y) $]

- #strong[典型应用：]图像归一化，#strong[校正光照/背景不均匀]。

== 图像逻辑运算

通常针对二值图像或掩膜图像进行操作。

- #strong[NOT（非）：]$g(x, y) = 255 - f(x, y)$。获取#strong[阴图像]或子图像补图（等同于灰度反转）。
- #strong[XOR（异或）：]两输入位不同时输出 $1$，相同时输出 $0$。用于#strong[提取两幅图像的差异区域]、寻找子图交叉点。
- #strong[OR（或）：]任意一位为 $1$ 则输出 $1$。用于#strong[图像合并]、求取#strong[两个子图的并集]。
- #strong[AND（与）：]两幅图同时为 $1$ 才输出 $1$。用于#strong[求取两幅子图的交集区域]、提取图像中的特定掩膜重叠部分。

= 【补2】数学形态学操作

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== 基本操作定义

形态学处理二值图像的核心是#strong[结构元素 $B$]滑过图像 $A$。

- #strong[腐蚀（Erosion）$A ⊖ B$：]$B$ 在 $A$ 内部滑动，$B$ 完全包含于 $A$ 时保留中心。结果：#strong[缩小亮区、断开狭窄连接、消除小噪声点]。
- #strong[膨胀（Dilation）$A ⊕ B$：]$B$ 与 $A$ 有交集即保留中心。结果：#strong[扩大亮区、桥接裂缝、填充小空洞]。

#formula[
  腐蚀：$ A ⊖ B = {z | (B)_z ⊆ A} $
  膨胀：$ A ⊕ B = {z | (B)_z ∩ A ≠ ∅} $
]

== 组合操作

- #strong[开运算（Opening）$A ∘ B$：]先腐蚀再膨胀 $(A ⊖ B) ⊕ B$。#strong[平滑轮廓、断开狭窄连接、消除细小突出物和孤立噪声点]。大小不变。
- #strong[闭运算（Closing）$A • B$：]先膨胀再腐蚀 $(A ⊕ B) ⊖ B$。#strong[平滑轮廓、连接狭窄缺口、填充细小空洞]。大小不变。

#strong[口诀：]开 → 去毛刺、断细桥；闭 → 补缺口、填小孔。

- #strong[形态学梯度：]$A ⊕ B - A ⊖ B$，提取#strong[物体边界轮廓]。
- #strong[顶帽变换（Top-Hat）：]原图 - 开运算结果，提取#strong[比背景亮的细小结构]。
- #strong[黑帽变换（Black-Hat）：]闭运算结果 - 原图，提取#strong[比背景暗的细小结构]。

== 结构元素（Structuring Element）

常见形状：矩形、十字形、圆盘形。尺寸越大，操作效果越显著。选择合适的结构元素是形态学应用的关键。

= 图像滤波基础概念与定义

== 为什么要滤波？

- #strong[目的：]生成一张像素值为原始像素值加权或组合而成的新图像。
- #strong[应用场景：]
  1. 获取有用信息：提取边缘/轮廓（理解物体形状）。
  2. 增强图像：去除噪声（平滑）、锐化图像（提取细节）。
  3. 深度学习的基石：卷积神经网络（CNN）中关键的特征提取算子。
- #strong[与点操作的区别：]点操作（Lecture 02）仅依赖#strong[单像素原始灰度 $r$]进行变换，未考虑空间信息；而#strong[滤波基于像素的邻域（上下文信息）]进行运算，考虑了空间相关性。

== 空间域图像增强与滤波公式

#formula[$ g(x, y) = T[f(x, y)] $]

- $f(x, y)$：输入原始图像。
- $g(x, y)$：输出增强后的图像。
- $T$：作用于像素 $(x, y)$ #strong[邻域]（如 $3 times 3$ 区域）的增强算子（线性或非线性）。
- #strong[空间滤波核心操作：]将每个像素替换为其#strong[邻域像素的线性组合（即加权和）]。

== 滤波器的基本结构

- #strong[空间滤波器（掩模/核/模板/窗口）：]在数字网格上进行数学运算的模板。
- #strong[常见同义词：]`Filter`（滤波器）、`Mask`（掩模）、`Kernel`（核）、`Template`（模板）、`Window`（窗口）。

= 二维滤波的具体实现（卷积与互相关）

== 二维互相关（无核翻转）【计算机视觉常用】

定义核 $H$ 和图像 $F$ 的#strong[互相关]运算（#strong[核不翻转，直接滑动点积]）：

#formula[$ G[i, j] = sum_(u=-k)^k sum_(v=-k)^k H[u, v] F[i+u, j+v] $]

- 核 $H$ 的大小为 $(2k+1) times (2k+1)$。
- #strong[意义：]可直接看作#strong[局部邻域与卷积核的"点积"]。在实际图像处理中，由于卷积核通常是对称的（如高斯、平滑核），#strong[实际应用通常默认做的是互相关运算]（即不翻转核）。

== 二维离散卷积（需核翻转）【数学标准定义】

#formula[$ (f * I)(x, y) = sum_(i, j=-infinity)^infinity f(i, j) I(x-i, y-j) $]

- #strong[区别：]卷积在数学定义上要求#strong[将核做 180° 旋转（翻转）]，然后进行点积求和。
- #strong[注意：]
  - 卷积满足交换律、结合律等数学性质，是经典的线性时不变系统（LTI）响应形式。
  - 实际图像处理中，因为核（如高斯核、均值核）大多数是#strong[对称的]，所以"卷积"和"互相关"的结果一样。考试时若无特殊说明，两种写法均不算错，但#strong[知道定义的区别]是考察重点。

== 线性滤波器的关键性质

- #strong[线性性质：]$"imfilter"(I, f_1 + f_2) = "imfilter"(I, f_1) + "imfilter"(I, f_2)$。
- #strong[平移不变性：]无论像素在图像哪个位置，滤波器行为一致（权重相同）。$"imfilter"(I, "shift"(f)) = "shift"("imfilter"(I, f))$。
- 输入平移 $a$ 输出同步平移：$f(x-a) -> g(x-a)$。
- #strong[重要结论：]任何线性、平移不变的算子都可以表示为#strong[卷积（或互相关）]的形式。

== 可分离滤波器

- #strong[定义：]如果一个二维滤波器可表示为一个"列向量"与一个"行向量"的乘积，则它是#strong[可分离的]。
- #strong[示例：]3×3 盒式滤波器 $ mat(1, 1, 1; 1, 1, 1; 1, 1, 1) = mat(1; 1; 1) times mat(1, 1, 1) $。高斯滤波器也可分离。

#strong[为什么重要（计算复杂度对比）：]

假设图像大小为 $M times M$，滤波器大小为 $N times N$。

- #strong[不可分离（2D）滤波器]的乘法次数：#strong[$M^2 times N^2$]。
- #strong[可分离滤波器]（先做行再做列，即 2 次 1D 卷积）的乘法次数：#strong[$M^2 times 2N$]。

#tip[
  考试常见简答："高斯核滤波，使用#strong[可分离（1 维卷积先水平后垂直）]的方式比直接二维卷积快很多，从 $O(N^2)$ 降到 $O(N)$。"
]

== 卷积中的边界填充（Padding）

卷积操作会使输出图像变小（边界像素没有完整邻域）。

- #strong[Full：]核与图像有任意一点重叠就计算输出（输出尺寸变大）。
- #strong[Same：]通过填充使输出尺寸与输入相同（#strong[实际工程中最常用]）。
- #strong[Valid：]核不超出图像边界（输出尺寸变小，无填充）。

#strong[填充方式（考试选择题常考）：]

- #strong[Zero-padding（零填充）：]边缘补 0。缺点：会在边缘引入虚拟的暗边，可能导致边缘误检。
- #strong[Symm（对称填充）：]将边缘像素向外折叠。
- #strong[Circular/Wrap（循环/包裹填充）：]将图像另一边的像素卷过来填补。


=  【补】频域处理与傅里叶变换

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== 为什么需要频域？

空间域滤波直接在像素上操作；频域则将图像变换到频率空间，利用频率特性进行滤波。两者通过#strong[卷积定理]等价。

==  二维离散傅里叶变换（2D DFT）

#formula[$ F(u, v) = sum_(x=0)^(M-1) sum_(y=0)^(N-1) f(x, y) dot e^(-j 2 pi ((u x)/M + (v y)/N)) $]

- $f(x, y)$：原始 $M times N$ 图像。
- $F(u, v)$：频域复数谱。$|F(u, v)|$ 为#strong[幅度谱]（亮度分布），$angle F(u, v)$ 为#strong[相位谱]（结构定位）。
- #strong[核心性质：]幅度谱决定"有哪些频率成分"，相位谱决定"图像结构在哪里"。#strong[纯幅度互换 + 纯相位互换实验证明：相位谱对视觉结构更重要]。
- 频谱图通常#strong[中心化]：低频在中心、高频在四周。通过 $f(x,y)(-1)^(x+y)$ 平移实现。

== 卷积定理（考试必考）

#formula[$ f(x, y) * h(x, y) <=> F(u, v) dot H(u, v) $]

#formula[$ f(x, y) dot h(x, y) <=> F(u, v) * H(u, v) $]

- #strong[空间卷积 = 频域乘积]（这是频域滤波的理论基础）。
- 利用 FFT，$O(N^2)$ 的大核卷积可降为 $O(N log N)$。

== 频域滤波器分类

#strong[低通滤波器（LPF）：]保留低频、抑制高频 → #strong[图像平滑/模糊]。
- 理想低通（ILPF）：硬截断，会产生#strong[振铃效应]（Gibbs 现象）。
- 巴特沃斯低通（BLPF）：$H(u,v) = 1 / (1 + (D(u,v)/D_0)^(2n))$，过渡平滑，无振铃。

- 高斯低通（GLPF）：$H(u,v) = exp (-(D^2(u,v))/(2D_0^2))$，无振铃，最常用。

#strong[高通滤波器（HPF）：]保留高频、抑制低频 → #strong[图像锐化/边缘增强]。$H_("HP")(u,v) = 1 - H_("LP")(u,v)$。

#strong[同态滤波（Homomorphic Filtering）：]基于#strong[照明-反射模型] $f(x,y) = i(x,y) dot r(x,y)$。取对数转换为加法：$ln f = ln i + ln r$。照明分量慢变（低频），反射分量快变（高频）。在频域同时压缩低频（动态范围）和增强高频（对比度），再做指数逆变换。用于#strong[消除光照不均匀]。


= 平滑滤波器（去噪与模糊）

==  线性平滑滤波器（均值与高斯）

=== 均值（盒式）滤波器

将邻域内每个像素赋予相同权重。

- 模板（3×3）：$ 1/9 mat(1, 1, 1; 1, 1, 1; 1, 1, 1) $。
- #strong[缺点：]会产生明显的#strong[块状伪影（马赛克效应）]。

=== 高斯滤波器（改进）

给距离中心更近的像素赋予更大权重（权重随距离中心变远而指数衰减）。

#formula[$ G_(sigma)(x, y) = 1/(2 pi sigma^2) exp(-(x^2 + y^2)/(2 sigma^2)) $]

- #strong[核大小推荐：]#strong[$6 sigma + 1$]（保证覆盖高斯分布 99.7% 的能量，即 $3 sigma$ 范围）。
- #strong[性质：]
  1. 高斯函数与自身卷积后仍是高斯函数，新的标准差 $sigma' = sqrt(n) dot sigma$（例如用 $sigma$ 卷积两次，等价于用 $sqrt(2) sigma$ 卷积一次）。
  2. 是#strong[低通滤波器]，抑制高频细节，仅保留低频轮廓。

== 非线性平滑滤波器（中值滤波）

- #strong[适用场景：]对#strong[椒盐噪声（Salt-and-Pepper Noise，即随机的纯黑 0 和纯白 255 像素点）]的抑制效果#strong[优于]均值滤波器。
- #strong[计算定义：]$R = "mid"{z_k | k = 1, 2, dots, n}$，即取邻域像素的#strong[中值]。
- #strong[最大值/最小值滤波器：]$R = "max"{z_k}$（寻找最亮点），$R = "min"{z_k}$（寻找最暗点）。

==  双边滤波（保边去噪）

- #strong[核心痛点：]高斯滤波在去噪的同时，不可避免地会把物体的#strong[边缘也给模糊掉]。
- #strong[解决思路：]#strong[空间距离加权 × 像素亮度差异加权]。

- 空间核（Domain Kernel）：$d(i, j, k, l) = exp(-((i-k)^2 + (j-l)^2)/(2 sigma_d^2))$（距离越近权重越大）
- 值域核（Range Kernel）：$r(i, j, k, l) = exp(-norm(f(i, j) - f(k, l))^2/(2 sigma_r^2))$（亮度越近权重越大）
- #strong[总权重（两者乘积）：]$w(i, j, k, l) = d(i, j, k, l) times r(i, j, k, l)$。

#strong[物理意义：]在平坦区域（像素亮度相近），值域核接近 1，表现为高斯模糊；#strong[在边缘处（像素亮度差异巨大），值域核迅速衰减至 0，边缘像素不被平滑]。因此双边滤波可以实现#strong["去噪，但不模糊边缘"]。

= 锐化滤波器与边缘检测

== 微分滤波器原理（数学近似）

- #strong[定义：]通过计算图像函数 $f(x, y)$ 的一阶或二阶导数来提取灰度变化剧烈的区域（即边缘）。
- #strong[离散化近似：] 用差分近似

#formula[
  一阶导数近似：$(partial f)/(partial x) approx f(x+1) - f(x)$

  二阶导数近似：$(partial^2 f)/(partial x^2) approx f(x+1) + f(x-1) - 2 f(x)$
]

== 一阶微分算子（梯度算子）

- #strong[梯度定义：]$nabla  = ((partial )/(partial x), (partial )/(partial y))^T$。

- #strong[边缘强度/梯度幅值：]$E_s = norm(nabla f) approx sqrt(((partial f)/(partial x))^2 + ((partial f)/(partial y))^2)$。工程上为简化计算，常使用绝对值近似：$E_s approx |I_x| + |I_y|$。
- #strong[边缘方向：]$theta = arctan((I_y)/(I_x)) + pi/2$。#strong[注意：]梯度方向是#strong[灰度增长最快的方向]，而边缘方向与梯度方向*垂直*。

#strong[常见的一阶微分算子模板：]

Roberts 算子（2×2，对角线差分）

#formula[
  $G_x = mat(-1, 0; 0, 1) quad G_y = mat(0, -1; 1, 0)$
]

Prewitt 算子（3×3，简单差分）

#formula[
  $G_x = mat(-1, 0, 1; -1, 0, 1; -1, 0, 1) quad G_y = mat(-1, -1, -1; 0, 0, 0; 1, 1, 1)$
]

Sobel 算子（3×3，最常用，给中心像素加权以抑制噪声）

#formula[
  $G_x = mat(-1, 0, 1; -2, 0, 2; -1, 0, 1) quad G_y = mat(-1, -2, -1; 0, 0, 0; 1, 2, 1)$
]

#strong[要点：]Sobel 算子中的 "2" 用于增强中心像素的重要性。这个加权近似于#strong[高斯平滑]，因此 Sobel 算子在边缘检测中比 Prewitt 算子更常用。

== 二阶微分算子（拉普拉斯算子）

- #strong[定义：]$nabla^2  = (partial^2 )/(partial x^2) + (partial^2 )/(partial y^2)$。

- #strong[二阶导数的特点：]
  - 一阶微分在边缘处产生峰值（找极大值），二阶微分在边缘处产生过零点（找符号变化）对#strong[灰度阶跃]产生#strong[双线响应]（正-负）。
  - 二阶微分对噪声的敏感度更高，实际使用时常先做高斯平滑再求拉普拉斯（即 LoG）。
  - #strong[对细节（孤立点）的响应最强]，点 > 线 > 阶跃。

#strong[离散拉普拉斯算子模板：]

#formula[
  #strong[4 邻域（各向同性）：]$mat(0, 1, 0; 1, -4, 1; 0, 1, 0)$（只考虑水平与垂直方向）

  #strong[8 邻域（各向同性，更好）：]$mat(1, 1, 1; 1, -8, 1; 1, 1, 1)$（加入对角方向，旋转不变性更好）
]

#strong[锐化增强公式：]

1. 用一阶导数做锐化增强(基本上不用，但是ppt里面讲过原理）：

锐化是平滑的逆操作。图像中的”细节”可以定义为原始图像与平滑结果的差，将细节加回原图，就得到锐化结果：


$
g(x, y) = f(x, y) + alpha(f(x, y) - nabla f(x, y) )
$，其中 $alpha > 0$。


2. 用拉普拉斯算子对图像进行锐化增强

减号的由来：拉普拉斯算子的卷积核中心为负数，在边缘暗侧响应为正、亮侧响应为负，从原图中减去拉普拉斯结果等于在暗侧减正变得更暗、在亮侧减负变得更亮，两侧对比增强。

#formula[
  若中心为负的模板：$ g(x, y) = f(x, y) - alpha nabla^2 f(x, y) $

  若中心为正的模板：$ g(x, y) = f(x, y) + alpha nabla^2 f(x, y) $
]

== 高频提升与钝化掩模（Unsharp Masking）

- #strong[原理：]锐化 = 原始图像 + $alpha times$ 细节（高频部分）。
- #strong[核心公式：]$F_"sharp" = F_"original" + alpha (F_"original" - F_"smooth")$。
  - 括号中 $F_"original" - F_"smooth"$ 就是原图减去高斯模糊图，即#strong[高频细节图]。

#strong[合并后的卷积核模板（考试选择题常用）：]

将上述公式合并成一次单次卷积扫描。对于 3×3 掩模：

#formula[
  #strong[4 邻域：]$mat(0, -1, 0; -1, 4+alpha, -1; 0, -1, 0)$

  #strong[8 邻域：]$mat(-1, -1, -1; -1, 8+alpha, -1; -1, -1, -1)$
]

- 若 $alpha = 0$ 时就是#strong[拉普拉斯]滤波（只提取边缘）；若 $alpha > 0$ 时就是#strong[锐化增强]（保留原图并加回细节）。

= Canny 边缘检测算法

Canny 算法是#strong[计算机视觉中最经典的边缘检测算法]。考试常考其#strong[具体执行步骤和每个步骤的目的]。以下为 5 步标准流程：

#strong[步骤 1：图像平滑（降噪）]

- #strong[操作：]使用#strong[高斯滤波器]对图像进行卷积去噪。
- #strong[原因：]图像中的噪声会对微分运算（梯度计算）造成极大的干扰（噪声会被导数放大）。
- #strong[参数：]高斯核大小与标准差 $sigma$。$sigma$ 越大，去噪越强，检测到的边缘越#strong[宏观（大尺度）]，小细节丢失；$sigma$ 越小，边缘越#strong[精细]，但也越容易受噪声影响。

#strong[步骤 2：计算图像梯度（强度与方向）]

- #strong[操作：]通常使用 #strong[Sobel 算子]计算图像 $x$ 方向和 $y$ 方向的偏导数 $G_x$ 和 $G_y$。
- 计算梯度幅值：$M = sqrt(G_x^2 + G_y^2)$（或近似 $M approx |G_x| + |G_y|$）。
- 计算梯度方向：$theta = arctan(G_y / G_x)$。

#strong[步骤 3：非最大值抑制（Non-Maximum Suppression, NMS）]

- #strong[核心目的：]#strong[将模糊的边缘变细（细化边缘）]。
- #strong[操作细节：]
  1. 对每一个像素，沿#strong[该像素的梯度方向]，检查其前后两个相邻像素（若梯度方向不指向正网格中心，需利用邻近像素进行#strong[插值]计算梯度值）。
  2. 若当前像素的梯度幅值 > 梯度方向上前后两个插值点的梯度幅值，则保留该点为候选边缘；否则，将该点梯度设为 0（舍弃）。
  3. #strong[结果：]生成的边缘图像是#strong[单像素宽度]的。

#strong[步骤 4：双阈值检测与滞后阈值化（Hysteresis Thresholding）]

- #strong[核心目的：]抑制噪声引起的假边缘，保留真实边缘。
- 设定高阈值 $T_h$ 和低阈值 $T_l$。
- #strong[分类（3 种情况）：]
  1. 梯度幅值 > $T_h$：判定为#strong[强边缘（Strong Edge）]，#strong[直接保留]。
  2. 梯度幅值 < $T_l$：判定为#strong[非边缘（No Edge）]，直接剔除。
  3. $T_l <=$ 梯度幅值 $<= T_h$：判定为#strong[弱边缘（Weak Edge）]。
- #strong[后续决策：]
  - #strong[若弱边缘像素与强边缘像素相邻（处在 8 邻域内）]，将其保留为边缘；
  - 否则，将其剔除。

#strong[步骤 5：输出最终边缘图]

- 将以上步骤保留下来的所有像素（强边缘 + 与强边缘连接的弱边缘）作为最终的图像边缘输出。

#strong[后续操作：]

- Canny 不产生闭合的连续边界，但在大多数图像上产生的边缘是分割的有效中间线索。

  - 形态学闭合：对边缘图做闭运算（膨胀+腐蚀），连接断裂的边缘段。
  - 轮廓填充：提取连通轮廓，填充封闭区域。
  - 分水岭标记：将 Canny 边缘作为分水岭输入或外部标记。

= 进阶边缘检测

- #strong[HED (Holistically-Nested Edge Detection)：]端到端的深度神经网络（CNN）边缘检测。利用#strong[多尺度、多层级特征]进行融合，输出更符合人类视觉感知的边缘。
- #strong[RCF (Richer Convolutional Features)：]比 HED 更进一步，利用#strong[图像金字塔]（Image Pyramid，即多尺度缩放原图）输入，结合多个侧边输出，提取更丰富的卷积特征进行边缘检测。
- #strong[ControlNet：]由边缘检测图（如 Canny 边缘）作为引导条件输入到 Stable Diffusion 中，用于精确控制生成的图像结构。

= Lecture 03 核心公式/模板速查

#strong[1. Sobel 算子模板（必须能默写）：]

#formula[
  垂直方向（检测水平边缘）：

  $ G_y = mat(-1, -2, -1; 0, 0, 0; 1, 2, 1) $

  水平方向（检测垂直边缘）：

  $ G_x = mat(-1, 0, 1; -2, 0, 2; -1, 0, 1) $
]

#strong[2. 拉普拉斯算子模板：]

#formula[
  4 邻域：$ mat(0, 1, 0; 1, -4, 1; 0, 1, 0) $（若做锐化，中心加权重：$4 + alpha$）

  8 邻域：$ mat(1, 1, 1; 1, -8, 1; 1, 1, 1) $（若做锐化，中心加权重：$8 + alpha$）
]

#strong[3. 高斯滤波器计算公式：]

#formula[$ G(x, y) = 1/(2 pi sigma^2) exp(-(x^2 + y^2)/(2 sigma^2)) $]

推荐核大小 = $6 sigma + 1$。

#strong[4. 双边滤波总权重公式（概念简答时默写）：]

#formula[$ w = exp(-("空间距离"^2)/(2 sigma_d^2)) times exp(-norm("像素灰度差")^2/(2 sigma_r^2)) $]

#strong[5. 可分离性复杂度对比：]$N^2$ vs $2N$（节省大量计算）。

#strong[6. 边界填充特性（名词解释）：]

- `Zero`：补 0，边缘易产生伪影。
- `Symm`：镜像对称。
- `Circular`：循环延伸。

= 特征检测基础概念与挑战

== 动机（为什么要检测特征？）

- #strong[核心问题：]如何将多张部分重叠的图像拼接成一张#strong[全景图像]？
- #strong[关键步骤：]在不同图像中找到相同的物理点（#strong[特征匹配]），通过匹配点对估计图像间的变换关系。

== 特征匹配的三大挑战

- #strong[挑战一：稳定（可复现）检测：]在不同的视角、光照变化下，能否在两幅图像中独立检测出同一个物理点？
- #strong[挑战二：唯一（显著）描述：]检测到特征点后，如何准确识别出它在另一幅图像中的"孪生兄弟"？这要求特征具备高度的#strong[独特性]。
- #strong[挑战三：错误匹配的鲁棒处理：]由于重复纹理、遮挡等原因，会产生错误匹配。算法需要具备#strong[鲁棒性]，能够剔除错误匹配（误匹配）。

== 优秀特征应具备的特点

1. #strong[可复现性：]（应对挑战一）在不同变换（旋转、缩放、光照）下，都能稳定被检测出来。
2. #strong[显著性：]（应对挑战二）特征的描述符应有足够独特的"身份标识"，能与其他特征区分开。
3. #strong[高效性：]特征点的数量远少于图像像素总量，且提取与匹配计算高效。

== 应用场景

运动跟踪、图像配准、三维重建、物体识别、图像检索、机器人导航。

= 哈里斯（Harris）角点检测器

== 基本思想

- 利用一个#strong[小窗口]在图像上滑动。
- #strong[平坦区域：]窗口向任意方向移动，灰度值变化都很小。
- #strong[边缘区域：]窗口沿边缘方向移动灰度变化小，垂直边缘方向变化剧烈。
- #strong[角点区域：]窗口#strong[向任何方向]移动，图像的灰度都会发生#strong[显著变化]。

== 数学推导（SSD 误差与泰勒展开）

设窗口 $W$ 移动了位移 $(u, v)$，像素变化用#strong[平方差之和（SSD）]衡量：

#formula[$ E(u, v) = sum_((x, y) in W) (I(x+u, y+v) - I(x, y))^2 $]

#strong[小运动假设]：对 $I(x+u, y+v)$ 进行#strong[一阶泰勒展开]：

#formula[$ I(x+u, y+v) approx I(x, y) + I_x u + I_y v $]

其中 $I_x = (partial I)/(partial x)$，$I_y = (partial I)/(partial y)$ 为图像在 $x, y$ 方向的偏导数（梯度）。

将泰勒展开代回 $E(u, v)$ 中，消除 $I(x, y)$：

#formula[$ E(u, v) approx sum_((x, y) in W) (I_x u + I_y v)^2 =sum_((x, y) in W) I_x^2 u^2 + 2 I_x I_y u v + I_y^2 v^2 $]

#strong[化为矩阵形式（结构张量/自相关矩阵）]：

设 $H = sum_W mat(I_x^2, I_x I_y; I_x I_y, I_y^2)$，则：

#formula[$ E(u, v) approx mat(u, v) H mat(u; v) $]

- #strong[结构张量 $H$]（称为 Harris 矩阵/二阶矩矩阵）描述了窗口内梯度的分布情况。它是一个对称半正定矩阵。
- $H$ 的#strong[特征值 $lambda_1, lambda_2$] 代表了窗口在#strong[两个正交方向]上的灰度变化剧烈程度。

== 特征值与图像区域的对应关系

1. #strong[平坦区域：]$lambda_1$ 和 $lambda_2$ 都很小（接近 0）。$E(u, v)$ 在所有方向都不变。
2. #strong[边缘区域：]$lambda_1 >> lambda_2$（或 $lambda_2 >> lambda_1$）。一个方向变化大，另一个方向几乎没有变化。
3. #strong[角点区域：]$lambda_1$ 和 $lambda_2$ 都很大（且大小相近）。#strong[在任意方向上的微小平移都会造成巨大的强度变化]。

== 角点响应函数（不算特征值的快速判定）

为快速判断角点而不直接解特征值，Harris 定义了#strong[角点响应函数 $R$]：

#formula[$ R = det(H) - alpha dot "tr"(H)^2 = lambda_1 lambda_2 - alpha (lambda_1 + lambda_2)^2 $]

- $det(H) = lambda_1 lambda_2$（矩阵行列式）。
- $"tr"(H) = lambda_1 + lambda_2$（矩阵的迹）。
- $alpha$：经验常数，通常取值范围为 #strong[0.04 到 0.06]。

#strong[判定规则（"选角点"）]：

- #strong[$R > 0$ 且很大：]$lambda_1, lambda_2$ 都大且相近，乘积大，和相对较小。判定为#strong[角点]。
- #strong[$R < 0$ 且很小（负值）：]$lambda_1 >> lambda_2$，乘积小，和高。判定为#strong[边缘]。
- #strong[$|R|$ 非常小（接近 0）：]$lambda_1, lambda_2$ 都很小，判定为#strong[平坦区域]。

== Harris 角点检测算法实现步骤

+ #strong[计算梯度]：用sobel算子对 整幅图像 进行卷积，得到每个像素的水平和垂直梯度 $I_x=I * S_x, I_y=I * S_y$ 。

+ #strong[结构张量计算]：计算每个像素的结构张量： $H$ 的元素：$I_x^2, I_y^2, I_x I_y$ 这一步得到三张梯度图。

+ #strong[计算响应值]：根据公式计算每个像素的角点响应函数 $R$ 得到响应图。

+ #strong[阈值处理]：设定阈值 $T$，遍历响应图，只保留 $R > T$ 的点（过滤平坦区域和弱边缘）剩下的置零。

+ #strong[非极大值抑制（NMS）]：在局部邻域内（如 $3 times 3$），只保留 $R$ 值最大（局部极值）的点作为最终角点（防止角点成堆出现）。

== harris算法的特点

- 对旋转不变：因为响应函数只依赖于特征值，与方向无关。
- 对光照变化不敏感：因为响应函数依赖于梯度的平方。
- 对噪声敏感：因为计算梯度时会放大噪声，所以通常在计算结构张量前会先对图像进行高斯模糊。
- *无法检测尺度变化*：因为窗口大小固定，无法适应不同尺度的角点。

= 斑点检测 — 尺度归一化与 LoG

== 从边缘到斑点

- #strong[边缘：]灰度发生阶跃（一阶导数极值，二阶导数过零点）。
- #strong[斑点：]可看作是两个边缘（阶跃）的叠加。检测斑点，就是检测#strong["双线响应"的极值]。
- #strong[尺度匹配直觉：]如果用高斯拉普拉斯（LoG）滤波器去检测斑点，当滤波器的尺度（$sigma$）和斑点的大小"匹配"时，LoG 响应在斑点的中心达到最大值。

== 为什么需要"尺度归一化"？

- #strong[问题：]标准的拉普拉斯算子会随着尺度 $sigma$ 的增大，其导数幅值剧烈衰减（衰减速度为 $1/sigma^2$）。
- #strong[后果：]如果不做归一化，LoG 的响应值在 $sigma -> 0$ 时总是最大。这意味着无论斑点有多大，滤波器都会倾向于选择极其微小的噪声作为最强特征点，#strong[导致无法正确匹配斑点的真实大小]。
- #strong[解决办法：]使用 Lindeberg 提出的#strong[尺度归一化理论]。对于 $k$ 阶微分算子，应乘以 $sigma^k$。对于二阶导数的拉普拉斯算子（LoG），应该乘以 #strong[$sigma^2$] 进行修正。

== 尺度归一化数学推导（一维情况）

- 信号（高斯斑点）：$f(x) = exp(-x^2/(2 r^2))$（$r$ 为斑点真实半径）。
- 滤波器：$g(x; sigma) = 1/(sqrt(2 pi) sigma) exp(-x^2/(2 sigma^2))$。
- 未归一化中心响应：$R(0; sigma) = -r/(r^2 + sigma^2)^(3/2)$。
- 归一化中心响应（乘以 $sigma^2$）：$R_("norm")(0; sigma) = -(r sigma^2)/(r^2 + sigma^2)^(3/2)$。
- 求极值：令 $(dif R_"norm")/(dif sigma) = 0$，解得 #strong[$sigma = sqrt(2) r$]。
- #strong[结论：]一维信号中，当检测尺度 $sigma$ 等于真实斑点尺寸 $r$ 的 $sqrt(2)$ 倍时，滤波器响应达到最大。

== 尺度归一化数学推导（二维情况）

- 信号（二维高斯斑点）：$f(x, y) = exp(-(x^2 + y^2)/(2 r^2))$。
- 滤波器：$G(x, y; sigma) = 1/(2 pi sigma^2) exp(-(x^2 + y^2)/(2 sigma^2))$。
- 未归一化中心响应：$R(0, 0; sigma) = -(2 r^2)/(r^2 + sigma^2)^2$。
- 归一化中心响应（乘以 $sigma^2$）：$R_("norm")(0, 0; sigma) = -(2 r^2 sigma^2)/(r^2 + sigma^2)^2$。
- 求极值：令 $(dif R_"norm")/(dif sigma) = 0$，解得 #strong[$sigma = r$]。
- #strong[结论：]二维图像中，当检测尺度 $sigma$ #strong[等于]真实斑点的半径 $r$ 时，尺度归一化的 LoG 响应达到最大。这使得我们能够利用多尺度 LoG 滤波器，准确地在不同尺度下找到匹配斑点大小的特征点（如 SIFT 的第一步）。

= 描述符与 SIFT 算法（尺度不变特征变换）

== SIFT 概述

- #strong[核心目标：]在空间尺度中寻找极值点，提取出#strong[位置、尺度、旋转不变量]。
- #strong[特点（必背）：]
  - 局部特征，对旋转、尺度缩放、亮度变化保持不变性。
  - 独特性强，信息量丰富，适合大规模数据库快速匹配。
  - 多量性，即使少数物体也能产生大量特征。
  - 高速性，经优化后可达实时。

== SIFT 算法的步骤

#strong[步骤一：尺度空间极值检测（构建高斯金字塔与 DoG 金字塔）]

- #strong[高斯金字塔：]对原图进行不同尺度的高斯模糊和下采样（Octave 分组）。每增加一个 Octave，图像长宽减半（下采样）。
- #strong[DoG（高斯差分）金字塔：]在高斯金字塔的每个 Octave 内，将#strong[相邻两层的高斯模糊图像相减]。数学原理上，DoG 可以高效地近似替代计算昂贵的 LoG（高斯拉普拉斯）。
- #strong[寻找极值点（关键点候选）：]在 DoG 尺度空间中，每个像素点需要与#strong[同层的 8 个邻居]以及#strong[上下相邻尺度的 18 个邻居]（共 26 个点）进行比较。若为局部最大值或最小值，则作为候选关键点。

#strong[步骤二：关键点定位（亚像素精确定位）]

- #strong[问题：]步骤一只能检测到#strong[整数像素坐标]（离散极值点），真实极值点实际上落在连续空间中。
- #strong[解决：]对 DoG 函数在极值点附近进行#strong[二阶泰勒展开]：

#formula[
  $ D(bold(x) + hat(bold(x))) approx D(bold(x)) + ((partial D)/(partial bold(x)))^T hat(bold(x)) + 1/2 hat(bold(x))^T ((partial^2 D)/(partial bold(x)^2)) hat(bold(x)) $
]

令导数等于 0，解得精确的#strong[亚像素级偏移量]：

#formula[$ hat(bold(x)) = -((partial^2 D)/(partial bold(x)^2))^(-1) (partial D)/(partial bold(x)) $]

- 利用求出的偏移量对原始整数坐标进行#strong[精准修正]，同时剔除低对比度或位于边缘的不稳定关键点。

#strong[步骤三：关键点方向分配]

- #strong[目的：]为了实现#strong[旋转不变性]。
- #strong[操作：]
  1. 以关键点为中心，在对应的#strong[高斯金字塔图层]上取约 $3 sigma$ 邻域窗口。
  2. 计算窗口内所有像素的#strong[梯度幅值] $m(x, y)$ 和#strong[梯度方向] $theta(x, y)$：

#formula[
  $ m(x, y) = sqrt((L(x+1, y) - L(x-1, y))^2 + (L(x, y+1) - L(x, y-1))^2) $

  $ theta(x, y) = arctan((L(x, y+1) - L(x, y-1))/(L(x+1, y) - L(x-1, y))) $
]

3. 构建#strong[梯度方向直方图]（通常 36 个 bins 覆盖 360°）。直方图的峰值方向即为该关键点的#strong[主方向]。

#strong[步骤四：关键点描述符生成（128 维向量）]

- #strong[目的：]为关键点生成一个具有#strong[高度独特性]的身份标识。
- #strong[操作细节（核心必考知识点）：]
  1. 将关键点附近的 $16 times 16$ 邻域窗口划分为 $4 times 4 = 16$ 个#strong[子块]。
  2. 对每个子块，统计内部所有像素的梯度方向，生成一个#strong[8 个 bin 的方向直方图]（0~360°，每 45°一个 bin）。像素根据其梯度方向"投票"给对应的 bin，投票的#strong[权重]是该像素的梯度幅值。
  3. 这样，我们得到了 $16$（子块个数）$times 8$（直方图 bins）= #strong[128 维的特征向量]。
  4. 为抵抗光照变化，对这个 128 维向量进行#strong[归一化]。

== 高斯差分金字塔层数计算

- 假设每组（Octave）内需要检测的有效特征层数为 $S$（通常取 3）。
- 为在 DoG 空间中对这 $S$ 层的像素进行 26 邻域极值比较（需要#strong[上一级]和#strong[下一级]层的图像），必须额外多生成两层图像作为边界。
- #strong[结论：]为了得到 $S$ 个有效的极值检测尺度，SIFT 需要生成 #strong[$S+3$ 层]高斯模糊图像（相邻相减得到 $S+2$ 层 DoG 图像，从而能在中间 $S$ 层检测极值）。
- #strong[举例：]$S = 3$ 时，需要生成 6 层高斯图像，对应生成 5 层 DoG 图像。第 1、2 层（以及倒数第 1、2 层）DoG 图像只用于作为边界层，不具备完整的上下邻域比较条件，因此#strong[仅在中间的第 3 层和 4 层进行极值检测]。

= Lecture 04 核心公式/参数速查

#strong[1. Harris 矩阵 $H$：]

#formula[$ H = sum_W mat(I_x^2, I_x I_y; I_x I_y, I_y^2) $]

#strong[2. Harris 响应值 $R$：]

#formula[$ R = det(H) - alpha dot "tr"(H)^2 = lambda_1 lambda_2 - alpha (lambda_1 + lambda_2)^2 quad (alpha in [0.04, 0.06]) $]

#strong[3. 角点判定：]$R > 0$ 为角点，$R < 0$ 为边缘，$|R|$ 极小为平坦区。

#strong[4. 尺度归一化核心逻辑：]对于 LoG（二阶导），必须乘以 #strong[$sigma^2$] 才能抵消随着尺度变大导数衰减的问题。

#strong[5. 一维归一化极值匹配：]$sigma = sqrt(2) dot r$（$r$ 为真实斑点大小）。

#strong[6. 二维归一化极值匹配：]$sigma = r$（尺度 $sigma$ 和斑点真实半径 $r$ 相等时匹配）。

#strong[7. SIFT 描述符维度：]$4 times 4$ 子块 $times 8$ 方向 = #strong[128 维向量]。

#strong[8. SIFT 高斯金字塔层数：]为在 $S$ 个尺度上检测极值，实际需要生成 #strong[$S+3$] 层高斯模糊图像。

= 基于特征的图像拼接流程（总览）

- #strong[核心任务：]将多张部分重叠的图像拼接成一张全景图。
- #strong[标准处理流程：]
  1. #strong[提取特征点]（使用 SIFT、Harris 等算法）。
  2. #strong[计算粗略特征匹配]（通过描述符距离寻找对应点）。
  3. #strong[RANSAC 筛选内点]（剔除错误匹配的外点）。
  4. #strong[最小二乘法估计最优单应性矩阵]（利用内点计算变换矩阵）。
  5. #strong[图像拼接]（应用变换矩阵合成全景图像）。

= 拟合技术

== 最小二乘法（垂直距离最小化）

已知数据点 $(x_1, y_1), dots, (x_n, y_n)$，寻找线性方程 $y_i = m x_i + b$ 的最佳参数 $(m, b)$。

#strong[目标函数（误差最小化）：]

#formula[$ E = sum_(i=1)^n (y_i - m x_i - b)^2 $]

#strong[求解方法（对参数求偏导，令导数为 0）：]

#formula[
  $ (partial E)/(partial m) = -2 sum_(i=1)^n x_i (y_i - m x_i - b) = 0 $

  $ (partial E)/(partial b) = -2 sum_(i=1)^n (y_i - m x_i - b) = 0 $
]

#strong[致命的局限性（考试常考）：]

- 因为误差是计算#strong["垂直误差"]（$y$ 轴方向的距离），所以#strong[无法拟合垂直线]（斜率 $m -> infinity$ 时，计算崩溃）。
- 且当直线越接近垂直时，拟合效果越差。

== 总体最小二乘法（法向距离最小化）

#strong[问题背景：]为克服最小二乘法"无法拟合垂直线"的缺陷，采用#strong[点到直线的法向垂直距离]替代垂直误差。

#strong[定义直线：]使用一般式 $L: a x + b y = d$，其中 #strong[$a^2 + b^2 = 1$]（单位法向量）。

点到直线的距离公式：点 $(x_i, y_i)$ 到直线 $a x + b y = d$ 的垂直距离为 $|a x_i + b y_i - d|$。

#strong[目标函数：]寻找 $(a, b, d)$ 最小化距离的平方和：

#formula[$ E = sum_(i=1)^n (a x_i + b y_i - d)^2 $]

#strong[中心化与化简：]令样本均值为 $bar(x) = 1/n sum x_i$，$bar(y) = 1/n sum y_i$。通过中心化推导，将问题转化为约束优化问题。

定义矩阵 $S = mat(S_(x x), S_(x y); S_(x y), S_(y y))$，其中：
- $S_(x x) = sum (x_i - bar(x))^2$
- $S_(x y) = sum (x_i - bar(x))(y_i - bar(y))$
- $S_(y y) = sum (y_i - bar(y))^2$

向量 $bold(u) = mat(a; b)$（即直线的法向量）。

#strong[约束条件：]$norm(bold(u))^2 = a^2 + b^2 = 1$。

#strong[求解方法（拉格朗日乘数法）：]

构造拉格朗日函数，对 $a, b$ 求偏导，最终得到一个#strong[特征值方程]：

#formula[$ S bold(u) = lambda bold(u) $]

#strong[结论：]总体最小二乘法的最优法向量 $bold(u) = mat(a; b)$，就是矩阵 $S$ #strong[最小特征值对应的特征向量]。由此求出的直线 $a x + b y = d$，不存在斜率为无穷大导致失败的问题，可以完美拟合垂直线。


= 随机采样一致性（RANSAC）

== 核心思想（考试概念题）

- #strong[全称：]Random Sample Consensus（随机采样一致性）。
- #strong[本质：]一种#strong[在存在大量异常值（外点/Outlier）的情况下，通用的模型拟合框架]。
- #strong[相比于最小二乘法的优势：]最小二乘法受#strong[离群点（Outliers）影响极大]，拟合出的直线会被离群点严重拉偏。RANSAC 能完美剔除离群点，只使用可信的"内点"进行拟合。

== 算法流程

+ 步骤 1：#strong[随机采样]：从全部数据点中，#strong[均匀随机]地选择足以确定模型的最少样本点（例如拟合直线最少需要 2 个点，拟合单应性矩阵最少需要 4 对点）。
+ 步骤 2：#strong[拟合模型]：利用这组最少样本点，计算出一个初步的模型参数。
+ 步骤 3：#strong[统计内点（投票）]：遍历剩余的所有数据点，判断其与模型的"距离"是否小于设定的阈值。若小于阈值，则认定为该模型下的#strong[内点（Inlier）]，计数加 1；否则认定为外点（Outlier）。
+ 步骤 4：#strong[迭代并更新最优模型]：重复步骤 1~3 多次，每次保留内点数量（投票数）最多，或者内点占总样本比例最高的模型作为当前最优解。
+ 步骤 5：#strong[最终输出]：迭代结束后，输出得到最多投票的最优模型。

== 缺点

- 需要手动调整的参数比较多（距离阈值、最少样本数、迭代次数）。
- 若初始随机采样的点集中含有外点，可能无法良好初始化模型。
- 如果内点比率极低，或迭代次数不足，可能导致失败。


= 将匹配视为拟合问题 / 图像变换

== 图像对齐的核心思想

对齐问题可转化为#strong[拟合两幅图像中匹配特征对（对应点）之间变换矩阵 $T$]的问题。寻找变换 $T$，使得匹配点对之间的#strong[残差（误差）最小]：

#formula[$ min_T sum "Residual"(T(x_i), x_i') $]

== 不同变换模型的自由度与矩阵

#figure(
  table(
    columns: (auto, auto, 4fr, auto),
    stroke: none,
    inset: (x: 8pt, y: 5pt),
    align: (left, center, left, center),
    table.hline(stroke: 1.2pt),
    table.header(
      [变换类型], [自由度数], [不变性质], [最少匹配对数]
    ),
    table.hline(stroke: 0.5pt),
    [#strong[相似变换] (Similarity)], [4], [形状不变，长度比率不变], [2 对],
    [#strong[仿射变换] (Affine)], [6], [平行线变换后仍保持平行], [3 对],
    [#strong[单应性变换] (Homography)], [#strong[8]], [直线变换后仍保持为直线], [#strong[4 对]（不共线）],
    table.hline(stroke: 1.2pt),
  ),
  caption: [图像变换模型对比 — 考试必背参数表],
  kind: table,
) <tbl-transforms>

#strong[对应齐次坐标矩阵：]

#formula[
  相似变换：$ H_S = mat(s cos theta, -s sin theta, t_x; s sin theta, s cos theta, t_y; 0, 0, 1) $

  仿射变换：$ H_A = mat(a, b, c; d, e, f; 0, 0, 1) $

  单应性变换：$ H = mat(h_(11), h_(12), h_(13); h_(21), h_(22), h_(23); h_(31), h_(32), 1) $
]

#tip[
  实际工程（如图像拼接）中，最常使用的是 #strong[单应性变换（Homography）]。它需要至少 4 对匹配点才能求解。
]

== 单应性矩阵的最小二乘法求解

设特征点对为 $P = (x, y, 1)^T$ 和 $P' = (x', y', 1)^T$。由单应性关系 $P' approx H P$ 展开可列出方程组。

将问题转化为求解超定线性方程组 $A bold(h) = 0$，通过最小二乘法拟合最优 $H$，目标是最小化映射误差 $sum norm(P'_i - H P_i)^2$，等价于求解：

#formula[$ A^T A bold(h) = bold(b) $]

或使用奇异值分解（SVD）求 $A$ 的最小奇异值对应的特征向量，得到最优解 $H$。若有 #strong[4 对]精确对应的点对，可直接解出唯一的 $H$。

= 霍夫变换

==  为什么需要霍夫变换？

- #strong[问题：]对于图像中的边缘点（例如一条直线上的 N 个点），我们不知道哪几个点属于同一条直线，更不知道直线方程是什么。
- #strong[本质：]一种#strong[投票（Voting）技术]。将图像空间中的点映射到#strong[参数空间]中，通过寻找参数空间中投票数（累加器）的峰值，来确定图像中的直线位置。

==  直线参数化与投票

#strong[直角坐标系参数化（存在缺陷）：]

若使用 $y = m x + b$ 作为参数，图像空间中的一个点 $(x_0, y_0)$，在参数空间 $(m, b)$ 中会变成一条直线：$b = -x_0 m + y_0$。

- #strong[致命缺陷：]无法表示#strong[垂直线]（斜率 $m -> infinity$，参数空间 $m$ 无限大，无法用有限大小的二维数组表示）。

#strong[极坐标系参数化（霍夫标准变换）：]

为克服上述缺陷，霍夫变换使用直线的#strong[极坐标法式]：

#formula[$ rho = x cos theta + y sin theta $]

- #strong[参数定义：]
  - $theta$：直线法线与 $x$ 轴的夹角（范围 $0 tilde 180 deg$）。
  - $rho$：直线到原点的距离（垂直距离）。
- #strong[图像空间到参数空间的映射：]
  - 图像空间中的一个点 $(x, y)$，在参数空间 $(theta, rho)$ 中变成一条#strong[正弦曲线]。
  - 图像空间中同一条直线上的#strong[多个点]，对应到参数空间中是一族#strong[相交于同一点]的正弦曲线。这个交点对应的 $(theta, rho)$ 就是该直线的参数。

==  基于霍夫变换的直线检测算法步骤

+ 步骤 1：#strong[初始化累加器]：构建二维数组（累加器）$A(theta, rho)$，覆盖所有 $theta$ 角度（如 $0 tilde 180 deg$，步长 $1 deg$）和可能的 $rho$ 距离。数组初始值设为 #strong[0]。
+ 步骤 2：#strong[遍历边缘点并投票]：对图像中的每一个#strong[边缘像素点] $(x, y)$（通常来源于 Canny 边缘检测结果）：
  - 遍历所有可能的 $theta$ 值（如 $0 deg$ 到 $180 deg$）。
  - 代入公式 $rho = x cos theta + y sin theta$ 计算出对应 $rho$。
  - 将累加器对应位置#strong[投票+1]：$A(theta, rho) <- A(theta, rho) + 1$。
+ 步骤 3：#strong[寻找峰值（检测直线）]：在累加器矩阵 $A(theta, rho)$ 中，寻找投票数#strong[最高]（大于设定阈值）的#strong[局部极大值点] $(theta_(max), rho_(max))$。
+ 步骤 4：#strong[输出直线]：每个峰值点对应一条检测到的直线，方程为 $rho_(max) = x cos theta_(max) + y sin theta_(max)$。

==  霍夫圆检测

方程：$(x - a)^2 + (y - b)^2 = r^2$（包含 3 个自由参数：圆心 $a, b$，半径 $r$）。

#strong[方案一：暴力投票（维度灾难，不使用）：]

假设半径未知，需要在 #strong[3D 累加器空间 $(a, b, r)$] 中进行投票。三维累加器计算量和内存需求呈#strong[指数级爆炸]，效率极低且易受噪声干扰。

#strong[方案二：霍夫梯度法（工程实际常用）：]

1. #strong[边缘检测]：首先对图像进行 Canny 边缘检测。
2. #strong[计算梯度方向]：使用 #strong[Sobel 算子]计算边缘像素的梯度。
3. #strong[沿梯度方向投票找圆心]：对于每一个非 0 的边缘像素，沿着其#strong[梯度方向]（梯度指向圆心），遍历可能的半径，记录经过的累加器点，寻找所有可能的#strong[圆心]。
4. #strong[找半径]：计算边缘图像中所有非 0 像素到找出的候选圆心的距离，从小到大排序，根据投票选出最适合的半径。

#tip[
  #strong[结论：]霍夫梯度法通过将 3D 圆心-半径搜索拆解为"先沿梯度搜 2D 圆心 → 再算距离找半径"的两步法，大幅降低计算复杂度。
]

= Lecture 05 核心公式/参数速查

#strong[1. 最小二乘误差：]$E = sum (y_i - m x_i - b)^2$

#strong[2. 总体最小二乘（直线法向）：]$a x + b y = d$，$a^2 + b^2 = 1$。解为 $S bold(u) = lambda bold(u)$ 的最小特征值对应的向量。

#strong[3. 单应性变换矩阵：]

#formula[$ H = mat(h_(11), h_(12), h_(13); h_(21), h_(22), h_(23); h_(31), h_(32), 1) $]（8 个自由度，至少 4 对点求解）

#strong[4. 霍夫变换直线方程（极坐标）：]$rho = x cos theta + y sin theta$

#strong[5. 霍夫圆方程：]$(x - a)^2 + (y - b)^2 = r^2$（三维霍夫空间）

#strong[6. RANSAC 核心流程：]随机采样 → 拟合 → 统计内点 → 迭代保留最优

#strong[7. 变换模型自由度（必背）：]

- 相似变换：4
- 仿射变换：6
- 单应性变换：#strong[8]

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


= 卷积神经网络核心特性

#strong[1. 稀疏交互：]传统全连接层中每个输出单元与所有输入单元相连。卷积层中，#strong[每个输出神经元只与输入图像的一个局部区域（感受野）相连]，减少计算量和过拟合风险。

#strong[2. 参数共享：]同一个卷积核滑过整张图像时，#strong[该卷积核的权重参数被所有局部位置共享]。使模型学到的特征具有平移不变性，同时极大减少参数量。

#strong[3. 等变表示：]

- #strong[平移等变性：]若将输入图像中的目标平移，卷积后输出的特征图也会发生同样幅度的平移。
- #strong[不变表示：]通过后续的#strong[池化层（Pooling）]（如最大池化、均值池化），使网络对微小平移、形变不敏感，还可增大感受野。

#strong[4. 卷积运算公式：]

$i j$ 是输出特征图的坐标，$m n$ 是卷积核的坐标，$I$ 是输入图像，$K$ 是卷积核。

#formula[$ S(i, j) = (I * K)(i, j) = sum_m sum_n I(m, n) K(i-m, j-n) $]

#strong[5. 输出特征图尺寸公式：]

给定输入尺寸 $W times H$，卷积核大小 $K$，步长 $S$，填充 $P$，输出尺寸为：

#formula[$ W' = (W - K + 2P) / S + 1 $]

通常取整数（向下取整）。

#strong[6. 池化层（Pooling）：]

#formula[
  最大池化：$ Y_(i, j) = max_((m, n) in R_(i, j)) X_(m, n) $

  平均池化：$ Y_(i, j) = 1 / (|R_(i, j)|) sum_((m, n) in R_(i, j)) X_(m, n) $
]

- 池化层无参数，用于降维和增大感受野，提升平移不变性(变形不敏感）。

= 经典卷积神经网络结构演化

#strong[1. LeNet-5 (1998)：]Yann LeCun 提出，用于手写数字识别（MNIST）。结构：

输入(32×32) → 卷积 → 池化 → 卷积 → 池化 → 全连接 → 输出。

奠定了现代 CNN 的基础结构。

#strong[2. AlexNet (2012)：]首个在 ImageNet 上取得显著突破的 CNN。

- #strong[创新点：]采用 #strong[ReLU] 激活函数代替 Sigmoid、使用 #strong[Dropout] 防止过拟合、GPU 加速训练、数据增强。
- 结构：5 个卷积层 + 3 个全连接层，约 6000 万个参数。

#strong[Dropout 公式（训练时）：]

#formula[$ r_j ~ "Bernoulli"(p) quad hat(y)_j = r_j * y_j / p $]

- 训练时以概率 $p$ 随机丢弃部分神经元，测试时使用全部神经元。

#strong[3. ZeilerNet (2014)：]改进 AlexNet：首层卷积核由 $11 times 11$ 降至 #strong[$7 times 7$]，步长由 4 降为 2，保留更多像素细节。

#strong[4. VGGNet (2015)：]核心思想：使用#strong[更小的卷积核]（全部采用 #strong[$3 times 3$]），叠加深层（VGG16 / VGG19）。

#strong[堆叠感受野公式：]两个 $3 times 3$ 卷积堆叠等价于一个 $5 times 5$ 卷积，三个等价于 $7 times 7$，但参数量大幅减少且引入更多非线性。

#formula[
  单个 $7 times 7$ 卷积参数量：$7^2 C^2 = 49 C^2$

  三个 $3 times 3$ 卷积参数量：$3 times 3^2 C^2 = 27 C^2$（节省约 45%）
]

#strong[5. GoogLeNet (2015)：]核心组件：#strong[Inception 模块]。在同一层并行使用 $1 times 1$、$3 times 3$、$5 times 5$ 卷积和 $3 times 3$ 最大池化，将多尺度特征在通道维度拼接。创新：使用 #strong[$1 times 1$ 卷积]降维，大幅减少计算量；用全局平均池化代替全连接层。

#strong[6. U-Net (2015)：]#strong[编码器-解码器]结构，#strong[核心创新为引入跳跃连接（Skip Connection）]。解码器（上采样）中将编码器（下采样）对应层的特征图复制拼接，使解码器能利用#strong[高分辨率空间信息]和#strong[浅层特征细节]，非常适合#strong[医学图像分割]。

#strong[7. ResNet (2016)：]解决极深网络（超过 20 层）的#strong[网络退化问题]。

- 核心思想：#strong[残差学习（Residual Learning）]。构建残差块：

#formula[
  $ F(x) = cal(H)(x) - x quad "则目标映射为" quad cal(H)(x) = F(x) + x $
]

- 引入跨层连接（#strong[恒等映射/Identity shortcut]），网络只需学习输入与输出之间的#strong[残差]，极大缓解深层网络的梯度消失和退化问题。
- 通过 #strong[Bottleneck（瓶颈）]结构进一步减少参数量：

#formula[
  $ 1 times 1 "降维" (256 -> 64) -> 3 times 3 (64) -> 1 times 1 "升维" (64 -> 256) $

  Bottleneck 参数量：$1^2 C_1 C_2 + 3^2 C_2^2 + 1^2 C_2 C_1$，远少于直接 $3 times 3$ 卷积
]

#strong[8. DenseNet (2017)：]密集连接结构：每一层的输入都来自于#strong[前面所有层]的输出，并将自身输出的特征图传递给之后的所有层。

#formula[$ x_l = H_(l)([x_0, x_1, ..., x_(l-1)]) $]

其中 $[dots]$ 表示通道维度的拼接（Concatenation）。优点：特征重用（Feature reuse），加强特征传播，大幅减少参数量，缓解梯度消失。

#strong[9. Batch Normalization（批归一化）：]

对每个 mini-batch 进行归一化，加速训练并缓解梯度消失：

#formula[$ hat(x)_i = (x_i - mu_B) / sqrt(sigma_B^2 + epsilon) quad y_i = gamma hat(x)_i + beta $]

其中 $mu_B, sigma_B^2$ 为 batch 均值和方差，$gamma, beta$ 为可学习参数。

#strong[10. 注意力机制：]

- #strong[空域注意力：]为特征图的不同#strong[空间位置]分配不同权重。
- #strong[通道注意力：]为特征图的不同#strong[通道]分配不同权重。
- #strong[SENet (2018)：]基于通道注意力。通过 #strong[Squeeze（全局池化）→ Excitation（全连接学习通道权重）→ Scale（加权）]三步，自动学习每个特征通道的重要程度。

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

= 视觉 Transformer

== Transformer 基础结构

Transformer 包含编码器（Encoder）和解码器（Decoder），主要由注意力机制和前馈神经网络构成。核心操作是将输入转为词嵌入（Word Embedding）与位置嵌入（Position Embedding）的和作为模型输入。

#strong[位置嵌入的作用：]由于自注意力机制本身不具备顺序感知能力，位置嵌入用于表示词或图像块在序列中的位置，以保留全局结构信息。

== 自注意力（Self-Attention）公式

#formula[$ "Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V $]

- $Q, K, V$ 通过将输入矩阵分别乘以三个可学习的线性变换矩阵得到。
- $d_k$ 为 $Q$ 和 $K$ 的列数（向量维度）。
- 除以 $sqrt(d_k)$ 是为了防止 $Q K^T$ 的内积结果过大，导致 softmax 梯度消失。
- #strong[多头注意力（Multi-Head Attention）：]将 $Q, K, V$ 拆分为多个头并行计算注意力，最后拼接并经过线性层输出。

== 编码器与解码器的区别

- #strong[编码器：]看到输入的完整序列信息，每层包含多头自注意力、残差连接、层归一化（Add & Norm）和前馈网络（Feed Forward）。
- #strong[解码器：]包含#strong[掩码多头自注意力（Masked Multi-Head Attention）]，训练时只能看到当前时刻及之前的信息。同时包含交叉注意力层（Cross-Attention），以编码器输出为 $K, V$，解码器自身输入为 $Q$。

== 代表性视觉 Transformer 模型

- #strong[ViT (Vision Transformer)：]将图片切分为固定大小（如 $16 times 16$）的 Patch，线性投影为向量，加入可学习的 `[class]` token，送入标准 Transformer Encoder，最后通过 MLP Head 输出分类结果。
- #strong[DeiT：]通过引入更优的优化算法、超参数搜索、更强的数据增广（Rand-Augment、Mixup、Cutmix）和正则化（随机深度 Stochastic Depth），使 Transformer 能在 ImageNet-1k 上直接训练。
- #strong[PVT (Pyramid Vision Transformer)：]引入#strong[特征金字塔]结构，将 Transformer 分为多个阶段，每阶段输出特征图分辨率逐渐缩小，类似 CNN 的多尺度特征提取。
- #strong[LocalViT：]将 FFN 中的全连接层替换为#strong[深度可分离卷积（Depthwise Convolution）]，在保留全局建模能力的同时注入局部空间上下文信息。
- #strong[Swin Transformer：]引入#strong[移动窗口注意力（Shifted Window Attention）]。每层划分为局部窗口进行自注意力计算，下一层将窗口平移，实现跨窗口信息交互，兼顾全局建模和计算效率。


= Transformer 向 CNN 回归（ConvNeXt & RepLKNet）

#strong[ConvNeXt：]完全采用 CNN 结构，但借鉴 Transformer 的训练技巧。

- 网络模块数从 ResNet 的 `(3,4,6,3)` 变为 `(3,3,9,3)`。
- #strong[Patchify 处理：]使用 $4 times 4$ 卷积，步长为 4 替代传统 $7 times 7$ 卷积加最大池化。
- #strong[ResNeXt 化：]采用深度可分离卷积（Depthwise Conv）并增加网络宽度。
- #strong[倒瓶颈结构（Inverted Bottleneck）：]维度 $96 -> 384 -> 96$（类似 MobileNetV2）。
- #strong[大卷积核：]深度可分离卷积核从 $3 times 3$ 提升至 $7 times 7$。
- #strong[微设计：]激活函数替换为 #strong[GELU]，BN 替换为 #strong[LayerNorm (LN)]，下采样与通道变换解耦。
- #strong[优化器：]采用 #strong[AdamW]。

#strong[RepLKNet：]通过#strong[大卷积核深度可分离卷积]获取更大感受野，提出#strong[结构重参数化]技术。

#formula[
  重参数化：$ bold(F)(bold(x)) + bold(x) = bold(x) star bold(w)' $

  其中 $bold(w)' = bold(w) + mat(0, 0, 0; 0, 1, 0; 0, 0, 0)$（训练多分支，推理融合为单一卷积核）
]


= 神经网络典型训练范式

== 监督学习（Supervised Learning）

给定带标签数据集 $cal(D) = {(x_i, y_i)}_(i=1)^N$，最小化经验风险：

#formula[$ L = 1/N sum_(i=1)^N {ell}(f(x_i), y_i) $]

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

#formula[$ L = 1/N sum_(i=1)^N {ell}(f(x_i), hat(y)_i) + L_"constraint" $]

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

#formula[$ theta_(t+1) = theta_t - eta_t nabla {ell}(theta_t; x_t, y_t) $]

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

#strong[6. 监督学习：]$L = 1/N sum {ell}(f(x_i), y_i)$

#strong[7. 对比学习 InfoNCE：]$L_"InfoNCE" = -sum_i log (exp(bold(z)_i dot bold(z)_(i^+) / tau)) / (sum_(j != i) exp(bold(z)_i dot bold(z)_j / tau))$

#strong[8. 元学习 MAML：]$theta^* = "arg min"_(theta) sum_k L_k^("test")(theta - alpha nabla L_k^("train")(theta))$

#strong[9. 联邦学习 FedAvg：]$theta_(t+1) = sum_(k=1)^K n_k/n theta_(t+1)^((k))$

#strong[10. 深度学习框架：]PyTorch（动态图）、TensorFlow（静态图）



= 图像分割定义与基本原则

== 分割任务分类

- #strong[语义分割（Semantic Segmentation）：]对所有像素分类，赋予类别标签（如：猫、草、天空）。不区分同一类别的不同实例。
- #strong[实例分割（Instance Segmentation）：]在语义分割基础上，进一步区分同一类别中的不同物体个体。
- #strong[全景分割（Panoptic Segmentation）：]结合语义分割与实例分割，给所有像素分配类别标签，并区分可计数实例（如人、车）与不可计数背景（如天空、草地）。

== 图像分割的数学原则

将图像域 $R$ 分为 $n$ 个子区域 $R_1, R_2, dots, R_n$，满足：

#formula[
  完备性：$ union_(i=1)^n R_i = R $

  互斥性：$ R_i ∩ R_j = ∅, quad i != j $
]

- #strong[区域一致性：]每个子区域 $R_i$ 内部像素满足某种相似性准则。
- #strong[区域差异性：]相邻子区域不满足同一准则。


= 传统图像分割方法

== 阈值法（固定阈值与 Otsu 大津法）

- #strong[固定阈值：]设定灰度阈值，大于该值置白，小于置黑。
- #strong[Otsu 大津法：]遍历所有可能灰度值，寻找最优阈值 $T$，使#strong[前景与背景两类的类间方差最大]，实现自动阈值选取。
- 优势：简单直观、计算量低、可解释性强。
- 缺陷：依赖直方图双峰假设；忽略空间信息；仅适用二分类；对噪声敏感。

== 边缘检测法（Canny）

- #strong[原理：]基于灰度不连续性，利用一阶导数极大值或二阶导数过零点检测轮廓。
- 优势：物理直观、计算高效。
- 缺陷：对噪声敏感；难以获得#strong[闭合边界]；语义缺失。

== 区域生长法

- 预设种子点 → 按相似性准则并入邻域像素 → 迭代至队列为空。
- 优势：分割连续、规则物体效果好。
- 缺陷：严重依赖种子点；对噪声敏感；结果受遍历顺序影响。

== 分水岭算法

- #strong[原理：]图像视为地形图，灰度代表海拔。模拟水位上升，低洼形成盆地，筑堤坝作为分割边界。
- 优势：边界精准连续，适合粘连物体分离。
- 缺陷：容易#strong[过分割]；依赖预处理；计算开销大。

== K 均值聚类

- 随机初始化 $K$ 个中心 → 像素划归最近中心 → 重算均值 → 迭代至收敛。
- 优势：简单高效。
- 缺陷：需预设 $K$ 值；对初始中心敏感；忽略空间相关性。

== 均值漂移（Mean Shift）

- 像素沿密度梯度方向"爬坡"到概率密度局部极大值，收敛到同一中心的像素归为一类。
- 优势：无需预设 $K$ 值。
- 缺陷：计算复杂度高；高维易失效。

== 传统方法的共同缺陷

- 依赖人工特征和假设，#strong[缺乏语义理解]。
- 对噪声和纹理敏感，#strong[鲁棒性差]。
- 缺乏全局上下文建模，泛化能力弱。


= 深度学习分割基础

== 全连接层与卷积层的相互转化

- 全连接层与卷积层唯一不同：卷积层神经元只与输入局部区域连接，且#strong[卷积列中的神经元共享参数]。
- #strong[转化原理：]任何全连接层可转化为等价卷积层，使原本接受固定尺寸输入的分类网络改为接受任意尺寸输入并输出#strong[热力图（Heatmap）]。

== 典型上采样方法

#strong[（1）插值法：]最近邻、双线性、双三次、Lanczos。支持任意倍率，无参数，计算高效。缺点：手工设计，细节保留差。

#strong[（2）像素重排（PixelShuffle）：]将 $N times N$ 个通道重排为 $N times N$ 窗格，增大空间分辨率。信息保留完整，但必须是整数倍采样。

#strong[（3）转置卷积（Transposed Convolution）：]卷积的"逆操作"。反向传播相当于权矩阵转置乘以误差向量：

#formula[$ (partial L)/(partial x) = C^T (partial L)/(partial y) $]

通过 im2col 和 col2im 实现分辨率放大。

= 【补9】图像插值方法详解

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== 最近邻插值（Nearest Neighbor）

直接取最近像素的值。$f(x, y) = f("round"(x), "round"(y))$。

- #strong[优点：]最快、无新值。
- #strong[缺点：]产生明显的#strong[方块/锯齿效应（马赛克）]，图像质量最差。

== 双线性插值（Bilinear）

在 $2 times 2$ 邻域内，先水平两次线性插值，再垂直一次：
$f(x, y) approx a x + b y + c x y + d$（可分离）。等价于 $2 times 2$ 区域加权平均。

- #strong[优点：]平滑自然，无方块效应，计算高效。
- #strong[缺点：]平滑带来#strong[高频细节损失]（轻微模糊），不保留边缘锐度。

== 双三次插值（Bicubic）

在 $4 times 4$ 邻域内用三次多项式拟合。权重函数：$W(d) = cases((a+2)|d|^3 - (a+3)|d|^2 + 1 "if" |d| <= 1, a|d|^3 - 5a|d|^2 + 8a|d| - 4a "if" 1 < |d| <= 2, 0 "otherwise")$，通常 $a = -0.5$。

- #strong[优点：]保留更多高频细节，比双线性更清晰。Photoshop 等专业软件默认插值方案。
- #strong[缺点：]计算量是双线性的约 10 倍。

== Lanczos 插值

使用 $sin c$ 函数截断加窗：$L(x) = text(sinc)(x) dot text(sinc)(x/a)$，窗口 $a$ 通常取 2 或 3。$text(sinc)(x) = sin(pi x)/(pi x)$。

- #strong[优点：]理论最优（基于采样定理），振铃效应可控。
- #strong[缺点：]计算复杂度高，可能产生轻微振铃。

== 四种插值方法对比

#figure(
  table(
    columns: (auto, auto, auto, auto),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([方法], [邻域], [#strong[质量]], [#strong[速度]]),
    table.hline(stroke: 0.4pt),
    [#strong[最近邻]], [$1 times 1$], [多方块/锯齿], [#strong[最快]],
    [#strong[双线性]], [$2 times 2$], [平滑但模糊], [快],
    [#strong[双三次]], [$4 times 4$], [较清晰], [慢 ~10×],
    [#strong[Lanczos]], [$6 times 6$~$8 times 8$], [理论最优], [最慢],
    table.hline(stroke: 1.2pt),
  ),
  caption: [插值方法对比速查],
  kind: table,
)
= 深度语义分割经典网络

== 全卷积网络（FCN, CVPR'15）

- #strong[核心思路：]将分类网络（如 VGG16）最后的全连接层替换为卷积层，输出#strong[像素级预测图]。
- #strong[跳跃连接架构：]
  - #strong[FCN-32s：]直接从最后层上采样 32 倍（结果粗糙）。
  - #strong[FCN-16s：]融合池化层 4 的特征，上采样 16 倍。
  - #strong[FCN-8s：]融合池化层 3 和 4 的特征，上采样 8 倍（边界最精细）。

== U-Net（MICCAI'15）

- #strong[编码器-解码器]结构。下采样提取特征，对称上采样恢复分辨率。
- #strong[关键创新：]跳跃连接（Concatenation），将编码器对应层特征图复制拼接，保留高分辨率空间信息和浅层纹理细节。
- #strong[数据增强：]采用#strong[弹性形变]（网格顶点随机偏移，内部像素插值）模拟组织形变，提升泛化能力。

== DeepLab 系列

#strong[DeepLab v1：]解决池化导致分辨率下降问题。
- #strong[空洞卷积（膨胀卷积）：]向卷积核内部插入空洞（Rate），不降低分辨率的同时扩大感受野。
- #strong[全连接 CRF：]结合像素间空间关系和颜色信息，修正粗糙边界。

#strong[DeepLab v2：]提出#strong[空洞空间金字塔池化（ASPP）]。并行使用多个不同膨胀率（Rate = 6, 12, 18, 24）的空洞卷积，拼接输出，同时捕获#strong[多尺度]上下文信息。

#strong[DeepLab v3：]改进 ASPP（去掉 CRF）。
- 空洞卷积后增加 #strong[BN] 层。
- 超大膨胀率替换为 $1 times 1$ 卷积。
- 增加#strong[全局池化]分支，补充全局图像级特征。

#strong[DeepLab v3+：]采用#strong[编码器-解码器]架构。编码器使用改进 ASPP 提取高级语义，解码器融合低层特征，提升边界精度。


= 实例分割与目标检测演进（R-CNN → Mask R-CNN）

== R-CNN（CVPR'14）

- 步骤：Selective Search 提取约 2000 个候选框 → 缩放后送 CNN 提取特征 → SVM 分类 → NMS 去重。
- #strong[缺陷：]每张图 2000 次 CNN 前向，速度极慢（约 47 秒/图）。

== Fast R-CNN（ICCV'15）

- 输入整张图只经过一次 CNN，提取#strong[全图共享特征图]。
- 引入 #strong[ROI Pooling] 层，将任意尺寸候选区域映射为固定尺寸特征向量。
- 网络末端同时连接分类分支与回归分支，实现#strong[端到端训练]（除候选框以外）。
- 速度约 2 秒/图，瓶颈在 Selective Search。

== Faster R-CNN（NeurIPS'15）

- 引入 #strong[RPN（区域提议网络）]，将候选框生成也放入 GPU。
- 在特征图每个位置预设 #strong[9 个锚点（Anchor）]（3 种尺度 $times$ 3 种长宽比）。RPN 判断前景/背景并回归偏移量。
- 速度约 0.2 秒/图，全 GPU。

== Mask R-CNN（ICCV'17）

- 在 Faster R-CNN 的分类 + 边框回归分支外，增加第三个#strong[全卷积掩码分支]，为每个候选框预测像素级掩码。
- #strong[RoI Align（核心改进）：]
  - 替代 RoI Pooling。RoI Pooling 两次取整量化导致空间错位。
  - RoI Align 保留浮点数边界，使用#strong[双线性插值]计算采样点值，消除量化误差。
- 最终输出：类别标签、精确边界框、像素级实例分割掩码。


= 【补5】一阶段目标检测器与特征金字塔

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== YOLO（You Only Look Once）核心思想

将检测视为#strong[回归问题]。整图 $->$ 网格划分（如 $7 times 7$） $->$ 每格预测 $B$ 个边界框及类别概率。

#strong[YOLOv1 输出：]每个网格输出 $(x, y, w, h, "confidence") times B + "class probs"$。

#strong[损失函数三大组成部分：]

+ 位置回归损失：$(hat(x)_i - x_i)^2 + (hat(y)_i - y_i)^2 + (sqrt(hat(w)_i) - sqrt(w_i))^2 + (sqrt(hat(h)_i) - sqrt(h_i))^2$（对 $w, h$ 开根号抑制大框误差）。
+ 置信度损失：有目标 → $(C_i - hat(C)_i)^2$；无目标 → $lambda_"noobj" (C_i - hat(C)_i)^2$。
+ 分类损失：有目标 → $(p_(i)(c) - hat(p)_(i)(c))^2$（交叉熵改进版）。

== YOLO vs R-CNN 家族对比（必考简答）

#figure(
  table(
    columns: (3fr, 4fr, 4fr),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([对比维度], [#strong[两阶段（Faster R-CNN）]], [#strong[一阶段（YOLO/SSD）]]),
    table.hline(stroke: 0.4pt),
    [检测流程], [先提候选框→再分类+回归], [直接回归边界框+分类],
    [#strong[速度]], [较慢（~0.2s/图）], [#strong[快（可达实时 ≥30FPS）]],
    [#strong[精度]], [#strong[更高（尤其小目标）]], [略低（但YOLOv5+已接近）],
    [核心优势], [RoI精细对齐，高准确率], [端到端、速度快、工业部署首选],
    table.hline(stroke: 1.2pt),
  ),
  caption: [两阶段 vs 一阶段检测器核心对比],
  kind: table,
)

== Focal Loss（RetinaNet, ICCV 2017）

解决一阶段检测器的#strong[前景-背景极度不平衡]问题：

#formula[$ "FL"(p_t) = -alpha_t (1 - p_t)^gamma log(p_t) $]

- $p_t$：模型预测的概率（易分类样本 $p_t -> 1$，难分类 $p_t -> 0$）。
- $gamma >= 0$：焦点参数。$(1 - p_t)^gamma$ 大幅#strong[降低易分类样本的损失权重]，使模型聚焦于难分类样本。
- $alpha_t$：类别平衡因子。标准取值 $gamma = 2, alpha = 0.25$。

== 特征金字塔网络（FPN）

#strong[核心思想：]浅层高分辨率（细节好但语义弱）+ 深层低分辨率（语义强但细节差），通过多尺度特征融合提升小目标检测。

#strong[FPN 三条路径：]

+ #strong[自底向上（Bottom-Up Path）：]标准 CNN 前向，每阶段输出特征图 $(C_2, C_3, C_4, C_5)$。
+ #strong[自顶向下（Top-Down Path）：]从 $C_5$ 开始逐级上采样（2×），与对应层的侧边特征（经 $1 times 1$ 卷积降维）相加。
+ #strong[横向连接（Lateral Connection）：]同层特征图经 $1 times 1$ 卷积匹配通道数后相加，再经 $3 times 3$ 卷积消除上采样混叠效应。

输出特征金字塔 $(P_2, P_3, P_4, P_5)$，多尺度检测头各自预测。

== 非极大值抑制（NMS）在目标检测中的应用

目标检测输出大量重叠边界框，NMS 去重：

+ 按置信度降序排列所有候选框。
+ 选取最高分框，计算其余框与该框的#strong[IoU]，将 IoU > 阈值者抑制（删除或衰减分数）。
+ 重复直到所有框被处理/抑制。

#strong[Soft-NMS：]不直接删除高重叠框，而是#strong[衰减其分数] $s_i = s_i (1 - "IoU")$ 或高斯衰减 $s_i = s_i e^(-"IoU"^2 / sigma)$，保留更多检测。

= Lecture 07 核心速查（开卷考试直接抄用）

#strong[1. 分割类型：]语义（逐像素分类）、实例（区分个体）、全景（实例+背景）

#strong[2. 分割数学原则：]完备性 $union R_i = R$、互斥性 $R_i ∩ R_j = ∅$

#strong[3. 传统方法：]

- 阈值法（Otsu：最大化类间方差）
- 分水岭（易过分割）、K 均值（需预设 $K$）
- Mean Shift（无需 $K$，计算量大）
- 共同缺陷：缺乏语义理解、鲁棒性差

#strong[4. 上采样：]插值、PixelShuffle（通道重排）、转置卷积（$partial L/(partial x) = C^T partial L/(partial y)$）

#strong[5. 语义分割网络：]

- FCN：全卷积化 + 跳跃连接（8s/16s/32s）
- U-Net：编码器-解码器 + 跳跃连接（适合分割）
- DeepLab v1：空洞卷积 + CRF
- DeepLab v2：ASPP（多尺度空洞卷积）
- DeepLab v3：改进 ASPP（+BN + 全局池化）
- DeepLab v3+：编码器-解码器 + ASPP

#strong[6. 实例分割演进：]

- R-CNN：Selective Search + SVM（47s/图）
- Fast R-CNN：共享特征图 + ROI Pooling（2s/图）
- Faster R-CNN：RPN + Anchor（0.2s/图）
- Mask R-CNN：+ 掩码分支 + RoI Align（双线性插值）

= 成像原理

== 图像与像素

- #strong[二维离散信号：]数字图像为二维函数 $I(x, y)$，$(x, y)$ 为像素空间坐标，$I(x, y)$ 为亮度值。也可用二维矩阵 $I[m, n]$ 表示。
- #strong[分辨率：]像素总数量。常见规格：720p（约 92 万）、1080p（约 207 万）、4K（约 829 万）。
- #strong[灰度级（位深）：]常见为 #strong[8 位（256 灰度级）]，$2^8 = 256$。

== 传感器与滤光

- #strong[CCD：]光子→电子→电压信号。
- #strong[CMOS：]主流，每个像素独立电荷→电压转换，读出快、功耗低。
- #strong[Bayer 阵列：]2×2 排列包含 #strong[2 绿、1 红、1 蓝]（人眼对绿最敏感），原始数据称 Raw 数据。

== 光学镜头参数

- #strong[焦距（Focal Length）：]平行光线汇聚的焦点到镜头光心的距离。焦距越长视场角越小。
- #strong[光圈与 f 值：]$N = f / D$，$f$ 为焦距，$D$ 为光圈直径。f 值越小（如 f/1.4），光圈越大，进光量越多，景深越浅。
- #strong[景深（DOF）：]减小光圈（增大 f 值）可增大景深。
- #strong[快门速度：]控制曝光时间。越快适合捕捉运动，越慢易模糊。
- #strong[ISO：]传感器感光度。提高 ISO 可应对弱光，但增加噪声。

== 单反 vs 手机相机

- 单反：传感器大（36×24mm）、色彩深度高（12~14 bit）、光学变焦，计算能力有限。
- 手机：传感器极小（5×4mm）、约 10 bit、固定镜头，#strong[依赖 ISP 计算摄影补救]。

= 图像信号处理器（ISP）处理流程

ISP 将 Raw 数据转化为 RGB 图像的核心计算管道。

#strong[1. ISO 增益与 Raw 处理：]放大原始信号；暗电流/黑电平减法（减去热激发的暗电流噪声）；镜头阴影校正（增益面修正边缘光照不均匀）。

#strong[2. 去马赛克（Demosaicing）：]将 Bayer 阵列单通道 Raw 数据恢复为 RGB 三通道。插值方法：双线性插值、边缘感知插值。替代方案：Foveon X3 传感器（叠放三层直接 RGB）。

#strong[3. 降噪（NR）：]将输入 $I$ 分为低频平滑部分 $B(I)$ 和高频细节部分 $I - B(I)$，仅当高频响应大于阈值时保留（视为内容），否则抑制（视为噪声）。

#strong[4. 白平衡与色彩空间转换：]

- #strong[白平衡：]"灰世界"算法（假设 RGB 三通道均值相等）或 "白点"算法（假设最亮区域为白色）。
- #strong[色彩空间转换：]传感器色彩空间 → CIE XYZ → sRGB。

#strong[5. 色调映射：]利用 3D LUT 或 1D 曲线进行风格化和对比度调整。

#strong[6. 映射至 sRGB：]应用 #strong[伽马编码]（非线性变换匹配人眼亮度感知）。

#strong[7. JPEG 压缩：]DCT（8×8 分块）→ 量化（舍弃高频细节）→ Z 字形扫描 → 差分编码 → Huffman 编码。


= 【补6】彩色空间与颜色模型

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== RGB 彩色空间

- 基于红绿蓝三原色#strong[加色混合]模型。每个通道 8 bit → 共 24 bit 真彩色。
- #strong[缺陷：]通道间高度相关；不符合人眼感知习惯；类似颜色在空间中的欧氏距离不代表感知相似。

== HSV/HSI 彩色空间（符合人眼直觉）

- #strong[H（色调 Hue）：]颜色类型，0°–360°（红→绿→蓝→红）。
- #strong[S（饱和度 Saturation）：]颜色纯度，0（灰白）→ 1（纯色）。
- #strong[V/I（亮度 Value/Intensity）：]明暗程度。
- #strong[优势：]将亮度与色彩信息解耦，对光照变化更鲁棒。非常适合#strong[基于颜色的图像分割]（如肤色检测）。

== Lab 彩色空间（感知均匀）

- $L$：亮度（0 黑 → 100 白）；$a$：绿→品红轴；$b$：蓝→黄轴。
- #strong[核心特性：]#strong[感知均匀性] — 空间中两点的欧氏距离 $Delta E = sqrt(Delta L^2 + Delta a^2 + Delta b^2)$ 与人眼感知的色差成正比。
- 常用于#strong[色差度量]和颜色迁移。

== YCrCb 彩色空间

- $Y$：亮度分量；$"Cb"$：蓝色色度分量；$"Cr"$：红色色度分量。
- #strong[优势：]亮度与色度分离，支持色度子采样（如 4:2:0），大幅节省存储和带宽。#strong[JPEG/MPEG 压缩标准的核心色彩空间]。

== 伪彩色增强

将单通道灰度图的每个灰度值#strong[映射为一种 RGB 颜色]。用于增强人眼对灰度差异的辨别能力（如医学热力图、红外成像）。

== 色彩恒常性（Color Constancy）

人眼/算法在不同光照下仍能正确感知物体本色的能力。经典算法：
- #strong[灰世界假设（Gray World）：]场景平均反射率是灰色的（$bar(R) = bar(G) = bar(B)$）。
- #strong[完美反射假设（White Patch）：]最亮的区域是白色反射面。


= 高动态范围（HDR）

== 动态范围定义

#formula[$ "Dynamic Range" = 20 log_10 (B_"max" / B_"min") quad "(dB)" $]

- $B_"max"$ 为满井容量，$B_"min"$ 为噪声底噪。
- 人眼 ≈ 120 dB，8-bit 显示器 ≈ 70~80 dB。

== HDR 实现

- 拍摄多张不同曝光量的低动态范围图像 → 合并有效像素 → #strong[色调映射]（将高动态范围压缩为标准 8-bit，保留明暗细节）。

= 图像复原（Image Restoration）

== 退化模型

#formula[$ y = H x + n $]

- $y$：退化图像，$x$：潜在清晰图像，$H$：退化矩阵，$n$：加性噪声。

#strong[经典任务分类：]

- $H$ 为恒等矩阵 → #strong[图像去噪]
- $H$ 为模糊算子 → #strong[图像去模糊]
- $H$ 包含下采样 → #strong[图像超分辨率]

== 评价指标

#strong[全参考（FR）：]MSE（均方误差）、PSNR（峰值信噪比）、SSIM（结构相似性）、MS-SSIM、LPIPS（深度学习感知相似度）、FID。

#strong[无参考（NR）：]NIQE、BRISQUE。

#strong[半参考（RR）：]仅获取部分特征进行比较。

== 去噪方法

#strong[传统去噪：]

- 均值/中值滤波：邻域平滑，损失边缘。
- NLM（非局部均值）：搜索相似块加权平均。
- #strong[BM3D：]分块找相似块 → 堆叠 3D 矩阵 → 变换域硬阈值滤波 → 聚合还原。

#strong[深度学习去噪：]

- #strong[DnCNN：]残差学习，网络学习噪声（残差），与原图相减得去噪图。
- #strong[FFDNet：]输入噪声水平图，支持空间变化噪声。
- #strong[CBDNet：]学习从真实噪声到清晰图像的映射。

== 图像超分辨率

- #strong[退化模型：]$y = (k star x)_"下采样" + n$（$k$ 为模糊核，$n$ 为噪声）。
- #strong[SRCNN：]三层卷积：Patch 提取 → 非线性映射 → 重建，与稀疏编码高度对应。
- #strong[盲超分（Blind SR）：]无法确知模糊核 $k$。BSRGAN 等使用混合退化策略覆盖现实场景。

// ================================================================
// 【补8】检测与分割常用评价指标
// ================================================================

= 【补8】检测与分割常用评价指标

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== 交并比（IoU, Jaccard Index）

#formula[$ "IoU" = (|A ∩ B|) / (|A ∪ B|) $]

- 衡量预测区域与真值区域的重叠程度。$0 tilde 1$，越高越好。
- #strong[阈值判定：]通常 IoU ≥ 0.5 判定为正确检测。

== 平均精度均值（mAP）— 目标检测核心指标

#strong[单类 AP（Average Precision）：]
- 按置信度降序排列所有预测框，计算不同召回率下的精确率。
- AP = Precision-Recall 曲线下的面积（通常用 11-point interpolation 或积分）。
- $"AP"@0.5$：IoU 阈值 0.5 时的 AP；$"AP"@[0.5:0.95]$：COCO 数据集标准（IoU 从 0.5 到 0.95，步长 0.05 取平均）。

#strong[mAP：]所有类别 AP 的均值。

== 平均交并比（mIoU）— 语义分割核心指标

#formula[$ "mIoU" = 1/(C+1) sum_(c=0)^C ("TP"_c) / ("TP"_c + "FP"_c + "FN"_c) $]

- $"TP"_c$：预测为 $c$ 类且真值为 $c$ 类的像素数。
- $"FP"_c$：预测为 $c$ 类但真值不是的像素数（假阳性）。
- $"FN"_c$：真值为 $c$ 类但预测不是的像素数（假阴性）。
- #strong[较像素准确率 PA 的优势：]mIoU 对类别不均衡更鲁棒（防止大量正确预测的背景像素掩藏少数类的失败）。

== 经典评价指标速查对比

#figure(
  table(
    columns: (auto, 3fr, 3fr),
    stroke: none,
    inset: (x: 6pt, y: 4pt),
    table.hline(stroke: 1.2pt),
    table.header([指标], [适用任务], [核心公式/说明]),
    table.hline(stroke: 0.4pt),
    [MSE], [图像重建/去噪], [平方误差均值，越小越好],
    [PSNR], [图像重建/去噪/超分], [$10 log_10 (("MAX"^2) / ("MSE"))$（dB），越大越好],
    [SSIM], [图像质量评估], [亮度+对比度+结构三项乘积，$0 tilde 1$，越高越好],
    [LPIPS], [感知相似度], [深层网络特征距离，越小越好],
    [FID], [生成图像质量], [Inception 特征分布距离，越小越好],
    [#strong[IoU]], [#strong[分割/检测]], [#strong[$|A∩B| / |A∪B|$]],
    [#strong[mAP]], [#strong[目标检测]], [#strong[各类 AP 均值 $\@$ 指定 IoU 阈值]],
    [#strong[mIoU]], [#strong[语义分割]], [#strong[各类 IoU 均值]],
    table.hline(stroke: 1.2pt),
  ),
  caption: [图像质量评价指标速查 — 补充指标粗体标明],
  kind: table,
)


= Lecture 08 核心速查（开卷考试直接抄用）

#strong[1. 像素与分辨率：]$2^8 = 256$ 灰度级，720p / 1080p / 4K

#strong[2. 光学参数：]f 值 $N = f / D$，f 值越小光圈越大、景深越浅

#strong[3. ISP 流程：]ISO 增益 → 去马赛克 → 降噪 → 白平衡 → 色调映射 → sRGB 伽马编码 → JPEG 压缩（DCT + 量化 + Huffman）

#strong[4. 动态范围：]$"DR" = 20 log_10 (B_"max" / B_"min")$（dB）

#strong[5. HDR：]多曝光合成 + 色调映射

#strong[6. 图像退化模型：]$y = H x + n$（去噪 / 去模糊 / 超分）

#strong[7. 评价指标：]MSE、PSNR、SSIM、LPIPS、FID

#strong[8. 去噪方法：]BM3D（传统）、DnCNN（残差学习）、FFDNet（噪声水平图）

#strong[9. 超分：]SRCNN 三层卷积（提取→映射→重建），盲超分 BSRGAN

= 光学与成像系统基础

== 折射定律（Snell's Law）

#formula[$ n_1 sin theta_i = n_2 sin theta_t $]

其中 $n_1, n_2$ 为介质折射率，$theta_i$ 为入射角，$theta_t$ 为折射角。小角度近似：$theta < 5 deg$ 时误差 < 1%，$sin theta approx tan theta approx theta$。

== 透镜类型

- #strong[菲涅尔透镜：]同心棱镜环构成，重量轻，用于聚光/投影。
- #strong[DOE（衍射光学元件）：]通过光栅衍射控制光路，色散补偿抵消色差。
- #strong[超透镜（Meta-lens）：]超表面亚波长结构调控光的相位、振幅和偏振，超薄轻量化。

== 镜头像差

- #strong[色差：]不同波长折射率不同（波长越长焦点越远），导致边缘伪彩。可通过 DOF 补偿。
- #strong[几何畸变：]广角镜头导致直线弯曲（桶形/枕形畸变），通过 LineNet、FaceNet 等校正。

= 传感器与噪声建模

== 成像链路

光子 → 光电转换 → 电路 → 放大器 → ADC → 数字信号。

== 噪声分类与数学模型

#strong[散粒噪声（Shot Noise）：]由光子的粒子性引起的统计涨落。

#formula[$ N_"shot" ~ cal(N)(0, beta_"shot" I) $]

#strong[暗电流噪声（Dark Current Noise）：]由传感器热激发产生。

#formula[$ N_("DC") = k N_("FP") + N_("BLE") + N_("DCSN") $]

#strong[读出噪声（Read Noise）：]由电路放大和读取过程引入。

#formula[$ N_"read" ~ cal(N)(0, sigma_"read"^2) quad N_"row" ~ cal(N)(0, sigma_"row"^2) $]

#strong[量化噪声（Quantization Noise）：]模拟→数字转换时的舍入误差。

#formula[$ N_q ~ U(-q/2, q/2) $]

= 多传感器与多模态融合

== 多摄超分（ECCV 2022）

利用多摄像头（主摄 + 长焦），通过训练阶段对齐多摄图像，推理时特征融合，生成高于单摄分辨率的图像。

== 可见光-近红外融合（RGB-NIR）

RGB 受光照影响，NIR 对光照不敏感。融合用于#strong[暗光增强]和#strong[反光消除]。

== 可见光-多光谱/高光谱融合

低分辨率高光谱（光谱信息）与高分辨率 RGB（空间信息）融合，生成同时高空间和高光谱分辨率的图像。应用于真实色彩还原（红枫原色影像系统）。


= 底层视觉新任务：去恶劣天气、去反光、人脸/文本恢复

== 去雨/雪/雾（De-weathering）

- #strong[SPA（CVPR 2019）：]语义引导像素级注意力（SPANet），局部到全局去除雨滴雨痕。
- #strong[Not Just Streaks（ECCV 2022）：]考虑雨滴、雨雾，引入可变形残差块和物理模型约束。
- #strong[WeatherStream（CVPR 2023）：]仿真技术，模拟从人为降雨到真实场景的自动变换。
- #strong[LiDAR 去雨/去雾：]滤除雨雪天产生的点云噪声。

== 去反光（Reflection Removal）

#strong[物理模型：]$I = B + R$，$B$ 为背景，$R$ 为反射层。

合成方法：对 $R$ 施加高斯模糊 → $I = B + R$ → 颜色加权截断 → 边缘增强。典型架构采用 E-CNN（提取边缘）和 I-CNN（恢复图像）两阶段串联。

== 人脸复原

#strong[GFRNet（ECCV 2018）：]利用流场对齐参考图像纹理 + 感知损失 + 对抗损失。
#strong[ASFFNet（CVPR 2020）：]基于关键点的引导图选择 + MLS 自适应对齐 + AdaIN 光照归一化 + 自适应特征融合。
#strong[DFDNet（ECCV 2020）：]同时保留通用字典和个性化字典。
#strong[选择性引导人脸复原（AAAI 2026）：]掩膜机制 + 循环损失 + 一步扩散模型 + ID 保留。

== 文本图像复原

利用 Transformer Encoder 提取上下文语义，结合结构先验生成与图像生成，学习文字笔画与结构。核心模块：字符编码、位置编码、多尺度特征融合。


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

= 视频中的运动应用

== 视频数据定义

视频是随时间拍摄的一系列连续帧，图像数据是空间坐标 $(x, y)$ 和时间 $t$ 的函数，记为 $I(x, y, t)$。

== 视频分割任务

- #strong[背景减除：]摄像机固定，计算当前帧与背景模型的差值，分离静态背景与动态前景。
- #strong[镜头边界检测：]计算帧间差异度量（像素差值、颜色直方图差异），超过阈值判定为镜头边界。
- #strong[运动分割：]利用运动特征对像素聚类，分割为不同运动属性的对象。

== 共同命运法则

#strong[共同命运法则（Law of Common Fate）：]以相同方向或速度运动的视觉元素被感知为一个整体。在均匀纹理背景下，运动可能是唯一区分目标与背景的线索。

= 光流（Optical Flow）的定义与基本假设

== 光流定义

光流是由观察者与场景之间的相对运动形成的#strong[表现运动模式]。核心目标：给定两连续帧，估计每个像素的运动矢量 $bold(v) = [u, v]^T$。

== 核心假设

#strong[假设 1：亮度恒常性（Brightness Constancy）]

同一物体点在不同帧中亮度值保持不变：

#formula[$ I(x(t), y(t), t) = C $]

#strong[假设 2：小运动（Small Motion）]

相邻帧像素位移极小，可通过泰勒级数一阶线性近似。

= 光流约束方程与孔径问题

== 亮度恒常性方程推导

由亮度恒常性 $I(x + u delta t, y + v delta t, t + delta t) = I(x, y, t)$，泰勒展开一阶近似并消项：

#formula[
  $ I_x u + I_y v + I_t = 0 $

  向量形式：$ nabla I^T bold(v) + I_t = 0 $
]

其中 $I_x = (partial I)/(partial x)$，$I_y = (partial I)/(partial y)$，$I_t = (partial I)/(partial t)$，$u = dif x/dif t$，$v = dif y/dif t$。

== 孔径问题（Aperture Problem）

- #strong[问题本质：]一个方程两个未知数 $(u, v)$，解构成一条直线。
- #strong[平坦区域：]梯度为 0，无法观测运动。
- #strong[边缘区域：]只能测到垂直于边缘的运动分量，无法确定沿边缘方向的分量。
- #strong[角点区域：]至少两个不同梯度方向，可唯一确定光流。

= 恒定光流 — Lucas-Kanade 方法

== 局部平滑性假设

在光流的#strong[局部邻域]（如 $5 times 5$ 图像块）内，所有像素具有相同位移 $(u, v)$。

== 超定方程组

对邻域内 $N$ 个像素应用亮度恒常性：

#formula[
  $ cases(I_(x)(p_1) u + I_(y)(p_1) v = -I_(t)(p_1), I_(x)(p_2) u + I_(y)(p_2) v = -I_(t)(p_2), dots.v) $

  矩阵形式：$ A bold(x) = bold(b) $
]

其中 $A = mat(I_(x)(p_1), I_(y)(p_1); I_(x)(p_2), I_(y)(p_2); dots.v, dots.v; I_(x)(p_N), I_(y)(p_N))$，$bold(x) = mat(u; v)$，$bold(b) = mat(-I_(t)(p_1); -I_(t)(p_2); dots.v; -I_(t)(p_N))$。

== 最小二乘求解

#formula[
  $ A^T A bold(x) = A^T bold(b) $

  即 $ mat(sum I_x^2, sum I_x I_y; sum I_x I_y, sum I_y^2) mat(u; v) = mat(-sum I_x I_t; -sum I_y I_t) $
]

$A^T A$ 为结构张量。当其特征值 $lambda_1, lambda_2$ 均较大（对应角点）时可逆，求得唯一解。

= 平滑光流 — Horn-Schunck 方法

== 全局平滑性假设

世界上大多数物体以连贯方式运动，期望#strong[光流场全局平滑]。定义为#strong[能量泛函极小化]问题。

== 能量函数

#formula[$ E = integral integral [(I_x u + I_y v + I_t)^2 + alpha (|nabla u|^2 + |nabla v|^2)] dif x dif y $]

- $I_x u + I_y v + I_t$：亮度恒常性数据项。
- $|nabla u|^2 + |nabla v|^2$：光流平滑度正则项。
- $alpha$：平滑项权重系数。

== 欧拉-拉格朗日方程

对 $E$ 分别对 $u, v$ 求变分，令变分为零：

#formula[
  $ cases(I_x (I_x u + I_y v + I_t) - alpha Delta u = 0, I_y (I_x u + I_y v + I_t) - alpha Delta v = 0) $
]

其中 $Delta u, Delta v$ 为 $u, v$ 的拉普拉斯算子。

== 迭代求解公式

利用高斯-赛德尔迭代求解：

#formula[
  $ u^((k+1)) = bar(u)^((k)) - (I_x (I_x bar(u)^((k)) + I_y bar(v)^((k)) + I_t)) / (alpha^2 + I_x^2 + I_y^2) $

  $ v^((k+1)) = bar(v)^((k)) - (I_y (I_x bar(u)^((k)) + I_y bar(v)^((k)) + I_t)) / (alpha^2 + I_x^2 + I_y^2) $
]

其中 $bar(u)^((k)), bar(v)^((k))$ 为邻域内光流平均值，$alpha^2$ 防止分母过小。

== 算法步骤

+ 预处理：计算 $I_x, I_y$（Sobel）和 $I_t$（帧间差分）。
+ 初始化 $u = 0, v = 0$。
+ 迭代更新：计算邻域均值 $bar(u), bar(v)$，按公式更新 $u, v$，直至收敛。

= Lecture 11 核心速查（开卷考试直接抄用）

#strong[1. 光流定义：]运动矢量 $bold(v) = [u, v]^T$，$I(x, y, t)$

#strong[2. 亮度恒常性：]$I_x u + I_y v + I_t = 0$，$nabla I^T bold(v) + I_t = 0$

#strong[3. 孔径问题：]一个方程两个未知数，平坦→无运动，边缘→法向分量，角点→唯一解

#strong[4. Lucas-Kanade：]局部平滑假设，$A^T A bold(x) = A^T bold(b)$，结构张量可逆时求解

#strong[5. Horn-Schunck：]全局平滑假设，能量泛函 $E = integral integral [(I_x u + I_y v + I_t)^2 + alpha(|nabla u|^2 + |nabla v|^2)] dif x dif y$

#strong[6. HS 迭代公式：]$u^((k+1)) = bar(u)^((k)) - (I_x (I_x bar(u)^((k)) + I_y bar(v)^((k)) + I_t)) / (alpha^2 + I_x^2 + I_y^2)$

#strong[7. LK vs HS：]LK 局部恒定、超定方程最小二乘；HS 全局平滑、能量泛函迭代求解。

// ================================================================
// 【补3】KLT 跟踪器 — LK 的改进
// ================================================================

= 【补3】KLT（Kanade-Lucas-Tomasi）跟踪器

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== KLT 核心思想

KLT 在 LK 光流基础上做了#strong[三大改进]：

- #strong[特征点筛选（"好"特征选择）：]不计算所有像素的光流，只选择"可跟踪"的特征点 — 要求结构张量 $A^T A$ 的#strong[两个特征值都大]（即角点），确保方程可解且解稳定。
- #strong[金字塔 LK（Pyramidal LK）：]LK 假设小运动，但实际运动可能很大。从低分辨率粗估计 → 逐级上采精修，多尺度处理大位移。
- #strong[仿射变换模型：]LK 假设平移($u,v$)恒定；KLT 进一步引入#strong[6 参数仿射变换] $x' = D x + d$，处理旋转、缩放、剪切变形。

== KLT 算法步骤

+ 步骤 1：检测"好"特征点（如 Harris 角点或 $min(lambda_1, lambda_2) > lambda_"thr"$）。
+ 步骤 2：构建图像金字塔（高斯下采样）。
+ 步骤 3：从最粗层开始，每层做 LK 计算光流，将结果传给下一层精细计算。
+ 步骤 4：逐帧跟踪特征点，剔除被遮挡或匹配误差大的点。

== 与 LK 和 HS 的对比

- LK：局部恒定、小运动、最小二乘。
- HS：全局平滑、变分能量最小化。
- #strong[KLT：带特征筛选的 LK + 金字塔 + 仿射模型。]

= 立体视觉深度恢复原理

== 深度恢复几何模型

假设两台相机水平放置，光轴平行，焦距 $f$，基线 $B$（光心距离）。三维点 $Q(X, Y, Z)$ 在左右像面的投影：

#formula[
  $ x = f X/Z quad x' = f (B - X)/Z $

  视差：$ d = x' - x = (f B)/Z $

  深度：$ Z = (f B)/d $
]

#strong[结论：]深度 $Z$ 与视差 $d$ 成#strong[反比]（视差越大物体越近），与 $f$ 和 $B$ 成正比。

== 单目局限性

单目小孔成像 $x = K [R|t] X$ 无法恢复深度，因为不同深度的点可能投影到同一像素坐标。双目通过引入第二个相机打破深度模糊。

= 对极几何（Epipolar Geometry）

== 基本元素

- #strong[光心：]$O_1, O_2$，相机的光学中心。
- #strong[基线：]连接 $O_1$ 和 $O_2$ 的直线。
- #strong[极点（Epipole）：]$e_1$ 为 $O_2$ 在左图的投影，$e_2$ 为 $O_1$ 在右图的投影。
- #strong[极平面（Epipolar Plane）：]空间点 $X$ 与两光心决定的平面。
- #strong[极线（Epipolar Line）：]极平面与图像平面的交线 $l_1, l_2$。

== 极线约束

若已知左图点 $x_1$，则右图对应点 $x_2$ 必然在#strong[极线 $l_2$]上。搜索范围从#strong[2D 全图]缩小到#strong[1D 直线]，极大提升效率。

= 本质矩阵与基础矩阵

== 本质矩阵（Essential Matrix, $E$）

由共面条件推导极线约束 $hat(x)^T E hat(x)' = 0$：

#formula[$ E = [t]_(times) R $]

其中 $[t]_(times)$ 为平移向量 $t$ 的反对称矩阵，$R$ 为旋转矩阵。

#strong[性质：]需已知内参（归一化坐标）；秩为 2；平移具有尺度模糊性（模长为 1）。

== 基础矩阵（Fundamental Matrix, $F$）

将归一化坐标代回像素坐标，消去内参：

#formula[
  $ F = K^(-T) E K'^(-1) $

  极线约束：$ x^T F x' = 0 $

  秩约束：$ det(F) = 0 $（自由度：$9 - 1 - 1 = 7$）
]

#strong[性质：]无需已知内参；将左图像点映射到右图极线；精度不如 $E$。

== $E$ vs $F$ 对比

- #strong[$F$：]不需要内参，适用于粗匹配，精度不足。
- #strong[$E$：]需已知内参，可恢复旋转和平移，适用于精确三维重建。

== 基础矩阵与本质矩阵的转换

#formula[$ E = K^T F K' $]


= 8 点法求解基础矩阵（含 RANSAC）

== 算法步骤

+ 步骤 1（构方程组）：对 8 组以上匹配点构建 $A f = 0$（$f$ 为 $F$ 的 9 个元素）。
+ 步骤 2（SVD 初始解）：$A = U Sigma V^T$，$V$ 最后一列对应最小奇异值的向量为初始解。
+ 步骤 3（强制秩约束）：将 $F_("alg")$ 的 SVD 分解中最小的奇异值 $sigma_3$ 置为 0：$F = U "diag"(sigma_1, sigma_2, 0) V^T$。

== RANSAC 剔除异常值

+ 随机抽取 8 对匹配点计算 $F$。
+ 代入剩余点计算误差 $x^T F x'$，误差小于阈值为内点。
+ 重复迭代，选内点最多的模型。

= 立体图像校正与稠密匹配

== 立体校正（Stereo Rectification）

通过两个单应性矩阵将左右图像重投影，使#strong[极线水平对齐]，对应点位于同一条水平扫描线上，搜索从 2D 降为 1D。

== 稠密匹配（基于相似性）

在左图沿水平极线取窗口 → 在右图同一水平线滑动 → 计算匹配代价。

#formula[
  SSD（平方差之和）：$ sum (I_1 - I_2)^2 $（越小越匹配）

  NCC（归一化互相关）：$ sum (I_1 - bar(I)_1)(I_2 - bar(I)_2) / sqrt(sum (I_1 - bar(I)_1)^2 sum (I_2 - bar(I)_2)^2) $（越接近 1 越匹配）
]

最终通过 $Z = f B / d$ 恢复深度图。

// ================================================================
// 【补4】三角测量与相机标定
// ================================================================

= 【补4】三角测量与相机标定

#warn[
  #strong[说明：]本章节为补充内容，PPT 中未涉及，但属于计算机视觉课程常见考点。
]

== 三角测量（Triangulation）

已知两个相机的投影矩阵 $P_1, P_2$ 及其匹配点对 $(x_1, x_2)$，反算 3D 点 $X$。

#strong[线性方法（SVD 求解）：]

从投影方程 $x_1 = P_1 X$，$x_2 = P_2 X$，交叉积去齐次因子：

#formula[$ x_1 times (P_1 X) = 0 quad x_2 times (P_2 X) = 0 $]

展开得 $A X = 0$（$A$ 为 $4 times 4$ 矩阵）。对 $A$ 做 SVD，$A = U Sigma V^T$，最小奇异值对应的 $V$ 最后一列即为 $X$ 的齐次坐标。

#strong[几何意义：]两相机的反投影射线因噪声不一定完美相交时，$X$ 为两条射线的"最近点"（最小化重投影误差）。

== 针孔相机模型（完整投影链）

从世界坐标 $X_w$ 到像素坐标 $(u,v)$：

#formula[$ s mat(u; v; 1) = K [R | t] mat(X_w; Y_w; Z_w; 1) $]

#strong[内参矩阵 $K$（必考）：]

#formula[$ K = mat(f_x, s, c_x; 0, f_y, c_y; 0, 0, 1) $]

- $f_x, f_y$：用像素单位表示的焦距（$f_x = f / p_x$，$p_x$ 为像素物理宽度）。
- $c_x, c_y$：主点坐标（光轴与像平面的交点，通常接近图像中心）。
- $s$：倾斜参数（通常为 0）。

#strong[外参 $[R|t]$：]旋转矩阵 $R$ + 平移向量 $t$，将世界坐标变换到相机坐标。

== 张正友标定法（必考流程）

用#strong[平面棋盘格]采集多张不同位姿的图像，分为#strong[四步]：

+ #strong[步骤 1 — 求单应性矩阵 $H$：]棋盘格为平面（$Z_w = 0$），简化投影 $s tilde(m) = K[r_1 r_2 t] tilde(M)$，每张图得一个 $H$。
+ #strong[步骤 2 — 求内参 $K$：]利用旋转矩阵列的正交性约束 $h_1^T K^(-T) K^(-1) h_2 = 0$ 及 $h_1^T K^(-T) K^(-1) h_1 = h_2^T K^(-T) K^(-1) h_2$。至少 3 张图可解 $K$。
+ #strong[步骤 3 — 求外参：]用 $K$ 和 $H$ 反算每张图的 $R, t$。
+ #strong[步骤 4 — 求畸变系数：]考虑径向/切向畸变，做非线性优化（Levenberg-Marquardt）最小化重投影误差。

#strong[径向畸变模型：]
#formula[$ x_c = x(1 + k_1 r^2 + k_2 r^4 + k_3 r^6) $ 其中 $r^2 = x^2 + y^2$]

畸变特征：$k < 0$ → 桶形畸变（广角）；$k > 0$ → 枕形畸变（长焦）。

= Lecture 13 核心速查（开卷考试直接抄用）

#strong[1. 视差与深度：]$d = f B / Z$，$Z = f B / d$，深度与视差成反比

#strong[2. 极线约束：]对应点必在极线上，2D→1D 搜索

#strong[3. 本质矩阵 $E$：]$E = [t]_(times) R$，秩 2，需内参，可恢复旋转平移

#strong[4. 基础矩阵 $F$：]$F = K^(-T) E K'^(-1)$，$x^T F x' = 0$，$det(F) = 0$，自由度 7

#strong[5. 8 点法：]SVD 解 $A f = 0$，最小奇异值置零强制秩约束

#strong[6. 匹配代价：]SSD（平方差和）、NCC（归一化互相关，对光照鲁棒）

= 3D 数据表示分类

- #strong[显式（Explicit）：]直接定义空间位置或几何表面。如点云、网格、参数化曲面。
- #strong[隐式（Implicit）：]通过函数 $f(x,y,z) = 0$ 描述几何。如体素、水平集、符号距离场、神经辐射场。
- #strong[参数化：]通过有限控制参数定义形状。如贝塞尔曲面。
- #strong[非参数化：]通过离散采样点逼近形状。

= 显式表示

== 点云（Point Clouds）

由三维坐标点 $(x,y,z)$ 的集合组成，有时附带法向量（点元 Surfel）。优点：采集简单、灵活。缺点：噪声大、#strong[无拓扑结构]、难以渲染平滑表面。

== 网格（Mesh）

使用顶点、边和三角形面表示表面。拓扑操作：上采样（细分 Subdivision）、下采样（简化 Simplification）、正则化（改善网格质量）。

== 参数化曲线与曲面

#formula[
  圆：$ bold(p)(t) = r (cos(t), sin(t)), quad t in [0, 2 pi) $

  球体：$ bold(s)(u, v) = r (cos(u) cos(v), sin(u) cos(v), sin(v)), quad (u,v) in [0, 2 pi) times [-pi/2, pi/2] $
]

- #strong[贝塞尔曲线/曲面：]通过控制点定义光滑曲线/曲面，曲线被控制点"吸引"。
- #strong[细分曲面：]从粗糙控制网格出发，递归细分生成光滑极限曲面。

== 显式特性

采样容易、存储位置关系、修改直观。缺点：细节受限于离散单元数量，内存占用大。

= 隐式表示

== 代数隐式

形状满足 $f(x,y,z) = 0$（如球体 $x^2 + y^2 + z^2 = 1$）。

#strong[特性：]内外判断容易（$f < 0$ 内部，$f > 0$ 外部）；采样困难；支持布尔操作（交/并/差）；可实现平滑融合：

#formula[$ phi = 1/k log(e^(k F_1) + e^(k F_2)) $]

== 体素（Voxel）

三维均匀网格，每格存储占据信息。类似 3D 像素。适合体积数据和医学成像。缺点：分辨率受限、存储量大。

== 隐式神经场（Neural Fields）

用 MLP 模拟连续函数，输入 3D 坐标（+ 观察方向），输出几何信息。

- #strong[占据场（Occupancy Field）：]输出点被占据的概率。
- #strong[符号距离场（SDF）：]输出点到最近表面的距离（内部为负，外部为正）。

优势：连续、无分辨率限制、可表达任意拓扑；缺点：渲染慢。

= NeRF（神经辐射场）

== 核心思想

NeRF（ECCV 2020）用于#strong[新视图合成]。输入多张 2D 图像，通过优化神经场渲染任意新视角。

输入：5D 坐标 $(x,y,z,theta,phi)$ → 输出：RGB 颜色 $bold(c)$ 和体积密度 $sigma$。

#strong[网络结构：]位置编码 → MLP → 密度 $sigma$ + 特征；特征 + 方向编码 → MLP → RGB（#strong[密度仅与位置相关，颜色与位置和方向相关]）。

== 体渲染方程

#strong[连续积分公式：]

#formula[$ C(bold(r)) = integral_(t_n)^(t_f) T(t) sigma(bold(r)(t)) bold(c)(bold(r)(t), bold(d)) dif t $]

其中透明度项 $T(t)$ 为光线不碰到粒子的概率：

#formula[$ T(t) = exp(-integral_(t_n)^t sigma(bold(r)(s)) dif s) $]

#strong[离散数值近似：]

#formula[
  $ hat(C)(bold(r)) = sum_(i=1)^N T_i (1 - exp(-sigma_i delta_i)) bold(c)_i $

  $ T_i = exp(-sum_(j=1)^(i-1) sigma_j delta_j) $
]

其中 $delta_i = t_(i+1) - t_i$ 为采样点间距。

== 粗-细采样

- #strong[粗采样：]沿射线均匀采样 64 点，获粗略密度分布。
- #strong[细采样：]根据密度分布做重要度采样（逆变换），额外采样 128 点，共 192 点恢复高频细节。

= 3D 高斯泼溅（3DGS）

== 核心思想

3DGS（2023）使用#strong[各向异性 3D 高斯分布（椭球）]表示场景，实现#strong[实时渲染]。

== 高斯体属性

- 位置 $(mu_x, mu_y, mu_z)$、协方差矩阵（拉伸与旋转）、不透明度 $alpha$、球谐系数（方向相关颜色）。

== 渲染流程

+ 从多视角图像用 SfM 初始化稀疏点云。
+ 将 3D 高斯体投影到 2D 图像平面（椭圆光斑）。
+ 按深度排序，通过 #strong[Alpha 混合]合成像素颜色。
+ 计算损失反向传播，优化高斯体属性；自适应#strong[分裂或克隆]高斯体以适应高频细节。

== NeRF vs 3DGS

- #strong[质量：]3DGS 通常超越或持平 NeRF。
- #strong[速度：]3DGS 100+ FPS（实时），NeRF 数秒/帧。
- #strong[训练：]3DGS 分钟级，NeRF 小时/天级。
- #strong[表示：]NeRF 隐式连续场，3DGS 显式离散高斯体集合。

// ================================================================
// 七十三、SfM（运动恢复结构）
// ================================================================

= 七十三、SfM（运动恢复结构）

从无序 2D 照片反推相机位姿并生成#strong[稀疏 3D 点云]：

+ 特征检测与提取（SIFT）。
+ 特征匹配。
+ 几何验证与相机模型匹配（对极几何）。
+ 稀疏重建：三角测量 + #strong[光束法平差（Bundle Adjustment）]。
+ 稠密重建（可选）：MVS 多视图立体。

// ================================================================
// 七十四、3D 数据集
// ================================================================

= 七十四、3D 数据集（代表性）

- #strong[ShapeNet：]300 万 3D 模型，51.3k（ShapeNetCore），55 类。
- #strong[Objaverse / Objaverse-XL：]80 万 ~ 1000 万 3D 物体。
- #strong[Object Scan：]10933 个 RGBD 样本，441 个高质量扫描。
- #strong[MVImgNet：]数十万组多视角图像序列。

// ================================================================
// 七十五、Lecture 13_3 核心速查
// ================================================================

= 七十五、Lecture 13_3 核心速查（开卷考试直接抄用）

#strong[1. 显式 vs 隐式：]显式（点云/网格/参数化）直接定义几何；隐式（$f(x,y,z)=0$）通过函数描述

#strong[2. 参数化曲线：]$bold(p)(t) = r(cos t, sin t)$，曲面 $bold(s)(u,v) = r(cos u cos v, sin u cos v, sin v)$

#strong[3. 隐式神经场：]占据场（概率）、SDF（带符号距离）

#strong[4. NeRF 体渲染：]$C(bold(r)) = integral T(t) sigma bold(c) dif t$，$T(t) = exp(-integral sigma dif s)$，离散 $hat(C) = sum T_i (1 - e^(-sigma_i delta_i)) bold(c)_i$

#strong[5. 3DGS：]3D 高斯椭球 + Alpha 混合渲染，100+ FPS，分钟级训练

#strong[6. SfM 流程：]SIFT → 匹配 → 几何验证 → 三角测量 + Bundle Adjustment → 稀疏点云

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

// ================================================================
// 考前综合提示
// ================================================================

= 考前综合提示

#strong[Lecture 02 重点：]直方图均衡化计算大题 — #strong["概率密度 → 累计求和 → 乘 $(L-1)$ 并四舍五入 → 合并同类项"]，将表格画在草稿纸上一步步算即可。

#strong[Lecture 03 重点：]Canny 边缘检测 5 步流程必须熟记（#strong[高斯平滑 → 梯度计算 → 非极大值抑制 → 双阈值 → 边缘连接]），Sobel/拉普拉斯算子模板必须能默写。

#strong[Lecture 04 重点：]Harris 角点响应函数 $R$ 公式和判定规则必背；SIFT 算法 4 大步骤（#strong[尺度空间极值检测 → 关键点定位 → 方向分配 → 128 维描述符]）与金字塔层数 $S+3$ 必考。

#strong[Lecture 05 重点：]RANSAC 5 步流程必考（#strong[随机采样 → 拟合 → 统计内点 → 迭代保留最优 → 输出最优模型]）；变换模型自由度（#strong[相似 4 / 仿射 6 / 单应性 8]）和霍夫变换直线方程 $rho = x cos theta + y sin theta$ 必背。

#strong[Lecture 06 重点：]MLP 解决 XOR（引入隐藏层）；CNN 三大特性（#strong[稀疏交互、参数共享、平移等变性]）；经典网络结构（#strong[LeNet → AlexNet → VGG → GoogLeNet → ResNet → DenseNet → U-Net]）；ResNet 残差学习 $cal(H)(x) = F(x) + x$。Transformer 自注意力公式 $"Attention"(Q, K, V) = "softmax"( Q K^T / sqrt(d_k) ) V$。对比学习 InfoNCE。PyTorch 动态图。

#strong[Lecture 07 重点：]三分割任务定义（#strong[语义 / 实例 / 全景]）；DeepLab 空洞卷积 + ASPP；分割演进 R-CNN → Fast → Faster → Mask R-CNN，RoI Align 核心改进（双线性插值消除量化误差）。转置卷积公式 $partial L/(partial x) = C^T partial L/(partial y)$。

#strong[Lecture 08 重点：]ISP 流程 7 步（#strong[Raw → 去马赛克 → 降噪 → 白平衡 → 色调映射 → sRGB → JPEG]）；动态范围 $"DR" = 20 log_10 (B_"max" / B_"min")$（dB）；图像退化模型 $y = H x + n$；评价指标 PSNR、SSIM、LPIPS；DnCNN 残差学习去噪。

#strong[Lecture 09 重点：]Snell 定律 $n_1 sin theta_i = n_2 sin theta_t$；噪声分类（#strong[散粒/暗电流/读出/量化]）；GAN 极小极大博弈 $min_G max_D EE[log D(x)] + EE[log(1 - D(G(z)))]$，收敛时 $D_G^*(x) = 1/2$，$C(G) = -log 4$；StyleGAN（映射 + AdaIN）→ StyleGAN2（路径正则化）→ StyleGAN3（平移不变）。

#strong[Lecture 11 重点：]光流约束方程 $I_x u + I_y v + I_t = 0$；孔径问题。Lucas-Kanade（#strong[局部平滑 + 最小二乘 $A^T A x = A^T b$]）。Horn-Schunck（#strong[全局平滑 + 能量泛函 $E = integral integral [(I_x u + I_y v + I_t)^2 + alpha(|nabla u|^2 + |nabla v|^2)] dif x dif y$] + 迭代求解）。

#strong[Lecture 13 重点：]视差与深度 $Z = f B / d$；极线约束 2D→1D。本质矩阵 $E = [t]_(times) R$（需内参，秩 2）；基础矩阵 $F = K^(-T) E K'^(-1)$（$x^T F x' = 0$，$det(F) = 0$，自由度 7）。8 点法（SVD + 最小奇异值置零）+ RANSAC 剔除异常值。SSD / NCC 匹配代价。

#strong[Lecture 13_3 重点：]显式 vs 隐式表示。NeRF 体渲染方程 $C(bold(r)) = integral T(t) sigma bold(c) dif t$，透明度 $T(t) = exp(-integral sigma dif s)$。3DGS（各向异性高斯椭球 + Alpha 混合，实时渲染）。SfM 流程（SIFT → Bundle Adjustment → 稀疏点云）。

#strong[Lecture 16 重点：]贝叶斯先验 $P(theta | X) prop P(X | theta) P(theta)$；TV 损失一维/二维公式；CNN 强/ ViT 弱归纳偏置。Noise2Noise 自监督去噪。GAN 反演 $G(w) approx x$；LoRA 参数高效微调 $h = W_0 x + B A x$。StyleCLIP（文本引导图像生成）。

#strong[生成模型重点：]VAE 重参数化 $z = mu + sigma dot epsilon$；VQ-VAE 离散 Codebook；归一化流 $p_(x)(x) = p_(z)(f^(-1)(x)) dot |det J|$；扩散模型 $x_t = sqrt(bar(alpha)_t) x_0 + sqrt(1 - bar(alpha)_t) z$，训练预测噪声 $L_"simple" = EE[norm(z - z_theta)^2]$。Stable Diffusion 潜在扩散 + 交叉注意力。视觉自回归（VQ-VAE + Token 序列）。

= 【补】补充章节重点速查

#tip[
  以下 9 个补充章节为 PPT 之外的扩展内容，根据老师"30% 题目不在 PPT 中"的提示整理，请重点关注。
]

#strong[【补1】频域处理：]2D DFT 公式、卷积定理（空间卷积 = 频域乘积）、理想/巴特沃斯/高斯低通滤波器、同态滤波。

#strong[【补2】形态学：]腐蚀（缩小亮区）、膨胀（扩大亮区）、开运算（去毛刺）、闭运算（补空洞）、形态学梯度/顶帽/黑帽变换。

#strong[【补3】KLT 跟踪器：]特征筛选（选角点）+ 金字塔 LK（处理大位移）+ 仿射模型。较 LK/HS 的改进点必考。

#strong[【补4】三角测量与相机标定：]SVD 求解 $A X = 0$、针孔相机模型 $K[R|t]$、内参 $K$（$f_x, f_y, c_x, c_y, s$）、张正友标定四步、径向畸变 $x_c = x(1 + k_1 r^2 + k_2 r^4)$。

#strong[【补5】一阶段检测器：]YOLO 核心思想（回归直接输出）、YOLO vs Faster R-CNN 对比（速度/精度）、Focal Loss $"FL"(p_t) = -alpha_t (1-p_t)^gamma log(p_t)$、FPN 三路径（自底向上 + 自顶向下 + 横向连接）、Soft-NMS。

#strong[【补6】彩色空间：]RGB/HSV/Lab/YCrCb 特性对比、灰世界/完美反射假设、伪彩色增强。

#strong[【补7】数据增强：]几何增强、色彩增强、MixUp / CutMix / CutOut / Mosaic（YOLOv4）/ RandAugment。

#strong[【补8】检测/分割评价指标：]IoU = $|A∩B| / |A∪B|$、mAP@"IoU"、mIoU（语义分割）、PSNR/SSIM/LPIPS/FID 已见正文章节。

#strong[【补9】图像插值：]最近邻（方块）→ 双线性（平滑模糊）→ 双三次（较清晰）→ Lanczos（理论最优）。质量与速度的 tradeoff。
