# AKO Installation Script

This guide describes how to use the `install_ako.sh` script to deploy AKO (Avi Kubernetes Operator).

## Prerequisites

- Kubernetes cluster with admin access
- `kubectl` configured to access your cluster
- `helm` installed (version 3+)
- Network connectivity to Avi Controller

## Installation Steps

### 1. Run the Installation Script

```bash
./install_ako.sh
```

### 2. Configuration Setup

The script will guide you through the following steps:

#### 2.1. Configuration File Setup
- Checks for `ako_manager.conf`
- Creates default configuration if missing:
  ```
  TARGET_AKO_VERSION="2.1.2"
  VALUES_FILE="ako-values.yaml"
  NAMESPACE="avi-system"
  HELM_REPO_NAME="ako"
  HELM_REPO_URL="oci://projects.registry.vmware.com/ako/helm-charts"
  ```
- Allows you to confirm or modify these values

#### 2.2. Dependency Installation
- Checks for required tools: `kubectl`, `helm`
- Installs missing dependencies automatically
- Installs Gateway API CRDs if not present

#### 2.3. Secrets Configuration
- Checks for `values-secret.yaml`
- If missing, creates it from `values-secret.yaml.template`
- Offers to edit `values-secret.yaml` to configure:
  - Avi Controller credentials
  - Network settings
  - Cluster-specific configuration

#### 2.4. AKO Values Configuration
- Checks for `ako-values.yaml`
- Retrieves default values from OCI registry if missing
- Offers to edit the configuration file

### 3. Installation Options

After setup, the script presents a menu:

```
--- Main Menu ---
1) Install AKO
2) Uninstall AKO
3) Exit
```

#### Option 1: Install AKO
- Deploys AKO using Helm
- Uses both `ako-values.yaml` and `values-secret.yaml`
- Creates namespace if it doesn't exist
- Shows pod status after installation

#### Option 2: Uninstall AKO
- Patches ConfigMap for cleanup
- Uninstalls Helm release
- Removes AKO CRDs

#### Option 3: Exit
- Exits the script

## File Structure

### Configuration Files

- `ako_manager.conf`: Main configuration (version, namespace, etc.)
- `ako-values.yaml`: Non-sensitive AKO configuration
- `values-secret.yaml`: Sensitive credentials and custom settings
- `values-secret.yaml.template`: Template for creating secrets file

### Script Files

- `install_ako.sh`: Main installation script

## Usage Examples

### Install AKO with Default Configuration
```bash
./install_ako.sh
# Select option 1 when prompted
```

### Install AKO with Custom Configuration
```bash
# Edit configuration files first
vi ako_manager.conf
vi ako-values.yaml
vi values-secret.yaml

# Then run installation
./install_ako.sh
```

### Uninstall AKO
```bash
./install_ako.sh
# Select option 2 when prompted
```

## Files Created/Modified

- `ako_manager.conf`: Configuration settings
- `ako-values.yaml`: AKO Helm values (non-sensitive)
- `values-secret.yaml`: Sensitive configuration (created from template)
- Kubernetes resources in the specified namespace

## Notes

- `values-secret.yaml` is excluded from version control via `.gitignore`
- The script uses OCI-based Helm charts
- Gateway API CRDs are installed automatically if missing
- All sensitive information is stored in `values-secret.yaml`