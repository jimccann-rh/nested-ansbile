# Ansible Role: vsphere_cleanup

Remove nested vSphere VMs (ESXi and vCenter) from parent vCenter.

## Requirements

- Access to parent vCenter with VM deletion permissions
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
vsphere_cleanup_force_remove: true
vsphere_cleanup_enabled: false  # Must be explicitly enabled
```

Required variables (must be set in group_vars/all.yml):

```yaml
parent_vcenter_hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
parent_vcenter_username: "{{ lookup('env', 'VMWARE_USER') }}"
parent_vcenter_password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
parent_vcenter_datacenter: "devqedatacenter-1"
parent_vcenter_folder: "nested-limited"
loop_bms: "nested-vm-1.local"  # Passed via loop_var
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: vsphere_cleanup
      vars:
        vsphere_cleanup_enabled: true
      loop: "{{ groups['esxi'] + groups['vc'] }}"
      loop_control:
        loop_var: loop_bms
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
