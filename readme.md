# cordova-plugin-engkoo


## 怎么安装

~~~
cordova plugin add https://github.com/menhal/cordova-plugin-engkoo
~~~

安装完之后需要用xcode打开ios项目然后进行如下设置 ，否则编译会报错

C language Dialect 选 gnu11
c++ language dialect 选 GNU++14

## 播放器

~~~ language=javascript

var token = "{\"access_token\":\"aDDW4rtAlN04q617L3AwLJ7Jd-vTL3IJLApzipPxCd8bfl2-dOUO0tyzFWZtOLeMMhQ7AKJTX9YjEhv6nOXEw5SZoqUgiv6rjCkUP785Eb-dlTNIC5dGUZ00ANmSfxoWoSjbOHw3B9_mb6yupJZvSejHknOQr9fxgNgo2Tl34KSH63POJ7J4qWPnk9DZRKV-bIWvddnlbdI1dT27CmEQi2e5mDDsq58iwxVE1PAn1SsTO9FvNLHqPrcloeC2hghERW7YyR1DNVSkxqSt8le5adVqgoE7xAl0KQYxcu4Kn8Fa9dWOuPTk37d1h2g27Y6EZVyyXcQWUCTcoLPFqnwgdqcsymAV7owYx0vqHCMdUmT3RRESuS9z7sqDlHXZ1gX0aBLjcuUhUJZVTMOMGiN-om8EJuHZSHAyDqKMEGxcyiST6K5JYyRgQrOSF-NtvejR\",\"token_type\":\"bearer\",\"expires_in\":1209599,\".issued\":\"Sun, 09 Jun 2019 03:56:26 GMT\",\".expires\":\"Sun, 23 Jun 2019 03:56:26 GMT\"}";

Engkoo.show(token);

~~~


## token获取地址
$.post("https://dev-mtutor.chinacloudsites.cn/proxy/oauth/login", {grant_type:"XFX", id:32, secret:"55F51592-A7AF-461B-B52C-54CE07B3ED05"})