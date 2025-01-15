= LLM Model
- Encoder
 - self-attention layer (使得模型不仅能够关注这个位置的词，而且能够关注句子中其他位置的词，作为辅助线索，进而可以更好地编码当前位置的词)
 - feed forware neural network
 - 用于进行特征提取和挖掘
- Decoder
 - self-attention layer (只允许关注到输出序列中早于当前位置之前的单词)
 - encoder-decoder attention (cross attention) (帮助解码器聚焦于输入句子的相关部分) (使用前一层的输出来构造 Query 矩阵，而 Key 矩阵和 Value 矩阵来自于编码器最终的输出)
 - feed forware neural network
 - 用于解码，将中间隐状态空间的特征映射到期望的目标空间中

- 纯 Encoder 模型：适用于只需要理解输入语义的任务，例如句子分类、命名实体识别；如BERT
- 纯 Decoder 模型：适用于生成式任务，例如文本生成；如GPT, GPT-2/3
- Encoder-Decoder 模型或 Seq2Seq 模型：适用于需要基于输入的生成式任务，例如翻译、摘要

== self-attention layer
- 输入$x$跟三个权重矩阵($W^K, W^Q, W^V$)乘法，得到三个向量： Query 向量 $Q$，Key 向量$K$，Value 向量$V$
- attention score: 计算当前词对应的 Query 向量和其他位置的每个词的 Key 向量的点积，归一化后做softmax
- attention score跟Value向量点积，将各个计算出来的结果加起来得到（Z矩阵）
=== multi-head
每个输入有多组$W^K, W^Q, W^V$，从而得到多个Z，将Z拼接然后与另一个矩阵做乘法

== feed forware neural network
线性层+激活函数

= llm量化方法
https://zhuanlan.zhihu.com/p/681158646

bfloat16和fp16(half float point)同样内存大小，那么它们可以节约的内存大小应该是一样的吗？他们的优缺点主要有哪些？


= Cuda
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

= vLLM
- iterative-level schedule (continous batching): 以单轮迭代的方式对用户的请求进行处理，即 LLM 生成一个 token 后会重新调度并挑选要下一轮要处理的请求 
 - 即每进行一次token生成或prefill前都进行一次batching，节省了大量的内部碎片，随着Token的生成动态的改变batchsize和序列长度，因此实现了更高的并行度和吞吐量
- pagedAttention: 受操作系统虚拟内存和分页思想启发，将原本连续的 KV cache 存储在不连续的空间，以避免 KV cache 带来的显存浪费
 - KV cache 利用率低下是现有推理系统需将 KV cache 存储在连续的内存空间导致
 - 做法：预先分配一大块显存，并将大块显存划分成较小的块（block），每块可以存放固定数量 token 的 key 和 value 值，为请求的 KV cache 分配空间时按需分配，且无需存储在连续的内存空间。它将大块显存划分成小块并按需分配的做法有效解决了内部碎片和外部碎片，因为每块只存放固定数量（block size，这个值默认是16）的 token，对于每个 request，最多只会浪费 block size-1 个 token 所需的空间。另外，由于它以块的方式存储 KV cache，因此它天然能够以块的粒度实现显存的共享。
- flashAttention: 通过运算分片（矩阵乘法、softmax等）、算子融合实现减少对显存（HBM）的访问

= C++
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
   
