---
title: 快速排序
published: 2025-12-05
description: '快速排序的原理及复杂度分析'
image: ''
tags: [排序]
category: '数据结构与算法'
draft: false 
lang: ''
---

[【数据结构合集 - 快速排序(算法过程, 效率分析, 稳定性分析)】 https://www.bilibili.com/video/BV1y4421Z7hK/?share_source=copy_web&vd_source=508f9008633ddcfb01e9adad004516c4](https://www.bilibili.com/video/BV1y4421Z7hK/?share_source=copy_web&vd_source=508f9008633ddcfb01e9adad004516c4)

## 快速排序算法原理

分治。

选一个基准值pivot，把数组分成两部分，一部分比pivot小，另一部分比pivot大，然后递归排序这两部分，最后合并。

### 算法步骤

1. 从数组中选择一个基准值 `pivot`。

2. left指针从左向右扫描，right指针从右向左扫描。如果 left 指向的元素小于等于 pivot，则left,right元素交换， left 右移；如果 right 指向的元素大于等于 pivot，则left,right元素交换， right 左移。
3. 重复上述过程，直到 left 和 right 指针相遇。此时，pivot 放到 left 指针位置，完成一次划分。

    注意，此时pivot位置的元素已经**归位**，不再参与后续排序。
4. 递归地对 pivot 左右两部分进行快速排序，直到子数组长度为1或0。

### 代码实现

```cpp
int partition(array<int, 5>& arr, int low, int high) {
    int pivot = arr[low]; // 选择基准值
    int left = low;
    int right = high;
    while (left < right) {
        // 从右向左找第一个小于 pivot 的元素
        while (left < right && arr[right] >= pivot) {
            right--;
        }
        // 从左向右找第一个大于等于 pivot 的元素
        while (left < right && arr[left] <= pivot) {
            left++;
        }
        if (left < right) {
            swap(arr[left], arr[right]); // 交换
        }
    }
    // 将 pivot 放到正确位置
    swap(arr[low], arr[left]);
    return left; // 返回 pivot 的位置
}

void quickSort(array<int, 5>& arr, int low, int high) {
    if (low < high) {
        int pivotIndex = partition(arr, low, high); // 划分
        quickSort(arr, low, pivotIndex - 1);  // 递归排序左半部分
        quickSort(arr, pivotIndex + 1, high); // 递归排序右半部分
    }
}
```

### 时间复杂度分析

- 最好情况：每次划分都能将数组均匀分成两半，时间复杂度为 O(n log n)。

- 最坏情况：每次划分都只能减少一个元素，时间复杂度为 O(n^2)。
- 平均情况：随机分布情况下，时间复杂度为 O(n log n)。
