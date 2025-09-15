---
title: forge模组开发
published: 2025-09-15
description: '濒死状态模组开发笔记'
image: ''
tags: [MC，mods，forge]
category: 'forge'
draft: false 
lang: ''
---

## 模组主类

模组主类是模组的入口点，负责初始化模组和注册事件。`@Mod` 是 Forge（或 NeoForge）提供的注解，用来标记一个类是模组的主类。它的参数用于告诉框架如何识别和加载这个模组。

### 模组主类的modid

`@Mod`必填参数：`value`

```java
@Mod("yourmodid")
```

类型：String

作用：指定模组的唯一标识符（mod ID）

必须和 `mods.toml` 文件中的 modId 一致

```java
import net.minecraftforge.fml.common.Mod;

@Mod(LastBreath.MODID)
public class LastBreath {
    //定义模组ID
    public static final String MODID = "lastbreath";
    //日志记录器
    private static final Logger LOGGER = LoggerFactory.getLogger(LastBreath.class);
    //...
}
```

模组id可以作为注册游戏内容的前缀，避免命名冲突（就是命名空间）

```java
DeferredRegister<Item> ITEMS = DeferredRegister.create(Registries.ITEM, MODID);
//模板：
类型<泛型> 变量名 = 类名.静态方法(参数1, 参数2);
```

这段代码创建了一个注册器对象，通过泛型类`DeferredRegister`的静态方法`create`创建注册器`ITEMS`，第一个参数指明注册的内容类型（这里是item），第二个参数指明模组id

## 注册游戏内容

游戏内容注册通常在模组主类的构造函数中进行。注册内容包括物品、方块、实体等。注册通常通过事件总线（Event Bus）来完成。

首先声明注册器
