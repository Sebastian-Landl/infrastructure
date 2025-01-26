## Environment Variables
- `TIMEZONE`: Your timezone, e.g. `Europe/Vienna`
- `WEB_PASSWORD`: Password to access the web interface
- `ETC_PIHOLE`: path to store some pihole files
- `ETC_DNSMASQ`: path to store some dnsmasq files

## Adlists
If you have no prior backup of a `pihole` instance, you may want to import the `adlists.list` into the new container, just replace the one inside the `ETC_PIHOLE` folder.

More info at https://github.com/pi-hole/docker-pi-hole/ and https://docs.pi-hole.net/.

## DNS Port may already be in use
You may have to disable and stop the service `systemd-resolved`, which handles local DNS lookups and already uses port `53`. Do that on the host machine with:
- `sudo systemctl disable systemd-resolved`
- `sudo systemctl stop systemd-resolved`

Then edit `/etc/resolv.conf` with `sudo nano /etc/resolv.conf` and replace the line
```
nameserver 127.0.0.53
```
with
```
nameserver 127.0.0.1
```
which means that instead of using `systemd-resolved` now the `pihole` container will be used for dns resolution.

**Be careful when doing this!** This disables the service responsible for DNS resolution on your server, meaning it won't be able to resolve names anymore. That includes the ones required for pulling the pihole docker image. So do that first. Easiest way is to deploy the service without deactivating `systemd-resolved`, seeing the container fail to start, stopping `systemd-resolved` and restarting the container without pulling it again.
