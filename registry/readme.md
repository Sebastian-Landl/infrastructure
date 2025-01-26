Your own docker registry.  
Relevant reading: https://hub.docker.com/_/registry

In short:
- Re-tag an existing image:
  - `docker pull ubuntu`
  - `docker tag ubuntu <host_address>:5000/ubuntu`
  - `docker push <host_address>:5000/ubuntu`
- Tag an image at build time:
  - `docker build -t <host_address>:5000/myimage:1.0 .`
  - `docker push <host_address>:5000/myimage:1.0`

When using an image from your registry, just reference it with `<host_address>:5000/myimage:1.0` and you are good to go. Just make sure your registry is reachable from where you want to pull.

Finally, if you don't want to set up HTTPS and only use the docker registry on your internal network, you need to add the registry to the list of insecure registries:  
Add `"insecure-registries":["192.168.99.100:5000"]` to the `daemon.json` file and restart the Docker daemon. It is located at `C:\ProgramData\Docker\config\daemon.json` or `%userprofile%\.docker\daemon.json` on Windows and `/etc/docker/daemon.json` or `~/.config/docker/daemon.json` on Linux. You may have to create the file, if it doesn't exist.  
https://stackoverflow.com/questions/49674004/docker-repository-server-gave-http-response-to-https-client, https://stackoverflow.com/questions/55351659/cannot-find-the-daemon-json-file-in-windows-10-after-docker-desktop-installation, https://docs.docker.com/engine/daemon/
