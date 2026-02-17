# Ansible Role: nested_vcenter

Deploy nested vCenter Server appliances from OVA with DHCP and SSO configuration.

## Requirements

- Access to parent vCenter with VM deployment permissions
- HTTP server hosting vCenter OVA files
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
nested_vcenter_version: "8"                  # vCenter version (8 or 9)
nested_vcenter_deployment_size: "tiny"       # tiny, small, medium, large
nested_vcenter_network_mode: "dhcp"          # dhcp or static
nested_vcenter_disk_provisioning: "thin"
nested_vcenter_ssh_enabled: true
nested_vcenter_shell_enabled: true
nested_vcenter_auto_config: true             # Auto-configure after deployment
nested_vcenter_testing_mode: false           # Delete existing VMs if true
nested_vcenter_wait_timeout: 1800
nested_vcenter_initial_pause: 300            # Pause for reboot
nested_vcenter_datastore: "vsanDatastore"
```

Required variables (must be set in group_vars/all.yml):

```yaml
parent_vcenter_datacenter: "devqedatacenter-1"
parent_vcenter_folder: "nested-limited"
ova_base_url: "http://10.185.92.22:8080"
nested_deployment_network: "devqe-922"
nested_domain: "vsphere.local"
nested_password: "{{ lookup('env', 'VCESXIPASSWORD') }}"
loop_bms_vc: "nested-vc-1.local"  # Passed via loop_var
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: nested_vcenter
      loop: "{{ groups['vc'] }}"
      loop_control:
        loop_var: loop_bms_vc
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
