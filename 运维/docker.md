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

