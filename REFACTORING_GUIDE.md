# Nested vSphere Ansible Refactoring Guide

## Overview

This codebase has been refactored from a monolithic Ansible structure to a modular, role-based architecture following Ansible Galaxy standards and best practices.

## New Directory Structure

```
nested-vsphere-automation/
├── group_vars/
│   └── all.yml                          # Global variables (consolidated)
├── playbooks/
│   ├── deploy_nested_environment.yml    # Main deployment orchestrator
│   ├── deploy_esxi.yml                  # ESXi-only deployment
│   ├── deploy_vcenter.yml               # vCenter-only deployment
│   ├── configure_vcenter.yml            # vCenter configuration only
│   └── remove_environment.yml           # Cleanup playbook
├── roles/
│   ├── prerequisites/                   # System package installation
│   ├── resource_validation/             # Cluster capacity checking
│   ├── nested_esxi/                     # ESXi VM deployment
│   ├── nested_vcenter/                  # vCenter VM deployment
│   ├── vcenter_datacenter/              # Datacenter/cluster creation
│   ├── vcenter_host_config/             # ESXi host configuration
│   ├── vcenter_storage/                 # VMFS & NFS configuration
│   ├── vcenter_networking/              # DVS configuration
│   ├── vsphere_cleanup/                 # VM removal
│   └── lifecycle_management/            # Cron job management
├── scripts/
│   ├── deploy.sh                        # New deployment wrapper
│   └── cleanup.sh                       # Cleanup wrapper
├── hosts                                # Inventory file
├── main.yml                             # Legacy playbook (kept for compatibility)
└── runitall.sh                          # Updated main script (supports both modes)
```

## Version Support

This refactored codebase supports both **vSphere 8.x** and **vSphere 9.x** deployments.

### Version-Specific Components

Each version has dedicated variable files:
- **ESXi 8.x**: `roles/nested_esxi/vars/esxi-8.yml`
- **ESXi 9.x**: `roles/nested_esxi/vars/esxi-9.yml`
- **vCenter 8.x**: `roles/nested_vcenter/vars/vcenter-8.yml`
- **vCenter 9.x**: `roles/nested_vcenter/vars/vcenter-9.yml`

### Quick Start by Version

**vSphere 8:**
```bash
VERSION=8 ./runitall.sh
# or
./runitallsmall8.sh  # Small deployment
```

**vSphere 9:**
```bash
VERSION=9 ./runitall.sh
# or
./runitallsmall9.sh  # Small deployment
```

### Environment Variables

The `runitall.sh` script automatically selects the appropriate host examples based on version:
- `VERSION=8` uses `ESXI_HOSTS_V8` and `VC_HOSTS_V8`
- `VERSION=9` uses `ESXI_HOSTS_V9` and `VC_HOSTS_V9`

### Version Differences

| Feature | Version 8 | Version 9 |
|---------|-----------|-----------|
| ESXi OVA | Nested_ESXi8.0u2c_Appliance_Template_v1.ova | Nested_ESXi9.0_Appliance_Template_v1.0.ova |
| vCenter OVA | VMware-vCenter-Server-Appliance-8.0.2.00100-22617221_OVF10.ova | VMware-vCenter-Server-Appliance-9.1.0.0.24840651_OVF10.ova |
| DVS Version | 8.0.0 | 8.0.0 (compatible) |
| Guest ID | vmkernel8Guest | vmkernel8Guest |

## Roles Overview

### 1. prerequisites
- **Purpose**: Install system packages and Python dependencies
- **Packages**: python3-pip, gcc, git, pyvmomi, dnspython, etc.
- **When to use**: First-time setup or when packages are missing

### 2. resource_validation
- **Purpose**: Validate parent vCenter cluster has sufficient resources
- **Checks**: CPU, memory, storage capacity
- **Configurable**: Resource reservation thresholds

### 3. nested_esxi
- **Purpose**: Deploy nested ESXi VMs from OVA
- **Features**: Nested virtualization, configurable CPU/memory, automatic IP detection
- **Version support**: ESXi 8.x and 9.x

### 4. nested_vcenter
- **Purpose**: Deploy nested vCenter VMs from OVA
- **Features**: DHCP/static IP, SSO configuration, auto-configuration
- **Version support**: vCenter 8.x and 9.x

### 5. vcenter_datacenter
- **Purpose**: Create datacenter and cluster in nested vCenter
- **Features**: DRS, HA configuration

### 6. vcenter_host_config
- **Purpose**: Add ESXi hosts to vCenter and configure them
- **Features**: Power management, autostart, vMotion enablement

### 7. vcenter_storage
- **Purpose**: Configure VMFS datastores and NFS mounts
- **Features**: HBA scanning, disk detection, vCLS configuration

### 8. vcenter_networking
- **Purpose**: Create Distributed vSwitch and port groups
- **Features**: DVS creation, host addition, port group configuration

### 9. vsphere_cleanup
- **Purpose**: Remove nested VMs from parent vCenter
- **Features**: Force deletion, configurable safety checks

### 10. lifecycle_management
- **Purpose**: Manage cron jobs for automated cleanup
- **Features**: Scheduled deletion, configurable retention

## Usage

### Using New Role-Based Playbooks (Recommended)

#### 1. Full Deployment

**Version 8:**
```bash
# Using wrapper script
VERSION=8 \
ESXI_HOSTS='["nested8-host1.local","nested8-host2.local"]' \
VC_HOSTS='["nested8-vc.local"]' \
./scripts/deploy.sh

# Or directly with ansible-playbook
ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=8 \
  -e 'nested_esxi_hosts=["nested8-host1.local","nested8-host2.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]' \
  -e nested_esxi_memory_mb=131072 \
  -e nested_esxi_cpu_count=20
```

**Version 9:**
```bash
# Using wrapper script
VERSION=9 \
ESXI_HOSTS='["nested9-host1.local","nested9-host2.local"]' \
VC_HOSTS='["nested9-vc.local"]' \
./scripts/deploy.sh

# Or directly with ansible-playbook
ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=9 \
  -e 'nested_esxi_hosts=["nested9-host1.local","nested9-host2.local"]' \
  -e 'nested_vcenter_hosts=["nested9-vc.local"]' \
  -e nested_esxi_memory_mb=131072 \
  -e nested_esxi_cpu_count=20
```

#### 2. Deploy Only ESXi
```bash
# Version 8
ansible-playbook -i hosts playbooks/deploy_esxi.yml \
  -e nested_environment_version=8 \
  -e 'nested_esxi_hosts=["nested8-host1.local"]'

# Version 9
ansible-playbook -i hosts playbooks/deploy_esxi.yml \
  -e nested_environment_version=9 \
  -e 'nested_esxi_hosts=["nested9-host1.local"]'
```

#### 3. Deploy Only vCenter
```bash
# Version 8
ansible-playbook -i hosts playbooks/deploy_vcenter.yml \
  -e nested_environment_version=8 \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]'

# Version 9
ansible-playbook -i hosts playbooks/deploy_vcenter.yml \
  -e nested_environment_version=9 \
  -e 'nested_vcenter_hosts=["nested9-vc.local"]'
```

#### 4. Configure Existing vCenter
```bash
# Works with any version - just specify the hosts
ansible-playbook -i hosts playbooks/configure_vcenter.yml \
  -e 'nested_esxi_hosts=["nested8-host1.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]'
```

#### 5. Cleanup Environment
```bash
# Using wrapper script (with confirmation) - works for any version
ESXI_HOSTS='["nested8-host1.local"]' \
VC_HOSTS='["nested8-vc.local"]' \
./scripts/cleanup.sh

# Version 9 cleanup
ESXI_HOSTS='["nested9-host1.local"]' \
VC_HOSTS='["nested9-vc.local"]' \
./scripts/cleanup.sh

# Or directly with ansible-playbook
ansible-playbook -i hosts playbooks/remove_environment.yml \
  -e 'nested_esxi_hosts=["nested8-host1.local"]' \
  -e 'nested_vcenter_hosts=["nested8-vc.local"]' \
  -e removevsphere=true
```

### Using runitall.sh Main Script

The `runitall.sh` script supports both versions and both legacy/new playbooks:

**Version 8 (new playbooks - default):**
```bash
VERSION=8 ./runitall.sh
```

**Version 9 (new playbooks):**
```bash
VERSION=9 ./runitall.sh
```

**Version 8 (legacy playbook):**
```bash
USE_LEGACY=true VERSION=8 ./runitall.sh
```

**Version 9 (legacy playbook):**
```bash
USE_LEGACY=true VERSION=9 ./runitall.sh
```

**Custom resource allocation:**
```bash
VERSION=9 ESXI_MEMORY=131072 ESXI_CPU=20 ./runitall.sh
```

### Using Legacy Playbook (Backward Compatibility)

The original `main.yml` is still available:

```bash
# Version 8 with legacy playbook
USE_LEGACY=true ./runitall.sh

# Or directly
ansible-playbook -i hosts main.yml \
  --extra-var version="8" \
  --extra-var='{"target_hosts": [nested8-host1.local]}' \
  --extra-var='{"target_vcs": [nested8-vc.local]}'

# Version 9 with legacy playbook
ansible-playbook -i hosts main.yml \
  --extra-var version="9" \
  --extra-var='{"target_hosts": [nested9-host1.local]}' \
  --extra-var='{"target_vcs": [nested9-vc.local]}'
```

## Variable Migration Guide

### Old Variables → New Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `version` | `nested_environment_version` | Legacy name still supported |
| `target_hosts` | `nested_esxi_hosts` | Now uses JSON array format |
| `target_vcs` | `nested_vcenter_hosts` | Now uses JSON array format |
| `esximemory` | `nested_esxi_memory_mb` | Same unit (MB) |
| `esxicpu` | `nested_esxi_cpu_count` | Same meaning |
| `removevsphere` | `vsphere_cleanup_enabled` | New role variable |
| `createcron` | `lifecycle_management_create_cron` | New role variable |

### Global Variables (group_vars/all.yml)

All global variables are now organized in `group_vars/all.yml` with clear sections:
- Parent vCenter Configuration
- Nested Environment Configuration
- OVA Distribution Configuration
- Module Defaults

Legacy variable names are maintained for backward compatibility.

## Tag-Based Execution

### Available Tags

- `always` - Inventory preparation (always runs)
- `prerequisites` - Install packages (manual trigger with `--tags prerequisites`)
- `validate` - Resource validation
- `deploy` - Full deployment (ESXi + vCenter)
- `esxi` - ESXi deployment only
- `vcenter` - vCenter deployment only
- `configure` - Configuration tasks only
- `vcenter_config` - vCenter configuration
- `info` - Display environment information
- `cleanup` - Cleanup operations
- `remove` - VM removal

### Examples

```bash
# Deploy only ESXi
ansible-playbook playbooks/deploy_nested_environment.yml --tags esxi

# Deploy only vCenter
ansible-playbook playbooks/deploy_nested_environment.yml --tags vcenter

# Configure only (skip deployment)
ansible-playbook playbooks/deploy_nested_environment.yml --tags configure

# Install prerequisites
ansible-playbook playbooks/deploy_nested_environment.yml --tags prerequisites
```

## Role Customization

### Overriding Role Defaults

Each role has configurable defaults in `roles/<role_name>/defaults/main.yml`.

Example - Override ESXi memory:
```bash
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e nested_esxi_memory_mb=65536
```

Example - Disable NFS mounts:
```bash
ansible-playbook playbooks/deploy_nested_environment.yml \
  -e vcenter_storage_nfs_enabled=false
```

## Testing

### Dry Run (Check Mode)
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --check
```

### Syntax Validation
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --syntax-check
```

### List Tasks
```bash
ansible-playbook playbooks/deploy_nested_environment.yml --list-tasks
```

## Troubleshooting

### Check Role Documentation
Each role has a README with detailed information:
```bash
cat roles/<role_name>/README.md
```

### View Role Defaults
```bash
cat roles/<role_name>/defaults/main.yml
```

### Enable Verbose Output
```bash
ansible-playbook playbooks/deploy_nested_environment.yml -vvv
```

### Check Logs
Logs are stored in `/tmp/` with timestamps:
- Deployment: `/tmp/deploy_DDMMYYYY_HHMMSS.log`
- Cleanup: `/tmp/cleanup_DDMMYYYY_HHMMSS.log`

## Benefits of New Structure

1. **Modularity** - Each role has a single responsibility
2. **Reusability** - Roles can be used independently or in other projects
3. **Maintainability** - Clear structure, easy to understand and modify
4. **Testability** - Individual roles can be tested in isolation
5. **Documentation** - Each role self-documents via README
6. **Flexibility** - Mix and match roles for different scenarios
7. **Best Practices** - Follows Ansible Galaxy standards
8. **Backward Compatible** - Legacy playbook still available
9. **Version Control** - Better separation of concerns for git
10. **Scalability** - Easy to add new features as roles

## Migration Path

1. **Test new playbooks** in a non-production environment
2. **Run in parallel** with legacy playbooks for validation
3. **Gradually migrate** to new structure
4. **Archive legacy files** once confident in new structure

## Contributing

When adding new features:
1. Create a new role or extend an existing one
2. Follow Ansible Galaxy role structure
3. Add comprehensive README to role
4. Update this guide with new features
5. Maintain backward compatibility where possible

## Support

- Role Documentation: `roles/<role_name>/README.md`
- GitHub: https://github.com/jimccann-rh/nested-ova-ansible
- Plan File: `/home/jimccann/.claude/plans/validated-juggling-robin.md`
