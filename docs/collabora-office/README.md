# Collabora Office on QingCloud AppCenter 用户手册

<extoc></extoc>

## 描述

[Collabora Office](https://www.collaboraoffice.com/code/) 是一个开源的企业级文档协同编辑解决方案。

`Collabora Office on QingCloud AppCenter` 将 Collabora Office 通过云应用的形式在 QingCloud AppCenter 部署，具有如下特性：

- 支持与 NextCloud 集成，请参考[Nextcloud 文档](https://appcenter-docs.qingcloud.com/user-guide/apps/docs/nextcloud/)
- 支持横向与纵向扩容
- 系统自动运维，降低企业使用成本

## 创建步骤

### 第1步: 基本设置

根据自己的需求填写 `名称` 和 `描述`，不影响集群的功能，版本一般建议选择最新版本。

### 第2步: Collabora Office 节点设置

Collabora Office 节点依赖于青云 QingCloud 提供的负载均衡器服务，我们需要创建资源并进行相应的设置。如果之前创建 [NextCloud 集群](https://appcenter.qingcloud.com/apps/app-7780utnf) 时已经创建了负载均衡器，则只需要再创建一个监听器并监听不同端口即可。同样需要注意：

- 监听器需开启会话保持
- 监听器的超时时间需设置为 86400 秒

根据自己的实际需求选取节点的配置，无特殊需求可以直接使用默认的配置：

- CPU: 2核
- 内存: 2G

### 第3步：网络设置

出于安全考虑，所有的集群都需要部署在私有网络中。如果之前创建 NextCloud 集群时已经创建了私有网络，则需要与 NextCloud 在同一私有网络下。

### 第4步：服务环境参数设置

访问地址是你用来访问这个集群的地址，可以是负载均衡器绑定的公网 IP，也可以是已经设置好 DNS 解析的域名，比如 `https://abc.xyz` 或者 `http://1.2.3.4` 。

> 如果与 NextCloud 集成，则需要注意必须使用与 NextCloud 相同的协议，且默认不需要添加端口号。
> 比如：
> NextCloud 集群中的配置为： https://test.nextcloud.com
> 则 Collabora Office 集群中的配置应为：https://test.nextcloud.com

### 第5步: 用户协议

阅读并同意青云 APP Center 用户协议之后即可开始部署应用。


## Tips

- 如果部署完毕后打开文档提示错误，请使用尝试 reload 集群再试，如果问题持续存在，请提交工单申请技术支持。
