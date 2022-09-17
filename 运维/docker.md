# 指定docker数据存储路径
* 验证环境：
   - centos 7.9
   - Docker version 20.10.10, build b485636

1. 重新docker工作目录
2. 停止docker   
3. 将docker目录移到到目标目录
4. 修改docker.service文件，使用-graph参数指定存储位置
   - vi /usr/lib/systemd/system/docker.service
   - ```ExecStart=/usr/bin/dockerd --graph /data/docker```
5. 重新加载启动docker   
   ```sh
    docker info |grep "Docker Root Dir"
    systemctl stop docker.socket
    mv  /var/lib/docker /data
    #  修改docker.service文件，使用-graph参数指定存储位置
    vi /usr/lib/systemd/system/docker.service
    ExecStart=/usr/bin/dockerd  --graph /data/docker -H fd:// --containerd=/run/containerd/containerd.sock
  
    systemctl daemon-reload
    systemctl restart docker 
     ```

# 查看容器网络映射端口
docker network inspect bridge
# 进入容器
docker exec -it 63021ad8716d /bin/bash

# 查看使用状态
docker stats

# 查看Docker正在运行的容器是通过什么命名启动的
docker ps -a --no-trunc
docker history registry.cn-shenzhen.aliyuncs.com/risinghf/minio:latest --format "table {{.ID}}{{.CreatedBy}}" --no-trunc

# 查看docker 占用的空间
docker system df
docker system df -v
# 清理docker磁盘空间
docker system prune -a
sudo apt-get clean
# 批量删除镜像（无tag标签镜像）
docker images|grep none|awk '{print $3}'|xargs docker rmi
# 批量删除已经退出的容器：
docker ps -a |grep Exited|awk '{print $1}'|xargs docker rm
# 强制删除所有的镜像
docker rmi -f $(docker images -qa)
# 查看日志
docker logs -t --since="2021-08-27" d1826d2bb544
docker logs -f --tail 10 f7255fec27e5
# 查看指定时间日志

docker logs -f iotsquaredockermaster_iotsquare_1 --since="2021-05-25T07:00:00" 2>&1 | grep "error"

docker logs -f iotsquaredockermaster_iotsquare_1 --since="2020-10-21T15:00:00" 2>&1 | grep "COLLISION_PACKET"

# 开机自启用项目：
docker update --restart=always 你的镜像名称


# docker 保存镜像

docker save -o test.tar registry.cn-shenzhen.aliyuncs.com/risinghf/iotsquare:rxhf-2.1.2-fix4

# docker 加载镜像
docker load --input test.tar



# docker-compose 安装:

curl -L https://github.com/docker/compose/releases/download/1.24.0-rc3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# 运行服务器设置开机重启：
```cgo
 docker run -d   --restart=always  cloudflare/cloudflared:2022.5.3 tunnel --no-autoupdate run --token eyJhIjoiNmVmYjhmY2Y5ZTg5NjIxZDk3MjI2NDNkZTU3Yzg1Y2UiLCJ0IjoiYTE2ZDBiYWQtY2E1OS00NmRmLWIyZDMtN2U1ZWQ4NTViZTJiIiwicyI6Ik5qRmtPVFUxT1RJdE5qZzNOaTAwT0RsaUxXSmxOakV0TXpJNU1HRXhObVUyWmpKbSJ9
```


# hub.docker.com
To use the access token from your Docker CLI client:

1. Run docker login -u sonocrelease

2. At the password prompt, enter the personal access token.
   4e802fef-1402-4c42-b0cd-08ebbfed154c


# 以普通用户运行docker容器

root账户下添加用户：
``` useradd test
    passwd test
```

修改用户可以使用root权限
```shell
sudo vi /etc/sudoers
# 添加行
root    ALL=(ALL)       ALL
test    ALL=(ALL)       ALL

```

将用户加入docker用户组：
```shell
su test
sudo groupadd docker
sudogpasswd -a test docker
newgrp docker 
```
