# Ansible Role: resource_validation

Validates that the parent vCenter cluster has sufficient CPU, memory, and storage capacity before deploying nested vSphere VMs.

## Requirements

- Access to parent vCenter with vmware_cluster_info permissions
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Resources to reserve on parent cluster
resource_validation_cpu_reserved: 20000     # MHz to reserve
resource_validation_memory_reserved: 98304  # MB to reserve (96 GB)
resource_validation_storage_reserved: 1000000  # MB to reserve (976 GB)
```

Required variables (must be set in group_vars/all.yml or passed as extra vars):

```yaml
parent_vcenter_cluster: "devqecluster-1"  # Cluster name on parent vCenter
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: resource_validation
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
