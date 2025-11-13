---
title: CSAPP_不同进制赋值与字节级读写
published: 2025-10-29
description: '64位机器上的不同进制赋值与字节级读写示例'
image: ''
tags: [数据存储, 进制, CSAPP]
category: 'CSAPP'
draft: false 
lang: ''
---

## 不同进制赋值

计算机存储数据时，通常使用不同的进制表示数值。在64位机器上，不同进制的赋值方式如下：

```c
long a = 123456789012345;        // 十进制赋值
long b = 0x1CBE991A14E9D;       // 十六进制赋值
long c = 01777777777777777777777; // 八进制赋值
```

## 字节级读写

在计算机中，数据是以字节为单位存储的。这里以64位机器cpp为例，展示如何进行字节级读写：

```c
#include <stdio.h>
#include <stdint.h>
#include <string.h>
void print_bytes(void *ptr, size_t size) {
    uint8_t *byte_ptr = (uint8_t *)ptr;
    for (size_t i = 0; i < size; i++) {
        printf("%02x ", byte_ptr[i]);
    }
    printf("\n");
}
```
