# ---------- Stage 1: Builder ----------
FROM python:3.12-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .

# Install all dependencies to a prefix directory
RUN pip install --no-cache-dir --prefix=/opt/app -r requirements.txt

# ---------- Stage 2: Runtime ----------
FROM python:3.12-slim-bookworm AS runtime

WORKDIR /app

# Copy only the installed packages, not pip cache or build artifacts
COPY --from=builder /opt/app /opt/app

# Set Python path to find the installed packages
ENV PYTHONPATH=/opt/app/lib/python3.12/site-packages

COPY . .

EXPOSE 9001

ENTRYPOINT ["python", "recommendation_server.py"]
