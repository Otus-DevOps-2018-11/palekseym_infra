variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "sapient-cycling-225707"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key_path {
  description = "Private ssh key for provisioning"
}

variable zone {
  description = "Zone for creat instance"
  default     = "europe-west4-a"
}

variable instance_count {
  description = "Count VM"
  default     = "1"
}
