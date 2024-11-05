#align(
  center,
  text(24pt)[
    *TechNote*
  ],
)
#align(
  center,
  text(21pt)[
    *Lucas-Wye*
  ],
)

#let date = datetime.today()
#align(
  center,
  text(17pt)[
    #date.display()
  ],
)

#set heading(numbering: "1.1.1")
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
#pagebreak()

#include "src/ask.typ"
#pagebreak()

#include "src/howtosearch.typ"
#pagebreak()

#include "src/git.typ"
#pagebreak()

#include "src/Linux.typ"
#pagebreak()

#include "src/Kali.typ"
#pagebreak()

#include "src/cli_net_work.typ"
#pagebreak()

#include "src/Tmux.typ"
#pagebreak()

#include "src/docker.typ"
#pagebreak()

#include "src/vi_vim.typ"
#pagebreak()

#include "src/gcc.typ"
#pagebreak()

#include "src/java.typ"
#pagebreak()

#include "src/Python.typ"
#pagebreak()

#include "src/matlab.typ"
#pagebreak()

#include "src/LaTeX.typ"
#pagebreak()

#include "src/openmp.typ"
#pagebreak()

#include "src/Zotero.typ"
#pagebreak()

#include "src/ic.typ"

#include "src/llm.typ"

