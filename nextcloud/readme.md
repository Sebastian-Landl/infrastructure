## Environment Variables:
- `NEXTCLOUD_TRUSTED_DOMAINS` is a whitespace separated list of domains nextcloud should be reachable under.
- `POSTGRES_PASSWORD`
- `POSTGRES_DATA_PATH`: could also be replaced with a volume mount
- `NEXTCLOUD_USER`: admin username
- `NEXTCLOUD_PASSWORD`: admin password
- `NEXTCLOUD_PATH`: path to store nextcloud and the data (could also be a volume mount)

## Additional setup, if the Nextcloud Client does not connect
To use the nextcloud client app, some more configuration may be necessary. Log into the nextcloud container. (It could be that this is only a problem, when the Nextcloud client and server are on the same network, not sure.)
- Identify the container by running `docker ps` on the docker host machine
- Start a shell in it with `docker exec -it <container ID or name> /bin/bash`

Next modify the file `/var/www/html/config/config.php`. The following will describe the changes necessary, but there may be other lines inbetween them.  
Change
```
  array (
    0 => 'localhost',
    1 => 'nextcloud.yourdomain.com',
  ),

  'overwrite.cli.url' => 'http://localhost',
```
to
```
  array (
    0 => 'nextcloud.yourdomain.com',
  ),

  'overwrite.cli.url' => 'https://nextcloud.yourdomain.com',
  'overwriteprotocol' => 'https',
```
After those changes you should be able to connect your client app.

(https://help.nextcloud.com/t/the-polling-url-does-not-start-with-https-despite-the-login-url-started-with-https/137576)

## Maximum Upload Size
The default maximum upload size is `512MB`. I you want to increase that, for now, do the following:
- Connect to the container: `docker exec -it <container_id> /bin/bash`
- Add the following lines to a config file using this command: `nano /etc/apache2/apache2.conf`:
```
<IfModule mod_php.c>
    php_value upload_max_filesize 100G
    php_value post_max_size 100G
    php_value memory_limit 1G
</IfModule>
```
- Restart the apache server with: `apachectl restart` (Warning: this will terminate the connection to the container, but that is expected)
- Check, if it worked by looking in the nextclout UI at `<nextcloud_url>/settings/admin/serverinfo` at the PHP settings

*Note: If you ran into this error with your nextcloud client, you also need to restart that client after configuring the server for the upload of larger files to work.*
