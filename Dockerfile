FROM node:20-bookworm

# -----------------------------------------------------------------------------
# 1. Run all system-level installations as the root user.
# -----------------------------------------------------------------------------
# This includes installing packages from apt-get and npm's global packages.
# Global npm packages are installed in a location accessible by all users.
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    zsh \
    fonts-powerline \
    locales \
    # Clean up APT caches to keep the image small
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g \
    @google/gemini-cli \
    typescript \
    tsx \
    nodemon \
    npm-check-updates \
    && npm cache clean --force

# -----------------------------------------------------------------------------
# 2. Create directories and set correct permissions BEFORE switching user.
# -----------------------------------------------------------------------------
# These directories need to be writable by the 'node' user.
# We create them as root and then change their ownership to 'node'.
# The 'node' user has UID 1000 and GID 1000 in the base image.
# -----------------------------------------------------------------------------
RUN mkdir -p /commandhistory /workspace \
    && chown -R node:node /commandhistory /workspace

# -----------------------------------------------------------------------------
# 3. Switch from the default 'root' user to the 'node' user.
# -----------------------------------------------------------------------------
# All subsequent commands will be run as 'node'.
# -----------------------------------------------------------------------------
USER node

# -----------------------------------------------------------------------------
# 4. Perform user-specific setup as the 'node' user.
# -----------------------------------------------------------------------------
# The working directory is now the node user's home directory.
# The home directory for the 'node' user is /home/node.
# -----------------------------------------------------------------------------
WORKDIR /home/node

# Set up command history for both bash and zsh in the node user's home directory
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && touch /commandhistory/.bash_history \
    && echo "$SNIPPET" >> "/home/node/.bashrc" \
    && echo "$SNIPPET" >> "/home/node/.zshrc"

# Set the WORKDIR to the workspace for the final container environment
WORKDIR /workspace

# Set up the entrypoint (this was already fine as it's an absolute path)
COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
