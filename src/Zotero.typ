= Zotero
#label("zotero")
Zotero is a free, easy-to-use tool to help you collect, organize, cite, and share research.

== Tips
#align(center)[#table(
    columns: 2,
    align: (col, row) => (auto, auto).at(col),
    inset: 6pt,
    [Requirements], [Operations],
    [查看文献条目所属的分类], [选中该条目后按住Ctrl/Option/Alt，该文献所在的文件夹就会高亮为黄色],
    [在文献集（Collections）之间移动文献],
    [选中待移动的文献，然后根据你的操作系统按下相应快捷键， macOS：`Cmd`
      Windows/Linux：`Shift`，将该文献拖拽到其他文献集即可],

    [快速查看近期添加的文献], [右键单击#strong[My Library]，选择#strong[New Saved
  Search]，进行具体的设置],
  )
]

== Plugin
=== #link("https://retorque.re/zotero-better-bibtex/")[Better Bibtex]
- #link("https://retorque.re/zotero-better-bibtex/citation-keys/")[设置格式]

`Zotero Preferences` -\> `Better Bibtex` -\>
`Citation Keys`中，修改`citation key format`为

```
[auth:lower][year][veryshorttitle:lower]
```

=== #link("http://zotfile.com/")[ZotFile]
- 修改附件的命名格式

`Zotero Tools` -\> `ZotFile Preferences` -\>
`Renaming`中，修改格式为`{%y_}{%t_}{%a}`

=== #link("https://github.com/beloglazov/zotero-scholar-citations")[Zotero Scholar Citations]

== More
#link("https://www.zotero.org/")[Zotero Website]
