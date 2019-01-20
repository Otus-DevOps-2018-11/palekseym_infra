provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "ssh-key" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
  }
}

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

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

# Обьединение в группу

resource "google_compute_instance_group" "puma-group" {
  name = "puma-group"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  named_port {
    name = "http"
    port = "9292"
  }

  zone = "${var.zone}"
}

resource "google_compute_http_health_check" "puma-health" {
  name               = "puma-health"
  request_path       = "/"
  timeout_sec        = 5
  check_interval_sec = 10
  port               = "9292"
}

resource "google_compute_backend_service" "puma-backend" {
  name        = "puma-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.puma-group.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.puma-health.self_link}"]
}

resource "google_compute_url_map" "puma-urlmap" {
  name            = "puma-urlmap"
  default_service = "${google_compute_backend_service.puma-backend.self_link}"
}

resource "google_compute_target_http_proxy" "puma-proxy" {
  name    = "proxy-puma"
  url_map = "${google_compute_url_map.puma-urlmap.self_link}"
}

resource "google_compute_global_forwarding_rule" "puma-forwarding-rule" {
  name       = "puma-website"
  target     = "${google_compute_target_http_proxy.puma-proxy.self_link}"
  port_range = "80"
}
