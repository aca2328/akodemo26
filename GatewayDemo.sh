#!/bin/bash

# Interactive menu for deploying Kubernetes resources in the gatewayapi directory

# Function to deploy a resource
deploy_resource() {
    local resource_name=$1
    local resource_file=$2
    local resource_type=$3
    
    echo "Deploying $resource_name..."
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
    
    sleep 2
    return 0
}

# Main menu
while true; do
    clear
    echo "=========================================="
    echo "  Gateway API Resources Deployment Menu"
    echo "=========================================="
    echo "a. Deploy Gateway"
    echo "b. Deploy Complete Stack (v1)"
    echo "c. Deploy HTTPRoute v1 Extended"
    echo "d. Deploy HealthMonitor"
    echo "e. Deploy RouteBackendExtension"
    echo "f. Deploy L7Rule"
    echo "g. Deploy Complete Stack (v2)"
    echo "h. Deploy Complete Stack (v3)"
    echo "i. Deploy Gateway with Static IP"
    echo "j. Deploy HTTPRoute v2 and v3"
    echo "k. Deploy AVIInfrasetting"
    echo "m. Verify All Deployments"
    echo "n. View AKO Logs"
    echo "x. Delete ALL Resources"
    echo "z. Exit"
    echo "=========================================="
    echo -n "Press key (a-z, n, x): "
    read -n 1 choice
    echo
    
    case $choice in
        a|A)
            # Deploy Gateway
            deploy_resource "avi-gateway" "gatewayapi/gateway-gw-multiple-listeners.yaml" "gateway"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        b|B)
            # Deploy complete stack: deployment, service, and HTTPRoute
            echo "Starting Complete Stack Deployment (v1)..."
            echo "=========================================="
            
            # Deploy Deployment v1
            echo "Step 1/3: Deploying Deployment v1..."
            deploy_resource "avi-hello-world-v1" "gatewayapi/deployment-avi-hello-world-v1.yaml" "deployment"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v1
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v1
            echo "Step 2/3: Deploying Service v1..."
            deploy_resource "svc-v1" "gatewayapi/service-svc-v1.yaml" "service"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v1
            echo "=========================================="
            echo -n "Press any key to continue to HTTPRoute deployment..."
            read -n 1 -s
            echo
            
            # Deploy HTTPRoute v1
            echo "Step 3/3: Deploying HTTPRoute v1..."
            deploy_resource "my-http-app-v1" "gatewayapi/httproute-my-http-app-v1.yaml" "httproute"
            echo "HTTPRoute deployed successfully!"
            echo "=========================================="
            kubectl get httproutes -n default -o wide | grep my-http-app-v1
            echo "=========================================="
            echo "Complete stack deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        c|C)
            # Deploy HTTPRoute v1 Extended
            deploy_resource "avi-httproute-v1-extended" "gatewayapi/httproute-my-http-app-v1-extended.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        d|D)
            deploy_resource "avi-healthmonitor" "gatewayapi/healthmonitor-my-health-monitor.yaml" "healthmonitor"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        e|E)
            deploy_resource "avi-routebackendextension" "gatewayapi/routebackendextension-my-route-backend-extension.yaml" "routebackendextension"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        f|F)
            deploy_resource "avi-l7rule" "gatewayapi/l7rule-gw-sec.yaml" "l7rule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        g|G)
            # Deploy complete stack v2: deployment, service (no HTTPRoute as v2-v3 covers both)
            echo "Starting Complete Stack Deployment (v2)..."
            echo "=========================================="
            
            # Deploy Deployment v2
            echo "Step 1/2: Deploying Deployment v2..."
            deploy_resource "avi-hello-world-v2" "gatewayapi/deployment-avi-hello-world-v2.yaml" "deployment"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v2
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v2
            echo "Step 2/2: Deploying Service v2..."
            deploy_resource "svc-v2" "gatewayapi/service-svc-v2.yaml" "service"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v2
            echo "=========================================="
            echo "Note: HTTPRoute my-http-app-v2-v3 will handle routing for both v2 and v3"
            echo "Complete stack v2 deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        h|H)
            # Deploy complete stack v3: deployment, service (no HTTPRoute as v2-v3 covers both)
            echo "Starting Complete Stack Deployment (v3)..."
            echo "=========================================="
            
            # Deploy Deployment v3
            echo "Step 1/2: Deploying Deployment v3..."
            deploy_resource "avi-hello-world-v3" "gatewayapi/deployment-avi-hello-world-v3.yaml" "deployment"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v3
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v3
            echo "Step 2/2: Deploying Service v3..."
            deploy_resource "svc-v3" "gatewayapi/service-svc-v3.yaml" "service"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v3
            echo "=========================================="
            echo "Note: HTTPRoute my-http-app-v2-v3 will handle routing for both v2 and v3"
            echo "Complete stack v3 deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        i|I)
            # Deploy Gateway with Static IP
            deploy_resource "avi-gateway-static" "gatewayapi/gateway-gw-multiple-listeners-static-ip.yaml" "gateway"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        j|J)
            # Deploy HTTPRoute v2 and v3
            deploy_resource "avi-httproute-v2-v3" "gatewayapi/httproute-my-http-app-v2-v3.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        k|K)
            deploy_resource "avi-aviinfrasetting" "gatewayapi/aviinfrasetting-toDmz.yaml" "aviinfrasetting"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        r|R)
            echo "Verifying deployments..."
            echo "Deployments:"
            kubectl get deployments -n default | grep avi-hello-world || echo "Not found"
            echo "Gateways:"
            kubectl get gateways -n default || echo "Not found"
            echo "HTTPRoutes:"
            kubectl get httproutes -n default || echo "Not found"
            echo "Services:"
            kubectl get services -n default | grep avi-service || echo "Not found"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        s|S)
            echo "Viewing AKO logs..."
            echo "=========================================="
            kubectl logs ako-0 -n avi-system --tail=50
            echo "=========================================="
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        x|X)
            echo "Deleting ALL gateway resources..."
            echo "This will delete deployments, services, gateways, httproutes, etc."
            read -p "Are you sure you want to delete ALL resources (y/n)? " choice
            if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
                echo "Deleting deployments..."
                kubectl delete deployment avi-hello-world -n default 2>/dev/null || true
                kubectl delete deployment avi-hello-world-v1 -n default 2>/dev/null || true
                kubectl delete deployment avi-hello-world-v2 -n default 2>/dev/null || true
                kubectl delete deployment avi-hello-world-v3 -n default 2>/dev/null || true
                
                echo "Deleting services..."
                kubectl delete service avi-hello-svc -n default 2>/dev/null || true
                kubectl delete service svc-v1 -n default 2>/dev/null || true
                kubectl delete service svc-v2 -n default 2>/dev/null || true
                kubectl delete service svc-v3 -n default 2>/dev/null || true
                
                echo "Deleting gateways..."
                kubectl delete gateway gw-sec -n default 2>/dev/null || true
                kubectl delete gateway gw-multiple-listeners -n default 2>/dev/null || true
                kubectl delete gateway gw-multiple-listeners-static-ip -n default 2>/dev/null || true
                
                echo "Deleting httproutes..."
                kubectl delete httproute my-http-app-v1 -n default 2>/dev/null || true
                kubectl delete httproute my-http-app-v2 -n default 2>/dev/null || true
                kubectl delete httproute my-http-app-v2-v3 -n default 2>/dev/null || true
                
                echo "Deleting healthmonitors..."
                kubectl delete healthmonitor my-health-monitor -n default 2>/dev/null || true
                
                echo "Deleting routebackendextensions..."
                kubectl delete routebackendextension my-route-backend-extension -n default 2>/dev/null || true
                
                echo "Deleting aviinfrasettings..."
                kubectl delete aviinfrasetting toDmz -n default 2>/dev/null || true
                
                echo "All gateway resources deleted successfully!"
            else
                echo "Delete operation cancelled."
            fi
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        z|Z)
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
