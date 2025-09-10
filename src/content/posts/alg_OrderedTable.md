---
title: 算法与数据结构-线性表
published: 2025-09-10
description: '线性表的基本概念与操作'
image: ''
tags: [线性表, 数据结构]
category: '数据结构与算法'
draft: false
lang: ''
---
线性表（Linear List）是最基本、最常用的一种数据结构。它是由n个数据元素（结点）组成的有限序列。线性表的主要特点是元素之间具有线性关系，即每个元素只有一个直接前驱和一个直接后继（第一个元素没有前驱，最后一个元素没有后继）。

## 顺序表

顺序表是线性表的一种顺序存储结构，数据元素按逻辑顺序依次存储在一块连续的存储空间中。顺序表的优点是支持随机访问，缺点是插入和删除操作效率较低。

```cpp
#define MAXSIZE 100 // 顺序表的最大长度
typedef struct {
    ElemType data[MAXSIZE]; // 存储空间
    int length; // 当前长度
} SqList;
```

位置类型：`typedef int position`
线性表的实例 `List L`
`L.length`  线性表的长度
`L.data[i]` 线性表中第i个元素

### 1.初始化线性表

```cpp
void InitList(SqList &L) {
    L.length = 0; // 初始化长度为0
}
```

### 2. 顺序表插入元素

数据整体往后挪，然后插入元素，并且修改数组长度。

```cpp
bool ListInsert(SqList &L, int i, ElemType e) {// 在第i个位置插入元素e
    if (i < 1 || i > L.length + 1 || L.length == MAXSIZE) {
        return false; // 插入位置不合法或顺序表已满
    }
    for (int j = L.length; j >= i; j--) {
        L.data[j] = L.data[j - 1]; // 元素后移，第j个元素赋值为第j-1个元素
    }//当这个循环结束时，L.data[i]的位置是空的
    L.data[i - 1] = e; // 插入元素
    L.length++; // 长度加1
    return true;
}
```

### 3. 顺序表删除元素

```cpp
bool ListDelete(SqList &L, int i, ElemType &e) {// 删除第i个位置的元素，并用e返回
    if (i < 1 || i > L.length) {
        return false; // 删除位置不合法
    }
    e = L.data[i - 1]; // 用e返回被删除的元素
    for (int j = i; j < L.length; j++) {
        L.data[j - 1] = L.data[j]; // 元素前移，第j个元素赋值为第j+1个元素
    }
    L.length--; // 长度减1
    return true;
}
```

### 4. 顺序表查找元素

```cpp
int LocateElem(SqList L, ElemType e) {// 查找元素e，返回位置
    for (int i = 0; i < L.length; i++) {
        if (L.data[i] == e) {
            return i + 1; // 返回位置
        }
    }
    return 0; // 未找到，返回0
}
```

## 链表

链表是线性表的一种链式存储结构，数据元素不必存储在连续的存储空间中。每个元素由数据域和指针域组成，指针域存储下一个元素的地址。链表的优点是插入和删除操作效率高，缺点是不能随机访问。

```cpp
typedef struct LNode {
    ElemType data; // 数据域
    struct LNode *next; // 指针域，指向下一个结点
} LNode, *LinkList;
```

### 1. 初始化链表

```cpp
void InitList(LinkList &L) {
    L = NULL; // 初始化为空链表
}
```

### 2. 链表插入元素

```cpp
struct LNode {
    int data;
    LNode* next;
};

bool ListInsert(LNode*& L, int i, int e) { // 在第i个位置插入元素e
    if (i < 1) {
        return false; // 插入位置不合法
    }
    LNode* p = L;
    int j = 1;
    while (p != nullptr && j < i - 1) {
        p = p->next; // 找到第i-1个结点
        j++;
    }
    if (p == nullptr || j != i - 1) {
        return false; // 插入位置不合法
    }
    LNode* s = new LNode; // 创建新结点
    s->data = e; // 赋值
    s->next = p->next; // 插入结点
    p->next = s;
    return true;
}
```
