+++
title = 'OpenVSwitch'
date = 2023-07-17T21:53:08+08:00
tags = ["Net"]
categories = "Technology"
katex = false
+++

### OVS 网络架构

Open vswitch 是一个开放的虚拟交换机，支持 openflow 协议，被远端的控制器通过 openflow 协议统一管理，从而实现对接入的虚拟机或设备进行组网和互通，主要作用就是:

1. 传递虚拟机之间的流量
2. 实现虚拟机和外界网络之间的通信

![整体组网结构](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907141824441.png)

#### OVS 内部结构

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/OVS网络架构2.png" alt="OVS网络架构2" style="zoom:67%;" />

OVS 有三个核心的部分:

1. ovs-vswitchd: 实现 OVS 守护进程 daemon，OVS 的核心部件，实现交换功能，和 Linux 内核兼容模块一起，实现基于流的交换（flow-based switching）。它和上层 controller 通信遵从 OPENFLOW 协议，它与 ovsdb-server 通信使用 OVSDB 协议，它和内核模块通过 netlink 通信，它支持多个独立的 datapath（网桥），它通过更改 flow table 实现了绑定和 VLAN 等功能。
2. ovsdb-server: 轻量级的数据库服务，主要保存了整个 OVS 的配置信息，包括 port、交换内容、VLAN 等。ovs-vswitchd 会根据数据库中的配置信息工作。它于 manager 和 ovs-vswitchd 交换信息使用了 OVSDB(JSON-RPC) 的方式。
3. ovs kernal module(datapath + flowtable): 内核模块，负责执行数据处理，把从接收端口收到的数据包在流表中进行匹配，并执行匹配到的动作。处理包交换和隧道，缓存 flow，如果在内核的缓存中找到转发规则则转发，否则发向用户空间去处理。一个 datapath 可以对应多个 vport，一个 vport 类似物理交换机的端口概念。每一个 ovs 网桥（交换机）都有一个内核空间的 datapath 与之相对应，可以说这个 datapath 就是 ovs 网桥（交换机）的实体，数据流都是受它控制，而它是根据 flow table 。每一个 datapth 在内核中都关联一个 flow table，一个 flow table 包含多个条目，每个条目包括两个内容：一个 match/key 和一个 action。

为了方便配置和管理，所以有了下面的工具:

- ovs-dpctl: 用来配置交换机内核模块，可以控制转发规则。
- ovs-vsctl: 用来查询或更新 ovs-vswitchd 的配置信息，操作对象是 ovsdb-server ，查询和更新 ovsdb-server 中的数据库。更新数据库的时候，命令会等待配置在 ovs-vswitchd 生效后才返回。
- ovs-appctl: 主要是向 OVS 守护进程发送命令的，一般用不上。ovs-appctl ofproto/trace 可以用来生成测试用的模拟数据包，并一步步的展示 OVS 对数据包的流处理过程。
- ovsdbmonitor: GUI 工具来显示 ovsdb-server 中数据信息。
- ovs-controller: 一个简单的 OpenFlow 控制器。
- ovs-ofctl: 用来查询和控制 OVS 作为 OpenFlow 交换机工作时候的流表内容。

通过架构可以看到，**用户空间**运行了两个进程: ovs-vswitchd 和 ovsdb-server 。 简单来说，ovsdb-server 将 ovs-vswitchd 的配置持久化到 db 中，一般路径是在 /etc/openvswitch/conf.db 中。ovs-vswitchd 是一个守护进程，它会向 ovsdb-server 读取相关配置信息，并且如果有配置需要更新也会将其同步到 ovsdb-server 中。他们之间的通信是通过 Unix 域套接字进行的。**内核空间**主要就是 datapath 和 flow table。用户空间和内核空间的交互是通过 Netlink 协议实现的。

![image-20230907150437980](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907150437980.png)
查看加载到内核的模块

![image-20230907151357139](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907151357139.png)
查看进程可以看到:
**ovs-vswitchd** 运行的命令为 `ovs-vswitchd unix:/datadisk0/var/run/openvswitch/db.sock`，指定了与 **ovsdb-server** 通信的 Unix 域套接字路径，监听了一个本机的 db.sock 文件。还指定 VLOG 中的三个场合的日志级别使用 mlockall 选项，用于将内存锁定在物理内存中，以及指定日志文件路径、PID 文件路径。
**ovsdb-server** 运行的命令为`ovsdb-server /sysdisk0/3rdparty/etc/openvswitch/conf.db`，指定了配置文件路径，将配置信息保存在 conf.db 中。remote 参数指定了和数据库 **ovsdb-server** 的连接方法，这里是 punix: /db.sock 表示监听的 Unix 域套接字路径，使用 db.sock 进行进程间 socket 的通信，收发数据，也就是 **ovs-vswitchd** 通过这个 db.sock 从这个进程读取配置信息。还用了一些选项，如日志文件路径、PID 文件路径、以及一些证书和密钥等。

**conf.db** 是 json 格式的，可以 cat 出来使用 json 工具解析或者使用 ovsdb-client dump 命令将数据库结构打印出来。

![image-20230907160656841](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907160656841.png)

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/635909-20160907114625238-1863348603.png" alt="数据库结构" style="zoom: 67%;" />

通过 ovs-vsctl 创建的所有的网桥，网卡，都保存在数据库里面，ovs-vswitchd 会根据数据库里面的配置创建真正的网桥，网卡。

#### 数据流向

![数据流向](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907164454232.png)

![ovs包处理流程](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/ovs-arch.png)

一般的数据包在 Linux 网络协议中的流向为上图中的蓝色箭头流向: 网卡 eth0 收到数据包后判断报文走向，如果是本地报文把数据传送到用户态，如果是转发报文根据选路 （二层交换或三层路由）把报文送到另一个网卡如 eth1。
当有 OVS 时，首先是创建一个网桥: ovs-vsctl add-br br0; 然后绑定某个网卡: ovs-vsctl add-port br0 eth0; 这里默认为绑定了 eth0 网卡。数据流向如红色所 示:

1. 从网卡 eth0 收到报文后然后到 OVS 的端口 Vport 上进入 OVS 中。
2. flow table 在内核中有一份，当从物理网卡收到包后根据 key 值进行流表匹配，如果匹配成功执行对应的 action。
3. 如果匹配失败，通过 upcall 调用，将数据包以 Netlink 协议上传到用户态，通过 ovs-vswitchd 查询 ovsdb 进行查表匹配。
4. 如果还是不能匹配，则通过 OpenFlow 协议域控制器通信，控制器下发流表项，ovs-vswitchd 解析流表项得到相应的动作，同时将流表存到 ovsdb 中。
5. 若能匹配上，将匹配的流表项通过 Netlink 下发到内核中的 flow table 中。
6. 通过 reinject，使用 Netlink 将数据包重新送回内核
7. 内核匹配流表项并执行相应的动作。

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/635909-20160907114619848-1715526737.png" alt="OVS网络架构1" style="zoom: 67%;" />

在工作中一般在这几个地方来修改内核代码以达到自己的目的:
第一个是在 datapath.c 中的 ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb) 函数内添加相应的代码来达到自己的目的，这里是每个数据包的必经之地;
第二个就是自定义的流表，可以根据流表来设计自己的 action，完成自己想要的功能。

#### 补充网络概念

1. Bridge: 虚拟网络设备，是一个以太网交换机（Switch），一个虚拟主机中可以创建一个或多个 Bridge 设备。在 Openvswitch 中每个虚拟交换机（vswitch）都可以认为是一个网桥，因为 Openvswitch 在底层的通信是借助了网桥模块来实现的。

   ![image-20230907170259377](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230907170259377.png)

2. datapath: 在 OVS 中，datapath 负责执行数据交换，也就是把从接收端口收到的数据包在流表中进行匹配，并执行匹配到的动作。datapath 也可以说是交换机、网桥。如下图，每个 datapath 项中我们都能看到存在几个 Port 项，它们其实就是虚拟交换机（datapath) 上的端口。datapath 类型分为 netdev 和 system.
   使用 ovs-vsctl show 可以看到详细信息，br-int 下的端口 tunnel_10_3_9_133_10_3_9_128 就与远端的端口建立了 vxlan 隧道。
   ![image-20230908110903676](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230908110903676.png)

3. Port: 端口与物理交换机的端口概念类似，每个 Port 都隶属于一个 Bridge（datapath)。

   ![bridge下的port](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230908101921215.png)

4. Interface: 连接到 Port 的网络接口设备。在通常情况下，Port 和 Interface 是一对一的关系, 只有在配置 Port 为 bond 模式后，Port 和 Interface 是一对多的关系。

5. Controller: OpenFlow 控制器。OVS 可以同时接受一个或者多个 OpenFlow 控制器的管理。

6. Flow table: 每个 datapath 都和一个“flow table”关联，当 datapath 接收到数据之后， OVS 会在 flow table 中查找可以匹配的 flow，执行对应的操作, 例如转发数据到另外的端口。支持 OpenFlow 协议的交换机应该包括一个或者多个流表，流表中的条目包含：数据包头的信息、匹配成功后要执行的指令和统计信息。

7. Flow : 在 OpenFlow 的白皮书中，Flow 被定义为某个特定的网络流量。例如，一个 TCP 连接就是一个 Flow，或者从某个 IP 地址发出来的数据包，都可以被认为是一个 Flow。

8. **[patch](http://arthurchiao.art/blog/ovs-deep-dive-4-patch-port/)**: OVS 里的不同 bridge 之间可以通过 patch port 进行连接，类似于 linux 的 veth 接口。patch 端口只存在网桥上，datapath 中不会存在；如果出端口为 patch 端口，则相当于其 peer 设备收到报文，在 peer 设备所在网桥查找 openflow 流表进行转发；不同类型 datapath 的网桥不能通过 patch 端口相连接。

9. Tun/Tap: TUN/TAP 设备是 Linux 内核中实现的虚拟网卡。物理网卡是从物理线路上收发数据包，而 TUN/TAP 设备是从用户态应用程序上收发以太网帧或 IP 包。TAP 等同于以太网设备，操作 L2 数据链路层的数据帧; TUN 则是模拟 L3 网络层的设备，操作网络层的 IP 数据包。

### VLOG

OVS 的两个进程 ovsdb-server 和 ovs-vswitchd 都使用了内置的 Vlog 来控制各自的 log 内容，合理的设置 log 模块和 log 等级方便定位问题或者学习。

我没有像大家一样在咱们公司扎根时间那么长，现在也只知道公司是搞通信方面的，我有疑问也希望理解，

Open vSwitch 具有一个内建的日志机制 VLOG。VLOG 工具允许你在各种网络交换组件中启用并自定义日志，由 VLOG 生成的日志信息可以被发送到一个控制台、syslog 以及一个便于查看的单独日志文件。可以通过 ovs-appctl 的命令行工具在运行时动态配置 OVS 日志。

设备上的 OVS 日志存放在 /datadisk0/var/log/openvswitch 路径下。

可以使用 ovs-appctl 查看或者修改目标进程的 log，默认的目标是 ovs-vswitchd，可以通过参数 -t 指定具体目标，

```bash
$ ovs-appctl vlog/list # 等价于 ovs-appctl -t ovs-vswitchd vlog/list
$ ovs-appctl -t ovsdb-server vlog/list
```

```bash
$ ovs-appctl vlog/list
                 console    syslog    file
                 -------    ------    ------
backtrace          OFF        ERR        ERR
bfd                OFF        ERR        ERR
bond               OFF        ERR        ERR
bridge             OFF        ERR        ERR
bundle             OFF        ERR        ERR
bundles            OFF        ERR        ERR
cfm                OFF        ERR        ERR
collectors         OFF        ERR        ERR
command_line       OFF        ERR        ERR
connmgr            OFF        ERR        ERR
conntrack          OFF        ERR        ERR
conntrack_tp       OFF        ERR        ERR
coverage           OFF        ERR        ERR
ct_dpif            OFF        ERR        ERR
daemon             OFF        ERR        ERR
daemon_unix        OFF        ERR        ERR
dpdk               OFF        ERR        ERR
...
```

输出结果显示了用于三个场合（facility：console，syslog，file）的各个模块的调试级别。自定义 VLOG 的语法如下：

```bash
$ ovs-appctl vlog/setmodule[:facility[:level]]
```

其中的 module 即模块名称（如 backtrace、bfd、dpdk 等），facility 即日志信息的目的地（必须是：console、syslog、或者 file），level 即日志的详细程度（必须是 emer、err、warn、info、或者 dbg ）

```bash
$ sudo ovs-appctl vlog/set dpdk:console:dbg # 修改 dpdk 模块的 console 的日志级别为 DBG
$ sudo ovs-appctl vlog/set ANY:console:dbg  # 修改每个模块的console的日志级别为DBG
$ sudo ovs-appctl vlog/set ANY:any:dbg 		# 修改每个模块的每个场合的日志级别为DBG
```

dpdk 模块的 console 工具已经将其日志等级修改为 DBG，而其它两个场合 syslog 和 file 的日志级别仍然没有改变。

![image-20230906160939722](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230906160939722.png)
