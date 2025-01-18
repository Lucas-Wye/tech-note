= LLM Model
- Encoder
  - self-attention layer (使得模型不仅能够关注这个位置的词，而且能够关注句子中其他位置的词，作为辅助线索，进而可以更好地编码当前位置的词)
  - feed forward neural network
  - 用于进行特征提取和挖掘
- Decoder
  - self-attention layer (只允许关注到输出序列中早于当前位置之前的单词)
  - encoder-decoder attention (cross attention) (帮助解码器聚焦于输入句子的相关部分) (使用前一层的输出来构造 Query 矩阵，而 Key 矩阵和 Value 矩阵来自于编码器最终的输出)
  - feed forward neural network
  - 用于解码，将中间隐状态空间的特征映射到期望的目标空间中

- 纯 Encoder 模型：适用于只需要理解输入语义的任务，例如句子分类、命名实体识别；如BERT
- 纯 Decoder 模型：适用于生成式任务，例如文本生成；如GPT, GPT-2/3
- Encoder-Decoder 模型或 Seq2Seq 模型：适用于需要基于输入的生成式任务，例如翻译、摘要

== self-attention layer
- 输入$x$跟三个权重矩阵($W^K, W^Q, W^V$)乘法，得到三个向量： Query 向量 $Q$，Key 向量$K$，Value 向量$V$
- attention score: 计算当前词对应的 Query 向量和其他位置的每个词的 Key 向量的点积，归一化后做softmax
- attention score跟Value向量点积，将各个计算出来的结果加起来得到（Z矩阵）
- Attention$(K, Q, V) = $softmax$((Q K^T)/sqrt(d_k)) dot.op V$

=== multi-head (MHA)
- 模型在对当前位置的信息进行编码时，会过度的将注意力集中于自身的位置，而可能忽略了其它位置
- 每个输入有多组$W^K, W^Q, W^V$，从而得到多个Z，将Z拼接然后与另一个矩阵做乘法

=== multi-query attention (MQA)
所有head共享同一个K和V

=== grouped-query attention (GQA)
多个head共享K和V

== feed forware neural network
线性层+激活函数

== llm量化方法
- 逐层量化(per-tensor)：以一层网络为量化单位，每层网络一组量化参数
- 逐通道量化(per-channel)：可以获得更高的量化精度，但计算更复杂
- 逐组量化(per-group)

量化分类:
- 量化感知训练：训练过程中加入伪量子算子，在训练时统计输入和输出的数据范围
- 量子感知微调：在微调过程中对模型进行量化
- 训练后量化
  - 仅权重量化：可以压缩模型的大小，而在推理时将权重反量化为fp32数据，推理性能基本无提升
  - 权重+激活：在模型推理时执行量化算子来加快模型推理速度；为了量化激活值，需要用户提供一定数量的校准数据集用于统计每一层激活值的分布，从而对量化后的算子做校准。

- FP32浮点数：1(符号)，8(指数)，23(尾数) num = $M dot.op 2^E$
- FP16浮点数：1(符号)，5(指数)，10(尾数)
- BF16: 1(符号)，8(指数)， 7(尾数) (精度更低) 深度学习模型通常对数值范围更敏感，而对精度的要求可以相对较低


== vLLM
- iterative-level schedule (continous batching): 以单轮迭代的方式对用户的请求进行处理，即 LLM 生成一个 token 后会重新调度并挑选要下一轮要处理的请求
  - 即每进行一次token生成或prefill前都进行一次batching，节省了大量的内部碎片，随着Token的生成动态的改变batchsize和序列长度，因此实现了更高的并行度和吞吐量
- pagedAttention: 受操作系统虚拟内存和分页思想启发，将原本连续的 KV cache 存储在不连续的空间，以避免 KV cache 带来的显存浪费
  - KV cache 利用率低下是现有推理系统需将 KV cache 存储在连续的内存空间导致
  - 做法：预先分配一大块显存，并将大块显存划分成较小的块（block），每块可以存放固定数量 token 的 key 和 value 值，为请求的 KV cache 分配空间时按需分配，且无需存储在连续的内存空间。它将大块显存划分成小块并按需分配的做法有效解决了内部碎片和外部碎片，因为每块只存放固定数量（block size，这个值默认是16）的 token，对于每个 request，最多只会浪费 block size-1 个 token 所需的空间。另外，由于它以块的方式存储 KV cache，因此它天然能够以块的粒度实现显存的共享。
- flashAttention: 通过运算分片（矩阵乘法、softmax等）、算子融合实现减少对显存（HBM）的访问

