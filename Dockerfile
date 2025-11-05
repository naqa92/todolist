# Use a specific version and multi-stage build for better security
FROM python:3.13-slim AS builder

WORKDIR /app

# Install uv
RUN pip install --no-cache-dir uv

# Copy pyproject.toml for dependency resolution
COPY app/pyproject.toml ./

# Create virtual environment and install dependencies
RUN uv venv /opt/venv && \
  . /opt/venv/bin/activate && \
  uv pip install -r pyproject.toml

# Production stage
FROM python:3.13-slim

WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends curl=8.14.1-2 && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy Python packages and application code
COPY --from=builder /opt/venv /opt/venv
COPY app/ ./

# Change ownership of the app directory
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 5000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

ENV PATH="/opt/venv/bin:$PATH"

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]