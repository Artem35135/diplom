# target группа

resource "yandex_alb_target_group" "tar_gr" {
  name = "tar-gr"

  target {
    subnet_id  = yandex_vpc_subnet.develop_a.id
    ip_address = yandex_compute_instance.web_a.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.develop_b.id
    ip_address = yandex_compute_instance.web_b.network_interface.0.ip_address
  }
}

# backend группа


resource "yandex_alb_backend_group" "backend_gr" {
  name                     = "backend-gr"
  
  http_backend {
    name                   = "bkend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.tar_gr.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }
    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15
      http_healthcheck {
        path               = "/"
        host            = ""
      }
    }
  }
}

# http роутер

resource "yandex_alb_http_router" "tf_router" {
  name          = "tf-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my_virtual_host" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.tf_router.id
  route {
    name                  = "route-to-web"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.backend_gr.id
        timeout           = "60s"
      }
    }
  }
}

# L7 балансировщик

resource "yandex_alb_load_balancer" "l7-balancer-zav" {
  name        = "l7-balancer-zav"
  network_id  = yandex_vpc_network.develop.id
  security_group_ids = [yandex_vpc_security_group.alb_security_group.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.develop_a.id
      
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.develop_b.id
      
    }
  }
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf_router.id
      }
    }
  }
  
}
