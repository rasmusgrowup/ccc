# --- Terraform Initialization ---
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"  # Specifies the Google Cloud provider plugin.
      version = "~> 4.0"            # Ensures compatibility with provider version 4.x.
    }
  }

  required_version = ">= 1.0.0"     # Requires Terraform CLI version 1.0.0 or higher.
}

# Instructions:
# 1. Ensure you have Terraform installed on your machine.
#    - Check the version by running `terraform -version`.
#    - If needed, download the latest version from https://www.terraform.io/downloads.
#
# 2. The "required_providers" block specifies that this configuration uses the
#    Google Cloud provider plugin. Terraform will download this plugin automatically.
#
# 3. The "required_version" block ensures compatibility with your Terraform CLI version.
#    Update this version constraint if you're using a newer Terraform version.
#
# 4. After editing this file, run `terraform init` to download the required provider plugins.

# --- Provider Configuration ---
provider "google" {
  project = var.project_id   # Specifies the GCP project where resources will be created.
  region  = var.region       # Specifies the default region for resource creation.
}

# Instructions:
# 1. The "project" and "region" attributes tell Terraform where to deploy your resources.
#    - "var.project_id" and "var.region" are variables defined at the bottom of the page.
#    - Replace these with static values if needed, e.g.:
#      project = "my-project-id"
#      region  = "europe-north1"
#
# 2. To find your project ID:
#    - Go to the Google Cloud Console (https://console.cloud.google.com/).
#    - Look in the top navigation bar or the "Project Info" section of the dashboard.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud projects list` to see a list of projects with their IDs.
#
# 3. The "region" attribute specifies the default location for resources.
#    - Example values: "europe-north1", "us-central1", "asia-southeast1".
#    - To see available regions, visit:
#      https://cloud.google.com/compute/docs/regions-zones
#    - Or run `gcloud compute regions list`.
#
# 4. Make sure your Terraform service account or credentials have the necessary permissions
#    for the specified project. You can authenticate using:
#    - `gcloud auth application-default login` (for local development).
#    - A service account key file (set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable).

# --- SECTION: VPC Configuration ---
# --- Option 1: Create a new VPC ---
# This block creates a new custom VPC in your GCP project.

resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"  # Specify the name for your new VPC.
  auto_create_subnetworks = false         # Set to false to prevent automatic subnet creation.
}

# Instructions:
# 1. The "name" attribute defines the name of the new VPC. You can change "custom-vpc"
#    to a name that follows your project's naming conventions.
#    Example: "exam-custom-vpc" or "project-network".
#
# 2. The "auto_create_subnetworks" attribute determines whether Google Cloud should
#    automatically create default subnets in all regions.
#    - Set it to "false" if you want full control over subnet creation (recommended for exams).
#    - Set it to "true" if you want GCP to create default subnets in all regions automatically.
#
# 3. After applying this configuration, the new VPC will be created in your project.
#    To verify:
#    - Open the Google Cloud Console (https://console.cloud.google.com/).
#    - Navigate to "VPC network" under Networking and check for the new VPC.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute networks list` to see all networks, including your new VPC.
#
# 4. Ensure the "custom-vpc" name does not conflict with any existing VPC in your project.

# --- Option 2: Use an existing VPC ---
# This block retrieves details of an existing VPC in your GCP project.
# You need to replace "existing-vpc-name" with the name of your existing VPC.
data "google_compute_network" "existing_vpc" {
  name = "existing-vpc-name"
}

# Instructions for VPC Option 2:
# 1. Open the Google Cloud Console (https://console.cloud.google.com/).
# 2. Navigate to the "VPC network" section (Networking > VPC network).
# 3. Find the VPC you want to use and note its name from the "Name" column.
# 4. Replace "existing-vpc-name" above with the exact name of your chosen VPC.
# 5. Alternatively, you can use the `gcloud` CLI:
#    - Run `gcloud compute networks list` in your terminal.
#    - Note the "NAME" of the VPC you want to use from the output.
# 6. Ensure the selected VPC is in the correct project and region for your deployment.

# Remember to change the VPC reference later in this file: custom_vpc or existing_vpc

# --- SECTION: Subnet Configuration ---
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"          # Specify a name for your custom subnet.
  ip_cidr_range = "10.0.0.0/16"            # Define the IP range for this subnet in CIDR notation.
  region        = var.region               # Specify the region where the subnet will be created.
  network       = google_compute_network.custom_vpc.id  # Link the subnet to the VPC created above.
}

# Instructions:
# 1. The "name" attribute specifies the name of the subnet. Change "custom-subnet" to
#    a name that follows your project naming conventions, e.g., "exam-subnet" or "my-subnet".
#
# 2. The "ip_cidr_range" attribute defines the IP address range for the subnet.
#    - This range must not overlap with other subnets in the same VPC.
#    - Example ranges: "192.168.1.0/24", "172.16.0.0/16", "10.1.0.0/20".
#    - For practice, use tools like https://www.ipaddressguide.com/cidr to calculate ranges.
#
# 3. The "region" attribute sets the region where the subnet will be deployed.
#    - Ensure the region matches the one used in the provider configuration or VM instances.
#    - You can dynamically link this to `var.region` or hard-code a value like "europe-north1".
#
# 4. The "network" attribute links this subnet to the VPC.
#    - Ensure the VPC is correctly referenced (e.g., `google_compute_network.custom_vpc.id`).
#    - If you're using an existing VPC, update the network reference to:
#      network = data.google_compute_network.existing_vpc.id
#
# 5. After applying this configuration:
#    - Verify the subnet creation in the Google Cloud Console under Networking > VPC networks.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute networks subnets list --regions=<your-region>` to see your subnets.
#
# 6. Note:
#    - Each subnet must have a unique IP range.
#    - Subnets cannot span regions; ensure the region aligns with your VPC and VM requirements.

# --- SECTION: VM Configuration ---
# Option 1: Single VM Instance
resource "google_compute_instance" "vm_instance" {
  name         = "vm-instance"             # Name of the VM instance.
  machine_type = "e2-medium"               # Specifies the machine type (CPU and memory).
  zone         = var.zone                  # Zone within the region for the VM.

  # Disk Configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"     # Specifies the OS image for the VM.
    }
  }

  # Network Configuration
  network_interface {
    network    = google_compute_network.custom_vpc.id    # Links the VM to the custom VPC.
    subnetwork = google_compute_subnetwork.custom_subnet.id # Assigns the VM to the subnet.
    access_config {}                                      # Enables external access with a public IP.
  }

  # Tags for Firewall Rules
  tags = ["http-server"]                  # Tags are used for applying firewall rules.
}

# Instructions:
# 1. The "name" attribute specifies the name of the VM instance.
#    - Change "vm-instance" to a meaningful name, e.g., "web-server" or "app-instance".
#    - Ensure the name is unique in the zone.

# 2. The "machine_type" attribute determines the CPU and memory configuration of the VM.
#    - Example types: "e2-micro", "e2-medium", "n1-standard-1".
#    - Find available machine types for your zone:
#      - Visit: https://cloud.google.com/compute/docs/machine-types
#      - Or use `gcloud compute machine-types list --zones=<your-zone>`.

# 3. The "zone" attribute sets the specific zone for the VM.
#    - Example zones: "europe-north1-a", "us-central1-b".
#    - Ensure the zone is in the same region as your subnet.

# 4. The "boot_disk" block specifies the OS for the VM:
#    - Replace "debian-cloud/debian-11" with another image if needed (e.g., "ubuntu-2004-lts").
#    - Find available images using the `gcloud` CLI:
#      Run `gcloud compute images list`.

# 5. The "network_interface" block configures the VM's networking:
#    - `network` links to the VPC.
#    - `subnetwork` assigns the VM to a specific subnet.
#    - `access_config {}` enables external access via a public IP address.
#      - If no external access is required, remove `access_config {}`.

# 6. The "tags" attribute is used for applying firewall rules:
#    - For example, the "http-server" tag matches the firewall rule allowing HTTP traffic.
#    - Update the tag to match other firewall rules if needed (e.g., "https-server").

# 7. After applying this configuration:
#    - Verify the VM creation in the Google Cloud Console under Compute Engine > VM instances.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute instances list` to see the VM and its details.

# 8. Optional Enhancements:
#    - Add additional disks by including more `disk` blocks.
#    - Add metadata for startup scripts or configuration management.
#    - Add labels for easier management and filtering in the console.

# --- Option 2: Multiple VM Instances (using count) ---
resource "google_compute_instance" "vm_instances" {
  count        = var.instance_count                # Specifies the number of instances to create.
  name         = "vm-instance-${count.index}"     # Generates unique names for each VM instance.
  machine_type = "e2-medium"                      # Specifies the machine type (CPU and memory).
  zone         = var.zone                         # Zone within the region for the VM.

  # Disk Configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"            # Specifies the OS image for the VMs.
    }
  }

  # Network Configuration
  network_interface {
    network    = google_compute_network.custom_vpc.id    # Links the VMs to the custom VPC.
    subnetwork = google_compute_subnetwork.custom_subnet.id # Assigns the VMs to the subnet.
    access_config {}                                      # Enables external access with public IPs.
  }

  # Tags for Firewall Rules
  tags = ["http-server"]                     # Tags are used for applying firewall rules.
}

# Instructions:
# 1. The "count" attribute specifies the number of instances to create.
#    - Use `var.instance_count` to make the number dynamic.
#    - Set the variable in `variables.tf` or via CLI: `terraform apply -var="instance_count=3"`.
#    - For fixed counts, replace `var.instance_count` with a static number (e.g., `count = 3`).

# 2. The "name" attribute generates unique names for each instance:
#    - The `${count.index}` adds a zero-based index to the name (e.g., "vm-instance-0", "vm-instance-1").
#    - Modify the name template if needed, e.g., "app-server-${count.index}".

# 3. The "machine_type" attribute determines the CPU and memory configuration of the VMs:
#    - Example types: "e2-micro", "e2-medium", "n1-standard-1".
#    - Use `gcloud compute machine-types list --zones=<your-zone>` to find available machine types.

# 4. The "zone" attribute sets the zone for all VMs:
#    - All VMs in this block are created in the same zone.
#    - To distribute VMs across zones, use a `for_each` loop instead of `count`.

# 5. The "boot_disk" block specifies the operating system:
#    - Replace "debian-cloud/debian-11" with another image if needed (e.g., "ubuntu-2004-lts").
#    - Find available images using `gcloud compute images list`.

# 6. The "network_interface" block configures the VMs' networking:
#    - `network` links to the VPC.
#    - `subnetwork` assigns the VMs to a specific subnet.
#    - `access_config {}` enables external access via public IPs.
#      - If no external access is required, remove `access_config {}`.

# 7. The "tags" attribute applies to all instances in this block:
#    - The "http-server" tag matches the firewall rule allowing HTTP traffic.
#    - Update tags as needed for other firewall rules (e.g., "https-server").

# 8. After applying this configuration:
#    - Verify the VMs in the Google Cloud Console under Compute Engine > VM instances.
#    - Use `gcloud compute instances list` to see all instances.

# 9. Optional Enhancements:
#    - Add metadata or startup scripts for customization.
#    - Add labels for easier filtering and management.
#    - Use a `for_each` loop instead of `count` for more control over VM configurations.

# --- SECTION: Firewall Rules ---
# Option 1: HTTP Firewall Rule
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"                      # Name of the firewall rule.
  network = google_compute_network.custom_vpc.id  # Links the rule to the custom VPC.

  allow {
    protocol = "tcp"                         # Specifies the protocol allowed (TCP for HTTP).
    ports    = ["80"]                        # Specifies the port(s) to allow (80 for HTTP traffic).
  }

  source_ranges = ["0.0.0.0/0"]               # Allows traffic from all IPs (0.0.0.0/0 means any source).
  target_tags   = ["http-server"]             # Applies this rule to instances with the matching tag.
}

# Instructions:
# 1. The "name" attribute specifies the name of the firewall rule:
#    - Change "allow-http" to a meaningful name, e.g., "web-traffic-firewall" or "http-access".
#    - Ensure the name is unique within your project.

# 2. The "network" attribute links the firewall rule to a specific VPC:
#    - Use `google_compute_network.custom_vpc.id` for a new VPC.
#    - Use `data.google_compute_network.existing_vpc.id` for an existing VPC.

# 3. The "allow" block defines the allowed traffic:
#    - The "protocol" specifies the traffic type (e.g., "tcp", "udp", "icmp").
#    - The "ports" attribute lists allowed port numbers (e.g., ["80"] for HTTP, ["443"] for HTTPS).

# 4. The "source_ranges" attribute defines the allowed source IP ranges:
#    - "0.0.0.0/0" means any IP address can access the instances.
#    - For restricted access, use a specific IP range, e.g., ["192.168.1.0/24"] or ["203.0.113.0/32"].

# 5. The "target_tags" attribute applies the rule to instances with the matching tag:
#    - Ensure your VM instances have the "http-server" tag to match this rule.
#    - Update the tag in the VM configuration if needed, e.g., ["http-server", "web"].

# 6. After applying this configuration:
#    - Verify the firewall rule in the Google Cloud Console under Networking > Firewall.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute firewall-rules list` to see all rules.
#      Run `gcloud compute firewall-rules describe allow-http` to see details of this rule.

# 7. Optional Enhancements:
#    - Add a description for clarity:
#      description = "Allows incoming HTTP traffic to VMs with 'http-server' tag"
#    - Combine multiple ports in one rule, e.g., ["80", "8080"].
#    - Use different protocols (e.g., "udp", "icmp") for other traffic types.
#    - Use "priority" to control the rule's evaluation order (default is 1000).

# --- SECTION: Firewall Rules ---
# Option 2: HTTPS Firewall Rule
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"                      # Name of the firewall rule.
  network = google_compute_network.custom_vpc.id  # Links the rule to the custom VPC.

  allow {
    protocol = "tcp"                         # Specifies the protocol allowed (TCP for HTTPS).
    ports    = ["443"]                       # Specifies the port(s) to allow (443 for HTTPS traffic).
  }

  source_ranges = ["0.0.0.0/0"]               # Allows traffic from all IPs (0.0.0.0/0 means any source).
  target_tags   = ["https-server"]            # Applies this rule to instances with the matching tag.
}

# Instructions:
# 1. The "name" attribute specifies the name of the firewall rule:
#    - Change "allow-https" to a meaningful name, e.g., "secure-web-firewall" or "https-access".
#    - Ensure the name is unique within your project.

# 2. The "network" attribute links the firewall rule to a specific VPC:
#    - Use `google_compute_network.custom_vpc.id` for a new VPC.
#    - Use `data.google_compute_network.existing_vpc.id` for an existing VPC.

# 3. The "allow" block defines the allowed traffic:
#    - The "protocol" specifies the traffic type (e.g., "tcp", "udp", "icmp").
#    - The "ports" attribute lists allowed port numbers (e.g., ["443"] for HTTPS).

# 4. The "source_ranges" attribute defines the allowed source IP ranges:
#    - "0.0.0.0/0" means any IP address can access the instances.
#    - For restricted access, use a specific IP range, e.g., ["192.168.1.0/24"] or ["203.0.113.0/32"].

# 5. The "target_tags" attribute applies the rule to instances with the matching tag:
#    - Ensure your VM instances have the "https-server" tag to match this rule.
#    - Update the tag in the VM configuration if needed, e.g., ["https-server", "secure-web"].

# 6. After applying this configuration:
#    - Verify the firewall rule in the Google Cloud Console under Networking > Firewall.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute firewall-rules list` to see all rules.
#      Run `gcloud compute firewall-rules describe allow-https` to see details of this rule.

# 7. Optional Enhancements:
#    - Add a description for clarity:
#      description = "Allows incoming HTTPS traffic to VMs with 'https-server' tag"
#    - Combine multiple ports in one rule if needed, e.g., ["443", "8443"].
#    - Use different protocols (e.g., "udp", "icmp") for other traffic types.
#    - Use "priority" to control the rule's evaluation order (default is 1000).
#    - Use `deny` instead of `allow` for specific blocking rules.

# 8. Security Consideration:
#    - Allowing traffic from "0.0.0.0/0" opens access to all external sources. For enhanced security:
#      - Limit access to trusted IPs or IP ranges.
#      - Use HTTPS in conjunction with SSL certificates to secure communication.

# 9. Additional Use Case:
#    - Combine this rule with the HTTP rule to enable both HTTP (port 80) and HTTPS (port 443) traffic.
#    - Add tags like `["http-server", "https-server"]` to VMs if they serve both HTTP and HTTPS traffic.

# --- SECTION: Firewall Rules ---
# Option 3: SSH Firewall Rule
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"                       # Name of the firewall rule.
  network = google_compute_network.custom_vpc.id  # Links the rule to the custom VPC.

  allow {
    protocol = "tcp"                         # Specifies the protocol allowed (TCP for SSH).
    ports    = ["22"]                        # Specifies the port(s) to allow (22 for SSH traffic).
  }

  source_ranges = ["0.0.0.0/0"]               # Allows traffic from all IPs (0.0.0.0/0 means any source).
  target_tags   = ["ssh-server"]              # Applies this rule to instances with the matching tag.
}

# Instructions:
# 1. The "name" attribute specifies the name of the firewall rule:
#    - Change "allow-ssh" to a meaningful name, e.g., "admin-ssh-access" or "ssh-inbound".
#    - Ensure the name is unique within your project.

# 2. The "network" attribute links the firewall rule to a specific VPC:
#    - Use `google_compute_network.custom_vpc.id` for a new VPC.
#    - Use `data.google_compute_network.existing_vpc.id` for an existing VPC.

# 3. The "allow" block defines the allowed traffic:
#    - The "protocol" specifies the traffic type (e.g., "tcp", "udp", "icmp").
#    - The "ports" attribute lists allowed port numbers (e.g., ["22"] for SSH).

# 4. The "source_ranges" attribute defines the allowed source IP ranges:
#    - "0.0.0.0/0" means any IP address can access the instances.
#    - For enhanced security, restrict access to specific IP ranges:
#      - Example: ["203.0.113.0/32"] for a single trusted IP.
#      - Example: ["192.168.1.0/24"] for a private subnet.

# 5. The "target_tags" attribute applies the rule to instances with the matching tag:
#    - Ensure your VM instances have the "ssh-server" tag to match this rule.
#    - Update the tag in the VM configuration if needed, e.g., ["ssh-server", "admin-access"].

# 6. After applying this configuration:
#    - Verify the firewall rule in the Google Cloud Console under Networking > Firewall.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute firewall-rules list` to see all rules.
#      Run `gcloud compute firewall-rules describe allow-ssh` to see details of this rule.

# 7. Optional Enhancements:
#    - Add a description for clarity:
#      description = "Allows incoming SSH traffic to VMs with 'ssh-server' tag"
#    - Use "priority" to control the rule's evaluation order (default is 1000).
#    - Set expiration rules for temporary access, if applicable.

# 8. Security Consideration:
#    - Allowing SSH from "0.0.0.0/0" is insecure and should only be used in testing or development.
#      - For production, restrict access to trusted IPs or ranges.
#      - Consider implementing a VPN or bastion host for secure SSH access.

# 9. Additional Use Case:
#    - Combine this rule with other rules (e.g., HTTP or HTTPS) to manage multi-use servers.
#    - Use separate firewall rules for different environments (e.g., dev-ssh, prod-ssh).

# --- SECTION: Outputs ---
# This output block provides the external IP address of the created VM instance(s).

output "vm_instance_external_ip" {
  description = "External IP address of the VM instance(s)"  # Describes the purpose of the output.
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  # Retrieves the external (public) IP address of the first network interface's access config for the VM.
}

# Instructions:
# 1. The "description" attribute provides context for the output:
#    - Update the description if needed to match your naming conventions or project purpose.
#    - Example: "Public IP for accessing the web server."

# 2. The "value" attribute fetches the external IP address of the VM:
#    - The `google_compute_instance.vm_instance` resource must match your VM resource name.
#    - If you're creating multiple instances with a count or for_each loop:
#      - Use `google_compute_instance.vm_instances[count.index].network_interface[0].access_config[0].nat_ip`
#        to retrieve IPs for all instances dynamically.
#    - If no external access is configured (e.g., `access_config {}` is removed), this value will be `null`.

# 3. After applying your Terraform configuration:
#    - The external IP will be displayed in the terminal under "Outputs".
#    - Example output:
#      ```
#      Outputs:
#      vm_instance_external_ip = "203.0.113.10"
#      ```

# 4. To access the VM:
#    - Use the outputted IP address in your SSH client, browser, or other tools.
#    - Example for SSH: `ssh <username>@<external-ip>`
#    - Example for HTTP: Open `http://<external-ip>` in your browser if HTTP is enabled.

# 5. Using the Output Dynamically:
#    - Use this output value in other Terraform configurations by referencing:
#      module.<module-name>.vm_instance_external_ip
#    - Example: Pass the IP address to another resource like a DNS record.

# 6. Verification:
#    - Verify the external IP address in the Google Cloud Console:
#      Navigate to Compute Engine > VM Instances and check the "External IP" column.
#    - Alternatively, use the `gcloud` CLI:
#      Run `gcloud compute instances list` to see the IP addresses of all instances.

# 7. Optional Enhancements:
#    - If multiple instances are created, output all their IPs:
#      ```
#      output "vm_instances_external_ips" {
#        description = "External IP addresses of the VM instances"
#        value       = google_compute_instance.vm_instances[*].network_interface[0].access_config[0].nat_ip
#      }
#      ```
#    - Add a conditional check to output an alternate message if no external IPs are assigned:
#      ```
#      value = length(google_compute_instance.vm_instance.network_interface[0].access_config) > 0
#        ? google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
#        : "No external IP assigned"
#      ```

# --- SECTION: Variables ---
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
  default     = "europe-north1"
}

variable "zone" {
  description = "Zone for the VM instance"
  type        = string
  default     = "europe-north1-a"
}

variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
}