#!/bin/bash

# for ubuntu 18.04
if [ -z "$1" ]
then
      echo "Usage: $0 \$domain"
      exit
fi

DOMAIN=$1
EMAIL=jianhu216@gmail.com

function sys_update {
    apt update && apt-get upgrade -y
    apt install -y nginx certbot unzip

    apt-get install software-properties-common
    add-apt-repository ppa:ondrej/nginx
    apt remove -y nginx
    apt install -y nginx
}

function enable_bbr {
cat <<EOF >> /etc/sysctl.conf
fs.file-max = 51200

net.core.default_qdisc = fq

net.core.rmem_max = 67108864

net.core.wmem_max = 67108864

net.core.rmem_default = 65536

net.core.wmem_default = 65536

net.core.netdev_max_backlog = 4096

net.core.somaxconn = 4096


net.ipv4.tcp_syncookies = 1

net.ipv4.tcp_tw_reuse = 1

net.ipv4.tcp_fin_timeout = 30

net.ipv4.tcp_keepalive_time = 1200

net.ipv4.ip_local_port_range = 10000 65000

net.ipv4.tcp_max_syn_backlog = 4096

net.ipv4.tcp_max_tw_buckets = 5000

net.ipv4.tcp_fastopen = 3

net.ipv4.tcp_rmem = 4096 87380 67108864

net.ipv4.tcp_wmem = 4096 65536 67108864

net.ipv4.tcp_mtu_probing = 1

net.ipv4.tcp_congestion_control = bbr

EOF

sysctl -p

cat << EOF >> /etc/profile
ulimit -n 51200
EOF
}

function enable_swap {
sudo swapon --show
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show

echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
}

function get_nginx_cert {
# prepare upstream
cat << EOF > /etc/nginx/conf.d/upstream.conf
upstream v2ray {
      server 127.0.0.1:10000;
}

upstream shadowsocks {
      server 127.0.0.1:10001;
}
EOF

cat << EOF >  /etc/ssl/certs/dhparam.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA59oCSXKEoKPSBai086EGdnwBjmf6JBUFHmhWQaq60gyjX6cS7Qhd
UrhC6tIczZZW0+jtzasuZwafISydXyfUOwzziZTeQup+Zj5nI8SMoe2bjsORxn5j
Te08nWMJd+8pSfOs1orhpUdPS5UzfmUurkX9/HGKN0i0G8MlDlkbE+XV3AHyezP1
6qUB/PZinmQdxaYfNAdztz9tgRwfo+Y7X1c9wmWMV/Cl44DZqZzw37PdgY9tdNm5
0LkNf0OvXNWrvtiNiVxZ30BxvKtFHlSDTd3dd691mBfQ9p/XY2+5TQpJXy1p9fmS
Kv/zrlz24fVIzThmFqawOLI4k3Xi4GiUAwIBAg==
-----END DH PARAMETERS-----
EOF

cat << EOF > /etc/nginx/snippets/letsencrypt.conf
location ^~ /.well-known/acme-challenge/ {
  allow all;
  root /var/lib/letsencrypt/;
  default_type "text/plain";
  try_files \$uri =404;
}
EOF

cat << EOF > /etc/nginx/snippets/ssl.conf
ssl_dhparam /etc/ssl/certs/dhparam.pem;

ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
ssl_prefer_server_ciphers on;

ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 30s;

add_header Strict-Transport-Security "max-age=15768000; includeSubdomains; preload";
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
EOF


cat << EOF > /etc/nginx/sites-available/$DOMAIN
server {
  listen 80;
  server_name $DOMAIN;

  include snippets/letsencrypt.conf;
}
EOF

mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt


sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo systemctl restart nginx

sudo certbot certonly --agree-tos --email $EMAIL --webroot -w /var/lib/letsencrypt/ -d $DOMAIN
sudo certbot renew --renew-hook "systemctl reload nginx"

mkdir -p /etc/letsencrypt/renewal-hooks/post/
cat << EOF > /etc/letsencrypt/renewal-hooks/post/reload.sh
#!/bin/sh
systemctl reload nginx
EOF
chmod +x /etc/letsencrypt/renewal-hooks/post/reload.sh
}

function enable_nginx_https {
cat << EOF > /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    include snippets/letsencrypt.conf;
    return 301 https://$DOMAIN\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$DOMAIN/chain.pem;
    include snippets/ssl.conf;
    include snippets/letsencrypt.conf;

    #root /var/www/$DOMAIN;
    #index index.html;

    location / {
        root /var/www/html/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        charset utf-8,gbk;
    }

    location /v {
        proxy_redirect off;
        proxy_pass http://v2ray;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;

        # Show real IP in v2ray access.log
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /s {
        proxy_redirect off;
        proxy_pass http://shadowsocks;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }

}
EOF
sudo systemctl restart nginx

}

function install_v2ray {

curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh --output v2raygo.sh

chmod +x v2raygo.sh
./v2raygo.sh
# cp /etc/v2ray/config.json /etc/v2ray/config.json.bak
cat << EOF > /usr/local/etc/v2ray/config.json
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": 10000,
    "listen": "127.0.0.1",
    "protocol": "vmess",
    "settings": {
      "clients": [
        { "id": "92c79a2e-fda3-497f-8075-50d887c1f75f", "level": 1, "alterId": 64},
        { "id": "d3134c2b-a7bc-4019-a941-9c42202ee7b1", "level": 1, "alterId": 64},
        { "id": "a3ee2d97-5766-4042-a670-f75238d8e39e", "level": 1, "alterId": 64},
        { "id": "8372eeab-66ac-41f8-b8e7-c5d5cc283d0b", "level": 1, "alterId": 64},
        { "id": "04adfdcf-fb45-4dd2-8124-e154f8ca6a7d", "level": 1, "alterId": 64},
        { "id": "6a489dfa-601a-4e8c-ba4a-e64754f8fc23", "level": 1, "alterId": 64},
        { "id": "8d3291bb-a37f-440c-a49d-e8a8a33bbc2d", "level": 1, "alterId": 64}

      ]
    },
    "streamSettings":{
      "network":"ws",
      "wsSettings": {
        "path": "/v"
      }
    }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "outboundDetour": [
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        }
      ]
    }
  }
}
EOF
sudo systemctl restart v2ray
}


function yes_or_no
{
read -p "$1 (Y/N)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    $2
fi
}


ss_file=0
v2_file=0
get_latest_ver(){
    ss_file=$(wget -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest | grep name | grep tar | cut -f4 -d\")
    v2_file=$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep linux-amd64 | grep name | cut -f4 -d\")
}

install_v2ray_plugin (){
    if [ -f /usr/local/bin/v2ray-plugin ];then
        echo "\033[1;32mv2ray-plugin already installed, skip.\033[0m"
    else
        if [ ! -f $v2_file ];then
            v2_url=$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep linux-amd64 | grep browser_download_url | cut -f4 -d\")
            wget $v2_url
        fi
        tar xf $v2_file
        mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin
        if [ ! -f /usr/local/bin/v2ray-plugin ];then
            echo "\033[1;31mFailed to install v2ray-plugin.\033[0m"
            exit 1
        fi
    fi
}

function install_shadowsocks {

get_latest_ver

install_v2ray_plugin

apt install -y shadowsocks-libev

cat << EOF > /etc/shadowsocks-libev/config.json
{
    "server":"127.0.0.1",
    "server_port":10001,
    "local_address": "0.0.0.0",
    "local_port":1080,
    "password":"H2Zf8Me3GX",
    "timeout":600,
    "method":"aes-256-gcm",
    "fast_open":true,
    "no_delay": true,
    "workers":4,
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;fast-open;path=/s;loglevel=none"
}
EOF

systemctl restart shadowsocks-libev
}

yes_or_no "update system?" sys_update

yes_or_no "enable brr?" enable_bbr

yes_or_no "enable swap?" enable_swap

yes_or_no "get nginx cert?" get_nginx_cert

yes_or_no "enable nginx https?" enable_nginx_https

yes_or_no "install v2ray?" install_v2ray

yes_or_no "install shadowsocks?" install_shadowsocks
