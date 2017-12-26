# Apache ZooKeeper on QingCloud AppCenter 用户指南

<extoc></extoc>

## 简介

青云QingCloud ZooKeeper 服务提供的是原生 [Apache ZooKeeper](http://zookeeper.apache.org/) 云服务，ZooKeeper 是一个高可用的分布式数据管理与系统协调软件，它可以为分布式应用提供状态同步、配置管理、名称服务、群组服务、分布式锁及队列、以及 Leader 选举等服务。

## 创建 ZooKeeper

在青云上，您可以很方便的创建和管理一个 ZooKeeper 集群。青云的 ZooKeeper 集群支持横向与纵向在线伸缩，同时具有自我诊断与自我修复功能，即当系统发现某节点坏死时会自我修复，无需人为干预。 另外我们还提供了监控告警等功能来帮助您更好的管理集群。集群将运行于私有网络内，结合青云提供的高性能硬盘，在保障高性能的同时兼顾您的数据安全。

> 为了保障数据安全, ZooKeeper 集群需要运行在受管私有网络中。所以在创建一个 ZooKeeper 集群之前，需要创建一个 VPC 和一个受管私有网络，受管私有网络需要加入 VPC，并开启 DHCP 服务（默认开启）。

第一步：选择基本配置

在创建的对话框中，您需要填写名称 (可选)，选择 ZooKeeper 版本号、CPU、节点配置和数量、私有网络等。
> 目前集群节点数支持1、3、5、7、9，其中1个节点的 ZooKeeper 仅供测试使用。

第二步：创建成功

当 ZooKeeper 创建完成之后，您可以查看每个节点的运行状态。当节点的服务状态显示为“正常”状态，表示该节点启动正常。 当每个节点都启动正常后 ZooKeeper 集群显示为“活跃”状态，表示您已经可以正常使用 ZooKeeper 服务了。


## 测试 ZooKeeper

ZooKeeper 创建完成之后可以进行连接测试。下载 [ZooKeeper](http://zookeeper.apache.org/releases.html) 并解压，您可以在 ZooKeeper 同一私有网络或跨网络的客户端上测试。现假设客户端和 ZooKeeper 在同一私有网络，ZooKeeper 集群有三个节点，IP 地址分别为192.168.100.10,192.168.100.11,192.168.100.12， 您可以通过如下命令连接 ZooKeeper：

```shell
bin/zkCli.sh|zkCli.cmd -server 192.168.100.10:2181,192.168.100.11:2181,192.168.100.12:2181
```

同时该应用也提供了 [REST](https://github.com/apache/zookeeper/tree/trunk/src/contrib/rest) 服务，可以通过下面命令获取 znode 信息：

```shell
curl -H'Accept: application/json' http://192.168.100.10:9998/znodes/v1/
```

## 在线伸缩

### 增加节点

当 ZooKeeper 需增加节点以应付客户端逐步增多带来的压力，您可以在 ZooKeeper 详细页点击“新增节点”按钮。 新增节点数必须为偶数，最好每次增加两个。需注意的是，增加节点会影响 ZooKeeper 的性能，因为每个节点上需要进行数据同步。


### 删除节点

当客户端连接并不多的时候您也可以在 ZooKeeper 详细页选中需要删除的节点，然后点“删除”按钮删除节点，以节省资源和费用。 同样，删除节点数只能为偶数，最好每次删除两个。


### 纵向伸缩

由于 ZooKeeper 的每个节点都有数据的全拷贝，并且数据都是要装载在内存里，所以当业务存放在 ZooKeeper 里的数据量增大到一定程度的时候， 不可避免需要纵向扩容每个节点的内存。反之，如果节点的 CPU、内存使用并不大，可以降低配置。值得注意的是，在缩小内存的时候选择新配置的内存不能过小， 否则 ZooKeeper 服务会启动不起来。ZooKeeper 内存使用率可以查看 ZooKeeper 详细页的监控图。在集群列表 ZooKeeper 所在栏右键选择「扩容」即可做纵向伸缩。
