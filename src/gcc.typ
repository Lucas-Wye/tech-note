= GCC
#label("gcc")
- GCC编译器也称为Linux
  GCC命令，它有很多选项。GCC编译器是Linux下最常用的编译器。

== Install
#label("install")
```sh
# MacOS安装Xcode工具链
xcode-select --install
# Ubuntu
sudo apt install gcc
```

== Basic
#label("basic")
```sh
gcc -c filename.c # compile only, produce .o
gcc -g # compile for debugging
gcc -o filename.o #
gcc -O 1,2,3,4,s,fast # for optimization level
gcc -Ipathname
gcc -Dsymbol # define preprocessor symbol
gcc -Ldirectory # add directory to the library search path
gcc -lxyz # link with library libxyz.a or libxyz.so
```

== gdb
#label("gdb")
```sh
gdb BINARY_FILE
list
br 8 # breakpoint in line 8
run
print value
next
where
help
quit
```

== multiple gcc version in one Ubuntu machine
#label("multiple-gcc-version-in-one-ubuntu-machine")
use `update-alternatives` to manage them.

```sh
sudo update-alternatives --config gcc
```

== make
#label("make")
(1)Predefined Macros - AS - assembler (as) - CC - C compiler command
(cc) - FC - Fortran compiler command (fc) - CPP - C++ preprocessing
command (\$(CC) -E) - CXX - C++ compiler command (g++) - CFLAGS - C
compiler option flags (e.g. -g) - FFLAGS - Fortran compiler option flags
(e.g. -g) - LDFLAGS - Linking option flags (e.g. –L /usr/share/lib) -
LDLIBS – Linking libraries (e.g. -lm)

(2)Special Internal Macros

```sh
$* # The basename of the current target
$< # The name of a dependency file, as we see on last page
$@ # The name of the current target.
$? # The list of dependencies that are newer than the target.
```

== C++
- C++虚函数实现机制: 虚函数表
- 单继承、多继承、虚继承
  - 单继承：子类只继承一个基类，简单且常用。
  - 多继承：子类可以继承多个基类，但可能会带来复杂性，如命名冲突。
  - 虚继承：用于解决多继承中的菱形继承问题，确保只有一个基类实例。
- 四种cast: 在 C++ 中，有四种类型转换，分别是 static_cast、dynamic_cast、const_cast 和 reinterpret_cast。
  - static_cast：用于通常的类型转换，例如将一个浮点数转换成整数，或者将一个指针类型转换成另一种指针类型。 它可以在编译时进行类型检查，但不能进行运行时检查。
  - dynamic_cast：用于将指向基类的指针或引用转换成指向派生类的指针或引用。 它可以在运行时检查类型，并返回 NULL 指针或抛出 bad_cast 异常来指示类型转换失败。
  - const_cast：用于将 const 对象的常量性去除。
  - reinterpret_cast: reinterpret_cast能够完成任意指针类型向任意指针类型的转换，即使它们毫无关联。该转换的操作结果是出现一份完全相同的二进制复制品，既不会有指向内容的检查，也不会有指针本身类型的检查。
- 三种智能指针
  - std::unique_ptr<T> ：独占资源所有权的指针。
  - std::shared_ptr<T> ：共享资源所有权的指针。
  - std::weak_ptr<T> ：共享资源的观察者，需要和 std::shared_ptr 一起使用，不影响资源的生命周期。


== More
#label("more")
#link("https://blog.csdn.net/gatieme/article/details/51671430")[more of gdb]
\
#link("https://github.com/Lucas-Wye/Makefile-Templates")[Makefile example]
