---
title: '深度学习课程复习索引'
published: 2026-11-17
description: '机器学习概述与数据基础、浅层模型、网络优化、感知机与 BP、序列建模、CNN、GNN、生成式、强化学习与预训练模型'
image: ''
tags: [DL, Course, Index]
category: '01-深度学习基础'
order: 0
draft: false
lang: ''
---

| 讲次 | 课件主题 | 对应文章 | 缺口与补充 |
|---|---|---|---|
| 1 | 引论：机器学习/深度学习概念、发展史、与人工智能的关系 | 不专门整理 | 概念性内容，复习直接过课件 |
| 2 | 机器学习概述：GPU/CUDA 计算环境、数据集与标注一致性（Cohen/Fleiss kappa）、数据划分与交叉验证、有监督/无监督/半监督/主动学习 | [机器学习概述：计算环境、数据集与学习范式](/posts/dl-basics/ml-overview/) | 计算环境、kappa 数值例、留出法/K 折/分层/网格搜索、自训练与主动学习查询策略均已覆盖；范式划分另见 [三种学习范式](/posts/reinforcement-learning/rl_paradigms/)（草稿） |
| 3 | 分类与回归：P/R/F1/ROC、SVM、朴素贝叶斯、线性与多项式回归、正则化、逻辑回归 | [线性回归](/posts/dl-basics/linear-regression/)、[逻辑回归](/posts/dl-basics/linear-logistic/)、[感知机与 LMSE](/posts/dl-basics/linearclf/)、[线性 SVM](/posts/dl-basics/linearclf-svm/)、[核方法](/posts/dl-basics/kernel-methods/)、[高斯贝叶斯与朴素贝叶斯](/posts/dl-basics/bayes-gauss/)、[评价指标](/posts/nlp/05-01-evaluation-metrics/) | 多项式回归、多项式/伯努利朴素贝叶斯的课件例题未单独整理；NB 手算以课件为准 |
| 4 | 网络优化：熵/KL/JS、风险最小化、损失函数、GD/SGD/mini-batch、动量、激活函数、梯度消失与爆炸、过拟合与正则化、Dropout/早停/数据增强/集成 | [网络优化：目标函数、梯度下降、激活函数与泛化](/posts/dl-basics/network-optimization/)（按课件七节组织的总览与索引） | 总览正文内链到 [信息熵](/posts/dl-basics/informationtheory/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)、[SGD 及其变体](/posts/cs-core/dsml-sgd/)、[BatchNorm](/posts/cnn/cnn-batchnorm/)、[BPTT 与梯度消失](/posts/rnn/rnn-bptt/)、[ResNet](/posts/cnn/cnn-resnet/) 等专篇 |
| 5 | 感知机模型：感知机学习算法、逻辑门与异或、多层感知机、BP 四公式、小批量 BP | [感知机与 LMSE](/posts/dl-basics/linearclf/)、[多层感知机与 BP](/posts/dl-basics/nonlinear-mlpclf/) | 逻辑门/XOR 的构造例子未整理；BP 推导比课件更细 |
| 6 | 序列建模：RNN、LSTM/GRU、双向 RNN、注意力、Transformer、递归神经网络 | [RNN 基础](/posts/rnn/rnn-basic/)、[BPTT](/posts/rnn/rnn-bptt/)、[LSTM 与 GRU](/posts/rnn/rnn-gru-lstm/)、[双向 RNN](/posts/rnn/rnn-bialrnn/)、[Seq2Seq 与注意力](/posts/rnn/rnn-seq2seq/)、[递归神经网络](/posts/rnn/rnn-recursive/)、[自注意力](/posts/transformer/trasformer-attetion/)、[位置编码](/posts/transformer/trasformer-otherpartsinencoder/)、[Add&Norm](/posts/transformer/trasformer-otherpartsinencoder-addandnorm/)、[FFN](/posts/transformer/trasformer-otherpartsinencoder-ffn/) | 课件不含 BPTT 推导，博客补上了 |
| 7 | 卷积神经网络：卷积/池化、局部连接与参数共享、LeNet-5、AlexNet、VGG、ResNet | [CNN 概述](/posts/cnn/cnn/)、[LeNet-5](/posts/cnn/cnn-lenet5/)、[AlexNet](/posts/cnn/cnn-alexnet/)、[VGG](/posts/cnn/cnn-vggnet/)、[ResNet](/posts/cnn/cnn-resnet/)、[BatchNorm](/posts/cnn/cnn-batchnorm/) | TextCNN 未整理（课件一笔带过）；GoogLeNet、DenseNet、U-Net 是课件外扩展，已整理 |
| 8 | 图神经网络：消息传递、DeepWalk、LINE、GCN、GAT | [GCN 图神经网络](/posts/gcn/gcn/)（含 DeepWalk/LINE/GCN/GAT） | GraphSAGE 课件只列名；LINE 一阶/二阶相似度数值例在文内 |
| 9 | 生成式神经网络：自编码器、VAE、GAN、条件 GAN、DCGAN、pix2pix、CycleGAN | [生成式模型：从 AE/VAE 到 GAN 的范式框架](/posts/dl-basics/generative-paradigms/)、[DCGAN 与 cGAN](/posts/dl-basics/dcgan-cgan/)、[pix2pix 与 CycleGAN](/posts/dl-basics/pix2pix-cyclegan/) | 已全覆盖：AE/VAE/GAN 范式、cGAN/DCGAN、pix2pix/CycleGAN 三篇按课件顺序对应 |
| 10 | 强化学习与深度强化学习：MDP/贝尔曼、MC/TD、SARSA/Q-learning、DQN、AlphaGo Zero | [MDP 基础](/posts/reinforcement-learning/rl_basicconception/)、[贝尔曼方程](/posts/reinforcement-learning/rl_bellmanequation/)、[被动 RL](/posts/reinforcement-learning/rl_passiverl/)、[主动 RL](/posts/reinforcement-learning/rl_activerl/)、[DQN](/posts/reinforcement-learning/rl_dqn/)、[策略学习](/posts/reinforcement-learning/rl_policylearning/)、[Actor-Critic](/posts/reinforcement-learning/rl_actorcritic/)、[PPO](/posts/reinforcement-learning/ppo/)、[探索与内在奖励](/posts/reinforcement-learning/rl_exploration/)、[AlphaGo Zero 与 MCTS](/posts/reinforcement-learning/rl_alphago/)、[网格世界手算](/posts/reinforcement-learning/rl_gridworldexample/) | AlphaGo Zero 与 MCTS 已整理；完整索引见 [强化学习课程索引](/posts/reinforcement-learning/00-course-map/) |
| 11 | 预训练模型：迁移学习、N-gram、NNLM、Word2Vec、层次 Softmax/负采样、GPT、BERT | [统计语言模型](/posts/nlp/03-01-language-model/)、[NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)、[Word2Vec](/posts/nlp/06-02-word2vec/)、[ELMo](/posts/nlp/06-06-elmo/)、[GPT](/posts/nlp/06-08b-gpt/)、[BERT](/posts/nlp/06-07-bert/)、[预训练范式速览](/posts/nlp/06-08-pretrain-overview/) | 完整索引见 [NLP 课程索引](/posts/nlp/00-course-map/) |

## 覆盖自查

| 讲次 | 覆盖状态 | 说明 |
|---|---|---|
| 1 | 未专门整理 | 概念与历史，建议直接过课件 |
| 2 | 已覆盖 | [机器学习概述](/posts/dl-basics/ml-overview/) 覆盖环境、kappa、数据划分与半监督/主动学习 |
| 3 | 基本覆盖 | 多项式回归与 NB 两类平滑例题未单独整理 |
| 4 | 已覆盖 | [网络优化总览](/posts/dl-basics/network-optimization/) 按课件七节组织，细节内链到各专篇 |
| 5 | 已覆盖 | BP 推导完整 |
| 6 | 已覆盖 | 链式 RNN、递归神经网络与 Transformer 均有专篇 |
| 7 | 已覆盖 | 课件模型全覆盖，另有扩展 |
| 8 | 已覆盖 | GCN 一篇覆盖四种模型 |
| 9 | 已覆盖 | 宏观范式、DCGAN/cGAN、pix2pix/CycleGAN 三篇覆盖课件全部八节 |
| 10 | 已覆盖 | AlphaGo Zero 与 MCTS 已有专篇 |
| 11 | 已覆盖 | 博客比课件更全 |

## 习题集索引（259 题）

| 习题章节 | 题量 | 对应文章 | 备注 |
|---|---|---|---|
| 1 人工智能、机器学习、深度学习绪论 | 25 | 无专篇 | 概念题，看课件 |
| 2 机器学习概述 | 11 | [机器学习概述](/posts/dl-basics/ml-overview/) | 单选 3、多选 8，概念与流程题均可在文中定位 |
| 3 多层感知机 | 31 | [感知机与 LMSE](/posts/dl-basics/linearclf/)、[MLP 与 BP](/posts/dl-basics/nonlinear-mlpclf/) | 单选 27 |
| 4 网络优化（信息熵与损失） | 5 | [信息熵](/posts/dl-basics/informationtheory/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/) | 含交叉熵主观题 |
| 5 信息熵、激活函数与优化器 | 31 | [网络优化总览](/posts/dl-basics/network-optimization/) + [信息熵](/posts/dl-basics/informationtheory/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)、[SGD 及其变体](/posts/cs-core/dsml-sgd/)、[MLP 与 BP](/posts/dl-basics/nonlinear-mlpclf/) | 单选 30 |
| 6 建模序列数据的神经网络 | 9 | [RNN 基础](/posts/rnn/rnn-basic/)、[LSTM 与 GRU](/posts/rnn/rnn-gru-lstm/)、[自注意力](/posts/transformer/trasformer-attetion/) | 多选 5 + 单选 4 |
| 7 卷积神经网络 | 36 | [CNN 概述](/posts/cnn/cnn/) 及其模型篇 | 题量第一 |
| 8 卷积神经网络（随堂） | 4 | 同上 | 随堂练习 |
| 9 强化学习 | 29 | [MDP 基础](/posts/reinforcement-learning/rl_basicconception/)、[被动 RL](/posts/reinforcement-learning/rl_passiverl/)、[主动 RL](/posts/reinforcement-learning/rl_activerl/) | 折扣回报、贝尔曼主观题 |
| 10 生成式神经网络 | 6 | [生成式模型：从 AE/VAE 到 GAN 的范式框架](/posts/dl-basics/generative-paradigms/)、[DCGAN 与 cGAN](/posts/dl-basics/dcgan-cgan/)、[pix2pix 与 CycleGAN](/posts/dl-basics/pix2pix-cyclegan/) | VAE/GAN 原理主观题与各模型要点均已覆盖 |
| 11 深度强化学习 | 27 | [DQN](/posts/reinforcement-learning/rl_dqn/)、[策略学习](/posts/reinforcement-learning/rl_policylearning/)、[Actor-Critic](/posts/reinforcement-learning/rl_actorcritic/) | 单选 26 |
| 12 | 强化学习与深度强化学习（随堂） | 8 | [MDP 基础](/posts/reinforcement-learning/rl_basicconception/)、[被动 RL](/posts/reinforcement-learning/rl_passiverl/)、[探索与内在奖励](/posts/reinforcement-learning/rl_exploration/)、[AlphaGo Zero 与 MCTS](/posts/reinforcement-learning/rl_alphago/) | 主观 6 道，主观题最集中；含 AlphaGo Zero 原理题 |
| 13 预训练模型 | 2 | [NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)、[Word2Vec](/posts/nlp/06-02-word2vec/)、[BERT](/posts/nlp/06-07-bert/)、[GPT](/posts/nlp/06-08b-gpt/) | 两道全主观 |
| 14 图神经网络 | 35 | [GCN 图神经网络](/posts/gcn/gcn/) | 题量第二 |

## 按主题复习

### 数据与工程基础

[机器学习概述：计算环境、数据集与学习范式](/posts/dl-basics/ml-overview/)：GPU/CUDA 软件栈 → 数据集表示与标注一致性（Pearson/kappa）→ 留出法/K 折/分层/网格搜索 → 六种学习范式 → 自训练与主动学习。放在所有模型之前读。

### 浅层分类与回归

[线性回归](/posts/dl-basics/linear-regression/) → [逻辑回归](/posts/dl-basics/linear-logistic/) → [感知机与 LMSE](/posts/dl-basics/linearclf/) → [线性 SVM](/posts/dl-basics/linearclf-svm/) → [核方法](/posts/dl-basics/kernel-methods/) → [贝叶斯分类](/posts/dl-basics/bayes-gauss/)；评价指标贯穿：[评价指标](/posts/nlp/05-01-evaluation-metrics/)。

### 神经网络基础与优化

[感知机](/posts/dl-basics/linearclf/) → [MLP 与 BP](/posts/dl-basics/nonlinear-mlpclf/) → [网络优化总览](/posts/dl-basics/network-optimization/)（先读总览，再按需进入下列专篇） → [信息熵](/posts/dl-basics/informationtheory/) → [交叉熵与 KL](/posts/dl-basics/kldivergenceandcrossentropy/) → [SGD/动量/Adam](/posts/cs-core/dsml-sgd/) → [BPTT 与梯度消失](/posts/rnn/rnn-bptt/) → [BatchNorm](/posts/cnn/cnn-batchnorm/)；过拟合与正则化见 [线性回归](/posts/dl-basics/linear-regression/) 与 [ResNet](/posts/cnn/cnn-resnet/)。

### 序列与 Transformer

[RNN 基础](/posts/rnn/rnn-basic/) → [BPTT](/posts/rnn/rnn-bptt/) → [LSTM 与 GRU](/posts/rnn/rnn-gru-lstm/) → [双向 RNN](/posts/rnn/rnn-bialrnn/) → [Seq2Seq 与注意力](/posts/rnn/rnn-seq2seq/) → [递归神经网络](/posts/rnn/rnn-recursive/) → [自注意力](/posts/transformer/trasformer-attetion/) → [位置编码](/posts/transformer/trasformer-otherpartsinencoder/) → [Add&Norm](/posts/transformer/trasformer-otherpartsinencoder-addandnorm/) → [FFN](/posts/transformer/trasformer-otherpartsinencoder-ffn/)。

### CNN

[CNN 概述](/posts/cnn/cnn/) → [LeNet-5](/posts/cnn/cnn-lenet5/) → [AlexNet](/posts/cnn/cnn-alexnet/) → [VGG](/posts/cnn/cnn-vggnet/) → [ResNet](/posts/cnn/cnn-resnet/) → [BatchNorm](/posts/cnn/cnn-batchnorm/)；扩展：[GoogLeNet](/posts/cnn/cnn-goolenet/)、[DenseNet](/posts/cnn/cnn-densenet/)、[U-Net](/posts/cnn/cnn-sc-unet/)。

### 生成式

[生成式模型：从 AE/VAE 到 GAN 的范式框架](/posts/dl-basics/generative-paradigms/) → [DCGAN 与 cGAN](/posts/dl-basics/dcgan-cgan/) → [pix2pix 与 CycleGAN](/posts/dl-basics/pix2pix-cyclegan/)：先建立 AE/VAE/GAN 范式，再落到条件控制与卷积结构，最后做有监督与无监督的图像翻译。

### GNN

[GCN 图神经网络](/posts/gcn/gcn/) 一篇覆盖消息传递、DeepWalk、LINE、GCN、GAT，复习时对照课件的 LINE 数值例。

### 预训练模型

[统计语言模型](/posts/nlp/03-01-language-model/) → [NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/) → [Word2Vec](/posts/nlp/06-02-word2vec/) → [ELMo](/posts/nlp/06-06-elmo/) → [GPT](/posts/nlp/06-08b-gpt/) 与 [BERT](/posts/nlp/06-07-bert/)。

### 强化学习

[强化学习课程索引](/posts/reinforcement-learning/00-course-map/) 按复习要点组织，深度强化学习部分从 [MDP 基础](/posts/reinforcement-learning/rl_basicconception/) 一路到 [DQN](/posts/reinforcement-learning/rl_dqn/)。

## 待补清单

按期末复习优先级排序：

1. **第 3 讲多项式回归与多项式/伯努利 NB**：对照课件手算例题。
2. **第 7 讲 TextCNN**：课件一笔带过，优先级最低。

课程相关的草稿（本地 dev 可见，发布前需改 `draft: false`）：[三种学习范式](/posts/reinforcement-learning/rl_paradigms/)、[Decoder-only Transformer](/posts/transformer/decoder-only-transformer/)、[现代 LLM 组件](/posts/transformer/modern-llm-components/)。
