= tmux
#label("tmux")
-  tmux是一个优秀的终端复用软件，类似GNU Screen，但来自于OpenBSD，采用BSD授权
-  使用它最直观的好处就是，通过一个终端登录远程主机并运行tmux后，在其中可以开启多个控制台而无需再“浪费”多余的终端来连接这台远程主机

== Install
#label("install")
```sh
# Ubuntu
sudo apt-get install tmux
# MacOS
brew install tmux
```

== 基本操作
#label("基本操作")
```sh
tmux # 新建一个无名称的会话
tmux new -s demo # 新建一个名称为demo的会话
# 进入之前会话
tmux a # 默认进入第一个会话
tmux a -t demo # 进入到名称为demo的会话
# 离开会话
[PREFIX] d
# 关闭会话
tmux kill-session -t demo # 关闭demo会话
tmux kill-server # 关闭服务器，所有的会话都将关闭
# 查看会话
tmux list-session # 查看所有会话
tmux ls # 查看所有会话，提倡使用简写形式

# 滚屏/cope mode
[PREFIX] [
# 设置滚屏vi快捷键
echo "setw -g mode-keys vi" >  ~/.tmux.conf
tmux source-file ~/.tmux.conf
# copy
[PREFIX] [  -> [Space] -> Select -> [Enter]
# paste
[PREFIX] ]

# 新建窗口
[PREFIX] c
# 切换窗口
[PREFIX] n

# 切换pane
[PREFIX] Up|Down|Left|Right
# 垂直分屏
[PREFIX] %
# 水平分屏
[PREFIX] "
```

== 用户共享
The first user should run:
```sh
tmux -S /tmp/shared new-session -s shared
chmod 777 /tmp/shared
```
The second user:
```sh
tmux -S /tmp/shared attach-session -t shared
```

== More
#label("more")
#link("http://louiszhai.github.io/2017/09/30/tmux/")[tmux使用手册]
