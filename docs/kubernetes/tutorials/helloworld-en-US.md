# Deploy Helloworld Service on QingCloud Kubernetes

## Deployment

1. Deploy[Kuberntes cluster on QingCloud](../README-en-US.md). 
2. Make sure kubectl works on your local machine or log into the client node of the Kubernetes cluster. 
3. Create an EIP on QingCloud console. 

```shell
# git clone https://github.com/QingCloudAppcenter/kubernetes.git
# cd kubernetes/sample
# ./deploy-helloworld.sh -e eip-xxxxxxxx
```

Replace the eip id with the one you created. 

The result will be as follows. 

```shell
deployment "helloworld" created
service "helloworld" created
service "helloworld-internal" created
```

Check pods and services via kubectl 

```shell
# kubectl get pods -o wide
NAME                               READY     STATUS    RESTARTS   AGE       IP                NODE
helloworld-2920729173-57nwc        1/1       Running   0          37s       192.168.102.244   i-73baa3ue
helloworld-2920729173-sz05f        1/1       Running   0          37s       192.168.102.242   i-fqauml9r
```

```shell
# kubectl get service
NAME                  CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
helloworld            10.96.200.197   139.198.0.55    80:32689/TCP   2m
helloworld-internal   10.96.147.153   192.168.0.8     80:31128/TCP   2m
```

Open browser and access helloworld page through the IP address of loadbalancer (Note: If this loadbalancer is vxnet type, please enable VPN service and connect it through VPN client), or test it by command line as the following:  

```shell
# curl -H "accept: application/yaml" http://139.198.0.55/env
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

The output above if the environment variables of this pod. 

Note: helloworld service in this example uses probe program on server side written by go, for more source reference, please go to [go-probe](https://github.com/jolestar/go-probe). 

## Specification

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

Define Deployment of helloworld service at first, set replicas to 2, which means two Pods will be deployed, specify image pulling URL and port in container spec. 

Then define two Service, which type is LoadBalancer, set qingcloud-load-balancer-eip-ids to one of them and set nothing annotations for another one, a LoadBalancer with internet type will be created, the other one is vxnet type and use the vxnet where current cluster resides in. 

## Deletion

```shell
kubectl delete -f helloworld-web-deployment.yaml
```

## Note

1. If wordpress can't access by the IP of loadbalancer, please double check if your account is verified, if not, try to change port as work-around. 

