provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

resource "google_compute_instance_template" "web_template" {
  name         = "web-template"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

  metadata_startup_script = file("../startup-script.sh")
}

resource "google_compute_instance_group_manager" "web_group" {
  name               = "web-mig"
  base_instance_name = "web-instance"
  zone               = "us-central1-a"

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  target_size = 2
}
