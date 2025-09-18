FROM node:20-bookworm

# Argument for the Docker group ID, which we will pass in during the build
ARG DOCKER_GID

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm

RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && groupadd -g ${DOCKER_GID:-999} docker \
    && usermod -aG docker node

RUN npm install -g \
    @qwen-code/qwen-code@latest \
    && npm cache clean --force \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /projects /qwen_data \
    && chown -R node:node /projects /qwen_data

USER node

WORKDIR /projects

COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
