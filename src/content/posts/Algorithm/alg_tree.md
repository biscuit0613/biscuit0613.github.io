---
title: 树和二叉树
published: 2025-09-26
description: '树和二叉树的基本概念'
image: ''
tags: [树, 二叉树, 数据结构]
category: '数据结构与算法'
draft: false 
lang: ''
---

## 树的定义

树是一种抽象数据类型，用于表示具有层次关系的数据结构。它由节点（Node）和边（Edge）组成，具有以下特性：

1. **层次结构**：树的节点具有父子关系，形成层次结构。每个节点可以有零个或多个子节点，但只能有一个父节点（根节点除外）。或者说每个节点只能有一个直接前驱，但可以有0个或多个直接后继。

    eg: 操作系统中的文件系统就是一种树形结构，目录是节点，文件是叶子节点。`cd ..`表示返回上一级目录。`cd dir`表示进入子目录。

2. **路径**：从一个节点到另一个节点的边的序列称为路径（Path），路径长度是指路径中边的数量。

3. **层数**：根节点的层数定义为1；若某节点的父节点层数为k，则该节点的层数为k+1。

4. **高度/深度**：树的高度/深度是指所有节点的最大层数，不是边数。
5. **子树**：树的任意节点及其所有后代节点组成的树称为子树。
6. **节点的度**：节点的度是指该节点所有的子树的个数。
    :::note
    和离散数学中节点度的定义不同，离散数学中节点的度是指与该节点直接相连的边的数量。
    :::
7. **树的度**：树的度是指树中节点的最大度。
8. **根节点**：树的最上层节点称为根节点（Root），没有父节点。
9. **叶子节点**：没有子节点的节点称为叶子节点（Leaf），也就是度为零的节点。
10. **有序树**：如果树中每个节点的子节点有一个固定的顺序（一般是从左到右），则称为有序树（Ordered Tree）。否则称为无序树（Unordered Tree）。

树的一个重要特例是**二叉树**，它的每个节点最多只能有两个子节点，分别称为左子节点和右子节点。

## 树的应用例子

表达式树：用于表示数学表达式的结构，节点表示操作符，叶子节点表示操作数。

eg: (a + b) * (c - d)

```plaintext
        *
       / \
      +   -
     / \ / \
    a  b c  d
```

决策树：用于机器学习中的分类和回归任务，节点表示决策条件，叶子节点表示结果。

文件系统：操作系统中的文件和目录结构通常以树的形式组织，根目录是树的根节点，子目录和文件是子节点。

HTML DOM：网页的结构以树的形式表示，HTML元素是节点，嵌套关系表示父子关系。

## 二叉树

### binary tree的定义

二叉树是每个节点最多有两个子节点的树结构，分别称为左子节点和右子节点。二叉树的节点度数最大为2，并且是有序树，用左右区分序。

斜树：只有左子树的二叉树称为左斜树，只有右子树的二叉树称为右斜树。

满二叉树：高度为 $K$ 且有 $2^K-1$ 个节点的二叉树称为满二叉树。每个分支节点都有两棵子树，且所有叶子节点都在最后一层。

完全二叉树：高度为 $K$ 的二叉树，除第 $K$ 层外，其余各层节点数均达到最大值，第 $K$ 层所有节点都连续集中在最左边。

深度为k的完全二叉树的前k-1层是满二叉树，第k层的节点从左到右依次编号为 $1,2,...,m(m<=2^(k-1))$。

### 二叉树的性质

1. **深度节点数**：深度为 $K$ 的二叉树最多有 $2^K-1$ 个节点，最少有 $K$ 个节点；

    :::tip
    每一层节点数是前一层的两倍，所以第i层最多有 $2^{i-1}$ 个节点，等比数列求和公式
    $$
    \sum_{i=0}^{n-1}2^i=2^n-1
    $$
    就得到了满二叉树节点数的公式
    :::

2. **每一层节点数**：第 $i$ 层最多有 $2^{i-1}$ 个节点，最少有1个节点。

3. **叶子节点数**：对于非空二叉树，叶子节点数 $n_0$ 与度为2的节点数 $n_2$ 满足关系 $n_0=n_2+1$。对于满二叉树，叶子节点数为 $(N+1)/2$，其中 $N$ 是总节点数。
    :::note[证明]

    设二叉树中度为0的节点数为 $n_0$，度为1的节点数为 $n_1$，度为2的节点数为 $n_2$，总节点数为 $N$，则有：
    $$
    N=n_0+n_1+n_2 \tag{1}
    $$
    每个节点有一条边指向它（根节点除外），所以边数 $E$ 满足：
    $$
    E=N-1 \tag{2}
    $$
    另一方面，边数也可以通过节点的度数来计算：
    $$
    E=n_1+2n_2 \tag{3}
    $$
    将 (2) 和 (3) 结合，得到：
    $$
    N-1=n_1+2n_2 \tag{4}
    $$
    将 (1) 代入 (4)：
    $$
    (n_0+n_1+n_2)-1=n_1+2n_2
    $$
    化简得到:
    $$
    n_0=n_2+1
    $$
    :::

4. **高度**：具有n个节点的完全二叉树的高度为 $\lceil log_2(n+1)\rceil$ 或 $\lfloor log_2n \rfloor +1$。

    :::note[证明]
    设完全二叉树的高度为 $h$，则前 $h-1$ 层是满二叉树，有 $2^{h-1}-1$ 个节点，第 $h$ 层有 $m$ 个节点，$1\leq m\leq 2^{h-1}$，所以总节点数 $n$ 满足
    $$
    2^{h-1}\leq n\leq 2^h-1
    $$
    取对数得到
    $$
    h-1\leq log_2n<h
    $$
    即
    $$
    h=\lceil log_2(n+1)\rceil=\lfloor log_2n \rfloor +1
    $$
    :::

## 二叉树的顺序存储

把一个n个节点的二叉树编号，从顶向下，同一层从左至右，从1开始编号。将二叉树的节点依次存储在数组中

## 二叉树的链式存储

每个节点由一个数据域和两个指针域组成，分别指向左子节点和右子节点。

```cpp
typedef struct TreeNode {
    int data;
    struct TreeNode* left;
    struct TreeNode* right;
    TreeNode(int val) : data(val), left(nullptr), right(nullptr) {}
} ;
```

### 二叉链表的建立

1. 先序遍历建立二叉树  
    按照先序遍历的顺序输入节点值，遇到空节点输入特殊标记（如#），递归建立二叉树。

    ```cpp
    #include <iostream>
    #include <sstream>
    using namespace std;

    TreeNode* createTree() {
        string val;
        if (!(cin >> val)) return nullptr;
        if (val == "#") return nullptr;
        TreeNode* node = new TreeNode(stoi(val));
        node->left = createTree();
        node->right = createTree();
        return node;
    }

2. 索引式构建二叉链表

    先创建所有节点对象，然后根据输入的左右孩子编号建立指针连接。

    ```cpp
        #include <iostream>
    #include <vector>
    #include <string>
    using namespace std;
    struct TreeNode {
        char data;
        TreeNode* left;
        TreeNode* right;
        TreeNode(char val) : data(val), left(nullptr), right(nullptr) {}
    };
    // 每个节点的输入信息
    struct NodeInfo {
        char data;
        int leftIndex;
        int rightIndex;
    };
    TreeNode* buildTree(const vector<NodeInfo>& input) {
        int n = input.size();
        vector<TreeNode*> nodes(n);
        // 第一步：创建所有节点对象
        for (int i = 0; i < n; ++i) {
            nodes[i] = new TreeNode(input[i].data);
        }
        // 第二步：建立左右孩子指针连接
        for (int i = 0; i < n; ++i) {
            int l = input[i].leftIndex;
            int r = input[i].rightIndex;
            if (l != 0) nodes[i]->left = nodes[l];
            if (r != 0) nodes[i]->right = nodes[r];
        }

        return nodes[0]; // 返回根节点
    }
    // 前序遍历用于验证构建结果
    void preorder(TreeNode* root) {
        if (!root) return;
        cout << root->data << " ";
        preorder(root->left);
        preorder(root->right);
    }
    int main() {
        // 示例输入：构建如下结构
        //        A
        //       / \
        //      B   C
        //     / \ / \
        //    D  E F  G
        vector<NodeInfo> input = {
            {'A', 1, 2},
            {'B', 3, 4},
            {'C', 5, 6},
            {'D', 0, 0},
            {'E', 0, 0},
            {'F', 0, 0},
            {'G', 0, 0}
        };
        TreeNode* root = buildTree(input);
        cout << "前序遍历结果: ";
        preorder(root);
        cout << endl;
        return 0;
    }

    ```

### 二叉树的遍历

遍历是指按照某种顺序访问二叉树的所有节点。常见的遍历方式有三种：先序遍历、中序遍历和后序遍历。

1. **先序遍历**（Preorder Traversal）：先访问根节点，再遍历左子树，最后遍历右子树。其递归实现如下：

    ```cpp
    void preorder(TreeNode* root) {
        if (!root) return;
        cout << root->data << " ";
        preorder(root->left);
        preorder(root->right);
    }
    ```

2. **中序遍历**（Inorder Traversal）：先遍历左子树，再访问根节点，最后遍历右子树。其递归实现如下：

    ```cpp
    void inorder(TreeNode* root) {
        if (!root) return;
        inorder(root->left);
        cout << root->data << " ";
        inorder(root->right);
    }
    ```

3. **后序遍历**（Postorder Traversal）：先遍历左子树，再遍历右子树，最后访问根节点。其递归实现如下：

    ```cpp
    void postorder(TreeNode* root) {
        if (!root) return;
        postorder(root->left);
        postorder(root->right);
        cout << root->data << " ";
    }
    ```

例如，给定如下二叉树：

```plaintext
        A
       / \
      B   C
     / \ / 
    D  E F  
```

- 先序遍历结果：A B D E C F
- 中序遍历结果：D B E A F C
- 后序遍历结果：D E B F C A