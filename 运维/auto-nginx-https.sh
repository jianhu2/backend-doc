#!/bin/bash

if [ -z "$1" ]
then
    echo "Usage: $0 \$domain"
    exit
fi

DOMAIN=$1
EMAIL=jianhu@gmail.com

function sys_upgrade {
    apt update && apt-get upgrade -y
}

function sys_update {
    # install dependencies
    apt update
    apt-get install software-properties-common
    add-apt-repository ppa:ondrej/nginx
    apt install -y nginx certbot unzip
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

# certbot签名证书参考：https://github.com/certbot/certbot
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


function yes_or_no
{
read -p "$1 (Y/N)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    $2
fi
}

yes_or_no "upgrade system?" sys_upgrade
yes_or_no "update system?" sys_update
yes_or_no "get nginx cert?" get_nginx_cert
yes_or_no "enable nginx https?" enable_nginx_https
