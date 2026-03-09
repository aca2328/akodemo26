#!/bin/bash

# Interactive menu for deploying Kubernetes resources in the ingress directory

# Function to check if a resource exists
resource_exists() {
    local resource_type=$1
    local resource_name=$2
    kubectl get $resource_type $resource_name -n default &> /dev/null
    return $?
}

# Function to deploy a resource
deploy_resource() {
    local resource_name=$1
    local resource_file=$2
    local resource_type=$3
    
    echo "Checking if $resource_name exists..."
    if resource_exists $resource_type $resource_name; then
        echo "$resource_name already exists."
        echo -n "Do you want to delete it (y/n)? "
        read -n 1 choice
        echo
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            echo "Deleting $resource_name..."
            kubectl delete $resource_type $resource_name -n default
            if [ $? -ne 0 ]; then
                echo "Error: Failed to delete $resource_name"
                return 1
            fi
            sleep 2
            echo "Resource deleted. Current status:"
            echo "=========================================="
            kubectl get $resource_type -n default -o wide | grep $resource_name || echo "Resource successfully deleted"
            echo "=========================================="
            echo -n "Press any key to continue..."
            read -n 1 -s
            return 0
        else
            echo "Skipping $resource_name."
        fi
    else
        echo "$resource_name does not exist. Deploying..."
        kubectl apply -f $resource_file
        if [ $? -ne 0 ]; then
            echo "Error: Failed to deploy $resource_name"
            return 1
        fi
        
        # Show the applied resource
        echo ""
        echo "Successfully deployed $resource_name. Resource details:"
        echo "=========================================="
        cat $resource_file
        echo "=========================================="
    fi
    sleep 2
    return 0
}

# Function to manage TLS secrets
manage_tls_secret() {
    local secret_name=$1
    local cn_name=$2
    
    echo "Checking if TLS secret $secret_name exists..."
    if kubectl get secret $secret_name -n default &> /dev/null; then
        echo "TLS secret $secret_name already exists."
        read -p "Do you want to delete it (y/n)? " choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            echo "Deleting TLS secret $secret_name..."
            kubectl delete secret $secret_name -n default
            if [ $? -ne 0 ]; then
                echo "Error: Failed to delete TLS secret $secret_name"
                return 1
            fi
            echo "TLS secret deleted successfully."
        else
            echo "Skipping deletion of $secret_name."
            return 0
        fi
    else
        echo "TLS secret $secret_name does not exist. Creating..."
        
        # Generate private key
        echo "Generating private key..."
        openssl genrsa -out ssl.key 2048
        
        # Generate self-signed certificate
        echo "Generating self-signed certificate..."
        openssl req -new -x509 -key ssl.key -out ssl.cert -days 360 -subj "/CN=$cn_name"
        
        # Create Kubernetes TLS secret
        echo "Creating Kubernetes TLS secret..."
        kubectl create secret tls $secret_name --key=ssl.key --cert=ssl.cert -n default
        
        # Clean up temporary files
        echo "Cleaning up temporary files..."
        rm -f ssl.key ssl.cert
        
        echo "TLS secret '$secret_name' created successfully!"
        
        # Verify the secret was created
        echo "Verifying secret..."
        kubectl get secret $secret_name -n default -o yaml | grep -E "(name:|type:)"
    fi
    echo -n "Press any key to continue..."
    read -n 1 -s
    return 0
}

# Main menu
while true; do
    clear
    echo "=========================================="
    echo "  Ingress Resources Deployment Menu"
    echo "=========================================="
    echo "1. Deploy Demo Application (Deployment + Service)"
    echo "2. Deploy LoadBalancer Service"
    echo "3. Deploy Ingress Resource"
    echo "4. Deploy HostRule for hello.110.ams.avilab.eu"
    echo "5. Deploy HostRule for hello2.110.ams.avilab.eu"
    echo "6. Deploy TLS Ingress (Optional)"
    echo "7. Manage TLS Secret for hello.110.ams.avilab.eu"
    echo "8. Manage TLS Secret for hello2.110.ams.avilab.eu"
    echo "9. Verify All Deployments"
    echo "x. Exit"
    echo "=========================================="
    echo -n "Press key (1-9, x): "
    read -n 1 choice
    echo
    
    case $choice in
        1)
            deploy_resource "avi-hello-world" "ingress/demoapp.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        2)
            deploy_resource "avi-hello-l4" "ingress/svc.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        3)
            deploy_resource "avi-hello-ingress" "ingress/ingress.yaml" "ingress"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        4)
            deploy_resource "hello-hr" "ingress/hello-hostrule.yaml" "hostrule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        5)
            deploy_resource "hello2-hr" "ingress/hello2-hostrule.yaml" "hostrule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        6)
            deploy_resource "avi-hello-ingress" "ingress/tls-ingress.yaml" "ingress"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        7)
            manage_tls_secret "certif1" "hello.110.ams.avilab.eu"
            ;;
        8)
            manage_tls_secret "certif2" "hello2.110.ams.avilab.eu"
            ;;
        9)
            echo "Verifying deployments..."
            echo "Deployments:"
            kubectl get deployments -n default | grep avi-hello-world || echo "Not found"
            echo "Services:"
            kubectl get services -n default | grep avi-hello || echo "Not found"
            echo "Ingress:"
            kubectl get ingress -n default | grep avi-hello-ingress || echo "Not found"
            echo "HostRules:"
            kubectl get hostrules -n default | grep hello || echo "Not found"
            echo "TLS Secrets:"
            kubectl get secrets -n default | grep -E "(certif1|certif2)" || echo "No TLS secrets found"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        x|X)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
    esac
done