---
title: Linux 常用命令
date: 2023-08-16 15:02:32
tags:
  - Linux
categories: Technology
---

## kill

![image-20240219234209813](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20240219234211.png)

```bash
$ kill pid # kill -15 pid 默认的 kill
```

系统会发送一个 SIGTERM 的信号给对应的程序，当程序接收到该 signal 后：

- 程序立刻停止
- 当程序释放相应资源后再停止
- 程序可能仍然继续运行

大部分程序接收到 SIGTERM 信号后，会先释放自己的资源，然后在停止。但是也有程序可以在接受到信号量后，做一些其他的事情，并且这些事情是可以配置的。如果程序正在等待 IO，可能就不会立马做出相应。也就是说，SIGTERM 多半是会被阻塞的、忽略。

`kill -15` 信号只是通知对应的进程要进行"安全、干净的退出"，程序接到信号之后，退出前一般会进行一些"准备工作"，如资源释放、临时文件清理等等，如果准备工作做完了，再进行程序的终止。如果在"准备工作"进行过程中，遇到阻塞或者其他问题导致无法成功，那么应用程序可以选择忽略该终止信号。

```bash
$ kill -9 pid
```

必杀，强制删除。在执行时，应用程序是没有时间进行"准备工作"的，所以这通常会带来一些副作用，数据丢失或者终端无法恢复到正常状态等。

## ps

Linux ps （英文全拼：process status）命令用于显示当前进程的状态，类似于 windows 的任务管理器。.

```bash
$ ps -ef | grep 进程关键字 # 查找指定进程
```

```bash
# ps -ef | grep php
root       794     1  0  2020 ?        00:00:52 php-fpm: master process (/etc/php/7.3/fpm/php-fpm.conf)
www-data   951   794  0  2020 ?        00:24:15 php-fpm: pool www
www-data   953   794  0  2020 ?        00:24:14 php-fpm: pool www
```

有时候则显示如下信息

![image-20240219234331091](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20240219234332.png)

上述查询，查询结果其实 **都是没有** cold 这个进程，但是都显示了 cold 进程的本身，当我们再次查询的时候

![image-20240219234408277](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20240219234409.png)

可以看到进程号一直在变化，正常进程号是不会变的。

解决方法：

1. 在进程名 任何一个字母上添加 [ ]
2. 在进程后面 + `grep -v grep` （-v 参数含义为不包括）

## cat 和 tail 查看日志

```bash
$ tail -f fileName	   # 尾部的内容显示在屏幕上，并且不断实时刷新
$ tail fileName		   # 默认显示最后 10 行
$ tail -n 20 fileName  # 显示最后 20 行
$ tail -n +20 fileName # 从第 20 行至文件末尾
```

```bash
$ cat fileName		# 打印全部日志
```

## mv

```bash
$ mv source_file(文件) dest_file(文件) 			 # 将源文件重命名
$ mv source_file(文件) dest_directory(目录) 	 # 将源文件移动到目标目录中
$ mv source_directory(目录) dest_directory(目录) # 若目标目录存在，移动源目录到其下面，否则对源目录重命名
$ mv source_directory(目录) dest_file(文件) 	 # 出错
```

## drwxr-xr-x 权限

![img](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20180328163937114)

第一个字符是表示文件类型：`- `表示普通文件 `d`表示目录 `l`表示符号链接 `b`表示块设备 (硬件存储设备)

剩下的三个一组，分别表示用户、组用户、其他用户的读、写、执行权限

如 -rwxr-xr-x 或 755 则表示 用户具有读、写和执行权限，而组用户和其他用户仅具有读和执行权限。

## scp 远程拷贝

文件夹需要加 `-r`

1. 从远处复制文件到本地目录，从 10.6.159.147 机器上的 /tmp/soft/ 的目录中下载 demo.tar 文件到本地 /tmp/soft/ 目录中

```bash
$ scp root@10.6.159.147:/tmp/soft/demo.tar /tmp/soft/
```

2. 从远处复制到本地，从 10.6.159.147 机器上的 /tmp/soft/ 中下载 test 目录到本地的 /tmp/soft/ 目录来。

```bash
$ scp -r root@10.6.159.147:/tmp/soft/test /tmp/soft/
```

3. 上传本地文件到远程机器指定目录，复制本地 tmp/soft/ 目录下的文件 demo.tar 到远程机器 10.6.159.147 的 tmp/soft/scptest 目录

```bash
$ scp /tmp/soft/demo.tar root@10.6.159.147:/tmp/soft/scptest
```

4. 上传本地目录到远程机器指定目录，上传本地目录 /tmp/soft/test 到远程机器 10.6.159.147 上/tmp/soft/scptest 的目录中

```bash
$ scp -r /tmp/soft/test root@10.6.159.147:/tmp/soft/scptest
```

## mkdir

```bash
$ mkdir /home/cold				# 创建单个文件夹
$ mkdir /home/cold /home/cold2 # 批量创建文件夹
$ mkdir -p /home/cold/coldFile  # 创建多层文件夹
```

## find

```bash
$ find /（查找范围） -name '查找关键字' -type d # 查找目录
$ find /（查找范围） -name 查找关键字 -print 	 # 查找文件
```

```bash
$ find / -name 'tomcat7' -type d 	# 查找tomcat7文件夹所在的位置
$ find / -name 'server.xml' -print  # 查找server.xml文件的位置
```

## tar

从网络上下载到的源码包， 最常见的是 ` .tar.gz`  包， 还有一部分是 ` .tar.bz2` 包。

- `.tar.gz`     格式解压命令为          `tar   -zxvf   xx.tar.gz`

- `.tar.bz2`   格式解压命令为         ` tar   -jxvf    xx.tar.bz2`

