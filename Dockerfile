FROM node

# Argument for the Docker group ID, which we will pass in during the build
ARG DOCKER_GID

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git build-essential python3 python3-pip curl ca-certificates gnupg lsb-release locales python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Add Docker's official GPG key and repo
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
       | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && groupadd -g ${DOCKER_GID:-999} docker \
    && usermod -aG docker node

# Clone repo into a clean directory (e.g., /qwen-code)
WORKDIR /qwen-code
RUN git clone --depth 1 https://github.com/QwenLM/qwen-code.git . \
    && git checkout main

# Install and globally link the package
RUN npm install
RUN npm install -g .

# Set up runtime directories
RUN mkdir -p /projects /qwen_data \
    && chown -R node:node /projects /qwen_data

USER node

WORKDIR /projects

COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
