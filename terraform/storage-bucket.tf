provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

module "storage-bucket" {
  source  = "modules/storage-bucket"
  version = "0.1.1"
  name    = ["alex-terraform-state"]
}
