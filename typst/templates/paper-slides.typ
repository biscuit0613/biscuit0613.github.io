// paper-slides.typ
// Touying 0.7.3 简约学术 PPT 模板
// heading-based slides (== Title), 白底 + 深蓝强调色

#import "@preview/touying:0.7.3": *
#import themes.simple: *

// 配色 —— 不设浅色字，确保对比度
#let accent = rgb("#1a3a5c")
#let dark-text = rgb("#222222")        // 正文用色，高对比
#let secondary-text = rgb("#444444")   // 附注/引用用色，仍保持足够对比
#let note-fill = rgb("#f0f2f5")

// 字号体系
// title(26pt) > body-default(22pt) > block-head(18pt) > block-body(15pt) > note(12pt)
#let title-size = 26pt
#let body-size = 22pt
#let block-head-size = 18pt
#let block-body-size = 15pt
#let note-size = 12pt

// 幻灯片主体
#let paper-slides(
  title: "",
  subtitle: "",
  author: "",
  date: "",
  body,
) = {
  set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: body-size, fill: dark-text)
  set par(leading: 0.6em)

  show: simple-theme.with(
    aspect-ratio: "16-9",
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
    ),
    config-colors(
      primary: accent,
      neutral-lightest: white,
      neutral-darkest: rgb("#333333"),
    ),
    config-page(
      margin: (x: 3em, y: 1.5em),
      footer: context align(right, text(size: note-size, fill: secondary-text)[
        Slide #utils.slide-counter.display()
      ]),
    ),
    config-common(new-section-slide: none),
  )

  body
}

// ======== 辅助函数 ========

// 封面
#let cover-slide(body) = {
  slide(body)
}

// 章节过渡页（尽量少用，仅在 20+ 页长 PPT 中使用）
#let section-slide(title) = {
  slide[
    #set align(center + horizon)
    #set text(size: title-size, weight: "bold", fill: accent)
    #title
  ]
}

// 灰度卡片块 —— 用于组织正文中的子模块
// usage: #card[title: ..][body: ..]
#let card(title: "", body) = {
  block(fill: note-fill, inset: (x: 10pt, y: 8pt), radius: 4pt)[
    #if title != "" [
      #text(size: block-head-size, weight: "bold", fill: accent)[#title]
      #v(0.2em)
    ]
    #set text(size: block-body-size)
    #body
  ]
}

// 双栏布局
#let two-col(left, right, ratio: (1fr, 1fr)) = {
  grid(columns: ratio, gutter: 1.5em, align: top, [#left], [#right])
}

// 插图（带可选 caption）
#let figure-img(path, caption: none, width: 80%) = {
  align(center, image(path, width: width))
  if caption != none [
    #v(0.2em)
    #set text(size: note-size, fill: secondary-text)
    #align(center)[#caption]
  ]
}

// 原文引用块（缩小字号 + 左竖线，区分于正文）
#let quote-block(body, source: none) = {
  block(
    fill: none,
    stroke: (left: 3pt + secondary-text),
    inset: (left: 12pt, top: 4pt, bottom: 4pt, right: 4pt),
  )[
    #set text(size: note-size, fill: secondary-text, style: "italic")
    #body
    #if source != none [
      #v(0.1em)
      #set text(size: note-size, fill: secondary-text, style: "normal")
      #align(right)[—— #source]
    ]
  ]
}

// 公式展示
#let formula-block(..formulas) = {
  for f in formulas [
    #align(center, text(size: 16pt)[$ #f $])
    #v(0.4em)
  ]
}

// 代码展示
#let code-block(lang, code) = {
  show raw: set text(font: ("JetBrains Mono", "Cascadia Code"), size: 11pt)
  raw(code, lang: lang)
}

// 致谢页
#let thanks-slide(extra: none) = {
  slide[
    #v(5em)
    #align(center, text(size: 26pt, weight: "bold", fill: accent)[谢谢！Q & A])
    #v(1.5em)
    #align(center, text(size: 12pt, fill: secondary-text)[#extra])
  ]
}

// 提示/引用块（背景灰底）
#let note-block(body) = {
  block(fill: note-fill, inset: 10pt, radius: 4pt, width: 100%, body)
}
