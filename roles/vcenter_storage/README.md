# Ansible Role: vcenter_storage

Configure storage for nested ESXi hosts including VMFS datastores and NFS mounts.

## Requirements

- ESXi hosts already added to vCenter
- community.vmware collection installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
vcenter_storage_vmfs_version: 6
vcenter_storage_vmfs_device_ctd: "vmhba1:C0:T2:L0"
vcenter_storage_vmfs_datastore_prefix: "Datastore"
vcenter_storage_nfs_enabled: false
vcenter_storage_rescan_hba: true
vcenter_storage_vcls_configure: true
```

NFS mount configuration (see `vars/main.yml`):

```yaml
vcenter_storage_nfs_mounts:
  - name: 'isos'
    server: '10.185.92.22'
    path: '/data/export/share/'
    type: 'nfs41'
    nfs_ro: true
  - name: 'dsnested'
    server: '10.185.151.99'
    path: '/nfsmount/devqe'
    type: 'nfs41'
    nfs_ro: false
```

## Dependencies

- community.vmware collection

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: vcenter_storage
      vars:
        vcenter_storage_nfs_enabled: true
      loop: "{{ groups['esxi'] }}"
      loop_control:
        loop_var: loop_bms
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
