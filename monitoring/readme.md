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

Import these from grafana.com after adding Prometheus as a data source (`http://prometheus:9090`):

- **Node Exporter Full** — ID `1860` (CPU, RAM, disk, network)
- **DCGM Exporter** — ID `12239` (NVIDIA GPU)
