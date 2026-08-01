# Overleaf CE

This stack runs Overleaf Community Edition with its own MongoDB, Redis, and
SeaweedFS services. It is meant to be a simple self-hosted setup: fill in the
environment values, create the host directories, and start it with Docker.


Note that this docker-compose runs an [arm image](https://hub.docker.com/r/pingwin02/sharelatex-arm), ther is also the [official amd64 only image](https://hub.docker.com/r/sharelatex/sharelatex/).

## Services

| Service          | Role                                                       |
|-------------------|-------------------------------------------------------------|
| `overleaf`       | the app, using the pinned prebuilt image with TeXLive baked in |
| `mongo`          | required, single-node replica set (transactions dependency) |
| `redis`          | session/pubsub state                                        |
| `seaweedfs`      | S3-compatible object store, private to this stack |
| `seaweedfs-init` | one-shot job (same SeaweedFS image, `weed shell`) that creates the two required buckets on first boot |

## Prepare host directories

The data directories are bind-mounted from the host. Create them first and set
ownership for MongoDB and Redis:

```bash
# adjust the base path to wherever you want this to live
sudo mkdir -p /srv/overleaf/{sharelatex,mongo,redis,seaweedfs}

# mongo and redis official images both run as uid:gid 999:999 internally
sudo chown -R 999:999 /srv/overleaf/mongo /srv/overleaf/redis

# sharelatex's entrypoint fixes ownership of its own data dir at container
# start (runs as root, drops privileges after), so no manual chown needed
# seaweedfs (chrislusf/seaweedfs) runs as root by default, same story
```

If a container keeps restarting with permission errors, check the ownership of
those host directories.

Make sure `OVERLEAF_DATA_PATH`, `MONGO_DATA_PATH`, `REDIS_DATA_PATH`, and
`SEAWEEDFS_DATA_PATH` in `.env` point at those paths.

## Deploy

```bash
cp .env.example .env
# edit .env: DOMAIN, ADMIN_EMAIL, S3_ACCESS_KEY, S3_SECRET_KEY,
#   and the four *_DATA_PATH variables (must match the directories you
#   created and chowned in "Prepare host directories" above)
#   (pick a real random secret for S3_SECRET_KEY — this only needs to be
#   unique to this stack, it's not shared with anything else)

docker compose up -d
docker compose logs -f overleaf   # watch until it's healthy
```

The start order is handled automatically: Mongo initializes its replica set,
SeaweedFS becomes ready, the init job creates the S3 buckets, and then
Overleaf starts.

## Create your admin user

There is no default admin account. Create one after the first start.

**Web UI:** visit `https://<DOMAIN>/launchpad` on a fresh install and create the
first admin account there.

**CLI:**

```bash
docker exec overleaf /bin/bash -ce \
  "cd /overleaf/services/web && node modules/server-ce-scripts/scripts/create-user --admin --email=you@example.tld"
```

That command prints a one-time setup URL. Save it when it appears, because it
is the only copy if mail is not configured.

## Verify everything came up right

```bash
# TeXLive toolchain
docker exec overleaf kpsewhich tikz.sty
docker exec overleaf which biber

# SeaweedFS buckets actually got created
docker exec overleaf-seaweedfs sh -c "echo 's3.bucket.list' | weed shell -master=seaweedfs:9333"
```

If TeXLive checks fail, check the container logs and pull the latest image.

## Notes

- Overleaf Community Edition is not the same as the paid hosted product.
- This setup is single-node and is best treated as a personal or small-team
  deployment.

## User/project management reference

New users can usually be added from the web UI once you have an admin
account.
