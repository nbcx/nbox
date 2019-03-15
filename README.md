# 网盘盒子

网盘盒子是基于阿里云的OSS服务提供的API，开发的一个网盘客户端。

主要功能：

- [x] 文件列表显示，包括文件夹切换
- [x] 添加OSS账户信息
- [x] 添加bucket和切换bucket，目前只完成了切换bucket
- [x] 主题设置
- [x] 图片文件预览和视频播放
- [ ] 切换OSS账户
- [ ] 多语言支持
- [ ] 文件搜索功能
- [ ] 文件上传和添加文件夹
- [ ] 文件删除和重命名修改等相关操作
- [ ] 文件下载

可能不会开发的功能
- 支持腾讯COS和七牛云等服务商
- 账户信息备份转移

## 界面预览

<img src="https://github.com/nbcx/nbox/blob/master/art/a.png">
<img src="https://github.com/nbcx/nbox/blob/master/art/b.png">
<img src="https://github.com/nbcx/nbox/blob/master/art/c.png">


## 主要使用到到一些第三方库

* [chewie](https://github.com/brianegan/chewie)
* [dio](https://github.com/flutterchina/dio)
* [shared_preferences](https://pub.flutter-io.cn/packages/shared_preferences)
* [photo_view](https://github.com/renancaraujo/photo_view)
* [synchronized](https://github.com/tekartik/synchronized.dart)
* [flutter_easyrefresh](https://github.com/xuelongqy/flutter_easyrefresh)

更多请看`pubspec.yaml`文件

## 安装

1. **Clone the repo**

```
$ git clone https://github.com/nbcx/nbox.git
$ cd nbox
```

2. **Running:**

```
$ flutter run
```


## 技术交流

QQ群: 1985508