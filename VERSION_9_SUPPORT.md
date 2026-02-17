# Version 9 Support Documentation

## Overview

The nested vSphere automation has been updated to support both **vSphere 8.x** and **vSphere 9.x** deployments with automatic version selection and dedicated examples.

## What Was Updated

### 1. runitall.sh (Main Script)

**Added:**
- `ESXI_HOSTS_V9` - Version 9 ESXi host examples
- `VC_HOSTS_V9` - Version 9 vCenter host examples
- Automatic host selection based on `VERSION` environment variable
- Display of deployed configuration at completion
- Usage instructions for both versions

**Example Variables:**
```bash
# Version 8 examples (default)
ESXI_HOSTS_V8='["nested8-myjobname1-host.vpshere.local","nested8-myjobname2-host.vpshere.local"]'
VC_HOSTS_V8='["nested8-myjobname-VC.vpshere.local"]'

# Version 9 examples (new)
ESXI_HOSTS_V9='["nested9-myjobname1-host.vpshere.local","nested9-myjobname2-host.vpshere.local"]'
VC_HOSTS_V9='["nested9-myjobname-VC.vpshere.local"]'
```

**Logic:**
- If `VERSION=9`, uses `ESXI_HOSTS_V9` and `VC_HOSTS_V9`
- If `VERSION=8` (or unset), uses `ESXI_HOSTS_V8` and `VC_HOSTS_V8`
- Works with both legacy (`USE_LEGACY=true`) and new playbooks

### 2. scripts/deploy.sh

**Updated:**
- Header documentation with version 9 examples
- Help text showing both version 8 and 9 usage
- Examples for both environment variables and command-line arguments

**Example Usage:**
```bash
# Version 9 with environment variables
VERSION=9 \
ESXI_HOSTS='["nested9-host1.local","nested9-host2.local"]' \
VC_HOSTS='["nested9-vc.local"]' \
./scripts/deploy.sh

# Version 9 with command-line arguments
./scripts/deploy.sh --version 9 \
  --esxi-hosts nested9-host1.local,nested9-host2.local \
  --vc-hosts nested9-vc.local
```

### 3. runitallsmall9.sh (New Script)

**Created:** New example script for small vSphere 9 deployments

**Features:**
- Pre-configured for single ESXi host + vCenter
- Reduced resources (64GB RAM, 16 CPUs)
- Version 9 specific host naming
- Automatic logging with timestamps
- Cleanup instructions at completion

**Usage:**
```bash
./runitallsmall9.sh
```

### 4. REFACTORING_GUIDE.md

**Added:**
- **Version Support** section with overview of 8.x and 9.x
- Version-specific quick start examples
- Version comparison table
- Updated all examples to show both version 8 and 9
- runitall.sh usage examples for both versions
- Environment variable explanations

**Key Sections Updated:**
- Version Support (new section)
- Full Deployment examples
- Deploy Only ESXi examples
- Deploy Only vCenter examples
- Cleanup examples
- runitall.sh usage (new section)
- Legacy playbook usage

## Usage Examples

### Quick Start

**Version 8 (default):**
```bash
./runitall.sh
# or explicitly
VERSION=8 ./runitall.sh
```

**Version 9:**
```bash
VERSION=9 ./runitall.sh
```

### Small Deployments

**Version 8:**
```bash
./runitallsmall8.sh
```

**Version 9:**
```bash
./runitallsmall9.sh
```

### Custom Deployments

**Version 8 with custom resources:**
```bash
VERSION=8 ESXI_MEMORY=131072 ESXI_CPU=20 ./runitall.sh
```

**Version 9 with custom resources:**
```bash
VERSION=9 ESXI_MEMORY=131072 ESXI_CPU=20 ./runitall.sh
```

### Using Wrapper Scripts

**Deploy Version 9:**
```bash
./scripts/deploy.sh --version 9 \
  --esxi-hosts nested9-host1.local,nested9-host2.local \
  --vc-hosts nested9-vc.local \
  --esxi-memory 65536 \
  --esxi-cpu 16
```

**Cleanup Version 9:**
```bash
./scripts/cleanup.sh \
  --esxi-hosts nested9-host1.local,nested9-host2.local \
  --vc-hosts nested9-vc.local
```

### Direct Ansible Playbook Usage

**Deploy Version 9:**
```bash
ansible-playbook -i hosts playbooks/deploy_nested_environment.yml \
  -e nested_environment_version=9 \
  -e 'nested_esxi_hosts=["nested9-host1.local","nested9-host2.local"]' \
  -e 'nested_vcenter_hosts=["nested9-vc.local"]' \
  -e nested_esxi_memory_mb=65536 \
  -e nested_esxi_cpu_count=16
```

**Deploy Only ESXi Version 9:**
```bash
ansible-playbook -i hosts playbooks/deploy_esxi.yml \
  -e nested_environment_version=9 \
  -e 'nested_esxi_hosts=["nested9-host1.local"]'
```

**Deploy Only vCenter Version 9:**
```bash
ansible-playbook -i hosts playbooks/deploy_vcenter.yml \
  -e nested_environment_version=9 \
  -e 'nested_vcenter_hosts=["nested9-vc.local"]'
```

## Version-Specific Files

### ESXi Version Files

**roles/nested_esxi/vars/esxi-8.yml:**
```yaml
nested_esxi_ova_file: 'Nested_ESXi8.0u2c_Appliance_Template_v1.ova'
nested_esxi_guest_id: "vmkernel8Guest"
```

**roles/nested_esxi/vars/esxi-9.yml:**
```yaml
nested_esxi_ova_file: 'Nested_ESXi9.0_Appliance_Template_v1.0.ova'
nested_esxi_guest_id: "vmkernel8Guest"
```

### vCenter Version Files

**roles/nested_vcenter/vars/vcenter-8.yml:**
```yaml
nested_vcenter_ova_file: 'VMware-vCenter-Server-Appliance-8.0.2.00100-22617221_OVF10.ova'
nested_vcenter_guest_id: "vmkernel8Guest"
```

**roles/nested_vcenter/vars/vcenter-9.yml:**
```yaml
nested_vcenter_ova_file: 'VMware-vCenter-Server-Appliance-9.1.0.0.24840651_OVF10.ova'
nested_vcenter_guest_id: "vmkernel8Guest"
```

## Environment Variables

### Version Selection

- `VERSION` - ESXi/vCenter version (8 or 9, default: 8)

### Version 8 Host Lists

- `ESXI_HOSTS_V8` - ESXi hosts for version 8 deployments
- `VC_HOSTS_V8` - vCenter hosts for version 8 deployments

### Version 9 Host Lists

- `ESXI_HOSTS_V9` - ESXi hosts for version 9 deployments
- `VC_HOSTS_V9` - vCenter hosts for version 9 deployments

### Resource Allocation

- `ESXI_MEMORY` - Memory per ESXi host in MB (default: 65536)
- `ESXI_CPU` - CPU count per ESXi host (default: 16)

### Playbook Selection

- `USE_LEGACY` - Use old main.yml (true) or new playbooks (false, default)

## Backward Compatibility

All existing version 8 deployments continue to work:

```bash
# These all work as before
./runitall.sh                    # Uses version 8 by default
./runitallsmall8.sh              # Explicit version 8
USE_LEGACY=true ./runitall.sh    # Legacy playbook with version 8
```

## Migration from Version 8 to Version 9

To switch from version 8 to version 9:

1. **Update environment variables:**
   ```bash
   VERSION=9  # Change from 8 to 9
   ```

2. **Update host names** (if following naming convention):
   ```bash
   # From
   ESXI_HOSTS='["nested8-host1.local"]'
   # To
   ESXI_HOSTS='["nested9-host1.local"]'
   ```

3. **Run deployment:**
   ```bash
   VERSION=9 ./runitall.sh
   ```

## Testing

### Test Version Detection

```bash
# Test version 8
VERSION=8 ./runitall.sh
# Should show: "Version: 8"

# Test version 9
VERSION=9 ./runitall.sh
# Should show: "Version: 9"
```

### Test Host Selection

```bash
# Version 8 should use V8 hosts
VERSION=8 ./runitall.sh
# Check output for nested8-* hosts

# Version 9 should use V9 hosts
VERSION=9 ./runitall.sh
# Check output for nested9-* hosts
```

## Summary of Changes

| File | Change | Description |
|------|--------|-------------|
| runitall.sh | Updated | Added V9 host examples, version selection logic |
| scripts/deploy.sh | Updated | Added V9 examples in documentation |
| runitallsmall9.sh | New | Small deployment script for version 9 |
| REFACTORING_GUIDE.md | Updated | Added version support section and V9 examples |
| VERSION_9_SUPPORT.md | New | This documentation file |

## Files Already Supporting Both Versions

These files were already version-aware and didn't need changes:

- `roles/nested_esxi/vars/esxi-8.yml` (existing)
- `roles/nested_esxi/vars/esxi-9.yml` (existing)
- `roles/nested_vcenter/vars/vcenter-8.yml` (existing)
- `roles/nested_vcenter/vars/vcenter-9.yml` (existing)
- `group_vars/all.yml` (supports `nested_environment_version` variable)
- All playbooks (use `nested_environment_version` variable)
- All roles (load version-specific vars dynamically)

## Next Steps

To use version 9 in production:

1. Ensure version 9 OVA files are available on HTTP server
2. Update host naming conventions if needed
3. Test deployment with `VERSION=9 ./runitall.sh`
4. Validate deployed environment
5. Update any custom scripts to use version 9 variables

## Support

For questions or issues:
- Review REFACTORING_GUIDE.md for general guidance
- Check role-specific README files in `roles/*/README.md`
- Review version-specific vars in `roles/*/vars/`
