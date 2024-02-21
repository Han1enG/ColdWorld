---
title: GitHub Pages绑定个人域名失效
date: 2023-03-15 11:10:00
tags:
  - Hexo
  - 域名
categories: Blog
---

> 暂时将博客托管在了 `GitHub Pages`上，并将个人域名解析指向了博客，但是每次配置好 `Custom domain`，访问成功后，不知不觉又 404 了，查询后发现是每次 `hexo deploy`后，`Custom domain`会被重置而失效。

![image-20230315112244174](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315112246.png)

- 在项目的 `source`文件夹下添加一个 `CNAME`文件，在文件中填写自己的域名地址，注意是存放有资源的 `source`文件夹，而不是主题下的 `source`文件夹，另外 `CNAME`文件无后缀。
  ![image-20230315112806781](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315112845.png)
- 重新部署后，无需再次手动修改配置。
