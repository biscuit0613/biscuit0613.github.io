---
title: alg_Graph
published: 2025-11-30
description: '图的存储结构与表示'
image: ''
tags: [图, 邻接矩阵, 邻接表]
category: '数据结构与算法'
draft: false 
lang: ''
---

## 邻接矩阵

邻接矩阵是一种表示图的二维数组结构。对于一个包含n个顶点的图，邻接矩阵是一个n×n的矩阵，其中矩阵的元素表示顶点之间的连接关系。

性质：

1. 对于无向图，邻接矩阵是对称的。如果顶点i和顶点j之间有边连接，则矩阵元素 $A[i][j]$ 和 $A[j][i]$ 为1（或边的权重），否则为0（或∞）。

2. 对于有向图，邻接矩阵不一定是对称的。$A[i][j]$ 表示从顶点i到顶点j的边的存在与否及权重。
3. 邻接矩阵适合表示稠密图，因为它使用固定大小的二维数组，空间复杂度为 $O(n^2)$，其中n是顶点数。

### 实现步骤

1. 初始化一个一位数组用来存储顶点信息

2. 初始化一个二维数组用来存储邻接矩阵信息

3. 根据输入的边信息，更新邻接矩阵

```cpp
#define MAXVEX 100 // 最大顶点数
typedef struct {
    char vexs[MAXVEX]; // 顶点表
    int arc[MAXVEX][MAXVEX]; // 邻接矩阵
    int numVertexes, numEdges; // 图的当前顶点数和边数
} MGraph;

void CreateMGraph(MGraph &G) {
    int i, j, k, w;
    printf("请输入顶点数和边数：\n");
    scanf("%d %d", &G.numVertexes, &G.numEdges);
    printf("请输入顶点信息：\n");
    for (i = 0; i < G.numVertexes; i++) {
        scanf(" %c", &G.vexs[i]);
    }
    // 初始化邻接矩阵
    for (i = 0; i < G.numVertexes; i++) {
        for (j = 0; j < G.numVertexes; j++) {
            G.arc[i][j] = (i == j) ? 0 : INT_MAX; // 自己到自己的距离为0，其他为∞
        }
    }
    printf("请输入边的信息（起点 终点 权重）：\n");
    for (k = 0; k < G.numEdges; k++) {
        char start, end;
        scanf(" %c %c %d", &start, &end, &w);
        // 查找顶点在数组中的位置
        for (i = 0; i < G.numVertexes; i++) {
            if (G.vexs[i] == start) break;
        }
        for (j = 0; j < G.numVertexes; j++) {
            if (G.vexs[j] == end) break;
        }
        G.arc[i][j] = w; // 更新邻接矩阵
        // 如果是无向图，还需要更新对称位置
        // G.arc[j][i] = w;
    }
}
```

## 邻接表

邻接表是一种表示图的链式结构。对于每个顶点，邻接表存储一个链表，链表中的每个节点表示与该顶点直接相连的其他顶点及边的权重。称为**边表**

再把所有边表的指针和顶点信息的一维数组构成**顶点表**

对于有向图，边表分为出边表和入边表，分别存储从该顶点出发和指向该顶点的边信息。

性质：

1. 边表的长度等于该顶点的出度（有向图的出边表），入度（有向图的入边表）或该顶点的度（无向图）。

2. 邻接表适合表示稀疏图，因为它只存储实际存在的边，节省空间。对于一个包含n个顶点和e条边的无向图，邻接表的空间复杂度为 $O(n + 2e)$；若是有向图，则为 $O(n + e)$。

### 邻接表的实现步骤

1. 输入顶点个数，边的个数

2. 建立顶点表，输入该点的信息，并初始化对应的边表
3. 依次输入边的信息并存储在边表中
   1. 输入边所依附的两个顶点tail&head及权重w
   2. 生成邻接点**序号**是head的的边表节点p
   3. 设置边表节点p
   4. 将p插入到第tail个边表的头部

```cpp
// 边表节点结构体
// |adjvex|w|next| 
typedef struct ENode {
    int adjvex; // 邻接点序号(下标)
    int weight; // 边的权重
    struct ENode* next; // 指向下一个邻接点
} ENode;

// 顶点表节点结构体
// |data|firstedge|
typedef struct VNode {
    char data; // 顶点信息
    ENode* firstedge; // 指向边表的指针
} VNode, AdjList[MAXVEX];

typedef struct {
    AdjList vertices[MAXVEX]; // 顶点表
    int numVertexes, numEdges; // 图的当前顶点数和边数
} AdjGraph;

void CreateAdjGraph(AdjGraph &G) {
    int i, j, k, w;
    printf("请输入顶点数和边数：\n");
    scanf("%d %d", &G.numVertexes, &G.numEdges);
    printf("请输入顶点信息：\n");// 建立顶点表
    for (i = 0; i < G.numVertexes; i++) {
        scanf(" %c", &G.vertices[i].data);// 输入顶点信息
        G.vertices[i].firstedge = nullptr; // 初始化指向边表的指针
    }
    printf("请输入边的信息（起点 终点 权重）：\n");
    for (k = 0; k < G.numEdges; k++) {
        char tail, head;
        scanf(" %c %c %d", &tail, &head, &w);
        // 查找顶点在数组中的位置
        for (i = 0; i < G.numVertexes; i++) {
            if (G.vertices[i].data == tail) break;
        }
        for (j = 0; j < G.numVertexes; j++) {
            if (G.vertices[j].data == head) break;
        }
        // 创建新的边表节点
        ENode* p = new ENode;
        p->adjvex = j; // 邻接点序号
        p->weight = w; // 边的权重
        p->next = G.vertices[i].firstedge; // 插入到边表头部
        G.vertices[i].firstedge = p;
    }
}
```

## 时间复杂度分析

1. 邻接矩阵的创建时间复杂度为 $O(n^2)$，其中n为顶点数，因为需要初始化一个n×n的矩阵。

2. 邻接表的创建时间复杂度为 $O(n + 2e)$，其中e为边数。输入顶点信息的时间复杂度为 $O(n)$，输入边信息的时间复杂度为 $O(2e)$。
