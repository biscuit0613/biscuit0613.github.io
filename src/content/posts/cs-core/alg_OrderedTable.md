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

## 单向链表

链表是线性表的一种链式存储结构，数据元素不必存储在连续的存储空间中。每个元素由数据域和指针域组成，指针域存储下一个元素的地址。链表的优点是插入和删除操作效率高，缺点是不能随机访问。

链表其实有两层指针：一层是节点内部的指针域，告诉节点前后邻居是谁；另一层是操控链表的指针，指向节点。

```cpp
typedef struct LNode {
    ElemType data; // 数据域
    struct LNode *next; // 指针域，指向下一个结点
} LNode, *LinkList;
```

### 链表插入元素

```cpp
class LNode {
public:
    int data;
    LNode* next;//节点内部的指针域，指向下一个结点
    LNode(int val = 0) : data(val), next(nullptr) {}//构造函数，构造一个节点，初始化data和next
};

class LinkedList {
private:
    LNode* head;
public:
    LinkedList() {
        head = new LNode(); // 创建头结点，注意头结点的索引为0
    }

    bool ListInsert(int i, int e) {
        if (i < 1) return false;
        LNode* p = head;//p指针就是操控用的指针，这里指向头结点
        int j = 0;
        while (p && j < i - 1) {
            p = p->next;
            j++;//循环进行了i-1次，j停在i-1的位置，此时p指向i-1的结点
        }
        if (!p) return false;
        LNode* s = new LNode(e);//创建节点s，用于插入（data=e,next=nullptr）
        s->next = p->next;//p->next赋值给s->next
        p->next = s;//第i-1个结点的next指向新节点，实现了在i位置左插入
        return true;
    }
};

```

这里面p是操控链表的指针，在经历while循环后指向第i-1个结点，通过`->`运算符访问p所指向的节点的成员（第i-1个节点的next和data）。s是新插入的结点。

这样实现了在第i个位置左插入元素e。

时间复杂度O(n)主要是查找位置（while循环）的时间，空间复杂度O(1)

### 单向链表删除元素

```cpp
//接续上面的LinkedList类
    bool ListDelete(int i, int &e) {
        if (i < 1) return false;
        LNode* p = head;//p指针是操控用的指针，这里指向头结点
        int j = 0;
        while (p && j < i - 1) {
            p = p->next;
            j++;//循环进行了i-1次，j停在i-1的位置，此时p指向i-1的结点
        }
        if (!p || !(p->next)) return false;//如果p为空或者p的下一个结点为空，说明位置不合法
        LNode* q = p->next;//q是另一个操控指针，指向第i个结点
        e = q->data;//用e返回被删除的元素
        p->next = q->next;//第i-1个结点的next指向第i+1个结点，实现了删除第i个结点
        delete q;//释放被删除结点的内存
        return true;
    }
```

这里用了俩操作指针，p指针在while循环后指向第i-1个结点，这时候引入q指针，q指针暂存第i个结点，通过`->`运算符访问节点成员，q->data存在局部变量e中,在函数结束后销毁。

## 双向链表

双向链表是链表的一种变体，每个结点除了包含数据域和指针域外，还包含一个指向前一个结点的指针。这样可以实现从后向前遍历链表。

```cpp
#include <iostream>
using namespace std;

class DNode {
public:
    int data;
    DNode* prev;
    DNode* next;

    DNode(int val) : data(val), prev(nullptr), next(nullptr) {}
};

class DoublyLinkedList {
private:
    DNode* head;
    DNode* tail;

public:
    DoublyLinkedList() : head(nullptr), tail(nullptr) {}
}
```

### 双向链表插入

```cpp
    bool insert(int position, int value) {
        DNode* newNode = new DNode(value);
        if (!newNode) return false; // 内存分配失败

        if (position == 0) { // 在头部插入
            newNode->next = head;
            if (head) head->prev = newNode;
            head = newNode;
            if (!tail) tail = newNode; // 如果链表为空，更新尾指针
        } else {
            DNode* current = head;
            int index = 0;
            while (current && index < position - 1) {
                current = current->next;
                index++;
            }
            if (!current) { // 如果位置超出链表长度，在尾部插入
                tail->next = newNode;
                newNode->prev = tail;
                tail = newNode;
            } else { // 在中间位置插入
                newNode->next = current->next;
                newNode->prev = current;
                if (current->next) current->next->prev = newNode;
                current->next = newNode;
                if (!newNode->next) tail = newNode; // 更新尾指针
            }
        }
        return true;
    }
```

## 双向链表的删除

```cpp
    bool remove(int position) {
        if (!head || position < 0) return false; // 链表为空或位置不合法

        DNode* current = head;
        int index = 0;
        while (current && index < position) {
            current = current->next;
            index++;
        }
        if (!current) return false; // 位置超出链表长度

        if (current->prev) current->prev->next = current->next;
        else head = current->next; // 删除头结点，更新头指针

        if (current->next) current->next->prev = current->prev;
        else tail = current->prev; // 删除尾结点，更新尾指针

        delete current; // 释放内存
        return true;
    }
```

## 循环链表

```cpp
#include <iostream>
using namespace std;

class CNode {
public:
    int data;
    CNode* next;

    CNode(int val) : data(val), next(nullptr) {}
};

class CircularLinkedList {
private:
    CNode* head;

public:
    CircularLinkedList() : head(nullptr) {}

    void insert(int value) {
        CNode* newNode = new CNode(value);
        if (!newNode) return;

        if (!head) {//如果head为空
            head = newNode;//新节点作为头结点
            newNode->next = head; // 指向自己，形成循环
        } else {
            CNode* current = head;
            while (current->next != head) {
                current = current->next;
            }
            current->next = newNode;
            newNode->next = head;
        }
    }

    void display() {
        if (!head) return;

        CNode* current = head;
        do {
            cout << current->data << " ";
            current = current->next;
        } while (current != head);
        cout << endl;
    }
};
```

典型问题：约瑟夫环问题

所谓约瑟夫环问题，是指n个人围成一圈，从第一个人开始报数，数到第m个人时，该人出列，然后从下一个人重新开始报数，数到第m个人时，该人又出列，如此循环，直到所有人都出列为止。问题是，给定n和m，求最后一个出列的人的位置。

```cpp
#include <iostream>
using namespace std;

class CNode {
public:
    int data;
    CNode* next;

    CNode(int val) : data(val), next(nullptr) {}
};

class CircularLinkedList {
private:
    CNode* head;

public:
    CircularLinkedList() : head(nullptr) {}

    void insert(int value) {
        CNode* newNode = new CNode(value);
        if (!newNode) return;

        if (!head) {//如果head为空
            head = newNode;//新节点作为头结点
            newNode->next = head; // 指向自己，形成循环
        } else {
            CNode* current = head;
            while (current->next != head) {
                current = current->next;
            }
            current->next = newNode;
            newNode->next = head;
        }
    }

    int josephus(int n, int m) {
        if (n < 1 || m < 1) return -1;

        // 创建循环链表
        for (int i = 1; i <= n; i++) {
            insert(i);
        }

        CNode* current = head;
        CNode* prev = nullptr;

        // 找到最后一个出列的人的位置
        while (current->next != current) {
            for (int i = 1; i < m; i++) {
                prev = current;
                current = current->next;
            }
            // 删除当前节点
            prev->next = current->next;
            delete current;
            current = prev->next;
        }
        int lastPerson = current->data;
        delete current;
        return lastPerson;
    }
};