#!/bin/sh

# Function to install dependencies based on environment
install_dependencies() {
    echo "Installing dependencies..."
    if [ "$ENVIRONMENT" = "AWS" ]; then
        apk add --no-cache curl python3 py3-pip
        pip install awscli
    elif [ "$ENVIRONMENT" = "Azure" ]; then
        apk add --no-cache curl python3 py3-pip
        pip install azure-cli
    elif [ "$ENVIRONMENT" = "GCP" ]; then
        apk add --no-cache curl
        curl -sSL https://sdk.cloud.google.com | bash
        source $HOME/google-cloud-sdk/path.bash.inc
        gcloud components install kubectl
    else
        echo "Unknown environment!"
        exit 1
    fi
}

# Check if curl is installed, if not, install it using wget
if ! command -v curl >/dev/null 2>&1; then
    echo "Curl not found, installing..."
    apk add --no-cache wget
    wget https://curl.se/download/curl-7.82.0.tar.gz
    tar -xvf curl-7.82.0.tar.gz
    cd curl-7.82.0
    ./configure
    make
    make install
    cd ..
    rm -rf curl-7.82.0.tar.gz curl-7.82.0
fi

# Detect environment
if command -v kubectl >/dev/null 2>&1; then
    ENVIRONMENT="GCP"
elif command -v aws >/dev/null 2>&1; then
    ENVIRONMENT="AWS"
elif command -v az >/dev/null 2>&1; then
    ENVIRONMENT="Azure"
else
    echo "Environment not detected!"
    exit 1
fi

# Install dependencies based on environment
install_dependencies

echo "Setup completed for $ENVIRONMENT environment."
