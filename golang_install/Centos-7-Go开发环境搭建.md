# Centos7配置Go开发环境

## 安装golang

准备环境

```
$ sudo yum update
$ sudo yum install wget vim -y
```

源码包编译安装（可下最新版本）：

```
$ wget https://studygolang.com/dl/golang/go1.14.4.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.13.5.linux-amd64.tar.gz
```

`https://studygolang.com/dl`下载最新的源码包编译

## 设置环境变量

Go代码必须放在工作空间中，实际上就是一个目录，且必须包含src、pkg、bin三个子目录。它们的用途如下：

- bin：包含编译后的可执行命令
- pkg：包含包对象
- src：包含Go的源文件，它们被组织成包

因此首先创建go语言的工作空间：

```
$ mkdir $HOME/gowork
```

然后在配置文件中添加环境变量

```
$ vim /etc/profile
```


加入以下内容：

```
# Golang
export GO111MODULE=on
export GOROOT=/usr/local/go
export GOPATH=$HOME/gowork
export GOCACHE=/tmp/gocache
export GONOSUMDB="github.com"
export GONOPROXY="github.com"
export GOPRIVATE="github.com"

export PATH=$PATH:$GOROOT/bin保存后执行source使其生效：
```

```
$ source /etc/profile
```

安装完成后查看go版本以确认：

```
$ go version
```

若有版本输出则表示安装成功，如`go version go1.14.4 linux/amd64`

之后执行`go env`来检查环境变量是否配置成功：

```
GO111MODULE="on"
GOARCH="amd64"
GOBIN=""
GOCACHE="/tmp/gocache"
GOENV="/root/.config/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOINSECURE=""
GONOPROXY="github.com"
GONOSUMDB="github.com"
GOOS="linux"
GOPATH="/root/gowork"
GOPRIVATE="github.com"
GOPROXY="https://proxy.golang.org,direct"
GOROOT="/usr/local/go"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/usr/local/go/pkg/tool/linux_amd64"
GCCGO="gccgo"
AR="ar"
CC="gcc"
CXX="g++"
CGO_ENABLED="1"
GOMOD="/dev/null"
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build989704061=/tmp/go-build -gno-record-gcc-switches"
```

可以看到GOPATH以及变为我们设置的值，也可以执行`cd $GOPATH`看是否进入对应的文件夹来验证是否配置成功。

## 环境测试

首先在工作空间中创建源代码目录：

```
$ cd $HOME/gowork
```

然后在该目录下创建hello.go文件

```
$ vim hello.go
```

输入以下程序：

```
package main

import "fmt"

func main() {
    fmt.Printf("hello, world\n")
}
```

然后用`go run`运行

```
$ go run hello.go
```

输出`hello, world`，运行成功。
