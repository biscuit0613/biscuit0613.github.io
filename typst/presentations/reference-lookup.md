# PPT ⇄ 原始论文对照速查表

> v1 = arXiv 2408.06292, v2 = arXiv 2504.08066

---

## 一、封面与背景

| PPT 内容                                    | 论文出处                                                                       |
| ------------------------------------------- | ------------------------------------------------------------------------------ |
| v1 单篇成本 ~$15                            | v1 §4.2, Table 1: Sonnet ~$250/50 ideas → $5/篇, DeepSeek ~$0.2/篇             |
| v2 首篇 AI 全自动论文通过 Workshop 同行评审 | v2 §4.3 (Accepted, 评分 6.33), §4.1 (实验设计)                                 |
| ICLR 2025 ICBINB Workshop                   | v2 §4.1: "ICLR 2025 ICBINB workshop"                                           |
| 评分 6.33, top 45%                          | v2 §4.3: "6.33 out of 10, individual scores 6, 6, 7"; "top 45% of submissions" |

## 二、v1 vs v2 对比表

| PPT 断言                     | 论文出处                                                                                                             |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| v1 需人工编写模板            | v1 §3: "Given a baseline code template"                                                                              |
| v2 完全自动生成              | v2 §3.2: "Removing Template Dependency"                                                                              |
| v1 线性 Aider 编辑           | v1 §3.2: Aider edits experiment.py sequentially                                                                      |
| v2 Tree Search + 并行        | v2 §3.2.2 "Parallelized Agentic Tree Search", Figure 2                                                               |
| v1 MAX_ITERS=4, RUNS=5       | v1 §3.2: 实验迭代部分                                                                                                |
| v2 4 阶段进度管理            | v2 §3.2.1 "Experiment Progress Manager": 4 stages                                                                    |
| v1 无视觉反馈                | v1 全文无 VLM 提及                                                                                                   |
| v2 VLM 审图 (GPT-4o JSON)    | v2 §3.4 "Vision-Language Model Reviewer"                                                                             |
| v1 Aider 逐节 + chktex       | v1 §3.3                                                                                                              |
| v2 单次 + o1 反思 + VLM 图注 | v2 §3: "single-pass generation followed by a separate reflection stage powered by reasoning models such as o1"; §3.4 |
| v1 单一 GPT-4o 审稿          | v1 §3.4: GPT-4o reads PDF                                                                                            |
| v2 5 集成 + AC 聚合          | v2 §4.1: "Ensemble reviews with meta-reviewer aggregation"                                                           |
| v1 无并行                    | v1 §3.2: 顺序执行                                                                                                    |
| v2 节点并行执行              | v2 §3.2.2: "all new nodes are executed concurrently in parallel"                                                     |
| v1 ~10 API                   | v1 §4, ai_scientist/llm.py                                                                                           |
| v2 ~30 API (o1, Gemini 2.5)  | v2 Appendix Table 2, GitHub llm.py                                                                                   |
| v1 未提交审稿                | v1 §5: 仅模拟审稿                                                                                                    |
| v2 Workshop 接收 6.33/10     | v2 §4.3, Table 1                                                                                                     |
| v1 1-2h, ~15-250 USD         | v1 §4.2 实验数据                                                                                                     |
| v2 数h~15h, API 更高         | v2 Appendix §1: "several hours to a maximum of 15 hours"                                                             |

## 三、v1 流水线

| PPT 断言                             | 论文出处                                                 |
| ------------------------------------ | -------------------------------------------------------- |
| Idea 生成: reflection 3 轮           | v1 §3.1: "3 times self-reflection"                       |
| Idea 新颖性: Semantic Scholar 10 轮  | v1 §3.1: "Semantic Scholar search up to 10 rounds"       |
| 实验: Aider 编辑 → 运行              | v1 §3.2                                                  |
| MAX_ITERS=4                          | v1 §3.2: "maximum 4 retries"                             |
| MAX_RUNS=5                           | v1 §3.2: "maximum 5 experiment rounds"                   |
| 写作: 引用搜索 20 轮                 | v1 §3.3: "20 rounds of citation search"                  |
| 写作: chktex 5 轮                    | v1 §3.3: "up to 5 rounds of LaTeX error correction"      |
| 审稿: reflection 5 轮                | v1 §3.4: "5 rounds of self-reflection"                   |
| 审稿: 集成 5 个                      | v1 §3.4: "ensemble of 5 reviews"                         |
| 审稿: temperature 0.1                | v1 §3.4 实验设置                                         |
| F1 0.57 vs Human 0.49                | v1 §4.3, §5, Table 2: "F1 0.57 (GPT-4o) vs 0.49 (Human)" |
| Balanced Acc 0.65 vs 0.66            | v1 §5, Table 2                                           |
| 人类 reviewer 一致性 0.14 < LLM 0.18 | v1 §5: "Human agreement 0.14, LLM-human alignment 0.18"  |

## 四、v2 Agentic Tree Search

| PPT 断言                           | 论文出处                                                                                                    |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 概率 p 优先选 Buggy                | v2 §3.2.2: "With a predefined probability, a buggy node is chosen"                                          |
| Best-First Search                  | v2 §3.2.2: "best-first search strategy, guided by an LLM"                                                   |
| Debug 深度 ≤ 3                     | v2 Appendix Table 3: "Maximum Debug Depth = 3"                                                              |
| 6 种节点类型                       | v2 §3.2.2: 列举全部节点类型                                                                                 |
| Plan → Code → Execute → Plot → VLM | v2 §3.2.2 执行循环描述                                                                                      |
| Claude 3.5 Sonnet (v2) 代码        | v2 Appendix Table 2: "Code Generation: Claude 3.5 Sonnet (v2)"                                              |
| GPT-4o 反馈                        | v2 Appendix Table 2: "LLM/VLM Feedback Agents: GPT-4o"                                                      |
| Temperature 0.5                    | v2 Appendix Table 2                                                                                         |
| 单节点超时 1h                      | v2 Appendix Table 3: "Maximum Experiment Runtime per Node = 1 hour"                                         |
| VLM 审查输出 JSON                  | v2 Appendix "VLM Image Review Prompt": 输出包含 Img_description, Img_review, Caption_review, Figrefs_review |

## 五、v2 四阶段

| PPT 断言                           | 论文出处                                                                               |
| ---------------------------------- | -------------------------------------------------------------------------------------- |
| Stage 1: 预研, 21 节点             | v2 §3.2.1 Stage 1; Appendix Table 3                                                    |
| Stage 2: 调参, 12 节点             | v2 §3.2.1 Stage 2; Appendix Table 3                                                    |
| Stage 3: 议程, 12 节点             | v2 §3.2.1 Stage 3; Appendix Table 3                                                    |
| Stage 4: 消融, 12 节点             | v2 §3.2.1 Stage 4; Appendix Table 3                                                    |
| 阶段终止条件: 最小原型成功执行     | v2 §3.2.1: "Stage 1 concludes when a basic working prototype is successfully executed" |
| 阶段终止条件: 曲线收敛 + ≥2 数据集 | v2 §3.2.1: "Stage 2 ends when experiments stabilize...across at least two datasets"    |
| 自动增加复杂度                     | v2 §3.2.1: "if runs finish much faster...suggests increasing complexity"               |
| 复制节点多 seeds → 统计            | v2 §3.2.1: "launches multiple replications"                                            |
| Aggregation 节点不执行实验         | v2 §3.2.2: "aggregation nodes do not conduct new experiments"                          |

## 六、v2 Workshop 验证

| PPT 断言                                    | 论文出处                                                                                                  |
| ------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 43 篇投稿混入 3 篇 AI                       | v2 §4.1: "three manuscripts were included among the 43 total submissions"                                 |
| 盲审, 可 opt-out                            | v2 §4.1: "reviewers were informed in advance that some submissions might be AI-generated...could opt out" |
| 接收后撤回                                  | v2 §4.1: "accepted AI-generated manuscripts would be withdrawn after the review process"                  |
| Compositional Regularization: Accepted 6.33 | v2 §4.3, Table 1 (Appendix: §A.3.1)                                                                       |
| Label Noise: Rejected                       | v2 §A.3.2                                                                                                 |
| Pest Detection: Rejected                    | v2 §A.3.3                                                                                                 |
| 57% 数据重叠                                | v2 §4.3: "approximately 57% overlap between training and test sets"                                       |
| 温度缩放实现了但未运行                      | v2 §A.3.2: "AI Scientist had implemented temperature scaling...but never actually used it"                |
| DA 未跑通                                   | v2 §A.3.3: "attempts...were unsuccessful"                                                                 |
| IRB 批准 (H24-02652)                        | v2 §4.1: "obtained IRB approval from the University of British Columbia (H24-02652)"                      |

## 七、被接收论文详情

| PPT 断言                     | 论文出处                                                                                                                          |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| LSTM embedding 正则化        | v2 §4.3: "penalizing large changes in embedding representations"                                                                  |
| 负面结果获认可               | v2 §4.3: "reviewers appreciated...clearly identifying the challenges...reporting on negative results"                             |
| 评分 6, 6, 7                 | v2 §4.3: "scores of 6, 7, and 6"                                                                                                  |
| 漏引用 Hochreiter 1997       | v2 §4.3: "does not cite Hochreiter and Schmidhuber (1997)"                                                                        |
| 图注错误                     | v2 §4.3: "caption of Figure 3 is wrong"                                                                                           |
| 注意力模型达 100% 因任务简单 | v2 §4.3: "100% test accuracy...attention-augmented LSTM...primarily due to task simplicity"                                       |
| Workshop 主题 (ICBINB)       | v2 §4.1: "the workshop's theme (ICBINB's focus on negative results)"                                                              |
| ~40 Idea → 选 3              | v2 §4.2 (Figure 3 注解): "generated around twenty potential research ideas...second phase produced another set of roughly twenty" |
| 论文生成流程                 | v2 §4.2: Figure 3 注解详细描述                                                                                                    |

## 八、架构设计

| PPT 断言                                | 论文出处                                                         |
| --------------------------------------- | ---------------------------------------------------------------- |
| Template Contract: experiment.py + JSON | v2 §3.2: exp. manager reads final_info.json; v1 §3.2: 相同模式   |
| Experiment Manager 4 阶段               | v2 §3.2.1                                                        |
| VLM Reviewer GPT-4o                     | v2 §3.4, Appendix Table 2                                        |
| LLM Adapter: Claude/GPT-4o/o1           | v2 Appendix Table 2, §3: "reasoning models such as o1"           |
| 并行节点执行                            | v2 §3.2.2: "all new nodes are executed concurrently in parallel" |

## 九、局限性

| PPT 断言                  | 论文出处                                                                                  |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| Idea 多样性不足           | v1 §5.1: "Idea diversity is limited"                                                      |
| 无法查看图表              | v1 §5.1: "No visual capability"                                                           |
| 幻觉硬件/结果             | v1 §5.1: "hallucinates hardware information...fabricates results"                         |
| 沙箱逃逸 (fork bomb, 1TB) | v1 §5.2: "Safety risks: fork bomb, 1TB checkpoints"                                       |
| Workshop 非主会           | v2 §5: "acceptance occurred at a workshop level rather than at the main conference track" |
| 1/3 通过                  | v2 §4.1: 3篇中1篇接收                                                                     |
| 数据泄露                  | v2 §4.3: 57% 重叠                                                                         |
| 成本高于 v1               | v2 §1: 15h vs 1-2h                                                                        |

## 十、通用速查

| 概念                 | 最关键的论文位置                                               |
| -------------------- | -------------------------------------------------------------- |
| v1 整体流水线图      | v1 Figure 2 (conceptual.png)                                   |
| v2 整体流水线图      | v2 Figure 1 (conceptual.png)                                   |
| v2 树搜索示意图      | v2 Figure 2 (experiment_tree_v2.pdf)                           |
| v2 超参数表          | v2 Appendix Table 2 (模型) + Table 3 (树搜索)                  |
| v1 实验结果表        | v1 Table 1 (论文产出) + Table 2 (审稿评估)                     |
| v1/v2 对比           | v2 Table 1 (§1)                                                |
| v1 Prompt 示例       | v1 Appendix A                                                  |
| v2 Prompt 示例       | v2 Appendix §A.2                                               |
| v2 三篇投稿论文全文  | v2 Appendix §A.3 (含内部审查 + 审稿意见)                       |
| 代码仓库             | github.com/SakanaAI/AI-Scientist (v2 已合入主仓库)             |
| v2 Workshop 实验数据 | github.com/SakanaAI/AI-Scientist-ICLR2025-Workshop-Experiment/ |
