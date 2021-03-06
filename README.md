# backend-doc
后端技术栈、运维技术栈、常用工具安装（比如：golang,goland、 shadowsocks、文件对比器、makedown）、技术分享等
包括但不限于以上



# 后端代码规范参考
* 《代码简洁之道》
* 《架构简洁之道》
* 《重构:改善既有代码的设计》
* 测试驱动开发
* golang一些代码写法干净利落的开源代码：
    * https://github.com/drone/drone
    * https://github.com/asim/go-micro



# 代码风格

## 分布式场景下的可靠性
* 谨慎使用协程(Goruntine)，如果用，一定要考虑如果程序在协程处理过程中被杀了怎么办
* 函数支持超时控制，一般有IO的函数，通过`context.Context`参数层层传递

## 清晰
* defer写法只是拿来释放文件/socket/连接等资源，不要拿来做复杂逻辑
* 空行。函数/方法/结构体定义之间，均需要空一行。
* 函数复杂度
    * 一个函数内不应该有太复杂的跳转、深层次代码逻辑、二层及以上的循环体，尽量拆分成类实例方法/局部方法
* 涉及数据的结构，尽可能用结构体而非map[string]interface{}，要将所有的数据以确切的结构化数据格式表示。
* 注意代码长度。
    * 函数长度不应该超过两次翻屏（50行代码为上限，特殊算法类、main函数、简单的堆叠同类代码如switch/ifelse的可以例外），否则人脑很难记得住。
* 函数参数
    * 避免使用`map[string]interface{}`传参
    * 尽量少于4个函数参数，除特殊情况外
* 变量命名
    * 用有意义的命名，不要用`map`/`list`这样通用的
    * 接口返回给前端的数据字段，是数字就用数字类型，不要拼上单位当成字符串
    * 变量命名用驼峰，不要用全大写或者缩写简称。 函数参数/变量用小写开头的驼峰，结构体、对包外可访问的全局变量用大写开头的驼峰。函数命名也类似
```shell 
比如
gatewayID => gatewayId   FwVersion => FirmwareVersion
```

## 高内聚低耦合
* 注意一个模块内，哪些可以暴露到外部，哪些不应该暴露，跟据Golang的习惯，用首字段大小写进行区分。
* 依赖别的模块的功能，尽量依赖`Interface{}`而不是具体实现的类，以实现隐藏和解耦
* 少用全局变量。不过太依赖全局变量，一个业务要把它自己的状态，放在自己的文件/类/目录里面自己维护。

# 注释
* 要写有意义的注释，复杂的功能要说明开发的背景、需要看的一些文档。功能越重要，越需要注释。
* 过于细节又重要的点要标注
* 定制内容，场景极有限的代码，要注明
* 有不妥当/可改进的要写 `//TODO:`，以便后续进行改进

# 分层
![代码分层](./img/code-layers.png)

### 纵向
代码依赖都是有层次的，一般就3-4层，而且是单向依赖的，写代码一定要关注代码所处的层次、依赖的层次

代码业务逻辑应该封装好，不要在MQTT/HTTP处理函数里面写过多逻辑（可以参考目前文件上传fileUpload、实时日志实现），与协议有关的入口，最好是拿来拼输入输出的，不适合放业务逻辑。
* 目前定义的用于业务逻辑的目录是internal/service/
* 存储是internal/storage/,

### 横向
不同的业务代码也不要交叉，应放在不同的目录/文件中，即便某个业务代码即少也是如此。

# 测试
## 单元测试
独立的业务逻辑算法能写单元测试的就写。 有外部依赖的，简单的也要写。

## 集成测试
麻烦是数据库/redis等外部依赖，虽然动态创建数据库之类的实现也能做到单元测试。但
在分布式环境下， 服务有众多的依赖，用端到端的API去驱动自动化测试的形式才更可靠，
这种情况下没必要针对单一功能/接口做单元测试了。
 

