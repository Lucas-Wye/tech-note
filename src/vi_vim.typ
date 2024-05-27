= Vi Editor
#label("vi-editor")
-  所有的 Unix Like 系统都会内建 Vi
  文书编辑器，其他的文书编辑器则不一定会存在。但是目前我们使用比较多的是
  Vim 编辑器。
-  Vim
  具有程序编辑的能力，可以主动的以字体颜色辨别语法的正确性，方便程序设计。
-  Vim是从 Vi
  发展出来的一个文本编辑器。代码补完、编译及错误跳转等方便编程的功能特别丰富，在程序员中被广泛使用。简单的来说，
  Vi 是老式的字处理器，不过功能已经很齐全了，但是还是有可以进步的地方。

== File Operation
#label("file-operation")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [:wq], [存盘退出],
  [:q!], [退出不保存],
  [:saveas \[path/to/file\]], [另存为 \[path/to/file\]],
  [:qa!], [强行退出所有的正在编辑的文件],
  [:bn 和 :bp], [切换下一个或上一个文件],
  [:w !sudo tee %], [以sudo保存正在编辑的文件],
  [:n], [move to next file],
  [:rew], [回到第一个文件],
  [:edit \[Filename\]], [打开新文件],
)

== Cursor movement
#label("cursor-movement")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [hjkl], [move],
  [/\[PATTERN\]], [搜索],
  [?\[PATTERN\]], [搜索],
  [/\\\<\[PATTERN\]\\\>], [精确匹配搜索],
  [%], [匹配括号移动],
  [f], [搜索并移动到某个字符前],
  [t], [到某个字符前的第一个字符],
  [:N], [到第N行],
  [gg], [到第一行],
  [G], [到最后一行],
  [\[n\]G], [go to last line or line \[n\]],
  [w/W], [到下一个单词的开头],
  [e/E], [到下一个单词的结尾],
  [b], [到上一个单词的开头], [0],
  [beginning of current line], [\$], [end of current line],
  [^], [beginning of text on current line], [\[CTRL\] F/B],
  [move screen], [\[CTRL\] D/U], [move half screen],
  [zz], [将当前行放置于屏幕中间],
  [zt], [将当前行放置于屏幕顶端],
  [zb], [将当前行放置于屏幕底端],
)

== Inserting text
#label("inserting-text")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [i], [前插入],
  [a], [后插入], 
  [I], [insert text at beginning of line],
  [A], [append text at end of line],
  [o], [在当前行后插入一个新行],
  [O], [在当前行前插入一个新行],
)

== Deleting text
#label("deleting-text")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [d], [删除],
  [D], [删除当前行光标后所有内容],
  [x], [删当前光标的字符],
  [X], [删当前光标前的字符],
)

== Changing commands
#label("changing-commands")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [u], [undo],
  [\[CTRL\] r], [redo],
  [.], [repeat last operation],
  [p], [后粘贴],
  [P], [前粘贴],
  [y], [复制],
  [s/S], [substitute],
  [~], [change case of character],
  [J], [join current line and next line],
)

== Split windows
#label("split-windows")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [:split/vsplit], [创建分屏],
  [\[CTRL\] w + 方向], [切换分屏],
)

== Command line mode
#label("command-line-mode")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [:\[cmd\]], [暂时退出命令行执行cmd],
  [:set all], [display all option settings],
  [:\[Addr/%\]s/old expr/new string/\[g\]], [替换当前行/Addr/%(文件内所有)的old expr为new string,\[g\]全局替换，否则只替换第一个 ｜],
  [\[CTRL\] p/n], [自动补齐],
  [\[CTRL\] +/-], [改变尺寸],
  [v], [visual模式],
  [V], [v-line模式],
  [\[CTRL\] v], [v-block模式],
  [:normal \[Command\]], [可视化模式下执行命令],
  [qa -> q -> \@a], [录制宏],
  [ci + ”], [删除引号之中的内容],
  [tabe], [打开新的标签页],
  [+/-tabnext], [切换标签页],
  [:tab sball], [打开所有的buffer到独立的一个标签],
  [\'.], [定位到上次修改的那一行行首],
  [\`.], [定位到上次修改的位置],
  [可视模式 -> o], [切换选区扩展的方向，向上或者向下],
  [gf], [打开当前光标显示的那个文件],
  [gt/gT], [切换标签页],
  [:r!\[cmd\]], [执行命令，并将结果复制到当前光标的下一行],
  [:%!\[cmd\]],[将buffer内容重定向到命令的标准输入，并用输出替换buffer内容],
)

== Regular expression
#label("regular-expression")
#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [?], [match any single character at the indicated position],
  [\*], [match any string of zero or more characters],
  [\[abc…\]], [match any of the enclosed characters],
  [\[a-e\]], [match any characters in the range a,b,c,d,e],
  [\[!def\]], [match any characters not one of the enclosed characters, sh/bash],
  [{abc,bcd,cde}], [match any set of characters separated by comma (,) (no spaces), bash/csh],
  [~], [home directory of the current user, bash/csh],
  [~ user], [home directory of the specified user, bash/csh],
  [.], [match any single character except newline],
  [\[^abc\]], [match any character NOT in the enclosed set],
  [^exp], [regular expression must start at the beginning of the line],
  [exp\$], [regular expression must end at the end of the line],
  [\\], [treat the next character literally 转义字符],
  [xy\*z], [xy开头，z结尾的字符串],
)

== Plug
#label("plug")
https://github.com/junegunn/vim-plug

== .vimrc
#label("vimrc")
#link("https://github.com/Lucas-Wye/rc/blob/master/sys/vimrc")[vimrc]

== #link("https://neovim.io")[NeoVim]
#label("neovim")
使用Vim配置文件

```sh
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
```

== More
#label("more")
#link("https://www.runoob.com/linux/linux-vim.html")[Vi/Vim教程] \
#link("https://coolshell.cn/articles/5426.html")[简明 VIM 练级攻略]
