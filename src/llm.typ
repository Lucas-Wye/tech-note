= LLM Model
- Encoder
 - self-attention layer (使得模型不仅能够关注这个位置的词，而且能够关注句子中其他位置的词，作为辅助线索，进而可以更好地编码当前位置的词)
 - feed forware neural network
- Decoder
 - self-attention layer (只允许关注到输出序列中早于当前位置之前的单词)
 - encoder-decoder attention (帮助解码器聚焦于输入句子的相关部分) (使用前一层的输出来构造 Query 矩阵，而 Key 矩阵和 Value 矩阵来自于编码器最终的输出)
 - feed forware neural network


== self-attention layer
- 输入跟三个权重矩阵($W^K, W^Q, W^V$)乘法，得到三个向量： Query 向量，Key 向量，Value 向量
- attention score: 计算当前词对应的 Query 向量和其他位置的每个词的 Key 向量的点积，归一化后做softmax
- attention score跟Value向量点积，将各个计算出来的结果加起来得到（Z矩阵）
=== multi-head
每个输入有多组$W^K, W^Q, W^V$，从而得到多个Z，将Z拼接然后与另一个矩阵做乘法


== feed forware neural network
线性层+激活函数

