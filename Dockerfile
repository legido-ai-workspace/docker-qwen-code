FROM node:20-bookworm

# Argument for the Docker group ID, which we will pass in during the build
ARG DOCKER_GID

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git build-essential python3 python3-pip curl ca-certificates gnupg lsb-release zsh fonts-powerline locales

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
    @google/gemini-cli@latest typescript tsx nodemon npm-check-updates \
    && npm cache clean --force \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /commandhistory /workspace \
    && chown -R node:node /commandhistory /workspace

USER node

WORKDIR /home/node

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && touch /commandhistory/.bash_history \
    && echo "$SNIPPET" >> "/home/node/.bashrc" \
    && echo "$SNIPPET" >> "/home/node/.zshrc"

WORKDIR /workspace

COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
