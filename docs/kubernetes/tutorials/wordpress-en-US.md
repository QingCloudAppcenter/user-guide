# Deploy Wordpress on QingCloud Kubernetes  

{% include "../auto-i18n.md" %}

## Deployment

1. Deploy [Kuberntes cluster on QingCloud](../README-en-US.md). 
2. Make sure kubectl works on your local machine or log into the client node of the Kubernetes cluster. 
3. Create an EIP on QingCloud console. 

Then input the following commands.

```shell
# git clone https://github.com/QingCloudAppcenter/kubernetes.git
# cd kubernetes/sample
# ./deploy-wordpress.sh -e eip-xxx
```

Replace the eip id with the one you created. 

The result will be as follows.

```shell
secret "mysql-pass" created
service "wordpress" created
persistentvolumeclaim "wp-pv-claim" created
deployment "wordpress" created
service "wordpress-mysql" created
persistentvolumeclaim "mysql-pv-claim" created
deployment "wordpress-mysql" created
```

Check pods, services and pvc/pv via kubectl  

```shell
# kubectl get pods -o wide
NAME                               READY     STATUS    RESTARTS   AGE       IP                NODE
wordpress-830495761-x543l          1/1       Running   0          4m        192.168.102.244   i-fqauml9r
wordpress-mysql-2605002378-0z72m   1/1       Running   0          4m        192.168.102.242   i-73baa3ue
```

```shell
# kubectl get service
NAME              CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
kubernetes        10.96.0.1       <none>          443/TCP        1d
wordpress         10.96.238.129   139.198.1.119   80:31795/TCP   5m
wordpress-mysql   None            <none>          3306/TCP       5m
```

```shell
# kubectl get pvc
NAME             STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
mysql-pv-claim   Bound     pvc-a7cea533-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           5m
wp-pv-claim      Bound     pvc-a7a4b6ba-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           5m
```

```shell
# kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                    REASON    AGE
pvc-a7a4b6ba-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           Delete          Bound     default/wp-pv-claim                6m
pvc-a7cea533-7271-11e7-b1c4-5254e5dd6c2d   20Gi       RWO           Delete          Bound     default/mysql-pv-claim             6m
```

Open browser and access wordpress page through the IP address of loadbalancer. 

## Specification

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

In this example, first define a service with type being LoadBalancer, and configure it with qingcloud-load-balancer-eip-ids. 

Then define PersistentVolumeClaim and Deployment of wordpress. The image pulling URL of wordpress and environment variables HOST/PASSWORD for mysql are also specified. 

As wordpress depends on mysql，we also need to define Service, PersistentVolumeClaim and Deployment for mysql. Mysql requires initial password when creating, which is generated by the script in above example and saved as secret on Kubernetes by running _kubectl create secret_. 

## Deletion

```shell
# kubectl delete -f wordpress-deployment.yaml
# kubectl delete secret/mysql-pass
```

## Note

* If the service can't be accessed by the IP of loadbalancer, please double check if your account is verified. If not, try to change port other than 80 as a temporary solution.
