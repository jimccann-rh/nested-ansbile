#!/bin/bash
#
# Example script for deploying a small nested vSphere 9 environment
# Two ESXi hosts + vCenter with reduced resources
#

set -e

echo "========================================="
echo "Small vSphere 9 Nested Environment"
echo "========================================="

# Configuration
VERSION="9"
ESXI_HOSTS='["nested9-singlemyjobname1-host.vpshere.local","nested9-singlemyjobname2-host.vpshere.local"]'
VC_HOSTS='["nested9-singlemyjobname-VC.vpshere.local"]'
ESXI_MEMORY="65536"  # 64 GB
ESXI_CPU="16"

echo "Configuration:"
echo "  Version: $VERSION"
echo "  ESXi Hosts: $ESXI_HOSTS"
echo "  vCenter Hosts: $VC_HOSTS"
echo "  ESXi Memory: $ESXI_MEMORY MB"
echo "  ESXi CPU: $ESXI_CPU"
echo "========================================="

# Using new role-based playbooks
time ANSIBLE_LOG_PATH=/tmp/deploy_v9_small_$(date +"%d%m%Y_%H%M%S").log \
  ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e "nested_environment_version=$VERSION" \
  -e "nested_esxi_hosts=$ESXI_HOSTS" \
  -e "nested_vcenter_hosts=$VC_HOSTS" \
  -e "nested_esxi_memory_mb=$ESXI_MEMORY" \
  -e "nested_esxi_cpu_count=$ESXI_CPU"

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "To remove this environment, run:"
echo "  ESXI_HOSTS='$ESXI_HOSTS' \\"
echo "  VC_HOSTS='$VC_HOSTS' \\"
echo "  ./scripts/cleanup.sh"
echo ""
