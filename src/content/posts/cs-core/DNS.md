---
title: DNS
published: 2026-05-14
description: ''
image: ''
tags: []
category: '网络与分布式系统'
draft: true 
lang: ''
---

## 简介

全称：Domain Name System（域名系统）

核心功能：

- 域名 → IP地址 的转换（也可反向，但主要是正向解析）

- 主机别名 → 规范名转换

- 邮件服务器别名 → 规范名转换

- 负载分担（一个域名对应多个 IP 地址）

重要性：没有DNS，用户需记忆IP地址（如“61.135.169.125”），无法便捷上网

## DNS的层次结构

DNS采用层次命名树，根为“.”（通常省略）。从右向左依次为：

```plaintext
主机名.二级域名.顶级域.根
```

1. 根域：顶级域之上，用点“.”表示，由根服务器管理（全球13组逻辑根服务器）。

2. 顶级域（TLD，Top-Level Domain）：

    通用顶级域（gTLD）：.com, .org, .net, .edu, .gov, .mil 等

    国家代码顶级域（ccTLD）：.cn（中国）、.jp（日本）、.uk（英国）等

3. 二级域：如 hit.edu.cn 中的 edu

子域（三级及以下）：如 `www.hit.edu.cn` 中的 www

每一级域名都有自己的 DNS 服务器，存放下级域名的 IP 地址。

举例：域名 `www.hit.edu.cn.`（最后的点代表根）

根：.

TLD：.cn

二级域：.edu.cn

三级域：.hit.edu.cn

主机名：www

## DNS查询过程

两种查询类型：

- 递归查询：客户端给服务器发查询请求，服务器代为解析，返回结果（ip地址）给客户端

- 迭代查询：本地 DNS 向根/TLD/权威服务器发送查询请求，服务器返回下一步应查的服务器地址

假设客户端向本地DNS服务器（LDNS）发起递归查询：

客户端 → LDNS：请求 <www.hit.edu.cn> 的IP地址（发起递归查询）。

1. LDNS → 根服务器：LDNS 询问根服务器（开始迭代查询）。根服务器不知道具体IP，但返回`.cn` TLD 服务器地址。

2. LDNS → `.cn` TLD服务器：询问 <www.hit.edu.cn>。TLD服务器返回 `edu.cn` 权威服务器地址。

3. LDNS → `hit.edu.cn` 权威服务器：询问 <www.hit.edu.cn>。权威服务器返回其IP地址（如 202.118.224.241）。

4. LDNS → 客户端：将IP地址返回客户端。

客户端：使用该IP地址与目标Web服务器建立TCP连接。

缓存机制：每一步的结果（如TLD服务器地址、IP地址）都会被LDNS缓存一段时间（TTL，Time To Live），减少重复查询。
