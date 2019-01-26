output "balancer_ip" {
  value = "${google_compute_global_forwarding_rule.puma-forwarding-rule.ip_address}"
}
