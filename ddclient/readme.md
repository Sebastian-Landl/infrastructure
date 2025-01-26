For `ddclient` to work the config must be correct. The file `ddclient.conf` must be placed inside a folder `config` and the location of that folder must be specified in the `.env` file (`DDCLIENT_CONFIG`).  
In `ddclient.conf` some general settings are specified and most importantly the information on how the DNS entry for a domain can be updated.

### General settings
- `daemon`: If set ddclient runs in daemon mode and will update the DNS entry in the given interval in seconds. Recommended: `330`.
- `ssl`: Enables ssl, if set to `yes`. Recommended: `yes`.
- `protocol`: Specifies the ddns protocol.
- `use=<method>, cmd='<specification>'`: Sets the method to check for the current IP address, depending on the method additional information is necessary. Examples are:
  - `use=cmd, cmd='curl https://checkipv4.dedyn.io/'` (Worked for me so far)
  - `use=web, web=https://api.ipify.org/`
- `server`: Specifies the update server, depends on you ddns supplier.

### Domain settings
For each subdomain you want to update, you need an entry of this shape (at least that's how it worked for me and my ddns supplier):
```
login=<(sub)domain>
password='<authetication_token>'
<(sub)domain>
```

## Checking if it works
With the command `sudo ddclient -daemon=0 -debug -verbose -noquiet -file config/ddclient.conf` you can check whether your configuration works. If it works, then for each (sub)domain you configured, you should see one line starting with `SUCCESS:` at the end of the output.