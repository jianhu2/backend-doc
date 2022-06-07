
## 2.7 packet forward版本管理

### 2.7.1  创建packetForward版本列表
接口:
- /api/packetForwardUpgrade/createNewVersion


请求方式: POST
#### 请求参数


| 字段名字   | 类型 	 |是否必选 	 | 描述    |
| :-------- | :----- |:----- | :-------|
|name	    |  string|是 |版本名称  |
|fileUrl	| string |是 |文件地址  |
|arch| string |是|cpu架构|

#### 响应参数
| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
| code     | int        | 响应码                     |
| msg      | string     | 响应消息                   |
| id         |int|packetForward版本ID|


### 2.7.2 packetForward版本列表
接口:
- /api/packetForwardUpgrade/listVersion

请求方式: GET
#### 请求参数


| 字段名字   | 类型 	 |是否必选 	 | 描述    |
| :-------- | :----- |:----- | :-------|
|pageNo	| int |否 |分页页数，默认从1开始  |
|pageSize	| int |否 |分页大小，默认10  |

#### 响应参数
| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
| code     | int        | 响应码                     |
| msg      | string     | 响应消息                   |
|count    |int|总数|
|versions  |struct|版本详情|

versions：

| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
| id     | int        | packetForward版本ID                     |
| versionName      | string     | 版本名称                   |
|userId         |int|用户ID，谁创建的|
|fileUrl         |string|文件下载地址|
|arch| string|架构：例：arm |
|createdAt|string|创建时间,格式"2006-01-02 15:04:05"|


### 2.7.3  删除packetForward版本
接口:
- /api/packetForwardUpgrade/deleteVersion


请求方式: POST
#### 请求参数


| 字段名字   | 类型 	 |是否必选 	 | 描述    |
| :-------- | :----- |:----- | :-------|
|versionId	    |  int|是 |版本ID |

#### 响应参数
| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
| code     | int        | 响应码                     |
| msg      | string     | 响应消息                   |



### 2.7.4  （网关调用）检查packetForward版本
接口:
- /api/packetForwardUpgrade/checkNewVersion


请求方式: POST
#### 请求参数


| 字段名字   | 类型 	 |是否必选 	 | 描述    |
| :-------- | :----- |:----- | :-------|
|gatewayId	    |  string|是 |网关ID |
|currentVersion	    |  string|是 |现在的版本 |
|upgradeType	    |  int|是 |升级类型:1,deb;2 bridge,3.packetForward |

#### 响应参数
| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
| code     | int        | 响应码                     |
| msg      | string     | 响应消息                   |
|hasNewVerson|bool|是否需要升级|
|upgradeRecordId|int|升级的唯一ID|
| newVersion      | struct     | 新packetForward的信息                   |

newVersion:

| 字段名字 | 类型       | 描述                       |
| :------- | :--------- | :------------------------- |
|id      | int     | id                   |
|versionName      | string     | 版本名称                   |
|userId      | int     | 用户ID，谁创建的                   |
|fileUrl      | string     | 文件下载地址                  |
