Дипломная работа по профессии «Системный администратор»

Содержание
Задача
Инфраструктура
Сайт
Мониторинг
Логи
Сеть
Резервное копирование
Дополнительно
Выполнение работы
Критерии сдачи
Как правильно задавать вопросы дипломному руководителю
Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, 
сбор логов и резервное копирование основных данных. 
Инфраструктура должна размещаться в Yandex Cloud и отвечать минимальным стандартам безопасности: 
   запрещается выкладывать токен от облака в git. Используйте инструкцию.

Перед началом работы над дипломным заданием изучите Инструкция по экономии облачных ресурсов.

Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена 
виртуальных машин в зоне ".ru-central1.internal". 
Пример: example.ru-central1.internal - для этого достаточно при создании ВМ указать name=example, hostname=examle !!

Важно: используйте по-возможности минимальные конфигурации ВМ:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая.

Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю 
сделайте ваши ВМ постоянно работающими.

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. 
Пункты взаимосвязаны и могут влиять друг на друга.

Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. 
ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. 
Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

Создайте Target Group, включите в неё две созданных ВМ.

Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, 
протокол HTTP.

Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.

Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. 
Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт curl -v <публичный IP балансера>:80

Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix.

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) 
для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, 
настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. 
Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. 
Эта вм будет реализовывать концепцию bastion host . Синоним "bastion host" - "Jump host". 
Подключение ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью ProxyCommand. 
Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через NAT-шлюз.

Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.





1. Создание виртуальной сети, подсетей, групп безопасности
https://github.com/Artem35135/diplom/blob/main/host/network.tf

2. Установка виртуальных машин
https://github.com/Artem35135/diplom/blob/main/host/vms.tf

3. Подключение по ssh на ВМ bastion
ssh 51.250.68.108

4. Установка nginx на ВМ web_a и  web_b
https://github.com/Artem35135/diplom/blob/main/bastion/nginx.yml

5. Установка elasticsearch на ВМ elastic

  6.1. Установка docker
  https://github.com/Artem35135/diplom/blob/main/bastion/docker_elasticvm.yml

  6.2 Установка elasticsearch
  https://github.com/Artem35135/diplom/blob/main/bastion/elastic.yml
  https://github.com/Artem35135/diplom/blob/main/bastion/docker-compose.yml

6. Установка filebeat на ВМ web_a и  web_b
https://github.com/Artem35135/diplom/blob/main/bastion/filebeat.yml

7. Установка kibana
https://github.com/Artem35135/diplom/blob/main/bastion/kibana.yml

8. Установка zabbix-server
https://github.com/Artem35135/diplom/blob/main/bastion/zabbix.yml

9. Установка zabbix-agent на все ВМ
https://github.com/Artem35135/diplom/blob/main/bastion/zabbix-agent.yml


Сайт http://158.160.181.26/

Скриншоты zabbix
https://github.com/Artem35135/diplom/blob/main/screenshots/zabbix_dashboard.jpg
https://github.com/Artem35135/diplom/blob/main/screenshots/zabbix_hosts.jpg

Скриншот kibana
https://github.com/Artem35135/diplom/blob/main/screenshots/kibana_dashboard.jpg

Снимки дисков
https://github.com/Artem35135/diplom/blob/main/screenshots/%D1%81%D0%BD%D0%B8%D0%BC%D0%BA%D0%B8%20%D0%B4%D0%B8%D1%81%D0%BA%D0%BE%D0%B2.jpg
