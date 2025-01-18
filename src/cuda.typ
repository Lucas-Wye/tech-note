= Cuda
+ SM（Streaming Multiprocessor）和SP（Streaming Processor）是硬件层次的，其中一个SM可以包含多个SP。
  thread是一个线程，多个thread组成一个线程块block，多个block又组成一个线程网格grid

+ 在CUDA 架构下执行时的最小单位是thread。
  若干个thread可以组成一个线程块（block）。
  一个block中的thread能存取同一块共享内存，可以快速进行同步和通信操作。
  每一个block 所能包含的thread 数目是有限的。
  执行相同程序的block，可以组成grid。
  不同block 中的thread 无法存取同一共享内存，因此无法直接通信或进行同步。
  不同的grid可以执行不同的程序（kernel）。

+ CUDA的设备在实际执行过程中，会以block为单位。
  把一个个block分配给SM进行运算；而block中的thread又会以warp（线程束）为单位，对thread进行分组计算。
  目前CUDA的warp大小都是32，也就是说32个thread会被组成一个warp来一起执行。
  同一个warp中的thread执行的指令是相同的，只是处理的数据不同。

== shared memory bank conflict
在访问shared memory时，因多个线程读写同一个Bank中的不同数据地址时，导致shared memory并发读写退化 成顺序读写的现象叫做Bank Conflict
- 当多个线程读写同一个Bank中的数据时，会由硬件把内存读写请求，拆分成 conflict-free requests，进行顺序读写
- 特别地，当一个warp中的所有线程读写同一个地址时，会触发broadcast机制，此时不会退化成顺序读写

== stream
- 将数据拆分称许多块，每一块交给一个Stream来处理
- 每一个Stream包含了三个步骤：1）将属于该Stream的数据从CPU内存转移到GPU内存，2）GPU进行运算并将结果保存在GPU内存，3）将该Stream的结果从GPU内存拷贝到CPU内存。
- 所有的Stream被同时启动，由GPU的scheduler决定如何并行。

用于实现GPU的两个特性：
- 数据拷贝和数值计算可以同时进行
- 两个方向的拷贝可以同时进行（GPU到CPU，和CPU到GPU），数据如同行驶在双向快车道
注：进行数值计算的kernel不能读写正在被拷贝的数据。

== cuda graph
CUDA Graphs 是 NVIDIA CUDA 10 引入的一项高级特性，它能够将一系列 CUDA 内核定义并封装为一个单一的操作图，而不是逐个启动操作。 这种机制通过一个 CPU 操作启动多个 GPU 操作，从而 减少 GPU 任务的启动开销。 在传统的 GPU 编程中，每当需要让 GPU 执行任务时，CPU 都必须发送指令，并等待 GPU 完成任务后再发送下一条指令。 这种 “逐个发送” 的方式效率较低，因为每个 GPU 操作（例如内核调用或内存复制）所花费的时间以微秒为单位，而提交每个操作给 GPU 也会产生微秒级的开销

== more
https://zhuanlan.zhihu.com/p/693010443

