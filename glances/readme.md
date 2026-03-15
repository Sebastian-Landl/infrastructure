Glances is a service to monitor information about the system in a dashboard. It runs directly on the server because it needs access to hardware information. The dashboard can be accessed in the local network.

## Glances Home Server Monitoring Setup

> Ubuntu/Debian · NVIDIA GPU · uv · Web UI

---

## Prerequisites

### 1. System packages

```bash
sudo apt update
sudo apt install -y lm-sensors
```

### 2. Configure lm-sensors

```bash
sudo sensors-detect --auto
```

### 3. Load drivetemp module (disk temps)

```bash
sudo modprobe drivetemp
echo "drivetemp" | sudo tee /etc/modules-load.d/drivetemp.conf
```

### 4. Verify sensors before proceeding

```bash
sensors      # Should show CPU + mobo temps + drive temps (after drivetemp is loaded)
nvidia-smi   # Should show GPU usage + temp
```

> Fix anything missing here before continuing — Glances can only surface what the host exposes.

---

## Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env  # or restart your shell
```

---

## Install Glances

```bash
uv tool install "glances[all]" --with py3nvml
```

Verify:

```bash
glances --version
```

---

## Configuration

Create the Glances config directory and file:

```bash
mkdir -p ~/.config/glances
```

### `~/.config/glances/glances.conf`

```ini
[global]
check_update=false

[cpu]
enable=true

[mem]
enable=true

[gpu]
enable=true

[diskio]
enable=true

[fs]
enable=true

[network]
enable=true

[sensors]
enable=true
# Uncomment and adjust if you want to filter specific sensors:
# hide=Virtual_0,acpitz

[hddtemp]
enable=false
```

---

## Systemd Service

### `/etc/systemd/system/glances.service`

```ini
[Unit]
Description=Glances Monitoring (Web UI)
After=network.target

[Service]
ExecStart=/home/YOUR_USER/.local/bin/glances -w --disable-plugin docker
Restart=on-failure
User=YOUR_USER
Environment=HOME=/home/YOUR_USER

[Install]
WantedBy=multi-user.target
```

> Replace `YOUR_USER` with your actual username.

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now glances
sudo systemctl status glances
```

---

## Accessing the Dashboard

Open in your browser:

```
http://<server-ip>:61208
```

To find your server's local IP:

```bash
hostname -I
```

### Optional: Make it available on your network

Glances binds to `0.0.0.0` by default when run with `-w`, so it's accessible from any machine on your LAN at `http://<server-ip>:61208` with no extra config.

---

## Metric Coverage

| Metric            | Plugin         | Dependency         | Status |
|-------------------|----------------|--------------------|--------|
| CPU usage         | `cpu`          | psutil             | ✅     |
| CPU temp          | `sensors`      | lm-sensors         | ✅     |
| RAM usage         | `mem`          | psutil             | ✅     |
| GPU usage + temp  | `gpu`          | py3nvml / nvidia-smi | ✅   |
| Disk usage        | `fs`           | psutil             | ✅     |
| Disk temp         | `sensors`      | lm-sensors + drivetemp module | ✅ |
| Network usage     | `network`      | psutil             | ✅     |

---

## Troubleshooting

### Temps not showing
```bash
# Check lm-sensors directly
sensors

# Check if drivetemp is loaded
lsmod | grep drivetemp

# Load it manually if missing
sudo modprobe drivetemp

# Re-run sensor detection
sudo sensors-detect --auto
```

### GPU not showing
```bash
# Verify py3nvml is installed in the right env
uv tool run glances --list-plugins | grep gpu

# Check nvidia-smi works
nvidia-smi
```

### Service not starting
```bash
sudo journalctl -u glances -f
```

---

## Notes

- Glances web UI auto-refreshes every 3 seconds by default. Adjust with `--time N` (seconds).
- Historical graphs are available in the web UI per metric.
- If you later want persistent history + alerting, Glances exports to InfluxDB → Grafana. Worth it for long-term trending.