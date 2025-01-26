# Infrastructure
A repo containing docker compose files for various services as well as useful instructions to set up Ubuntu server to run them. The general options described here are setting up Proxmox and then running a Ubuntu server VM. Or simply installing Ubuntu server directly on the machine. 

The main event here are the docker compose files. They are used to set up services like Pi-Hole, Nextcloud, Jellyfin, and more. The services are set up behind an Nginx Proxy Manager, which handles SSL certificates and reverse proxies.

*NOTE: These are configs that work or worked for me. I tried to keep them general, but there may be some things specific to my setup.*

## Setting up Proxmox (including useful zfs commands)
Just install it. (Optionally switch to no-subscription repos: https://www.techwrix.com/configuring-no-subscription-repository-in-proxmoxm-ve-8-x-part-6/) If you need an encrypted ZFS dataset:
- Create zfs pool: `sudo zpool create -f data /dev/disk/by-id/ata-ST4000DM004-2CV104_ZFN0ZFZC /dev/disk/by-id/ata-ST4000DM004-2CV104_ZFN1TX2Y` (Or use it like so, to create a mirrored pool: `zpool create data mirror ...`)  
Use the disk IDs to prevent problemns, when adding/removing disks (new letters may be assigned). Find the disk IDs by running `ls -l /dev/disk/by-id/`.
- Create encryption key (`sudo chmod 600 /root/zfs-keys/file.key`)
- Create encrypted dataset on existing pool: `sudo zfs create -o encryption=on -o keyformat=raw -o keylocation=file:///root/zfs-keys/file.key data/data`.
- Export zfspool (to import it later in the VM): `zpool export data` (the keyfile can now be deleted, but make sure to note the key; you need to keep it safe and also to create a keyfile in the VM)
- Create the VM. You can the inspect its config with `cat /etc/pve/qemu-server/100.conf` (100 is the VM ID). In there you should see a drive at `scsi0`. In the next steps we will add the disks used in the zpool.
- Repeat for each disk to add. Increate the number in `scsi1` and change the disk ids accordingly:
  - `qm set 100 -scsi1 /dev/disk/by-id/ata-ST4000DM004-2CV104_ZFN0ZFZC`
- Now boot into the VM, set it up and import the zpool using `sudo zpool import <zpool_name>`
- Set a new keylocation, if necessary `sudo zfs set keylocation=file:///path/to/key <nameofzpool>/<nameofdataset>`
- Dataset should be available at `<nameofzpool>/<nameofdataset>`
- It should auto-mount on boot. Otherwise: Enable auto-mount on boot: `sudo systemctl enable zfs.target zfs-import.service zfs-mount.service` (don't worry about errors, the relevant services should be enabled by default anyways)

(https://blog.programster.org/zfs-create-disk-pools, https://wiki.archlinux.org/title/ZFS#Unlock_at_boot_time, https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM))

### How to import an existing pool?
- Find available pools `sudo zpool import`
- Follow the instructions above starting with `sudo zpool import <zpool_name>`

(https://docs.oracle.com/cd/E19253-01/819-5461/gazru/index.html)

## Setting up ubuntu server
After the install and setting a secure password (during install or with `passwd`), here are some useful things I like to set up:
- Edit `.bashrc`:
    - `alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'`
    - Set history size to `250000`
- Activate Ubuntu pro: `sudo pro attach <token>`. You can find your token at the [Ubuntu Pro dashboard](https://ubuntu.com/pro/dashboard)
- Optional: Increase LVM size to use entire disk
	- `sudo lvdisplay`
	- `sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv`
	- `sudo lvdisplay`
  - `sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv`
- [Install docker](https://docs.docker.com/engine/install/ubuntu/), if not set up at OS installation time. If you need features like docker secrets (do it), then you need to create a (single node) docker swarm by making your node a docker swarm manager:
  - `docker swarm init` (See the [docs](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) for more info and a multi-node setup)
- Install Nvidia drivers
  - `ubuntu-drivers devices`: detect devices
  - `sudo ubuntu-drivers autoinstall`: install recommended
  - `sudo reboot`
  - Test with `nvidia-smi`
- Install CUDA (I deviate from the Nvidia docs, which can be found [here](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu))
  - `sudo apt install nvidia-cuda-dev nvidia-cuda-toolkit`
  - Test with `nvcc --version`
- [Install Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
  - ````
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
		sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
	````
  - `sudo apt update`
  - `sudo apt install nvidia-container-toolkit`
  - `sudo systemctl restart docker`
  - Test with `sudo docker run --rm --gpus all nvidia/cuda:12.2.2-base-ubuntu22.04 nvidia-smi` (use your cuda version here)
- [Set up Portainer](https://docs.portainer.io/start/install-ce/server/docker/linux)
  - `docker volume create portainer_data`
  - `docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest`
  - Go to port `9443` on the server

## Host ports utilized (example setup)
| Service                         | Port    |
|---------------------------------|:-------:|
| Pi-Hole                         | `53`    |
| Open WebUI                      | `3000`  |
| Registry                        | `5000`  |
| MLFlow                          | `5010`  |
| MLFlow MinIO                    | `5011`  |
| MLFlow Postgres                 | `5012`  |
| Portainer                       | `8000`  |
| Pi-Hole Admin Panel             | `8053`  |
| Nginx Proxy Manager HTTP        | `8080`  |
| Nginx Proxy Manager Admin Panel | `8081`  |
| Nextcloud                       | `8082`  |
| TabbyML                         | `8083`  |
| Jellyfin                        | `8096`  |
| Nginx Proxy Manager HTTPS       | `8443`  |
| Portainer Admin Panel           | `9443`  |
| Ollama                          | `11434` |

## Backups with rsync
`rsync -avHP --delete data_folder backup_folder`
This command will create a folder `data_folder` inside `backup_folder` containing all the data from the `data_folder`. It will perform an incremental backup and delete data that has been removed from the `data_folder`.
Options used:
- `a`: Archive mode used to copy files recursively while preserving symbolic links, file permissions and ownership, and timestamps
- `v`: Verbose
- `H`: Preserve hard links
- `P`: Show the progress of the data transfer
- `delete`: Delete files that are present in `backup_folder`, but not present in `data_folder`

You can configure a cron job to run this command using `crontab -e` (or `sudo crontab -e` to run `sudo` commands) and generate a line with [this handy website](https://crontab-generator.org/).
