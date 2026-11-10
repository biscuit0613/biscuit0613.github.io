---
title: 'NLP 课程复习索引：课件与博客对应关系'
published: 2026-10-20
description: '按课程讲次整理 NLP 博客文章：统计 NLP、深度学习、预训练与 LLM 生命周期、知识增强、推理部署与应用适配的复习入口'
image: ''
tags: [NLP, Course, Index]
category: '09-自然语言处理'
order: 0
draft: false
lang: ''
---

| 讲次 | 课件主题 | 对应文章 | 外部笔记与补充 |
|---|---|---|---|
| 1 | 绪论 | 不整理 | 按约定跳过 |
| 2 | 基础理论：信息论、机器学习范式 | 无专门文章，概念分散在后续文章中 | [自信息量、联合熵与条件熵](/posts/dl-basics/informationtheory/)、[KL 散度与交叉熵](/posts/dl-basics/kldivergenceandcrossentropy/)、[困惑度](/posts/dl-basics/perplexity/)、[强化学习基础](/posts/reinforcement-learning/rl_basicconception/) |
| 3 | 统计建模与经典技术 | [统计语言模型](/posts/nlp/03-01-language-model/)、[词法分析](/posts/nlp/03-02-lexical-analysis/)、[句法分析与语义角色标注](/posts/nlp/03-03-syntax-semantics/)、[经典 NLP 任务](/posts/nlp/03-04-classic-tasks/) | 评价指标见 [NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/) |
| 4 | 深度学习基础 | 无专门文章，按网络类型分布在不同分类 | [CNN](/posts/cnn/cnn/)、[RNN 基础](/posts/rnn/rnn-basic/)、[BPTT](/posts/rnn/rnn-bptt/)、[GRU 与 LSTM](/posts/rnn/rnn-gru-lstm/)、[Seq2Seq](/posts/rnn/rnn-seq2seq/)、[自注意力](/posts/transformer/trasformer-attetion/)、[Transformer 编码器](/posts/transformer/trasformer-otherpartsinencoder/)、[Decoder-only Transformer](/posts/transformer/decoder-only-transformer/) |
| 5 | NLP 评价 | [NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)、[词向量的评价](/posts/nlp/05-02-embedding-evaluation/) | 大模型评价见 [大语言模型的评价](/posts/nlp/10-03-llm-evaluation/)；基础概念见 [困惑度](/posts/dl-basics/perplexity/) |
| 6 | 词向量与神经语言模型 | [词向量基础](/posts/nlp/06-01-word-representation/)、[Word2Vec](/posts/nlp/06-02-word2vec/)、[GloVe](/posts/nlp/06-03-glove/)、[子词分词](/posts/nlp/06-04-subword-tokenization/)、[NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/)、[ELMo](/posts/nlp/06-06-elmo/)、[BERT](/posts/nlp/06-07-bert/)、[预训练范式速览](/posts/nlp/06-08-pretrain-overview/)、[GPT](/posts/nlp/06-08b-gpt/)、[BART](/posts/nlp/06-09-bart/)、[BERT 微调实践](/posts/nlp/06-10-bert-finetune/) | SVD 数学基础：[奇异值分解](/posts/math/singularandsvd/)；ELMo 的序列建模：[LSTM](/posts/rnn/rnn-gru-lstm/) |
| 7 | 大模型预训练 | [LLM 预训练：框架与架构](/posts/nlp/07-01-llm-architecture/)、[大模型训练系统](/posts/nlp/07-02-llm-training-systems/) | 架构组件细节：[现代 LLM 组件](/posts/transformer/modern-llm-components/) |
| 8 | 有监督微调 SFT | [LLM 有监督微调](/posts/nlp/08-01-llm-sft/)、[参数高效微调](/posts/nlp/08-02-peft-lora/) | 提示与上下文学习：[提示工程](/posts/nlp/12-01-prompt-engineering/)；量化部署：[模型压缩](/posts/nlp/11-02-quantization-distillation/) |
| 9 | 大模型强化学习 | [RLHF 与 PPO](/posts/nlp/09-01-rlhf-ppo/)、[DPO](/posts/nlp/09-02-dpo/) | [MDP 与强化学习基础](/posts/reinforcement-learning/rl_basicconception/)、[PPO](/posts/reinforcement-learning/ppo/)、[GRPO](/posts/reinforcement-learning/grpo/) |
| 10 | 知识增强与模型评价 | [知识图谱](/posts/nlp/10-01-knowledge-graph/)、[知识增强的大语言模型](/posts/nlp/10-02-knowledge-enhanced-llm/)、[大语言模型的评价](/posts/nlp/10-03-llm-evaluation/) | 检索增强的工程实现：[RAG](/posts/nlp/12-03-rag/)；经典信息抽取：[经典 NLP 任务](/posts/nlp/03-04-classic-tasks/) |
| 11 | 推理部署 | [推理框架与部署](/posts/nlp/11-01-inference-frameworks/)、[量化与蒸馏](/posts/nlp/11-02-quantization-distillation/) | [现代 LLM 组件](/posts/transformer/modern-llm-components/)、[LoRA 与 QLoRA](/posts/nlp/08-02-peft-lora/) |
| 12 | 应用场景适配 | [提示工程](/posts/nlp/12-01-prompt-engineering/)、[CoT、ToT 与 GoT](/posts/nlp/12-02-cot-tot-got/)、[RAG](/posts/nlp/12-03-rag/)、[智能体](/posts/nlp/12-04-agent/)、[高级 RAG](/posts/nlp/12-05-rag-advanced/)、[模块化 RAG 与 RAG 增强](/posts/nlp/12-06-rag-modular/) | 课件只展开提示工程，RAG 按教材 12.2 拆成主线+两篇深入，智能体按教材目录补充；知识增强背景见 [知识增强的大语言模型](/posts/nlp/10-02-knowledge-enhanced-llm/) |

## 按主题复习

### 语言模型与预训练演进

[统计语言模型](/posts/nlp/03-01-language-model/) → [NNLM 与 RNNLM](/posts/nlp/06-05-nnlm-rnnlm/) → [ELMo](/posts/nlp/06-06-elmo/) → [BERT](/posts/nlp/06-07-bert/) / [预训练范式速览](/posts/nlp/06-08-pretrain-overview/)（[GPT](/posts/nlp/06-08b-gpt/)、[BART](/posts/nlp/06-09-bart/)）→ [LLM 预训练](/posts/nlp/07-01-llm-architecture/)

### 大模型训练与对齐

[LLM 有监督微调](/posts/nlp/08-01-llm-sft/) → [参数高效微调](/posts/nlp/08-02-peft-lora/) → [RLHF 与 PPO](/posts/nlp/09-01-rlhf-ppo/) → [DPO](/posts/nlp/09-02-dpo/)

### 经典 NLP 与评价

[词法分析](/posts/nlp/03-02-lexical-analysis/) → [句法分析与语义角色标注](/posts/nlp/03-03-syntax-semantics/) → [经典 NLP 任务](/posts/nlp/03-04-classic-tasks/)；指标贯穿其中：[NLP 评价指标](/posts/nlp/05-01-evaluation-metrics/)、[词向量的评价](/posts/nlp/05-02-embedding-evaluation/)

### 知识、部署与应用

[知识图谱](/posts/nlp/10-01-knowledge-graph/) → [知识增强](/posts/nlp/10-02-knowledge-enhanced-llm/) → [RAG 主线](/posts/nlp/12-03-rag/) → [高级 RAG](/posts/nlp/12-05-rag-advanced/) → [模块化 RAG 与 RAG 增强](/posts/nlp/12-06-rag-modular/)；[推理部署](/posts/nlp/11-01-inference-frameworks/) → [量化与蒸馏](/posts/nlp/11-02-quantization-distillation/)；[提示工程](/posts/nlp/12-01-prompt-engineering/) → [CoT、ToT 与 GoT](/posts/nlp/12-02-cot-tot-got/) → [智能体](/posts/nlp/12-04-agent/)

