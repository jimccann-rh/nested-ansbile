# Nested vSphere Automation with Ansible

Automated deployment and management of nested vSphere environments (ESXi + vCenter) using Ansible with a modular, role-based architecture.

## 🎯 Features

- **Modular Role-Based Architecture**: 10 specialized Ansible roles following Galaxy standards
- **Version Support**: vSphere 8.x and 9.x with automatic version selection
- **Multiple Deployment Options**: Full stack, ESXi-only, vCenter-only, or configuration-only
- **Automated Configuration**: DRS, HA, VMFS datastores, NFS mounts, Distributed vSwitch
- **Lifecycle Management**: Automated cleanup with cron job scheduling
- **Backward Compatible**: Legacy playbook support maintained
- **Comprehensive Documentation**: Role READMEs, refactoring guide, version 9 guide

## 📋 Prerequisites

### Infrastructure Requirements

1. **Parent vCenter**: Existing vCenter where nested VMs will be deployed
2. **HTTP Server**: To host OVA files (recommend [miniserve](https://github.com/svenstaro/miniserve) or S3 bucket)
3. **DHCP Server**: On the network for nested vSphere environment
4. **OVA Files**:
   - ESXi OVA from [William Lam](https://williamlam.com/)
   - vCenter OVA from vCenter install ISO (download from VMware/Broadcom)

### Physical Host Configuration

Your physical host's vSwitch or DVS must have:
- ✅ **Promiscuous mode**: Accept
- ✅ **MAC address changes**: Accept
- ✅ **Forged transmits**: Accept

### vSAN Configuration (if applicable)

If running on vSAN, execute on the ESXi host:
```bash
esxcli system settings advanced set -o /VSAN/FakeSCSIReservations -i 1
```

### Ansible Requirements

- Ansible 2.9 or higher
- Python 3.6 or higher
- Ansible Collections:
  - `vmware.vmware` (required for cluster/datacenter modules)
  - `community.vmware` (required for guest/host operations)
  - `community.general`

Install collections:
```bash
ansible-galaxy collection install vmware.vmware community.vmware community.general
```

**Note:** As of `community.vmware` v6.0.0, cluster and datacenter modules have been moved to the `vmware.vmware` collection.

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone git@github.com:jimccann-rh/nested-ansbile.git
cd nested-ansbile
```

### 2. Configure Environment
```bash
# Copy the example environment file
cp nested.source.example nested.source

# Edit with your credentials
vi nested.source

# Set required variables:
# - VCESXIPASSWORD: Password for nested ESXi/vCenter
# - VMWARE_HOST: Parent vCenter hostname
# - VMWARE_USER: Parent vCenter username
# - VMWARE_PASSWORD: Parent vCenter password

# Source the environment
source nested.source
```

### 3. Deploy Nested Environment

**Option A: Using the main script (Version 8 - Default)**
```bash
./runitall.sh
```

**Option B: Using the main script (Version 9)**
```bash
VERSION=9 ./runitall.sh
```

**Option C: Using wrapper scripts**
```bash
# Version 8
./scripts/deploy.sh --version 8 \
  --esxi-hosts nested8-host1.local,nested8-host2.local \
  --vc-hosts nested8-vc.local

# Version 9
./scripts/deploy.sh --version 9 \
  --esxi-hosts nested9-host1.local,nested9-host2.local \
  --vc-hosts nested9-vc.local
```

**Option D: Small deployment (reduced resources)**
```bash
# Version 8 (64GB RAM, 16 CPUs per ESXi)
./runitallsmall8.sh

# Version 9
./runitallsmall9.sh
```

## 📚 Architecture

### Directory Structure
```
nested-ansbile/
├── roles/                      # 10 Ansible roles
│   ├── prerequisites/          # System package installation
│   ├── resource_validation/    # Cluster capacity checking
│   ├── nested_esxi/            # ESXi VM deployment
│   ├── nested_vcenter/         # vCenter VM deployment
│   ├── vcenter_datacenter/     # Datacenter/cluster creation
│   ├── vcenter_host_config/    # ESXi host configuration
│   ├── vcenter_storage/        # VMFS & NFS configuration
│   ├── vcenter_networking/     # DVS configuration
│   ├── vsphere_cleanup/        # VM removal
│   └── lifecycle_management/   # Cron job automation
├── playbooks/                  # 5 specialized playbooks
│   ├── deploy_nested_environment.yml
│   ├── deploy_esxi.yml
│   ├── deploy_vcenter.yml
│   ├── configure_vcenter.yml
│   └── remove_environment.yml
├── scripts/                    # Wrapper scripts
│   ├── deploy.sh
│   └── cleanup.sh
├── group_vars/
│   └── all.yml                 # Global variables
└── Documentation
    ├── REFACTORING_GUIDE.md    # Comprehensive guide
    └── VERSION_9_SUPPORT.md    # Version 9 documentation
```

### Roles Overview

| Role | Purpose | Key Features |
|------|---------|--------------|
| **prerequisites** | Install dependencies | System packages, Python libraries |
| **resource_validation** | Validate capacity | CPU, memory, storage checks |
| **nested_esxi** | Deploy ESXi VMs | OVA deployment, nested virt, version-specific |
| **nested_vcenter** | Deploy vCenter VMs | DHCP, SSO, auto-configuration |
| **vcenter_datacenter** | Infrastructure setup | Datacenter, cluster, DRS, HA |
| **vcenter_host_config** | ESXi configuration | Power mgmt, autostart, vMotion |
| **vcenter_storage** | Storage setup | VMFS datastores, NFS mounts |
| **vcenter_networking** | Network setup | DVS, portgroups |
| **vsphere_cleanup** | Environment removal | VM deletion, cleanup |
| **lifecycle_management** | Automation | Cron-based cleanup scheduling |

## 🎮 Usage Examples

### Full Deployment

**Using Direct Ansible Playbook:**
```bash
# Version 8
ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=8 \
  -e 'nested_esxi_hosts=["nested8-host1.local","nested8-host2.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]' \
  -e nested_esxi_memory_mb=131072 \
  -e nested_esxi_cpu_count=20

# Version 9
ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=9 \
  -e 'nested_esxi_hosts=["nested9-host1.local","nested9-host2.local"]' \
  -e 'nested_vcenter_hosts=["nested9-vc.local"]'
```

**Using Environment Variables:**
```bash
VERSION=8 \
ESXI_HOSTS='["nested8-host1.local"]' \
VC_HOSTS='["nested8-vc.local"]' \
ESXI_MEMORY=65536 \
ESXI_CPU=16 \
./scripts/deploy.sh
```

### ESXi-Only Deployment
```bash
# Deploy only ESXi hosts (no vCenter)
ansible-playbook -i hosts playbooks/deploy_esxi.yml \
  -e nested_environment_version=8 \
  -e 'nested_esxi_hosts=["nested8-host1.local"]'
```

### vCenter-Only Deployment
```bash
# Deploy only vCenter (no ESXi)
ansible-playbook -i hosts playbooks/deploy_vcenter.yml \
  -e nested_environment_version=8 \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]'
```

### Configuration-Only (Existing VMs)
```bash
# Configure existing ESXi/vCenter without redeploying
ansible-playbook -i hosts playbooks/configure_vcenter.yml \
  -e 'nested_esxi_hosts=["nested8-host1.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]'
```

### Tag-Based Selective Execution
```bash
# Deploy only ESXi (skip vCenter)
ansible-playbook playbooks/deploy_nested_environment.yml --tags esxi

# Deploy only vCenter (skip ESXi)
ansible-playbook playbooks/deploy_nested_environment.yml --tags vcenter

# Run only configuration (skip deployment)
ansible-playbook playbooks/deploy_nested_environment.yml --tags configure

# Validate resources only
ansible-playbook playbooks/deploy_nested_environment.yml --tags validate
```

### Environment Cleanup
```bash
# Using wrapper script (with confirmation prompt)
ESXI_HOSTS='["nested8-host1.local"]' \
VC_HOSTS='["nested8-vc.local"]' \
./scripts/cleanup.sh

# Using playbook directly
ansible-playbook -i hosts playbooks/remove_environment.yml \
  -e 'nested_esxi_hosts=["nested8-host1.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]' \
  -e removevsphere=true
```

### Scheduled Cleanup (Cron)
```bash
# Schedule automatic cleanup after 7 days
ansible-playbook -i hosts playbooks/remove_environment.yml \
  -e 'nested_esxi_hosts=["nested8-host1.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]' \
  -e createcron=true \
  -e lifecycle_management_retention_days=7
```

## ⚙️ Configuration

### Key Variables (group_vars/all.yml)

**Parent vCenter:**
```yaml
parent_vcenter_hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
parent_vcenter_username: "{{ lookup('env', 'VMWARE_USER') }}"
parent_vcenter_password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
parent_vcenter_datacenter: "devqedatacenter-1"
parent_vcenter_cluster: "devqecluster-1"
parent_vcenter_folder: "nested-limited"
```

**Nested Environment:**
```yaml
nested_environment_version: "8"  # or "9"
nested_password: "{{ lookup('env', 'VCESXIPASSWORD') }}"
nested_domain: "vsphere.local"
nested_deployment_network: "devqe-922"
ova_http_server: "10.185.92.22:8080"
```

**ESXi Configuration (override as needed):**
```yaml
nested_esxi_memory_mb: 131072      # 128 GB
nested_esxi_cpu_count: 20
nested_esxi_disk_size_tb: 1
```

**vCenter Configuration:**
```yaml
nested_vcenter_deployment_size: "tiny"  # tiny, small, medium, large
nested_vcenter_network_mode: "dhcp"     # or "static"
```

### Role-Specific Configuration

Each role has configurable defaults in `roles/<role_name>/defaults/main.yml`.

Examples:
```bash
# Override ESXi memory
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e nested_esxi_memory_mb=65536

# Disable NFS mounts
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e vcenter_storage_nfs_enabled=false

# Change DVS version
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e vcenter_networking_dvs_version="7.0.0"
```

## 🔄 Version Support

### Version 8 (Default)
```bash
# All default examples use version 8
./runitall.sh
./runitallsmall8.sh
```

### Version 9
```bash
# Set VERSION=9 for vSphere 9.x deployments
VERSION=9 ./runitall.sh
./runitallsmall9.sh

# Or explicitly in playbooks
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=9
```

### Version-Specific Files

| Component | Version 8 | Version 9 |
|-----------|-----------|-----------|
| ESXi OVA | Nested_ESXi8.0u2c_Appliance_Template_v1.ova | Nested_ESXi9.0_Appliance_Template_v1.0.ova |
| vCenter OVA | VMware-vCenter-Server-Appliance-8.0.2.00100-22617221_OVF10.ova | VMware-vCenter-Server-Appliance-9.1.0.0.24840651_OVF10.ova |
| DVS Version | 8.0.0 | 8.0.0 |

See [VERSION_9_SUPPORT.md](VERSION_9_SUPPORT.md) for complete version 9 documentation.

## 🔧 Troubleshooting

### Enable Verbose Output
```bash
ansible-playbook playbooks/deploy_nested_environment.yml -vvv
```

### Check Logs
Logs are automatically created in `/tmp/` with timestamps:
```bash
# Deployment logs
tail -f /tmp/deploy_*.log

# Cleanup logs
tail -f /tmp/cleanup_*.log
```

### Validate Syntax
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --syntax-check
```

### Dry Run (Check Mode)
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --check
```

### Role-Specific Documentation
Each role has comprehensive documentation:
```bash
cat roles/nested_esxi/README.md
cat roles/vcenter_storage/README.md
```

## 📖 Documentation

- **[REFACTORING_GUIDE.md](REFACTORING_GUIDE.md)** - Comprehensive guide to the new architecture
- **[VERSION_9_SUPPORT.md](VERSION_9_SUPPORT.md)** - vSphere 9.x deployment guide
- **Role READMEs** - Individual role documentation in `roles/*/README.md`
- **Example Scripts** - `runitall.sh`, `runitallsmall8.sh`, `runitallsmall9.sh`

## 🔙 Backward Compatibility

### Legacy Playbook Support

The original monolithic `main.yml` is preserved:

```bash
# Use legacy playbook
USE_LEGACY=true ./runitall.sh

# Or directly
ansible-playbook -i hosts main.yml \
  --extra-var version="8" \
  --extra-var='{"target_hosts": [nested8-host1.local]}' \
  --extra-var='{"target_vcs": [nested8-vc.local]}'
```

### Variable Migration

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `version` | `nested_environment_version` | Legacy name still works |
| `target_hosts` | `nested_esxi_hosts` | Now uses JSON array |
| `target_vcs` | `nested_vcenter_hosts` | Now uses JSON array |
| `esximemory` | `nested_esxi_memory_mb` | Same unit (MB) |
| `esxicpu` | `nested_esxi_cpu_count` | Same meaning |

## 🛠️ Advanced Usage

### Install Prerequisites Only
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --tags prerequisites
```

### Custom Resource Allocation
```bash
# High-performance setup
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e nested_esxi_memory_mb=262144 \
  -e nested_esxi_cpu_count=32 \
  -e nested_esxi_disk_size_tb=2
```

### Multiple Datacenters
Edit `group_vars/all.yml` to configure multiple datacenters:
```yaml
vc_fact_datacenter1: "nested-dc-1"
vc_fact_datacenter2: "nested-dc-2"
vc_fact_cluster1: "nested-cluster-1"
vc_fact_cluster2: "nested-cluster-2"
```

### Custom NFS Mounts
Edit `roles/vcenter_storage/vars/main.yml`:
```yaml
vcenter_storage_nfs_mounts:
  - name: 'custom-nfs'
    server: '10.0.0.100'
    path: '/exports/data'
    type: 'nfs41'
    nfs_ro: false
```

## 📊 What Gets Deployed

### ESXi Hosts
- Nested virtualization enabled
- Configurable CPU/memory (default: 20 CPUs, 128GB RAM)
- 1TB additional disk for VMFS datastore
- VMware Tools installed and running
- DHCP network configuration

### vCenter
- Tiny deployment size (configurable)
- DHCP or static IP
- SSH and shell enabled
- Auto-configuration enabled
- SSO domain: vsphere.local (configurable)

### Infrastructure
- Datacenter and cluster created
- DRS enabled (fully automated)
- HA enabled with custom settings
- VMFS datastores created from second disk
- Optional NFS datastores mounted
- Distributed vSwitch created
- Port groups configured
- vMotion enabled on management network

## 🤝 Contributing

This code is a work in progress with ongoing feature additions. If you see commented code or debug statements, they're part of active development for future features.

## 📝 License

Apache-2.0

## 👤 Author

**Jim McCann** (jimccann@redhat.com)

Co-authored by Claude Sonnet 4.5

## 🔗 Links

- **Repository**: https://github.com/jimccann-rh/nested-ansbile
- **William Lam's Nested ESXi**: https://williamlam.com/
- **Miniserve (HTTP Server)**: https://github.com/svenstaro/miniserve

## ⚠️ Note

This is designed for **Ansible Automation Platform (AAP)** but works with standalone Ansible as well.

Ensure your OVA files are hosted on an HTTP server accessible from the parent ESXi hosts.
