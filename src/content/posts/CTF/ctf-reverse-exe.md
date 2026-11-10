---
title: ctf逆向学习
published: 2026-09-22
description: 'CTF的逆向入门，一个简单的exe逆向题目，适合初学者练习。'
image: ''
tags: [逆向, CTF, PE文件, objdump, CSAPP]
category: '网络安全'
draft: false
lang: ''
---

## 题目

HIT-CTF 逆向入门题，目标文件 `week1_1.exe`（约 60KB）。目标是找到一段输入，让程序输出 `this is the right flag!`。

这一篇记录从零开始的分析过程，重点是**每一步是怎么想的**，而不只是敲了什么命令。

## 第 1 步：认清文件 —— `file`

第一步永远是先搞清"这是什么物种"，才好决定用什么工具、按什么姿势去碰它。

```bash
$ file week1_1.exe
week1_1.exe: PE32+ executable for MS Windows 6.00 (console), x86-64, 10 sections
```

`file` 不靠扩展名，而是读文件开头的"魔数"（magic bytes）判断真实类型。`.exe` 后缀可以随便改，但文件开头的魔数骗不了它。

这一行输出要拆成**事实**和**判断**两层，别混在一起：

**事实（它直接告诉我的）：**

| 输出 | 含义 |
| --- | --- |
| `PE32+` | PE32+ 格式，即 64 位 Windows 可执行文件 |
| `x86-64` | 为 64 位架构编译 |
| `(console)` | 控制台子系统（不是 GUI 程序） |
| `10 sections` | 有 10 个节 |

**判断（我要从事实推出的下一步动作）：**

- 64 位 → 后面读寄存器是 `rax/rcx/rdx...`，不是 `eax` 那一套。**看错位数，汇编全读错。**
- `(console)` → 它跟人打交道的方式是"命令行输入输出"，所以大概率有 `scanf` 读入 + `printf` 输出 → 后面应该去导入表找这几个函数。

:::tip
`file` 的定位是"5 秒分类器"，负责告诉你这是**什么物种**，而不是里面**在干什么**。物种内部的构造和行为，得靠 `objdump` / `strings` / 反汇编。
:::

## 第 2 步：看程序的"性格" —— 导入表

程序调用了 Windows 的哪些函数，是它行为的指纹。看导入表（import table）就能快速判断它大概在干什么。

```bash
$ objdump -p week1_1.exe | sed -n '/Import Tables/,/The Function Table/p'
```

挑出有信息量的几个：

| 导入函数 | 人话 | 说明什么 |
| --- | --- | --- |
| `__stdio_common_vfprintf` | = `printf` | 会输出提示 |
| `__stdio_common_vfscanf` | = `scanf` | 会读入你的输入 |
| `strncmp` | 字符串比较 | 拿输入和某物比对 |
| `strlen` | 求长度 | 配合 strncmp 用 |
| `_CrtDbgReport` | 调试 CRT 报告 | 这是 **Debug 版**构建 |

:::note
新版 Windows 的 C 运行库（uCRT）把 `printf` / `scanf` 实现成了内部函数，你写 `printf` 编译出来就变成调 `__stdio_common_vfprintf`。**认它们就等于认 printf/scanf。**
:::

同样重要的是**没看到什么**：没有文件读写、没有网络、没有加密库（`Crypt*`）。信号很干净。

### 由此判断

```
printf + scanf + strncmp   →   读输入 → 和一个字符串比 → 报对错
```

这意味着一件关键的事：**正确答案必然以"明文字符串"的形式存在程序里。** 于是这场仗的性质就变了：

- 不是"逆一个加密算法"（那要写脚本、逐位还原）
- 而是"**找到那个字符串，看清它**"

策略一定成这样就轻松了：后面所有动作都围绕 **定位比较点 → 找出比较对象 → 读出来**。

## 附：读懂 `objdump -h` 的节头表

`objdump -h` 打印的是**节头表（section header table）**，这是 CSAPP 第 7 章「链接」的核心结构。

```bash
$ objdump -h week1_1.exe
Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .textbss      00010000  0000000140001000  0000000140001000  00000000  2**4
                  ALLOC, LOAD, CODE
  1 .text         000078b1  0000000140011000  0000000140011000  00000400  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  2 .rdata        00002b4c  0000000140019000  0000000140019000  00007e00  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .data         00000200  000000014001c000  000000014001c000  0000aa00  2**4
                  CONTENTS, ALLOC, LOAD, DATA
  ...
```

### 目标文件本质是个"容器"

CSAPP 那条编译链：

```
hello.c ──编译器──► hello.s ──汇编器──► hello.o ──链接器──► hello ──加载器──► 进程(虚拟内存)
                              (可重定位目标文件)      (可执行目标文件)
```

关键认知：**目标文件（`.o` / `.exe`）本身只是一个"容器"，里面按用途把字节分装成一堆「节（section）」。** 而**节头表就是这个容器的目录** —— 每一项告诉你：某个节叫什么、多大、在文件里的哪个位置、运行时在内存的哪个地址、有什么权限。

### 逐列解释

```
Idx Name          Size      VMA               LMA               File off  Algn
  3 .data         00000200  000000014001c000  000000014001c000  0000aa00  2**4
```

| 列 | 含义 |
| --- | --- |
| `Idx` | 节的编号 |
| `Name` | 节名 |
| `Size` | 节的字节数 |
| `VMA` | Virtual Memory Address —— 运行时在内存里的地址 |
| `LMA` | Load Memory Address —— 加载地址（用户态程序里和 VMA 相同；嵌入式固件"从 ROM 加载、到 RAM 运行"才不同） |
| `File off` | 节的内容在文件里的起始偏移 |
| `Algn` | 对齐要求，`2**4` = 16 字节 |

### 真正的重点：同一个节活在两个世界里

```
       磁盘上的文件                          运行时的进程(虚拟内存)
   ┌──────────────────────┐            ┌──────────────────────┐
   │ File off 0xaa00 处    │            │ VMA 0x14001c000 处    │
   │  .data 的字节        │   ═══►     │  .data 的字节        │
   │ (用"文件偏移"定位)    │            │ (用"虚拟地址"定位)    │
   └──────────────────────┘            └──────────────────────┘
                    ▲                              ▲
                    └──── 节头表把两套坐标对上 ────┘
```

- **文件里**：地址是"从文件头数第几个字节" → `File off` 列
- **内存里**：地址是"虚拟地址空间里的位置" → `VMA` 列
- **节头表 = 这两套坐标的对照表**

所以"把某个内存地址换算成文件偏移"的本质就是**拿这张表做翻译**：

```
文件偏移 = 节的 File off + (目标 VMA − 节的 VMA)
```

:::tip
PE 的 VMA = `ImageBase + RVA`。x64 程序默认基址是 `0x140000000`，所以看到的地址都那么大。这对应 CSAPP 说的"每个程序都以为自己从某个地址开始运行"，靠虚拟内存实现。
:::

### ELF ↔ PE 名词对照

CSAPP 教的是 Linux 的 ELF，这题是 Windows 的 PE，名词换了但骨架相同：

| CSAPP / ELF | 这个 PE | 装什么 |
| --- | --- | --- |
| `.text` | `.text` | 机器码 |
| `.rodata` | **`.rdata`** | **只读数据（字符串常量！）** |
| `.data` | `.data` | 已初始化的全局/静态变量 |
| `.bss` | `.bss` | 未初始化全局变量 |
| `.symtab` | 符号在 PDB，不在 exe 里 | 符号表 |
| `.rel.text` / `.rel.data` | `.reloc` | 重定位信息 |
| Section header table | Section table | 节目录 |

**认住这个：CSAPP 的 `.rodata` = PE 的 `.rdata`，存字符串常量。** 后面要找的提示语（`"wrong flag"`、`"input the flag:"`）就住在这儿；而 `.data` 住的是**可写**的全局变量。

### 标志位与 `.bss` / `.textbss`

| 标志 | 含义 |
| --- | --- |
| `CONTENTS` | 节在文件里**有实际字节** |
| `ALLOC` | 运行时**占用内存** |
| `LOAD` | 启动时**要加载** |
| `READONLY` | 不可写 |
| `CODE` / `DATA` | 是代码 / 是数据 |

特别注意第 0 节 `.textbss`：

```
  0 .textbss      00010000  0000000140001000  0000000140001000  00000000  2**4
                  ALLOC, LOAD, CODE          ← 注意：没有 CONTENTS
```

它的 `Size` 是 `0x10000`，但 `File off` 是 0、文件大小是 0，**文件里一个字节都没有**，只在运行时占内存。这就是 CSAPP 里 **`.bss` 的经典设计**：未初始化的数据（全 0）没必要在文件里存，只记一个"大小"，加载器直接清零 —— **省文件空间**。这里是把同样的思想用在了代码区，是 MSVC **增量链接**的产物。

## 目前的分析链

```
file  →  64 位控制台 PE 程序
   ↓
导入表  →  printf + scanf + strncmp
   ↓
战略判断  →  正确答案是程序里的一个明文字符串，目标 = 找到并读出它
   ↓
下一步  →  定位校验逻辑（调用 strncmp 的那一行）
```

## 第 3 步：在两万行汇编里精准逮住 `strncmp`

**要回答的问题：校验逻辑具体在哪个地址？**

**思路：不读全文，用"锚点"。** 第 2 步已经从导入表拿到了 `strncmp` 的 IAT 地址 = `0x1400202d0`。任何调用 `strncmp` 的指令，必然要引用这个地址，直接搜它：

```bash
$ grep -n "1400202d0" dis.txt
1320:   14001197e:	ff 15 4c e9 00 00 	call   QWORD PTR [rip+0xe94c]        # 0x1400202d0
8155:   1400156f6:	ff 25 d4 ab 00 00 	jmp    QWORD PTR [rip+0xabd4]        # 0x1400202d0
```

两个结果，但**只有一个是真正的调用**，看指令助记符：

| 地址 | 指令 | 性质 |
| --- | --- | --- |
| `14001197e` | `call QWORD PTR [...]` | ✅ 真正的调用 |
| `1400156f6` | `jmp QWORD PTR [...]` | ❌ 跳转桩（thunk） |

`0x1400156f6` 那个是**导入桩**：一条 `jmp [IAT]`，相当于一个"接线员"——别的代码想调 `strncmp` 就 `call` 这个桩，桩再跳到真正的函数。它是 MSVC **增量链接**的产物（ELF 里对应的东西叫 PLT）。

:::tip
Debug 版（增量链接）的 `.text` 开头会塞一大片 `jmp` 跳转桩，看到 `jmp [IAT]` 基本可以当成"转发"，不是真正的调用点。
:::

**所以真正做比较的只有一处：`0x14001197e`。** 它所在的函数，就是校验函数。往上一路翻到函数序言（`push rbp; sub rsp, ...`），起点是 **`0x1400118c0`**。铁证：CRT 启动代码是 `0x140011159: jmp 0x1400118c0` 跳进来的 —— **它就是 `main`。**

## 第 4 步：它拿什么跟我的输入比？

**要回答的问题：`strncmp` 的三个参数分别是什么？**

x64 Windows 调用约定：前 4 个参数依次放 `rcx, rdx, r8, r9`。看 `call` 前三条指令往这三个寄存器装了什么：

```asm
140011948  lea rcx,[0x140019d30]   ; "input the flag:"
14001194f  call 0x1400111d1        ; → printf   打印提示
─────────────────────────────────────────────────────────────
140011954  lea rdx,[rbp+0x28]      ;   arg2 = 栈上的输入缓冲区
140011958  lea rcx,[0x140019d24]   ;   arg1 = "%20s"
14001195f  call 0x14001128f        ; → scanf    读入我的输入
─────────────────────────────────────────────────────────────
140011964  lea rcx,[0x14001c000]   ;
14001196b  call 0x1400111a4        ; → strlen   结果在 rax
140011970  mov r8,rax              ;   arg3 = 长度
140011973  lea rdx,[0x14001c000]   ;   arg2 = 0x14001c000 处的字符串
14001197a  lea rcx,[rbp+0x28]      ;   arg1 = 我的输入
14001197e  call strncmp            ; ← 比较！
─────────────────────────────────────────────────────────────
140011984  test eax,eax
140011986  je 0x140011996          ; 相等 → 成功分支
140011988  lea rcx,[0x140019c10]   ; "wrong flag\n"
14001198f  call printf
140011996  lea rcx,[0x140019c90]   ; "this is the right flag!\n"
14001199d  call printf
```

:::note
认函数不用一路追 thunk 到底。看**参数是什么、返回值怎么用**更快：`rcx=字符串常量` 后调用 → 输出；`rcx="%20s", rdx=&缓冲区` → 输入；`rcx=某字符串` 且返回值马上被搬走当长度 → `strlen`。
:::

翻译成 C：

```c
printf("input the flag:");
scanf("%20s", input);                       // input 在栈上 rbp+0x28
if (strncmp(input, buf, strlen(buf)) == 0)  // buf 在 0x14001c000
    printf("this is the right flag!\n");
else
    printf("wrong flag\n");
```

**结论：标准答案就住在 `0x14001c000`。**

## 第 5 步：比较前的那段循环（全题的分水岭）

按直觉，下一步就是"读 `0x14001c000`"。**但先别动** —— 回到 `main` 开头，`printf` 之前还有一段循环，它在**比较之前**执行：

```asm
1400118ef  mov  DWORD [rbp+4],0     ; i = 0
140011900  ...  call strlen         ; 循环条件: i <= strlen(buf)
14001192e  movsx eax,BYTE [buf+i]   ; c = buf[i]
140011932  cmp  eax,0x6f            ; c == 'o' ?
140011935  jne  ...                 ; 不是就跳过
140011942  mov  BYTE [buf+i],0x30   ; 是就写成 '0'
```

C 版本：

```c
for (int i = 0; i <= strlen(buf); i++)   // buf = 0x14001c000
    if (buf[i] == 'o')     // 0x6f = 'o'
        buf[i] = '0';      // 0x30 = '0'
```

**磁盘上存的字符串 ≠ 实际被比较的字符串。** 程序在比对前，先把缓冲区里所有字母 `o` 换成了数字 `0`。

:::caution
这就是陷阱。`strings` 搜出来的是 `Lilac{rEost4rT}`（字母 `o`），是**假答案**；程序改成 `Lilac{rE0st4rT}`（数字 `0`）才是**真答案**。出题人专门造来惩罚"strings 一把梭"。
:::

**记住这个检查项：凡是看到"比较/使用某块数据之前有循环动过它"，就不能直接读原始值，必须把变换算进去。** 常见变换：逐字符替换（`o↔0`、`l↔1`）、大小写翻转、异或、逆序、凯撒位移。

## 第 6 步：抠出数据，算出答案

`0x14001c000` 是虚拟地址，先换算成文件偏移：

```
文件偏移 = 节的 File off + (目标 VMA − 节的 VMA)
        = 0xaa00 + (0x14001c000 − 0x14001c000)   ← .data 节
        = 0xaa00
```

读出来、施加变换、反向验证：

```python
d = open('week1_1.exe','rb').read()
raw = d[0xaa00:0xaa00+64].split(b'\x00')[0]     # 磁盘上的原始值
buf = bytearray(raw) + b'\x00'
for i in range(len(buf)):
    if buf[i] == ord('o'):
        buf[i] = ord('0')
print(buf.split(b'\x00')[0].decode())
# Lilac{rE0st4rT}
```

| 阶段 | 值 |
| --- | --- |
| 磁盘上的原始值 | `Lilac{rEost4rT}` |
| 程序变换后的值 | `Lilac{rE0st4rT}` |
| `strncmp(输入, buf, 15) == 0` | ✅ |

## Flag

```
Lilac{rE0st4rT}
```

## 完整判断链

```
file            → 64 位控制台 PE 程序
   ↓
导入表          → printf + scanf + strncmp
   ↓
战略判断        → 答案是个明文字符串，目标 = 找到并读出它
   ↓
搜 strncmp 的 IAT 地址 → 唯一调用点 0x14001197e ∈ main(0x1400118c0)
   ↓
读 strncmp 参数  → 标准答案在 0x14001c000
   ↓
★ 发现比较前的循环动了同一块数据 → 磁盘值 ≠ 答案值（o → 0）
   ↓
节表换算 0x14001c000 → 文件偏移 0xaa00 → dump 得 "Lilac{rEost4rT}"
   ↓
施加变换 → "Lilac{rE0st4rT}"  ✅
```

## 小结

1. **`strings` 是找线索的工具，不是得答案的工具。** 这题专门用 `o/0` 替换惩罚"strings 一把梭"。
2. **顺关键 API 定位，而不是从头读汇编。** 用 `strncmp` 的 IAT 地址当锚点，一步命中。
3. **检查项：比较前有没有循环改过同一块数据。** 有，就必须把变换算进去。
4. **地址要换算成文件偏移才能读**：`文件偏移 = 节 File off + (VA − 节 VMA)`。
