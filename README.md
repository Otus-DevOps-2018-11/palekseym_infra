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

# ДЗ 6

## Здание *
После того как добавили ssh ключ руками через web интерфейс, при выполнении terraform apply обнаружил расхождение с тем состоянием что известно ему и удалил добавленный вручную ключ ssh, чтобы привести состояние к тому что описанного у terraform.

Пример конфигурации для нескольких пользователей через метаданные проекта

```
resource "google_compute_project_metadata" "ssh-key" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
  }
}
```

## Здание **
Настройки балансировщика лежат в файле lb.tf
При добавлении второго экземпляра копирования методом копирования появляются следующие проблемы:
 - Затруднительно повторное использование кода
 - При изменение какого-то параметра придется отдельно вносить изменения в описание каждого ресурса
 - При копировании получается много излишнего кода

Пример создание экземпляров через задание необходимого количества в переменной

```
resource "google_compute_instance" "app" {
  count        = "${var.instance_count}"
  name         = "${format("reddit-app-%03d", count.index + 1)}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }
}
```

# ДЗ 7. Terraform: ресурсы, модули, окружения и работа в команде

## Здание со *
Для каждого окружения используется свой файл backend.tf размещенный в корне папки окружения
### Описание для бекенда prod

```
terraform {
   backend "gcs"{
       bucket="alex-terraform-state"
       prefix = "prod"
   }
}
```

### Описание для бекенда stage

```
terraform {
   backend "gcs"{
       bucket="alex-terraform-state"
       prefix = "stage"
   }
}
```
### Расположение состояния
Терраформ настроен на хранение состояния в удаленном бакете
Можно убедится, что локально не хранит состояние
```
tay@ubuntu:~/repo/palekseym_infra/terraform/stage$ ll
total 32
drwxrwxr-x 3 tay tay 4096 Jan 26 05:33 ./
drwxrwxr-x 7 tay tay 4096 Jan 26 04:57 ../
-rw-rw-rw- 1 tay tay  106 Jan 26 05:31 backend.tf
-rw-rw-rw- 1 tay tay  537 Jan 22 08:22 main.tf
-rw-rw-rw- 1 tay tay   71 Jan 22 08:16 outputs.tf
drwxr-xr-x 4 tay tay 4096 Jan 26 05:33 .terraform/
-rw-rw-rw- 1 tay tay  156 Jan 22 08:16 terraform.tfvars
-rw-rw-rw- 1 tay tay  735 Jan 22 08:16 variables.tf
```

Но при этом он видит текущее состояние

```
tay@ubuntu:~/repo/palekseym_infra/terraform/stage$ terraform state list
module.app.google_compute_address.app_ip
module.app.google_compute_firewall.firewall_puma
module.app.google_compute_instance.app
module.db.google_compute_firewall.firewall_mongo
module.db.google_compute_instance.db
module.vpc.google_compute_firewall.firewall_ssh
```

### Проверка блокировок
проверить можно запустив `terraform applay` параллельно. в удаленном бакете создаться файл default.tflock и при повторном запуске выпадет ошибка
```
tay@ubuntu:~/repo/palekseym_infra/terraform/stage$ terraform apply
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://alex-terraform-state/stage/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1548510806879323
  Path:      gs://alex-terraform-state/stage/default.tflock
  Operation: OperationTypeApply
  Who:       tay@ubuntu
  Version:   0.11.11
  Created:   2019-01-26 13:53:26.74056728 +0000 UTC
  Info:


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
```

## Задание с **
### Добавлен provisioner
Для того чтобы инстансы подымались с приложением были сделаны следующие изменения.
* пересобран образ reddit-db-base для того чтобы mongo запускалось не на localhost интерфейсе
* Добавлен код для провижинга в модуль app
```
  provisioner "file" {
    source      = "../modules/app/files/puma.service"
    destination = "/tmp/puma.service"
  }
  # передача ip дареса для подключения к базе данных mongo
    provisioner "remote-exec" {
    inline = [
      "echo 'DATABASE_URL=${var.database_url}' >> ~/db_config"
    ]
  }
# диплой приложения
  provisioner "remote-exec" {
    script = "../modules/app/files/deploy.sh"
  }


  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
```
* в модуль app добавлены файлы deploy.sh и puma.service
* передача ip адреса приложению reddit выполнена в момент провижинга app через файл `/home/appuser/db_config` в puma.service добавлена строчка `EnvironmentFile=/home/appuser/db_config`
