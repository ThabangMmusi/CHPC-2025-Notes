# User Management with Ansible

Ansible's `ansible.builtin.user` module provides a powerful way to manage user accounts across your compute nodes. This section will guide you through creating and managing user accounts in your CHPC environment.

## Basic Playbook Structure

Here's a complete playbook example for user management:

```yaml
---
- name: Manage CHPC user accounts
  hosts: compute_nodes
  become: yes
  vars:
    default_shell: /bin/bash
    admin_group: wheel
    
  tasks:
    - name: Create standard CHPC user
      ansible.builtin.user:
        name: "{{ chpc_username }}"
        state: present
        shell: "{{ default_shell }}"
        groups: "{{ admin_group }}"
        append: yes
        password: "{{ chpc_password | password_hash('sha512') }}"
        comment: "CHPC User Account"
        home: "/home/{{ chpc_username }}"
        create_home: yes
        generate_ssh_key: yes
        ssh_key_type: ed25519
        ssh_key_file: ".ssh/id_ed25519_chpc"
        ssh_key_comment: "CHPC SSH Key"

    - name: Ensure .ssh directory permissions
      ansible.builtin.file:
        path: "/home/{{ chpc_username }}/.ssh"
        state: directory
        mode: "0700"
        owner: "{{ chpc_username }}"
        group: "{{ chpc_username }}"

    - name: Ensure authorized_keys exists
      ansible.builtin.file:
        path: "/home/{{ chpc_username }}/.ssh/authorized_keys"
        state: touch
        mode: "0600"
        owner: "{{ chpc_username }}"
        group: "{{ chpc_username }}"
```

## Key Features Explained

1. **User Creation**: The playbook creates a user with specified username, shell, and group membership.
2. **Password Security**: Passwords are hashed using SHA-512 (never store plaintext passwords).
3. **SSH Key Generation**: Automatically generates an Ed25519 SSH key for the user.
4. **Permission Management**: Ensures proper permissions for the `.ssh` directory and `authorized_keys` file.

## Variables File

Create a `vars.yml` file to store sensitive information:

```yaml
---
chpc_username: "chpc_user"
chpc_password: "secure_password_here"  # In production, use Ansible Vault
```

## Running the Playbook

Execute the playbook with:

```bash
ansible-playbook -i inventory users.yml --extra-vars "@vars.yml"
```

For production environments, encrypt sensitive variables with Ansible Vault:

```bash
ansible-vault create vars.yml
ansible-playbook -i inventory users.yml --extra-vars "@vars.yml" --ask-vault-pass
```

## Advanced User Management

### Managing Multiple Users

Use a loop to create multiple users:

```yaml
- name: Create multiple CHPC users
  ansible.builtin.user:
    name: "{{ item.name }}"
    state: present
    shell: "{{ default_shell }}"
    groups: "{{ admin_group }}"
    append: yes
    password: "{{ item.password | password_hash('sha512') }}"
  loop: "{{ users_list }}"
```

With a corresponding variable file:

```yaml
users_list:
  - name: user1
    password: pass1
  - name: user2
    password: pass2
```

### User Removal

To remove a user and their home directory:

```yaml
- name: Remove CHPC user
  ansible.builtin.user:
    name: "{{ chpc_username }}"
    state: absent
    remove: yes
```

### Password Updates

To update a user's password without changing other attributes:

```yaml
- name: Update user password
  ansible.builtin.user:
    name: "{{ chpc_username }}"
    password: "{{ new_password | password_hash('sha512') }}"
    update_password: on_create
```

## Security Best Practices

1. **Ansible Vault**: Always encrypt sensitive data like passwords using Ansible Vault.
2. **SSH Keys**: Prefer SSH key authentication over passwords when possible.
3. **Least Privilege**: Only grant necessary permissions (e.g., avoid adding users to `wheel` unless needed).
4. **Regular Audits**: Periodically review user accounts and permissions.
5. **Password Policies**: Enforce strong password policies through Ansible or system configuration.

## Integration with NFS

When using NFS-mounted home directories (as configured in the previous section), ensure:

1. The NFS server has proper permissions for the home directories
2. UIDs/GIDs are consistent across all nodes
3. SSH keys are properly synchronized

The playbook above automatically handles these considerations by:
- Creating the home directory with correct permissions
- Generating SSH keys in the NFS-mounted home directory
- Ensuring proper `.ssh` directory permissions