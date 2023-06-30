#!/bin/bash

# for ubuntu 18.04
function install_v2ray {

echo "install_v2ray..."

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

yes_or_no "install v2ray?" install_v2ray