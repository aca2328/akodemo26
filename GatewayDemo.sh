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

# Main menu
while true; do
    clear
    echo "=========================================="
    echo "  Gateway API Resources Deployment Menu"
    echo "=========================================="
    echo "a. Deploy Demo Application"
    echo "b. Deploy Gateway"
    echo "c. Deploy Gateway with Static IP"
    echo "d. Deploy HTTPRoute v1"
    echo "e. Deploy HTTPRoute v1 Extended"
    echo "f. Deploy HTTPRoute v2"
    echo "g. Deploy HTTPRoute v2 and v3"
    echo "h. Deploy Service v1"
    echo "i. Deploy Service v2"
    echo "j. Deploy Service v3"
    echo "k. Deploy Deployment v1"
    echo "l. Deploy Deployment v2"
    echo "m. Deploy Deployment v3"
    echo "n. Deploy HealthMonitor"
    echo "o. Deploy L7Rule"
    echo "p. Deploy RouteBackendExtension"
    echo "q. Deploy AVIInfrasetting"
    echo "r. Verify All Deployments"
    echo "s. View AKO Logs"
    echo "x. Delete ALL Resources"
    echo "z. Exit"
    echo "=========================================="
    echo -n "Press key (a-z, s, x): "
    read -n 1 choice
    echo
    
    case $choice in
        a|A)
            deploy_resource "avi-hello-world" "gatewayapi/deployment-avi-hello-world.yaml" "deployment"
            echo -n "Press any key to continue..."
            read -n 1 -s
            ;;
        b|B)
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
            deploy_resource "avi-deployment-v3" "gatewayapi/deployment-avi-hello-world-v3.yaml" "deployment"
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
            deploy_resource "avi-deployment-v3" "gatewayapi/deployment-avi-hello-world-v3.yaml" "deployment"
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
            deploy_resource "avi-deployment-v3" "gatewayapi/deployment-v3.yaml" "deployment"
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