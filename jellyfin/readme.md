The `RENDER_GROUP_ID` is for hardware acceleration with Intel iGPUs. Get this number for your system by running `getent group render | cut -d: -f3` on the host.  
Note: An Intel iGPU (probably) requires a (headless) display to be plugged in.

- https://jellyfin.org/docs/general/administration/hardware-acceleration/
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/

## Environment variables:
- `JELLYFIN_PUBLISHED_SERVER_URL`: public URL of the Jellyfin server
- `CONFIG_PATH`: path to store the Jellyfin configuration
- `CACHE_PATH`: path to store the Jellyfin cache
- `MEDIA_PATH`: path to the media files
- `RENDER_GROUP_ID`: figure out as mentioned above (e.g. `109`)
