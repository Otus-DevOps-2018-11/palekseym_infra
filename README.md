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

