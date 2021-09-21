# chudinanton_platform
chudinanton Platform repository
<details>
<summary> <b>ДЗ №9 - kubernetes-monitoring (Сервисы централизованного логирования для компонентов Kubernetes и приложений)</b></summary>

- [x] Основное ДЗ

- [x] Все дополнительные задания *

- [x] Все необязательные и самостоятельные задания

<details>
<summary> <b>Создаем кластер k8s в gcp через Terraform</b></summary>

Создаем кластер gcp через Terraform. Потребуется ранее установленный gke и непосредственно сам Terraform

https://www.terraform.io/downloads.html


> Авторизация будет проходить через сервис аккаунт, созданный ранее в задании kubernetes-templating/Подключаем GCP KMS | Необязательное задание


Не забываем выдать сервис аккаунту нужные права в 

https://console.cloud.google.com/iam-admin/serviceaccounts

```console
gcloud --version                                                       
Google Cloud SDK 357.0.0
bq 2.0.71
core 2021.09.10
gsutil 4.67

terraform version                                                      
Terraform v1.0.7
on darwin_amd64
```

Актуальная дока:

https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

Дока по гугловым модулям:

https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest

https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/14.2.0/submodules/auth

И крутой МАН:

https://learnk8s.io/terraform-gke

Создаем папку kubernetes-logging/terraform и инициализируем внутри нее проект

Создаем три файла:

```console
main.tf - основной код
output.tf - что хотим вывести
variables.tf - переменные
```

Копируем и кастомизируем код и переменные. Чуть подправил провайдера т.к. был ворнинг:
```console
Warning: Version constraints inside provider configuration blocks are deprecated
```

```yml
provider "google" {
  project = var.project_id
}
```

Ошибку существования default_pool решаем так:

```yml
  remove_default_node_pool = true
```

Отключение мониторинга и логгирования так:

```yml
  monitoring_service       = var.monitoring_service 
  logging_service          = var.logging_service
```

Кастомизируем:
```yml
project_id
cluster_name
region
```

Инициализируем:

```console
terraform init
Initializing modules...
Downloading terraform-google-modules/network/google 2.6.0 for gcp-network...
- gcp-network in .terraform/modules/gcp-network
- gcp-network.routes in .terraform/modules/gcp-network/modules/routes
- gcp-network.subnets in .terraform/modules/gcp-network/modules/subnets
- gcp-network.vpc in .terraform/modules/gcp-network/modules/vpc
Downloading terraform-google-modules/kubernetes-engine/google 16.1.0 for gke...
- gke in .terraform/modules/gke/modules/private-cluster
Downloading terraform-google-modules/gcloud/google 2.1.0 for gke.gcloud_delete_default_kube_dns_configmap...
- gke.gcloud_delete_default_kube_dns_configmap in .terraform/modules/gke.gcloud_delete_default_kube_dns_configmap/modules/kubectl-wrapper
- gke.gcloud_delete_default_kube_dns_configmap.gcloud_kubectl in .terraform/modules/gke.gcloud_delete_default_kube_dns_configmap
Downloading terraform-google-modules/kubernetes-engine/google 16.1.0 for gke_auth...
- gke_auth in .terraform/modules/gke_auth/modules/auth

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/external...
- Finding latest version of hashicorp/template...
- Finding latest version of hashicorp/local...
- Finding hashicorp/google versions matching ">= 2.12.0, >= 3.39.0, < 4.0.0"...
- Finding hashicorp/kubernetes versions matching "~> 2.0"...
- Installing hashicorp/external v2.1.0...
- Installed hashicorp/external v2.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing hashicorp/local v2.1.0...
- Installed hashicorp/local v2.1.0 (signed by HashiCorp)
- Installing hashicorp/google v3.84.0...
- Installed hashicorp/google v3.84.0 (signed by HashiCorp)
- Installing hashicorp/kubernetes v2.5.0...
- Installed hashicorp/kubernetes v2.5.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/null v3.1.0...
- Installed hashicorp/null v3.1.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Проверяем:

```console
terraform validate
Success! The configuration is valid.
terraform plan
...
```

Поэкспериментировал с terraform.tfvars. # TODO: Надо будет обернуть потом в модули все это.

Ну и раскатываем:

```console
terraform apply -auto-approve=true
```

Объединяем конфиги:

```console
cp ~/.kube/config ~/.kube/config.bak && KUBECONFIG=~/.kube/config:~/.kube/conf.d/config-gcp-cluster-prod kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config
```

Проверяем:

```console
k config use-context gcp-cluster-prod
kg nodes -o wide
NAME                                              STATUS   ROLES    AGE   VERSION            INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-gcp-cluster-prod-default-pool-fa81dbe2-1l3m   Ready    <none>   49m   v1.20.10-gke.301   10.10.0.3     34.141.59.249   Container-Optimized OS from Google   5.4.120+         docker://20.10.3
gke-gcp-cluster-prod-default-pool-fa81dbe2-whrh   Ready    <none>   49m   v1.20.10-gke.301   10.10.0.2     34.89.236.114   Container-Optimized OS from Google   5.4.120+         docker://20.10.3
```

Кластер развернут. Но по условию нам нужен второй пул infra-pool с тремя нодами и tain node-role=infra:NoSchedule

Добавляем в main.tf:

```yml
      name                      = var.node_pools_2
      machine_type              = var.machine_type_node_pools_2
      node_locations            = var.node_pools_2_node_locations
      min_count                 = var.node_pools_2_min_count_nodes
      max_count                 = var.node_pools_2_max_count_nodes
      disk_size_gb              = var.node_pools_2_disk_size_gb
   },
  ]
  node_pools_taints = {
    infra-pool = [
      {
        key    = "node-role"
        value  = "infra"
        effect = "NO_SCHEDULE"
      }
    ]
  }
```

Проверям и раскатываем

```console
terraform validate
terraform plan
terraform apply -auto-approve=true
</pre>

Смотрим что получилось:

```console
kg nodes -o wide
NAME                                              STATUS   ROLES    AGE     VERSION            INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-gcp-cluster-prod-default-pool-46899ffe-jncm   Ready    <none>   4m58s   v1.20.10-gke.301   10.10.0.3     34.141.64.71     Container-Optimized OS from Google   5.4.120+         docker://20.10.3
gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   Ready    <none>   5m      v1.20.10-gke.301   10.10.0.2     34.89.236.114    Container-Optimized OS from Google   5.4.120+         docker://20.10.3
gke-gcp-cluster-prod-infra-pool-607b4813-flcf     Ready    <none>   3m33s   v1.20.10-gke.301   10.10.0.4     34.107.86.246    Container-Optimized OS from Google   5.4.120+         docker://20.10.3
gke-gcp-cluster-prod-infra-pool-607b4813-nc9v     Ready    <none>   3m35s   v1.20.10-gke.301   10.10.0.5     34.107.120.254   Container-Optimized OS from Google   5.4.120+         docker://20.10.3
gke-gcp-cluster-prod-infra-pool-607b4813-rt6f     Ready    <none>   3m35s   v1.20.10-gke.301   10.10.0.6     35.242.222.132   Container-Optimized OS from Google   5.4.120+         docker://20.10.3

kd nodes gke-gcp-cluster-prod-infra-pool-607b4813-rt6f | grep Taint
Taints:             node-role=infra:NoSchedule
```

Обращаем внимание, что Cloud Logging и Cloud Monitoring отключены.

### Установка nginx-ingress и cert-manager из helmfile

Я сразу вкачу nginx-ingress и cert-manager из helmfile.yaml

```console
helmfile sync

kg all -n cert-manager -o wide
NAME                                           READY   STATUS    RESTARTS   AGE     IP           NODE                                              NOMINATED NODE   READINESS GATES
pod/cert-manager-66b6d6bf59-f4xr7              1/1     Running   0          6m40s   10.20.5.83   gke-gcp-cluster-prod-default-pool-46899ffe-qpw7   <none>           <none>
pod/cert-manager-cainjector-856d4df858-6b9s7   1/1     Running   0          6m40s   10.20.5.82   gke-gcp-cluster-prod-default-pool-46899ffe-qpw7   <none>           <none>
pod/cert-manager-webhook-6d866ffbc7-sfgks      1/1     Running   0          6m40s   10.20.5.81   gke-gcp-cluster-prod-default-pool-46899ffe-qpw7   <none>           <none>

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE     SELECTOR
service/cert-manager           ClusterIP   10.30.129.212   <none>        9402/TCP   6m41s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cert-manager
service/cert-manager-webhook   ClusterIP   10.30.26.202    <none>        443/TCP    6m41s   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=webhook

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS     IMAGES                                            SELECTOR
deployment.apps/cert-manager              1/1     1            1           6m41s   cert-manager   quay.io/jetstack/cert-manager-controller:v1.5.3   app.kubernetes.io/component=controller,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cert-manager
deployment.apps/cert-manager-cainjector   1/1     1            1           6m41s   cert-manager   quay.io/jetstack/cert-manager-cainjector:v1.5.3   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cainjector
deployment.apps/cert-manager-webhook      1/1     1            1           6m41s   cert-manager   quay.io/jetstack/cert-manager-webhook:v1.5.3      app.kubernetes.io/component=webhook,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=webhook

NAME                                                 DESIRED   CURRENT   READY   AGE     CONTAINERS     IMAGES                                            SELECTOR
replicaset.apps/cert-manager-66b6d6bf59              1         1         1       6m41s   cert-manager   quay.io/jetstack/cert-manager-controller:v1.5.3   app.kubernetes.io/component=controller,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cert-manager,pod-template-hash=66b6d6bf59
replicaset.apps/cert-manager-cainjector-856d4df858   1         1         1       6m41s   cert-manager   quay.io/jetstack/cert-manager-cainjector:v1.5.3   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cainjector,pod-template-hash=856d4df858
replicaset.apps/cert-manager-webhook-6d866ffbc7      1         1         1       6m41s   cert-manager   quay.io/jetstack/cert-manager-webhook:v1.5.3      app.kubernetes.io/component=webhook,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=webhook,pod-template-hash=6d866ffbc7

kg all -n ingress-nginx -o wide
NAME                                            READY   STATUS    RESTARTS   AGE     IP           NODE                                            NOMINATED NODE   READINESS GATES
pod/ingress-nginx-controller-586f7795dd-bjtrw   1/1     Running   0          8m55s   10.20.4.19   gke-gcp-cluster-prod-infra-pool-607b4813-rt6f   <none>           <none>
pod/ingress-nginx-controller-586f7795dd-l268v   1/1     Running   0          8m55s   10.20.3.22   gke-gcp-cluster-prod-infra-pool-607b4813-flcf   <none>           <none>
pod/ingress-nginx-controller-586f7795dd-sqqql   1/1     Running   0          8m55s   10.20.2.21   gke-gcp-cluster-prod-infra-pool-607b4813-nc9v   <none>           <none>

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE     SELECTOR
service/ingress-nginx-controller             LoadBalancer   10.30.118.142   34.141.115.199   80:32018/TCP,443:32593/TCP   8m56s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
service/ingress-nginx-controller-admission   ClusterIP      10.30.149.52    <none>           443/TCP                      8m57s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
service/ingress-nginx-controller-metrics     ClusterIP      10.30.198.189   <none>           10254/TCP                    8m57s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                                                                                                               SELECTOR
deployment.apps/ingress-nginx-controller   3/3     3            3           8m57s   controller   k8s.gcr.io/ingress-nginx/controller:v1.0.0@sha256:0851b34f69f69352bf168e6ccf30e1e20714a264ab1ecd1933e4d8c0fc3215c6   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx

NAME                                                  DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                                                                                                               SELECTOR
replicaset.apps/ingress-nginx-controller-586f7795dd   3         3         3       8m57s   controller   k8s.gcr.io/ingress-nginx/controller:v1.0.0@sha256:0851b34f69f69352bf168e6ccf30e1e20714a264ab1ecd1933e4d8c0fc3215c6   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx,pod-template-hash=586f7795dd

```

Обращаем внимание, что поды стартовали на infra-pool нодах.

### Установка HipsterShop

Для начала, установим в Kubernetes кластер уже знакомый нам HipsterShop.

```console
kubectl create ns microservices-demo
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo
```

Проверяем, что все раскатилось на default-pool нодах:

```console
kubectl get pods -n microservices-demo -o wide                                          ✹ ✭kubernetes-monitoring 
NAME                                     READY   STATUS    RESTARTS   AGE     IP           NODE                                              NOMINATED NODE   READINESS GATES
adservice-56d56d89cc-wfg5d               1/1     Running   0          23h   10.20.1.14   gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
cartservice-c8b9fc586-fx7w7              1/1     Running   1          23h   10.20.0.16   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
checkoutservice-74f4c5464f-9xl96         1/1     Running   0          23h   10.20.1.9    gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
currencyservice-7df4d74b7c-wzmfh         1/1     Running   0          23h   10.20.0.17   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
emailservice-86794489df-nmjc8            1/1     Running   0          23h   10.20.0.13   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
frontend-cf49f7975-k4bmw                 1/1     Running   0          23h   10.20.1.10   gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
loadgenerator-7fdb874b-djzxl             1/1     Running   4          23h   10.20.1.12   gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
paymentservice-5768d9bb67-hrvbz          1/1     Running   0          23h   10.20.0.15   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
productcatalogservice-84fd74ccc9-vrmz4   1/1     Running   0          23h   10.20.1.11   gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
recommendationservice-6fcb597467-z4fkx   1/1     Running   0          23h   10.20.0.14   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
redis-cart-55d76945cb-fwflm              1/1     Running   0          23h   10.20.0.18   gke-gcp-cluster-prod-default-pool-46899ffe-m0b9   <none>           <none>
shippingservice-6bc75ffff-lsg92          1/1     Running   0          23h   10.20.1.13   gke-gcp-cluster-prod-default-pool-46899ffe-jncm   <none>           <none>
```

</details>

<details>
<summary> <b>Установка EFK стека</b></summary>

### Установка EFK стека | Helm charts

Я не буду издеваться над кластером и установлю сразу через tolerations и nodeSelector

```console
helm repo add elastic https://helm.elastic.co
kubectl create ns observability

# ElasticSearch
helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability -f elasticsearch.values.yaml
# Kibana
helm upgrade --install kibana elastic/kibana --namespace observability
# Fluent Bit DEPRECATED
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability

```

### Установка EFK стека | Kibana

Кибану зарулим через https

```console
helm upgrade --install kibana elastic/kibana --namespace observability -f kibana.values.yaml
```

values взяты из чарта.

Проверяем доступность:

https://kibana.yogatour.su/

### Установка EFK стека

Создаем fluent-bit.values.yaml натравливаем его на наш эластик и обновляем.

```console
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f fluent-bit.values.yaml
```

После установки можно заметить, что в ElasticSearch попадают далеко не все логи нашего приложения. Причину можно найти в логах pod с Fluent Bit, он пытается обработать JSON, отдаваемый приложением, и находит там дублирующиеся поля time и timestamp 

> GitHub [issue](https://github.com/fluent/fluent-bit/issues/628), с более подробным описанием проблемы


Решаем проблему удалением двух полей:

```yml
rawConfig: |
  @INCLUDE fluent-bit-service.conf
  @INCLUDE fluent-bit-input.conf
  @INCLUDE fluent-bit-filter.conf
  @INCLUDE fluent-bit-output.conf

  [FILTER]
      Name modify
      Match *
      Remove time
      Remove @timestamp
```

Применяем:

```console
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f fluent-bit.values.yaml
```


</details>

<details>
<summary> <b> Установка EFK стека | Задание со ⭐  </b></summary>

Решение есть по ссылке в самом ДЗ:

> https://github.com/fluent/fluent-bit/issues/628#issuecomment-592489560

> https://bk0010-01.blogspot.com/2020/03/fluent-bit-and-kibana-in-kubernetes.html

> https://github.com/Vfialkin/vf-observability/blob/master/fluentbit/fluent-bit-dev.yaml


```yml
extraEntries:
  filter: |-
    Keep_Log  off

filter:
  mergeJSONLog: true
  mergeLogKey: "app"

input:
  tail:
    path: /var/log/containers/*.log
    ignore_older: 1h
    exclude_path: /var/log/containers/kibana*.log,/var/log/containers/kube*.log,/var/log/containers/etcd-*.log,/var/log/containers/dashboard-metrics*.log
```

Исключены логи самой кибаны, дашборда и куба. Мы хотим получать логи нашего приложения, насколько я понял само задание.

После обновления чарта fluent-bit проблем больше нет :) Нет "лишних" логов - нет проблемы :)
Остались логи приложухи. В этом можно убедиться потыкая UI hipster-shop'а.


```console
kl pod/fluent-bit-wzh8j -n observability
Fluent Bit v1.3.7
Copyright (C) Treasure Data

[2021/09/19 21:19:19] [ info] [storage] initializing...
[2021/09/19 21:19:19] [ info] [storage] in-memory
[2021/09/19 21:19:19] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/09/19 21:19:19] [ info] [engine] started (pid=1)
[2021/09/19 21:19:19] [ info] [filter_kube] https=1 host=kubernetes.default.svc port=443
[2021/09/19 21:19:19] [ info] [filter_kube] local POD info OK
[2021/09/19 21:19:19] [ info] [filter_kube] testing connectivity with API server...
[2021/09/19 21:19:19] [ info] [filter_kube] API server connectivity OK
[2021/09/19 21:19:19] [ info] [sp] stream processor started
```
</details>

<details>
<summary> <b>Мониторинг ElasticSearch</b></summary>

Добавил игрессы + ssl для prometheus и grafana. prometheus разворачивается с tolerations и nodeSelector.

<b>Prometheus разворачиваем из нового чарта kube-prometheus-stack! prometheus-community/prometheus-operator устарел и DEPRECATED!</b>

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n observability -f kube-prometheus-stack/values.yaml

```

Если не поставить это, то prometheus будет искать сервис мониторы только "selectors based on values in the helm deployment"

```yaml
serviceMonitorSelectorNilUsesHelmValues: false
```

Проверяем доступность:

```
https://grafana.yogatour.su/
https://prometheus.yogatour.su/

```

<b>Установим prometheus exporter из prometheus-community. stable/elasticsearch-exporter DEPRECATED!</b>

```console
helm upgrade --install elasticsearch-exporter prometheus-community/prometheus-elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true --namespace=observability
```

Актуальный дашборд для графаны:

> https://github.com/prometheus-community/elasticsearch_exporter/blob/master/examples/grafana/dashboard.json

> https://grafana.com/grafana/dashboards/4358

Рассмотрим некоторое количество ключевых метрик, которые рекомендуется отслеживать при эксплуатации ElasticSearch:

- unassigned_shards - количество shard, для которых не нашлось подходящей ноды, их наличие сигнализирует о проблемах
- jvm_memory_usage - высокая загрузка (в процентах от выделенной памяти) может привести к замедлению работы кластера
- number_of_pending_tasks - количество задач, ожидающих выполнения. Значение метрики, отличное от нуля, может сигнализировать о наличии проблем внутри кластера

> Больше метрик с их описанием можно найти [здесь](https://habr.com/ru/company/yamoney/blog/358550/)

</details>

<details>
<summary> <b>EFK | nginx ingress</b></summary>

Чтобы логи nginx попали в эластик, надо запустить fluent-bit на infra-pool

```yaml
tolerations:
  - key: node-role
    operator: Equal
    value: infra
    effect: NoSchedule
```

Перезапуск:

```console
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f fluent-bit.values.yaml
```

Логи пошли. Но нужно их распарсить.


Устанавливаем формат логов и описываем их формат.

Дока для оф. чарта от Nginx Inc (я пробовал разворачивать два разных ingress):

https://github.com/nginxinc/kubernetes-ingress/tree/v1.12.1/examples/custom-log-format

https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource#logging



```yaml
  config:
    ## The name of the ConfigMap used by the Ingress controller.
    ## Autogenerated if not set or set to "".
     name: nginx-config

    ## The annotations of the Ingress Controller configmap.
     annotations: {}

    ## The entries of the ConfigMap for customizing NGINX configuration.
     entries:
      log-format: >-
        { "remote_addr": "$proxy_protocol_addr", "x-forward-for":
        "$proxy_add_x_forwarded_for", "remote_user": "$remote_user", "bytes_sent":
        $bytes_sent, "request_time": $request_time, "status":$status, "vhost":  
        "$host", "request_proto": "$server_protocol", "path": "$uri",
        "request_query": "$args", "request_length": $request_length, "duration":
        $request_time,"method": "$request_method", "http_referrer": "$http_referer",
        "http_user_agent": "$http_user_agent" }
      log-format-escaping: json
```

Дока по ingress-nginx от куба

https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#log-format-upstream

Для ingress-nginx от куба правильно будет так:

```yaml
  config:
    name: nginx-config

    log-format-escape-json: "true"
    log-format-upstream: '{"remote_addr": "$proxy_protocol_addr", "x-forward-for": "$proxy_add_x_forwarded_for", "request_id": "$req_id", "remote_user": "$remote_user", "bytes_sent": $bytes_sent, "request_time": $request_time, "status":$status, "vhost": "$host", "request_proto": "$server_protocol", "path": "$uri", "request_query": "$args", "request_length": $request_length, "duration": $request_time,"method": "$request_method", "http_referrer": "$http_referer", "http_user_agent": "$http_user_agent" }'
```

Проверяем в kibana, что логи теперь идут в json формате и разбиваются по полям:

```log
  "_source": {
    "@timestamp": "2021-09-20T09:49:47.708Z",
    "stream": "stdout",
    "time": "2021-09-20T09:49:47.708788242Z",
    "app": {
      "remote_addr": "",
      "x-forward-for": "87.228.103.130",
      "remote_user": "",
      "bytes_sent": 710,
      "request_time": 0,
      "status": 404,
      "vhost": "34.141.59.249",
      "request_proto": "HTTP/1.1",
      "path": "/",
      "request_query": "",
      "request_length": 492,
      "duration": 0,
      "method": "GET",
      "http_referrer": "",
      "http_user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"
    },
```

Поигрался с дашбордом и Visualizes
Выгрузил export.ndjson.

</details>

<details>
<summary> <b>Loki</b></summary>

- Установим Loki из актуально helm чарта grafana/loki-stack!
- Модифицируем prometheus чтобы datasource Loki создавался вместе с prometheus
- Отправляем логи в prometheus из ingress-nginx

Актуальный ман по установке Loki:

https://grafana.com/docs/loki/latest/installation/helm/

```console
helm repo add grafana https://grafana.github.io/helm-charts

helm upgrade --install loki grafana/loki-stack -n observability -f loki.values.yaml

```

Не забываем про tolerations node-role

Добавляем в kube-prometheus-stack/values.yaml Loki datasource.

```yml
  additionalDataSources:
    - name: Loki
      type: loki
      url: http://loki:3100/
      access: proxy
```

И обновляем наш prometheus-stack:

```console
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n observability -f kube-prometheus-stack/values.yaml
```

Смотрим в Grafana появился ли Loki datasource.

Добавляем в nginx-ingress.values.yaml включение метрик для prometheus

Дока:

https://github.com/nginxinc/kubernetes-ingress/tree/master/deployments/helm-chart#configuration

```yml
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      namespace: observability

```

Применяем:

```console
helmfile sync
```

nginx-ingress начинает отдавать метрики в Prometheus format на 9113 порту.

Все, после этого prometheus начинает видеть наши ингрессы.

### Loki | Визуализация

- Добавляем вывод логов в Графана.
- Делаем необходимый дашборд и выгружаем его в nginx-ingress.json


### Event logging | k8s-event-logger

https://github.com/max-rocket-internet/k8s-event-logger

Позволяет получить и сохранить event'ы Kubernetes 

</details>

<details>
<summary> <b>Audit logging/Host logging | 2 Задания со ⭐</b></summary>

Документация.

Дано, self-hosted кластер на kind

```yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
networking:
  kubeProxyMode: "ipvs"
```

```console
kind create cluster --config
kg nodes -o wide
NAME                  STATUS   ROLES                  AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION     CONTAINER-RUNTIME
kind-control-plane    Ready    control-plane,master   5m17s   v1.21.1   172.18.0.5    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
kind-control-plane2   Ready    control-plane,master   4m31s   v1.21.1   172.18.0.7    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
kind-control-plane3   Ready    control-plane,master   3m35s   v1.21.1   172.18.0.8    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
kind-worker           Ready    <none>                 3m13s   v1.21.1   172.18.0.3    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
kind-worker2          Ready    <none>                 3m13s   v1.21.1   172.18.0.6    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
kind-worker3          Ready    <none>                 3m12s   v1.21.1   172.18.0.4    <none>        Ubuntu 21.04   5.10.47-linuxkit   containerd://1.5.2
```  

Задача: настроить сбор аудит логов и их отправку в elastic.

Все артифакты сохраним в audit-logging папке.

Разворачиваем EFK стек:

```console
kubectl create ns observability
helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability
helm upgrade --install kibana elastic/kibana --namespace observability
```

В старом helm чарте есть такое:

```yml

audit:
  enable: false
  input:
    memBufLimit: 35MB
    parser: docker
    tag: audit.*
    path: /var/log/kube-apiserver-audit.log
    bufferChunkSize: 2MB
    bufferMaxSize: 10MB
    skipLongLines: On
    key: kubernetes-audit

</details>
```

Используем эту секцию. В новом чарте иначе, нужно это учитывать.

Минимальная политика с выводом всего из документации:

"Вы можете использовать минимальный файл политики аудита для регистрации всех запросов на Metadata уровне:

```yml
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
```

Теперь нужно передать на все ноды. Придется это сделать с хостовой машины тк у нас kind. Я опубликую все в рабочей папке для наглядности.

```
    - --audit-policy-file=/etc/kubernetes/audit-policies/audit-policy.yaml
    - --audit-log-path=/var/log/audit/kube-apiserver-audit.log
    - --audit-log-format=json
```

Я сделаю только на одной ноде для примера. Гемор.

```
vim /etc/kubernetes/manifests/kube-apiserver.yaml

```
    volumeMounts:
    - mountPath: /etc/kubernetes/
      name: audit-logging-policies
      readOnly: true
    - mountPath: /var/log/audit
      name: audit-logs
      readOnly: false

  volumes:
  - hostPath:
      path: /etc/kubernetes/audit-policies
      type: DirectoryOrCreate
    name: audit-logging-policies
  - hostPath:
      path: /var/log/audit
      type: DirectoryOrCreate
    name: audit-logs
```

Не забываем про для fluent-bit

```yml
tolerations:
  - key: node-role.kubernetes.io/master
    operator: Equal
    value: 
    effect: NoSchedule
```

helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f fluent-bit.values.yaml

Поперло, смотрим в кибане:

```json
{
  "_index": "kubernetes_cluster-2021.09.21",
  "_type": "flb_type",
  "_id": "nJHvB3wBUDsBltizgDTy",
  "_score": 1,
  "_source": {
    "@timestamp": "2021-09-21T10:38:28.886Z",
    "kind": "Event",
    "apiVersion": "audit.k8s.io/v1",
    "level": "Metadata",
    "auditID": "b1412414-6161-48ca-b16c-f882f115233a",
    "stage": "ResponseComplete",
    "requestURI": "/readyz",
    "verb": "get",
    "user": {
      "username": "system:anonymous",
      "groups": [
        "system:unauthenticated"
      ]
    },
    "sourceIPs": [
      "172.18.0.5"
    ],
    "userAgent": "kube-probe/1.21",
    "responseStatus": {
      "metadata": {},
      "code": 200
    },
    "requestReceivedTimestamp": "2021-09-21T10:38:28.817094Z",
    "stageTimestamp": "2021-09-21T10:38:28.837455Z",
    "annotations": {
      "authorization_k8s_io/decision": "allow",
      "authorization_k8s_io/reason": "RBAC: allowed by ClusterRoleBinding \"system:public-info-viewer\" of ClusterRole \"system:public-info-viewer\" to Group \"system:unauthenticated\""
    }
  },
  "fields": {
    "sourceIPs.keyword": [
      "172.18.0.5"
    ],
    "stage.keyword": [
      "ResponseComplete"
    ],
    "user.username.keyword": [
      "system:anonymous"
    ],
    "auditID.keyword": [
      "b1412414-6161-48ca-b16c-f882f115233a"
    ],
    "userAgent.keyword": [
      "kube-probe/1.21"
    ],
    "user.username": [
      "system:anonymous"
    ],
    "kind.keyword": [
      "Event"
    ],
    "annotations.authorization_k8s_io/decision": [
      "allow"
    ],
    "apiVersion": [
      "audit.k8s.io/v1"
    ],
    "apiVersion.keyword": [
      "audit.k8s.io/v1"
    ],
    "requestReceivedTimestamp": [
      "2021-09-21T10:38:28.817Z"
    ],
    "auditID": [
      "b1412414-6161-48ca-b16c-f882f115233a"
    ],
    "level": [
      "Metadata"
    ],
    "annotations.authorization_k8s_io/reason": [
      "RBAC: allowed by ClusterRoleBinding \"system:public-info-viewer\" of ClusterRole \"system:public-info-viewer\" to Group \"system:unauthenticated\""
    ],
    "kind": [
      "Event"
    ],
    "verb": [
      "get"
    ],
    "annotations.authorization_k8s_io/reason.keyword": [
      "RBAC: allowed by ClusterRoleBinding \"system:public-info-viewer\" of ClusterRole \"system:public-info-viewer\" to Group \"system:unauthenticated\""
    ],
    "responseStatus.code": [
      200
    ],
    "userAgent": [
      "kube-probe/1.21"
    ],
    "requestURI": [
      "/readyz"
    ],
    "user.groups.keyword": [
      "system:unauthenticated"
    ],
    "stageTimestamp": [
      "2021-09-21T10:38:28.837Z"
    ],
    "user.groups": [
      "system:unauthenticated"
    ],
    "sourceIPs": [
      "172.18.0.5"
    ],
    "@timestamp": [
      "2021-09-21T10:38:28.886Z"
    ],
    "stage": [
      "ResponseComplete"
    ],
    "verb.keyword": [
      "get"
    ],
    "level.keyword": [
      "Metadata"
    ],
    "annotations.authorization_k8s_io/decision.keyword": [
      "allow"
    ],
    "requestURI.keyword": [
      "/readyz"
    ]
  }
}
```
</details>



<details>
<summary> <b>Установка nginx-ingress | Самостоятельное задание</b></summary>

C helmfile я потопропился :) Модифицируем его:

```yml
    values:
      - ./nginx-ingress.values.yaml
```

values взял из stable helm chart

Проверяем доступность:

https://kibana.yogatour.su/

</details>

</details>

<details>
<summary> <b>ДЗ №8 - kubernetes-monitoring (Мониторинг сервиса в кластере k8s)</b></summary>

- [x] Основное ДЗ

<details>
<summary> <b>Основное задание</b></summary>

Ставим prometheus-operator через Helm3

Документация:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#configuration

<pre>
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create ns monitoring
helm upgrade --install prometheus-operator prometheus-community/prometheus-operator -n monitoring

kg deployments,rs,po -n monitoring
NAME                                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-operator-grafana              1/1     1            1           14m
deployment.apps/prometheus-operator-kube-state-metrics   1/1     1            1           14m
deployment.apps/prometheus-operator-operator             1/1     1            1           14m

NAME                                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-operator-grafana-7c7599754              1         1         1       14m
replicaset.apps/prometheus-operator-kube-state-metrics-bd8f49464   1         1         1       14m
replicaset.apps/prometheus-operator-operator-7dfc554db             1         1         1       14m

NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-prometheus-operator-alertmanager-0          2/2     Running   0          14m
pod/prometheus-operator-grafana-7c7599754-d5pcx              2/2     Running   0          14m
pod/prometheus-operator-kube-state-metrics-bd8f49464-8hqpn   1/1     Running   0          14m
pod/prometheus-operator-operator-7dfc554db-5kbs6             2/2     Running   0          14m
pod/prometheus-operator-prometheus-node-exporter-6jl5q       1/1     Running   0          14m
pod/prometheus-operator-prometheus-node-exporter-9bsmd       1/1     Running   0          14m
pod/prometheus-operator-prometheus-node-exporter-g7qjh       1/1     Running   0          14m
pod/prometheus-operator-prometheus-node-exporter-zvh8t       1/1     Running   0          14m
pod/prometheus-prometheus-operator-prometheus-0              3/3     Running   1          14m
</pre>

Собираем образ nginx. Для этого берем из оф. хаба образ nginx:1.21.3-alpine и подсовываем ему конфиг metrics.conf с нужным location.
Выдумывать ничего не будем, задание предельно простое. Однако отдавать метрики по общедоступному извне порту не тру.
Будем отдавать по 8080.

Dockerfile

<pre>
FROM nginx:1.21.3-alpine
COPY metrics.conf /etc/nginx/conf.d/metrics.conf
CMD ["nginx", "-g", "daemon off;"]
</pre>

Собираем и пушим

<pre>
docker build -t chudinanton/nginx:v.0.0.1 .
docker push chudinanton/nginx:v.0.0.1
</pre>

### Деплоим nginx, nginx-exporter, сервисы и servicemonitor

Экспортер NGINX Prometheus извлекает метрики из одного NGINX или NGINX Plus, конвертирует метрики в соответствующие типы метрик Prometheus и, наконец, предоставляет их через HTTP-сервер для сбора Prometheus.

Документация по nginx-prometheus-exporter -nginx.scrape-uri

https://github.com/nginxinc/nginx-prometheus-exporter#running-the-exporter-in-a-docker-container

Аргументы для nginx-prometheus-exporter

https://github.com/nginxinc/nginx-prometheus-exporter#command-line-arguments

Поместим nginx-prometheus-exporter внутрь нашего пода в качестве sidecar контейнера.

<pre>
      - name: nginx-prometheus-exporter
        image: nginx/nginx-prometheus-exporter:0.9.0
        env:
          - name: SCRAPE_URI
            value: "http://127.0.0.1:8080/basic_status"
        ports:
        - containerPort: 9113
</pre>

Публикуем манифесты:

<pre>
ka deployment.yaml
ka service.yaml
ka servicemonitor.yaml

kg deployments,rs,po,svc,ServiceMonitor
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-metrics   3/3     3            3           4m41s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-metrics-56ff8bff64   3         3         3       4m41s

NAME                                 READY   STATUS    RESTARTS   AGE
pod/nginx-metrics-56ff8bff64-9cr9h   2/2     Running   0          4m41s
pod/nginx-metrics-56ff8bff64-kbl52   2/2     Running   0          4m41s
pod/nginx-metrics-56ff8bff64-xxh8z   2/2     Running   0          4m41s

NAME                    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)           AGE
service/kubernetes      ClusterIP   10.12.0.1    <none>        443/TCP           3d1h
service/nginx-metrics   ClusterIP   10.12.2.0    <none>        80/TCP,9113/TCP   4m20s

NAME                                                                 AGE
servicemonitor.monitoring.coreos.com/nginx-metrics-service-monitor   3m21s
</pre>

Смотрим через Lens:

<pre>
http://localhost:54973/metrics

# HELP nginx_connections_accepted Accepted client connections
# TYPE nginx_connections_accepted counter
nginx_connections_accepted 2
# HELP nginx_connections_active Active client connections
# TYPE nginx_connections_active gauge
nginx_connections_active 1
# HELP nginx_connections_handled Handled client connections
# TYPE nginx_connections_handled counter
nginx_connections_handled 2
# HELP nginx_connections_reading Connections where NGINX is reading the request header
# TYPE nginx_connections_reading gauge
nginx_connections_reading 0
# HELP nginx_connections_waiting Idle client connections
# TYPE nginx_connections_waiting gauge
nginx_connections_waiting 0
# HELP nginx_connections_writing Connections where NGINX is writing the response back to the client
# TYPE nginx_connections_writing gauge
nginx_connections_writing 1
# HELP nginx_http_requests_total Total http requests
# TYPE nginx_http_requests_total counter
nginx_http_requests_total 3
# HELP nginx_up Status of the last metric scrape
# TYPE nginx_up gauge
nginx_up 1
# HELP nginxexporter_build_info Exporter build information
# TYPE nginxexporter_build_info gauge
nginxexporter_build_info{commit="5f88afbd906baae02edfbab4f5715e06d88538a0",date="2021-03-22T20:16:09Z",version="0.9.0"} 1
</pre>

Можно войти и в сам prometheus и grafana со стандартным паролем через port forwarding. Но мы пойдем другим путем.

Добавляем ингресс в графану через kube-prometheus-stack/values.yaml и обновляем

<pre>
helm upgrade --install prometheus-operator prometheus-community/prometheus-operator -n monitoring -f kubernetes-monitoring/kube-prometheus-stack/values.yaml
</pre>

Смотрим на графану

https://grafana.yogatour.su/

Реквизиты стандартные:

<pre>
admin
prom-operator
</pre>

Импортируем дашборд:

https://github.com/nginxinc/nginx-prometheus-exporter/tree/master/grafana


Дашборд 
![dashboards_nginx](kubernetes-monitoring/dashboards_nginx.png)

Проверка:

https://grafana.yogatour.su/d/MsjffzSZz/nginx?orgId=1&var-DS_PROMETHEUS=&var-instance=All&refresh=5s

</details>
</details>

<details>
<summary> <b>ДЗ №7 - kubernetes-operators (Операторы, CustomResourceDefinition)</b></summary>

- [x] Основное ДЗ

- [x] Создание оператора на Python

- [ ] Все дополнительные задания *

<details>
<summary> <b>Основное задание №1  - Создаем CR и CRD</b></summary>

Поднимаем minikube, важно указать версию!
<pre>
minikube start --driver=docker --kubernetes-version=v1.21.3
minikube addons disable default-storageclass
</pre>

Создаем cr.yml и crd.yml

<pre>
kubectl apply -f deploy/crd.yml
spec.versions[0].schema.openAPIV3Schema: Required value: schemas are required
</pre>

Меняем v1 на v1beta1
И применяем.
Создадим CRD:

<pre>
kubectl apply -f deploy/crd.yml
Warning: apiextensions.k8s.io/v1beta1 CustomResourceDefinition is deprecated in v1.16+, unavailable in v1.22+; use apiextensions.k8s.io/v1 CustomResourceDefinition
customresourcedefinition.apiextensions.k8s.io/mysqls.otus.homework created

kubectl get crd
NAME                   CREATED AT
mysqls.otus.homework   2021-09-17T10:16:24Z

</pre>

Cоздаем CR:

<pre>
kubectl apply -f deploy/cr.yml
mysql.otus.homework/mysql-instance created

kubectl get mysqls.otus.homework
NAME             AGE
mysql-instance   2m4s
</pre>

### Validation

Удалим наш инстанс:

<pre>
kubectl delete mysqls.otus.homework mysql-instance
</pre>

Чтобы валидация работала так как мы хотим, надо добавить в CRD также

<pre>
  preserveUnknownFields: false
</pre>

<pre>
kubectl apply -f deploy/cr.yml                                                                             
error: error validating "deploy/cr.yml": error validating data: ValidationError(MySQL): unknown field "usless_data" in homework.otus.v1.MySQL; if you choose to ignore these errors, turn validation off with --validate=false
</pre>

Убираем из deploy/cr.yml usless_data: "useless info", оно не описано в валидации.
Применяем:

<pre>
kubectl apply -f deploy/cr.yml                                                                       
mysql.otus.homework/mysql-instance created
</pre>

Задание по CRD:
Если сейчас из описания mysql убрать строчку из спецификации, то манифест будет принят API сервером. Для того, чтобы этого избежать, добавьте описание обязательный полей в ustomResourceDefinition:

<pre>
          required: ["image", "database", "password", "storage_size"]     

kubectl apply -f deploy/crd.yml                                                                           
Warning: apiextensions.k8s.io/v1beta1 CustomResourceDefinition is deprecated in v1.16+, unavailable in v1.22+; use apiextensions.k8s.io/v1 CustomResourceDefinition
customresourcedefinition.apiextensions.k8s.io/mysqls.otus.homework configured
</pre>

Проверяем (убираем одно значение для теста):

<pre>
kubectl apply -f deploy/cr.yml                                                                     
error: error validating "deploy/cr.yml": error validating data: ValidationError(MySQL.spec): missing required field "password" in homework.otus.v1.MySQL.spec; if you choose to ignore these errors, turn validation off with --validate=false
</pre>

Cтавим необходимые питоновские библиотеки:
<pre>
pip install kopf jinja2 kubernetes
</pre>

Создаем папку build/templates и помещаем туда необходимые шаблоны

<pre>
mysql-deployment.yml.j2
mysql-service.yml.j2
mysql-pv.yml.j2
mysql-pvc.yml.j2
backup-pv.yml.j2
backup-pvc.yml.j2
backup-job.yml.j2
restore-job.yml.j2
</pre>

Должно получиться, что-то похожее на:

https://gist.githubusercontent.com/Evgenikk/581fa5bba6d924a3438be1e3d31aa468/raw/c7c0b8882550ab54d981a4941959276802fe0233/controller-1.py

Я дополнительно проставил комментарии для понимания. В питоне разбираюсь не шибко.

С такой конфигурацией уже должны обрабатываться события при создании cr.yml, проверим, для этого из папки build:

<pre>
(minikube # ) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# kopf run mysql-operator.py                                                                      
/usr/local/lib/python3.9/site-packages/kopf/_core/reactor/running.py:170: FutureWarning: Absence of either namespaces or cluster-wide flag will become an error soon. For now, switching to the cluster-wide mode for backward compatibility.
  warnings.warn("Absence of either namespaces or cluster-wide flag will become an error soon."
[2021-09-17 12:48:20,428] kopf._core.engines.a [INFO    ] Initial authentication has been initiated.
[2021-09-17 12:48:20,448] kopf.activities.auth [INFO    ] Activity 'login_via_client' succeeded.
[2021-09-17 12:48:20,448] kopf._core.engines.a [INFO    ] Initial authentication has finished.
mysql-operator.py:12: YAMLLoadWarning: calling yaml.load() without Loader=... is deprecated, as the default Loader is unsafe. Please read https://msg.pyyaml.org/load for full details.
  json_manifest = yaml.load(yaml_manifest)
[2021-09-17 12:48:20,734] kopf.objects         [INFO    ] [default/mysql-instance] Handler 'mysql_on_create' succeeded.
[2021-09-17 12:48:20,735] kopf.objects         [INFO    ] [default/mysql-instance] Creation is processed: 1 succeeded; 0 failed.
</pre>

> Вопрос: почему объект создался, хотя мы создали CR, до того, как запустили контроллер?
> Ответ: как было сказано в лекции есть два триггера Edge Triggered & Level Triggered. В данном случае отрабатывает Level Triggered

Если сделать kubectl delete mysqls.otus.homework mysql-instance , то CustomResource будет удален, но наш контроллер ничего не
сделает т. к. обработки событий на удаление у нас нет.

Удалим все ресурсы, созданные контроллером:

<pre>
kubectl delete mysqls.otus.homework mysql-instance
kubectl delete deployments.apps mysql-instance
kubectl delete pvc mysql-instance-pvc
kubectl delete pv mysql-instance-pv
kubectl delete svc mysql-instance
</pre>

Для удаления ресурсов, сделаем deployment,svc,pv,pvc дочерними ресурсами к mysql, для этого в тело функции mysql_on_create , после генерации json манифестов добавим:

<pre>
    # Определяем, что созданные ресурсы являются дочерними к управляемому CustomResource:
    kopf.append_owner_reference(persistent_volume, owner=body)
    kopf.append_owner_reference(persistent_volume_claim, owner=body)  # addopt
    kopf.append_owner_reference(service, owner=body)
    kopf.append_owner_reference(deployment, owner=body)
    # ^ Таким образом при удалении CR удалятся все, связанные с ним pv,pvc,svc, deployments
</pre>

Добавляем обработку события удаления ресурса mysql в самый конец файла:

<pre>
@kopf.on.delete('otus.homework', 'v1', 'mysqls')
def delete_object_make_backup(body, **kwargs):
  return {'message': "mysql and its children resources deleted"}
</pre>

Актуальное состояние контроллера можно подсмотреть в

https://gist.githubusercontent.com/Evgenikk/581fa5bba6d924a3438be1e3d31aa468/raw/8308e18203e191d0318f2f6d4ec6459b27e1b56e/controller-2.py

Тестируем:

<pre>
kubectl apply -f ../deploy/cr.yml
kopf run mysql-operator.py

kg pv,deployment,pvc,svc -A
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                        STORAGECLASS   REASON   AGE
persistentvolume/mysql-instance-pv                          1Gi        RWO            Retain           Available                                                        92s
persistentvolume/pvc-25359ec1-8acf-48f2-bdd1-2ac244255974   1Gi        RWO            Delete           Bound       default/mysql-instance-pvc   standard                92s

NAMESPACE     NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/mysql-instance   0/1     1            0           92s
kube-system   deployment.apps/coredns          1/1     1            1           3h46m

NAMESPACE   NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
default     persistentvolumeclaim/mysql-instance-pvc   Bound    pvc-25359ec1-8acf-48f2-bdd1-2ac244255974   1Gi        RWO            standard       92s

NAMESPACE     NAME                     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes       ClusterIP   10.96.0.1    <none>        443/TCP                  3h46m
default       service/mysql-instance   ClusterIP   None         <none>        3306/TCP                 92s
kube-system   service/kube-dns         ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   3h46m
</pre>

Теперь добавим создание pv, pvc для backup и restore job. Для этого после создания deployment добавим следующий код:

<pre>
    # Cоздаем PVC  и PV для бэкапов:
    try:
        backup_pv = render_template('backup-pv.yml.j2', {'name': name})
        api = kubernetes.client.CoreV1Api()
        print(api.create_persistent_volume(backup_pv))
        api.create_persistent_volume(backup_pv)
    except kubernetes.client.rest.ApiException:
        pass

    try:
        backup_pvc = render_template('backup-pvc.yml.j2', {'name': name})
        api = kubernetes.client.CoreV1Api()
        api.create_namespaced_persistent_volume_claim('default', backup_pvc)
    except kubernetes.client.rest.ApiException:
        pass
</pre>

Конструкция try, except - это обработка исключений, в данном случае, нужна, чтобы наш контроллер не пытался бесконечно пересоздать pv и pvc для бэкапов, т. к. их жизненный цикл отличен от жизненного цикла mysql. 

Далее нам необходимо реализовать создание бэкапов и восстановление из них. Для этого будут использоваться Job. Поскольку при запуске Job, повторно ее запустить нельзя, нам нужно реализовать логику удаления успешно законченных jobs c определенным именем.

Для этого выше всех обработчиков событий (под функцией render_template) добавим следующую функцию:

<pre>
def delete_success_jobs(mysql_instance_name):
    print("start deletion")
    api = kubernetes.client.BatchV1Api()
    jobs = api.list_namespaced_job('default')
    for job in jobs.items:
        jobname = job.metadata.name
        if (jobname == f"backup-{mysql_instance_name}-job") or \
                (jobname == f"restore-{mysql_instance_name}-job"):
            if job.status.succeeded == 1:
                api.delete_namespaced_job(jobname,
                                          'default',
                                          propagation_policy='Background')
</pre>

Также нам понадобится функция, для ожидания пока наша backup job завершится, чтобы дождаться пока backup выполнится перед удалением mysql deployment, svc, pv, pvc.

<pre>
def wait_until_job_end(jobname):
    api = kubernetes.client.BatchV1Api()
    job_finished = False
    jobs = api.list_namespaced_job('default')
    while (not job_finished) and \
            any(job.metadata.name == jobname for job in jobs.items):
        time.sleep(1)
        jobs = api.list_namespaced_job('default')
        for job in jobs.items:
            if job.metadata.name == jobname:
                print(f"job with { jobname }  found,wait untill end")
                if job.status.succeeded == 1:
                    print(f"job with { jobname }  success")
                    job_finished = True
</pre>

Добавим запуск backup-job и удаление выполненных jobs в функцию delete_object_make_backup:

<pre>
@kopf.on.delete('otus.homework', 'v1', 'mysqls')
def delete_object_make_backup(body, **kwargs):
    name = body['metadata']['name']
    image = body['spec']['image']
    password = body['spec']['password']
    database = body['spec']['database']

    delete_success_jobs(name)

    # Cоздаем backup job:
    api = kubernetes.client.BatchV1Api()
    backup_job = render_template('backup-job.yml.j2', {
        'name': name,
        'image': image,
        'password': password,
        'database': database})
    api.create_namespaced_job('default', backup_job)
    wait_until_job_end(f"backup-{name}-job")
    return {'message': "mysql and its children resources deleted"}
</pre>

Актуальное состояние контроллера:

https://gist.githubusercontent.com/Evgenikk/581fa5bba6d924a3438be1e3d31aa468/raw/bf3545bc96ddff423424b43c2c687e14242a13fb/controller-3.py

Добавим генерацию json из шаблона для restore-job:

<pre>
    restore_job = render_template('restore-job.yml.j2', {
        'name': name,
        'image': image,
        'password': password,
        'database': database})
</pre>

Добавим попытку восстановиться из бэкапов после deployment mysql:

<pre>
    # Пытаемся восстановиться из backup
    try:
        api = kubernetes.client.BatchV1Api()
        api.create_namespaced_job('default', restore_job)
    except kubernetes.client.rest.ApiException:
        pass
</pre>

Добавим зависимость restore-job от объектов mysql (возле других owner_reference):
<pre>
kopf.append_owner_reference(restore_job, owner=body)
</pre>

Вот и готово. Запускаем оператор (из директории build):

<pre>
kopf run mysql-operator.py
</pre>

Создаем CR:

<pre>
kubectl apply -f deploy/cr.yml
</pre>

Проверяем:

Актуальное состояние контроллера:
https://gist.githubusercontent.com/Konstantinov86/496dfa95154bc1b24a92ab9b347829fc/raw/3114468de9f0add1ae7afa58e81fee982267b374/controller-5.py

В backup-pvc.yml.j2 не указан pv-usage, не думаю, что это "ошибка" :), диверсия скорее :)

<pre>
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-{{ name }}-pvc
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      pv-usage: backup-{{ name }}
</pre>

<pre>
kg pv,pvc
NAME                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE
persistentvolume/backup-mysql-instance-pv   1Gi        RWO            Retain           Bound    default/backup-mysql-instance-pvc                           29s
persistentvolume/mysql-instance-pv          1Gi        RWO            Retain           Bound    default/mysql-instance-pvc                                  29s

NAME                                              STATUS   VOLUME                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/backup-mysql-instance-pvc   Bound    backup-mysql-instance-pv   1Gi        RWO                           29s
persistentvolumeclaim/mysql-instance-pvc          Bound    mysql-instance-pv          1Gi        RWO                           29s
</pre>

Заполняем базу:

<pre>
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (null, 'some data' );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (null, 'some data-2' );" otus-database
</pre>

Смотрим что получилось:

<pre>
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
</pre>

Проверяем задание бэкапа при удалении:

<pre>
kubectl delete mysqls.otus.homework mysql-instance                                
mysql.otus.homework "mysql-instance" deleted
(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# kg pv,pvc                                                                
NAME                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                               STORAGECLASS   REASON   AGE
persistentvolume/backup-mysql-instance-pv   1Gi        RWO            Retain           Bound      default/backup-mysql-instance-pvc                           117s
persistentvolume/mysql-instance-pv          1Gi        RWO            Retain           Released   default/mysql-instance-pvc                                  117s

NAME                                              STATUS   VOLUME                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/backup-mysql-instance-pvc   Bound    backup-mysql-instance-pv   1Gi        RWO                           117s

kg job
NAME                        COMPLETIONS   DURATION   AGE
backup-mysql-instance-job   1/1           1s         30s

</pre>

Создадим заново mysql-instance:
<pre>
kubectl apply -f ../deploy/cr.yml
kg job
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           1s         65s
restore-mysql-instance-job   1/1           16s        19s
</pre>

Видим, что restore-mysql-instance-job выполнен и все данные на месте!

<pre>
kg job
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           1s         65s
restore-mysql-instance-job   1/1           16s        19s
(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# kgpo
NAME                               READY   STATUS      RESTARTS   AGE
backup-mysql-instance-job-xh987    0/1     Completed   0          107s
mysql-instance-6785949c48-nrvg6    1/1     Running     0          61s
restore-mysql-instance-job-tsr8h   0/1     Completed   2          61s
(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")

(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
</pre>


Для решения проблемы
<pre>
HTTP response headers: HTTPHeaderDict({'Cache-Control': 'no-cache, private', 'Content-Type': 'application/json', 'X-Kubernetes-Pf-Flowschema-Uid': '59e0f613-106d-4cbb-8f87-f1f605b59802', 'X-Kubernetes-Pf-Prioritylevel-Uid': '65541d7a-7bc8-4395-90f2-ed3dad8cf301', 'Date': 'Fri, 17 Sep 2021 14:51:52 GMT', 'Content-Length': '238'})
HTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"persistentvolumes \"mysql-instance-pv\" already exists","reason":"AlreadyExists","details":{"name":"mysql-instance-pv","kind":"persistentvolumes"},"code":409}

[2021-09-17 17:51:52,393] kopf.objects         [WARNING ] [default/mysql-instance] Patching failed with inconsistencies: (('remove', ('status',), {'kopf': {'progress': {'mysql_on_create': {'started': '2021-09-17T14:48:51.817429', 'stopped': None, 'delayed': '2021-09-17T14:52:52.380297', 'purpose': 'create', 'retries': 4, 'success': False, 'failure': False, 'message': '(409)\nReason: Conflict\nHTTP response headers: HTTPHeaderDict({\'Cache-Control\': \'no-cache, private\', \'Content-Type\': \'application/json\', \'X-Kubernetes-Pf-Flowschema-Uid\': \'59e0f613-106d-4cbb-8f87-f1f605b59802\', \'X-Kubernetes-Pf-Prioritylevel-Uid\': \'65541d7a-7bc8-4395-90f2-ed3dad8cf301\', \'Date\': \'Fri, 17 Sep 2021 14:51:52 GMT\', \'Content-Length\': \'238\'})\nHTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"persistentvolumes \\"mysql-instance-pv\\" already exists","reason":"AlreadyExists","details":{"name":"mysql-instance-pv","kind":"persistentvolumes"},"code":409}\n\n', 'subrefs': None}}}}, None),)
</pre>

В mysql-operator.py добавлены:

<pre>
    apiv1 = kubernetes.client.CoreV1Api()
    apiv1.delete_persistent_volume(f"{ name }-pv")
</pre>

### Деплой оператора.

Создаем докер образ и пушим его в хаб

<pre>
cat Dockerfile

FROM python:3.7
COPY templates ./templates
COPY mysql-operator.py ./mysql-operator.py
RUN pip install kopf kubernetes pyyaml jinja2
CMD kopf run /mysql-operator.py
</pre>

<pre>
docker build -t chudinanton/mysql-operator:v.0.0.1 .
docker push chudinanton/mysql-operator:v.0.0.1
</pre>

Создадим и применим манифесты. В Deployment используем свой образ.

<pre>

ka ../deploy/service-account.yml
ka ../deploy/role.yml
ka ../deploy/ClusterRoleBinding.yml
ka ../deploy/deploy-operator.yml

kgpo
NAME                               READY   STATUS      RESTARTS   AGE
backup-mysql-instance-job-xh987    0/1     Completed   0          18m
mysql-instance-6785949c48-nrvg6    1/1     Running     0          17m
mysql-operator-558ccb8d75-kv2dn    1/1     Running     0          75s
restore-mysql-instance-job-tsr8h   0/1     Completed   2          17m
</pre>

И проверяем еще раз.

<pre>
kubectl get jobs.batch
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           2s         39s
restore-mysql-instance-job   1/1           18s        18s
(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
(minikube # N/A) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-operators/build# kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
</pre>

К сожалению,  ограничен во времени чтобы выполнить доп. задания.

</details>
</details>

<details>
<summary> <b>ДЗ №6 - kubernetes-templating (Шаблонизация манифестов Kubernetes)</b></summary>

- [x] Основное ДЗ

- [x] Все дополнительные задания *

- [x] Все необязательные и самостоятельные задания

<details>
<summary> <b>Основное задание №1  - Подготовка среды</b></summary>
- Регистрация нового аккаунта в gcp.
- Настройка управления gcp на локальной машине:
https://cloud.google.com/storage/docs/gsutil_install?hl=ru
- Ручное создание кластера k8s кластера в gcp, подключение к нему:
<pre>
gcloud container clusters get-credentials gke-cluster --zone europe-west3-c --project geometric-orbit-325713
</pre>

<pre>
Отобразить текущий Контекст:
$ kubectl config current-context
Вывести список всех Контекстов из файла kubeconfig:
$ kubectl config get-contexts
kubectl config get-contexts                                                                                                                              
(gke_cluster # ) antonchudin@mir ~/otus/k8s_06/chudinanton_platform/kubernetes-templating/cert-manager# kubectl config get-contexts

CURRENT   NAME          CLUSTER       AUTHINFO                         NAMESPACE
          bgd_cluster   bgd_cluster   kubernetes-admin-cluster.local   
*         gke_cluster   gke_cluster   gke_cluster                      
          kind-bob      kind-kind     kind-bob                         
          kind-dave     kind-kind     kind-dave                        
          kind-kind     kind-kind     kind-kind  
Сменить Контекст:
$ kubectl config use-context <context_name>

Убрать контекст:
#kubectl config unset current-context
</pre>
- Установка Helm3: brew install helm
<pre>
#helm version                                
version.BuildInfo{Version:"v3.6.3", GitCommit:"d506314abfb5d21419df8c7e7e68012379db2354", GitTreeState:"dirty", GoVersion:"go1.16.6"}
</pre>
- Добавление репы Helm:
<pre>
#helm repo add stable https://kubernetes-charts.storage.googleapis.com                                
Error: repo "https://kubernetes-charts.storage.googleapis.com" is no longer available; try "https://charts.helm.sh/stable" instead
#helm repo add stable https://charts.helm.sh/stable                                            
"stable" already exists with the same configuration, skipping

antonchudin@mir ~/otus/chudinanton_platform/kubernetes-templating
# helm repo list                                                                            
NAME            URL                              
stable          https://charts.helm.sh/stable    
jetstack        https://charts.jetstack.io       
harbor          https://helm.goharbor.io         
metallb         https://metallb.github.io/metallb
</pre>
- Изменил промт для отображения контекста клонировав:

https://github.com/jonmosco/kube-ps1
<pre>
#mcedit ~/.zshrc
...
source ~/kube-ps1/kube-ps1.sh
...

#mcedit .oh-my-zsh/themes/alanpeabody.zsh-theme
...
PROMPT2="${user} ${pwd}# "
PROMPT='$(kube_ps1)'$PROMPT2
...
</pre>
Теперь будет виден контекст при подключении к кластеру.

</details>


<details>
<summary> <b>Основное задание №2 - nginx-ingress</b></summary>
- Переключаемся в нужный контекст 
<pre>
#kubectl config use-context gke_cluster
#kubectl create ns nginx-ingress
#kubectl get namespaces
#helm upgrade --install nginx-ingress stable/nginx-ingress --wait  --namespace=nginx-ingress --version=1.41.3
</pre>
Смотрим внешний ip:
<pre>
#kubectl get service --namespace nginx-ingress
NAME                          TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)                      AGE
nginx-ingress-nginx-ingress   LoadBalancer   10.12.7.69   34.89.236.114   80:32701/TCP,443:30307/TCP   86m
</pre>
</details>
<details>
<summary> <b>Основное задание №3 - cert-manager</b></summary>
- Переключаемся в нужный контекст 
Добавим репозиторий, в котором хранится актуальный helm chart certmanager:
<pre>
#helm repo add jetstack https://charts.jetstack.io
</pre>
Также для установки cert-manager предварительно потребуется создать
в кластере некоторые CRD ( на документацию по установке):

https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager
Соответственно создаем namespace cert-manager и установим cert-manager через HELM вместе с CRD:
<pre>
#kubectl create namespace cert-manager
#kubectl get namespaces 
#helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.2 --set installCRDs=true
#
#kubectl get service --namespace cert-manager
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
cert-manager           ClusterIP   10.12.14.152   <none>        9402/TCP   88m
cert-manager-webhook   ClusterIP   10.12.12.41    <none>        443/TCP    88m
</pre>

Для инициирования процедуры заказа сертификата в кластере должны быть объявлены ресурсы центров сертификации (CA): 
- Issuer или ClusterIssuer, — которые используются для подписи CSR (запросов на выпуск сертификата). 
Отличие первого ресурса от второго — в области видимости:
Issuer может использоваться в рамках одного пространства имен,
ClusterIssuer является глобальным объектом кластера.

Выберем ClusterIssuer

Примечание: у Let’s Encrypt существуют довольно строгие лимиты на запросы к ACME-серверам. Чтобы не попасть в длительный бан, для отладки рекомендуется использовать тип сертификата letsencrypt-staging (отличие только в ACME-сервере).
Я выбираю production. Делаем cluster_issuer.yaml в соответствующей папке cert-manager.
Также добавил stage для тестирования.

<pre>
#kubectl apply -f cert-manager/cluster_issuer.yaml
#kubectl get clusterissuer --namespace cert-manager
NAME                     READY   AGE
letsencrypt-production   True    88m
letsencrypt-stage        True    42m
</pre>

</details>
<details>
<summary> <b>Основное задание №4 - chartmuseum</b></summary>
- Создаем папку chartmuseum и файл values.yaml
- Включаем в нем создание ingress ресурса с корректным hosts.name (должен
использоваться nginx-ingress) и автоматическую генерацию Let's Encrypt сертификата
Соответственно меняем в файле:
<pre>
ingress:
  enabled: true
</pre>
- Добавляем аннотации где задаем ingress и cluster-issuer
<pre>
 annotations:
 kubernetes.io/ingress.class: nginx
 kubernetes.io/tls-acme: "true"
 cert-manager.io/cluster-issuer: "letsencrypt-production"
 cert-manager.io/acme-challenge-type: http01
</pre>
- Указываем хост
<pre>
  hosts:
    - name: chartmuseum.yogatour.su
      path: /
      tls: true
      tlsSecret: chartmuseum.yogatour.su
</pre>

Разрешаем обращение к API:

<pre>
   # disable all routes prefixed with /api
    DISABLE_API: false
</pre>
- Создаем ns и раскатываем там chartmuseum
<pre>
#kubectl create ns chartmuseum
#helm upgrade --install chartmuseum chartmuseum/chartmuseum --wait \
 --namespace=chartmuseum \
 --version=3.1.0 \
 -f kubernetes-templating/chartmuseum/values.yaml

#helm ls -n chartmuseum
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
chartmuseum     chartmuseum     1               2021-09-14 14:48:24.442644 +0300 MSK    deployed        chartmuseum-2.13.2      0.12.0   
</pre>
chartmuseum работает с валидным сертификатом!

!!!
Чтобы не было проблемы с генерацией сертификата не забываем про аннотацию:
!!!
<pre>
<b>acme.cert-manager.io/http01-edit-in-place: "true"</b>
</pre>

Просмотр сертификатов кластере:
<pre>
#kubectl get certificate --namespace chartmuseum
NAME                      READY   SECRET                    AGE
chartmuseum.yogatour.su   True    chartmuseum.yogatour.su   2m58s
</pre>

<pre>
kubectl get secrets -n chartmuseum
NAME                                TYPE                                  DATA   AGE
chartmuseum                         Opaque                                0      3m26s
chartmuseum.yogatour.su             kubernetes.io/tls                     2      3m25s
default-token-5v4z9                 kubernetes.io/service-account-token   3      7m12s
sh.helm.release.v1.chartmuseum.v1   helm.sh/release.v1                    1      3m26s
</pre>

</details>
<details>
<summary> <b>Доп. задание №1 - Научитесь работать с chartmuseum</b></summary>
<pre>
helm pull bitnami/redis
curl --data-binary "@redis-15.3.2.tgz" https://chartmuseum.yogatour.su/api/charts
helm repo add chartmuseum-gcp https://chartmuseum.yogatour.su
helm search repo redis                                                                            ✹ ✭kubernetes-volumes 
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
chartmuseum-gcp/redis                   15.3.2          6.2.5           Open source, advanced key-value store. It is of...
stable/prometheus-redis-exporter        3.5.1           1.3.4           DEPRECATED Prometheus exporter for Redis metrics  
stable/redis                            10.5.7          5.0.7           DEPRECATED Open source, advanced key-value stor...
stable/redis-ha                         4.4.6           5.0.6           DEPRECATED - Highly available Kubernetes implem...
stable/sensu                            0.2.5           0.28            DEPRECATED Sensu monitoring framework backed by...

kubectl create ns redis-cluster-test
helm install redis-cluster-test chartmuseum-gcp/redis --namespace=redis-cluster-test

cd ../frontend
helm package .
curl --data-binary "@frontend-0.1.0.tgz" https://chartmuseum.yogatour.su/api/charts
{"saved":true}
</pre>

</details>
<details>
<summary> <b>Самостоятельное задание №1 - Harbor</b></summary>
Установка Harbor
<pre>
kubectl create ns harbor
helm repo add harbor https://helm.goharbor.io
helm install harbor harbor/harbor --namespace harbor -f kubernetes-templating/harbor/values.yaml
kubectl get secrets -n harbor -l owner=helm
NAME                           TYPE                 DATA   AGE
sh.helm.release.v1.harbor.v1   helm.sh/release.v1   1      3m20s
</pre>
Ссылка на harbor:
https://github.com/goharbor/harbor-helm

Ссылка на работающий harbor в gcp:
https://harbor.yogatour.su
</details>

<details>
<summary> <b>Доп. задание №2 Используем helmfile | Задание со</b></summary>
<pre>
helm delete nginx-ingress --namespace=nginx-ingress
helm delete cert-manager --namespace cert-manager
helm delete harbor -n harbor
brew install helmfile
cd kubernetes-templating/helmfile
helmfile sync
helmfile destroy
</pre>

</details>

<details>
<summary> <b>Основное задание №5 Создаем свой helm chart</b></summary>
<pre>
helm create kubernetes-templating/hipster-shop
kubectl create ns hipster-shop
helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop
</pre>
Запрошено больше ресурсов чем было выдано в gcloud.  Включил автоскейлинг нод. 

Тестирование UI через port forwarding изнутри https://console.cloud.google.com/
а также через Lens.

Отдельный helm chart для frontenfd.

<pre>
helm create kubernetes-templating/frontend
</pre>
Выносим из hipster-shop deployment, service и создаем Ingress сразу с запросом сертификата.
Применяем чарт hipster-shop для удаления из него вынесенного в отдельный чарт frontend, и затем применяем frontend чарт в том же --namespace hipster-shop
<pre>
helm upgrade hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop

kubectl get secrets -n hipster-shop -l owner=helm                                                                             
NAME                                 TYPE                 DATA   AGE
sh.helm.release.v1.frontend.v1       helm.sh/release.v1   1      3m34s
sh.helm.release.v1.hipster-shop.v1   helm.sh/release.v1   1      50m
sh.helm.release.v1.hipster-shop.v2   helm.sh/release.v1   1      39m
sh.helm.release.v1.hipster-shop.v3   helm.sh/release.v1   1      9m14s

helm upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop

https://shop.yogatour.su/
</pre>

Параметризовывыем наш чарт.
<pre>
image:
  tag: v0.1.3

replicas: 1

service:
  port: 80
  targetPort: 8079
  NodePort: 30001
  type: NodePort
</pre>

Условие делаем через IF
<pre>
{{ if eq .Values.service.type "NodePort" }}nodePort: {{ .Values.service.NodePort }}{{ end }}
</pre>

Не забываем про порты на котором работает контейнер.
</details>
<details>
<summary> <b>Доп. задание №3 Redis используя community chart's. | Задание со</b></summary>
Создаем свой helm chart | Задание со ⭐
Доп. задание про вынос redis'a на community chart's от Bitnami
<pre>
helm repo add bitnami https://charts.bitnami.com/bitnami
</pre>
Указываем зависимость и пересобираем чарт:
<pre>
....
  - name: redis 
    version: 15.3.2 
    repository: https://charts.bitnami.com/bitnami
....
helm dep update kubernetes-templating/hipster-shop
</pre>


</details>

<details>
<summary> <b>Работа с helm-secrets | Необязательное задание</b></summary>

Установка необходимых компонентов:
<pre>
brew install sops
brew install gnupg2
brew install gnu-getopt
brew install gpg
helm plugin install https://github.com/jkroepke/helm-secrets
</pre>

Сгенерируем новый PGP ключ:
<pre>
gpg --full-generate-key 
</pre>

Шифруем файл:
<pre>
sops -e -i --pgp 5673F6CBC1CFBC24AEDE5CCF1F6E790F209DDF99 kubernetes-templating/frontend/secrets.yaml
gpg --export-secret-keys >~/.gnupg/secring.gpg
</pre>

Смотрим (предварительно фиксим багу):

https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
<pre>
mcedit .zshrc

.....
GPG_TTY=$(tty)
export GPG_TTY

helm secrets view kubernetes-templating/frontend/secrets.yaml
sops -d kubernetes-templating/frontend/secrets.yaml
</pre>


Добавляем kubernetes-templating/frontend/templates/secret.yaml и передаем в него через переменную {{ .Values.visibleKey | b64enc | quote }} данные из kubernetes-templating/frontend/secrets.yaml
и запихиваем в наш hipster-shop уже развернутый в gcp.
<pre>
helm secrets upgrade --install hipster-shop kubernetes-templating/frontend --namespace hipster-shop \
 -f kubernetes-templating/frontend/values.yaml \
 -f kubernetes-templating/frontend/secrets.yaml
</pre>

Проверяем секрет на соответствие значения. Можно через Lens, а можно через команду чтоб не разлениться:

<pre>
kg secrets secret -n hipster-shop -o "jsonpath={.data.visibleKey}" | base64 -D
</pre>
</details>
<details>
<summary> <b>Подключаем GCP KMS | Необязательное задание</b></summary>


<pre>
gcloud kms keyrings create sops --location global
gcloud kms keys create sops-key --location global --keyring sops --purpose encryption
gcloud kms keys list --location global --keyring sops

NAME                                                                                PURPOSE          ALGORITHM                    PROTECTION_LEVEL  LABELS  PRIMARY_ID  PRIMARY_STATE
projects/geometric-orbit-325713/locations/global/keyRings/sops/cryptoKeys/sops-key  ENCRYPT_DECRYPT  GOOGLE_SYMMETRIC_ENCRYPTION  SOFTWARE                  1           ENABLED
</pre>

Далее нужно настроить сервис аккаунт по следующей инструкции:

https://cloud.google.com/docs/authentication/production#auth-cloud-explicit-csharp

Не забываем про (через тильду не взлетело)
<pre>
export GOOGLE_APPLICATION_CREDENTIALS="/Users/antonchudin/.ssh/chudinanton-gcp-key.json"

А лучше запихать в .zshrc

GOOGLE_APPLICATION_CREDENTIALS="/Users/antonchudin/.ssh/chudinanton-gcp-key.json"
export GOOGLE_APPLICATION_CREDENTIALS

</pre>

Поможет следующая документация:

https://gofore.com/very-secret-development-operations-part-ii-storing-skeletons-into-a-version-control/

https://github.com/mozilla/sops#using-sops-yaml-conf-to-select-kms-pgp-for-new-files

https://github.com/mozilla/sops#encrypting-using-gcp-kms

Cоздаю тестовый проект
<pre>
mkdir kubernetes-templating/kms
</pre>

Создаем шаблоны шифрования и расшифровывания в .sops.yaml:
<pre>
creation_rules:
  # Staging
  - path_regex: staging/.*\.enc(\.yaml|\.json)?$
    gcp_kms: projects/geometric-orbit-325713/locations/global/keyRings/sops/cryptoKeys/sops-key

  # Global enc-files (typically for testing and dev-environment)
  - path_regex: .*\.enc(\.yaml|\.json)?$
    gcp_kms: projects/geometric-orbit-325713/locations/global/keyRings/sops/cryptoKeys/sops-key
</pre>

Пример шифрования и расшифровывания с использованием gcp_kms:
<pre>
sops -e staging.prod.enc.yaml > prod.enc.yaml

cat prod.enc.yaml


visibleKey: ENC[AES256_GCM,data:UQHXrugXIL2O,iv:06WFEehgF031BzU4a+G+SjZZL3G/Sb63cDeVscYoeEM=,tag:N+zEB2clz+a0zZNBzTv4CA==,type:int]
sops:
    kms: []
    gcp_kms:
        - resource_id: projects/geometric-orbit-325713/locations/global/keyRings/sops/cryptoKeys/sops-key
          created_at: "2021-09-15T19:13:36Z"
          enc: CiQAK/B0ZcxDqdDnEfdCH7PU2cw5m9IMpJ9WMjjG6hYHHb/fCagSSQBnrCMehpvVlPHz99H9ACX+m7Gpk0eRcAWBdDjtnhyWTXsib8CqvDucZLt8qxEf1pEKr0y61cy8zcJNcsJsThbEYGqE3gFdiUI=
    azure_kv: []
    hc_vault: []
    age: []
    lastmodified: "2021-09-15T19:13:36Z"
    mac: ENC[AES256_GCM,data:+zDUD8V9gYICXjt2+13NZzHGfapuHJ3jYLgayS1t4J35SMXiWZ9ykRWd5OQGF+SVHb/Y1XN2baXJLBCZPUJz//c5TCZPi/OISkV8UVlaYoSNWKRJ6dGJcOW4FrhjVXw0Hj+pJKvI4VzgujHGrp9Jh1qFJTEUz30bi0V13DkW/Dk=,iv:J9cWIDewaVhsocquHREQxYWteO+U+tHoaNe8Xdh73Uc=,tag:TFYVg8g+zgPjjiANs99ppA==,type:str]
    pgp: []
    unencrypted_suffix: _unencrypted
    version: 3.7.1


sops -d prod.enc.yaml > s2.prod.enc.yaml

</pre>

Для того чтобы автоматизировать шифрование секретов и не коммитить их в репу можно настроить pre-commit-hook
Прекрасно описано здесь:

https://gofore.com/very-secret-development-operations-part-ii-storing-skeletons-into-a-version-control/

</details>


<details>
<summary> <b>Проверка</b></summary>
Загружаем два чарта в Harbor
<pre>
helm repo add templating https://harbor.yogatour.su/chartrepo/kubernetes-templating
"templating" has been added to your repositories

helm search repo hipster                                                               
NAME                   	CHART VERSION	APP VERSION	DESCRIPTION                
templating/hipster-shop	0.1.0        	1.16.0     	A Helm chart for Kubernetes

helm search repo frontend
NAME                    	CHART VERSION	APP VERSION	DESCRIPTION                                       
chartmuseum-gcp/frontend	0.1.0        	1.16.0     	A Helm chart for Kubernetes                       
templating/frontend     	0.1.1        	1.16.0     	A Helm chart for Kubernetes                       
stable/phpmyadmin       	4.3.5        	5.0.1      	DEPRECATED phpMyAdmin is an mysql administratio...
</pre>
</details>

<details>
<summary> <b>Основное задание №6 Kubecfg</b></summary>
Выносим два сервиса из all-hipster-shop.yaml и помещаем их в в папку kubecfg

Добиваемся неработоспособности корзины в https://shop.yogatour.su/cart

Устанавливаем kubecfg
<pre>
brew install kubecfg
kubecfg version

kubecfg version: v0.20.0
jsonnet version: v0.16.0
client-go version: v0.0.0-master+886ea66
</pre>

Для начала в файле мы должны указать libsonnet библиотеку, которую будем использовать для генерации манифестов. В домашней работе воспользуемся готовой от bitnami
Загрузил в корень kubecfg и поправил верисию  Deployment
<pre>
  Deployment(name): $._Object("apps/v1", "Deployment", name) {
</pre>

Проверяем, применяем и проверяем работу корзины с доставкой.
<pre>
kubecfg update services.jsonnet --namespace hipster-shop                                             
INFO  Validating services paymentservice
INFO  validate object "/v1, Kind=Service"
INFO  Validating deployments paymentservice
INFO  validate object "apps/v1, Kind=Deployment"
INFO  Validating deployments shippingservice
INFO  validate object "apps/v1, Kind=Deployment"
INFO  Validating services shippingservice
INFO  validate object "/v1, Kind=Service"
INFO  Fetching schemas for 4 resources
INFO  Creating services paymentservice
INFO  Creating services shippingservice
INFO  Creating deployments paymentservice
INFO  Creating deployments shippingservice

curl -I https://shop.yogatour.su/cart                                                                                                                   
HTTP/1.1 200 OK
Server: nginx/1.21.0
Date: Wed, 15 Sep 2021 21:11:27 GMT
Content-Type: text/html; charset=utf-8
Connection: keep-alive
Set-Cookie: shop_session-id=cf556a67-ed34-47ee-bbb4-33a6210b8cef; Max-Age=172800
</pre>

</details>

<details>
<summary> <b>Доп. задание №4 - Qbec</b></summary>
Будем выпиливать сервис currencyservice и использовать Qbec. Он описан более понятно, чем Kapitan.

Документация:

https://qbec.io/userguide/tour/

Установка:
<pre>
brew tap splunk/tap
brew install qbec
</pre>

Инициализация шаблона с примером:
<pre>
qbec init currencyservice --with-example                                                 
using server URL "https://34.107.24.126" and default namespace "default" for the default environment
wrote currencyservice/params.libsonnet
wrote currencyservice/environments/base.libsonnet
wrote currencyservice/environments/default.libsonnet
wrote currencyservice/components/hello.jsonnet
wrote currencyservice/qbec.yaml
</pre>

Переводим шаблон сервиса из yaml в json и кладем его в currencyservice/components/currencyservice.jsonnet:

https://www.convertjson.com/yaml-to-json.htm

И вспоминаем зачем нужен шаблон, параметризуем его. По умолчанию создается два окружения base и default.

<pre>
params.name
params.image
params.containterPort
params.cpu_requests
params.memory_requests
params.cpu_limits
params.memory_limits
params.servicePort
</pre>

Значения по умолчанию берутся из base.libsonnet. Вносим в него вышеуказанные значения.
Значения для default окружения немного изменим и поменяем cpu_limits и memory_limits для теста.

Validate, diff, and apply

https://qbec.io/userguide/tour/#validate-diff-and-apply

<pre>
qbec validate base                                                             
setting cluster to gcp-cluster
setting context to gcp-cluster
cluster metadata load took 1.741s
1 components evaluated in 5ms
✔ deployments currencyservice -n hipster-shop (source currencyservice) is valid
✔ services currencyservice -n hipster-shop (source currencyservice) is valid
---
stats:
  valid: 2

command took 2.04s

qbec validate default                                                         
setting cluster to gcp-cluster
setting context to gcp-cluster
cluster metadata load took 365ms
1 components evaluated in 5ms
✔ services currencyservice -n hipster-shop (source currencyservice) is valid
✔ deployments currencyservice -n hipster-shop (source currencyservice) is valid
---
stats:
  valid: 2

command took 980ms
</pre>
<pre>
qbec show default
</pre>

Без сервиса currencyservice сайт чет приуныл:

<pre>
rpc error: code = Unavailable desc = all SubConns are in TransientFailure, latest connection error: connection error: desc = "transport: Error while dialing dial tcp: lookup currencyservice on 10.12.0.10:53: no such host"
could not retrieve currencies
</pre>

Раскатываем его через qbec:
<pre>
cd kubernetes-templating/jsonnet/currencyservice
qbec apply default                                                    
setting cluster to gcp-cluster
setting context to gcp-cluster
cluster metadata load took 356ms
1 components evaluated in 6ms

will synchronize 2 object(s)

Do you want to continue [y/n]: y
1 components evaluated in 3ms
update deployments currencyservice -n hipster-shop (source currencyservice)
waiting for deletion list to be returned
server objects load took 721ms
---
stats:
  same: 1
  updated:
  - deployments currencyservice -n hipster-shop (source currencyservice)

waiting for readiness of 1 objects
  - deployments currencyservice -n hipster-shop

  0s    : deployments currencyservice -n hipster-shop :: 1 old replicas are pending termination
✓ 7s    : deployments currencyservice -n hipster-shop :: successfully rolled out (0 remaining)

✓ 7s: rollout complete
command took 10.09s
</pre>

Получилось не с первого раза, но взлетело :) и сайт ожил.
</details>

<details>
<summary> <b>Самостоятельное задание №2 Kustomize</b></summary>

Выпиливаю adservice. 

Ставим Kustomize

https://kustomize.io/

https://kubectl.docs.kubernetes.io/installation/kustomize/homebrew/

<pre>
brew install kustomize
</pre>

Краткое введение в Kustomize

https://habr.com/ru/company/flant/blog/469179/

По аналогии c хабром сделаем:

<pre>
- base
  - deployment.yaml
  - service.yaml
  - kustomization.yaml
- overlays
  - dev
    - kustomization.yaml
  - staging
    - kustomization.yaml
  - prod
    - kustomization.yaml
</pre>

<pre> 
tree                                                
.
|-- base
|   |-- adservice-deployment.yaml
|   |-- adservice-service.yaml
|   `-- kustomization.yaml
`-- overlays
    |-- hipster-shop
    |   `-- kustomization.yaml
    `-- hipster-shop-prod
        `-- kustomization.yaml
</pre>

Окружения должны отличаться:
- Набором labels во всех манифестах
- Префиксом названий ресурсов

Проверяем окружения и деплоим:

<pre>
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop/
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop-prod/
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop/ | kubectl apply -f -
kubectl create ns hipster-shop-prod
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop-prod/ | kubectl apply -f -
</pre>

Поскольку окружения hipster-shop и hipster-shop-prod отличаются от нашего варианта либо namespace либо префиксом сделаем для теста еще stage где не будем ставить префикс.

<pre>
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop-stage
kustomize build kubernetes-templating/kustomize/overlays/hipster-shop-stage  | kubectl apply -f -
</pre>

Проверяем в UI работу нашего приунывшего сервиса:
<pre>
https://shop.yogatour.su/
Advertisement: Vintage camera lens for sale. 20% off.

kg deployments.apps -A | grep adservice                                                                                     
hipster-shop-prod   prod-adservice                             1/1     1            1           69s
hipster-shop        adservice                                  1/1     1            1           17m
hipster-shop        dev-adservice                              1/1     1            1           26m
</pre>

</details>

</details>



<details>
<summary> <b>ДЗ №5 - kubernetes-volumes (Хранение данных в Kubernetes: Volumes, Storages, Statefull-приложения)</b></summary>

- [x] Основное ДЗ

- [x] Дополнительно ДЗ


### <b>Основное задание  - StatefulSet с Minio </b>
Развернул Minio и сделали headless service для него

### <b>Дополнительное задание - использование secrets</b> 
Убрал секреты в secret для не явного их хранения в манифесте StatefulSet
Зашифровал credentials.yaml через ansible-vault


</details>
<details>
<summary> <b>ДЗ №4 - kubernetes-network (Сетевая подсистема Kubernetes )</b></summary>

- [x] Основное ДЗ

- [x] Дополнительно ДЗ №1

- [x] Дополнительно ДЗ №2

- [x] Дополнительно ДЗ №3

Minikube развернут так (дабы нормально функционировала маршрутизация): 
https://minikube.sigs.k8s.io/docs/drivers/vmware/

Плюс установлен Vmware Fusion.
Добавил маршрут:
<pre>
sudo route -n add 172.17.255.0/24 192.168.153.2
</pre>

### <b>Основное задание 1 - ClusterIP </b>

Удобны в тех случаях, когда:
- Нам не надо подключаться к конкретному поду сервиса
- Нас устраивается случайное расределение подключений между подами
- Нам нужна стабильная точка подключения к сервису, независимая от
подов, нод и DNS-имен

Например:
- Подключения клиентов к кластеру БД (multi-read) или хранилищу
- Простейшая (не совсем, use IPVS, Luke) балансировка нагрузки внутри
кластера

### <b>Основное задание 2 - Включение IPVS </b>

Что такое IPVS
IPVS (IP Virtual Server) реализует балансировку нагрузки на транспортном уровне, обычно называемую коммутацией LAN уровня 4, как часть ядра Linux.

IPVS работает на хосте и действует как балансировщик нагрузки перед кластером реальных серверов. IPVS может направлять запросы для служб на основе TCP и UDP к реальным серверам и заставлять службы реальных серверов отображаться как виртуальные службы на одном IP-адресе.

IPVS против IPTABLES
Режим IPVS был представлен в Kubernetes v1.8, идет бета-версия в v1.9 и GA в v1.11. Режим IPTABLES был добавлен в v1.1 и стал рабочим режимом по умолчанию, начиная с v1.2. И IPVS, и IPTABLES основаны на netfilter. Различия между режимами IPVS и IPTABLES заключаются в следующем:

IPVS обеспечивает лучшую масштабируемость и производительность для больших кластеров.

IPVS поддерживает более сложные алгоритмы балансировки нагрузки, чем IPTABLES (наименьшая нагрузка, наименьшее количество соединений, местонахождение, взвешенное значение и т. Д.).

IPVS поддерживает проверку работоспособности сервера, повторные попытки подключения и т. Д.

Полезная команда в toolbox внутри ВМ
<pre>
ipvsadm --list -n
</pre>

### <b>Основное задание 3 - Установка MetalLB</b>

MetalLB позволяет запустить внутри кластера L4-балансировщик,
который будет принимать извне запросы к сервисам и раскидывать их
между подами.


- Cделал Load balancer web-svc-lb для web с опубликованным 80-м портом
<pre>
#kubectl describe svc web-svc-lb                                                                      
Name:                     web-svc-lb
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=web
Type:                     LoadBalancer
IP:                       10.107.131.31
LoadBalancer Ingress:     172.17.255.1
Port:                     <unset>  80/TCP
TargetPort:               8000/TCP
NodePort:                 <unset>  32546/TCP
Endpoints:                172.17.0.6:8000,172.17.0.7:8000,172.17.0.8:8000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
</pre>
Присвоен ip <b>172.17.255.1</b>
- Добавили маршрут к сети в миникубе
- Проверил работоспособность 

### <b>Дополнительное задание №1 - DNS через MetalLB</b> 
- Сделаны два манифеста coredns-tcp-svc-lb.yaml и coredns-udp-svc-lb.yaml где создаются сервисы со статичным ip <b>172.17.255.10</b> в ns kube-system с kube-dns

Документация по шарингу сервиса на одном ip:

https://metallb.universe.tf/usage/#ip-address-sharing

Необходимо использовать 
<pre>
annotations:
    metallb.universe.tf/allow-shared-ip
</pre>

<pre>
# nslookup kubernetes.default.svc.cluster.local 172.17.255.10
Server:         172.17.255.10
Address:        172.17.255.10:53


Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
</pre>


### <b>Основное задание 4 - Cоздаем "коробочный" Ingress контроллер ingress-nginx и proxy сервиса</b>
- Cоздание ingress-nginx
<pre>
#NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-7wv4g        0/1     Completed   0          154m
pod/ingress-nginx-admission-patch-t74r2         0/1     Completed   2          154m
pod/ingress-nginx-controller-659dbc6d66-cp52k   1/1     Running     0          154m

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
service/ingress-nginx                        LoadBalancer   10.96.166.218   172.17.255.2   80:30186/TCP,443:30268/TCP   123m
service/ingress-nginx-controller             NodePort       10.105.35.255   <none>         80:31611/TCP,443:31004/TCP   154m
service/ingress-nginx-controller-admission   ClusterIP      10.110.6.221    <none>         443/TCP                      154m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           154m

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-659dbc6d66   1         1         1       154m

NAME                                       COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   1/1           8s         154m
job.batch/ingress-nginx-admission-patch    1/1           24s        154m
</pre>

Для ingress-nginx присвоен ip <b>172.17.255.2</b>

- <b>Подключение приложение Web к Ingress (Создание Headless-сервиса)</b>

Ingress-контроллер не требует ClusterIP для балансировки
трафика
Список узлов для балансировки заполняется из ресурса Endpoints
нужного сервиса (это нужно для "интеллектуальной" балансировки,
привязки сессий и т.п.)
Поэтому мы можем использовать headless-сервис для нашего вебприложения.

Смотрим на различия в ClusterIP для опубликованного headless-сервиса:
<pre>
#kubectl get service/web-svc-cip                                                                    
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
web-svc-cip   ClusterIP   10.109.149.24   <none>        80/TCP    48s
#kubectl get service/web-svc                                                                         
NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
web-svc   ClusterIP   None         <none>        80/TCP    106m
</pre>

Ошибка:
<pre>
Error from server (InternalError): error when creating "web-ingress.yaml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": an error on the server ("") has prevented the request from succeeding
</pre>

Решение ошибки:
https://stackoverflow.com/questions/61365202/nginx-ingress-service-ingress-nginx-controller-admission-not-found

- <b>Создание правил Ingress, настройка ingress-прокси</b>
<pre>
networking.k8s.io/v1beta1 уже устарела о чем выводится предупреждение
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
Лучше сразу делать на networking.k8s.io/v1 чуть изменив манифест
</pre>

Просмотр созданного правила:
<pre>
#kubectl describe ingress/web
Name:             web
Namespace:        default
Address:          192.168.153.2
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /web   web-svc:8000 (172.17.0.3:8000,172.17.0.4:8000,172.17.0.5:8000)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
Events:       <none>
</pre>
Заметим что есть ошибка (error: endpoints "default-http-backend" not found)

### <b>Дополнительное задание №2 - Ingress для Dashboard</b>

Install

To deploy Dashboard, execute following command:
<pre>
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
</pre>
Создан dashboard-ingress.yaml методом гугления на 443 порту. Иначе не будет работать авторизация.

Используем аннотацию:
<pre>
nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
</pre>

Cервис становится доступным по следующей ссылке:
<pre>
https://172.17.255.2/dashboard/
</pre>

Авторизация:
<pre>
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
</pre>

### <b>Дополнительное задание №3 - Canary для Ingress</b>
Что нам нужно сделать?
- Создаем Deployment <b>prod</b> с нужным нам приложением.
- Создаем Headless-сервис svc-prod с app <b>prod</b> с соответсвующими портами
- Делаем Ingress правило для svc-prod
Проверяем:
<pre>
curl http://172.17.255.2/production
</pre>

- Создаем Deployment <b>canary</b> с нужным нам приложением и replicas: 1  на то она и canary
- Создаем Headless-сервис svc-canary с app <b>canary</b> с соответсвующими портами
- Создаем Ingress правило для svc-canary используя в аннотации canary-by-header и canary-by-header-value:

<pre>
  annotations:
    ... 
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "canary" 
    nginx.ingress.kubernetes.io/canary-by-header-value: "true"
    ...
</pre>
др. МАН:

https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary

Поверяем:
<pre>
#for i in $(seq 1 10); do curl -s -H "canary: true" http://172.17.255.2/production | grep "HOSTNAME="; done
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'

Если используем веса:
...
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "50"
....

#for i in $(seq 1 10); do curl -s http://172.17.255.2/production | grep "HOSTNAME="; done 
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='prod-7978c597c-8qsfc'
export HOSTNAME='prod-7978c597c-8qsfc'
export HOSTNAME='prod-7978c597c-7zg2m'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='canary-7ccb57755d-dtg4z'
export HOSTNAME='prod-7978c597c-7zg2m'
export HOSTNAME='prod-7978c597c-vhksb'
</pre>
</details>

<details>
<summary>
<b>ДЗ №3 - kubernetes-security (Безопасность и управление доступом )</b>
</summary>

- [x] Основное ДЗ

### <b>Основное задание 1</b>
- Создать Service Account bob, дать ему роль admin в рамках всего кластера
- Создать Service Account dave без доступа к кластеру

<pre>
#Посмотреть имя токена у bob
kubectl get serviceaccounts bob -o yaml
kubectl describe serviceaccounts bob
Вытащить и декодировать токен сервис аккаунта bob
kubectl get secret bob-token-rv77h -o "jsonpath={.data.token}" | base64 -D
</pre>
Конфигурационный файл доступу к кластеру получается токой (client-key-data берем из kubectl get secret bob-token-rv77h -o yaml):
<pre>
apiVersion: v1
clusters:
- cluster:
- cluster:
    certificate-authority-data:
    ....
    server: https://127.0.0.1:65082
  name: kind-kind
contexts:
- context:
    cluster: kind-kind
    user: kind-bob
  name: kind-bob
- context:
    cluster: kind-kind
    user: kind-dave
  name: kind-dave
- context:
    cluster: kind-kind
    user: kind-kind
  name: kind-kind
current-context: kind-bob
kind: Config
preferences: {}
users:
- name: kind-bob
  user:
    client-key-data: 
    .....
    token: 
    .....
- name: kind-kind
  user:
    client-certificate-data: 
    .....
    client-key-data: 
    .....
- name: kind-dave
  user:
    client-key-data: 
    .....
    token: 
    ..... 
</pre>

Результат:
<pre>
(kind-bob # N/A) antonchudin@mir ~# kubectl config use-context kind-bob                                                                      
Switched to context "kind-bob".
(kind-bob # N/A) antonchudin@mir ~# kubectl get nodes                                                                                                     
Error from server (Forbidden): nodes is forbidden: User "system:serviceaccount:default:bob" cannot list resource "nodes" in API group "" at the cluster scope
(kind-bob # N/A) antonchudin@mir ~# kubectl get pods                                                                          
NAME                              READY   STATUS    RESTARTS   AGE
frontend-5776587b79-g2slw         1/1     Running   0          28h
frontend-5776587b79-g79cw         1/1     Running   0          28h
frontend-5776587b79-r9kn6         1/1     Running   0          28h
paymentservice-7bc7f8b757-hm25q   1/1     Running   0          28h
paymentservice-7bc7f8b757-wl4ss   1/1     Running   0          28h
paymentservice-7bc7f8b757-xpt9b   1/1     Running   0          28h

(kind-kind # N/A) antonchudin@mir ~# kubectl config use-context kind-dave                                                                                 
Switched to context "kind-dave".
(kind-dave # N/A) antonchudin@mir ~# kubectl get nodes                                                                                                    
error: You must be logged in to the server (Unauthorized)
(kind-dave # N/A) antonchudin@mir ~# kubectl get pods                                                                          
error: You must be logged in to the server (Unauthorized)
(kind-dave # N/A) antonchudin@mir ~# cat .kube/config  

Или так
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i get pods -A --as system:serviceaccount:default:bob 
yes
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i get pods -A --as system:serviceaccount:default:dave
no
</pre>

### <b>Основное задание 2</b>
- Создать Namespace prometheus
- Создать Service Account carol в этом Namespace
- Дать всем Service Account в Namespace prometheus возможность делать get, list, watch в отношении Pods всего кластера
<pre>
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i get pods --as system:serviceaccount:prometheus:carol 
yes
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i delete pods --as system:serviceaccount:prometheus:carol
no
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i watch pods --as system:serviceaccount:prometheus:carol
yes
</pre>

### <b>Основное задание 3</b>
- Создать Namespace dev
- Создать Service Account jane в Namespace dev
- Дать jane роль admin в рамках Namespace dev
- Создать Service Account ken в Namespace dev
- Дать ken роль view в рамках Namespace dev

<pre>
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i get pods -A --as system:serviceaccount:dev:jane
no
(kind-kind # ) antonchudin@mir ~# kubectl auth can-i get pods -n dev --as system:serviceaccount:dev:jane
yes
(kind-kind # N/A) antonchudin@mir ~# kubectl auth can-i get pods -n dev --as system:serviceaccount:dev:ken                                                
yes
(kind-kind # N/A) antonchudin@mir ~# kubectl auth can-i delete pods -n dev --as system:serviceaccount:dev:ken                                             
no
(kind-kind # N/A) antonchudin@mir ~# kubectl auth can-i delete pods -n dev --as system:serviceaccount:dev:jane
yes
</pre>
</details>
<details>
<summary>
<b>ДЗ №2 - kubernetes-controllers (Механика запуска и взаимодействия контейнеров в Kubernetes )</b></summary>

- [x] Основное ДЗ

- [x] Дополнительно ДЗ №1

- [x] Дополнительно ДЗ №2

- [x] Дополнительно ДЗ №3

### <b>Основное задание</b>

- Установка kind и поднятие кластера
<pre>
#brew install kind
#cat kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
#kind create cluster --config kind-config.yaml

</pre>

- Изучение ReplicaSet контроллера
- Разворот frontend в ReplicaSet
<pre>
Контроллер ReplicaSet не позволяет проводить обновление pod'ов при изменении манифеста. Для развертывания и обновления приложения лучше использовать Deployment
</pre>
- Изучение контроллера Deployment
- Сборка Docker образов paymentservice
- Разворот paymentservice с помощью Deployment
- Обновление Deployment paymentservice и Rollback
- Изучение readinessProbe

### <b>Дополнительное задание №1</b>
- Написание двух стратегий обновления Deployment: Аналог blue-green и Reverse Rolling Update
### <b>Дополнительное задание №2</b>
- Изучение DaemonSet на примере Node Exporter и разворот на worker нодах c namespace monitoring
<pre>
Воспользовался готовым решением:
https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests
</pre>
### <b>Дополнительное задание №3</b>
- Развернул Node Exporter на мастерах используя соответствующий допуск самому поду:
<pre>
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: "Exists"
        effect: NoSchedule
</pre>

Результат:
<pre>
#kubectl get all -n monitoring                                                                          
NAME                      READY   STATUS    RESTARTS   AGE
pod/node-exporter-g5vrh   2/2     Running   0          2m11s
pod/node-exporter-gsbxs   2/2     Running   0          2m11s
pod/node-exporter-jmg2f   2/2     Running   0          2m11s
pod/node-exporter-tzwjv   2/2     Running   0          2m12s
pod/node-exporter-wmg7g   2/2     Running   0          2m11s
pod/node-exporter-xhp59   2/2     Running   0          2m11s

NAME                    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/node-exporter   ClusterIP   None         <none>        9100/TCP   2m12s

NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/node-exporter   6         6         6       6            6           kubernetes.io/os=linux   2m12s
</pre>
</details>

<details>
<summary>
<b>ДЗ №1 kubernetes-intro (Знакомство с Kubernetes, основные понятия и архитектура )</b></summary>

- [x] Основное ДЗ

- [x] Дополнительно ДЗ №1

### <b>Основное задание</b>

- Подготовка репозитория для выполнения ДЗ. (travis + служебные файлы)

Настройка локального окружения:
- Установка kubectl
- Установка Minikube & Запуск Minikube  (использую драйвер docker, иначе есть проблема с днс, не скачиваются образы с dockerhub)
<pre>
minikube start --driver=docker
</pre>
- Dashboard & k9s
- Изучение задания по автовостановлению системны подов после удаления.

Ответ:
<pre>
kube-scheduler, kube-controller-manager, kube-apiserver, etcd стартует благодаря kubelet, они описаны в манифестах /etc/kubernetes/manifests
Где в частности есть и проверки состояния livenessProbe

Документация:
https://kubernetes.io/docs/concepts/workloads/pods/#static-pods

coredns запущен как Deployments c ReplicaSet
Документация:
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

kube-proxy запусскается как DaemonSet и перезапускается/запускатеся автоматически на каждой ноде.
Документация:
https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
</pre>
- Генерация Dockerfile из nginx:latest + загрузка Docker Hub
- Написание web-pod.yaml манифеста для запуска Pod web из созданного Dockerfile лежащего на Docker Hub
- Ознакомление с базовым траблшутингом для Pod
- Добавление Init контейнера генерирующий страницу index.html.
- Подключение Volumes
- Запуск приложения

Проверка работы приложения:
<pre>
kubectl port-forward --address 0.0.0.0 pod/web 8000:8000
</pre>

- Установка и настройка kube-forwarder для удобства
- Генерация frontend Dockerfile загрузка на Docker Hub
- Изучение ad-hoc режима

### <b>Дополнительное задание Hipster Shop frontend</b>
- Добавляем недостающие env необходимые для работы.
- В результате, после применения исправленного манифеста pod
frontend должен находиться в статусе Running
</details>
