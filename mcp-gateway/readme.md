Set up the `mcp` docker network if not already created:

```bash
docker network create mcp
```

Put all services in it, that need to access the MCP tools.

Browse available mcps: https://hub.docker.com/mcp

There are multiple gateways set up, so the functionalities are split up in a meaningful way.
