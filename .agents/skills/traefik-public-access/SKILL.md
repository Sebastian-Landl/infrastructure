---
name: traefik-public-access
description: Wires up a docker-compose service for public HTTPS access through the Traefik reverse proxy used in this repo. Use this skill whenever the user wants to expose a service publicly, add a domain, add a Traefik label, route traffic through Traefik, or make a container reachable from the internet. Also use it when adding any new service to docker-compose.yml that should be accessible from a browser or external client.
---

# Traefik Public Access

This repo runs Traefik v3 as a reverse proxy on the `public` Docker network. Services opt in with labels. TLS is handled automatically via Let's Encrypt.

## Architecture

```
Internet → Traefik (:80/:443)
             ├── HTTP → redirects to HTTPS
             └── HTTPS → routes by Host() rule → service container
```

Global middlewares applied automatically by `traefik.yml` to every HTTPS request:
- `secureHeaders@file` — HSTS, SSL redirect
- `crowdsec-bouncer@file` — IP reputation / bot protection

## Checklist for exposing a service

1. Add `traefik.enable=true` label and the routing labels (see below)
2. Join the `public` network
3. Declare `public` as an external network at the bottom of the file
4. Remove the direct host port mapping (Traefik handles ingress) — keep it only if local non-TLS access is also needed
5. Add `<SERVICE>_TRAEFIK_DOMAIN` to `.env.example`

## Labels template

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.docker.network=public"
  - "traefik.http.routers.<service>-secure.entrypoints=websecure"
  - "traefik.http.routers.<service>-secure.rule=Host(`${<SERVICE>_TRAEFIK_DOMAIN}`)"
  - "traefik.http.routers.<service>-secure.service=<service>"
  - "traefik.http.services.<service>.loadbalancer.server.port=<internal_container_port>"
```

Replace `<service>` with a lowercase slug (e.g. `grafana`, `litellm`). Use the container's internal port, not the host-mapped port.

### Optional: protect with basic auth

Add this label when the service has no built-in auth (e.g. Prometheus, internal dashboards):

```yaml
  - "traefik.http.routers.<service>-secure.middlewares=user-auth@file"
```

The `user-auth` middleware is a basic-auth door defined in `traefik/configurations/dynamic.yml`.

## Networks block

In the service's `networks:` list add `public`:

```yaml
    networks:
      - <any_internal_network>
      - public
```

At the bottom of the compose file, declare the network as external:

```yaml
networks:
  <any_internal_network>:
    driver: bridge       # or external: true if it pre-exists
  public:
    external: true
```

## .env.example entry

```dotenv
# Public domain for <ServiceName> served via Traefik
<SERVICE>_TRAEFIK_DOMAIN=myservice.example.com
```

## Full example

```yaml
services:
  myapp:
    image: myapp:latest
    container_name: myapp
    restart: unless-stopped
    environment:
      - SOME_VAR=${SOME_VAR}
    volumes:
      - ${MYAPP_DATA_PATH}:/data
    networks:
      - internal
      - public
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=public"
      - "traefik.http.routers.myapp-secure.entrypoints=websecure"
      - "traefik.http.routers.myapp-secure.rule=Host(`${MYAPP_TRAEFIK_DOMAIN}`)"
      - "traefik.http.routers.myapp-secure.service=myapp"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"

networks:
  internal:
    driver: bridge
  public:
    external: true
```

## Common mistakes

| Mistake | Fix |
|---|---|
| Forgetting `traefik.docker.network=public` when a container has multiple networks | Traefik can't pick the right IP without this |
| Using host port in `server.port` | Always use the container's internal port |
| Leaving a conflicting `ports:` mapping | Remove it or Traefik and the direct port will both work (usually fine, but unnecessary) |
| Router name clash with another service | Each service needs a unique router/service name slug |
