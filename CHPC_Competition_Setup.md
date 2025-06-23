
# 🧠 CHPC Competition Notes

## ✅ Step 1: Create the NAT Network in VirtualBox

This is a one-time setup.

1. Open **VirtualBox**.
2. Go to **File** → **Tools** → **Network Manager**.
3. Click the **NAT Networks** tab.
4. Click **Create**.
   - You’ll get something like `NatNetwork`.
   - Confirm CIDR is `10.0.2.0/24`.
   - Enable network.
5. This acts as a **virtual router** for your cluster.

---

## ✅ Step 2: Configure Your Ubuntu VMs

We're assuming two VMs: `ubuntu-head` (head node), `ubuntu-node1` (compute node).

### 🖧 Step 2.1: Attach VMs to the NAT Network

1. For each VM → **Settings** → **Network** → **Adapter 1**:
   - Enable adapter.
   - Attached to: NAT Network.
   - Name: `NatNetwork`.

### 🔐 Step 2.2: Install SSH Server on Each VM

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh --now
```

### 🌐 Step 2.3: Get IP Addresses

Run on each VM:

```bash
ip a
```

Note the `inet` address under `enp0s3` (e.g., `10.0.2.4`, `10.0.2.5`).

### 📶 Step 2.4: Test Connectivity

From `head`, test ping and SSH to `node1`:

```bash
ping 10.0.2.5
ssh your_user@10.0.2.5
```

---

## ✅ Step 3: Set Up Port Forwarding (Host → VM)

### Port Mappings

- Host `2222` → `head:22`
- Host `2223` → `node1:22`

### In VirtualBox

1. **File** → **Tools** → **Network Manager** → `NatNetwork` → **Port Forwarding**
2. Add 2 rules:
   - `head-ssh`: Host Port `2222`, Guest IP `10.0.2.4`, Guest Port `22`
   - `node1-ssh`: Host Port `2223`, Guest IP `10.0.2.5`, Guest Port `22`

---

## ✅ Step 4: SSH from Host to VMs

From host terminal:

```bash
ssh your_user@127.0.0.1 -p 2222  # head
ssh your_user@127.0.0.1 -p 2223  # node1
```

---

## ✅ Step 5: Passwordless SSH Setup

### 🔐 Scenario 1: Host → VM (Passwordless)

#### Step 5.1: Generate SSH Key (if needed)

```bash
ls -l ~/.ssh/id_rsa.pub
ssh-keygen -t rsa -b 4096
```

#### Step 5.2: Copy Host Key to VMs

```bash
ssh-copy-id -p 2222 your_user@127.0.0.1
ssh-copy-id -p 2223 your_user@127.0.0.1
```

#### Step 5.3: Test SSH

```bash
ssh -p 2222 your_user@127.0.0.1
ssh -p 2223 your_user@127.0.0.1
```

---

### 🔁 Scenario 2: head → node1 (Internal Cluster Access)

#### Step 5.4: Generate Key on `head`

```bash
ssh -p 2222 your_user@127.0.0.1
ssh-keygen
```

#### Step 5.5: Copy to `node1`

```bash
ssh-copy-id your_user@10.0.2.5
```

#### Step 5.6: Test Passwordless from head to node1

```bash
ssh your_user@10.0.2.5
```

---

## ✅ Summary Table

| From       | To         | Method / Command              | Description                                                  |
|------------|------------|-------------------------------|--------------------------------------------------------------|
| Host       | `head`      | `ssh-copy-id -p 2222`         | Manage head from your machine                                 |
| Host       | `node1`      | `ssh-copy-id -p 2223`         | Manage node1 from your machine                                 |
| `head`      | `node1`      | `ssh-copy-id 10.0.2.5`        | Needed for clustering & automated control                    |
