terraform {
  backend "gcs" {
    bucket = "alex-terraform-state"
    prefix = "prod"
  }
}
