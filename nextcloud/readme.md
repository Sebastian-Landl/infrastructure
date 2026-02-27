## Environment Variables:
- `REDIS_PASSWORD`
- `POSTGRES_DB`: name of the nextcloud database
- `POSTGRES_USER`: name of the nextcloud database user
- `POSTGRES_PASSWORD`
- `POSTGRES_DATA`: could also be replaced with a volume mount
- `NEXTCLOUD_ADMIN_USER`: admin username
- `NEXTCLOUD_ADMIN_PASSWORD`: admin password
- `NEXTCLOUD_TRUSTED_DOMAINS` is a whitespace separated list of domains nextcloud should be reachable under
- `NEXTCLOUD_OVERWRITEPROTOCOL`: if you want to use https, set this to `https`, otherwise to `http`. This must correspond to your access method.
- `NEXTCLOUD_DIR`: path to store nextcloud and data (could also be a volume mount)

## TODO: test, make unnecessary and move to an archive section

### Additional setup, if the Nextcloud Client does not connect 
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

### Maximum Upload Size
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

## References
- [Extra cron container](https://github.com/nextcloud/docker/blob/master/.examples/docker-compose/with-nginx-proxy/mariadb/apache/compose.yaml)
- [Redis integration](https://github.com/Andreaux/Nextcloud-Docker-Compose/blob/main/docker-compose.yml)