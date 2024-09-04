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

== More
#label("more")
#link("https://blog.csdn.net/gatieme/article/details/51671430")[more of gdb]
\
#link("https://github.com/Lucas-Wye/Makefile-Templates")[Makefile example]
