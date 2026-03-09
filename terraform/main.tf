provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# -----------------------------
# VPC Network
# -----------------------------
resource "google_compute_network" "vpc_network" {
  name                    = "web-vpc-network"
  auto_create_subnetworks = true
}

# -----------------------------
# Firewall Rule
# -----------------------------
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# -----------------------------
# Instance Template
# -----------------------------
resource "google_compute_instance_template" "web_template" {
  name         = "web-server-template"
  machine_type = "e2-micro"

  tags = ["web-server"]

  disk {
    boot         = true
    auto_delete  = true
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
    }
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              apt update
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Scalable Web Server Running on GCP</h1>" > /var/www/html/index.html
              EOF
}

# -----------------------------
# Managed Instance Group
# -----------------------------
resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "web-instance-group"
  base_instance_name = "web"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  target_size = 2
}

# -----------------------------
# Autoscaler
# -----------------------------
resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_mig.id

  autoscaling_policy {
    max_replicas = 4
    min_replicas = 2

    cpu_utilization {
      target = 0.6
    }
  }
}
