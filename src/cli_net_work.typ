= Network
#label("network")
-  A computer network is a digital telecommunications network which
  allows nodes to share resources. In computer networks, computing
  devices exchange data with each other using connections (data links)
  between nodes.

== Commands
#label("commands")
```sh
ping 
domainname
hostname

cat /etc/hosts # ip address
sudo systemctl restart NetworkManager # hosts生效

cat /etc/resolv.conf # dns server
ip # TCP/IP interface configuration and routing utility
ifconfig # configure a network interface
route # show / manipulate the IP routing table
netstat # show network status (network connections, routing tables, interface statistics, masquerade connections, and multicast memberships)

sudo ping ip地址 -i 0.01 -s 65500 # 每0.01秒给ip地址对应的机器发送65500字节的数据包
```

== Useful Remote Connection Utilities
#label("useful-remote-connection-utilities")
• #strong[ftp] \[options\] host, transfer file(s) using file transfer
protocol \
• #strong[telnet] \[host \[port\]\], communicate with host using telnet
protocol \
• #strong[ssh], remote login or remote execution using secure shell \
• #strong[rcp/scp], remotely copy files from this machine to another
machine \
• #strong[rsync], smartly copy files over network after checking
contents \
• #strong[curl], transfer a URL via HTTP, FTP, IMAP, etc \
• #strong[wget], download files over the Internet via HTTP or FTP \
• #strong[lynx/links], text-mode (mini) web browser

=== aria2
#label("aria2")
(1)Install

```sh
# Ubuntu
sudo apt-get install aria2
# CentOS
yum install aria2
```

(2)Usage

```sh
# 在命令后附加地址即可
aria2c "url"
# 分段下载，利用 aria2 的分段下载功能可以加快文件的下载速度
# 使用 2 个连接来下载该文件，s的参数值介于 1~5 之间
aria2c -s 2 "url"  

# 断点续传，在命令中使用 c 选项可以断点续传文件
aria2c -c "url" 
```

=== curl
#label("curl")
-  client URL tool

(1)不带有任何参数时，发出 GET 请求

```sh
curl https://www.example.com
```

(2)`-A`指定User-Agent，默认用户代理字符串是curl/\[version\]

```sh
curl -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36' https://google.com
```

(3)`-b` 参数用来向服务器发送 Cookie

```sh
# 生成一个标头Cookie: foo=bar，向服务器发送一个名为foo、值为bar的 Cookie
curl -b 'foo=bar' https://google.com
```

(4)`-d` 参数用于发送 POST 请求的数据体

```sh
curl -d'login=emma＆password=123'-X POST https://google.com/login
# `--data-urlencode` 等同于 `-d` 
# 发送 POST 请求的数据体，区别在于会自动将发送的数据进行 URL 编码
```

(5)`-G` 参数用来构造 URL 的查询字符串

```sh
# 实际请求的 URL 为https://google.com/search?q=kitties&count=20
curl -G -d 'q=kitties' -d 'count=20' https://google.com/search
```

(6)`-H` 参数添加 HTTP 请求的标头

```sh
curl -H 'Accept-Language: en-US' https://google.com
curl -d '{"login": "emma", "pass": "123"}' -H 'Content-Type: application/json' https://google.com/login
```

#block[
#set enum(numbering: "(1)", start: 7)
+  `-i` 参数打印出服务器回应的 HTTP 标头
]

```sh
# 先输出服务器回应的标头，然后空一行，再输出网页的源码
curl -i https://www.example.com
```

(8)`-o` 参数将服务器的回应保存成文件，等同于wget命令

```sh
curl -o example.html https://www.example.com
# `-O` 参数将服务器回应保存成文件，并将 URL 的最后部分当作文件名。
curl -O https://www.example.com/foo/bar.html
# 通过添加 `-C` 继续对该文件进行下载，已经下载过的文件不会被重新下载
curl -C -O http://www.gnu.org/software/gettext/manual/gettext.html
```

(9)使用wget或者curl下载github release文件

```
curl -LJO GITHUB_RELEASE_LINK
wget --no-check-certificate --content-disposition GITHUB_RELEASE_LINK
```

=== terminal设置代理
#label("terminal设置代理")
```sh
# MacOS & Linux
export http_proxy=http://127.0.0.1:PORT # PORT替换成具体的端口
export https_proxy=http://127.0.0.1:PORT
# Windows
set https_proxy="http://127.0.0.1:PORT"
set http_proxy="http://127.0.0.1:PORT"
```

=== nmcli
#label("nmcli")
```sh
# connect to l2tp
nmcli con up {L2TP_VPN_NAME} --ask
```

=== Windows VPN连接
#label("windows-vpn连接")
```
rasdial VPN_NAME USERNAME PASSWORD
```

== More
#label("more")
