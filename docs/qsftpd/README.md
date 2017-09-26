# qsftpd App 文档

qsftpd 是后端存储基于 QingStor 对象存储的 FTP 服务，qsftpd App 将 qsftpd 通过云应用的形式在 QingCloud AppCenter 部署，部署完成后，您可以将其视作一个 FTP 服务来使用。

## 准备工作

在创建 qsftpd App 之前，您需要进行如下准备工作：

- 创建或使用已有的 VPC 网络并连接一个私有网络。
- 创建或使用已有的 API 密钥对。
- 创建或使用已有的 QingStor 存储空间。

## 基础配置

当你部署 qsftpd 的实例时，你需要首先完成该 APP 的基础配置。基础配置页面会帮助你 完成部署主机的参数选择以及输入 qsftpd 所需要的运行参数。

配置项               | 配置内容
----------------- | -----------------------------------------------------------------------------------
Access Key ID     | 提供要使用的 access_key_id
Secret Access Key | 提供要使用的 secret_access_key
Bucket 名称         | 提供要使用的存储空间名称
区域                | 提供要使用的存储空间区域
监听地址              | 指定该服务要使用的监听地址，如果通过 VPN 在内网中使用，请填写内网 IP；如果通过 VPC 端口转发的方式的使用， 请填写 VPC 所绑定的公网 IP。
监听端口              | 指定该服务要使用的监听端口，无特殊需求使用默认值即可。
最大连接数             | 指定该服务的最大连接数，超过连接数的请求将会被拒绝，可根据实际需求进行调整。
开始端口              | 指定该服务开始端口，该服务将会随机分配开始端口之后的端口以进行数据传输。如果通过 VPC 端口转发的方式使用，请保证防火墙和对应端口的转发均已设置。
结束端口              | 指定该服务结束端口，该服务将会随机分配结束端口之前的端口以进行数据传输。如果通过 VPC 端口转发的方式使用，请保证防火墙和对应端口的转发均已设置。
FTP 用户            | 指定该服务的用户列表，默认只有 anonymous 用户。请严格按照 `username1:password1,username2:password2` 的格式输入。

## 使用说明

在部署了该应用之后，您可以使用如下两种方式来连接到 FTP 服务器：

- 使用 VPC 网络提供的 VPN 功能，使用 qsftpd 节点的内网 IP 来连接。通过此种方式连接无需配置防火墙规则，只需要连接 VPN 即可使用。
- 使用 VPC 网络提供的端口转发功能，使用 VPC 网络绑定的公网 IP 来连接。通过此种方式连接需要转发配置中使用的 `监听端口` 以及 `开始端口` 到 `结束端口` 所有端口，并在防火墙上打开这些端口。

您可以使用任意的 FTP 客户端通过 `被动模式` 来连接服务器，接下来以常用的 pftp 为例演示:

```bash
$ ftp -a 171.11.231.2
Connected to 171.11.231.2.
220 Welcome to QSFTP Server
331 User name okay, need password.
230 Password ok, continue
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||6081|)
150 Using transfer connection
d--------- 1 ftp ftp            0  Nov 30 00:00  test-output

226 Closing transfer connection
ftp> put AUTHORS
local: AUTHORS remote: AUTHORS
229 Entering Extended Passive Mode (|||6887|)
150 Using transfer connection
100% |***********************************|   146       91.68 KiB/s    00:00 ETA
226 Closing transfer connection
146 bytes sent in 00:00 (2.19 KiB/s)
ftp>
```
