# 编译web
 - node 
 - yarn

node版本要求 
``` 
node -v
v10.24.1
```

# centos 下载node

``` 
 wget https://nodejs.org/dist/latest-v10.x/node-v10.24.1-linux-x64.tar.xz

 tar -xf node-v10.24.1-linux-x64.tar.xz

 cd node-v10.24.1-linux-x64

 mv bin/n* /usr/local/bin/

```
在项目中执行：
``` 
yarn install
yarn run build

```


