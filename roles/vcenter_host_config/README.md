# Ansible Role: vcenter_host_config

Add ESXi hosts to nested vCenter and configure power management, VM autostart, and vMotion.

## Requirements

- ESXi hosts already deployed
- vCenter already deployed and accessible
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
vcenter_host_power_policy: "high-performance"
vcenter_host_autostart_enabled: true
vcenter_host_autostart_delay: 100
vcenter_host_autostart_stop_action: "guestShutdown"
vcenter_host_autostart_wait_heartbeat: true
vcenter_host_enable_vmotion: true
vcenter_host_vmotion_vmk: "vmk0"
vcenter_host_vmotion_vswitch: "vSwitch0"
vcenter_host_vmotion_portgroup: "Management Network"
vcenter_host_exit_maintenance: true
```

Required variables (must be set in group_vars/all.yml):

```yaml
vcenter_datacenter_name: "nested-devqedatacenter-1"
vcenter_cluster_name: "nested-devqecluster-1"
nested_domain: "vsphere.local"
nested_password: "{{ lookup('env', 'VCESXIPASSWORD') }}"
loop_bms: "nested-esxi-1.local"  # Passed via loop_var
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: vcenter_host_config
      loop: "{{ groups['esxi'] }}"
      loop_control:
        loop_var: loop_bms
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
