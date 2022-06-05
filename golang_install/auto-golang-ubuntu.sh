#!/bin/bash

# for ubuntu 18.04


function sys_update {
    apt update && apt-get upgrade -y
}

function create_dir (){
    if [ -f /root/go ];then
        echo "\033[1;32 dir already installed, skip.\033[0m"
    else
         mkdir /root/go
         mkdir -p  /root/go/path/src
    fi
}

function install_golang{
    create_dir

    curl -Ok https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
    tar -zxvf go1.18.3.linux-amd64.tar.gz -C /root/go
    tar -zxvf go1.18.3.linux-amd64.tar.gz -C /root/go
    rm -rf go1.18.3.linux-amd64.tar.gz
    go env -w GOPROXY=https://goproxy.cn,direct
    go env -w GO111MODULE=on

    # 有私人仓库才需要设置如下
    go env -w GOPRIVATE=github.com
    go env -w GONOSUMDB=github.com
    git config --global url."git@github.com:".insteadOf "https://github.com/"

}

function set_profile{
  cat << EOF >> /etc/profile
export GOROOT=/root/go/go
export GOPATH=/root/go/path
export GOBIN=$GOPATH/bin
export PATH=$GOPATH:$GOBIN:$GOROOT/bin:$PATH
EOF
source  /etc/profile
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


yes_or_no "update system?" sys_update

yes_or_no "install golang?" install_golang

yes_or_no "set profile?" set_profile
