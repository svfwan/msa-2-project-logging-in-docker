import json
import sys
from datetime import datetime, timezone
from fastapi import FastAPI, Request

app = FastAPI(title="Logging Demo API")


def log(event: str, **kwargs) -> None:
    """Write structured JSON log to stdout (captured by Docker)."""
    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event": event,
        **kwargs,
    }
    print(json.dumps(entry), flush=True)


@app.get("/")
def root(request: Request):
    """Root endpoint - logs access event."""
    log("homepage_accessed", path="/", method="GET")
    return {"message": "Welcome to the Logging Demo API"}


@app.get("/hello/{name}")
def hello(name: str, request: Request):
    """Greeting endpoint - logs greeting event with name."""
    log("greeting", path=f"/hello/{name}", method="GET", name=name)
    return {"message": f"Hello, {name}!"}


@app.get("/health")
def health():
    """Health check endpoint."""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
