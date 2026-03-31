# Monitoring Stack

Prometheus + Grafana with exporters for system and GPU metrics.

## Services

| Service | Port | Description |
|---|---|---|
| Grafana | 3000 | Dashboard UI |
| Prometheus | 9090 | Metrics store and query engine |
| node-exporter | 9100 | Host CPU, RAM, disk, network |
| dcgm-exporter | 9400 | NVIDIA GPU (MIG, NVLink, memory BW, SM util) |

## Setup

```bash
cp .env.example .env
# Edit .env — set GRAFANA_ADMIN_PASSWORD and data paths
mkdir -p /opt/monitoring/prometheus /opt/monitoring/grafana
# Grafana runs as UID 472 — fix ownership before first start
sudo chown -R 472:472 $GRAFANA_DATA_PATH
# Prometheus runs as UID 65534 (nobody) — fix ownership before first start
sudo chown -R 65534:65534 $PROMETHEUS_DATA_PATH
# Create the shared monitoring network (once per host)
docker network create monitoring
docker compose up -d
```

## GPU monitoring

Uses **dcgm-exporter** (`nvcr.io/nvidia/k8s/dcgm-exporter`) over the simpler `nvidia_gpu_exporter` because it exposes:
- MIG slice metrics
- NVLink throughput
- Memory bandwidth
- SM utilization

Requires the NVIDIA Container Toolkit and `nvidia` runtime available on the host.

## Grafana dashboards

### Recommended dashboards

| Dashboard | ID | Description |
|---|---|---|
| [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) | `1860` | Host CPU, RAM, disk, network |
| [NVIDIA DCGM Dashboard](https://grafana.com/grafana/dashboards/22515-nvidia-dcgm-dashboard/) | `22515` | NVIDIA GPU metrics (MIG, NVLink, memory BW, SM util) |
| [cAdvisor Dashboard](https://grafana.com/grafana/dashboards/19792-cadvisor-dashboard/) | `19792` | Per-container CPU, RAM, disk I/O, network |
| [LiteLLM](https://grafana.com/grafana/dashboards/24965-litellm/) | `24965` | LiteLLM model usage |

### How to import a dashboard

1. Open Grafana in your browser and log in.
   > Prometheus is already provisioned as the default data source via `provisioning/datasources/prometheus.yml` — no manual setup needed.
2. Go to **Dashboards → New → Import**
3. Enter the dashboard ID (e.g. `1860`) and click **Load**
4. Select your Prometheus data source from the dropdown and click **Import**
