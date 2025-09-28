# Docker Qwen Code

Docker container to run [Qwen Code](https://github.com/QwenLM/Qwen) safely in an isolated environment.

Qwen Code is an AI coding assistant that helps developers write code more efficiently. This Docker image provides a secure and consistent environment to run Qwen Code with all necessary dependencies pre-installed.

## Features

- Isolated environment for running Qwen Code with multi-stage build optimization
- Pre-installed Docker CLI for containerized development (Docker-in-Docker support)
- Optimized image size through multi-stage build process
- Easy volume mounting for project files
- Configurable GitHub App integration for repository access
- Health checks for container status monitoring
- Non-root user security model

## Prerequisites

- Docker installed on your system
- Docker Compose (v2.0 or higher)
- Access to a GitHub App or Personal Access Token (PAT) for repository operations

## Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Configure the environment variables in `.env`:
   
   ### GitHub Authentication (Choose one)
   
   For GitHub App authentication:
   ```env
   GITHUB_APP_ID=your_github_app_id
   GITHUB_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
YOUR_KEY_HERE
-----END RSA PRIVATE KEY-----"
   GITHUB_INSTALLATION_ID=your_installation_id
   ```
   
   For Personal Access Token (classic):
   ```env
   GITHUB_PAT=your_personal_access_token
   ```
   
   ### Docker Group ID
   Get your Docker group ID:
   ```bash
   getent group docker | cut -d: -f3
   ```
   
   If the value is different from the default (998), set the `DOCKER_GID` variable:
   ```env
   DOCKER_GID=your_docker_gid
   ```
   
   ### Volume Mounts
   Adjust the volume paths as needed:
   ```env
   VOLUME_CONFIG=/path/to/qwen/config
   VOLUME_PROJECTS=/path/to/your/projects
   ```

## Running from GHCR

You can run the Docker container directly from GitHub Container Registry without building it locally:

1. Pull the image:
   ```bash
   docker pull ghcr.io/legido-ai-workspace/docker-qwen-code:latest
   ```

2. Run the container with volume mounts:
   ```bash
   docker run -it --rm \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v $HOME/.qwen:/home/node/.qwen \
     -v $PWD:/projects \
     ghcr.io/legido-ai-workspace/docker-qwen-code:latest \
     qwen
   ```

3. Or start it as a daemon:
   ```bash
   docker run -d \
     --name qwen-code \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v $HOME/.qwen:/home/node/.qwen \
     -v $PWD:/projects \
     ghcr.io/legido-ai-workspace/docker-qwen-code:latest
   ```

   Then access it with:
   ```bash
   docker exec -ti qwen-code qwen
   ```

## Build

Build the Docker image with:
```bash
docker build -t qwen-code:latest .
```

Or use the provided build script:
```bash
./build.sh --tag latest --push
```

Or use the Makefile:
```bash
make build
```

### Multi-stage Build Benefits

This image uses a multi-stage build process that:

- Separates the build environment (with all build tools) from the runtime environment
- Reduces the final image size by only including necessary runtime dependencies
- Improves security by minimizing the attack surface in the final image
- Ensures better layer caching for faster builds

### Build

Build the Docker image with:
```bash
# Get Docker group ID
DOCKER_GID=$(getent group docker | cut -d: -f3)

# Build the image
docker build --build-arg DOCKER_GID=$DOCKER_GID -t ghcr.io/legido-ai-workspace/docker-qwen-code:latest .
```

### Multi-stage Build Benefits

This image uses a multi-stage build process that:

- Separates the build environment (with all build tools) from the runtime environment
- Reduces the final image size by only including necessary runtime dependencies
- Improves security by minimizing the attack surface in the final image
- Ensures better layer caching for faster builds

## GitHub Actions Integration

The project includes a GitHub Actions workflow (`.github/workflows/docker.yml`) that automatically builds and pushes the image to GitHub Container Registry when changes are pushed to the main branch.

## Usage

1. Start the container:
   ```bash
   docker run -d --name qwen-code -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/projects qwen-code:latest
   ```

2. Access the Qwen Code CLI:
   ```bash
   docker exec -ti qwen-code qwen
   ```

3. For interactive shell access:
   ```bash
   docker exec -ti qwen-code /bin/bash
   ```

## Docker-in-Docker (DinD) Usage

To use Docker commands inside the container:

1. Run the container with access to the Docker socket:
   ```bash
   docker run -d --name qwen-code \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v $HOME/.qwen:/home/node/.qwen \
     -v $PWD:/projects \
     qwen-code:latest
   ```

2. Execute Docker commands inside the container:
   ```bash
   docker exec -ti qwen-code docker ps
   ```

## Update

To update to the latest version:
```bash
docker build --no-cache -t qwen-code:latest .
docker stop qwen-code
docker rm qwen-code
docker run -d --name qwen-code -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/projects qwen-code:latest
```

## Volumes

The container mounts these volumes by default:
- `/projects`: Your local project files
- `/qwen_data`: Qwen data storage (optional)

## GitHub Integration

The container supports both GitHub App and Personal Access Token authentication for repository operations. Configure the appropriate environment variables in your `.env` file.

For GitHub App permissions required:
- Repository permissions: Administration (Read and write)
- Contents: Read and write
- Packages: Read and write
- Workflows: Read and write

For PAT permissions required:
- `write:packages`
- `delete:packages`

## Security

- The application runs as a non-root user (appuser) for enhanced security
- The Docker image uses a minimal base (node:bookworm-slim) to reduce the attack surface
- Multi-stage build ensures only runtime dependencies are included in the final image

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Qwen Code is licensed under separate terms - see [QwenLM/Qwen](https://github.com/QwenLM/Qwen) for details.