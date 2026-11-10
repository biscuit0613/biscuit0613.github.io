---
title: '大模型推理部署：KV Cache、PagedAttention 与推理框架'
published: 2026-10-20
description: '自回归推理的两个阶段、KV Cache 的显存问题、PagedAttention 与连续批处理，以及 vLLM、TGI、TensorRT-LLM、llama.cpp 等框架的选择'
image: ''
tags: [NLP, LLM, Inference, vLLM, PagedAttention, Deployment]
category: '09-自然语言处理'
order: 1101
draft: false
lang: ''
---

## 推理的两个阶段

自回归生成分为两个阶段：

- **Prefill（预填充）**：把整段提示一次性送入模型，并行计算所有位置的表示，生成第一个 token 和 KV Cache。这个阶段矩阵乘规模大，通常受算力限制；
- **Decode（解码）**：每次只生成一个 token，把新 token 的 query 与历史 KV 做注意力。这个阶段每次只处理一个位置，受显存带宽限制，GPU 利用率往往不高。

因此推理优化的重点不同：Prefill 关注吞吐和算子效率，Decode 关注 KV Cache 的显存占用和访存速度。

### KV Cache

生成第 $t$ 个 token 时，需要之前所有 token 的 key 和 value。如果每次都重新计算，复杂度会随序列长度平方增长。KV Cache 把历史 key/value 保存在显存中，每步只计算新 token 的 K/V 并追加：

$$
\begin{aligned}

\mathbf{k}_t &= \mathbf{x}_t \mathbf{W}_K,
\mathbf{v}_t = \mathbf{x}_t \mathbf{W}_V &\text{计算新token的key和value}
\\
\mathbf{K}_{1:t} &= [\mathbf{K}_{1:t-1}; \mathbf{k}_t],
\mathbf{V}_{1:t} = [\mathbf{V}_{1:t-1}; \mathbf{v}_t] &\text{追加到历史K/V中}
\\
\operatorname{Attn}_t &=
\operatorname{softmax}\left(
\frac{\mathbf{q}_t [\mathbf{K}_{1:t}]^T}{\sqrt{d_k}}
\right)[\mathbf{V}_{1:t}] &\text{计算新token的注意力输出}
\end{aligned}

$$

KV Cache 的大小与层数、头数、头维度、序列长度和批次大小成正比。长上下文、多并发时，KV Cache 往往比模型权重更占显存。

## 推理指标

- **TTFT**（Time To First Token）：从请求到第一个 token 的延迟，主要由 Prefill 决定；
- **TPOT / ITL**（每 token 时间 /  token 间隔）：Decode 阶段每个 token 的耗时；
- **吞吐**：每秒处理的 token 数或请求数；
- **显存占用**：权重、KV Cache、激活和临时缓冲区之和；
- **内存占用**：CPU 内存，影响模型加载和混合推理。

实时对话更关注 TTFT 和 TPOT，离线批处理更关注总吞吐。两者经常需要权衡。

## PagedAttention 与连续批处理

### PagedAttention

传统实现为每个请求预分配一段连续的 KV Cache，按最大长度预留，造成大量内部碎片；请求长度不一还会产生外部碎片。

vLLM 的 **PagedAttention** 借鉴操作系统虚拟内存分页：把 KV Cache 切成固定大小的 block，用页表把逻辑位置映射到不连续的物理 block。这样：

- 按需分配 block，减少预留浪费；
- 不同请求可以共享物理 block（如相同的系统提示），实现前缀共享；
- 显存利用率提高后，可以容纳更多并发请求。

### 连续批处理

静态批处理要等一个批次中所有请求都结束才能释放，短请求会被长请求拖住。**连续批处理**（continuous batching / in-flight batching）在每个解码步检查请求状态，完成的请求立即移出，新请求随时加入，从而保持 GPU 忙碌。

这两个技术是 vLLM、TGI、TensorRT-LLM 等框架高吞吐的核心。

## 主流框架

| 框架 | 主要特点 | 适用场景 |
| --- | --- | --- |
| vLLM | PagedAttention、连续批处理、张量/流水线并行、兼容 HuggingFace | 通用服务端部署，社区活跃 |
| HuggingFace TGI | 连续批处理、Flash Attention、张量并行、Safetensors | HuggingFace 生态、快速上线 |
| TensorRT-LLM | NVIDIA GPU 专用，编译优化、in-flight batching | 追求极致 NVIDIA 推理性能 |
| DeepSpeed-MII | DeepSpeed-Inference、自动张量切片、即时量化 | 低延迟、低成本部署 |
| llama.cpp | 纯 C/C++、1.5–8 bit 量化、CPU+GPU 混合推理 | 本地、边缘设备、无 GPU 环境 |
| Ollama | 封装模型拉取与运行，命令行交互 | 个人本地体验、快速原型 |

### vLLM

vLLM 是面向大模型推理和部署的开源库，核心是 PagedAttention 和连续批处理，支持张量并行、流水线并行、并行采样和束搜索，并可与 HuggingFace 模型无缝集成。

### TGI

Text Generation Inference 是 HuggingFace 的部署工具包，提供简单的启动器、多 GPU 张量并行、连续批处理、Flash Attention 和 Safetensors 权重加载，适合快速部署主流开源模型。

### TensorRT-LLM

TensorRT-LLM 针对 NVIDIA GPU 做编译级优化，提供模型定义 API、预处理/后处理和分布式通信原语。它的 in-flight batching 可以移除已完成序列、接收新请求，减少队列等待。缺点是绑定 NVIDIA 生态，模型转换和编译成本较高。

### DeepSpeed-MII

DeepSpeed-MII 基于 DeepSpeed-Inference，提供低延迟、低成本的推理实现，支持自动张量切片、DeepFusion 算子融合和即时量化，几行代码即可本地或云端部署。

### llama.cpp 与 Ollama

llama.cpp 用纯 C/C++ 实现，不依赖外部框架，支持 1.5–8 bit 整数量化，并能在显存不足时把部分层放到 CPU 上做混合推理，适合本地和边缘设备。

Ollama 在 llama.cpp 等后端之上封装了模型下载、运行和交互，执行 `ollama run model` 即可自动拉取并启动模型，适合个人体验和原型开发，不适合高并发生产服务。

## 框架选择

- **服务端高吞吐**：vLLM、TGI；
- **NVIDIA 极致性能**：TensorRT-LLM；
- **低成本/低延迟**：DeepSpeed-MII；
- **本地与边缘**：llama.cpp、Ollama；
- **显存不足**：结合 [量化](/posts/nlp/11-02-quantization-distillation/) 或 CPU+GPU 混合推理。

部署时还要考虑模型格式、并行策略、批处理配置、监控和弹性扩缩容。推理框架解决的是“怎么跑得快”，量化与蒸馏解决的是“怎么放得下”，两者通常一起使用。

## 相关阅读

- 量化与蒸馏：[模型压缩：量化与蒸馏](/posts/nlp/11-02-quantization-distillation/)
- 训练阶段的显存与并行：[大模型训练系统](/posts/nlp/07-02-llm-training-systems/)
- 模型组件与 KV Cache：[现代 LLM 组件](/posts/transformer/modern-llm-components/)
- 推理服务评价：[大语言模型的评价](/posts/nlp/10-03-llm-evaluation/)
- 低资源微调：[LoRA 与 QLoRA](/posts/nlp/08-02-peft-lora/)
