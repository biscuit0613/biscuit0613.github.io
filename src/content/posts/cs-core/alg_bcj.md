---
title: 并查集
published: 2025-12-04
description: '并查集的原理'
image: ''
tags: [数据结构]
category: '数据结构与算法'
draft: false 
lang: ''
---

干什么：高效处理集合的合并和查询。

+ 查询find：元素属于哪个集合

+ 合并操作union：合并两个元素所属的集合

## 实现思路

用**树**表示每个集合，构成森林。

每个树的根节点作为表示该集合的编号。树除了根节点以外的结点都应指向其父节点，根节点指向自己。

在存储时，用**父亲表示法**，记作数组p。结点作下标，存父亲结点对应的下标,根节点的p[根]=根。

**find操作**就转化成了找每个结点的根节点，变成了顺序表遍历。可以路径压缩优化，第一次查找的时候就把父亲结点换成根，扁平化

递归

```cpp
int Find(int x){
    if (p[x]==x)
        return x
    else
        retutn Find(p[x])
        //retutn p[x]=Find(p[x]) //路径压缩，扁平化
}
```

**union操作** 先基于find找到根节点，比较根节点是否相同，如果不同则让一个指向另一个对应的数组只需要改根节点下标处的值；如果相同则让结点合并。可以比较高度优化，合并后树不会增高或只增高1。

```cpp
h[int 根节点值]=树高

void Union(int x,int y){
    int rootx=Find(x)
    int rooty=Find(y)
    if (rootx!=rooty){
        p[rootx]=p[rooty]//或者p[rooty]=p[rootx]
    }
}


void UnionWithHeight(int x,int y){
    int rootx=Find(x)
    int rooty=Find(y)
    if (rootx!=rooty){
        if(h[rootx]<h[rooty]){
        p[rootx]=p[rooty]//矮树合并到高树
        }
        if(h[rootx]>h[rooty]){
        p[rooty]=p[rootx]//高树合并到矮树
        }
        else{
            p[rootx]=p[rooty]
            h[rooty]++
        }
    }
}
```