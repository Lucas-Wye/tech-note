= Emacs
#label("emacs")
-  GNU Emacs, An extensible, customizable, free/libre text editor — and
  more.
-  At its core is an interpreter for Emacs Lisp, a dialect of the Lisp
  programming language with extensions to support text editing.

== Cursor movement
#label("cursor-movement")
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [C-v],
  [Move forward one screenful],
  [M-v],
  [Move backward one screenful],
  [C-l],
  [Clear screen and redisplay all the text],
  [C-n],
  [Move next line],
  [C-p],
  [Move previous line],
  [C-f],
  [Move forward a character],
  [C-b],
  [Move backward a character],
  [M-f],
  [Move forward a word],
  [M-b],
  [Move backward a word],
  [C-a],
  [Move to beginning of line],
  [C-e],
  [Move to end of line],
  [M-a],
  [Move back to beginning of sentence],
  [M-e],
  [Move forward to end of sentence],
  [M-\<],
  [Move to the beginning of file],
  [M-\>],
  [Move to the end of file],
  [C-u NUM],
  [(Prefix) repeat NUM times],
  [C-g],
  [stop/cancel current execution],
)
]

== Insert and Delete
#label("insert-and-delete")
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [DEL],
  [delete the character just before the cursor],
  [C-d],
  [delete the next character after the cursor],
  [M-DEL],
  [kill the word immediately before the cursor],
  [M-d],
  [kill the next word after the cursor],
  [C-k],
  [kill from the cursor position to end of line],
  [M-k],
  [kill to the end of the current sentence],
  [C-SPACE + \[Move Cursor\]],
  [select text],
  [C-y],
  [yank the more recent killed text back],
  [M-y],
  [replace the yanked text with the previous kill],
  [C-/, C-\_, C-x u],
  [Undo],
)
]

== File and Buffer
#label("file-and-buffer")
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [C-x C-f],
  [find a file],
  [C-x C-s],
  [save the file],
  [C-x C-b],
  [list buffers],
  [C-x b],
  [switch buffer],
  [C-x s],
  [save some buffers],
  [C-x C-c],
  [quit the Emacs session],
  [C-z],
  [exit Emacs temporarily],
  [M-x],
  [prefix of some commands],
)
]

== Search
#label("search")
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [C-s],
  [search forward],
  [C-r],
  [search backward],
)
]

== Windows
#label("windows")
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [C-x 1],
  [get rid of extra windows and go back to basic one-window editing],
  [C-u 0 C-l],
  [],
  [C-h k C-f],
  [],
  [C-x 2],
  [split the screen into two windows],
  [C-M-v],
  [scroll the bottom window],
  [C-v o],
  [move the cursor to the other window],
)
]

== 配置镜像源
#label("配置镜像源")
#link("https://mirror.tuna.tsinghua.edu.cn/help/elpa/")[清华源]

== More
#label("more")
#link("https://www.spacemacs.org")[Spacemas]
