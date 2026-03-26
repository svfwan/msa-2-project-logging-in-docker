# Docker Logging with PLG Stack (Promtail, Loki, Grafana)

MSA-2 Project: Adding logging capabilities to a local Docker host using the PLG stack.

## Architecture

```
+----------------+     +------------+     +-------+     +---------+
|  FastAPI App   | --> |  Promtail  | --> |  Loki | <-- | Grafana |
| (JSON logging) |     | (collector)|     | (DB)  |     |  (UI)   |
+----------------+     +------------+     +-------+     +---------+
        |                    |
        v                    v
    stdout/stderr      Docker Socket
    (docker logs)      (log discovery)
```

## Prerequisites

- Docker (Docker Desktop, Rancher Desktop, or Docker CLI)
- Docker Compose

## Project Structure

```
.
├── app/
│   ├── Dockerfile
│   ├── main.py              # FastAPI application
│   └── pyproject.toml       # Python dependencies (uv)
├── promtail/
│   └── config.yml           # Promtail configuration
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── loki.yaml    # Loki datasource config
├── docker-compose.yml
└── README.md
```

## Quick Start

### 1. Start the Stack

```bash
docker compose up -d
```

This will start:
- **app** (FastAPI): http://localhost:8000
- **loki** (Log storage): http://localhost:3100
- **promtail** (Log collector): running in background
- **grafana** (Visualization): http://localhost:3000

### 2. Generate Some Logs

Make API calls to generate log entries:

```bash
# Access the homepage
curl http://localhost:8000/

# Greet someone
curl http://localhost:8000/hello/Alice

# Greet multiple people
curl http://localhost:8000/hello/Bob
curl http://localhost:8000/hello/Charlie

# Health check
curl http://localhost:8000/health
```

### 3. View Logs in Grafana

1. Open Grafana: http://localhost:3000
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. Go to **Explore** (compass icon in left sidebar)
4. Select **Loki** as the data source (should be pre-selected)
5. Run a query:
   - Click **Label browser** and select `container` = `logging-demo-app`
   - Or enter the query: `{container="logging-demo-app"}`
6. Click **Run query** to see the logs

### Example Queries

```logql
# All logs from the app
{container="logging-demo-app"}

# Filter by event type
{container="logging-demo-app"} |= "greeting"

# Parse JSON and filter
{container="logging-demo-app"} | json | event="greeting"

# All container logs
{service="app"}
```

## How It Works

1. **Application Logging**: The FastAPI app writes structured JSON logs to stdout using `print()`. Docker automatically captures stdout/stderr from containers.

2. **Log Collection (Promtail)**: Promtail uses Docker service discovery (`docker_sd_configs`) to find running containers and read their logs via the Docker API. It adds labels like container name and service.

3. **Log Storage (Loki)**: Promtail sends logs to Loki, which indexes them by labels and stores the log content efficiently.

4. **Visualization (Grafana)**: Grafana queries Loki and displays logs in a user-friendly interface with filtering and search capabilities.

## Stopping the Stack

```bash
docker compose down
```

To also remove the Grafana data volume:

```bash
docker compose down -v
```

## Troubleshooting

### Logs not appearing in Grafana

1. Check if all containers are running:
   ```bash
   docker compose ps
   ```

2. Check Promtail logs:
   ```bash
   docker compose logs promtail
   ```

3. Check if Loki is receiving logs:
   ```bash
   curl http://localhost:3100/ready
   ```

4. Verify the app is generating logs:
   ```bash
   docker compose logs app
   ```

### Connection refused errors

Make sure all services are on the same Docker network (`loki`).

## Services Overview

| Service   | Port | Description                    |
|-----------|------|--------------------------------|
| app       | 8000 | FastAPI application            |
| loki      | 3100 | Log aggregation database       |
| promtail  | -    | Log collector (no exposed port)|
| grafana   | 3000 | Visualization dashboard        |
