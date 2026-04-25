# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A demonstration repository for **AKO (Avi Kubernetes Operator)** — VMware's load balancer controller for Kubernetes. It provides automated installation scripts, interactive demo scripts, and pre-built Kubernetes manifests for showcasing AKO with both traditional Ingress and modern Gateway API patterns.

There is no build system, no test suite, and no linting. The "code" is Bash scripts and Kubernetes YAML manifests.

## Key Scripts

| Script | Purpose |
|---|---|
| `./install_ako.sh` | Install or uninstall AKO via Helm; checks for kubectl/helm/Gateway API CRDs |
| `./ingressDemo.sh` | Interactive menu-driven demo using Kubernetes Ingress API |
| `./GatewayDemo.sh` | Interactive menu-driven demo using Gateway API (GatewayClass/Gateway/HTTPRoute) |

Run any script directly: `./install_ako.sh`, `./ingressDemo.sh`, `./GatewayDemo.sh`

## Required External Dependencies

Before running scripts, the following must be available:

- **kubectl** and **helm** (auto-installed by `install_ako.sh` if missing)
- **Gateway API CRDs** v1.0.0 from kubernetes-sigs (auto-installed by `install_ako.sh`)
- **Avi Controller** appliance — credentials go in `values-secret.yaml` (created from `values-secret.yaml.template`)

The file `values-secret.yaml` must be created before running `install_ako.sh`. It is gitignored and holds real credentials (controller host/IP, username/password or auth token, cloud name, tenant, service engine group, VRF context, node and VIP network lists).

## Architecture

### Two Parallel Deployment Models

**Ingress model** (`ingress/` directory):
- Standard `Ingress` resources + AKO-specific CRDs: `HostRule` and `L7Rule`
- TLS managed via Kubernetes secrets (see `ingress/create-tls-secret.sh`)

**Gateway API model** (`gatewayapi/` directory):
- `GatewayClass` → `Gateway` → `HTTPRoute` chain (Kubernetes-standardized)
- Extended with AKO CRDs: `HealthMonitor`, `RouteBackendExtension`, `AVIInfrasetting`, `L7Rule`

### Multi-Version Application Pattern

The Gateway API demo deploys three versions (v1/v2/v3) of a hello-world app plus a liveness variant. Each version has its own `Deployment`, `Service`, and routing config — used to demonstrate canary/weighted routing via HTTPRoute rules.

### Configuration Split

- `ako-values.yaml` — non-sensitive Helm values (already populated with lab defaults)
- `values-secret.yaml` — sensitive credentials; never committed (gitignored)
- `ako_manager.conf` — default AKO version, namespace, and Helm repo URL

### Script Conventions

- All scripts use color-coded output: green = success, red = error, yellow = warning
- Operations are idempotent — scripts check whether resources already exist before applying
- Interactive menus drive the demo flow; scripts do not accept CLI arguments for the demo actions
- AKO is deployed into the `avi-system` namespace by default
