ubuntu 安装go 


##  环境准备
 ```
  apt update && apt-get upgrade -y
```
## 环境安装
mkdir ~/go

cd ~/go

wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz

tar -C /usr/local go1.18.3.linux-amd64.tar.gz


## 设置环境变量

Go代码必须放在工作空间中，实际上就是一个目录，且必须包含src、pkg、bin三个子目录。它们的用途如下：

- bin：包含编译后的可执行命令
- pkg：包含包对象
- src：包含Go的源文件，它们被组织成包

因此首先创建go语言的工作空间：
```
$  mkdir $HOME/gowork
```

在配置文件中添加环境变量

```
$ vim /etc/profile
```


加入以下内容：
```

export GOROOT=/usr/local/go
export GOPATH=$HOME/gowork
export GOBIN=$GOPATH/bin
export PATH=$GOPATH:$GOBIN:$GOROOT/bin:$PATH
export GONOSUMDB="github.com"
export GONOPROXY="github.com"
export GOPROXY=https://goproxy.cn,direct
export GOPRIVATE="github.com"

```

设置使用git方式拉取私人仓库
```
 git config --global url."git@github.com:".insteadOf "https://github.com/"
```


使配置文件生效
```
$ source /etc/profile
```

安装完成后查看go版本以确认：

```
$ go version
```

之后执行`go env`来检查环境变量是否配置成功：
 






参考：
- https://go.dev/dl/


