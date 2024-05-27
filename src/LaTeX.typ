= LaTeX
-  LaTeX（音译“拉泰赫”）是一种基于ΤΕΧ的排版系统，由美国计算机学家莱斯利·兰伯特（Leslie
  Lamport）在20世纪80年代初期开发。
  利用这种格式，即使使用者没有排版和程序设计的知识也可以充分发挥由TeX所提供的强大功能，能在几天，甚至几小时内生成很多具有书籍质量的印刷品。
-  对于生成复杂表格和数学公式，这一点表现得尤为突出。因此它非常适用于生成高印刷质量的科技和数学类文档。这个系统同样适用于生成从简单的信件到完整书籍的所有其他种类的文档。

== Install
从#link("https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/")[清华镜像源]下载对应操作系统的Texlive软件包

```sh
# 安装
sudo ./install-tl
# 设置环境变量
# LaTeX
export TEX_HOME=/usr/local/texlive/2019
export PATH=$PATH:$TEX_HOME/bin/x86_64-linux
export INFOPATH=$INFOPATH:$TEX_HOME/texmf-dist/doc/info
export MANPATH=$MANPATH:$TEX_HOME/texmf-dist/doc/man
```

== 安装 Windows 字体
```sh
# 创建 win 下字体专用文件夹
sudo mkdir /usr/share/fonts/winfonts

# 复制windows上的字体到/usr
sudo cp your_winfonts_dir /usr/share/fonts/winfonts 

# 进入字体文件夹
cd /usr/share/fonts/winfonts

# 修改访问权限
sudo chmod 744 *

# 回到主目录
cd ~

# 更新字体信息
sudo mkfontscale
sudo mkfontdir
sudo fc-cache -f -v
```

== 通过取消pdf压缩加快编译
=== XelaTeX
在导言区加上特殊语句，例子如下：
```latex
\special{dvipdfmx:config z 0}
\documentclass{article}
\begin{document}
hello world.
\end{document}
```
或者在latexmk编译脚本中修改:
```perl
$xdvipdfmx="xdvipdfmx -z0 -q -E -o %D %O %S";
```
z0即采用不压缩的方式生成pdf

=== pdfTeX
设置两个变量的值：
```latex
\pdfcompresslevel=0
\pdfobjcompresslevel=0
```

== More
#link("http://github.com/Lucas-Wye/Latex_template")[LaTeX模板] \
#link("http://latexstudio.net/")[LaTeX开源小屋] \
#link("https://tex.stackexchange.com/")[Stackexchange] \
#link("https://github.com/Lucas-Wye/Share/tree/master/LaTeX")[LaTeX Introduction]
\
#link("https://castel.dev/post/lecture-notes-1/")[How I’m able to take notes in mathematics lectures using LaTeX and Vim]
