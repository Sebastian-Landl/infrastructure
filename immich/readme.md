Recommended [Immich](https://immich.app/) setup taken from [here](https://docs.immich.app/install/docker-compose/), customized to use nvenc, DB on HDD and using traefik labels.
Note: CUDA is at the time of writing x86 only.

When deploying on arm64, you may encounter the error `no matching manifest for linux/arm64/v8 in the manifest list entries`. Try directly `docker pull`ing the image(s). Worked for me.