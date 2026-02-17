# Ansible Role: vcenter_networking

Configure Distributed vSwitch (DVS) and portgroups in nested vCenter environment.

## Requirements

- vCenter already deployed and configured
- ESXi hosts already added to vCenter
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
vcenter_networking_dvs_enabled: true
vcenter_networking_dvs_name: "dvSwitch-nested"
vcenter_networking_dvs_version: "8.0.0"
vcenter_networking_dvs_mtu: 9000
vcenter_networking_dvs_uplinks: 1
vcenter_networking_dvs_uplink_nics:
  - vmnic1
vcenter_networking_portgroup_name: "devqe-922"
vcenter_networking_portgroup_vlan_id: 0
vcenter_networking_portgroup_num_ports: 120
vcenter_networking_portgroup_binding: "static"
vcenter_networking_pause_after_dvs: 10
vcenter_networking_pause_after_host: 10
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: vcenter_networking
      loop: "{{ groups['esxi'] }}"
      loop_control:
        loop_var: loop_bms
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
