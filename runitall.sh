#!/bin/bash
#
# Main execution script for nested vSphere automation
# Updated to use new role-based playbooks
#
# Set USE_LEGACY=true to use old main.yml (for backward compatibility)
# Set USE_LEGACY=false to use new playbooks (default)

USE_LEGACY="${USE_LEGACY:-false}"

echo "https://github.com/jimccann-rh/nested-ova-ansible"
echo ""
echo "========================================="
echo "Nested vSphere Automation Script"
echo "========================================="
echo "Using legacy playbooks: $USE_LEGACY"
echo ""

# Environment configuration
VERSION="${VERSION:-8}"

# Version 8 examples
ESXI_HOSTS_V8='["nested8-myjobname1-host.vpshere.local","nested8-myjobname2-host.vpshere.local"]'
VC_HOSTS_V8='["nested8-myjobname-VC.vpshere.local"]'

# Version 9 examples
ESXI_HOSTS_V9='["nested9-myjobname1-host.vpshere.local","nested9-myjobname2-host.vpshere.local"]'
VC_HOSTS_V9='["nested9-myjobname-VC.vpshere.local"]'

# Select hosts based on version
if [ "$VERSION" = "9" ]; then
    ESXI_HOSTS="$ESXI_HOSTS_V9"
    VC_HOSTS="$VC_HOSTS_V9"
else
    ESXI_HOSTS="$ESXI_HOSTS_V8"
    VC_HOSTS="$VC_HOSTS_V8"
fi

ESXI_MEMORY="${ESXI_MEMORY:-65536}"
ESXI_CPU="${ESXI_CPU:-16}"

if [ "$USE_LEGACY" = "true" ]; then
    echo "========================================="
    echo "Using LEGACY main.yml playbook"
    echo "========================================="

    echo "@@@ GOING TO DELETE NESTED VM'S IN 10 SECONDS"
    sleep 10

    echo "Removing existing environment..."
    time ANSIBLE_LOG_PATH=/tmp/dynamic_$(date +"%d%m%Y_%H%M%S").log \
      ansible-playbook -i hosts main.yml \
      --extra-var version="$VERSION" \
      --extra-var='{"target_hosts": [nested8-myjobname1-host.vpshere.local,nested8-myjobname2-host.vpshere.local]}' \
      --extra-var='{"target_vcs": [nested8-myjobname-VC.vpshere.local]}' \
      --extra-var removevsphere=true -t removevsphere

    echo ""
    echo "@@@ GOING TO CREATE NESTED VSPHERE ENVIRONMENT"
    sleep 5

    echo "Deploying nested environment..."
    time ANSIBLE_LOG_PATH=/tmp/dynamic_$(date +"%d%m%Y_%H%M%S").log \
      ansible-playbook -i hosts main.yml \
      --extra-var version="$VERSION" \
      --extra-var='{"target_hosts": [nested8-myjobname1-host.vpshere.local,nested8-myjobname2-host.vpshere.local]}' \
      --extra-var='{"target_vcs": [nested8-myjobname-VC.vpshere.local]}' \
      --extra-var esximemory="$ESXI_MEMORY" \
      --extra-var esxicpu="$ESXI_CPU"

    echo ""
    echo "@@@ RERUN SCRIPT FOR CONFIRMING ENVIRONMENT"
    time ansible-playbook -i hosts main.yml \
      --extra-var version="$VERSION" \
      --extra-var='{"target_hosts": [nested8-myjobname1-host.vpshere.local,nested8-myjobname2-host.vpshere.local]}' \
      --extra-var='{"target_vcs": [nested8-myjobname-VC.vpshere.local]}' \
      --extra-var esximemory="$ESXI_MEMORY" \
      --extra-var esxicpu="$ESXI_CPU"

    echo ""
    echo "### CREATING CRONJOB"
    time ansible-playbook -i hosts main.yml \
      --extra-var createcron=true \
      --extra-var version="$VERSION" \
      --extra-var='{"target_hosts": [nested8-myjobname1-host.vpshere.local]}' \
      --extra-var='{"target_vcs": [nested8-myjobname-VC.vpshere.local]}' \
      --extra-var esximemory="$ESXI_MEMORY" \
      --extra-var esxicpu="$ESXI_CPU"

else
    echo "========================================="
    echo "Using NEW role-based playbooks"
    echo "========================================="

    echo "@@@ GOING TO DELETE NESTED VM'S IN 10 SECONDS"
    sleep 10

    echo "Removing existing environment..."
    time ANSIBLE_LOG_PATH=/tmp/cleanup_$(date +"%d%m%Y_%H%M%S").log \
      ansible-playbook -i hosts playbooks/remove_environment.yml \
      -e "nested_esxi_hosts=$ESXI_HOSTS" \
      -e "nested_vcenter_hosts=$VC_HOSTS" \
      -e "removevsphere=true"

    echo ""
    echo "@@@ GOING TO CREATE NESTED VSPHERE ENVIRONMENT"
    sleep 5

    echo "Deploying nested environment..."
    time ANSIBLE_LOG_PATH=/tmp/deploy_$(date +"%d%m%Y_%H%M%S").log \
      ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
      -e "nested_environment_version=$VERSION" \
      -e "nested_esxi_hosts=$ESXI_HOSTS" \
      -e "nested_vcenter_hosts=$VC_HOSTS" \
      -e "nested_esxi_memory_mb=$ESXI_MEMORY" \
      -e "nested_esxi_cpu_count=$ESXI_CPU"

    echo ""
    echo "@@@ RERUN SCRIPT FOR CONFIRMING ENVIRONMENT"
    time ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
      -e "nested_environment_version=$VERSION" \
      -e "nested_esxi_hosts=$ESXI_HOSTS" \
      -e "nested_vcenter_hosts=$VC_HOSTS" \
      -e "nested_esxi_memory_mb=$ESXI_MEMORY" \
      -e "nested_esxi_cpu_count=$ESXI_CPU"

    echo ""
    echo "### CREATING CRONJOB (using lifecycle_management role)"
    time ansible-playbook -i hosts playbooks/remove_environment.yml \
      -e "nested_esxi_hosts=$ESXI_HOSTS" \
      -e "nested_vcenter_hosts=$VC_HOSTS" \
      -e "createcron=true" \
      -e "removevsphere=false"
fi

echo ""
echo "========================================="
echo "@@@ DONE"
echo "========================================="
echo ""
echo "Deployed Configuration:"
echo "  Version: $VERSION"
echo "  ESXi Hosts: $ESXI_HOSTS"
echo "  vCenter Hosts: $VC_HOSTS"
echo "  ESXi Memory: $ESXI_MEMORY MB"
echo "  ESXi CPU: $ESXI_CPU"
echo ""
echo "To use different versions:"
echo "  VERSION=8 ./runitall.sh  # Deploy vSphere 8 (default)"
echo "  VERSION=9 ./runitall.sh  # Deploy vSphere 9"
echo ""
echo "To switch between legacy and new playbooks:"
echo "  USE_LEGACY=true  ./runitall.sh  # Use old main.yml"
echo "  USE_LEGACY=false ./runitall.sh  # Use new role-based playbooks (default)"
echo ""
