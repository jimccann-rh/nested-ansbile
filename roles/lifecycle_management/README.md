# Ansible Role: lifecycle_management

Manage cron jobs for automated cleanup of nested vSphere environments.

## Requirements

- Cron service installed and running
- Ansible playbook and inventory accessible on the system

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
lifecycle_management_create_cron: false
lifecycle_management_remove_cron: false
lifecycle_management_retention_days: 1
lifecycle_management_source_file: "/root/nested.source"
lifecycle_management_playbook_dir: "/root/ansible-remotenesteddevqe/"
lifecycle_management_playbook_name: "main.yml"
lifecycle_management_inventory: "hosts"
```

Required variables (must be set in group_vars/all.yml or passed as extra vars):

```yaml
nested_esxi_hosts: ["nested8-host1.local"]
nested_vcenter_hosts: ["nested8-vc.local"]
nested_environment_version: "8"
```

## Dependencies

None

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: lifecycle_management
      vars:
        lifecycle_management_create_cron: true
        lifecycle_management_retention_days: 7
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
