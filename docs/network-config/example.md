# 示例

## 示例: Wordpress 单机中文版

[应用链接](https://appcenter.qingcloud.com/apps/app-jbvdproy)

通过下面的步骤，我们可以创建一个 wordpress 单机版的 App，并利用 VPC 网络的端口转发进行公网访问。

1. [创建依赖资源](create_vxnet.html) - 一个连接到 VPC 的私有网络（SDN 2.0）

2. 利用 [VPC 的端口转发](config_portmapping.html)响应公网请求

## <a id = "tomcat_cluster">示例: Tomcat Cluster on QingCloud</a>

[应用链接](https://appcenter.qingcloud.com/apps/app-jwq1fzqo)

通过下面的步骤，我们可以创建一个 Tomcat 集群，并利用负载均衡器进行公网访问。

1. [创建依赖资源](create_vxnet.html)- 一个连接到VPC的私有网络（SDN 2.0）

2. 为 AppCenter 应用[配置公网负载均衡器](public_loadbalancer.html)

同样也可以参考[Tomcat Cluster on QingCloud AppCenter 用户手册](https://github.com/QingCloudAppcenter/user-guide/tree/master/docs/tomcat) 进行配置。