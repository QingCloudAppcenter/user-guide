# 在 QingCloud Kubernetes 上部署 Wordpress

{% include "../auto-i18n.md" %}

## 部署

1. 先在 QingCloud 上部署一套 Kubernetes 集群。
2. 配置好 kubectl 环境，或者直接登陆到客户端（client）节点上进行操作。
3. 准备好一个可用的公网  IP (EIP) 地址，并复制 ID。这个eip为可用状态，创建服务时，程序会自动创建负载均衡器，并绑定这个IP。

```shell
git clone https://github.com/QingCloudAppcenter/kubernetes.git
cd kubernetes/sample
./deploy-wordpress.sh -e eip-xxx
```

将上面的参数中的 eip 替换成我们前面准备好的 ID。

执行后将输出：

```shell
secret "mysql-pass" created
service "wordpress" created
persistentvolumeclaim "wp-pv-claim" created
deployment "wordpress" created
service "wordpress-mysql" created
persistentvolumeclaim "mysql-pv-claim" created
deployment "wordpress-mysql" created
```

通过 kubectl 查看 pod，service 以及 pvc/pv

```shell
kubectl get pods -o wide
NAME                               READY     STATUS    RESTARTS   AGE       IP                NODE
wordpress-830495761-x543l          1/1       Running   0          4m        192.168.102.244   i-fqauml9r
wordpress-mysql-2605002378-0z72m   1/1       Running   0          4m        192.168.102.242   i-73baa3ue
```

```shell
kubectl get service
NAME              CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
kubernetes        10.96.0.1       <none>          443/TCP        1d
wordpress         10.96.238.129   139.198.1.119   80:31795/TCP   5m
wordpress-mysql   None            <none>          3306/TCP       5m
```

```shell
kubectl get pvc
NAME             STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
mysql-pv-claim   Bound     pvc-a7cea533-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           5m
wp-pv-claim      Bound     pvc-a7a4b6ba-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           5m
```

```shell
kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                    REASON    AGE
pvc-a7a4b6ba-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           Delete          Bound     default/wp-pv-claim                6m
pvc-a7cea533-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           Delete          Bound     default/mysql-pv-claim             6m
```

输出结果中的 ID 以及 IP 地址根据您的环境不同会有变化。

然后通过浏览器打开负载均衡器 IP 地址，进入 wordpress 安装界面进行操作。

## Spec 说明

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  annotations:
      service.beta.kubernetes.io/qingcloud-load-balancer-eip-ids: "${EIP}"
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
#  annotations:
#      volume.beta.kubernetes.io/storage-class: qingcloud-storageclass
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: dockerhub.qingcloud.com/wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password.txt
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
#  annotations:
#      volume.beta.kubernetes.io/storage-class: qingcloud-storageclass
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: dockerhub.qingcloud.com/mysql:5.6
        name: mysql
        env:
          # $ kubectl create secret generic mysql-pass --from-file=password.txt
          # make sure password.txt does not have a trailing newline
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password.txt
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

上例中的 wordpress，首先定义了一个 Service，类型是 LoadBalancer，并且指定了 qingcloud-load-balancer-eip-ids。

然后定义了 wordpress 的 PersistentVolumeClaim 以及 Deployment。Deployment 中设置了 wordpress 的镜像地址以及依赖的 mysql 的 HOST 以及 PASSWORD 环境变量。

由于 wordpress 依赖 mysql，后面的部分定义了 mysql 的 Service，PersistentVolumeClaim，Deployment。mysql 创建的时候需要依赖一个初始化密码，这个密码是通过前面例子中的安装脚本自动生成，并通过 kubectl create secret 在 Kubernetes 上创建了一个 secret。

## 删除

```shell
kubectl delete -f wordpress-deployment.yaml
kubectl delete secret/mysql-pass
```

## 常见问题

1. 如果部署后发现通过公网负载均衡器无法访问访问，请确认您的账号是否通过认证。这种情况可以先通过修改端口解决。
