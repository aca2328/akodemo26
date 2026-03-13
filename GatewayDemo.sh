#!/bin/bash

# Interactive menu for deploying Kubernetes resources in the gatewayapi directory

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
        echo "$resource_name already exists. Deleting..."
        kubectl delete $resource_type $resource_name -n default
        if [ $? -ne 0 ]; then
            echo "Error: Failed to delete $resource_name"
            return 1
        fi
        sleep 2
        echo "Resource deleted successfully."
    fi
    
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
    echo "a. Deploy Complete Stack (v1)"
    echo "b. Deploy Complete Stack (v2)"
    echo "c. Deploy Complete Stack (v3)"
    echo "d. Deploy Demo Application"
    echo "e. Deploy Gateway"
    echo "f. Deploy Gateway with Static IP"
    echo "g. Deploy HTTPRoute v1 Extended"
    echo "h. Deploy HTTPRoute v2 and v3"
    echo "i. Deploy HealthMonitor"
    echo "j. Deploy L7Rule"
    echo "k. Deploy RouteBackendExtension"
    echo "l. Deploy AVIInfrasetting"
    echo "m. Scale v1 Deployment to 6 Pods"
    echo "n. Verify All Deployments"
    echo "o. View AKO Logs"
    echo "x. Delete ALL Resources"
    echo "z. Exit"
    echo "=========================================="
    echo -n "Press key (a-z, o, x): "
    read -n 1 choice
    echo
    
    case $choice in
        a|A)
            # Deploy complete stack: deployment, service, and HTTPRoute
            echo "Starting Complete Stack Deployment (v1)..."
            echo "=========================================="
            
            # Deploy Deployment v1
            echo "Step 1/3: Deploying Deployment v1..."
            if resource_exists "deployment" "avi-hello-world-v1"; then
                echo "Deployment avi-hello-world-v1 already exists. Deleting..."
                kubectl delete deployment avi-hello-world-v1 -n default
                sleep 3
                echo "Deployment deleted successfully."
            fi
            echo "Deploying avi-hello-world-v1..."
            kubectl apply -f "gatewayapi/deployment-avi-hello-world-v1.yaml"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v1
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v1
            echo "Step 2/3: Deploying Service v1..."
            if resource_exists "service" "svc-v1"; then
                echo "Service svc-v1 already exists. Deleting..."
                kubectl delete service svc-v1 -n default
                sleep 3
                echo "Service deleted successfully."
            fi
            echo "Deploying svc-v1..."
            kubectl apply -f "gatewayapi/service-svc-v1.yaml"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v1
            echo "=========================================="
            echo -n "Press any key to continue to HTTPRoute deployment..."
            read -n 1 -s
            echo
            
            # Deploy HTTPRoute v1
            echo "Step 3/3: Deploying HTTPRoute v1..."
            if resource_exists "httproute" "my-http-app-v1"; then
                echo "HTTPRoute my-http-app-v1 already exists. Deleting..."
                kubectl delete httproute my-http-app-v1 -n default
                sleep 3
                echo "HTTPRoute deleted successfully."
            fi
            echo "Deploying my-http-app-v1..."
            kubectl apply -f "gatewayapi/httproute-my-http-app-v1.yaml"
            echo "HTTPRoute deployed successfully!"
            echo "=========================================="
            kubectl get httproutes -n default -o wide | grep my-http-app-v1
            echo "=========================================="
            echo "Complete stack deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        b|B)
            # Deploy complete stack v2: deployment, service (no HTTPRoute as v2-v3 covers both)
            echo "Starting Complete Stack Deployment (v2)..."
            echo "=========================================="
            
            # Deploy Deployment v2
            echo "Step 1/2: Deploying Deployment v2..."
            if resource_exists "deployment" "avi-hello-world-v2"; then
                echo "Deployment avi-hello-world-v2 already exists. Deleting..."
                kubectl delete deployment avi-hello-world-v2 -n default
                sleep 3
                echo "Deployment deleted successfully."
            fi
            echo "Deploying avi-hello-world-v2..."
            kubectl apply -f "gatewayapi/deployment-avi-hello-world-v2.yaml"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v2
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v2
            echo "Step 2/2: Deploying Service v2..."
            if resource_exists "service" "svc-v2"; then
                echo "Service svc-v2 already exists. Deleting..."
                kubectl delete service svc-v2 -n default
                sleep 3
                echo "Service deleted successfully."
            fi
            echo "Deploying svc-v2..."
            kubectl apply -f "gatewayapi/service-svc-v2.yaml"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v2
            echo "=========================================="
            echo "Note: HTTPRoute my-http-app-v2-v3 will handle routing for both v2 and v3"
            echo "Complete stack v2 deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        c|C)
            # Deploy complete stack v3: deployment, service (no HTTPRoute as v2-v3 covers both)
            echo "Starting Complete Stack Deployment (v3)..."
            echo "=========================================="
            
            # Deploy Deployment v3
            echo "Step 1/2: Deploying Deployment v3..."
            if resource_exists "deployment" "avi-hello-world-v3"; then
                echo "Deployment avi-hello-world-v3 already exists. Deleting..."
                kubectl delete deployment avi-hello-world-v3 -n default
                sleep 3
                echo "Deployment deleted successfully."
            fi
            echo "Deploying avi-hello-world-v3..."
            kubectl apply -f "gatewayapi/deployment-avi-hello-world-v3.yaml"
            echo "Deployment deployed successfully!"
            echo "=========================================="
            kubectl get deployments -n default -o wide | grep avi-hello-world-v3
            echo "=========================================="
            echo -n "Press any key to continue to Service deployment..."
            read -n 1 -s
            echo
            
            # Deploy Service v3
            echo "Step 2/2: Deploying Service v3..."
            if resource_exists "service" "svc-v3"; then
                echo "Service svc-v3 already exists. Deleting..."
                kubectl delete service svc-v3 -n default
                sleep 3
                echo "Service deleted successfully."
            fi
            echo "Deploying svc-v3..."
            kubectl apply -f "gatewayapi/service-svc-v3.yaml"
            echo "Service deployed successfully!"
            echo "=========================================="
            kubectl get services -n default -o wide | grep svc-v3
            echo "=========================================="
            echo "Note: HTTPRoute my-http-app-v2-v3 will handle routing for both v2 and v3"
            echo "Complete stack v3 deployed successfully!"
            echo -n "Press any key to return to main menu..."
            read -n 1 -s
            ;;
        d|D)
            deploy_resource "avi-gateway" "gatewayapi/gateway-gw-multiple-listeners.yaml" "gateway"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        c|C)
            deploy_resource "avi-gateway-static" "gatewayapi/gateway-gw-multiple-listeners-static-ip.yaml" "gateway"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        d|D)
            deploy_resource "avi-httproute-v1" "gatewayapi/httproute-my-http-app-v1.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        e|E)
            deploy_resource "avi-httproute-v1-extended" "gatewayapi/httproute-my-http-app-v1-extended.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        f|F)
            deploy_resource "avi-httproute-v2" "gatewayapi/httproute-my-http-app-v2.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        g|G)
            deploy_resource "avi-httproute-v2-v3" "gatewayapi/httproute-my-http-app-v2-v3.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        h|H)
            deploy_resource "avi-service-v1" "gatewayapi/service-svc-v1.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        i|I)
            deploy_resource "avi-service-v2" "gatewayapi/service-svc-v2.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        j|J)
            deploy_resource "avi-service-v3" "gatewayapi/service-svc-v3.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        k|K)
            deploy_resource "avi-deployment-v1" "gatewayapi/deployment-avi-hello-world-v1.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        l|L)
            deploy_resource "avi-deployment-v2" "gatewayapi/deployment-avi-hello-world-v2.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        m|M)
            # Scale v1 deployment to 6 pods
            echo "Scaling v1 Deployment to 6 Pods..."
            echo "=========================================="
            
            # Check if deployment exists
            if resource_exists "deployment" "avi-hello-world-v1"; then
                echo "Scaling deployment avi-hello-world-v1 to 6 replicas..."
                kubectl scale deployment avi-hello-world-v1 --replicas=6
                
                # Verify scaling
                sleep 3
                echo "Scaling complete. Current status:"
                echo "=========================================="
                kubectl get deployments -n default -o wide | grep avi-hello-world-v1
                echo "Pod status:"
                kubectl get pods -n default -o wide | grep avi-hello-world-v1
                echo "=========================================="
                echo "Deployment scaled to 6 pods successfully!"
            else
                echo "Error: Deployment avi-hello-world-v1 not found."
                echo "Please deploy the v1 stack first using option 'a'."
            fi
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        n|N)
            deploy_resource "avi-healthmonitor" "gatewayapi/healthmonitor-my-health-monitor.yaml" "healthmonitor"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        o|O)
            deploy_resource "avi-l7rule" "gatewayapi/l7rule-gw-sec.yaml" "l7rule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        p|P)
            deploy_resource "avi-routebackendextension" "gatewayapi/routebackendextension-my-route-backend-extension.yaml" "routebackendextension"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        q|Q)
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
        d|D)
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
        d|D)
            deploy_resource "avi-httproute-v1" "gatewayapi/httproute-my-http-app-v1.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        e|E)
            deploy_resource "avi-httproute-v1-extended" "gatewayapi/httproute-my-http-app-v1-extended.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        f|F)
            deploy_resource "avi-httproute-v2" "gatewayapi/httproute-my-http-app-v2.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        g|G)
            deploy_resource "avi-httproute-v2-v3" "gatewayapi/httproute-my-http-app-v2-v3.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        h|H)
            deploy_resource "avi-service-v1" "gatewayapi/service-svc-v1.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        i|I)
            deploy_resource "avi-service-v2" "gatewayapi/service-svc-v2.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        j|J)
            deploy_resource "avi-service-v3" "gatewayapi/service-svc-v3.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        k|K)
            deploy_resource "avi-deployment-v1" "gatewayapi/deployment-avi-hello-world-v1.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        l|L)
            deploy_resource "avi-deployment-v2" "gatewayapi/deployment-avi-hello-world-v2.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        m|M)
            # Scale v1 deployment to 6 pods
            echo "Scaling v1 Deployment to 6 Pods..."
            echo "=========================================="
            
            # Check if deployment exists
            if resource_exists "deployment" "avi-hello-world-v1"; then
                echo "Scaling deployment avi-hello-world-v1 to 6 replicas..."
                kubectl scale deployment avi-hello-world-v1 --replicas=6
                
                # Verify scaling
                sleep 3
                echo "Scaling complete. Current status:"
                echo "=========================================="
                kubectl get deployments -n default -o wide | grep avi-hello-world-v1
                echo "Pod status:"
                kubectl get pods -n default -o wide | grep avi-hello-world-v1
                echo "=========================================="
                echo "Deployment scaled to 6 pods successfully!"
            else
                echo "Error: Deployment avi-hello-world-v1 not found."
                echo "Please deploy the v1 stack first using option 'a'."
            fi
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        n|N)
            deploy_resource "avi-healthmonitor" "gatewayapi/healthmonitor-my-health-monitor.yaml" "healthmonitor"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        o|O)
            deploy_resource "avi-l7rule" "gatewayapi/l7rule-gw-sec.yaml" "l7rule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        p|P)
            deploy_resource "avi-routebackendextension" "gatewayapi/routebackendextension-my-route-backend-extension.yaml" "routebackendextension"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        q|Q)
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
        e|E)
            deploy_resource "avi-httproute-v1-extended" "gatewayapi/httproute-v1-extended.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        f|F)
            deploy_resource "avi-httproute-v2" "gatewayapi/httproute-v2.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        g|G)
            deploy_resource "avi-httproute-v2-v3" "gatewayapi/httproute-v2-v3.yaml" "httproute"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        h|H)
            deploy_resource "avi-service-v1" "gatewayapi/service-v1.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        i|I)
            deploy_resource "avi-service-v2" "gatewayapi/service-v2.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        j|J)
            deploy_resource "avi-service-v3" "gatewayapi/service-v3.yaml" "service"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        k|K)
            deploy_resource "avi-deployment-v1" "gatewayapi/deployment-v1.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        l|L)
            deploy_resource "avi-deployment-v2" "gatewayapi/deployment-v2.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        m|M)
            # Scale v1 deployment to 6 pods
            echo "Scaling v1 Deployment to 6 Pods..."
            echo "=========================================="
            
            # Check if deployment exists
            if resource_exists "deployment" "avi-hello-world-v1"; then
                echo "Scaling deployment avi-hello-world-v1 to 6 replicas..."
                kubectl scale deployment avi-hello-world-v1 --replicas=6
                
                # Verify scaling
                sleep 3
                echo "Scaling complete. Current status:"
                echo "=========================================="
                kubectl get deployments -n default -o wide | grep avi-hello-world-v1
                echo "Pod status:"
                kubectl get pods -n default -o wide | grep avi-hello-world-v1
                echo "=========================================="
                echo "Deployment scaled to 6 pods successfully!"
            else
                echo "Error: Deployment avi-hello-world-v1 not found."
                echo "Please deploy the v1 stack first using option 'a'."
            fi
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        n|N)
            deploy_resource "avi-healthmonitor" "gatewayapi/healthmonitor.yaml" "healthmonitor"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        o|O)
            deploy_resource "avi-l7rule" "gatewayapi/l7rule.yaml" "l7rule"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        p|P)
            deploy_resource "avi-routebackendextension" "gatewayapi/routebackendextension.yaml" "routebackendextension"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        q|Q)
            deploy_resource "avi-aviinfrasetting" "gatewayapi/aviinfrasetting.yaml" "aviinfrasetting"
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
        d|D)
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