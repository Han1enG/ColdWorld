---
title: Hexo + Butterfly 添加评论系统
date: 2023-03-15 11:53:52
tags:
  - Hexo
categories: Blog
---
>  参考作者给出的[教程](https://butterfly.js.org/posts/ceeb73f/)以及官方文档[twikoo](https://twikoo.js.org/)和[waline](https://waline.js.org/)

## 通用设置

### 主题文件配置

1. 在主题配置文件`_config.butterfly.yml`中找到`comments`
    ```yaml
    comments:
      # Up to two comments system, the first will be shown as default
      # Choose: Disqus/Disqusjs/Livere/Gitalk/Valine/Waline/Utterances/Facebook Comments/Twikoo/Giscus/Remark42/Artalk
      use: Twikoo,Waline
      text: true # Display the comment name next to the button
      # lazyload: The comment system will be load when comment element enters the browser's viewport.
      # If you set it to true, the comment count will be invalid
      lazyload: true
      count: true # Display comment count in post's top_img
      card_post_count: false # Display comment count in Home Page
    ```

2. 在主题配置文件`_config.butterfly.yml`中找到`waline`
    ```yaml
    waline:
      serverURL: waline.coldcoding.top  # 填入刚刚得到的后端 URL（必填,根据实际情况填写你自己的域名）
      option:
        locale: {
          nick: '昵称',
          mail: '邮箱',
          link: '你的网站',
          placeholder: '欢迎大家文明评论嗷～(填写邮箱可以收到回复通知)',
          requiredMeta: [],
          mailError: '请填写正确的邮件地址',
          sofa: '快来抢占沙发~',
          level0: '列兵',
          level1: '上等兵',
          level2: '一期',
          level3: '二期',
          level4: '三期',
          level5: '四期',
          level6: '五期',
          level7: '六期',
          level8: '兵王',
          }
        emoji: [
            'https://cdn.jsdelivr.net/gh/walinejs/emojis@1.0.0/tw-emoji',
            'https://cdn.jsdelivr.net/gh/norevi/waline-blobcatemojis@1.0/blobs',
            'https://cdn.jsdelivr.net/gh/walinejs/emojis@1.0.0/bilibili',
            ]
    ```

3. 在主题配置文件`_config.butterfly.yml`中找到`twikoo`
    ```yaml
    twikoo:
      envId: twikoo.coldcoding.top
      region:
      visitor: false
      option:
        locale: {
          nick: '昵称',
          mail: '邮箱',
          link: '你的网站（选填）',
          placeholder: '欢迎大家文明评论嗷～(填写邮箱可以收到回复通知)',
          requiredMeta: [],
          mailError: '请填写正确的邮件地址',
          sofa: '快来抢占沙发~',
          level0: '列兵',
          level1: '上等兵',
          level2: '一期',
          level3: '二期',
          level4: '三期',
          level5: '四期',
          level6: '五期',
          level7: '六期',
          level8: '兵王',
          }
        emoji: [
            'https://cdn.jsdelivr.net/gh/walinejs/emojis@1.0.0/tw-emoji',
            'https://cdn.jsdelivr.net/gh/norevi/waline-blobcatemojis@1.0/blobs',
            'https://cdn.jsdelivr.net/gh/walinejs/emojis@1.0.0/bilibili',
            ]
    ```

    

### 安装`Waline`

```bash
$ npm install @waline/hexo-next --save
```

## Waline

### LeanCloud

#### 注册[LeanCloud国际版](https://console.leancloud.app/)

#### 创建应用

![image-20230315121854860](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315212506.png)

进入`设置-应用凭证`，记下自己的`AppID、AppKey、MasterKey`。

### Vercel

点击[vercel](https://vercel.com/new/clone?repository-url=https://github.com/walinejs/waline/tree/main/example)进行 `Server` 端部署。

1. 使用`GitHub`登录。

    吐槽一下需要用手机号登录，国内`github`一般都是绑定的邮箱，虽然`github`开了双重认证，但是没有中国地区的选项，之前看到有人发帖反映过问题，得到的答复是国内收到信息的成功率比较低，就直接去掉了。在绑定页面`F12`进入开发者模式，直接把美国换成中国的`+86`。
    ![image-20230315212428121](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315212430.png)

2. 新建一个项目
    ![image-20230316214304309](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230316214314.png)
    ![image-20230316214548547](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230316214552.png)

3. 点击仪表盘的`Settings/Environment Variables`，进入环境变量配置页，并配置三个环境变量 `LEAN_ID`, `LEAN_KEY` 和 `LEAN_MASTER_KEY` 。它们的值分别对应上一步在 `LeanCloud` 中获得的 `APP ID`, `APP KEY`, `Master Key`。
    ![image-20230316215052293](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230316215055.png)

4. 环境变量配置完成之后点击顶部的 `Deployments` 点击顶部最新的一次部署右侧的 `Redeploy` 按钮进行重新部署。该步骤是为了让刚才设置的环境变量生效。
    ![image-20230316215311670](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230316215315.png)

5. 等待片刻后 `STATUS` 会变成 `Ready`。此时请点击 `Visit` ，即可跳转到部署好的网站地址，此地址即为你的服务端地址。

6. 点击顶部的 `Settings` - `Domains` 进入域名配置页，输入需要绑定的域名并点击 `Add`
    ![image-20230317222046504](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230317222049.png)
    以上信息表明需要在你的域名商管理后台配置对应的`CNAME`解析后才能生效，这里以腾讯云为例，按照`vervel`推荐进行配置，同时可以参考这篇[教程](https://tangly1024.com/article/vercel-domain)。
    ![image-20230317222100297](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230317222104.png)
    ![image-20230317222125363](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230317222128.png)

    

7. 等待生效，就可以通过自己的域名来访问了🎉

    - 评论系统：waline.yourdomain.com
    - 评论管理：waline.yourdomain.com/ui

    ![image-20230317222223707](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230317222226.png)
    ![image-20230317222502134](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230317222505.png)

### 部署

一键三连`hexo cl && hexo g && hexo d`部署



## Twikoo

### MongoDB

1. 官方文档给出了多种部署方式，这里选择了 [MongoDB](https://www.mongodb.com/zh-cn/cloud/atlas/register)数据库来存储数据，首先进行账号注册，并创建免费数据库。区域推荐选择 `AWS / N. Virginia (us-east-1)`，在 `Clusters` 页面点击 `CONNECT`，按步骤设置允许所有` IP`地址的连接。
    ![image-20230315222619248](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315222620.png)
2. 连接数据库，选择`Connect your application`
    ![image-20230315222948746](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230315222950.png)
    ![image-20230318150133844](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318150136.png)
3. 记录下`connection string`

### Vercel

1. 点击[vercel](https://vercel.com/import/project?template=https://github.com/imaegoo/twikoo/tree/main/src/server/vercel-min)进行`server`端部署，新建一个仓库。
    ![image-20230318150716668](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318150814.png)
    ![image-20230318150944565](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318150946.png)

2. 进入 `Settings - Environment Variables`，添加环境变量 `MONGODB_URI`，值为上一步的数据库连接字符串，注意将`<password>`替换为自己设置的用户密码。

    ![image-20230318151338849](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318151340.png)

3. 进入 `Deployments` , 然后在任意一项后面点击更多（三个点） , 然后点击`Redeploy` , 最后点击下面的`Redeploy`

4. 进入 `Overview`，点击 `Domains` 下方的链接，如果环境配置正确，可以看到 “Twikoo 云函数运行正常” 的提示。
    ![image-20230318151725984](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318151727.png)

5. 点击顶部的 `Settings` - `Domains` 进入域名配置页，输入需要绑定的域名并点击 `Add`
    ![image-20230318152505606](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318152507.png)

6. 以上信息表明需要在你的域名商管理后台配置对应的`CNAME`解析后才能生效，这里以腾讯云为例，按照`vervel`推荐进行配置，同时可以参考这篇[教程](https://tangly1024.com/article/vercel-domain)。
    ![image-20230318153006726](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318153008.png)
    ![image-20230318153033540](https://images-1311785948.cos.ap-chengdu.myqcloud.com/typora/20230318153035.png)

### 开启管理面板

点击评论窗口的“小齿轮”图标，设置管理员密码

## 针对 Vercel 部署的更新方式

1. 进入 [Vercel 仪表板](https://vercel.com/dashboard) - twikoo - Settings - Git
2. 点击 `Connected Git Repository` 下方的仓库地址
3. 打开 `package.json`，点击编辑
4. 将 `"twikoo-vercel": "x.x.x"` 其中的版本号修改为最新版本号。点击 `Commit changes`
5. 部署会自动触发，可以回到 [Vercel 仪表板](https://vercel.com/dashboard)，查看部署状态

