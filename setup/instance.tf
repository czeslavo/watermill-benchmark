provider "google" {
  credentials = "${file(var.credentials_path)}"
  project     = "${var.project}"
  region      = "europe-west3"
}

data "google_compute_image" "ubuntu_18" {
  family  = "ubuntu-1904"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "default" {
  name         = "benchmark-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  machine_type = "n1-highcpu-16"
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      size  = 128
      type = "pd-ssd"
      image = "${data.google_compute_image.ubuntu_18.self_link}"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "benchmark:${file(var.pub_key_path)}"
  }

  metadata_startup_script = "${file("startup.sh")}"
}

output "public_ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

variable "credentials_path" {}
variable "project" {}
variable "pub_key_path" {}
