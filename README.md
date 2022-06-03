# devops-tools
常用的运维工具


## ubuntu 
```
apt-get install ufw
ufw enable
ufw allow 80/tcp
ufw allow 443/tcp
```

  防火墙设置参考：
 -  https://www.hostinger.com/tutorials/how-to-configure-firewall-on-ubuntu-using-ufw/
  
  证书生成：
 如果certbot  生成证书失败，常见的错误Type:   unauthorized/ 404; 
 尝试使用 lego生成证书
 ```
 apt install lego 
 
 // 生成https证书
 lego --email="jianhu918@gmail.com" --domains="hujian.xyz" --http run
 
 // 证书生成后的位置
 ls -l ~/.lego/certificates/
```
参考：
 - https://go-acme.github.io/lego/usage/cli/examples/
 - https://eff-certbot.readthedocs.io/en/stable/using.html#where-are-my-certificates