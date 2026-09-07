# Container base — pin the digest, not the tag
FROM ubuntu:24.04@sha256:1e0a86e57d247923571b75e0aaf48a1449cf8c543d51fb3e07a4a7d7bfa79316
RUN apt-get update && apt-get install -y --no-install-recommends \
python3.12 python3.12-venv python3-pip \
git curl jq make build-essential \
ca-certificates gnupg \
&& rm -rf /var/lib/apt/lists/*

# Non-root by default

RUN useradd -m -o -u 1000 ases
USER ases
WORKDIR /home/ases
