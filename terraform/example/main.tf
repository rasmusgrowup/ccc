# ---- ASSIGNMENT ----
#   Submit:

#   Terraform IaC code you created (the entire repo / folder)
#   Commands you used / screenshots of the configuration you made
#   You must use Terraform to solve the exercises.

#   Create a non-default auto mode VPC network
#   Deploy a VM instance in the VPC network's subnet that is related the europe-north1 region
#   Create a firewall rule that allows HTTP traffic to the VM instance

# Set the required provider and version
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0.0"
}

# Provider Configuration
provider "google" {
  project = var.project_id
  region  = "europe-north1"
}

# Create VPC Network
resource "google_compute_network" "custom_vpc" {
  name                    = "custom-auto-vpc"
  auto_create_subnetworks = false
}

# Create Subnet in europe-north1
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet-europe-north1"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-north1"
  network       = google_compute_network.custom_vpc.id
}

# Create a VM Instance
resource "google_compute_instance" "vm_instance" {
  name         = "vm-instance"
  machine_type = "e2-medium"
  zone         = "europe-north1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    access_config {}
  }
}

# Create Firewall Rule to Allow HTTP Traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Add tags to the VM for firewall rule
resource "google_compute_instance" "vm_instance_tags" {
  instance = google_compute_instance.vm_instance.name
  tags     = ["http-server"]
}

# --- SECTION: Outputs ---
output "vm_instance_external_ip" {
  description = "The external IP of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

# --- SECTION: Variables ---
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}