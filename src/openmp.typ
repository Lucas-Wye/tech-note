= OpenMP
#label("openmp")
-  OpenMP是由OpenMP Architecture Review
  Board牵头提出的，并已被广泛接受的，用于共享内存并行系统的多线程程序设计的一套编译指令
  (Compiler Directive)。

== Introduction
#label("introduction")
See detail at #link("https://en.wikipedia.org/wiki/OpenMP")[wiki].

== OpenMP Programming Example
#label("openmp-programming-example")
Here is a C program using OpenMP.

```c
#include<stdio.h>
#include<omp.h>

int main(void) {
    const int n = 10;
    int arr[n];

    #pragma omp parallel for  
    for(int i = 0;i < n;i++) {
        arr[i] = i;
        printf("%d\n",i);
    }

    for(int j = 0;j < n;j++){
        printf("%d\n",arr[j]);
    }

    return 0;      
}
```

== More Example
#label("more-example")
#link("https://zhuanlan.zhihu.com/p/51173703")[OpenMP并行开发（C++）] \
#link("https://blog.csdn.net/drzhouweiming/article/details/1175848")[OpenMP并行程序设计（二）]
