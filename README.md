# palekseym_infra
palekseym Infra repository

bastion_IP = 35.204.67.210
someinternalhost_IP = 10.164.0.3

Предварительная подготовка:

- Запустить ssh-agent `eval $(ssh-agent)`
- Загрузить ssh ключ `ssh-add` 

Вариант подключения к someinternalhost в одну строку
`ssh -A Tay@35.204.67.210 ssh -tt 10.164.0.3`
Результат
```
tay@ubuntu:~$ ssh -A Tay@35.204.67.210 ssh -tt 10.164.0.3
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.15.0-1025-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Mon Jan  7 11:32:43 2019 from 10.164.0.2
Tay@someinternalhost:~$
```

Подключение к someinternalhost через алиас
Создать в папке пользователя на рабочем устройстве файл .ssh/confg
```
Host bastion
HostName 35.204.67.210
User Tay

Host someinternalhost
HostName 10.164.0.3
IdentityFile /home/tay/.ssh/id_rsa
User Tay
ProxyCommand ssh -W %h:%p -A bastion someinernalhost
```
После этого можно подключиться с помощью команды `ssh someinternalhost`

Результат
```
tay@ubuntu:~$ ssh someinternalhost
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.15.0-1025-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Mon Jan  7 11:54:34 2019 from 10.164.0.2
Tay@someinternalhost:~$
```

# ДЗ 4
## Параметры для автоматических тестов
testapp_IP = 35.204.21.83
testapp_port = 9292

## Команда для создания разрешающего правила фаервола
`gcloud compute --project=sapient-cycling-225707 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server`

Результат
```
tay@ubuntu:~/repo/palekseym_infra$ gcloud compute --project=sapient-cycling-225707 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
Creating firewall...⠏Created [https://www.googleapis.com/compute/v1/projects/sapient-cycling-225707/global/firewalls/default-puma-server].
Creating firewall...done.
NAME                 NETWORK  DIRECTION  PRIORITY  ALLOW     DENY  DISABLED
default-puma-server  default  INGRESS    1000      tcp:9292        False

```
## Команда для создания инстанса с использованием startup-script
`gcloud compute instances create reddit-app --boot-disk-size=10GB --zone=europe-west4-c --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --metadata startup-script-url=https://gist.githubusercontent.com/palekseym/6ca75b7d8d04086b5b6f11807f4fcf1f/raw/12100ca1595452c33a4507631b688e6888aef705/startup_script.sh`

Результат
```
tay@ubuntu:~/repo/palekseym_infra$ gcloud compute instances create reddit-app --boot-disk-size=10GB --zone=europe-west4-c --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --metadata-from-file startup-script=startup_script.sh
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/sapient-cycling-225707/zones/europe-west4-c/instances/reddit-app].
NAME        ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
reddit-app  europe-west4-c  g1-small                   10.164.0.2   35.204.21.83  RUNNING
```

# ДЗ 5
# Было сделано
 - Получены практические навыки работы с packer
 - Выполнены два задания со звездочкой
 - Создан шаблон packer для подготовки reddit-base образа. Шаблон находится в файле packer/ubuntu16.json. Чувствительные переменные вынесены в файл переменных packer/variables.json.
 - Создан шаблон packer для подготовки образа reddit-full на основе образа reddit-base. Шаблон находится в файле packer/immutable.json. Чувствительные переменные вынесены в файл переменных packer/variables-immutable.json. в образе содержится приложение.
 - Создан скрипт создания виртуально машины config-scripts/create-redditvm.sh
