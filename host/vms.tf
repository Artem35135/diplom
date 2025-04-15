
#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}


resource "yandex_compute_instance" "bastion" {
  name        = "bastion"  #Имя ВМ в облачной консоли
  hostname    = "bastion" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v1"
  zone        = "ru-central1-a"  #зона ВМ должна совпадать с зоной subnet!!!

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./bastion-cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }
}

resource "yandex_compute_instance" "web_a" {
  name        = "web-a"  #Имя ВМ в облачной консоли
  hostname    = "web-a" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v1"
  zone        = "ru-central1-a" #зона ВМ должна совпадать с зоной subnet!!!
    

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }
}

resource "yandex_compute_instance" "web_b" {
  name        = "web-b"  #Имя ВМ в облачной консоли
  hostname    = "web-b" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v1"
  zone        = "ru-central1-b" #зона ВМ должна совпадать с зоной subnet!!!

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  
  }
}

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix-server"  
  hostname    = "zabbix" 
  platform_id = "standard-v1"
  zone        = "ru-central1-a"  
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  metadata = {
    user-data          = file("./zabbix-cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = true
    security_group_ids = [yandex_vpc_security_group.zabbix_security_group.id]
  }
}

resource "yandex_compute_instance" "elastic" {
  name        = "elastic"  
  hostname    = "elastic" 
  platform_id = "standard-v1"
  zone        = "ru-central1-a"  
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  
  allow_stopping_for_update = true
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
  
  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }

  connection {
    type        = "ssh"
    user        = "user"
    private_key = "${file("~/.ssh/id_ed25519")}"
    host = yandex_compute_instance.elastic.network_interface[0].ip_address
  }
}


resource "yandex_compute_instance" "kibana" {
  name        = "kibana"  
  hostname    = "kibana" 
  platform_id = "standard-v1"
  zone        = "ru-central1-a"  
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  allow_stopping_for_update = true

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id #зона ВМ должна совпадать с зоной subnet!!!
    nat       = true
    security_group_ids = [yandex_vpc_security_group.kibana_security_group.id]
  }
}


resource "local_file" "inventory" {
  content  = <<-EOF
  [bastion]
  ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

  [webservers]
  ${yandex_compute_instance.web_a.fqdn}
  ${yandex_compute_instance.web_b.fqdn}

  [zabbix]
  ${yandex_compute_instance.zabbix.fqdn}

  [elastic]
  ${yandex_compute_instance.elastic.fqdn}

  [kibana]
  ${yandex_compute_instance.kibana.fqdn}

  [all]
  ${yandex_compute_instance.bastion.fqdn}
  ${yandex_compute_instance.web_a.fqdn}
  ${yandex_compute_instance.web_b.fqdn}
  ${yandex_compute_instance.elastic.fqdn}
  ${yandex_compute_instance.kibana.fqdn}

  [webserver:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  EOF
  filename = "./hosts.ini"
}

resource "local_file" "config" {
  content  = <<-EOF
  Host ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
      User user
  Host 10.0.*
      ProxyJump ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
      User user
  EOF
  filename = "/home/art/.ssh/config"
}

