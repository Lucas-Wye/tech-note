#import "winnote/lib.typ": *

#let date = datetime.today()
#show: winnote.with(
  title: "TechNote",
  author: "lucas.zw.ye@outlook.com",
  createtime: date.display(),
  lang: "zh",
  bibliography-style: "ieee",
  // preface: [], //Annotate this line to delete the preface page.
  // bibliography-file: bibliography("refs.bib"), //Annotate this line to delete the bibliography page.
)

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
#pagebreak()

#include "src/llm.typ"
#pagebreak()

#include "src/cuda.typ"
#pagebreak()

#include "src/world-quant.typ"
