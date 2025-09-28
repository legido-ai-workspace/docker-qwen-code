# Stage 1: Build the application
FROM node:bookworm-slim AS builder

# Install only what's needed to clone and build
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Allow specifying a branch, tag, or commit at build time
ARG QWEN_COMMIT=main

# Clone and checkout - use --depth 1 for efficiency if using branches/tags
# (If using full SHAs, you may need to remove --depth 1 or fetch explicitly)
RUN git clone --depth 1 https://github.com/QwenLM/qwen-code.git . \
    && git checkout "${QWEN_COMMIT}"

# Install and globally link the package
RUN npm install
RUN npm install -g .

# Stage 2: Runtime image with Docker-in-Docker support
FROM node:bookworm-slim

# Argument for the Docker group ID, which we will pass in during the build
ARG DOCKER_GID

# Install necessary packages first
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git build-essential python3 python3-pip curl ca-certificates gnupg lsb-release locales python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean && \
    echo 'Acquire::Check-Valid-Until false;' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::Check-Date false;' > /etc/apt/apt.conf.d/99no-check-date

# Install Docker CLI with fixed GPG keys
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Set up Docker group and add node user to it
RUN groupadd -g ${DOCKER_GID:-999} docker && \
    usermod -aG docker node

# Copy global npm modules and binaries from the builder stage
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/qwen /usr/local/bin/qwen

# Set up directories
RUN mkdir -p /projects /qwen_data && \
    chown -R node:node /projects /qwen_data

# Optional: Create non-root user for security
RUN groupadd --system --gid 1001 appuser && \
    useradd --system --uid 1001 --gid 1001 --shell /sbin/nologin --home /app appuser && \
    mkdir -p /app && \
    chown appuser:appuser /app

# Change ownership of the application files
RUN chown -R appuser:appuser /usr/local/lib/node_modules /usr/local/bin/qwen

# Switch to non-root user
USER appuser

WORKDIR /projects

COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER appuser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]