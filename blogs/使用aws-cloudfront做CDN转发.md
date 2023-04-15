# CND转发到v2ray服务
环境:
 - 域名一个
 - aws cloudfront服务
 - aws ec2安装v2ray服务


## 数据转发流程
 - A.example.com->cloudfront->B.example.com->ip.ec2.port


## 注意事项
踩过的坑：
1. v2ray-plugin报错 ``` http: TLS handshake error from 64.252.173.97:23912: read tcp 172.21.0.3:443->64.252.173.97:23912: read: connection reset by peer```
    - 原因为2层(EC2,cloudfront)TLS证书不一致; 第一个想法就是将两个证书整成一致，然后cloudfront就上传"Let's Encrypt自签的证书，发现使用自上传的证书cloudfront根本不转发数据了;得出一个结论:cloudfront必须使用它请求生成的tls证书；
    - 解决方案：A.example.com->cloudfront->ip.ec2.port转发流程修改为A.example.com->cloudfront->B.example.com->ip.ec2.port
2. v2ray-plugin报错```not found in 'Sec-Websocket-Version' header ```   
  ```shell
cloudfront ws一直是v2ray.com/core/transport/internet/websocket: failed to convert to WebSocket connection > websocket: unsupported version: 13 not found in 'Sec-Websocket-Version' header
```
   - 原因是cloudfront没有配置转发HTTP请求头,CloudFront 预设并不会转发所有的 HTTP request headers，
    有些 request headers 在经过 CloudFront 之后就被丟掉了导致 v2ray 无法识别到必要的数据。
     需要更改 origin request policies 為 Managed-AllViewer，這樣它才會轉發所有的 headers。
   
    - 解决方案：cloudfront设置源请求策略为```Managed-AllViewer```

## 参考链接：
- [CloudFront配置HTTP请求头的问题](https://github.com/v2ray/discussion/issues/795)
- [docker-compose for v2ray](https://hub.docker.com/r/gists/v2ray-plugin)