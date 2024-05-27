#align(center, text(24pt)[
  *TechNote*
])
#align(center, text(21pt)[
  *Lucas-Wye*
])

#let date = datetime(
  year: 2024,
  month: 3,
  day: 9,
)
#align(center, text(17pt)[
    #date.display()
])

#set heading(numbering: "1.1.1")
#show outline.entry.where(
  level: 1
): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
#pagebreak()

#include "src/ask.typ"

#include "src/howtosearch.typ"

#include "src/git.typ"

#include "src/Linux.typ"

#include "src/Kali.typ"

#include "src/cli_net_work.typ"

#include "src/Tmux.typ"

#include "src/docker.typ"

#include "src/vi_vim.typ"

#include "src/gcc.typ"

#include "src/java.typ"

#include "src/Python.typ"

#include "src/matlab.typ"

#include "src/LaTeX.typ"

#include "src/openmp.typ"

#include "src/Zotero.typ"
