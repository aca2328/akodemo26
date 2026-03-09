#!/bin/bash

# Script to create TLS secret for ingress resources
# Generates self-signed certificate and creates Kubernetes TLS secret

set -e

echo "Creating TLS secret for ingress..."

# Generate private key
echo "Generating private key..."
openssl genrsa -out ssl.key 2048

# Generate self-signed certificate
echo "Generating self-signed certificate..."
openssl req -new -x509 -key ssl.key -out ssl.cert -days 360 -subj "/CN=hello.110.ams.avilab.eu"

# Create Kubernetes TLS secret
echo "Creating Kubernetes TLS secret..."
kubectl create secret tls certif1 --key=ssl.key --cert=ssl.cert -n default

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f ssl.key ssl.cert

echo "TLS secret 'certif1' created successfully!"

# Verify the secret was created
echo "Verifying secret..."
kubectl get secret certif1 -n default -o yaml