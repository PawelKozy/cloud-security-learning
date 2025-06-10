# Multi-stage Dockerfile template for a Python application
FROM python:3.11-slim AS base
WORKDIR /app

# Builder stage installs dependencies
FROM base AS builder
COPY requirements.txt ./
RUN pip install --prefix=/install -r requirements.txt

# Runtime stage uses minimal image
FROM gcr.io/distroless/python3-debian11
COPY --from=builder /install /usr/local
COPY . .
ENTRYPOINT ["python", "app.py"]
