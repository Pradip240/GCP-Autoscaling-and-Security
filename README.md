# GCP-Autoscaling-and-Security
---
### Install VirtualBox in linux
1. Update system
```bash
sudo apt update
```

2. Install VirtualBox
```bash
sudo apt install virtualbox
```

3. Verify installation
```bash
virtualbox
```
---

### Download alpine OS

download ios file from https://download.g0tmi1k.com/iso/Ubuntu/Ubuntu-20.04/ubuntu-20.04.6-live-server-amd64.iso
---

### Create VM
create VM using downloaded image
- add 4096 MB memory and 2 CPU processor
- Enable EFI
- keep 50 GB Hard Disk
setup network adapter to bridge for local machine access
---

### Install OpenSSH server
```bash
sudo apt update
sudo apt install -y openssh-server
```
Start and enable the SSH service
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```
Check status:
```bash
sudo systemctl status ssh
```

# Disable IPv6
Edit sysctl config:
```bash
sudo nano /etc/sysctl.conf
```
Add these lines at the bottom:
```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
Apply immediately:
```bash
sudo sysctl -p
```
---

### Create the Service Account
- name: local-autoscale-bot

Grant this service account access to project:
- Compute Admin
- Service Account User

Download the JSON Key
- rename key to: autoscale-key.json
- Copy the key to VM

### Create the Instance Template
- name: autoscale-app-template
- Check Allow HTTP traffic and Allow HTTPS traffic
- Add app's Startup Script
---

### Install the CPU Monitor
```bash
sudo apt update
sudo apt install -y sysstat 
```

Clone the repositories
```bash
sudo apt update
sudo apt install -y curl git
git clone https://github.com/Pradip240/GCP-Autoscaling-and-Security.git
```

Install gcloud
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg curl

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt update
sudo apt install -y google-cloud-sdk
```

Authenticate the terminal
```bash
gcloud auth activate-service-account --key-file=/home/pradip/autoscale-key.json
```

## Set Cronjob
Open the crontab editor:
```bash
crontab -e
```
Add this line to run script every minute:
```bash
* * * * * /home/pradip/GCP-Autoscaling-and-Security/autoscale-trigger.sh >> /home/pradip/autoscale.log 2>&1
```
