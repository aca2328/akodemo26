#!/bin/bash

# Interactive menu for deploying Kubernetes resources (ClusterIP or NodePort mode)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==========================================
# Helper functions
# ==========================================

resource_exists() {
    local resource_type=$1
    local resource_name=$2
    kubectl get $resource_type $resource_name -n default &> /dev/null
    return $?
}

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
                echo -e "${RED}Error: Failed to delete $resource_name${NC}"
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
            echo -e "${RED}Error: Failed to deploy $resource_name${NC}"
            return 1
        fi
        echo ""
        echo -e "${GREEN}Successfully deployed $resource_name. Resource details:${NC}"
        echo "=========================================="
        cat $resource_file
        echo "=========================================="
    fi
    sleep 2
    return 0
}

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
                echo -e "${RED}Error: Failed to delete TLS secret $secret_name${NC}"
                return 1
            fi
            echo "TLS secret deleted successfully."
        else
            echo "Skipping deletion of $secret_name."
            return 0
        fi
    else
        echo "TLS secret $secret_name does not exist. Creating..."
        echo "Generating private key..."
        openssl genrsa -out ssl.key 2048
        echo "Generating self-signed certificate..."
        openssl req -new -x509 -key ssl.key -out ssl.cert -days 360 -subj "/CN=$cn_name"
        echo "Creating Kubernetes TLS secret..."
        kubectl create secret tls $secret_name --key=ssl.key --cert=ssl.cert -n default
        echo "Cleaning up temporary files..."
        rm -f ssl.key ssl.cert
        echo -e "${GREEN}TLS secret '$secret_name' created successfully!${NC}"
        echo "Verifying secret..."
        kubectl get secret $secret_name -n default -o yaml | grep -E "(name:|type:)"
    fi
    echo -n "Press any key to continue..."
    read -n 1 -s
    return 0
}

toggle_delete_config() {
    local ns="avi-system"
    local cm="avi-k8s-config"

    if ! kubectl get configmap $cm -n $ns &> /dev/null; then
        echo -e "${RED}ConfigMap $cm not found in namespace $ns.${NC}"
        echo -n "Press any key to continue..."
        read -n 1 -s
        return 1
    fi

    local current
    current=$(kubectl get configmap $cm -n $ns -o jsonpath='{.data.deleteConfig}')
    echo -e "Current ${YELLOW}deleteConfig${NC} = ${YELLOW}${current}${NC}"

    local new_val
    if [ "$current" = "true" ]; then
        new_val="false"
    else
        new_val="true"
    fi

    echo -n "Toggle to \"$new_val\"? (y/n): "
    read -n 1 confirm
    echo
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        kubectl patch configmap $cm -n $ns --type merge -p "{\"data\":{\"deleteConfig\":\"$new_val\"}}"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}deleteConfig set to \"$new_val\".${NC}"
        else
            echo -e "${RED}Failed to patch ConfigMap.${NC}"
        fi
    else
        echo "No change made."
    fi
    echo -n "Press any key to continue..."
    read -n 1 -s
}

# ==========================================
# Mode selection
# ==========================================

clear
echo "=========================================="
echo "  AKO Ingress Demo"
echo "=========================================="
echo -e "${YELLOW}Select demo mode:${NC}"
echo "1) ClusterIP  — manifests in ingress/"
echo "2) NodePort   — manifests in nodeport/"
echo "=========================================="
echo -n "Press key (1 or 2): "
read -n 1 MODE_CHOICE
echo

case $MODE_CHOICE in
    1) MODE="clusterip" ;;
    2) MODE="nodeport"  ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Mode: $MODE${NC}"
sleep 1

# ==========================================
# Main menu loop
# ==========================================

while true; do
    clear

    if [ "$MODE" = "clusterip" ]; then
        echo "=========================================="
        echo -e "  Ingress Demo — ${GREEN}ClusterIP mode${NC}"
        echo "=========================================="
        echo "1. Deploy Demo Application (Deployment + ClusterIP Service)"
        echo "2. Deploy LoadBalancer Service"
        echo "3. Deploy Ingress Resource"
        echo "4. Deploy HostRule for hello.110.ams.avilab.eu"
        echo "5. Deploy HostRule for hello2.110.ams.avilab.eu"
        echo "6. Deploy TLS Ingress (Optional)"
        echo "7. Manage TLS Secret for hello-tls.110.ams.avilab.eu"
        echo "8. Manage TLS Secret for hello2-tls.110.ams.avilab.eu"
        echo "9. View AKO Logs"
        echo "c. Toggle deleteConfig in avi-k8s-config"
        echo "v. Verify All Deployments"
        echo "d. Delete ALL Resources"
        echo "x. Exit"
        echo "=========================================="
        echo -n "Press key (1-9, c, v, d, x): "
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
                deploy_resource "tls-avi-hello-ingress" "ingress/tls-ingress.yaml" "ingress"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            7)
                manage_tls_secret "hello-tls.110.ams.avilab.eu" "hello-tls.110.ams.avilab.eu"
                ;;
            8)
                manage_tls_secret "hello2-tls.110.ams.avilab.eu" "hello2-tls.110.ams.avilab.eu"
                ;;
            9)
                echo "Viewing AKO logs..."
                echo "=========================================="
                kubectl logs ako-0 -n avi-system --tail=50
                echo "=========================================="
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            c|C)
                toggle_delete_config
                ;;
            d|D)
                echo -e "${YELLOW}Deleting ALL ClusterIP demo resources...${NC}"
                read -p "Are you sure (y/n)? " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    kubectl delete deployment avi-hello-world -n default 2>/dev/null || true
                    kubectl delete service avi-hello-svc -n default 2>/dev/null || true
                    kubectl delete service avi-hello-l4 -n default 2>/dev/null || true
                    kubectl delete ingress avi-hello-ingress -n default 2>/dev/null || true
                    kubectl delete ingress tls-avi-hello-ingress -n default 2>/dev/null || true
                    kubectl delete hostrule hello-hr -n default 2>/dev/null || true
                    kubectl delete hostrule hello2-hr -n default 2>/dev/null || true
                    kubectl delete secret hello-tls.110.ams.avilab.eu -n default 2>/dev/null || true
                    kubectl delete secret hello2-tls.110.ams.avilab.eu -n default 2>/dev/null || true
                    echo -e "${GREEN}All ClusterIP demo resources deleted.${NC}"
                else
                    echo "Delete operation cancelled."
                fi
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            v|V)
                echo "Deployments:"
                kubectl get deployments -n default | grep avi-hello-world || echo "Not found"
                echo "Services:"
                kubectl get services -n default | grep avi-hello || echo "Not found"
                echo "Ingress:"
                kubectl get ingress -n default | grep -E "(avi-hello-ingress|tls-avi-hello-ingress)" || echo "Not found"
                echo "HostRules:"
                kubectl get hostrules -n default | grep hello || echo "Not found"
                echo "TLS Secrets:"
                kubectl get secrets -n default | grep -E "(hello-tls\.110\.ams\.avilab\.eu|hello2-tls\.110\.ams\.avilab\.eu)" || echo "No TLS secrets found"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            x|X)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
        esac

    else  # nodeport mode

        echo "=========================================="
        echo -e "  Ingress Demo — ${GREEN}NodePort mode${NC}"
        echo "=========================================="
        echo "1. Deploy Demo Application (Deployment + NodePort Service)"
        echo "2. Deploy LoadBalancer Service"
        echo "3. Deploy Ingress Resource"
        echo "4. Deploy HostRule for hello-np.110.ams.avilab.eu"
        echo "5. Deploy HostRule for hello2-np.110.ams.avilab.eu"
        echo "6. Deploy TLS Ingress (Optional)"
        echo "7. Manage TLS Secret for hello-np-tls.110.ams.avilab.eu"
        echo "8. Manage TLS Secret for hello2-np-tls.110.ams.avilab.eu"
        echo "9. View AKO Logs"
        echo "c. Toggle deleteConfig in avi-k8s-config"
        echo "v. Verify All Deployments"
        echo "d. Delete ALL Resources"
        echo "x. Exit"
        echo "=========================================="
        echo -n "Press key (1-9, c, v, d, x): "
        read -n 1 choice
        echo

        case $choice in
            1)
                deploy_resource "avi-hello-nodeport" "nodeport/deployment.yaml" "deployment"
                deploy_resource "avi-hello-nodeport-svc" "nodeport/service-nodeport.yaml" "service"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            2)
                deploy_resource "avi-hello-l4" "ingress/svc.yaml" "service"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            3)
                deploy_resource "avi-hello-nodeport-ingress" "nodeport/ingress.yaml" "ingress"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            4)
                deploy_resource "hello-np-hr" "nodeport/hello-np-hostrule.yaml" "hostrule"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            5)
                deploy_resource "hello2-np-hr" "nodeport/hello2-np-hostrule.yaml" "hostrule"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            6)
                deploy_resource "tls-avi-hello-nodeport-ingress" "nodeport/tls-ingress.yaml" "ingress"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            7)
                manage_tls_secret "hello-np-tls.110.ams.avilab.eu" "hello-np-tls.110.ams.avilab.eu"
                ;;
            8)
                manage_tls_secret "hello2-np-tls.110.ams.avilab.eu" "hello2-np-tls.110.ams.avilab.eu"
                ;;
            9)
                echo "Viewing AKO logs..."
                echo "=========================================="
                kubectl logs ako-0 -n avi-system --tail=50
                echo "=========================================="
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            c|C)
                toggle_delete_config
                ;;
            d|D)
                echo -e "${YELLOW}Deleting ALL NodePort demo resources...${NC}"
                read -p "Are you sure (y/n)? " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    kubectl delete deployment avi-hello-nodeport -n default 2>/dev/null || true
                    kubectl delete service avi-hello-nodeport-svc -n default 2>/dev/null || true
                    kubectl delete service avi-hello-l4 -n default 2>/dev/null || true
                    kubectl delete ingress avi-hello-nodeport-ingress -n default 2>/dev/null || true
                    kubectl delete ingress tls-avi-hello-nodeport-ingress -n default 2>/dev/null || true
                    kubectl delete hostrule hello-np-hr -n default 2>/dev/null || true
                    kubectl delete hostrule hello2-np-hr -n default 2>/dev/null || true
                    kubectl delete secret hello-np-tls.110.ams.avilab.eu -n default 2>/dev/null || true
                    kubectl delete secret hello2-np-tls.110.ams.avilab.eu -n default 2>/dev/null || true
                    echo -e "${GREEN}All NodePort demo resources deleted.${NC}"
                else
                    echo "Delete operation cancelled."
                fi
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            v|V)
                echo "Deployments:"
                kubectl get deployments -n default | grep avi-hello-nodeport || echo "Not found"
                echo "Services:"
                kubectl get services -n default | grep -E "(avi-hello-nodeport|avi-hello-l4)" || echo "Not found"
                echo "Ingress:"
                kubectl get ingress -n default | grep -E "(avi-hello-nodeport-ingress|tls-avi-hello-nodeport-ingress)" || echo "Not found"
                echo "HostRules:"
                kubectl get hostrules -n default | grep -E "(hello-np-hr|hello2-np-hr)" || echo "Not found"
                echo "TLS Secrets:"
                kubectl get secrets -n default | grep -E "(hello-np-tls\.110\.ams\.avilab\.eu|hello2-np-tls\.110\.ams\.avilab\.eu)" || echo "No TLS secrets found"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
            x|X)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                echo -n "Press any key to continue..."
                read -n 1 -s
                ;;
        esac
    fi
done
