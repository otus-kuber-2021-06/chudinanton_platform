# chudinanton_platform
chudinanton Platform repository
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
