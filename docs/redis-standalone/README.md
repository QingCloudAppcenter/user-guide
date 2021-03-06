# Redis standalone on QingCloud AppCenter 用户手册

<extoc></extoc>

## 描述

   [Redis](https://redis.io/) 是一个使用ANSI C编写的开源、支持网络、基于内存、可选持久性的键值对存储数据库。

**Redis standalone on QingCloud** 将 **Redis** 封装成 App，采用 **Redis** 最近的稳定版本 3.2.9 构建， 支持在 AppCenter 上一键部署，在原生 **Redis** 的基础上增加了其易用性、高可用的特性，免去您维护的烦恼。细致说来，具有如下特性：

- 高可用性。

  **Redis standalone on QingCloud** 集成 **[Redis Sentinel](https://redis.io/topics/sentinel)** 机制，支持秒级主从切换，并提供一个对外的读写 vip, 在保证高可用性的同时，无需手动切换主节点 IP 地址。

- 支持节点的纵向和横向扩容。

  **Redis standalone on QingCloud** 支持单节点和三节点部署方式，只有多节点部署形式包含主从自动切换的功能。可以从单节点增加节点到三节点，而无需暂停当前 **Redis** 服务。也可以从多节点缩小到单节点，此时会导致服务的短暂不可用。

- 一键部署。 

  无需额外配置，可以立即部署一个 **Redis** 服务



## 部署 **Redis standalone** 服务

> 为了您的数据安全，目前 **Redis standalone on QingCloud** 需要部署在私有网络内。请您在部署服务之前，先创建一个私有网络。



### 一. 选择基本配置

​      填写集群的名称，描述，选择应用的版本 _Redis_standalone_v3.2.9_

![服务名称](../../images/redis-standalone/base_step_1.png)

### 二. 配置节点

​        配置单个节点，根据业务需要选择节点CPU/内存/类型，建议选择默认配置，您可以在随后根据业务需要扩容您的节点。选择节点个数，包含单节点和三节点两个版本，但只有三节点版本才包含主从切换的功能。您可以从单节点增加到三节点。

![配置节点](../../images/redis-standalone/base_step_2.png)

### 三. 选择私有网络

​     在此选择您在开始创建好的私有网络。

![选择私有网络](../../images/redis-standalone/base_step_3.png)

### 四. 配置 Redis 环境参数

​       **Redis Standalone on QingCloud** 提供了 **Redis** 大部分配置参数，您可以在此根据需要修改相应的参数。

![配置环境变量](../../images/redis-standalone/base_step_4.png)

- _requirepass_ : 如果您想为您的 **Redis** 服务设置密码，请在此填写，注意密码长度以保证安全



### 五. 部署

​       阅读并同意青云 AppCenter 用户协议之后即可马上部署您的应用。



## 应用详情

​	部署完成后您将看到如下信息

![集群信息](../../images/redis-standalone/cluster_info.png)



- 服务端口信息

  **Redis standalone on QingCloud** 提供一个读写IP，此IP始终指向主节点。当发生主从切换时，此IP将指向新的主节点，无需手动更改主节点IP

### 伸缩节点

​	您可以从三个节点减少到一个节点，任意删除两个节点即可。由于您可能删除主节点，会造成服务的短暂不可用(约5s)，所以请在服务压力较小的情况下减少节点，剩下的节点就会以主节点继续提供服务。

​	您也可以从一个几点增加到三节点，增加节点的过程中服务不会停止，为在线升级方式。从单节点增加到三节点后，集群将自动拥有主从切换的能力，无需任何额外操作。

### 测试服务

​	集群创建完成后，您可以使用 redis-cli 来测试服务是否正常运行

![测试服务](../../images/redis-standalone/test_redis.png)



### 参数修改

​	可以在此修改环境参数，参数修改完成保存后，集群将重启以应用新的参数配置，所以请在服务压力相对较小的时候修改参数。

![修改参数](../../images/redis-standalone/change_env.png)



### 监控告警

​	可以在此为节点配置告警信息，随时监控您的服务

![alert](../../images/redis-standalone/alert.png)



### 迁移现有数据

​	如果您目前有 **Redis( >= 2.6.0)** 数据库数据想迁移到 **Redis on QingCloud** 上来，可以使用下列的方式来迁移:

- **迁移脚本** 您可以使用 [redis_migrate.sh](./redis_migrate.sh) 来迁移，请将脚本下载到本地后，执行`./redis_migrate.sh -f [源地址:端口号] -a [源地址密码] -t [目标地址:端口号] -p [目标地址密码]`，如无密码可不填.

- **redis-port** 您也可以使用 [redis_port](https://github.com/CodisLabs/redis-port/releases) 来迁移， 下载程序后，执行 `./redis-port sync -f [源地址:端口号] -t [目标地址:端口号] --redis -n 8`，如下图，提示完成[100%]，即可终止程序。此工具也支持rdb文件导入，比较灵活，详细说明请参见 https://github.com/CodisLabs/redis-port

![redis_port](../../images/redis-standalone/migrate.png)

### 获取日志

​	获取 **Redis** 日志，**Redis on QingCloud Standalone** 默认开启了 FTP 服务，您可以通过 FTP 来获取 **Redis** 的日志，用户名为 _ftp_redis_ ，默认密码为 _Pa88w0rd_。

![get_log](../../images/redis-standalone/get_log.png)



### 其他

为了更好的管理 Redis 服务，我们默认禁用一些 Redis 的命令，禁用的命令列表如下：

- **BGREWRITEAOF**
- **BGSAVE**
- **DEBUG**
- **CONFIG**
- **SAVE**
- **SHUTDOWN**
- **SLAVEOF**


您可以通过参数配置页打开 _CONFIG_ 和 _SAVE_ 命令，但我们强烈不推荐您这么做。错误地使用 _CONFIG_ 命令可能会导致服务的不可用，我们建议您在生产环境上使用默认设置来禁用这两个命令。 当您需要打开命令时，在配置参数页取消勾选 DISABLE_ALL 选项，并勾选您需要打开的命令，保存配置，服务会自动重启以生效。

![enable_commands](../../images/redis-standalone/set_commands.png)
