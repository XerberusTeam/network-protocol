# Polkadot Infrastructure Terraform

This directory contains Terraform configurations for deploying a Polkadot node infrastructure on Google Cloud Platform (GCP).

## Infrastructure Overview

The infrastructure includes:
- Full nodes and light nodes running on GCP Compute Engine
- Load balancer for RPC, WebSocket, and P2P traffic
- IAP for secure SSH access
- Proper network isolation and firewall rules
- Managed SSL certificates

## Prerequisites

- Google Cloud SDK
- Terraform (v1.5.0+)
- GCP project with appropriate permissions
- GCS bucket for Terraform state storage

## Initial Setup

Before using these Terraform configurations, you need to set up your GCP environment:

```bash
# Install Google Cloud SDK and Terraform if you haven't already
brew install --cask google-cloud-sdk
brew install terraform

# Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Run the setup script to configure your GCP project
cd ../scripts
./setup_gcp.sh YOUR_PROJECT_ID YOUR_EMAIL
```

The setup script enables necessary APIs, assigns required IAM roles, and creates a GCS bucket for Terraform state.

## Deploying Infrastructure

To deploy the infrastructure:

```bash
# Navigate to the terraform directory
cd ../terraform

# Initialize Terraform
terraform init

# Select workspace (optional)
terraform workspace select default  # or another workspace

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

When prompted during the `terraform apply` step, type `yes` to confirm.

## Working with Multiple Environments

This configuration supports multiple environments using Terraform workspaces:

```bash
# List available workspaces
terraform workspace list

# Create a new workspace
terraform workspace new your-workspace

# Select an existing workspace
terraform workspace select your-workspace

# Deploy to the selected workspace
terraform plan
terraform apply
```

Environment-specific configurations are stored in the `environments/` directory.

## Using the Infrastructure on a New Laptop

When you clone this repository on a different laptop:

1. **Install prerequisites** (Terraform, Google Cloud SDK)
2. **Authenticate with Google Cloud**:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```
3. **Initialize Terraform**:
   ```bash
   cd infra/terraform
   terraform init
   ```
4. **Review and apply**:
   ```bash
   terraform plan
   terraform apply
   ```

## Infrastructure Components

- **fullnodes.tf**: Configuration for the full node instances
- **lightnodes.tf**: Configuration for the light node instances
- **load-balancer.tf**: Load balancer and SSL certificate configuration
- **network.tf**: VPC, subnet, and firewall configurations
- **iap.tf**: IAP and SSH access configurations
- **main.tf**: Main Terraform configuration and backend setup
- **locals.tf**: Local variables and environment settings
- **outputs.tf**: Output values for the deployment

## Accessing Nodes

After deployment, you can access your nodes using the IAP tunnel commands provided in the Terraform output:

```bash
# View outputs
terraform output

# SSH to a full node
gcloud compute ssh --zone ZONE INSTANCE_NAME --tunnel-through-iap --project PROJECT_ID

# SSH to a light node
gcloud compute ssh --zone ZONE LIGHTNODE_NAME --tunnel-through-iap --project PROJECT_ID
```

## Destroying Infrastructure

To tear down the infrastructure:

```bash
terraform destroy
```

When prompted, type `yes` to confirm.

## File Structure

```
terraform/
├── .terraform/               # Local Terraform directory (not in git)
├── .terraform.lock.hcl       # Dependency lock file
├── compute.tf                # Compute image configuration
├── environments/             # Environment-specific configurations
├── fullnodes.tf              # Full node configurations
├── iap.tf                    # IAP access configurations
├── lightnodes.tf             # Light node configurations
├── load-balancer.tf          # Load balancer configurations
├── locals.tf                 # Local variables
├── main.tf                   # Main Terraform configuration
├── network.tf                # Network configurations
└── outputs.tf                # Output definitions
```

## Notes

- The Terraform state is stored in a GCS bucket defined in `main.tf`
- OS Login is enabled by default for secure SSH access
- The load balancer is configured with both TCP and HTTP backends for different protocols 