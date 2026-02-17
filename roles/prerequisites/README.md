# Ansible Role: prerequisites

Install system packages and Python dependencies required for nested vSphere automation.

## Requirements

- Root/sudo access on the target host
- Internet connectivity for package downloads

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
prerequisites_system_packages:
  - python3-pip
  - git
  - gcc

prerequisites_python_packages:
  - dnspython
  - pyvmomi
  - pyvim
  - requests
  - omsdk
  - jmespath
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: remotedevqe
  roles:
    - role: prerequisites
```

## License

Apache-2.0

## Author Information

This role was created for nested vSphere environment automation.
