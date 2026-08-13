---
title: 'MiniMind 学习成果总览：从源码阅读到 Pre-training、SFT 与 DPO'
published: 2026-08-13
description: '汇总 MiniMind 项目的学习路径、代码注释、三阶段训练实践、成果链接与当前局限，作为科研实习申请材料入口'
image: ''
tags: [minimind, LLM, Pre-training, SFT, DPO, 项目总结]
category: '10-MiniMind项目'
order: 0
draft: false
lang: ''
---

| 材料 | 链接/位置 | 说明 |
| --- | --- | --- |
| 项目源码与个人 fork | [github.com/biscuit0613/minimind](https://github.com/biscuit0613/minimind) | 源码、训练脚本和学习型注释版本 |
| 模型前向传播笔记 | [从 Token IDs 到训练 Loss](/posts/minimind/01-model-forward-pass/) | 逐段追踪模型主干和语言模型损失 |
| Attention 笔记 | [Attention 的完整张量流](/posts/minimind/02-attention-forward-pass/) | 逐段解释 Q/K/V、RoPE、GQA、KV Cache |
| 训练实践笔记 | [从预训练到偏好对齐](/posts/minimind/03-training-pipeline/) | 记录环境、参数、日志、权重和问题 |
| 训练权重 | 个人 Hugging Face 链接（待补充） | 仅上传本人实际训练的权重，并附模型卡和训练说明 |
| 汇报材料 | PDF/PPT 附件 | 介绍项目结构、核心模块、训练结果和反思 |

##  学习内容

本项目围绕一个小型 Decoder-only 语言模型，完成了从源码阅读到训练实践的学习闭环：

- 模型结构：配置、Embedding、Decoder Block、Attention、RoPE、GQA、KV Cache 和 LM Head；
- 训练流程：Pre-training、SFT、DPO，以及数据处理和 loss mask；
- 工程实现：混合精度、梯度累积、梯度裁剪、checkpoint、日志和模型加载。

## 注释代码

个人 fork 中的 `*_annotated.py` 是关键代码的学习型注释版本，主要补充输入输出形状、对应的数学操作，以及修改代码可能造成的训练行为变化。它们用于展示源码理解，不替代项目原始实现。

## 实践摘要

我在 A100-80GB 环境下完成了 64M 配置的 Pre-training、SFT 和 DPO 实验，并保存了各阶段权重。详细参数、日志、耗时、权重文件和推理测试见[训练实践笔记](/posts/minimind/03-training-pipeline/)。

本次实验主要用于验证训练链路和理解代码机制。受数据规模、训练步数和评测设置限制，loss 下降不能直接等同于模型能力提升。
