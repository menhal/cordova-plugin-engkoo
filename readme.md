# cordova-plugin-polyvplayer


## 怎么安装

ios需要下载pod包管理器（具体怎么下载请百度。。。 算了还是参照这篇文章吧 https://www.jianshu.com/p/43a1891b267d ）
~~~
sudo gem install cocoapods
~~~

安装完pod之后就可以安装插件了
~~~
cordova plugin add ../../cordova-plugin-polyvplayer
~~~

安装完之后需要用xcode打开ios项目然后进行如下设置 ，否则编译会报错

C language Dialect 选 gnu11
c++ language dialect 选 GNU++14

## 播放器

~~~ language=javascript
PolyvPlayer.play(vid, {start:0}, onPolyvPlayerMessage);

function onPolyvPlayerMessage(message){

    switch(message.type){
        // 5秒钟一次报告进度
        case "Playing":
            console.log(message);
            break;

        // 播放完毕
        case "PlayOver":
            console.log(message);
            break;

        // 播放器退出
        case "PlayerQuit":
            console.log(message);
            break;
    }
}
~~~


## 下载器


### 下载视频

~~~ language=javascript
// bitrate 清晰度，取之 1 流畅 2 高清 3 超清
PolyvPlayer.download(vid, {bitrate: 2}, handleMessage, handleError);


// 处理返回信息
function handleMessage(message) {
    switch (message.type) {
        // 更新下载信息
        case "init" :
            console.log(message);
            break;
        // 下载进度
        case "progress" :
            console.log(message);
            break;
        // 下载完成
        case "success" :
            console.log(message);
            break;
    }
}

// 处理错误信息
function handleError(error) {

    switch (error.type) {
        default:
            console.log("下载失败")
    }
}
~~~


### 删除 已下载/下载中的视频

~~~
// bitrate 清晰度，取之 1 流畅 2 高清 3 超清
PolyvPlayer.remove(vid, {bitrate: 2}, function () {
    alert("删除成功");
}, function(){
    alert("删除失败");
});
~~~


### 暂停下载

~~~
// bitrate 清晰度，取之 1 流畅 2 高清 3 超清
PolyvPlayer.stop(vid, {bitrate: 2}, onSuccess, onError);
~~~


### 暂停所有下载

~~~
// bitrate 清晰度，取之 1 流畅 2 高清 3 超清
PolyvPlayer.stopAll();
~~~
