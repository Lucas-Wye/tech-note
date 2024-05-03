= How to use search engine
#label("how-to-use-search-engine")
- Search engines are systems that enable users to search for documents on the World Wide Web.
- Popular examples include Yahoo!Search, Bing, Google, and Ask.com.

== 特殊符号
#label("特殊符号")
#strong[双引号]：把搜索词放在双引号中，代表#strong[完全匹配搜索]（顺序也必须完全匹配）

eg: "浙江大学SCDA"

#strong[减号]：搜索不包含减号后面的词的页面，使用这个指令时减号前面必须是#strong[空格]，减号后面没有空格，紧跟着需要排除的词

eg: 浙江大学 -学院

#strong[星号]：通配符

eg: 浙\*大学

#strong[inurl]：查找网址中包含指定字符的页面

eg: inurl:nice

#strong[inanchor]：查找导入链接锚文字中包含搜索词的页面

eg: inanchor:点击这里

#strong[intitle]: 查找页面title 中包含关键词的页面

eg: intitle: 查老师

#strong[filetype]：查找特定格式文件

eg: filetype:pdf SCDA

#strong[site]: 搜索某个域名下的所有子路径

eg: site: www.zju.edu.cn

== 快照功能
#label("快照功能")
搜索引擎在收录网页时，对网页进行备份，存在自己的服务器缓存里，由于网页快照是存储在搜索引擎服务器中，所以查看网页快照的速度往往比直接访问网页要快

eg: 高斯分布 site:zh.wikipedia.org

== 特殊搜索
#label("特殊搜索")
- 中文文献 \
  #link("http://xueshu.baidu.com")[百度学术] \
  #link("https://cn.bing.com/academic?mkt=zh-CN")[bing学术] \
  #link("https://scholar.google.com")[谷歌学术]
- 英文文献 \
  #link("https://cn.bing.com/academic?mkt=zh-CN")[bing学术] \
  #link("https://scholar.google.com")[谷歌学术] \
  #link("https://sci-hub.tw")[Sci-hub] \
  #link("http://ieeexplore.ieee.org")[IEEE]
- 编程相关 \
  #link("http://github.com")[github] \
  #link("https://medium.com")[medium] \
  #link("http://stackoverflow.com")[stackoverflow]

== 深度搜索
#label("深度搜索")
特殊的搜索工具可以搜索#strong[深网]的内容

微信搜索 https://weixin.sogou.com

Archive搜索引擎 http://archive.org

Wikihow #link("https://zh.wikihow.com/搜索深网")

more https://www.freebuf.com/news/137844.html

== More
#label("more")
#link("https://github.com/Lucas-Wye/Share/blob/master/search.pdf")[search.pdf]
\
#link("https://www.zhihu.com/question/19847393")[搜索引擎有哪些常用技巧]
\
#link("https://zhuanlan.zhihu.com/p/33188000")[深网搜索引擎]
