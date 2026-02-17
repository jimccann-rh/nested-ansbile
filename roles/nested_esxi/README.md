# Ansible Role: nested_esxi

Deploy nested ESXi VMs from OVA with nested virtualization enabled.

## Requirements

- Access to parent vCenter with VM deployment permissions
- HTTP server hosting ESXi OVA files
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
nested_esxi_version: "8"                    # ESXi version (8 or 9)
nested_esxi_memory_mb: 131072               # Memory allocation (128 GB)
nested_esxi_cpu_count: 20                   # Number of vCPUs
nested_esxi_disk_size_tb: 1                 # Additional disk size
nested_esxi_disk_provisioning: "thin"       # Disk provisioning type
nested_esxi_enable_nested_virt: true        # Enable nested virtualization
nested_esxi_testing_mode: false             # Delete existing VMs if true
nested_esxi_wait_timeout: 900               # Timeout for ESXi to be ready
nested_esxi_datastore: "vsanDatastore"      # Datastore for deployment
```

Version-specific variables are loaded from `vars/esxi-{{ nested_esxi_version }}.yml`:
- `nested_esxi_ova_file`: OVA filename
- `nested_esxi_guest_id`: Guest OS type

Required variables (must be set in group_vars/all.yml):

```yaml
parent_vcenter_datacenter: "devqedatacenter-1"
parent_vcenter_folder: "nested-limited"
ova_base_url: "http://10.185.92.22:8080"
nested_deployment_network: "devqe-922"
nested_password: "{{ lookup('env', 'VCESXIPASSWORD') }}"
loop_bms: "nested-esxi-1.local"  # Passed via loop_var
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: nested_esxi
      loop: "{{ groups['esxi'] }}"
      loop_control:
        loop_var: loop_bms
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
