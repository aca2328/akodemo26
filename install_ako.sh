#!/bin/bash

# Configuration File
CONFIG_FILE="ako_manager.conf"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ==========================================
# 0. Configuration Management
# ==========================================

manage_configuration() {
    # 1. Check for config file or create defaults
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}Creating default configuration file: $CONFIG_FILE${NC}"
        cat <<EOF > "$CONFIG_FILE"
TARGET_AKO_VERSION="2.1.2"
VALUES_FILE="ako-values.yaml"
NAMESPACE="avi-system"
HELM_REPO_NAME="ako"
HELM_REPO_URL="oci://projects.registry.vmware.com/ako/helm-charts"
EOF
    fi
    
    # Load current variables
    source "$CONFIG_FILE"

    # 2. Propose modifications
    echo -e "${GREEN}Current Configuration:${NC}"
    echo "  AKO Version: $TARGET_AKO_VERSION"
    echo "  Namespace:   $NAMESPACE"
    echo "  Repo URL:    $HELM_REPO_URL"
    
    read -n 1 -p "Do you want to confirm these values? (y/n) [If 'n', you can edit them]: " confirm
    echo "" # Newline
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Press Enter to keep the [default] value${NC}"

        read -e -p "Target AKO Version: " -i "$TARGET_AKO_VERSION" TARGET_AKO_VERSION
        read -e -p "Values Filename: " -i "$VALUES_FILE" VALUES_FILE
        read -e -p "Target Namespace: " -i "$NAMESPACE" NAMESPACE
        read -e -p "Helm Chart Name: " -i "$HELM_REPO_NAME" HELM_REPO_NAME
        read -e -p "Helm OCI Registry URL: " -i "$HELM_REPO_URL" HELM_REPO_URL

        # Save updates back to file
        cat <<EOF > "$CONFIG_FILE"
TARGET_AKO_VERSION="$TARGET_AKO_VERSION"
VALUES_FILE="$VALUES_FILE"
NAMESPACE="$NAMESPACE"
HELM_REPO_NAME="$HELM_REPO_NAME"
HELM_REPO_URL="$HELM_REPO_URL"
EOF
        echo -e "${GREEN}Configuration updated in $CONFIG_FILE${NC}"
# 3. Install Logic
=======
    fi
}

# ==========================================
# 2.5. Secrets Configuration Management
# ==========================================

prepare_secrets_configuration() {
    SECRETS_FILE="values-secret.yaml"
    SECRETS_TEMPLATE="values-secret.yaml.template"
    
    if [ ! -f "$SECRETS_FILE" ]; then
        if [ -f "$SECRETS_TEMPLATE" ]; then
            echo -e "${YELLOW}No secrets file found. Creating from template...${NC}"
            cp "$SECRETS_TEMPLATE" "$SECRETS_FILE"
            echo -e "${GREEN}Created $SECRETS_FILE from template.${NC}"
            echo -e "${RED}IMPORTANT: Edit $SECRETS_FILE with your actual credentials and settings!${NC}"
        else
            echo -e "${RED}Warning: No secrets template found ($SECRETS_TEMPLATE).${NC}"
            echo -e "${RED}You need to create $SECRETS_FILE manually with your sensitive configuration.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Secrets file '$SECRETS_FILE' detected.${NC}"
    fi
    
    # Propose editing the secrets file
    read -n 1 -p "Do you want to edit $SECRETS_FILE now to configure your credentials? (y/n): " edit_secrets
    echo "" # Newline
    if [[ "$edit_secrets" =~ ^[Yy]$ ]]; then
        if [ -f "$SECRETS_FILE" ]; then
            vi "$SECRETS_FILE"
        else
            echo -e "${RED}Error: $SECRETS_FILE not found. Cannot edit.${NC}"
        fi
    else
        echo -e "${YELLOW}Remember to edit $SECRETS_FILE before installation to set your credentials.${NC}"
    fi
}


# ==========================================
# 3. Install LogicRun config management before starting
manage_configuration

echo -e "${GREEN}--- AKO Manager (Version $TARGET_AKO_VERSION) ---${NC}"

# ==========================================
# 1. Dependency Checks & Installation
# ==========================================

check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"

    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}kubectl not found. Installing...${NC}"
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        echo -e "${GREEN}kubectl installed.${NC}"
    else
        echo -e "${GREEN}kubectl is already installed.${NC}"
    fi

    # Check helm
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}helm not found. Installing...${NC}"
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        echo -e "${GREEN}helm installed.${NC}"
    else
        echo -e "${GREEN}helm is already installed.${NC}"
    fi

    # Check Gateway API CRDs (Fixes: no matches for kind "GatewayClass")
    echo -e "${YELLOW}Checking Gateway API CRDs...${NC}"
    if ! kubectl get crd gatewayclasses.gateway.networking.k8s.io &> /dev/null; then
        echo -e "${RED}Gateway API CRDs (GatewayClass) not found. Installing standard CRDs (v1.0.0)...${NC}"
        # Installing standard install from kubernetes-sigs which includes GatewayClass, Gateway, HTTPRoute etc.
        kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Gateway API CRDs installed successfully.${NC}"
        else
            echo -e "${RED}Failed to install Gateway API CRDs. The AKO installation might fail.${NC}"
        fi
    else
        echo -e "${GREEN}Gateway API CRDs are already installed.${NC}"
    fi
}

# ==========================================
# 2. Configuration Management
# ==========================================

prepare_configuration() {
    # OCI does not use 'helm repo add'. We interact directly with the registry URL.

    if [ ! -f "$VALUES_FILE" ]; then
        echo -e "${YELLOW}File '$VALUES_FILE' not found.${NC}"
        echo -e "Retrieving default values from OCI registry for AKO version ${TARGET_AKO_VERSION}..."
        
        # Use OCI syntax to pull values
        if helm show values "${HELM_REPO_URL}/${HELM_REPO_NAME}" --version $TARGET_AKO_VERSION > "$VALUES_FILE"; then
             echo -e "${GREEN}Successfully created $VALUES_FILE${NC}"
        else
             echo -e "${RED}Error: Could not retrieve values for version $TARGET_AKO_VERSION from OCI registry.${NC}"
             echo -e "${RED}Ensure '${HELM_REPO_URL}/${HELM_REPO_NAME}' is correct and accessible.${NC}"
             return 1
        fi
    else
        echo -e "${GREEN}Configuration file '$VALUES_FILE' detected.${NC}"
    fi

    # Propose editing
    read -n 1 -p "Do you want to edit $VALUES_FILE now using vi? (y/n): " edit_choice
    echo "" # Newline
    if [[ "$edit_choice" =~ ^[Yy]$ ]]; then
        vi "$VALUES_FILE"
    fi
}

# ==========================================
# 3. Install Logic
# ==========================================

install_ako() {
    prepare_configuration
    if [ $? -ne 0 ]; then return; fi
    
    prepare_secrets_configuration
    if [ $? -ne 0 ]; then return; fi

    echo -e "${YELLOW}Starting Installation of AKO $TARGET_AKO_VERSION via OCI...${NC}"
    
    # Check if namespace exists, create if not (handled by --create-namespace, but good to check context)
    echo "Deploying to namespace: $NAMESPACE"

    helm install ako "${HELM_REPO_URL}/${HELM_REPO_NAME}" \
        --version $TARGET_AKO_VERSION \
        --namespace $NAMESPACE \
        --create-namespace \
        -f "$VALUES_FILE" \
        -f "values-secret.yaml"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}AKO Installation completed successfully!${NC}"
        kubectl get pods -n $NAMESPACE
    else
        echo -e "${RED}AKO Installation failed.${NC}"
    fi
}

# ==========================================
# 4. Uninstall Logic
# ==========================================

uninstall_ako() {
    echo -e "${YELLOW}Uninstalling AKO...${NC}"
    
    # Patch ConfigMap to trigger deletion of AVI objects
    echo -e "${YELLOW}Patching ConfigMap to ensure config deletion...${NC}"
    # Using $NAMESPACE variable instead of hardcoded 'avi-system' to match script config
    kubectl patch configmap avi-k8s-config -n $NAMESPACE --type merge -p '{"data":{"deleteConfig":"true"}}' || echo -e "${RED}Warning: ConfigMap patch failed. Continuing...${NC}"

    echo -e "${YELLOW}Waiting 10 seconds for cleanup synchronization...${NC}"
    sleep 10
    
    helm uninstall ako --namespace $NAMESPACE

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Helm release uninstalled.${NC}"
        
        # Clean up CRDs
        echo -e "${YELLOW}Cleaning up AKO CRDs (*.ako.vmware.com)...${NC}"
        CRD_LIST=$(kubectl get crd -o name | grep "ako.vmware.com")
        
        if [ -n "$CRD_LIST" ]; then
            echo "$CRD_LIST" | xargs kubectl delete
            echo -e "${GREEN}AKO CRDs and related objects deleted.${NC}"
        else
            echo -e "${GREEN}No AKO CRDs found to delete.${NC}"
        fi
        
        # Namespace deletion prompt removed
    else
        echo -e "${RED}Uninstall failed or release not found.${NC}"
    fi
}

# ==========================================
# Main Execution Flow
# ==========================================

check_dependencies

while true; do
    echo -e "\n${YELLOW}--- Main Menu ---${NC}"
    echo "1) Install AKO $TARGET_AKO_VERSION"
    echo "2) Uninstall AKO"
    echo "3) Exit"
    read -n 1 -p "Select an option [1-3]: " option
    echo "" # Newline

    case $option in
        1)
            install_ako
            ;;
        2)
            uninstall_ako
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
done
