= Linux
- Linux是一套免费使用和自由传播的类Unix操作系统，是一个基于POSIX和Unix的多用户、多任务、支持多线程和多CPU的操作系统。它能运行主要的Unix工具软件、应用程序和网络协议。它支持32位和64位硬件。Linux继承了Unix以网络为核心的设计思想，是一个性能稳定的多用户网络操作系统。

== Control Key
```
[CTRL]U           cancel line
[CTRL]C           cancel operation
[CTRL]S           pause display
[CTRL]Q           restart display
[CTRL]A           光标移到行首
[CTRL]E           光标移到行末
[CTRL]K           清除至当前行尾
[CTRL]V           treat following control character as normal character
[Option]方向键     以单词为单位移动
```

== User
```
sudo adduser USERNAME
# 添加root权限
sudo usermod -g sudo USERNAME
# change password
passwd
# delete user
sudo userdel -r USERNAME
```

== Infomation
```
who
who am i
whoami
env
alias
man
```

== File Maintenance
```
# r = 4, w = 2, x = 1
chmod
umask # set in startup files for the account to masks out permissions, umask numbers added to desired permission number equals 7.
chgrp # change the group of the file
chown # change the owner of a file

# 查看当前目录文件大小
# (1)列出当前目录下每个文件的大小，同时也会给出当前目录下所有文件大小总和
ls -lht

# (2)列出当前文件夹下所有文件对应的大小
du -sh PATH

# 删除文件中的空行
cat YOUR_FILE | sed -e '/^$/d'

# conditions
-r return true (1) if it exists and is readable, otherwise return false (0)
-w true if it exists and is writable
-x true if it exists and is executable
-f true if it exists and is a regular file (or for csh, exists and is not a directory)
-d true if it exists and is a directory
-e true if the file exists
-o true if the user owns the file
-z true if the file has zero length (empty)

# 对Exfat文件系统支持
sudo apt install exfat-utils

# 打包
tar -cvf  YOUR_FILE.tar YOUR_FILE # 仅打包
tar -zcvf YOUR_FILE.tar.gz YOUR_FILE # gzip压缩
tar -jcvf YOUR_FILE.tar.bz2 YOUR_FILE # bzip2压缩

# 查看文件
tar -tvf YOUR_FILE.tar
tar -ztvf YOUR_FILE.tar.gz
tar -jtvf YOUR_FILE.tar.bz2

# 解包
tar -xvf YOUR_FILE.tar
tar -zxvf YOUR_FILE.tar.gz
tar -jxvf YOUR_FILE.tar.bz2
```

== find and search
```
# 查找24小时内修改过的文件
find ./ -mtime 0
# 查找当前目录及子目录中的.c文件
find . -name "*.c"
# 查找当前目录符合条件的文件内容
grep -nHR "STRING" .
# grep不匹配二进制文件
grep --binary-files=without-match
```

== process
```
ps
ps -ef
kill -9 PID
```

== Bash executes order
```
# login shell executes order:
/etc/profile
~/.bash_profile
~/.bash_login
~/.profile

# non-login shell executes:
/etc/bashrc
~/.bashrc
```

== History
```
history
!598 # 执行第598条命令
sudo !! # 以root执行上一条命令
history  | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head # 统计情况
```

== CPU
```
# 总核数 = 物理CPU个数 x 每颗物理CPU的核数
# 总逻辑CPU数 = 物理CPU个数 x 每颗物理CPU的核数 x 超线程数

# 物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l

# CPU型号
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

# CPU的负载，返回1、5、15分钟内的负载情况
uptime
```

== 内存
```
cat /proc/meminfo
free
```

== 磁盘
```sh
# 硬盘信息
fdisk -l
# 查看磁盘IO的性能
iostat -x 10
# 挂载硬盘到某个文件夹
sudo mount /dev/sda YOUR_PATH
# 查看硬盘挂载信息
df -h
# 取消挂载
sudo umount YOUR_PATH
```

== Fedora Firefox 视频播放异常处理
```
sudo dnf install ffmpeg ffmpeg-libs --allowerasing
```

== 开机自动挂载Windows硬盘分区
```
查看分区信息
sudo fdisk -l
查看磁盘类型
sudo blkid
```

输出

```
Device         Boot     Start       End   Sectors  Size Id Type
/dev/nvme0n1p1 *         2048   1187839   1185792  579M  7 HPFS/NTFS/exFAT
/dev/nvme0n1p2        1187840 210903039 209715200  100G  7 HPFS/NTFS/exFAT
/dev/nvme0n1p3      210903040 420618239 209715200  100G  7 HPFS/NTFS/exFAT
/dev/nvme0n1p4      420620286 500117503  79497218 37.9G  5 Extended
/dev/nvme0n1p5      420620288 421595135    974848  476M 83 Linux
/dev/nvme0n1p6      421597184 450891775  29294592   14G 83 Linux
/dev/nvme0n1p7      450893824 500117503  49223680 23.5G 83 Linux
```

```
修改配置文件
sudo vim /etc/fstab

# for Windows 10 C:/
/dev/nvme0n1p2 /home/usrname/Windows_Disks/C ntfs defaults 0 0

挂载新添加的分区
sudo mount -a
```

== 字体
```sh
# 安装Windows字体
sudo cp [Windows-Fonts] /usr/share/fonts/Windows-Fonts
sudo mkfontscale
sudo mkfontdir
fc-cache

# 查看中文字体
fc-list:lang=zh-cn
```

== I/O Redirection and Piping
```
# stdin: 0, stdout: 1, stderr: 2
|                      管道
>                      stdout重定向到file
>>                     stdout重定向到file(不覆盖)
<                      stdin从file重定向
tee                    复制stdout
>/dev/null             直接扔掉stdout
1>FILE_1 2>FILE_2        stdout to FILE_1, stderr to FILE_2
>FILE 2>&1             redirect stdout and stderr to FILE
2>&1 | tee             将stderr和stdout输出到文件的同时在屏幕上输出
```

== 清理僵尸进程
```
# find process
ps aux | awk '$8 ~ /^[Zz]/'
# find parent process
ps -A -ostat,pid,ppid | grep -e '[zZ]'
# kill parent process
```

== 开机进入命令行
```sh
sudo systemctl set-default multi.user # 进入命令行
sudo systemctl set-default graph...   # 进入图形界面
```

== 命令行切换回GUI
```
startx
sudo service gdm3 restart
```

== Ubuntu设置窗口键在左侧
```sh
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
```

== 生成强密码
```sh
openssl rand -base64 NUMBER
```

== terminal output to clip
- Windows: `clip`
- MacOS: `pbcopy`, `pbpaste`
- Linux: `xsel`

== ssh
```sh
# 安装 SSH(Secure Shell) 服务以提供远程管理服务
sudo apt install openssh-server

# 启动ssh服务
/etc/init.d/ssh start
sudo service ssh start

# 检测是否已启动
ps -e | grep ssh

## SSH远程登录
ssh username@IP_ADDR

# 将文件/文件夹从远程机下载到本地(scp)
scp -r username@IP_ADDR:/home/username/remotefile.txt .

# 设置公钥登录
# (1)复制本地的公钥
cat ~/.ssh/id_rsa.pub
# (2)在远程机器上写入复制的公钥
vim ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
# (3)远程机器授权公钥登录
sudo echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
# (4)重启ssh服务
sudo systemctl restart sshd.service
# Or
ssh-copy-id -i Public_Key_File Remote_Server

# .ssh/config example
Host {HOSTNAME}
  HostName {IP}
  User {Username}

ssh HOSTNAME

# SSH for data transfer
ssh -qTfnN -D PORT SERVER
```

== More
#link("https://github.com/QSCTech/2020-Autumn-Round-Two/tree/master/problem-set-1")[A good introduction to Linux]
