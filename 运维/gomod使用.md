
## gomod 
|命令|作用|
|---|---|
| go mod init| 生成 go.mod 文件| 
| go mod download|     下载 go.mod 文件中指明的所有依赖|
| go mod tidy    |     整理现有的依赖|
| go mod graph   |    查看现有的依赖结构|
| go mod edit    |     编辑 go.mod 文件|
| go mod vendor  |     导出项目所有的依赖到vendor目录|
| go mod verify  |     校验一个模块是否被篡改过|
| go mod why     |    查看为什么需要依赖某模块|

## replace

replace [require 中的地址] => [新地址] 

手动添加go get 不出来的地址,然后replace
```
replace (
	github.com/hodgesds/perf-utils => github.com/hodgesds/perf-utils v0.4.0
	//log模块，用的zerolog v1.25.0/v1.26.0都让WithField失效了
	github.com/rs/zerolog => github.com/rs/zerolog v1.24.0
)
```


## go清理缓存
```
go clean -i
go clean -cache
go clean -testcache
go clean -modcache

```
