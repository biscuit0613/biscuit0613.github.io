# AGENT-writing.md — 博客知识体系架构与写作指南

> **用途**: 为 AI Agent 提供博客知识体系全貌，保证 Agent 在创建/更新文章后能够同步更新此文件。
> **最后更新**: 2026-07-20
> **总文章数**: 254 篇（含 18 篇草稿）
> **分类数**: 14 个有效分类（2 个空目录预留给未来内容）

---

## 一、目录结构与分类映射

```
docs/
├── AGENT-writing.md          ← 本文件（不会作为博客文章被 Astro 收录）

src/content/posts/
├── cnn/                      # 卷积神经网络架构 (11篇)
├── compute-perf/             # [空] 预留给计算性能
├── computer-vision/          # 计算机视觉 (39篇)
├── cs-core/                  # 计算机核心基础 (46篇)
├── dl-basics/                # 深度学习基础/模式识别 (19篇)
├── dl-computation/           # [空] 预留给深度学习计算
├── math/                     # 数学基础 (63篇)
├── minimind/                 # MiniMind 项目源码导读与训练实践 (4篇)
├── misc/                     # 杂项 (4篇)
├── nlp/                      # 自然语言处理 (6篇)
├── optimization/             # 优化理论 (9篇)
├── paper-reading/            # 论文阅读笔记 (6篇)
├── programming/              # 编程/工具 (29篇)
├── reinforcement-learning/   # 强化学习 (5篇)
├── rnn/                      # 循环神经网络 (6篇)
└── transformer/              # Transformer 架构 (7篇)
```

### 文件命名规范

- 每篇文章一个 `.md` 文件，放在对应分类目录下
- 文件名使用英文，以 `-` 分隔单词，如 `self-attention.md`
- 同一主题系列文章用数字前缀，如 `RPC1:socket.md`、`RPC2:rpc-basics.md`
- 图片资源与 `.md` 文件放在同一目录下

---

## 二、知识体系架构

### 依赖关系图（学习路径）

```
                        ┌─────────────────┐
                        │    math (63)     │ ← 数学基础层
                        │ 线代/概率/复变   │
                        └────────┬────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
    ┌─────────────────┐ ┌──────────────┐ ┌──────────────────┐
    │  optimization   │ │   cs-core    │ │  programming     │
    │   凸优化/KKT     │ │ 算法/DS/网络  │ │  C++/Python/Rust  │
    │    (9篇)        │ │   (46篇)     │ │    (29篇)         │
    └────────┬────────┘ └──────┬───────┘ └────────┬─────────┘
             │                 │                  │
             ▼                 ▼                  ▼
    ┌──────────────────────────────────────────────────────┐
    │                    dl-basics (19)                     │ ← ML/DL 基础层
    │        模式识别、分类器、聚类、降维、贝叶斯            │
    └────────────────────────┬─────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌───────────────┐  ┌─────────────────┐  ┌──────────────────┐
│  cnn (11)     │  │ computer-vision │  │  rnn (6)         │
│ LeNet→ResNet  │  │ 滤波/分割/立体   │  │ LSTM/GRU/Seq2Seq │
│ DenseNet      │  │ GAN/光流/去噪   │  │                  │
│ U-Net/Attn    │  │   (39篇)        │  │                  │
└───────┬───────┘  └────────┬────────┘  └────────┬─────────┘
        │                   │                    │
        ▼                   ▼                    ▼
┌──────────────────────────────────────────────────────────┐
│                   transformer (7)                         │ ← 现代架构层
│          Self-Attention / Positional Encoding / ViT       │
└────────────────────────┬─────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
┌───────────────┐ ┌──────────────┐ ┌──────────────────────┐
│   nlp (6)     │ │rl (5)        │ │  paper-reading (6)   │
│ word2vec→BERT │ │ MDP→PPO→GRPO │ │ AI-for-Science 论文  │
└───────────────┘ └──────────────┘ └──────────────────────┘
```

### 各分类知识域详述

#### 1. `math` — 数学基础 (63篇)

**覆盖领域**: 线性代数、概率论与数理统计、复变函数、信息论
**关键主题**:

- 线性代数: 矩阵运算、向量空间、特征值/SVD、QR分解、范数、投影
- 概率论: 随机变量、分布函数、大数定律、中心极限定理、矩估计、极大似然估计
- 复变函数: 复数、解析函数、柯西积分、泰勒/洛朗级数、留数定理、傅里叶/拉普拉斯变换
- 信息论: 自信息量、信息熵、KL散度、交叉熵、互信息
**草稿**: 6篇（多为习题集）

#### 2. `cs-core` — 计算机核心基础 (46篇)

**覆盖领域**: 数据结构与算法、计算机系统(CSAPP)、网络与分布式系统、形式语言与自动机
**关键主题**:

- 数据结构: 线性表、树、图、哈希表、B/B+树、并查集
- 算法: 排序、最短路径、拓扑排序、哈夫曼编码
- CSAPP: 整数/小数表示、布尔代数、机器级编程
- 网络: TCP/UDP、IP、DNS、NAT
- 分布式: RPC、RAFT、一致性协议、分布式ML
- 形式语言: 正则语言、DFA/NFA
**草稿**: 1篇

#### 3. `computer-vision` — 计算机视觉 (39篇)

**覆盖领域**: 图像处理基础、特征检测、图像分割、立体视觉、光流、图像去噪、GAN、视觉先验
**关键主题**:

- 滤波: 卷积/互相关、平滑滤波、梯度/边缘检测
- 特征: Harris角点、Blob/SIFT、HOG/LBP
- 分割: 阈值/Otsu、Canny、K-means、分水岭、水平集、深度分割
- 立体视觉: 几何基础、对极几何、深度恢复
- 光流: Lucas-Kanade、Horn-Schunck、金字塔LK
- 去噪: 噪声模型、NLM/BM3D、DnCNN、FFDNet、CBDNet
- GAN系列: DCGAN/cGAN、StyleGAN、GAN反演、GAN编辑、WGAN
- 视觉先验: 低级视觉、损失函数、网络结构、生成先验
- 其他: 颜色空间、图像金字塔、HDR/Tone Mapping、ISP

#### 4. `dl-basics` — 深度学习基础 (19篇)

**覆盖领域**: 模式识别、分类器、聚类、降维、概率密度估计
**关键主题**:

- 线性分类器: 感知机、LMSE、SVM、多分类
- 非线性分类: 距离分类器、MLP
- 降维: PCA、kPCA、LDA、特征选择
- 概率方法: 贝叶斯分类器、高斯类条件密度、参数/非参数密度估计
- 聚类: 准则与算法
- 其他: 决策树(ID3/C4.5/CART)、深度学习组件、GAN介绍

#### 5. `cnn` — 卷积神经网络 (11篇)

**覆盖领域**: CNN架构演进史
**关键主题**: LeNet5 → AlexNet → VGG → GoogLeNet(Inception) → ResNet → DenseNet → U-Net
**扩展**: BatchNorm、通道注意力、空域注意力

#### 6. `rnn` — 循环神经网络 (6篇)

**覆盖领域**: 序列建模
**关键主题**: RNN基础、BPTT/梯度问题、GRU/LSTM、双向RNN、Seq2Seq、递归神经网络
**草稿**: 0篇

#### 7. `transformer` — Transformer 架构 (7篇)

**覆盖领域**: 现代注意力架构
**关键主题**: Self-Attention、位置编码、Add&Norm、FFN、ViT、Decoder-only Transformer、RoPE、RMSNorm、SwiGLU、GQA、KV Cache
**草稿**: 2篇

#### 8. `nlp` — 自然语言处理 (6篇)

**覆盖领域**: 词嵌入 → 预训练 → 微调
**关键主题**: word2vec(Skip-gram/CBOW)、GloVe/fastText/BPE、BERT预训练、BERT微调、NLP到LLM演进路线、自回归语言模型与CLM
**草稿**: 1篇

#### 9. `reinforcement-learning` — 强化学习 (5篇)

**覆盖领域**: RL基础 → 策略优化
**关键主题**: RL概念、MDP、贝尔曼方程、PPO(Clip机制)、GRPO(组内相对比较)

#### 10. `optimization` — 优化理论 (9篇)

**覆盖领域**: 凸优化、对偶理论、次梯度
**关键主题**: 凸集/凸函数/凸优化、线性规划、对偶问题、拉格朗日对偶/KKT、Fenchel对偶、次梯度、收敛条件、Bayes准则、检测准则
**草稿**: 2篇

#### 11. `paper-reading` — 论文阅读 (6篇)

**覆盖领域**: AI-for-Science
**语言**: 全部使用 `zh`
**关键主题**: AI Scientist v1/v2、MatMind、SAGA、GNN晶体预测、扩散模型晶体生成

#### 12. `programming` — 编程与工具 (29篇)

**覆盖领域**: 语言(C++/Java/Kotlin/Rust)、RM机器人、Linux、工具
**关键主题**: C++基础、Java/Kotlin、Rust/Cargo、CMake、RM系列(OpenCV/ROS2/YOLO/卡尔曼滤波/solvePnP)、Linux(CachyOS/distrobox/快照)、MC模组开发、Android开发、英语六级
**草稿**: 2篇

#### 13. `misc` — 杂项 (4篇)

**覆盖领域**: 博客模板、相机模型、食物、存储
**注意**: `misc/index.md` 是普通文章(Mizuki 模板指南)，不是目录索引

#### 14. `minimind` — MiniMind 项目 (4篇)

**覆盖领域**: MiniMind 源码、预训练、监督微调与偏好优化
**关键主题**: 项目总览、模型配置、Token Embedding、Decoder Block 前向传播、LM Head、Next-Token Loss、Q/K/V 投影、QK Norm、RoPE、GQA、KV Cache、因果掩码与 Flash Attention、Pre-training、SFT、DPO、loss mask、训练日志与成果整理
**草稿**: 0篇

---

## 三、文章 Frontmatter 规范

pnpm new-post <文章名> 脚本会自动规范

```yaml
---
title: 文章标题                    # 必填，支持中文
published: YYYY-MM-DD             # 必填，发布日期
description: ''                   # 可选，文章摘要（留空则自动截取正文）
image: ./cover.jpg                # 可选，封面图路径（相对于文章目录）
tags: [标签1, 标签2]              # 可选，标签数组
category: frontend                # 可选，默认为目录名
draft: false                      # 可选，草稿=true 不发布
order: 0                          # 可选，文章排序，数字越小越靠前,支持小数
pinned: false                     # 可选，置顶=true
lang: zh-CN                       # 可选，仅当与站点默认语言不同时设置
---
```

### 标签使用规范

- 标签应使用**中文关键词**，与文章主题直接相关
- 同一分类下标签应保持一致，便于聚合
- 不同分类共享的标签表示跨领域关联（如 `RM` 同时出现在 programming 和 math）
- 当前已使用的标签总数: **142个**

---

## 四、Agent 写作规范

### 创建新文章

1. **确定分类**: 根据知识体系架构图确定文章所属分类目录
2. **命名文件**: 英文命名，`-` 分隔，放在对应分类目录下
3. **编写 Frontmatter**: 按规范填写，至少包含 `title` 和 `published`
4. **添加标签**: 至少添加 1 个相关标签
5. **编写正文**: 使用 Markdown 格式，支持 Mermaid 图表、数学公式(LaTeX)、代码高亮、Admonitions
6. **更新本文**: 在对应分类下添加新文章条目，更新总计数

### 更新已有文章

1. 修改文章内容后，检查是否需要更新 `description`、`tags` 等 Frontmatter
2. 如果文章从一个分类移到另一个分类，同步更新本文

### 更新 `docs/AGENT-writing.md`

**每次创建/删除/修改文章后，必须同步更新本文的以下部分**:

- 第二节「各分类知识域详述」中对应分类的文章计数和关键主题
- 第三节「当前使用统计」中的相关计数
- 如果新增了标签，更新标签列表
- 更新「最后更新」日期

---

## 五、当前状态汇总

### 文章统计

| 分类                   | 文章数  | 草稿数 | 日期范围                |
| ---------------------- | ------- | ------ | ----------------------- |
| math                   | 63      | 6      | 2025-08-17 ~ 2026-05-15 |
| cs-core                | 46      | 1      | 2025-09-05 ~ 2026-06-17 |
| computer-vision        | 39      | 0      | 2026-05-25 ~ 2026-07-01 |
| programming            | 29      | 2      | 2022-07-01 ~ 2026-06-22 |
| dl-basics              | 19      | 0      | 2026-04-07 ~ 2026-07-03 |
| cnn                    | 11      | 0      | 2026-06-09 ~ 2026-06-28 |
| optimization           | 9       | 2      | 2026-04-29 ~ 2026-05-15 |
| paper-reading          | 6       | 0      | 2026-07-09 ~ 2026-07-15 |
| rnn                    | 6       | 0      | 2026-06-26 ~ 2026-06-27 |
| nlp                    | 6       | 1      | 2026-07-18              |
| transformer            | 7       | 2      | 2026-06-27 ~ 2026-07-19 |
| minimind               | 2       | 2      | 2026-07-20              |
| reinforcement-learning | 5       | 0      | 2025-11-02 ~ 2026-07-15 |
| misc                   | 4       | 0      | 2022-08-01 ~ 2026-05-22 |
| **总计**               | **252** | **16** | 2022-07-01 ~ 2026-07-20 |

### 空目录（预留给未来内容）

| 目录              | 预期用途                               |
| ----------------- | -------------------------------------- |
| `compute-perf/`   | 计算性能优化（CUDA、内存层级、量化等） |
| `dl-computation/` | 深度学习计算（自动微分、分布式训练等） |

### 草稿清单

| 分类        | 文件名                        | 标题                                 |
| ----------- | ----------------------------- | ------------------------------------ |
| cs-core     | net1_intro.md                 | 网络与分布式系统：第一章：网络的构成 |
| math        | Pt_2DrandVarExercises.md      | 2维随机变量及其分布 习题             |
| math        | Pt_1DranVarExercises.md       | 一维随机变量及其分布练习题           |
| math        | Cmplxfunc_exams.md            | 复变函数：习题与考试                 |
| math        | Pt_Chptr1Exercises.md         | 概率论第一章习题                     |
| math        | Matrix.md                     | 矩阵相关的知识点                     |
| math        | navigation.md                 | 线性代数知识导航                     |
| optimization | Bayes.md                     | 贝叶斯决策                           |
| optimization | Bayes-test.md                | 贝叶斯检测                           |
| programming | draft.md                      | Draft Example                        |
| programming | rust-cargo.md                 | rust-cargo                           |
| nlp         | 06-autoregressive-language-model.md | 自回归语言模型：从联合概率到下一个 Token 预测 |
| transformer | decoder-only-transformer.md | Decoder-only Transformer：从因果注意力到语言模型输出 |
| transformer | modern-llm-components.md | 现代 LLM 组件：RoPE、RMSNorm、SwiGLU、GQA 与 KV Cache |
| minimind | 01-model-forward-pass.md | MiniMind 代码导读（一）：从 Token IDs 到训练 Loss |
| minimind | 02-attention-forward-pass.md | MiniMind 代码导读（二）：Attention 的完整张量流 |

---

## 六、Agent 自更新指令

当 Agent 完成文章操作后，**必须**执行以下步骤更新本文:

1. 使用 `read` 工具读取 `docs/AGENT-writing.md`
2. 根据操作类型修改对应部分:
   - **新增文章**: 在对应分类下添加 `| 序号 | 标题 | 日期 | 标签 | 描述 |` 条目，更新计数字段
   - **修改文章**: 更新对应文章的标签、描述等信息
   - **删除文章**: 移除对应条目，更新计数
   - **修改草稿状态**: 移动文章在草稿/已发布列表之间
3. 更新「最后更新」日期
4. 使用 `edit` 或 `write` 工具保存修改

### 更新示例

新增一篇 `transformer` 分类的文章后，Agent 应:

1. 将 `transformer` 文章数从 5 更新为 6
2. 在「各分类知识域详述」的 transformer 部分添加关键主题
3. 更新总文章数从 247 到 248
4. 更新「最后更新」日期
