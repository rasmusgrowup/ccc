# Terraform Commands for GCP Configuration

This document provides the essential Terraform commands to manage your GCP infrastructure using the included Terraform configuration file.

### Prerequisites
- Terraform Installed: Install Terraform
- Authenticate using the gcloud CLI: 
  - ```gcloud auth application-default login``` 
- Ensure the GOOGLE_APPLICATION_CREDENTIALS environment variable is set if using a service account: 
  - ```export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-service-account-key.json"```
- Compute Engine API must be enabled in your GCP project:
  - ```gcloud services enable compute.googleapis.com```

## Commands

1. Initialize the Terraform Project

Run this command to download required provider plugins and prepare your working directory:
```
terraform init
```

2. Validate the Configuration

Validate the syntax and correctness of your Terraform configuration files:
```
terraform validate
```

3. Create a Plan

Preview the changes Terraform will apply to your infrastructure. (You can run these commands without the flags also, so just `terraform plan`)

```
terraform plan -var="project_id=<your-gcp-project-id>" -var="region=<your-region>" -var="zone=<your-zone>" -var="instance_count=<number-of-vms>"
```

Example using the example configuration: (You can run these commands without the flags also, so just `terraform plan`)

```
terraform plan -var="project_id=my-gcp-project" -var="region=europe-north1" -var="zone=europe-north1-a" -var="instance_count=3"
```

4. Apply the Configuration

Deploy the resources defined in your Terraform configuration: (You can run these commands without the flags also, so just `terraform apply`)

```
terraform apply -var="project_id=<your-gcp-project-id>" -var="region=<your-region>" -var="zone=<your-zone>" -var="instance_count=<number-of-vms>"
```

Example using the example configuration: ("project_id" is the variable name, "my-gcp-project" is the value)

```
terraform apply -var="project_id=my-gcp-project" -var="region=europe-north1" -var="zone=europe-north1-a" -var="instance_count=3"
```

## Additional Commands

### Check Existing Resources

Use the gcloud CLI to inspect existing resources in your GCP project:

List networks:
```
gcloud compute networks list
```

List subnets:
```
gcloud compute networks subnets list
```

List VM instances:
```
gcloud compute instances list
```

List Firewall Rules
```
gcloud compute firewall-rules list
```

