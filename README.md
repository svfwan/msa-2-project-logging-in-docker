# Docker Logging with PLG Stack

MSA-2 Project: Centralized logging for Docker containers using Promtail, Loki, and Grafana.

## Architecture

```mermaid
flowchart LR
    APP[FastAPI App] -->|stdout| Docker
    Docker -->|socket API| Promtail
    Promtail -->|push| Loki
    Grafana -->|query| Loki
```

## Data Flow

```mermaid
sequenceDiagram
    User->>App: HTTP request
    App->>App: print(json log)
    App-->>Docker: stdout captured
    Promtail->>Docker: read logs via socket
    Promtail->>Loki: push logs
    User->>Grafana: view logs
    Grafana->>Loki: LogQL query
```

## Quick Start

```bash
make up      # start all services
make test    # generate test logs
make down    # stop all services
make help    # show all commands
```

## Services

| Service  | Port | Description |
|----------|------|-------------|
| app      | 8000 | FastAPI app with JSON logging |
| loki     | 3100 | Log storage |
| promtail | -    | Log collector |
| grafana  | 3000 | Web UI (admin/admin) |

## View Logs in Grafana

1. Open http://localhost:3000 (login: admin/admin)
2. Go to **Explore** (compass icon)
3. Query: `{container="logging-demo-app"}`

### Example Queries

```logql
{container="logging-demo-app"}              # all app logs
{container="logging-demo-app"} |= "greeting" # filter by text
{container="logging-demo-app"} | json        # parse JSON fields
```

## Project Structure

```
app/
├── main.py           # FastAPI with JSON logging
├── Dockerfile
└── pyproject.toml
promtail/
└── config.yml        # Docker service discovery config
grafana/provisioning/
└── datasources/
    └── loki.yaml     # Auto-configured Loki datasource
docker-compose.yml
Makefile
```

## Troubleshooting

```bash
make ps              # check containers running
make logs-promtail   # check promtail logs
make logs-app        # check app logs
curl localhost:3100/ready  # check loki health
```
