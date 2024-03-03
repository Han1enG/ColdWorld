+++
title = 'Git 基础命令'
date = 2023-05-30T18:55:31+08:00
tags = ["Git"]
categories = "Technology"
+++

### Git 环境搭建

#### 安装 [Git](https://registry.npmmirror.com/binary.html?path=git-for-windows/)

#### 添加 SSH key

1. 创建 `ssh key`

```bash
$ ssh-keygen -t rsa -C "cold@google.com"
```

2. 克隆代码库报错，查看调试信息

```bash
$ ssh -vv -p 29418 [git服务器IP地址]
```

- 验证 publickey 时，本地提供了私钥/home/user/.ssh/id_rsa，但是 no mutual signature algorithm 无互签名算法，尝试 ed25529 等算法但是没有匹配的认证方式。
- 解决办法是提供 ecdsa,ed25519,dsa 等算法的公钥和私钥对。

3. 查看当前 OpenSSH 版本：

```bash
$ ssh -V [git服务器IP地址]
```

![image-20230703171108847](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/image-20230703171108847.png)

> OpenSSH 8.8 考虑到`cryptographically broken`，开始禁用了使用`SHA-1`哈希算法的`RSA`签名算法。
> 这是一个客户端限制，我们必须提供能被`OpenSSH 8.8`认可的密钥类型，比如 `OpenSSH` 推荐的`Ed25519`。

4. 使用 Ed25519 算法

```bash
# 生成ed25519密钥
$ ssh-keygen -t ed25519 -C "your_email@example.com"
# 将私钥添加到身份验证代理
$ ssh-add
```

### Git 拉取远程指定分支到本地 [^1]

1. 将远程指定分支拉取到本地指定分支上：

```bash
$ git pull origin 远程分支名:本地分支名
```

2. 将远程指定分支拉取到本地当前分支上：

```bash
$ git pull origin 远程分支名
```

3. 将与本地当前分支同名的远程分支拉取到本地当前分支上(需先关联远程分支):

```bash
$ git pull
```

4. 将本地分支与远程同名分支相关联

```bash
$ git push -u origin 远程分支名
```

### Git 本地推送到远程指定分支

1. 将本地当前分支推送到远程指定分支上（注意：pull 是远程在前本地在后，push 相反）：

```bash
$ git push origin 本地分支名:远程分支名
```

2. 将本地当前分支推送到与本地当前分支同名的远程分支上

```bash
$ git push origin 本地分支名
```

3.将本地当前分支 推送到 与本地当前分支同名的远程分支上(需先关联远程分支）

```bash
$ git push
```

### Gerrit 提交代码

```bash
$ git commit -m "xxx"
$ git push origin HEAD:refs/for/master
```

> 注意`commit`提交规范

```bash
$ git reset --soft HEAD^   # 撤销最近一次 commit
$ git reset --soft HEAD^2  # 撤销最近两次 commit
$ git log                  # 查看最近提交日志
```

> 修改提交

```bash
$ git commit --amend     # 在上次提交的基础上
$ git push origin HEAD:refs/for/master
```

### git pull 撤销误操作

1. `git reflog` 查看历史变更记录

2. `git reset --hard HEAD@{n}`，（n 是你要回退到的引用位置）回退，如：

   ```bash
   $ git reset --hard 911c4e90
   ```

> `git pull` 后`git reset --soft HEAD^`失败：Cannot do a soft reset in the middle of a merge
>
> ```bash
> $ git reset --merge  # 取消合并
> $ git rebase         # 将当前分支重新设置基线
> ```

### git pull 冲突 (Deprecated)

冲突怕了，现在基本上都是**每次写之前先 pull，写完 push 前也先 pull**

可以参考：[git pull 时冲突的几种解决方式](https://www.cnblogs.com/zjfjava/p/10280247.html)

### git push (Deprecated)

以前没事就 git pull，git push，在没有顺利的按照顺序 merge 就进行这些操作是非常糟糕的，导致经常出现 push 错误，现在的做法是每新增一个业务就新建代码库，直接拷贝 gerrit 上最新的代码，在此基础上进行开发，这样就避免了很多冲突，非必要的情况下不需要经常去拉取最新的代码，特别是目前你在做的有冲突的，在确认 merge 后再小心的拉取到本地。

### Git 修改 Commit Message

1. `git commit --amend`：修改最近一次 commit 的 message；
2. `git rebase -i`：修改某次 commit 的 message。

### Git 合并多次 commit

已经 commit 了一次，还 push 到远程了，修改后又 commit 了一次，且 push 了，过一段时间把第一次的 abandon 了，在合入的时候报错，因为第一次的不见了，第二次是修改和补充的内容，在我本地是没有问题的，同事在合入的时候则会出现问题。

我需要合并这两次提交，可以使用 rebase 命令

```bash
$ git rebase -i HEAD~2
```

修改第二行 **pick** 为 **squash**或者**s**（按提交顺序）这里的编辑器不是 vim，搞得我退不出来，这是 nano 编辑器，直接 control + x, Y 确定, 然后回车确定文件名。

pick：执行这个 commit
squash：这个 commit 会合并到前一个 commit

![在这里插入图片描述](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20200210130958466.png)

注释掉不需要的 commit 描述，我选择的是注释掉旧的，因为我需要基于上一次的 change amend 一下。
保存退出后会有 successful 提示，ammend 后再次 push 就好了。

### git stash

```bash
$ git stash save "message"
$ git stash list            # 查看现有stash
$ git stash pop             # 重新应用缓存的stash，最近的一个,恢复后删除该暂存
$ git stash pop stash@{n}   # 指定恢复某个stash，恢复后删除该暂存
$ git stash apply stash@{n} # 指定恢复某个stash，恢复后保留该暂存

$ git stash drop n          # 移除某个stash
$ git stash clear           # 删除所有缓存的stash

$ git stash show stash@{1}  # 查看某个暂存的差异
```

### git checkout 和 git cherry-pick

获取尚未 merge 的代码到本地，一般有两种选择（不包括直接修改和打补丁 patch)：

```bash
$ git checkout FETCH_HEAD       # 工作目录反射（reflect）了 X
$ git cherry-pick FETCH_HEAD	# X 获取 Y
```

在第一个命令中，只是切换到远程更改，而在最后一个命令中，将远程更改应用到当前分支。

### Inspired by

[^1]: [git 操作](https://blog.csdn.net/u010059669/article/details/82670484)
