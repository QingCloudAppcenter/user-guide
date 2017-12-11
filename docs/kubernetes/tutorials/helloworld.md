# 在 QingCloud Kubernetes 上部署 Helloworld Service
{% include "../auto-i18n.md" %}
## 部署

1. 先在 QingCloud 上部署一套 Kubernetes 集群。
2. 配置好 kubectl 环境，或者直接登陆到客户端（client）节点上进行操作。
3. 准备好一个可用的公网 IP (EIP) 地址,复制 ID。这个eip为可用状态，创建服务时，程序会自动创建负载均衡器，并绑定这个IP，


```shell
git clone https://github.com/QingCloudAppcenter/kubernetes.git
cd kubernetes/sample
./deploy-helloworld.sh -e eip-xxx
```

将上面的参数中的 eip 替换成我们前面准备好的 ID。

执行后将输出：

```shell
deployment "helloworld" created
service "helloworld" created
service "helloworld-internal" created
```

通过 kubectl 查看 pod 以及 service

```shell
kubectl get pods -o wide
NAME                               READY     STATUS    RESTARTS   AGE       IP                NODE
helloworld-2920729173-57nwc        1/1       Running   0          37s       192.168.102.244   i-73baa3ue
helloworld-2920729173-sz05f        1/1       Running   0          37s       192.168.102.242   i-fqauml9r
```

```shell
kubectl get service
NAME                  CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
helloworld            10.96.200.197   139.198.0.55    80:32689/TCP   2m
helloworld-internal   10.96.147.153   192.168.0.8     80:31128/TCP   2m
```

输出结果中的 ID 以及 IP 地址根据您的环境不同会有变化。

我们通过浏览器打开负载均衡器 IP 地址（注意：如果是内网的负载均衡器，需要您通过 VPN 连接到 Kubernetes 所在的 VPC），或者通过命令行进行测试。

```shell
curl -H "accept: application/yaml" http://139.198.0.55/env
name: env
summary: ""
data:
  HELLOWORLD_INTERNAL_PORT: tcp://10.96.147.153:80
  HELLOWORLD_INTERNAL_PORT_80_TCP: tcp://10.96.147.153:80
  HELLOWORLD_INTERNAL_PORT_80_TCP_ADDR: 10.96.147.153
  HELLOWORLD_INTERNAL_PORT_80_TCP_PORT: "80"
  HELLOWORLD_INTERNAL_PORT_80_TCP_PROTO: tcp
  HELLOWORLD_INTERNAL_SERVICE_HOST: 10.96.147.153
  HELLOWORLD_INTERNAL_SERVICE_PORT: "80"
  HELLOWORLD_PORT: tcp://10.96.200.197:80
  HELLOWORLD_PORT_80_TCP: tcp://10.96.200.197:80
  HELLOWORLD_PORT_80_TCP_ADDR: 10.96.200.197
  HELLOWORLD_PORT_80_TCP_PORT: "80"
  HELLOWORLD_PORT_80_TCP_PROTO: tcp
  HELLOWORLD_SERVICE_HOST: 10.96.200.197
  HELLOWORLD_SERVICE_PORT: "80"
  HOME: /root
  HOSTNAME: helloworld-2920729173-sz05f
  KUBERNETES_PORT: tcp://10.96.0.1:443
  KUBERNETES_PORT_443_TCP: tcp://10.96.0.1:443
  KUBERNETES_PORT_443_TCP_ADDR: 10.96.0.1
  KUBERNETES_PORT_443_TCP_PORT: "443"
  KUBERNETES_PORT_443_TCP_PROTO: tcp
  KUBERNETES_SERVICE_HOST: 10.96.0.1
  KUBERNETES_SERVICE_PORT: "443"
  KUBERNETES_SERVICE_PORT_HTTPS: "443"
  PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

这个接口输出的是该 pod 的系统环境变量。

注：示例中的 helloworld service 用的是一个 go 的 server 端探针程序，支持的更多接口请参看 github 源码 [go-probe](https://github.com/jolestar/go-probe)。

## Spec 说明

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: helloworld
spec:
  replicas: 2
  template:
      metadata:
        labels:
          app: helloworld
      spec:
        containers:
          - name: web
            image: dockerhub.qingcloud.com/qingcloud/go-probe
            ports:
              - name: web
                containerPort: 80
                protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld
  annotations:
    service.beta.kubernetes.io/qingcloud-load-balancer-eip-ids: "${EIP}"
    service.beta.kubernetes.io/qingcloud-load-balancer-type: "0"
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: helloworld
  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld-internal
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: helloworld
  type: LoadBalancer
```

上例中的 helloworld service，首先定义了一个 Deployment，replicas 为 2，也就是部署后会有两个 pod 实例，container spec 中指定了 image 地址以及端口。

然后定义了两个 service，类型都是 LoadBalancer，不过一个指定了 qingcloud-load-balancer-eip-ids，另外一个没有配置 annotations，所以创建后一个会是公网类型的 LoadBalancer，另外一个会是默认的私网类型的 LoadBalancer，使用的是当前集群所在的私网。

## 删除

```shell
kubectl delete -f helloworld-web-deployment.yaml
```

## 常见问题

1. 如果部署后发现通过公网负载均衡器无法访问访问，请确认您的账号是否通过认证。这种情况可以先通过修改端口解决。

