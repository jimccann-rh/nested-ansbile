#!/bin/bash
#
# Wrapper script for deploying nested vSphere environment
#
# Usage examples:
#
# Version 8:
#   VERSION=8 \
#   ESXI_HOSTS='["nested8-host1.local","nested8-host2.local"]' \
#   VC_HOSTS='["nested8-vc.local"]' \
#   ./scripts/deploy.sh
#
# Version 9:
#   VERSION=9 \
#   ESXI_HOSTS='["nested9-host1.local","nested9-host2.local"]' \
#   VC_HOSTS='["nested9-vc.local"]' \
#   ./scripts/deploy.sh
#
# Or using command line arguments:
#   ./scripts/deploy.sh --version 8 \
#     --esxi-hosts nested8-host1.local,nested8-host2.local \
#     --vc-hosts nested8-vc.local
#
#   ./scripts/deploy.sh --version 9 \
#     --esxi-hosts nested9-host1.local,nested9-host2.local \
#     --vc-hosts nested9-vc.local

set -e

# Default values
VERSION="${VERSION:-8}"
ESXI_HOSTS="${ESXI_HOSTS:-[]}"
VC_HOSTS="${VC_HOSTS:-[]}"
ESXI_MEMORY="${ESXI_MEMORY:-131072}"
ESXI_CPU="${ESXI_CPU:-20}"
INVENTORY="${INVENTORY:-hosts}"
TAGS="${TAGS:-}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --esxi-hosts)
      # Convert comma-separated to JSON array
      IFS=',' read -ra HOSTS <<< "$2"
      ESXI_HOSTS="["
      for host in "${HOSTS[@]}"; do
        ESXI_HOSTS+="\"$host\","
      done
      ESXI_HOSTS="${ESXI_HOSTS%,}]"
      shift 2
      ;;
    --vc-hosts)
      # Convert comma-separated to JSON array
      IFS=',' read -ra HOSTS <<< "$2"
      VC_HOSTS="["
      for host in "${HOSTS[@]}"; do
        VC_HOSTS+="\"$host\","
      done
      VC_HOSTS="${VC_HOSTS%,}]"
      shift 2
      ;;
    --esxi-memory)
      ESXI_MEMORY="$2"
      shift 2
      ;;
    --esxi-cpu)
      ESXI_CPU="$2"
      shift 2
      ;;
    --tags)
      TAGS="--tags $2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --version VERSION         ESXi/vCenter version (8 or 9)"
      echo "  --esxi-hosts HOSTS        Comma-separated list of ESXi host names"
      echo "  --vc-hosts HOSTS          Comma-separated list of vCenter host names"
      echo "  --esxi-memory MB          Memory per ESXi host in MB (default: 131072)"
      echo "  --esxi-cpu COUNT          CPU count per ESXi host (default: 20)"
      echo "  --tags TAGS               Ansible tags to run"
      echo "  --help                    Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  VERSION                   ESXi/vCenter version"
      echo "  ESXI_HOSTS                JSON array of ESXi host names"
      echo "  VC_HOSTS                  JSON array of vCenter host names"
      echo "  ESXI_MEMORY               Memory per ESXi host in MB"
      echo "  ESXI_CPU                  CPU count per ESXi host"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Display configuration
echo "========================================="
echo "Nested vSphere Deployment Configuration"
echo "========================================="
echo "Version: $VERSION"
echo "ESXi Hosts: $ESXI_HOSTS"
echo "vCenter Hosts: $VC_HOSTS"
echo "ESXi Memory: $ESXI_MEMORY MB"
echo "ESXi CPU: $ESXI_CPU"
echo "========================================="

# Run ansible playbook
ANSIBLE_LOG_PATH="/tmp/deploy_$(date +"%d%m%Y_%H%M%S").log"

echo "Running deployment playbook..."
echo "Log file: $ANSIBLE_LOG_PATH"

time ansible-playbook -i "$INVENTORY" playbooks/deploy_nested_environment.yml \
  -e "nested_environment_version=$VERSION" \
  -e "nested_esxi_hosts=$ESXI_HOSTS" \
  -e "nested_vcenter_hosts=$VC_HOSTS" \
  -e "nested_esxi_memory_mb=$ESXI_MEMORY" \
  -e "nested_esxi_cpu_count=$ESXI_CPU" \
  $TAGS

echo "========================================="
echo "Deployment complete!"
echo "========================================="
