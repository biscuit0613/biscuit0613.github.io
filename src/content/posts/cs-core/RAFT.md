---
title: RAFT
published: 2026-05-14
description: ''
image: ''
tags: []
category: '网络与分布式系统'
draft: false 
lang: ''
---

RAFT 是一种分布式一致性算法，旨在在分布式系统中实现可靠的状态复制和一致性。RAFT 通过选举一个领导者节点来协调集群中的操作，确保所有节点都保持一致的状态。

概念全景图：

```mermaid
flowchart TD
    B[领导者选举Leader Election] --> B1[角色: Leader / Follower / Candidate]
    B --> B2[任期 Term]
    B --> B3[选举超时 Election Timeout]
    B --> B4[RequestVote RPC]
    B --> B5[随机超时避免冲突]
```

```mermaid
flowchart TD
    C[日志复制<br>Log Replication] --> C1[日志条目: 索引+任期+命令]
    C --> C2[AppendEntries RPC]
    C --> C3[一致性检查]
    C --> C4[nextIndex 回退机制]
```

```mermaid
flowchart TD
    D[安全性<br>Safety] --> D1[选举限制:<br>候选者日志必须至少最新]
    D --> D2[提交规则:<br>只有当前任期条目能间接提交旧任期]
    D --> D3[状态机应用前必须提交]
```

## 服务器角色

- 领导者（Leader）：处理所有客户端请求，负责日志复制，发送心跳，同一时刻最多一个
- 追随者（Follower）：被动接受领导者的日志复制和心跳，只响应 Leader 和 Candidate 的 RPC，不主动发起操作
- 候选者（Candidate）：当追随者没有收到领导者的心跳时，会变成候选者并发起选举，试图成为新的领导者。

## 任期（Term）

- 时间被划分为连续的整数任期。

- 每个任期开始于一次选举，如果选举成功，则一个 Leader 管理整个任期。

- 有些任期可能因选举失败（分票）而没有 Leader。

- 任期是一个逻辑时钟，用于检测过期的信息（如旧的 Leader）。

## 领导者选举流程

触发条件：Follower 在选举超时（一般 100~500ms）内未收到 Leader 的心跳。变成 Candidate：

- 增加当前任期号。

- 给自己投票。
- 向所有其他服务器并发发送 RequestVote RPC。

结果三种可能：

1. 获得超过半数投票 → 成为 Leader，立即发送心跳维持权威。
2. 收到合法 Leader 的 RPC → 退回 Follower。
3. 选举超时无人胜出 → 增加任期，重开新一轮选举。

避免平局：选举超时时间随机（例如 100~200ms 之间），使一个服务器大概率先发起选举并获胜。

### RequestVote RPC

| 字段         | 类型   | 说明                                      |
| ------------ | ------ | ----------------------------------------- |
| term         | int    | 候选人的当前任期号                        |
| candidateId  | string | 候选人的服务器 ID                         |
| lastLogIndex | int    | 候选人最后一条日志条目的索引（从 1 开始） |
| lastLogTerm  | int    | 候选人最后一条日志条目的任期号            |

接收方的处理逻辑:

1. 如果 term < currentTerm：返回 false，拒绝投票。

2. 如果 voteGranted 尚未投给其他人（或已投给该 candidateId）：

- 比较候选人与自己的日志“谁更完整”：

  - 如果 lastLogTerm > 接收方的 lastLogTerm → 候选人的日志更新 → 可以投票；

  - 若 lastLogTerm == 接收方的 lastLogTerm，则比较 lastLogIndex >= 接收方的 lastLogIndex → 候选人的日志不短于自己 → 可以投票；

- 否则拒绝投票。

投票后，持久化记录 voteFor = candidateId，防止同一任期内重复投票。

## 日志复制（正常操作）

1. 客户端向 Leader 发送命令。(客户端命令只发给 Leader。)

2. Leader 将命令作为新条目追加到本地日志。

3. Leader 并发向所有 Follower 发送 AppendEntries RPC。

4. 当该条目被过半数节点复制后，Leader 将该条目**提交（commit）**：

    - 应用到 Leader 的状态机，产生结果返回客户端。

5. Leader 在后续的 AppendEntries RPC 中告诉 Follower 已提交的条目索引。

6. Follower 将已提交的条目应用到自己的状态机。

### 日志结构

每个日志条目由 (索引, 任期, 命令) 标识。

索引从 1 开始连续递增。

日志存储在持久化介质（磁盘），崩溃恢复后保留。

### 日志特性

如果两个不同服务器上的日志条目有相同索引和相同任期，则：

1. 它们存储相同的命令。

2. 它们之前的所有日志条目也完全相同。（通过一致性检查保证）。

### AppendEntries RPC与日志一致性

| 字段         | 类型       | 说明                                                                                                                  |
| ------------ | ---------- | --------------------------------------------------------------------------------------------------------------------- |
| term         | int        | 领导者的当前任期号                                                                                                    |
| leaderId     | string     | 领导者的 ID（Follower 用于重定向客户端）                                                                              |
| prevLogIndex | int        | 紧接新日志条目之前的那个日志条目的索引，Leader 认为 Follower 应该已经拥有的日志索引（通常是 nextIndex[follower] - 1） |
| prevLogTerm  | int        | prevLogIndex 条目的任期号，Leader 自己在该索引位置的条目的任期。                                                      |
| entries[]    | []LogEntry | 需要复制的日志条目列表（心跳时为空）                                                                                  |
| leaderCommit | int        | 领导者已提交的最高日志索引                                                                                            |

接收方处理逻辑（Follower）

1. 如果 term < currentTerm：返回 false（拒绝）。

2. 如果 term > currentTerm：更新 currentTerm，转为 Follower。

3. 检查自己日志中在 prevLogIndex 位置的条目的`任期`是否和 prevLogTerm 匹配：

    - 若不匹配 → 返回 false（触发 Leader 递减 nextIndex 重试）。

    - 若匹配 → 接受新条目：

4. 删除从 prevLogIndex+1 开始的所有冲突条目（保持一致性）。

5. 追加 entries[] 到本地日志。

6. 如果 leaderCommit > commitIndex：更新 commitIndex = min(leaderCommit, 最后一个新条目的索引)，并应用到状态机。

返回 success = true。

### 日志不一致

Leader 为每个 Follower 维护 nextIndex：下一个要发送的日志索引。

当 AppendEntries 的一致性检查失败（Follower 在 prevLogIndex 处没有匹配的条目），Leader 会递减 nextIndex 并重试。

最终 Follower 会删除冲突的日志（及之后所有条目），以 Leader 的日志为准。

```mermaid
sequenceDiagram
    participant Client
    participant Leader
    participant Follower1
    participant Follower2

    Client->>Leader: 提交命令 (e.g., set x=3)
    Leader->>Leader: 追加日志条目 (index, term, cmd)
    Leader->>Follower1: AppendEntries (新条目)
    Leader->>Follower2: AppendEntries (新条目)
    Follower1-->>Leader: 成功
    Follower2-->>Leader: 成功
    Note over Leader: 收到多数确认 → 提交条目
    Leader->>Leader: 应用到状态机
    Leader-->>Client: 命令成功执行
    Leader->>Follower1: 后续心跳 (告知提交索引)
    Leader->>Follower2: 后续心跳
```

```mermaid
stateDiagram-v2
    [*] --> Follower

    Follower --> Candidate: 选举超时(未收到有效RPC)
    Candidate --> Leader: 获得超过半数投票
    Candidate --> Follower: 收到更高任期的Leader RPC
    Leader --> Follower: 发现更高任期的\n服务器或RPC

    note right of Follower
        启动时进入Follower
        被动响应Leader/Candidate
    end note

    note right of Candidate
        增加任期号
        投票给自己
        发送RequestVote
    end note

    note right of Leader
        发送心跳维持权威
        处理所有客户端请求
        负责日志复制
    end note
```

leader 宕机，触发选举操作

```mermaid
sequenceDiagram
    participant L as Leader (宕机前)
    participant F1 as Follower
    participant F2 as Follower
    participant F3 as Follower

    Note over L: Leader 崩溃 (无心跳)
    F1--xL: 心跳超时
    F2--xL: 心跳超时
    F3--xL: 心跳超时

    F1->>F1: 选举超时 → 变成 Candidate
    F1->>F2: RequestVote (term+1, lastLog)
    F1->>F3: RequestVote (term+1, lastLog)

    alt 投票成功
        F2-->>F1: 投票同意
        F3-->>F1: 投票同意
        F1->>F1: 获得多数 → 成为 Leader
        F1->>F2: AppendEntries (心跳, 新任期)
        F1->>F3: AppendEntries (心跳, 新任期)
    else 分票或网络分区
        Note over F1,F3: 选举超时 → 重试
    end
```

日志不一致，触发日志回退机制

```mermaid
sequenceDiagram
    participant L as Leader
    participant F as Follower (日志不一致)

    Note over L: 维护 nextIndex[F]=5
    L->>F: AppendEntries (prevLogIndex=4, prevLogTerm=2, entries=[5,6])
    F-->>L: 拒绝 (因为本地 index=4 的 term 不匹配)

    L->>L: nextIndex[F]--  (变为4)
    L->>F: AppendEntries (prevLogIndex=3, prevLogTerm=2, entries=[4,5,6])
    F-->>L: 拒绝 (依然不匹配)

    L->>L: nextIndex[F]--  (变为3)
    L->>F: AppendEntries (prevLogIndex=2, prevLogTerm=1, entries=[3,4,5,6])
    F-->>L: 成功 (匹配到一致点)

    Note over F: 删除本地冲突的后续日志<br>并追加新条目
    F->>L: 接受并复制完成
```
