#!/bin/bash
#
# Wrapper script for cleaning up nested vSphere environment
#
# Usage:
#   ESXI_HOSTS='["nested8-host1.local","nested8-host2.local"]' \
#   VC_HOSTS='["nested8-vc.local"]' \
#   ./scripts/cleanup.sh
#
# Or using command line arguments:
#   ./scripts/cleanup.sh --esxi-hosts nested8-host1.local,nested8-host2.local \
#     --vc-hosts nested8-vc.local

set -e

# Default values
ESXI_HOSTS="${ESXI_HOSTS:-[]}"
VC_HOSTS="${VC_HOSTS:-[]}"
INVENTORY="${INVENTORY:-hosts}"
FORCE="${FORCE:-true}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
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
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --esxi-hosts HOSTS        Comma-separated list of ESXi host names to remove"
      echo "  --vc-hosts HOSTS          Comma-separated list of vCenter host names to remove"
      echo "  --help                    Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  ESXI_HOSTS                JSON array of ESXi host names"
      echo "  VC_HOSTS                  JSON array of vCenter host names"
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
echo "Nested vSphere Cleanup Configuration"
echo "========================================="
echo "ESXi Hosts to remove: $ESXI_HOSTS"
echo "vCenter Hosts to remove: $VC_HOSTS"
echo "========================================="

# Confirmation prompt
read -p "Are you sure you want to delete these VMs? (yes/no): " confirmation
if [[ "$confirmation" != "yes" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

# Run ansible playbook
ANSIBLE_LOG_PATH="/tmp/cleanup_$(date +"%d%m%Y_%H%M%S").log"

echo "Running cleanup playbook..."
echo "Log file: $ANSIBLE_LOG_PATH"

time ansible-playbook -i "$INVENTORY" playbooks/remove_environment.yml \
  -e "nested_esxi_hosts=$ESXI_HOSTS" \
  -e "nested_vcenter_hosts=$VC_HOSTS" \
  -e "removevsphere=true"

echo "========================================="
echo "Cleanup complete!"
echo "========================================="
