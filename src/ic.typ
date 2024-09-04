= IC
== 体系结构

- 数据冒险：当指令在流水线中重叠执行时，后面的指令需要用到前面的指令的执行结果，而前面的指令尚未写回导致的冲突，称为数据冒险（也称为数据相关性）。
- 结构冒险：当一条指令需要的硬件部件还在为之前的指令工作，而无法为这条指令提供服务，那就导致了结构冒险。（这里结构是指硬件当中的某个部件、也称为资源冲突）。
- 控制冒险：如果现在想要执行哪条指令，是由之前指令的运行结果决定，而现在那条之前指令的结果还没产生，就导致了控制冒险（实际上就是riscv 的跳转指令引起的，跳转指令要经过2个周期后才会出现跳转结果）。

== 电容，电感和电阻
- 电容通高频阻低频、电感通低频阻高频

== 布尔代数
=== 二进制转换
- 除k取余法（第一个余数为低位）
- 乘k取整法（第一个整数为高位）

=== 原码，反码，补码
- 正数的原码，反码和补码都一样
- 负数的反码除符号位都取反，补码为反码+1

=== 十进制编码
- 8421码：正常二进制数值
- 余3码：从3开始计数
- 余3循环码：从3开始计数，每次改变一位
#table(
  columns: 5,
  [], [00], [01], [11], [10],
  [00], [0000], [0001], [0011], [*0010*],
  [01], [*0100*], [*0101*], [*0111*], [*0110*],
  [11], [*1100*], [*1101*], [*1111*], [*1110*],
  [10], [1000], [1001], [1011], [*1010*],
)
- 格雷码：从0开始计数，每次改变一位

=== 逻辑运算
- Y = (AB)' = A' + B'
- Y = A xor B = AB' + A'B
- A + BC = (A+B)(A+C)
- 最小项：m1 = 001 = A'B'C, m3 = ABC'
- 卡诺图化简：画圈; 若包含无关项，可当作1处理

== 基本电路
=== 单bit加法器
- 半加器：S = A xor B, CO = AB
- 全加器：S = A xor B xor CI, CO = (A xor B)CI + AB

=== 竞争冒险
- 竞争：在组合逻辑电路中，当某一个变量经过两条以上路径到达输出端时，由于每条路径上的延迟时间的不同，到达终点的时间有先后，这一现象称为竞争。（输入级）
- 冒险：由于竞争使电路的输出端出现了稳态下没有的干扰脉冲（毛刺）的现象称为冒险。（输出级）
- 可通过判断输出端表达式会不会出现一个变量的原状态和非状态来判断。
- 消除竞争冒险：
  -- 接入滤波电容
  -- 引入选通脉冲
  -- 修改逻辑设计，增加冗余项

=== 锁存器与触发器
==== SR锁存器
- 由两个或非门或者与非门反馈连接的电路。 Q=R'Q, Q'=S'Q'
- 输入S和R，输出Q和Q‘
- 也可由两个与非门组成。
- 其输出不仅与输入有关，也与Q’有关，需要根据当前状态来判断

=== D锁存器
- SR锁存器的R改成D‘，S改成D

=== 触发器
==== SR触发器
- $Q^(n+1)$ = $S$ + $R' Q^n$ (约束条件：SR=0)

==== JK触发器
- $Q^(n+1)$ = $J Q^n '$ + $K' Q^n$
- 保持，复位，置位，切换四种状态

==== D触发器
- 将两个D锁存器级联，两个锁存器使能信号相反

==== T触发器
- $Q^(n+1)$ = $T Q^n '$ + $T' Q^n$


=== 建立时间和保持时间
- 建立时间：数据需要在时钟到达前保持稳定的最短时间
- 保持时间：数据在时钟到达后需要保持稳定的最短时间
- 建立时间+ 保持时间=时钟周期


== IC协议
=== AXI总线
- 5个传输通道：读地址、读数据、写地址、写数据、写响应
- 最多256个数据传输的突发事务，AXI4-Lite只允许每个事务并行一个数据传输
- full, lite, stream三种传输方式
- lite不支持突发传输
- stream是非存储映射，数据传输时不需要地址；定义传输流数据的单一通道，可以无限制长度突发传输

==== 突发传输
===== 类型
FIXED: 地址固定(FIFO)
INCR: 地址递增(Memory)
WRAP：地址递增，回环(Cache line)

===== 突发读传输
信号
- 读地址相关信号：ARVALID, ARADDR, ARLEN(突发传输次数), ...
- 读数据相关信号：RDATA, RREADY, RVALID, ...

传输过程
- 当ARVILID和ARREADY都为高，地址被传递给从接口。
- 当RVALID和RREADY都为高，数据被传递给从接口。
- RLAST为高，表示最后一个数据。
- 当从接口接收了第一个地址后，master接口可以发送另一个突发地址。使得当第一个突发读结束后，紧跟着第二个突发读。

===== 突发写传输
- 写地址相关信号：AWADDR, AWVALID, AWREADY, ...
- 写数据相关信号：WDATA, WLAST, WVALID, WREADY, ...
- 写响应相关信号：BRESP, BVALID, BREADY, ...
当从机接受了所有的数据后，它会向主机发送一个写响应以表明事务已经完成。

事务顺序:
无序，每个事务用ID标记，相同ID的交易按顺序，不同的无序。

通道握手机制:
只有VALID和READY同时有效时，才会发生传输

==== outstanding传输
- 不需要等待前一笔传输完成就可以发送下一笔的操作。即，有缓存存在。
- burst传输可以提高单笔传输的效率，而outstanding传输可以提高多笔传输的效率。

===== outstanding相关计算
- master最大缓存能力 = outstanding \* (burst length + 1) \* 带宽
- 访问延时 = master最大缓存能力 / 有效带宽(最大传输带宽)

==== 乱序传输
不同ID之间的数据不必按顺序传输。

==== 交织传输
在乱序的基础上支持不同ID间数据的乱序。
可以是一次传输中先后出现不同ID的数据。

==== 非对齐传输
一个笔数据非对齐，后面的仍然保持对齐。


=== APB总线
- 最大支持32bit的数据位宽
- 有两个独立的数据通道：读通道和写通道，但不会被同时使用
- 相关信号：PCLK, PRESETn, PADDR, PSELx, PWDATA, PRDATA, PREADY, PSTRB, PENABLE, PSLVERR, ...
- 状态：IDLE, SETUP, ENABLE, DATA VALID, FINISH
- 读：PSEL, PENABLE, PREADY
- 写：PWRITE, PSEL, PENABLE, PREADY
- APB的地址和读写控制信号在下一次数据传输前，不会发生改变


=== I2C总线
- 串行、半双工、多主机总线
- 近距离、低速
- 两根双向信号线：数据线SDA和时钟线SCL（用于通信双方时钟的同步）
- 每个连接到I2C总线上的期间都有一个唯一的7bit地址
- I2C总线上可挂接的设备数量受总线的最大电容400pF限制
- 串行的8bit双向数据传输速率：标准模式 100 Kbit/s， 快速模式 400 Kbit/s，高速模式3.4 Mbit/s

==== 通信过程
1. 主机发送起始信号启用总线
2. 主机发送一个字节数据指明从机地址和后续字节的传送方向
3. 被寻址的从机发送应答信号回应主机
4. 发送器发送一个字节数据
5. 接收器发送应答信号回应发送器
6. 循环步骤4、5
7. 通信完成后主机发送停止信号释放总线
- 第4步和第5步用的是发送器和接收器，不是主机和从机，这是由第一个字节的最后一位决定主给从发，还是从给主发。
- 数据发送过程中不允许改变发送方向
- 第一个字节的前7位是从机地址
- 起始信号：SCL为高电平时，SDA由高变低
- 停止信号：SCL为高电平时，SDA由低变高
- I2C总线每次传送一个字节时，先传送最高位，再传送低位，发送器发送完一个字节数据后接收器必须发送1 bit的应答位回应发送器。
- SCL为低电平期间发送器向数据线上发送一位数据，此时数据线上的信号可变化；SCL为高电平期间接收器从数据线上读取一位数据，此时数据线上的信号需要保持稳定。

==== 时钟同步
I2C总线上SCL之间存在线与，只有多个主机同时发送高电平时，SCL才是高电平，否则为低电平。

==== 仲裁
- 只发生在SCL为高电平时
总线仲裁：只有当所有主机在SDA上都写高电平时，SDA的数据才是1，否则为0
- 一个主机每发送一位数据，在SCL为高电平时，就检查SDA的电平是否和发送的数据一致，如果不一致，这个主机就输掉了仲裁。输了的主机在检测到自己输了之后就不再产生时钟脉冲信号，并且要在总线空闲时才能重新传输。


=== SPI协议
- 一个主机，多个从机，全双工(具有单独的发送和接收线路)
- SCLK, MOSI, MOSO, NSS（片选信号）
- 优点：高速传输速率，简单的软件配置，灵活的数据传输
- 缺点：没有从机应答信号，需要更多的引脚
- 多个从机时，可以给主机配置多个NSS信号

==== 传输过程
- 主机将NSS拉低，开始接收数据
- 接受端检测到时钟边沿信号后，立即读取数据线上的信号
- 主机发送到从机时：主机产生相应的时钟信号，然后将数据逐位从MOSI信号线上发送到从机
- 主机接收从机数据；从机从MISO信号发送数据给主机

==== 时钟极性和相位
- 时钟极性CKP：CKP=0，时钟IDLE为低电平；CKP=1，时钟IDLE为高电平
- 时钟相位CKE：CKE=0，时钟SCK的第一个跳变沿采样；CKE=1，时钟SCK的第二个跳变沿采样


=== UART协议
- 异步、串行、全双工
- RX, TX

==== 传输过程
- 总线空闲时为高电平
- 起始位：发送方发送一个低电平信号VOL
- 数据位：可以是5到9位等组成一个字符，通常是8位。先发送最低位，再发送高位。
- 奇偶校验位：1的个数和0的个数，有不同校验方式
- 停止位：1或2位的VOH，表示传输的结束，并且可以提供纠正时钟的机会，停止位越多，数据传输越稳定、越慢

== UART, I2C, SPI对比
#table(
  align: center,
  columns: (auto, auto, auto, auto, auto, auto),
  [协议], [复杂度], [传输速度], [设备数量], [复式], [主从数量],
  [UART], [简单的], [最慢], [最多 2 台设备], [全双工], [单对单],
  [I2C], [轻松链接多个设备], [比 UART 更快], [最多 127 个, 但变得复杂], [半双工], [多个从机和主机],
  [SPI], [随着设备的增加而复杂], [最快的], [很多，但变得复杂], [全双工], [1个主机，多个从机],
)
