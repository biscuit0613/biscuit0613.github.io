---
title: Djikstra算法
published: 2025-10-29
description: ''
image: ''
tags: [最短路径算法, Djikstra算法]
category: '数据结构与算法'
draft: false 
lang: ''
---

## 算法思想

Djikstra算法是一种用于计算加权图中单源最短路径的经典算法。它适用于**边权非负**的图，能够有效地找到从**起始节点**到其他节点的最短路径。

是一种贪心算法

## 算法数据结构

对于一个有向加权图G=(V,E)，其中V是顶点集合$\{1,2,\ldots,n\}$，E是边集合，w(u,v)表示边(u,v)的权重。

采用**邻接矩阵**C表示图G，邻接矩阵的定义如下：

$$
C[i][j] =
\begin{cases}
w(i,j) & \text{如果边}(i,j) \in E \\
\infty & \text{如果边}(i,j) \notin E
\end{cases}
$$

有向性体现在矩阵的非对称性上，从行到列是有向边的方向

## 算法步骤

1. 初始化：

   - 从顶点中找一个点作为原点，创建一个距离数组 $D[n]$，$D[i]$ 表示从**起始节点**到第 $i$ 个节点的**最短距离**。$D[i]=C[start][i]$。

   - 将起始节点的距离设为0，即$D[start] = 0$。

   - 维护一个一维数组 $P[n]$，初始化为-1。$P[i]$ 表示从起始节点到节点i的最短路径上，i的**前一个节点**。
   - 创建一个布尔数组 $S[n]$，用于标记节点是否已被处理，初始化为false。
    :::tip  
    P数组用于记录路径信息，方便在算法结束后回溯最短路径。最后得到一颗**树**，表示从起始节点到所有其他节点的最短路径。  
    :::

2. 主循环

   - 将顶点集V分为两个子集：已处理节点集S和未处理节点集V-S。初始化邻接矩阵 $C[i][j]$ ， $D[i]$ ， $P[i]$ 和 $S[i]$。

   - 从V-S中选择一个顶点w,使得 $D[w]$ 最小，将w加入S。
   - 对于每个未处理节点v ∈ V-S，检查通过w到达v的路径是否更短，即检查 $D[w] + C[w][v] < D[v]$。如果是，则更新 $D[v]$ 和 $P[v]$。

对于给定目标点求最短路径，Djikstra算法可以反过来用，即从终点回溯到起点，得到最短路径。

## 代码实现

```cpp
#ifndef GRAPH_H
#define GRAPH_H

/*
 * graph.h
 * 最短路径实验 — 图的类定义
 * 提供邻接矩阵和邻接表两种表示，包含 Dijkstra 和 Floyd-Warshall 算法接口。
 */

#include <vector>
#include <string>
#include <utility>

using namespace std;

/*
 Graph 类：表示带权图，支持无向/有向（由 addEdge 的实现决定）
* 成员：
*  n: 顶点数量
*   adjMatrix: 邻接矩阵（用于 Floyd-Warshall）
*   adjList: 邻接表（用于 Dijkstra）
*/
class Graph {
public:
    int n; // 顶点数量
    vector<vector<int>> adjMatrix;            // 邻接矩阵，未连通处用 INT_MAX 表示
    vector<vector<pair<int, int>>> adjList;   // 邻接表，每项为 (目标顶点, 权重)

    // 构造函数：初始化顶点数并设置邻接结构
    Graph(int vertices);

    // 添加一条边 u->v, 权重 w；当前实现也会同时添加 v->u（即无向图），如需有向图可修改此函数
    void addEdge(int u, int v, int w);

    // 从文件加载图，文件格式：第一行 "n edges"，随后每行 "u v w"
    void loadFromFile(const string& filename);

    // Dijkstra 算法（单源最短路径）
    // 输入：source 源点
    // 输出：pair(dist, prev)
    //  dist[i] 为 source 到 i 的最短距离（不可达为 INT_MAX）
    //  prev[i] 为重建路径时 i 的前驱节点，source 的 prev 为 -1
    pair<vector<int>, vector<int>> dijkstra(int source);

    // Floyd-Warshall 算法（任意两点最短路径）
    // 返回 pair(distMatrix, nextMatrix)
    //  distMatrix[i][j] 为 i->j 的最短距离（不可达为 INT_MAX）
    //  nextMatrix[i][j] 若为 -1 表示无路径，否则表示从 i 到 j 路径上的下一个节点
    pair<vector<vector<int>>, vector<vector<int>>> floydWarshall();

    // 使用 Dijkstra 的 prev 数组重建 source->target 路径，返回路径节点序列；若无路径返回空向量
    vector<int> getPath(int source, int target, const vector<int>& prev);

    // 使用 Floyd-Warshall 的 next 矩阵重建 source->target 路径；若无路径返回空向量
    vector<int> getPathFW(int source, int target, const vector<vector<int>>& next);
};

#endif // GRAPH_H
```

```cpp

#include "graph.h"
#include <iostream>
#include <fstream>
#include <queue>
#include <limits>
#include <algorithm>
#include <climits>

// 根据给定顶点数创建邻接矩阵和邻接表
// 初始化，邻接矩阵中无边处使用 INT_MAX 表示，自身到自身的距离为 0
Graph::Graph(int vertices) : n(vertices) {
    adjMatrix.assign(n, vector<int>(n, INT_MAX));
    adjList.assign(n, vector<pair<int, int>>());
    for (int i = 0; i < n; ++i) {
        adjMatrix[i][i] = 0;
    }
}

// 将边信息写入邻接矩阵与邻接表
// 当前实现同时添加反向边以构造无向图
void Graph::addEdge(int u, int v, int w) {
    adjMatrix[u][v] = w;
    adjList[u].emplace_back(v, w);//u->v
    // 无向图同时添加反向边
    adjMatrix[v][u] = w;
    adjList[v].emplace_back(u, w);
}

// 从文件加载图数据，文件格式：第一行 "n edges"，后续每行为 "u v w"
void Graph::loadFromFile(const string& filename) {
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error opening file: " << filename << endl;
        return;
    }
    int edges;
    file >> n >> edges;
    adjMatrix.assign(n, vector<int>(n, INT_MAX));
    adjList.assign(n, vector<pair<int, int>>());
    for (int i = 0; i < n; ++i) {
        adjMatrix[i][i] = 0;
    }
    for (int i = 0; i < edges; ++i) {
        int u, v, w;
        file >> u >> v >> w;
        addEdge(u, v, w);
    }
    file.close();
}

// Dijkstra 算法（使用最小堆实现）
// 输入：source 源点
// 返回：pair(dist, prev)
//  dist[i] 为 source 到 i 的最短距离
//  prev[i] 在路径重建时表示 i 的前驱节点
pair<vector<int>, vector<int>> Graph::dijkstra(int source) {
    vector<int> dist(n, INT_MAX);
    vector<int> prev(n, -1);
    dist[source] = 0;
    // 优先队列按距离从小到大弹出（pair.first = 距离, pair.second = 顶点）
    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;
    pq.emplace(0, source);
    while (!pq.empty()) {
        auto top = pq.top();
        int cost = top.first;
        int node = top.second;
        pq.pop();
        if (cost > dist[node]) continue;//跳过过期节点
        for (auto& p : adjList[node]) {
            int v = p.first;//node的邻居
            int w = p.second;//node到邻居的边权
            if (dist[node] != INT_MAX && dist[node] + w < dist[v]) {
                dist[v] = dist[node] + w;
                prev[v] = node;//更新前驱节点
                pq.emplace(dist[v], v);
            }
        }
    }
    return {dist, prev};
}

// Floyd-Warshall 算法：计算任意两点最短路径
// 返回：pair(dist, next)
//  dist 为最短距离矩阵
//  next 用于路径重建，若 next[i][j] == -1 表示 i->j 无路径
pair<vector<vector<int>>, vector<vector<int>>> Graph::floydWarshall() {
    vector<vector<int>> dist = adjMatrix;
    vector<vector<int>> next(n, vector<int>(n, -1));
    // 初始化 next 矩阵：若存在直接边则 next[i][j] = j
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            if (dist[i][j] != INT_MAX && i != j) {
                next[i][j] = j;
            }
        }
    }
    // 三层循环，动态规划
    for (int k = 0; k < n; ++k) {
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                if (dist[i][k] != INT_MAX && dist[k][j] != INT_MAX &&
                    dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];
                    next[i][j] = next[i][k];
                }
            }
        }
    }
    return {dist, next};
}

// 使用 prev 数组重建路径（Dijkstra）
// 从 target 回溯到 source，如果回溯后首节点不是 source 则说明无路径
vector<int> Graph::getPath(int source, int target, const vector<int>& prev) {
    vector<int> path;
    for (int at = target; at != -1; at = prev[at]) {
        path.push_back(at);
    }
    reverse(path.begin(), path.end());
    if (!path.empty() && path[0] == source) return path;
    return {};
}

// 使用 Floyd-Warshall 的 next 矩阵重建路径
vector<int> Graph::getPathFW(int source, int target, const vector<vector<int>>& next) {
    if (next[source][target] == -1) return {};
    vector<int> path = {source};
    while (source != target) {
        source = next[source][target];
        path.push_back(source);
    }
    return path;
}
```
