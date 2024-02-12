#!/bin/sh

# Update and install wget and curl
apk update && apk add --no-cache wget curl

# Function to install kubectl
install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/bin/
}

# Function to install Azure CLI
install_az_cli() {
  apk update --no-cache python3 py3-pip
  pip install --user azure-cli
}

# Function to install AWS CLI
install_aws_cli() {
  apk update && --no-cache aws-cli || pip install --user awscli
}

# Function to install Google Cloud CLI
install_gcloud_cli() {
  apk add --no-cache curl
  curl -sSL https://sdk.cloud.google.com | bash
}

# Detect cloud provider by querying the metadata service
detect_cloud_provider() {
  # AWS check
  if curl -s http://169.254.169.254/latest/dynamic/instance-identity/ 2>&1 | grep -q 'instanceId'; then
    echo "AWS"
  # Azure check
  elif curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-04-02" 2>&1 | grep -q 'compute'; then
    echo "Azure"
  # GCP check
  elif curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/" 2>&1 | grep -q 'instance'; then
    echo "GCP"
  else
    echo "Unknown"
  fi
}

# Install kubectl
install_kubectl

# Detect the cloud provider and install the appropriate CLI
CLOUD_PROVIDER=$(detect_cloud_provider)
echo "Detected cloud provider: $CLOUD_PROVIDER"

case $CLOUD_PROVIDER in
  AWS)
    install_aws_cli
    ;;
  Azure)
    install_az_cli
    ;;
  GCP)
    install_gcloud_cli
    ;;
  *)
    echo "Could not detect cloud environment or not running in a supported cloud environment."
    ;;
esac
