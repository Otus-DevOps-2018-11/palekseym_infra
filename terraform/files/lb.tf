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

# Создание проверки на доступность
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
