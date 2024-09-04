= Docker
#label("docker")
- Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的镜像中，然后发布到任何流行的 Linux或Windows 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。

== Install
#label("install")
```sh
# Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 建立docker组
sudo groupadd docker
# 将当前用户加入docker组
sudo usermod -aG docker $USER

# 卸载本机所有的镜像、容器、卷以及配置文件
sudo rm -rf /var/lib/docker
```

== Basic
=== Pull
```sh
docker pull [user name]/[repo name]:[tag name]
```

=== Run
```sh
-i # 以交互模式运行容器，通常与 -t 同时使用
-t # 为容器重新分配一个伪输入终端，通常与 -i 同时使用
-v # 绑定一个卷，格式为：本机绑定目录:容器内部绑定目录
-d # 后台运行容器，并返回容器ID
-P # 随机端口映射，容器内部端口随机映射到主机的高端口
-p # 指定端口映射，格式为：主机(宿主)端口:容器端口
-a # 指定标准输入输出内容类型，可选 STDIN/STDOUT/STDERR 三项
–name # 对所新建容器进行命名
–rm # 容器终止后，自动删除容器文件
```

=== Others
```sh
# 列出容器
docker container ls -a
# 查看容器ID
docker ps -a
# 重新启动已被终止的指定容器
docker start [CONTAINER ID]
# 终止容器
docker stop [CONTAINER NAME/ID]
# 若是利用 -it 在容器内部进行操作，仅需输入 exit 即可
# 删除容器
docker kill [CONTAINER NAME/ID]
# 将所有容器删除
docker container prune
# 列出镜像
docker images
# 重命名镜像
docker tag [old REPOSITORY]:[old TAG] or [IMAGE ID] [new REPOSITORY]:[new TAG]
# 删除镜像
docker rmi [IMAGE]
# 存出镜像
docker save -o [xx.tar] [REPOSITORY]:[TAG]
# 载入镜像
sudo docker load --input [镜像文件]
# 更新镜像
docker commit [OPTIONS] [IMAGE ID] [new REPOSITORY]:[new TAG]
# -m: 提交的描述信息
# -a: 指定镜像作者
```

== More
#label("more")
#link("https://www.runoob.com/docker/docker-container-usage.html")[Docker教程]
\
#link("https://wiki.jikexueyuan.com/project/docker-technology-and-combat/save_load.html")[Docker学习笔记]
