---
title: 哈夫曼编码
published: 2025-10-17
description: '树的应用：哈夫曼编码的原理与实现'
image: ''
tags: [数据结构,树,哈夫曼编码]
category: '数据结构与算法'
draft: false 
lang: ''
---

## 哈夫曼编码简介

哈夫曼编码（Huffman Coding）是一种无损数据压缩算法，由大卫·哈夫曼（David A. Huffman）在1952年提出。它通过使用变长编码来表示数据中的符号，使得出现频率较高的符号使用较短的编码，而出现频率较低的符号使用较长的编码，从而实现数据压缩。

## 前置知识

1. 编码：是指把一组对象(如字符集)中的每个对象用**唯一**的一个二进制位串表示。如ASCII,指令系统

2. 解码：是编码的逆过程,把二进制位串还原成原来的对象。

3. 前缀码：**任何一个编码都不是另一个编码的前缀**。
   1. 前缀码保证了在解码(译码)时的唯一性。
   2. 等长编码显然具有前缀性;
   3. 变长编码可能不具有前缀性。比如：A->0, B->01, C->010 不是前缀码，因为A的编码0是B和C编码的前缀。
4. 平均编码长度：设每个(对象)字符c 的出现的概率 $j$ 为 $p_j$,其二进制位串长度(码长)为$l_j$，则$\sum l_j \cdot p_j$ 表示该组对象(字符)的平均编码长度。平均编码长度越小,表示编码的压缩效果越好。

## 哈夫曼树的构造

哈夫曼树是一种带权路径长度最短的二叉树，用于生成哈夫曼编码。构造哈夫曼树的步骤如下：

1. **初始化**：为字符集中每个字符初始化一棵只有叶结点的二叉树（就一个带权节点），叶子的权值为对应字符的使用频率。
2. **计算WPL**：定义带权路径长度(WPL,Weighted Path Length)为所有叶子结点的权值与**其到根结点路径长度**的乘积之和。WPL越小，表示编码的压缩效果越好。
    $$
    WPL = \sum_{i=1}^{n} (权值_i \times 路径长度_i)
    $$

核心思想：**权值越大**的节点越**靠近根节点**，WPL越小；离根节点**越远**的**权值尽可能小**

步骤：

1. 初始化：对于 ${\omega_1, \omega_2, \ldots, \omega_n}$ 为每个字符的权值，构造n个单节点二叉树，每个节点的权值为对应字符的权值。

2. 重复以下步骤直到只剩下一棵树：
   1. 从森林中选出两棵权值最小的二叉树 $T_1$ 和 $T_2$。
   2. 创建一个新的二叉树 $T_{n1}$，其根节点的权值为 $T_1$ 和 $T_2$ 的权值之和，$T_1$ 和 $T_2$ 分别作为 $T_{n1}$ 的左子树和右子树。
   3. 将新树 $T_{n1}$ 插入森林中，并移除 $T_1$ 和 $T_2$。

## 哈夫曼编码的生成

生成哈夫曼编码的步骤如下：

1. 从哈夫曼树的根节点开始，向**左子树**移动时添加`0`，向**右子树**移动时添加`1`。（也可以左1右0），或者理解成左边权=0,右边权=1

2. 当到达叶节点时，记录下该叶节点对应的字符及其路径上的编码。
3. 重复上述过程，直到所有叶节点的编码都被记录下来。

## 示例代码

用cpp实现哈夫曼编码：

```cpp
#include <bits/stdc++.h>
#include <filesystem>
using namespace std;

// 哈夫曼树节点结构体
struct Node {
    uint8_t symbol;  // 符号（字节值）
    uint64_t freq;  // 频率
    Node *Left, *Right;  // 左右子节点
    bool IsLeaf;  // 是否为叶子节点
    Node(uint8_t s, uint64_t f): symbol(s), freq(f), Left(nullptr), Right(nullptr), IsLeaf(true) {}  // 叶子节点构造函数
    Node(Node* l, Node* r): symbol(0), freq(l->freq + r->freq), Left(l), Right(r), IsLeaf(false) {}  // 内部节点构造函数
};

// 优先队列比较器，用于最小堆，每次push的时候都会触发判断，让小freq上浮
struct Cmp {
    bool operator()(const Node* a, const Node* b) const {
        if (a->freq != b->freq) return a->freq > b->freq;  // 频率小的优先
        return a->IsLeaf < b->IsLeaf;  // 叶子节点优先
    }
};

// 构建哈夫曼编码表
void buildCodes(Node* Root, vector<string>& hufCodes, string Cur="") {
    if (!Root) return;// 空节点返回
    if (Root->IsLeaf) {
        hufCodes[Root->symbol] = Cur.empty() ? "0" : Cur;  // 叶子节点设置编码
        return;
    }
    buildCodes(Root->Left, hufCodes, Cur + "0");  // 左子树编码加 "0"
    buildCodes(Root->Right, hufCodes, Cur + "1");  // 右子树编码加 "1"
}

// 构建哈夫曼树,返回根节点指针
Node* buildTree(const map<uint8_t, uint64_t>& charFreqMap) {
    if (charFreqMap.empty()) return nullptr;  // 空频率表返回空
    priority_queue<Node*, vector<Node*>, Cmp> pq;  // 最小堆priority_queue
    for (auto &p : charFreqMap) {
        pq.push(new Node(p.first, p.second));  // 推入叶子节点
        //这里采用new分配内存，确保树能长期存在
    }
    if (pq.size() == 1) {
        // 单符号情况，创建父节点
        Node* only = pq.top(); pq.pop();
        Node* parent = new Node(only, nullptr);
        return parent;
    }
    while (pq.size() > 1) {
        Node* A = pq.top(); pq.pop();//先访问后弹出
        Node* B = pq.top(); pq.pop();
        Node* Parent = new Node(A, B); //调用非叶子的构造函数，创建父节点
        pq.push(Parent);
    }
    return pq.top();
}

// 释放哈夫曼树内存
void freeTree(Node* Root) {
    if (!Root) return;
    freeTree(Root->Left);
    freeTree(Root->Right);
    delete Root;
}

// AI写的：打印哈夫曼树结构（树形显示）
void printTree(Node* node, string prefix = "", bool isLast = false) {
    if (!node) return;
    cout << prefix;
    if (!prefix.empty()) cout << (isLast ? "└── " : "├── ");
    if (node->IsLeaf) {
        if (isprint(node->symbol)) {
            cout << "'" << char(node->symbol) << "' (" << node->freq << ")" << endl;
        } else {
            cout << "0x" << hex << node->symbol << " (" << dec << node->freq << ")" << endl;
        }
    } else {
        cout << "分支 (" << node->freq << ")" << endl;
    }
    string newPrefix = prefix + (isLast ? "    " : "│   ");
    if (node->Left) printTree(node->Left, newPrefix, node->Right == nullptr);
    if (node->Right) printTree(node->Right, newPrefix, true);
}

// 对文件进行哈夫曼编码
bool encodeFile(const string& inPath, const string& outPath) {
    ifstream in(inPath, ios::binary);//用二进制模式打开输入文件
    if (!in) return false;
    //用istreambuf构建一个字节数据向量，char表示每个元素是一个字母对应的ASCII码
    //data存储转成哈夫曼编码之后的字节流
    vector<uint8_t> Data((istreambuf_iterator<char>(in)), istreambuf_iterator<char>());
    in.close();

    map<uint8_t, uint64_t> charFreqMap;//计算字符频率,键是字节值（uint8_t），值是频率(uint64_t)
    //这里data里面存的是ASCII码对应的字节值，B就是ASCII码
    for (uint8_t asciiChar : Data) charFreqMap[asciiChar]++;

    Node* Root = buildTree(charFreqMap);//根据频率表构建哈夫曼树
    vector<string> hufCodes(256);//256个可能的字节值对应的ascii编码字符串0～255
    if (Root) buildCodes(Root, hufCodes);//构建哈夫曼编码表

    // 打印哈夫曼树结构
    cout << "哈夫曼树结构:" << endl;
    printTree(Root);//(AI写的)
    cout << endl;

    // 将数据编码为比特流（位操作）
    vector<uint8_t> outBytes;
    uint8_t currentByte = 0;// 当前正在构建的字节，默认值为0
    int bitpos = 0;  // 当前字节的位位置（0-7，从高位开始）
    string BitStreamStr;  // 01序列字符串
    for (uint8_t asciiChar : Data) {
        const string& code = hufCodes[asciiChar];//用ascii码访问编码表
        for (char c : code) {
            BitStreamStr += c;  // 累积01序列
            // '1' 设置为 1，'0' 设置为 0
            if (c == '1') {
                currentByte |= (1 << (7 - bitpos));  
            }
            bitpos++;
            if (bitpos == 8) {//每积累满8位，形成一个完整字节
                outBytes.push_back(currentByte);
                currentByte = 0;
                bitpos = 0;
            }
        }
    }
    // 处理填充：添加 '0' 直到字节边界
    int padding = (8 - bitpos) % 8;
    for (int i = 0; i < padding; ++i) {
        BitStreamStr += '0';  // 填充 '0'
        bitpos++;
        if (bitpos == 8) {
            outBytes.push_back(currentByte);
            currentByte = 0;
            bitpos = 0;
        }
    }
    if (bitpos > 0) {
        outBytes.push_back(currentByte);  // 最后不完整的字节
    }

    // 输出编码表和01序列到文本文件
    ofstream codes_out("codes.txt");
    for (int i = 0; i < 256; ++i) {
        if (!hufCodes[i].empty()) {
            if (isprint(i)) {
                codes_out << "'" << char(i) << "' (" << i << "): " << hufCodes[i] << "\n";
            } else {
                codes_out << "0x" << hex << i << ": " << hufCodes[i] << "\n";
            }
        }
    }
    codes_out.close();

    ofstream bitstream_out("bitstream.txt");
    bitstream_out << BitStreamStr << "\n";
    bitstream_out.close();

    // 写入文件头：魔数 + 符号数量 + (符号, 编码长度, 编码位串) + 填充位 + 数据
    ofstream out(outPath, ios::binary);
    if (!out) { freeTree(Root); return false; }
    out.write("HUF2", 4);  // 更新魔数为 HUF2，表示新格式
    uint16_t Cnt = 0;// 有效符号数量
    for (auto& code : hufCodes) if (!code.empty()) Cnt++;
    out.write(reinterpret_cast<const char*>(&Cnt), sizeof(Cnt));
    for (int i = 0; i < 256; ++i) {
        if (!hufCodes[i].empty()) {
            uint8_t S = (uint8_t)i;// 符号对应的ascii码
            uint8_t Len = (uint8_t)hufCodes[i].size();// 编码长度
            out.write(reinterpret_cast<const char*>(&S), sizeof(S));
            out.write(reinterpret_cast<const char*>(&Len), sizeof(Len));
            // 将编码字符串转换为字节写入
            uint8_t codeByte = 0;
            int bitPos = 7;
            for (char c : hufCodes[i]) {
                if (c == '1') codeByte |= (1 << bitPos);
                bitPos--;
                if (bitPos < 0) {
                    out.write(reinterpret_cast<const char*>(&codeByte), sizeof(codeByte));
                    codeByte = 0;
                    bitPos = 7;
                }
            }
            if (bitPos < 7) out.write(reinterpret_cast<const char*>(&codeByte), sizeof(codeByte));
        }
    }
    uint8_t Pad8 = (uint8_t)padding;
    out.write(reinterpret_cast<const char*>(&Pad8), sizeof(Pad8));
    if (!outBytes.empty()) out.write(reinterpret_cast<const char*>(outBytes.data()), outBytes.size());
    out.close();

    size_t Orig = filesystem::file_size(inPath);
    size_t Comp = filesystem::file_size(outPath);
    cout << "原始大小: " << Orig << " 字节\n";
    cout << "压缩后大小: " << Comp << " 字节\n";
    double Rate = Orig ? (double(Comp) / double(Orig) * 100.0) : 0.0;
    cout << fixed << setprecision(2) << "压缩率: " << Rate << "%\n";

    freeTree(Root);
    return true;
}

// 对文件进行哈夫曼译码
bool decodeFile(const string& InPath, const string& OutPath) {
    ifstream In(InPath, ios::binary);
    if (!In) return false;
    // 读取并验证魔数 "HUF2"，确保是有效的HUF文件
    char Magic[4];
    In.read(Magic, 4);
    if (In.gcount() != 4 || strncmp(Magic, "HUF2", 4) != 0) {
        cerr << "不是有效的 HUF 文件\n";
        return false;
    }
    // 读取符号数量 Cnt，然后读取 Cnt 个 (符号, 编码长度, 编码位串)
    uint16_t Cnt;
    In.read(reinterpret_cast<char*>(&Cnt), sizeof(Cnt));
    map<string, uint8_t> codeToSymbol;  // 编码到符号的映射
    for (int i = 0; i < Cnt; ++i) {//大循环读编码表，cnt次读取符号和编码
        uint8_t S;//ascii码
        uint8_t Len;//编码长度,多少bit
        In.read(reinterpret_cast<char*>(&S), sizeof(S));
        In.read(reinterpret_cast<char*>(&Len), sizeof(Len));
        string code;// 读取编码位串
        int bitsRead = 0;
        while (bitsRead < Len) {
            uint8_t byte;
            In.read(reinterpret_cast<char*>(&byte), sizeof(byte));
            for (int b = 7; b >= 0 && bitsRead < Len; --b) {
                code += ((byte >> b) & 1) ? '1' : '0';
                bitsRead++;
            }
        }
        codeToSymbol[code] = S;
    }

    // 读取填充位数
    uint8_t padding8;
    In.read(reinterpret_cast<char*>(&padding8), sizeof(padding8));

    // 读取压缩数据，采用istreambuf_iterator构建把bit打包成字节向量
    vector<uint8_t> Data((istreambuf_iterator<char>(In)), istreambuf_iterator<char>());
    In.close();

    // 译码：直接使用编码字典匹配
    vector<uint8_t> OutBytes;
    string currentCode;//从左往右逐位读取
    size_t byte_index = 0;//data的字节索引
    int bit_index = 7;//data每一个元素的位索引
    size_t total_bits = Data.size() * 8 - padding8;

    while (byte_index < Data.size()) {
        uint8_t byte = Data[byte_index];
        bool bit = (byte >> bit_index) & 1;
        currentCode += bit ? '1' : '0';

        // 每读取一位，检查是否匹配编码
        if (codeToSymbol.count(currentCode)) {
            OutBytes.push_back(codeToSymbol[currentCode]);
            currentCode.clear();
        }

        bit_index--;
        if (bit_index < 0) {
            bit_index = 7;
            byte_index++;
        }

        // 防止无限循环，如果读取超过总位数
        if ((byte_index * 8 + (7 - bit_index)) >= total_bits) break;
    }

    ofstream Out(OutPath, ios::binary);
    Out.write(reinterpret_cast<const char*>(OutBytes.data()), OutBytes.size());
    Out.close();
    return true;
}

void usage() {
    cout << "用法:\n";
    cout << "  huffman encode <输入文件> <输出文件>\n";
    cout << "  huffman decode <输入文件.huf> <输出文件>\n";
}

int main(int argc, char** argv) {
    if (argc != 4) { usage(); return 1; }
    string cmd = argv[1];
    string inp = argv[2];
    string outp = argv[3];
    if (cmd == "encode") {
        if (!encodeFile(inp, outp)) { cerr << "编码失败\n"; return 2; }
    } else if (cmd == "decode") {
        if (!decodeFile(inp, outp)) { cerr << "译码失败\n"; return 3; }
    } else {
        usage(); return 1;
    }
    return 0;
}
```
