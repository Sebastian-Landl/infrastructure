## Environment Variables
- `TIMEZONE`: Your timezone, e.g. `Europe/Vienna`
- `WEB_PASSWORD`: Password to access the web interface
- `PIHOLE_HTTP_PORT`: Port at which the pihole web interface will be running
- `PIHOLE_HTTPS_PORT`: Port at which the pihole web interface will be running (HTTPS)
- `PIHOLE_DATA`: Host path for Pi-hole configuration data, e.g. `/path/to/pihole`

Recommended custom dns servers: `1.1.1.2,1.0.0.2` from Cloudflare or Quad9, which also includes malware blocking.

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
with another valid DNS server like
```
nameserver 1.1.1.2
```
which means that instead of using `systemd-resolved` now the `pihole` container will be used for dns resolution. Afer pihole is running, you may change it to `127.0.0.1` to use the pihole container for dns resolution on the host machine as well.

**Be careful when doing this!** This disables the service responsible for DNS resolution on your server, meaning it won't be able to resolve names anymore. Once you edit the `/etc/resolv.conf`, you are good to go again, but be aware of what you are doing.
