---
title: ARP协议
date: 2023-06-23 19:05:14
tags:
  - Net
categories: Technology
---

1. ARP（Address Resolution Protocol）即地址解析协议， 用于实现从 IP 地址到 MAC 地址的映射，即询问目标 IP               对应的 MAC 地址。
2. 在网络通信中，主机和主机通信的数据包需要依据OSI模型从上到下进行数据封装，当数据封装完整后，再向外发出。所以在局域网的通信中，不仅需要源目IP地址的封装，也需要源目MAC的封装。
3. 一般情况下，上层应用程序更多关心IP地址而不关心MAC地址，所以需要通过ARP协议来获知目的主机的MAC地址，完成数据封装。

### 一问一答

同一个局域网里面，当`PC1`需要跟`PC2`进行通信时，此时`PC1`是如何处理的？

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjyQzzPWA8AADqjhYvy2c681.png" alt="wKioL1mjyQzzPWA8AADqjhYvy2c681.png" style="zoom: 33%;" />

根据`OSI`数据封装顺序，发送方会自顶向下（从应用层到物理层）封装数据，然后发送出去，这里以`PC1 ping PC2`的过程举例:

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKiom1mjyTaTFTPSAAGeGtry-OU503.png" alt="wKiom1mjyTaTFTPSAAGeGtry-OU503.png" style="zoom: 33%;" />

`PC1`封装数据并且对外发送数据时，上图中出现了`"failed"`，即数据封装失败了，为什么？

当我们令`PC1`去`ping ip2`时，此时`PC1`便有了通信需要的源、目的`IP`地址，但是`PC1`缺少通信需要的目的`MAC`地址。**这就好比我们要寄一个快递，如果在快递单上仅仅写了收件人的姓名（IP），却没有写收件人的地址（MAC），那么这个快递就没法寄出，因为信息不完整**，那么如何获取到`PC2`的`MAC`地址呢？

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKiom1mjyUfTP_VZAAH2B0OmqsU256.png" alt="wKiom1mjyUfTP_VZAAH2B0OmqsU256.png" style="zoom:33%;" />

`PC1`和`PC2`进行了一次`ARP`请求和回复过程，通过交互，`PC1`便具备了`PC2`的`MAC`地址信息。在真正进行通信之前，`PC1`还会将`PC2`的`MAC`信息放入本地的【ARP缓存表】，表里面放置了`IP`和`MAC`地址的映射信息，例如 `IP2<->MAC2`。接下来，`PC1`再次进行数据封装，正式进入`PING`通信，如下:

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKiom1mjyVWjQvbeAAHINNu-eZo561.png" alt="wKiom1mjyVWjQvbeAAHINNu-eZo561.png" style="zoom:33%;" />

> `ARP`缓存表同样具有**时效性**，并且如果设备重启的话，这张表就会**清空**；也就是说，如果下次需要通信，又需要进行`ARP`请求。在我们的`windows/macos`系统下，可以通过命令行`arp -a`查看具体信息。s

### 广播请求单播回应

实际网络中，一个LAN可能有几十上百的主机：

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKiom1mjyX-yuMXeAAHYtV_I9rA078.png" alt="wKiom1mjyX-yuMXeAAHYtV_I9rA078.png" style="zoom:33%;" />

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjyW-RqIfVAAH6rC7kWJM787.png" alt="wKioL1mjyW-RqIfVAAH6rC7kWJM787.png" style="zoom:33%;" />

1. `ARP`协议就需要采用以太网的"广播"功能：将请求包**以广播的形式**发送，交换机或`WiFi`设备（无线路由器）收到广播包时，会将此数据发给同一局域网的其他所有主机。

2. `PC1`发送的请求广播包同时被其他主机收到，然后`PC3`和`PC4`收到之后（发现不是问自己）则丢弃。**而`PC2`收到之后，根据请求包里面的信息（有自己的`IP`地址），判断是给自己的，所以不会做丢弃动作，而是返回`ARP`回应包。**

    <img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjyYXgyhcYAAL1Uhn9Yzc214.png" alt="wKioL1mjyYXgyhcYAAL1Uhn9Yzc214.png" style="zoom:33%;" />

3. `ARP`请求是通过广播方式来实现的，那么，`PC2`返回`ARP`回应包，是否也需要通过广播来实现呢？答案是否定的。**大部分网络协议在设计的时候，都需要保持极度克制，不需要的交互就砍掉，能合并的信息就合并，能不用广播就用单播，以此让带宽变得更多让网络变得更快。**
    `ARP`请求包的完整信息是：我的`IP`地址是`IP1`，`MAC`地址是`MAC1`，请问谁是`PC2`，你的`IP2`对应的`MAC`地址是多少？即**`ARP`请求首先有"自我介绍"，然后才是询问**，因此`PC2`在收到请求之后，就可以将`PC1`的`IP`和`MAC`映射信息存储在本地的【ARP缓存表】，既然知道`PC1`在哪里，就可以返回`ARP`单播回应包。

    <img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjyZzxyHuUAAL8B6-X0vY648.png" alt="wKioL1mjyZzxyHuUAAL8B6-X0vY648.png" style="zoom:33%;" />

### ARP 数据包

#### ARP 请求包

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjybXBzN7XAASAgIFsB_0048.png" alt="wKioL1mjybXBzN7XAASAgIFsB_0048.png" style="zoom:33%;" />

#### ARP 响应包

<img src="https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/wKioL1mjycTRmvOEAAQLf48DXPo677.png" alt="wKioL1mjycTRmvOEAAQLf48DXPo677.png" style="zoom:33%;" />

#### ARP 协议字段解读

![image-20230721153654604](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230721153654604.png)

> 从功能来看，`ARP`协议的功能最终是获取到`MAC`信息，服务于链路层，`ARP`是链路层协议；
>
> 从层次来看，`ARP`协议和`IP`协议都基于`Ethernet`协议，它们在`Ethernet`协议里面有独立的`Type`类型，前者是`0x0806`，后者是`0x0800`，`ARP`是网络层。

ARP是解决**同一个局域网**上的主机或路由器的IP地址和硬件地址的映射问题，如果所要找的目标设备和源主机不在同一个局域网上。

<1> 此时主机 A 就无法解析出主机 B 的硬件地址（实际上主机 A 也不需要知道远程主机 B 的硬件地址）;

<2> 此时主机A需要的是将路由器R1的IP地址解析出来，然后将该IP数据报发送给路由器R1.

<3> R1从路由表中找出下一跳路由器R2，同时使用ARP解析出R2的硬件地址。于是IP数据报按照路由器R2的硬件地址转发到路由器R2。

<4> 路由器R2在转发这个IP数据报时用类似方法解析出目的主机B的硬件地址，使IP数据报最终交付给主机B.

![topo](https://liushy.com/imgs/topo.png)

1. 最初h2会通过将自己和h3的ip地址同子网掩码与运算得知：自己和h3在同一网段，可直接通信；
    2.h2对数据包二层封装时，发现自己并不知道h3的mac地址，于是发送ARP广播包；
    3.switch收到arp广播包后，由于没有流表，于是它向控制器发送packet_in消息；
    4.控制器收到packet_in后，向switch发送packet_out,并下发流表给switch让它将数据包从除2端口以外的其他所有端口发送；
    5.h3收到arp数据包后，在数据包里添加上自己的mac地址；
    6.switch收到h3的arp包，由于没有流表项，于是向控制器发送packet_in消息；
    7.控制器学习到h3的mac和ip地址，向switch发送packet_out消息并下发h3到h2的流表项；
    8.h2知道了h3的mac地址，完成icmp包的封装，就向h3发包了；
    9.由于switch没有h2->h3的流表项，所以它还是会向控制器发送packet_in；
    10.控制器发送packet_out给switch并下发h2->h3的流表；至此h2和h3就能不通过控制器只通过switch直接通信啦！

### 合法性检查

无效情况: 源 `ip` 地址为全 0 或为广播、组播；源 `Mac` 地址为全 0 或为组播地址。

### 组播Mac地址判断

以太网定义的48位`MAC`地址中，第一个字节的最低位为`'1'`代表组播`MAC`地址。

```go
if (mac[0] & 0x01) == 0x1 {
		return true
}
```
