# mqtt鉴权机制？

鉴权流程两种方式：

方式一：
对于业务服务，账户密码写在代码里； 对于mqtt服务 账户密码写在文件里，通过文件里的账号密码鉴权（ helium项目mqtt配置文件示例：）

cat /mosquitto/config/mosquitto.conf
```
listener 1883
protocol mqtt

listener 2883
protocol mqtt
cafile /mosquitto/tls/caCert.pem
certfile /mosquitto/tls/serverCert.pem
keyfile /mosquitto/tls/serverKey.pem
#  双向认证
require_certificate false
tls_version tlsv1.2

log_type debug
log_dest stderr
connection_messages true
log_timestamp true
set_tcp_nodelay true
persistence false

allow_anonymous false
password_file /mosquitto/config/passwd.txt
acl_file /mosquitto/config/acls.txt
）
```

cat /mosquitto/config/acls.txt
```
# helium-manage service user
user b5d39f4516fd1714
topic read rxgw/+/http/response/+
topic write rxgw/+/http/request/+
topic read txgw/+/http/request/+
topic write txgw/+/http/response/+

# gateway service user
user 945c87d95c3007ea
topic read rxgw/+/http/request/+
topic write rxgw/+/http/response/+
topic read txgw/+/http/response/+
topic write txgw/+/http/request/+
topic write ping

```

cat /mosquitto/config/passwd.txt
```
b5d39f4516fd1714:PBKDF2$sha256$901$l5Xi9BuvrRd8$vCqT7sehLSe3UJRksH16+TkyudNCDILcL+7fGZ7dxexD3ej3o50elso0M8Vc201F
945c87d95c3007ea:PBKDF2$sha256$901$l5Xi9BuvrRd8$vCqT7sehLSe3UJRksH16+TkyudNCDILcL+7fGZ7dxexD3ej3o50elso0M8Vc202F
```

方式二：对于业务服务，已知的账号密码写到代码，新建的账号密码写到pg数据库；对于MQTT服务 通过业务服务http的方式鉴权;
iotsqaure mqtt示例：
```
# 默认双向验证
listener 1883
protocol mqtt

listener 2883
protocol mqtt
cafile /mosquitto/config/caCert.pem
certfile /mosquitto/config/serverCert.pem
keyfile /mosquitto/config/serverKey.pem
tls_version tlsv1.2

log_type error
log_dest stderr
connection_messages true
log_timestamp true
set_tcp_nodelay true
persistence true
persistence_location /mosquitto/data
plugin /usr/lib/mosquitto_auth_acl.so
plugin_opt_auth_http_api http://iotsquare:7000/internal/mqtt/auth
plugin_opt_acl_http_api http://iotsquare:7000/internal/mqtt/acl
```


业务服务和MQTT在同一台ECS，不需要鉴权，通过nginx不引流api /interna/*
业务服务实现接口：
- /internal/mqtt/auth   // 账号密码是否正确
- /internal/mqtt/acl    // 检查topic是否有操作合法性
 
# 关于证书：
- caCert.pem,serverCert.pem,serverKey.pem三个文件证书是通过docker镜像放到目录/mosquitto/config/

