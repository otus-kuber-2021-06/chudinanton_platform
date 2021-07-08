# chudinanton_platform
chudinanton Platform repository
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
