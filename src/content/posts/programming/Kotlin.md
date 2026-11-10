---
title: Kotlin 扫盲笔记
published: 2025-09-28
description: '为了安卓开发而学习 Kotlin 的一些笔记'
image: ''
tags: [Kotlin, Android]
category: '编程语言'
draft: false 
lang: ''
---

## kotlin 函数

Kotlin 中定义函数使用 `fun` 关键字，语法如下：

```kotlin
fun functionName(param1: Type1, param2: Type2): ReturnType {
    // 函数体
    return value
}
```

其中返回值`ReturnType`为空时可以省略返回类型，或者使用 `Unit` 作为返回类型：

函数可以直接返回表达式：

```kotlin
fun max(a: Int, b: Int) = if (a > b) a else b
```

这相当于：

```kotlin
fun max(a: Int, b: Int): Int {
    return if (a > b) a else b
}
```

函数可以有默认参数，函数的参数也可以是可变数量的参数，用 `vararg` 关键字表示。这样允许传入零个或多个参数，而不需要显式地创建一个数组。例如：

```kotlin
fun deleteID(vararg ids: String) {
    for (id in ids) {
        id.deleteUserById(id)
        println("Deleting user with ID: $id")
    }
}

deleteID("饼干", "小明", "小红")  // 可以传多个参数
```

注意使用 `vararg` 时，如果传入的是一个数组，需要使用展开运算符 `*`：

```kotlin
val ids = arrayOf("饼干", "小明", "小红")
deleteID(*ids)  // 使用 * 展开数组
```

并且，`vararg` 参数必须是函数的最后一个参数。参数列表中也只能有一个 `vararg` 参数。

## kotlin 类和对象

Kotlin 中定义类使用 `class` 关键字，语法如下：

```kotlin
class ClassName(val property1: Type1, var property2: Type2) {
    // 类体
    fun method1() {
        // 方法体
    }
}
```

## if 语句

Kotlin 中的 if 语句与其他编程语言类似，但它也可以作为表达式使用，这意味着它可以返回一个值。例如：

```kotlin
val max = if (a > b) a else b
```

## when 语句

Kotlin 的 when 语句类似于其他语言中的 switch 语句，但更强大。它可以匹配多种条件，并且可以作为表达式使用。例如：

```kotlin
when (x) {
    1 -> print("x == 1")
    2 -> print("x == 2")
    else -> { // 注意这个块
        print("x is neither 1 nor 2")
    }
}
```

其中 `-> ` 前面的部分是条件，后面的部分是执行的代码块。

条件可以是任何表达式，包括范围和类型检查：

```kotlin
when (x) {
    in 1..10 -> print("x is in the range")
    !in 10..20 -> print("x is outside the range")
    is String -> print("x is a string")
    else -> print("none of the above")
}
```

