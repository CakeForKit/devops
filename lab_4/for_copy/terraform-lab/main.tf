terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# провайдер для подключения к локальному Docker
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Создаём ресурс типа local_file. Имя ресурса — nginx_index
resource "local_file" "nginx_index" {
  filename = abspath("${path.module}/nginx-content/index.html")
  content  = "<h1>Hello from Nginx Container!</h1><p>This page is served by Nginx.</p>"
}

resource "docker_container" "nginx" {
  name  = "my-nginx"
  image = "nginx:latest"
  memory = 256
  cpus   = 0.5

  volumes {
    host_path      = abspath("${path.module}/nginx-content")
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = 8082 # Какой порт на хосте будет открыт
  }
}

resource "local_file" "caddy_config" {
  filename = abspath("${path.module}/caddy-content/Caddyfile")
  content  = <<-EOT
    :80 {
        root * /usr/share/caddy
        file_server
    }
  EOT
}

resource "docker_container" "caddy" {
  name  = "my-caddy"
  image = "caddy:latest"
  memory = 256
  cpus    = 0.5

  volumes {
    host_path      = abspath("${path.module}/caddy-content/Caddyfile")
    container_path = "/etc/caddy/Caddyfile"
  }

  ports {
    internal = 80
    external = 8083 
  }
}

output "nginx_access" {
  value = "Nginx is available at http://192.168.170.138:8082"
}

output "caddy_access" {
  value = "Caddy is available at http://192.168.170.138:8083"
}