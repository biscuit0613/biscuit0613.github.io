// paper-note.typ
// Typst 论文详细笔记模板
// 基于 ilm 包，与现有 ml_basics.typ、stereo.typ 风格一致
//
// Usage:
//   #import "../templates/paper-note.typ": paper-note
//   #show: paper-note.with(title: "论文标题", authors: "...")

#import "@preview/ilm:2.1.0": *

#let accent = rgb("#1a3a5c")

#let tip(body) = {
  block(
    fill: rgb("#FFF8E1"),
    stroke: (left: 3pt + rgb("#FFA000")),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body,
  )
}

#let warn(body) = {
  block(
    fill: rgb("#FFEBEE"),
    stroke: (left: 3pt + red),
    inset: 8pt,
    radius: (right: 4pt),
    width: 100%,
    body,
  )
}

#let formula-box(body) = {
  block(
    fill: luma(245),
    inset: (x: 12pt, y: 6pt),
    radius: 4pt,
    width: 100%,
    body,
  )
}

#let paper-note(
  title: "",
  authors: "",
  date: datetime.today(),
  abstract: [],
  body,
) = {
  set text(font: ("Noto Serif CJK SC", "New Computer Modern"), lang: "zh", size: 10pt)
  set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
  set heading(numbering: "1.1")
  set math.equation(numbering: none)

  show: ilm.with(
    title: title,
    authors: authors,
    date: date,
    abstract: abstract,
    chapter-pagebreak: false,
  )

  body
}
