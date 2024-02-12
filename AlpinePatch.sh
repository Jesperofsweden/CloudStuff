#!/bin/sh

# Update system and install necessary packages
apk update && apk add --no-cache wget curl python3 py3-pip

# Function to create a virtual environment and activate it
create_and_use_venv() {
  local venv_name="/opt/venv_$1"
  echo "Creating virtual environment for $1 in $venv_name"
  python3 -m venv $venv_name
  . $venv_name/bin/activate
}

# Function to install kubectl
install_kubectl() {
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/bin/kubectl
}

# Function to install Azure CLI
install_az_cli() {
  echo "Installing Azure CLI..."
  create_and_use_venv azure-cli
  pip install azure-cli
  deactivate
}

# Function to install AWS CLI
install_aws_cli() {
  echo "Installing AWS CLI..."
  create_and_use_venv aws-cli
  pip install awscli
  deactivate
}

# Function to install Google Cloud CLI
install_gcloud_cli() {
  echo "Installing Google Cloud CLI..."
  create_and_use_venv gcloud-cli
  curl https://sdk.cloud.google.com | bash
  deactivate
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

echo "Installation complete."
