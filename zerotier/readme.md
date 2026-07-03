# ZeroTier Home Server Access — Setup Guide

Goal: reach your home server (its ports/services) from anywhere via ZeroTier, no LAN routing.

## 1. Prerequisites
- ZeroTier account at https://my.zerotier.com (free tier: up to 25 devices)
- Docker + docker-compose on the home server
- ZeroTier client on laptop (Windows/Mac/Linux native installer, not Docker)

## 2. Create the network
1. Go to my.zerotier.com → Networks → Create a Network
2. Note the **Network ID** (16-char hex string)
3. Leave default settings (IPv4 Auto-Assign enabled) — covered in section 5

## 3. Server container

Bring it up:
```bash
docker compose up -d
docker exec zerotier zerotier-cli join <NETWORK_ID>
```

Go back to my.zerotier.com → your network → Members tab. The server's node ID will appear as "unauthorized" — check the box to authorize it. Give it a name in the notes field so you don't confuse it with the laptop later.

## 4. Laptop client
- Install native app: https://www.zerotier.com/download/
- `zerotier-cli join <NETWORK_ID>` (or use the GUI)
- Authorize it in the Members tab, same as the server

## 5. IP addressing
- Auto-Assign (default) hands out IPs from a pool (e.g. `172.25.0.0/16`) — fine for most cases, IP is stable per node unless you delete/rejoin.
- For a **predictable/static IP** on the server: in the network's Members tab, uncheck "Auto-Assign" for that member and manually type an IP in the pool's range (e.g. `172.25.0.10`). Do this for the server so you always know its address.
- The laptop can stay on auto-assign — you're initiating connections *to* the server, not the other way around.

Once both are authorized, from the laptop:
```bash
ping 172.25.0.10          # server's ZT IP
ssh user@172.25.0.10
```

## 6. Container restart behavior
- `restart: unless-stopped` means it survives host reboots and Docker daemon restarts, rejoining the network automatically.
- **Identity persistence is the critical part**: `/var/lib/zerotier-one` (mapped to `./zerotier-data`) stores the node's cryptographic identity (`identity.secret`/`identity.public`) and network membership state.
  - If that volume is intact: container restarts, reconnects with the same node ID and same assigned IP, no re-authorization needed.
  - If that volume is lost/deleted: container generates a **new node ID** on next start, shows up as a brand-new unauthorized member, and you have to authorize it again and reconfigure the static IP. Treat this directory like a credential — back it up.

## 7. Verify / troubleshoot
```bash
docker exec zerotier zerotier-cli listnetworks   # should show OK status
docker exec zerotier zerotier-cli info            # node ID + online status
```
- Status `ACCESS_DENIED` = not authorized yet in Central
- Status `REQUESTING_CONFIGURATION` stuck = check NAT/firewall isn't blocking UDP 9993 outbound (rarely an issue, ZT falls back to relays)
- No `zt*` interface on host = missing `/dev/net/tun` or caps, or container isn't actually using `network_mode: host`

## 8. Exposing services
Once connected, hit the server's ZT IP directly on whatever port the service listens on (e.g. `172.25.0.10:8080`). No port forwarding on your router needed — that's the entire point of this setup.