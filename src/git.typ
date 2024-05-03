= Git
#label("git")
- Git 是一个开源的分布式版本控制系统，用于敏捷高效地处理任何或小或大的项目。
- Git 是 Linus Torvalds 为了帮助管理 Linux 内核开发而开发的一个开放源码的版本控制软件。
- Git 与常用的版本控制工具 CVS, Subversion 等不同，它采用了分布式版本库的方式，不必服务器端软件支持。

== 创建版本库
#label("创建版本库")
```sh
git init
git clone URL
```

== 修改和提交
#label("修改和提交")
```sh
git status
git diff FILE_NAME
git add FILE_NAME
git mv OLD_NMAE NEW_NAME
git rm FILE_NAME
git rm --cached FILE_NAME # 停止跟踪文件但不删除
git commit -m YOUR_COMMENT
git commit --amend
```

== 查看提交历史
#label("查看提交历史")
```sh
git log
git reflog # 所有分支信息
git log -p FILE_NAME # 查看指定文件的提交历史
git blame FILE_NAME # 以列表方式查看指定文件的提交历史
```

== 撤销
#label("撤销")
```sh
git reset HEAD
git reset --hard HEAD
git checkout HEAD FILE_NAME
git revert COMMIT_ID
```

== 分支
#label("分支")
```sh
# 查看所有远程分支
git branch -r
# 查看远程和本地所有分支
git branch -a
# 查看所有本地分支
git branch

# 切换分支
git checkout BRANCH

git branch NEW_BRANCH
git branch -d BRANCH
git branch -m OLD_NAME NEW_NAME

# 拉取远程分支并创建本地分支
# (1)使用该方式会在本地新建分支x，并自动切换到该本地分支x，采用此种方法建立的本地分支会和远程分支建立映射关系
git checkout -b 本地分支名x origin/远程分支名x
# (2)使用该方式会在本地新建分支x，但是不会自动切换到该本地分支x，需要手动checkout，采用此种方法建立的本地分支不会和远程分支建立映射关系
git fetch origin 远程分支名x:本地分支名x

# 删除远程分支(1)
git branch -r -d origin/BRANCH_NAME
git push origin :BRANCH_NAME
# 删除远程分支(2)
git push origin --delete BRANCH_NAME
```

== 标签
#label("标签")
```sh
git tag # 列出所有的本地标签
git tag TAG_NAME # 基于最新的提交创建标签
git tag -d TAG_NAME
```

== 合并与衍合
#label("合并与衍合")
```sh
git merge BRANCH
git rebase BRANCH
```

== 远程操作
#label("远程操作")
```sh
git remote -v
git remote show REMOTE # 查看指定远程版本库信息
git remote add REMOTE URL

git fetch REMOTE
git pull REMOTE BRANCH
git push REMOTE BRANCH
git push REMOTE:BRANCH:TAG
git push --tags
```

== submodule
#label("submodule")
```sh
# 添加子仓库
git submodule add <仓库地址> <本地路径>
# 检出子仓库
git submodule init # 初始化本地配置文件
git submodule update # 检出父仓库列出的commit
## 或者
git submodule update --init --recursive
# 递归克隆
git clone <仓库地址> --recursive
```

== worktree
可以在多个不同的目录显示不同git分支内容
```sh
git worktree
```

== 合并多个commit
#label("合并多个commit")
```sh
commit THIRD_COMMIT_ID
    add third commit

commit SECOND_COMMIT_ID
    add second_commit

commit FIRST_COMMIT_ID
    add third commit
```

首先有3个commit，需要将前两个commit合成一个

```sh
git rebase -i FIRST_COMMIT_ID
```

出现如下界面：

```sh
pick SECOND_COMMIT_ID add second_commit
pick THIRD_COMMIT_ID add third commit

...
```

修改成：

```sh
pick SECOND_COMMIT_ID add second_commit
squash THIRD_COMMIT_ID add third commit
```

DONE.


== stash
#label("stash")
- stash 是 Git
  提供的一种机制，它可以将当前工作目录和暂存区的修改保存起来。当我们需要切换分支、执行
  pull 操作或解决一些紧急 bug 时，stash
  可以帮助我们保存当前的修改，避免丢失工作。

- 我们可以把 stash 看作是一个临时保存修改的容器，每次执行 stash
  操作时，Git
  将当前的修改保存到一个栈中，并将工作目录和暂存区恢复到最新的提交状态。stash
  不会创建新的提交记录，它只是将修改暂时存储起来
```sh
git stash # Git 会将当前的修改保存到 stash 中，并将工作目录和暂存区还原到最新的提交状态
git stash list # 查看 stash 列表，确认保存的 stash
git stash show stash@{0} # 查看某个 stash 中保存的具体修改内容
git stash apply stash@{0} # 将0所对应的内容应用到当前分支
git stash drop stash@{0} # 删除这个stash
```

== Git Server
#label("git-server")
```sh
sudo adduser git
su git
cd
# add ssh key
git init --bare [PROJECT_NAME].git
```

== 垃圾回收
#label("垃圾回收")
Git仓库越来越臃肿，大多数版本控制系统存储的是一组初始文件，
以及每个文件随着时间的演进而逐步积累起来的差异；
而Git则会把文件的每一个差异化版本都记录在案。
这意味着，即使你只改动了某个文件的一行内容，
Git也会生成一个全新的对象来存储新的文件内容。

对象碎片：如果你改动了一个很大的文件，
git会为这个文件生成了一个很大的Blob对象

```sh
cd .git
du -ah  # 查看文件大小
git gc --prune=now # 垃圾回收
```

实际上，并不需要手动调用 gc
命令。每当碎片对象过多，或者你向远端服务器发起推送的时候，git
就会自动执行一次打包过程。

== More
#label("more")
#link("https://www.runoob.com/git/git-tutorial.html")[git教程]
