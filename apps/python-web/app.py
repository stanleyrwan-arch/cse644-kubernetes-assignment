import datetime as dt
import os
import socket
from pathlib import Path

from flask import Flask, jsonify, request

app = Flask(__name__)
DATA_FILE = Path("/data/message.txt")


@app.get("/")
def index():
    return jsonify(
        service="cse644-python-web-kubernetes",
        student="ZIZE WAN",
        greeting=os.getenv("GREETING", "CSE644 Kubernetes Assignment"),
        environment=os.getenv("ENVIRONMENT", "local"),
        secret_configured=bool(os.getenv("DEMO_SECRET")),
        timestamp=dt.datetime.now(dt.timezone.utc).isoformat(),
        hostname=socket.gethostname(),
    )


@app.get("/health")
def health():
    return jsonify(status="healthy"), 200


@app.get("/data")
def get_data():
    if not DATA_FILE.exists():
        return jsonify(message=None), 200
    return jsonify(message=DATA_FILE.read_text(encoding="utf-8").strip()), 200


@app.post("/data")
def write_data():
    payload = request.get_json(silent=True) or {}
    message = payload.get("message", "persistent-data-written-by-cse644")
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    DATA_FILE.write_text(message, encoding="utf-8")
    return jsonify(message=message, status="stored"), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)
