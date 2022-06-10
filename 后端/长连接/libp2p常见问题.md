# libp2p-(helium-gate)与helium-gateway 通信流程？

setup:
1. 启动libp2p server,将监听的地址写入redis, 以便业务服务拿到该地址进行请求长连接;  监听的地址示例：/ip4/192.168.0.138/tcp/10112/ws/p2p/12D3KooWLbuiUYbVS6vMKh7ykhrddQdYg3TNs4q7fbhNvg8VpDRP
2. 启动业务服务，连接数据库，拿到libp2p的服务地址，NewLibp2pClient，初始化libp2p连接；每个IP维护1-10个连接; 



# libp2p-(helium-gate)与sdk-agent 通信流程？