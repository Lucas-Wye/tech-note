= Java
#label("java")
-  Java 是由Sun Microsystems公司于1995年5月推出的高级程序设计语言。
  Java可运行于多个平台，如Windows, Mac OS，及其他多种UNIX版本的系统。

== Install
#label("install")
#link("https://www.oracle.com/technetwork/java/javase/downloads/index.html")[JDK]
\
#link("https://www.jetbrains.com/idea/")[IntelliJ IDEA]

```sh
# 配置环境变量                                
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_144  # 这里换成自己的jdk目录
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH
```

== Usage of adb(Android Debug)
#label("usage-of-adbandroid-debug")
```sh
# 卸载系统软件
adb shell
pm list package
pm uninstall -k --user 0 package_name
```
