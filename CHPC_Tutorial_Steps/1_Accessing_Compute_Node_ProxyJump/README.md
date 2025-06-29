# Accessing Your Compute Node Using `ProxyJump` Directive

The SSH ProxyJump directive allows you to connect to a remote server (compute node) through an intermediate server (head node). This means you can SSH into your compute node even though it's not directly accessible from your workstation - the connection is tunneled through your head node. The SSH keys for both nodes need to be on your local workstation to enable this connection.

```bash
ssh -i <path to ssh key> -J <user>@<head node publicly accessible ip> <user>@<compute node private internal ip>
```



For example, if your head node has a public facing IP address of **154.114.57.126** and the compute node has an private, internal IP address of **10.100.0.191**, then you would connect to this compute node using:

```bash
ssh -i ~/.ssh/id_ed25519_sebowa -J arch@154.114.57.126 arch@10.100.0.191
```

> [!NOTE]
> Remember to use the **SSH keys**, **usernames** and **ip addresses** corresponding to *your* nodes! You have been **STRONGLY** advised to make use of the **SAME SSH KEY** on your compute node as you had used on your head node. Should you insist on using different SSH keys for you nodes, refer to the hidden description that follows. Reveal the hidden text by clicking on the description.

<details>
<summary>Head node and compute node deployed using different SSH key pairs</summary>

```bash
ssh -o ProxyCommand="ssh -i <path to head node ssh key> -l <user> -W %h:%p <head node ip>" -i <path to  compute node ip> <user>@<compute node ip>
```
</details>

## Setting a Temporary Password on your Compute Node

```bash
sudo passwd <user>
```

In the event that you manage to lock yourselves out of your VMs, you can typically access the console through your cloud provider's interface (e.g., OpenStack, AWS, Azure) to log in using the password you've just created.

> [!IMPORTANT]
> You will not be able to login into your SSH servers on your head (and *generally speaking* your compute) nodes using a password. This is a security feature by default. Should you have a ***very good reason*** for wanting to utilize password enabled SSH access, discuss this with the instructors.
>
> The reason why you are setting a password at this stage, is because the following set of tasks could potentially break your SSH access and lock you out of your node(s).
>
> * Edit your /etc/ssh/sshd_config and enable password authentication
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> * And uncomment #PasswordAuthentication
> ```conf
> PasswordAuthentication yes
> ```
> 
> * Restart the SSH daemon on your compute node
> ```bash
> sudo systemctl restart sshd
> ```