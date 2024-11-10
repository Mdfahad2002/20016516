Here’s a sample `README.md` file for the Ansible automation portion of your infrastructure setup:

---

# Azure Infrastructure Ansible Repository

This repository contains Ansible playbooks to automate the configuration of an Azure Windows Server VM. The playbooks perform tasks like installing Docker and configuring system settings using Ansible. This setup simplifies and automates the configuration of the server environment.

## Prerequisites

- Ansible installed on your local machine
- A running Azure subscription with an existing Windows VM
- Azure VM set up with WinRM enabled for remote management
- Python 3 and `pywinrm` installed on the machine running Ansible

## Directory Structure

```
.
├── inventory.ini             # Inventory file listing target hosts
├── setup_docker.yml          # Ansible playbook to install and configure Docker on Windows VM
├── README.md                 # Repository documentation
```

## Getting Started

### 1. Clone the Repository

Start by cloning this repository:

```bash
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

### 2. Configure Ansible Inventory

In the `inventory.ini` file, list your Azure Windows VM with necessary connection details.

```ini
[azure_vm]
52.160.65.158 ansible_user=NetworkAdmin ansible_password=P@ssw0rd1234! ansible_connection=winrm ansible_winrm_transport=basic ansible_winrm_server_cert_validation=ignore
```

- Replace `52.160.65.158` with the **public IP address** of your Azure VM.
- Replace `NetworkAdmin` with the **administrator username**.
- Replace `P@ssw0rd1234!` with the **password**.

### 3. Configure Ansible Playbook

The playbook `setup_docker.yml` is used to install Docker on your Windows VM. 

Here is the basic structure:

```yaml
- name: Install Docker on Windows VM
  hosts: azure_vm
  tasks:
    - name: Install Chocolatey (Windows package manager)
      win_chocolatey:
        name: chocolatey
        state: present
        source: https://chocolatey.org/install.ps1

    - name: Install Docker
      win_chocolatey:
        name: docker-desktop
        state: present

    - name: Ensure Docker service is started
      win_service:
        name: com.docker.service
        start_mode: auto
        state: started
```

This playbook will:

1. Install Chocolatey (a Windows package manager).
2. Install Docker Desktop.
3. Ensure that the Docker service is running and starts automatically.

### 4. Install Python Dependencies

For Ansible to communicate with the Windows VM, you need to install `pywinrm` for WinRM-based communication.

Run the following commands on your local machine:

```bash
sudo apt install python3-pip -y
pip3 install pywinrm[credssp]
```

### 5. Test the Connection

Test the connectivity to your Windows VM using the `win_ping` module to check if Ansible can reach the server:

```bash
ansible -i inventory.ini azure_vm -m win_ping
```

You should see a success message from the VM.

### 6. Run the Playbook

Once the connection is verified, run the playbook to set up Docker on your Azure VM:

```bash
ansible-playbook -i inventory.ini setup_docker.yml
```

This command will install Docker and start the Docker service on your Azure Windows VM.

### 7. Clean Up (Optional)

To stop the Docker service or remove it from your VM, modify the playbook or manually stop the service via Windows settings.

## Notes

- Ensure that **WinRM** is enabled on your Windows VM for remote management.
- The `ansible_winrm_server_cert_validation=ignore` option is necessary if your Windows VM is using self-signed certificates or if you are not configuring HTTPS for WinRM.
- Keep your Azure credentials and passwords secure and avoid committing them to the repository.

## Contributing

Feel free to fork the repository and contribute by submitting pull requests or reporting issues.

---

This README outlines the steps to set up and run your Ansible automation for the Azure Windows VM. Adjust the commands, paths, and configuration as necessary for your setup.