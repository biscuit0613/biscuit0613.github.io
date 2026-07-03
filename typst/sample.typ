#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)

#align(center, text(size: 20pt, weight: "bold")[
  Typst 功能展示
])

#line(length: 100%)

= 概述 <sec:intro>

Typst 是一个基于标记的排版引擎，支持数学公式、交叉引用和表格等功能。

#lorem(20)

= 数学公式

欧拉公式：

$ e^(i pi) + 1 = 0 $

二次方程求根公式：

$ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a) $

= 表格

#table(
  columns: (1fr, 2fr, 1fr),
  inset: 10pt,
  align: center + horizon,
  stroke: 0.5pt,
  [*语言*], [*用途*], [*难度*],
  [Typst], [排版], [低],
  [Python], [数据科学], [低],
  [Rust], [系统编程], [高],
  [TypeScript], [Web 开发], [中],
)


#text(gray, size: 9pt)[
  _编译时间：2026-07-03_
]
