---
title: 控制面和转发面
date: 2023-06-24 20:28:36
tags:
  - Net
categories: Technology
---

#### 通俗理解

1. **控制面**是为了找好路径，**转发面**是在有个好路径的基础上转发数据，两者协作来达到网络是通的这样一个目的。

2. 数据包是以跳为单位进行路由的，转发的决定是由接收到该数据包的路由器决定的。

    **The Control Plane**: 决定怎么和从哪转发出去。

    **The Data Plane:** 在路由器端口上进行实际包转发到线路上（硬件层面）。

#### 官方定义

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230721175913676.png" alt="image-20230721175913676" style="zoom: 80%;" />

1. **控制层面** ：负责路由协议的更新和交互，路由的计算等。

    通过控制和管理各协议的运行使得路由器或交换机能够对整个网络的设备、链路和运行的协议有一个准确的了解，并在网络发生变化时也能及时感知并调整。

2. **转发层面** ：负责IP数据报文的转发。

    转发平面是用来进行数据的接收、解封装、封装、查找路由表进行转发数据。

3. 控制层面和转发层面的分离

    良好的系统设计应该是使控制平面与转发平面尽量分离,互不影响。
    当系统的控制平面暂时出现故障时,转发平面还可以继续工作,这样可以保证网络中原有的业务不受系统故障的影响从而提高整个网络的可靠性。

在计算机网络中，路由器的主要工作就是为经过路由器的每个数据包寻找一条最佳的传输路径，并将该数据有效地传送到目的站点。在每一个路由器设备中，通常都维护了两张比较相似的表，分别为：

- 路由信息表（Routing Information Base），简称为**RIB**表、路由表
- 转发信息表（Forwarding Information Base）, 简称为**FIB**表、转发表

其中，路由表（RIB表）用来决策路由；转发表用来转发分组。

路由器的核心工作便是为经过路由器的每一个数据包找到最佳路径（最快、质量最好、路径最短等指标选择最优），并将到达不同网络的最优路径对应的路由组成一张新的表格，即FIB表。

![image-20230628140016109](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230628140016109.png)

Destination:目的网络地址、Gatewat:网关、Genmask:子网掩码、Metric:跳数、Ref:引用次数、Use：查询次数

在进行报文转发(发送)时：

- 先查询路由表，确定目的地址是否可达，如果可达则确定出接口和下一跳信息
- 再查询ARP表，获取到目的地址对应的Mac地址信息，构建完整的以太网报文。
- 最后查询Mac表，是为了确定报文的发送接口，确定了出接口，内核会将报文发送到对应的网卡驱动上，网卡在合适的时间会将报文发送到下一跳设备上。
