= Python
#label("python")
-  Python 是一种解释型、面向对象、动态数据类型的高级程序设计语言。
-  Python 由 Guido van Rossum 于 1989 年底发明，第一个公开发行版发行于
  1991 年。 像 Perl 语言一样, Python 源代码同样遵循 GPL(GNU General
  Public License) 协议。

== Install
#label("install")
从#link("https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/")[清华镜像源]下载对应平台的
anaconda/miniconda 安装即可。

== conda创建python虚拟环境
#label("conda创建python虚拟环境")
```sh
# 查看当前存在哪些虚拟环境                                
conda env list
## or
conda info -e 
# 创建虚拟环境
conda create -n your_env_name python=X.X  # 版本选择：2.7、3.6等
# 激活环境
conda activate your_env_name
# 关闭虚拟环境
conda deactivate
# 安装package到your_env_name
conda install -n your_env_name package_name
# 删除环境中的某个包
conda remove --name your_env_name package_name
# 删除虚拟环境
conda remove -n your_env_name --all
```

== 常用包安装方法
#label("常用包安装方法")
```sh
# tensorflow
conda install tensorflow
# pytorch(CPU)
conda install pytorch torchvision cpuonly -c pytorch
```

=== conda导出环境依赖
#label("conda导出环境依赖")
```sh
conda list -e > requirements.txt
```

=== Jupyter notebook
#label("jupyter-notebook")
访问远程服务器的notebook配置：

```sh
# 生成一个 notebook 配置文件
jupyter notebook --generate-config
# 生成密码
jupyter notebook password
```

修改配置文件 ~/.jupyter/jupyter\_notebook\_config.py

```python
c.NotebookApp.ip = '*' # 允许任何IP访问
c.NotebookApp.password = u'sha:...' # 密码的哈希值
c.NotebookApp.open_browser = False 
c.NotebookApp.port = 8888 # 自行指定一个端口
```

=== PyPy
#label("pypy")
https://www.pypy.org \
https://github.com/rvianello/conda-pypy

=== Cython
#label("cython")
https://cython.org

=== 镜像源
#label("镜像源")
`cat ~/.condarc`

```
channels:
 - defaults
 - ric/channel/pypy

show_channel_urls: true

default_channels:
 - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
 - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
 - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r

custom_channels:
 conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
 pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud

envs_dirs:
 - ~/pypy-envs
```

== pip
#label("pip")
```sh
# 导入依赖包                                
pip install -r requirements.txt 
# 只导出项目依赖包
pip install pipreqs
pipreqs ./
# 导出依赖包
pip freeze > requirements.txt
# 离线下载
pip download -d [DIR] -r requirements.txt 
# 离线安装
pip install --no-index --find-links=[DIR] -r requirements.txt  
```

=== 镜像源
#label("镜像源-1")
`cat ~/.pip/pip.conf`

```
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host = mirrors.aliyun.com
```

== More
#label("more")
#link("http://nbviewer.jupyter.org/")[ipynb文件在线查看工具]
