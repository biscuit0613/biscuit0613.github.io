#import "@preview/ilm:2.1.0": *

#set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: 10pt)
#show raw: set text(font: ("JetbrainsMono NF"))
#set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
#set heading(numbering: none)
#set math.equation(numbering: none)

#let cvimg(name) = image("../src/content/posts/CV/assets/" + name)
#let camimg(name) = image("../src/content/posts/camera/" + name)

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
  title: [计算机视觉 开卷考试速查手册 — 立体视觉与 3D 篇],
  authors: "Biscuit · Alkaid",
  date: datetime(year: 2026, month: 07, day: 05),
  abstract: [
     本文档包含立体视觉与三维视觉内容，涵盖：立体视觉深度恢复（$Z = f B/d$）、对极几何、本质矩阵 $E$ 与基础矩阵 $F$、8 点法求解、立体校正与稠密匹配（SSD/NCC）、【补4】三角测量与张正友相机标定、3D 数据表示（点云/网格/隐式场）、NeRF 神经辐射场（体渲染方程）、3D 高斯泼溅（3DGS）、SfM 运动恢复结构。适合开卷考试快速查阅。
  ],
  chapter-pagebreak: false,
)

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

#figure(cvimg("image-9.png"), caption: [对极几何示意图 — 双目相机与空间点])
#figure(cvimg("image-10.png"), caption: [对极几何元素：极点、极线、极平面])

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

#pagebreak()

= 立体图像校正与稠密匹配

#figure(cvimg("image-11.png"), caption: [极线校正与立体匹配流程])

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

#figure(camimg("小孔模型.png"), caption: [针孔相机成像模型 — 相似三角形关系])

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

#figure(camimg("相机畸变.png"), caption: [径向畸变示意：桶形畸变与枕形畸变])

= Lecture 13 核心速查（开卷考试直接抄用）

#strong[1. 视差与深度：]$d = f B / Z$，$Z = f B / d$，深度与视差成反比

#strong[2. 极线约束：]对应点必在极线上，2D→1D 搜索

#strong[3. 本质矩阵 $E$：]$E = [t]_(times) R$，秩 2，需内参，可恢复旋转平移

#strong[4. 基础矩阵 $F$：]$F = K^(-T) E K'^(-1)$，$x^T F x' = 0$，$det(F) = 0$，自由度 7

#strong[5. 8 点法：]SVD 解 $A f = 0$，最小奇异值置零强制秩约束

#strong[6. 匹配代价：]SSD（平方差和）、NCC（归一化互相关，对光照鲁棒）


#pagebreak()

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


