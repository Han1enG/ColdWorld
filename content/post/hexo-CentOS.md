---
title: Hexo 部署到服务器
date: 2023-03-19 11:29:44
tags:
  - Hexo
  - Linux
categories: Blog
---
> `GitHub Pages` 实在太慢了，科学上网有时候也卡住。

## 搭建Git服务器

首先使用 `Xshell`连接服务器，并切换 `root`用户，回退到根路径

1. 安装 `openssh`

   ```shell
   sudo apt-get install openssh-server # Ubuntu
   sudo yum install openssh-server # Centos
   ```
2. 安装完成之后，查看 `ssh`服务是否启动

   ```shell
   ps -e|grep ssh
   ```

   ![image-20230319115141985](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230319115148.png)
3. 创建一个名为 `git`的用户，用于管理 `Hexo`项目

   ```shell
   adduser git
   ```

   ![image-20230320203202602](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230320203205.png)
4. 给 `git`用户添加文件的写权限

   ```shell
   chmod 740 /etc/sudoers
   vim /etc/sudoers
   ```

   找到 `User privilege specification`部分，添加如下内容：

   ```shell
   git    ALL=(ALL:ALL) ALL
   ```

   ![image-20230320203415465](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230320203419.png)
5. 按 `ESC` 退出编辑模式，输入 `:wq`保存退出
6. 将写权限收回

   ```shell
   chmod 400 /etc/sudoers
   ```
7. 切换至 `git`用户，创建 `~/.ssh`文件夹和 ` ~/.ssh/authorized_keys`文件，并赋予相应的权限

   ```shell
   su git
   mkdir ~/.ssh
   vim ~/.ssh/authorized_keys
   ```

   按 `i`进入编辑模式，将我们先前生成的 `id_rsa.pub`文件中的公钥复制到 `authorized_keys`中，按 `ESC` 退出编辑模式，输入 `:wq`保存退出。
8. 赋予权限

   ```shell
   chmod 600 /home/git/.ssh/authorized_keys
   chmod 700 /home/git/.ssh
   ```
9. 在电脑本地桌面，右键 `Git Bash Here`，输入一下命令，其中 `SERVER`填写自己的云主机 `ip`，如果能够免密登录即代表成功。

   ```shell
   ssh -v git@SERVER
   ```

   ![image-20230326094751020](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230326094753.png)
10. 安装 `git`，有的话就不需要再安装

    ```shell
    # 安装 Git
    sudo yum -y install git
    # 查看版本
    git version
    ```
11. 在 `var`目录下创建 `repo`作为 `Git`仓库目录，并赋予权限，先切换到 `root`账户，然后输入：

    ```shell
    mkdir /var/repo
    chown -R git:git /var/repo
    chmod -R 755 /var/repo
    ```

    创建 `hexo`目录作为网站根目录，并赋予权限

    ```shell
    mkdir /var/hexo
    chown -R git:git /var/hexo
    chmod -R 755 /var/hexo
    ```

    创建一个空白的 `git`仓库

    ```shell
    cd /var/repo
    git init --bare hexo.git
    ```

    在 `/var/repo/hexo.git`下，有一个自动生成的 hooks 文件夹，我们需要在里面新建一个新的钩子文件 `post-receive`，用于自动部署

    ```shell
    vim /var/repo/hexo.git/hooks/post-receive
    ```

    进入编辑模式，输入以下内容：

    ```shell
    #!/bin/bash
    git --work-tree=/var/hexo --git-dir=/var/repo/hexo.git checkout -f
    ```

    写入后添加可执行权限

    ```shell
    chown -R git:git /var/repo/hexo.git/hooks/post-receive
    chmod +x /var/repo/hexo.git/hooks/post-receive
    ```

## 配置Nginx托管文件目录

1. 安装Nginx

   ```shell
   sudo yum install nginx -y
   ```

   ![image-20230319143057171](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230319143059.png)

   安装成功后，在浏览器中输入服务器的ip地址，即可访问到Nginx的默认站点
   ![image-20230319144928430](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230319144931.png)
2. 配置 `Nginx`

   ```shell
   nginx -t
   ```

   编辑 `nginx.conf`文件

   ```shell
   vim /etc/nginx/nginx.conf
   ```

   按 `i`进入编辑模式，粘贴完按 `Esc` 键退出编辑模式，输入 `:wq` 保存退出。

   ![3](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230326101400.png)
3. 启动 `nginx`

   ```shell
   systemctl start nginx.service
   ```

   重启 `ngxin`

   ```shell
   systemctl restart nginx.service
   ```

## 修改 `Hexo`配置

在配置文件 `_config.yml`中找到 `deploy`，修改为

```shell
deploy:
  type: git
  repo: git@hjxlog.com:/var/repo/hexo.git #repo改为repo: git@你的域名:/var/repo/hexo.git
  branch: master
```

三连部署

```shell
hexo cl & hexo g & hexo d
```
