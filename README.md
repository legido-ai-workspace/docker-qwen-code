# Docker Qwen Code

Docker container to run [Qwen Code](https://github.com/QwenLM/Qwen) safely in an isolated environment.

Qwen Code is an AI coding assistant that helps developers write code more efficiently. This Docker image provides a secure and consistent environment to run Qwen Code with all necessary dependencies pre-installed.

## Features

- Isolated environment for running Qwen Code
- Pre-installed Docker CLI for containerized development
- Easy volume mounting for project files
- Configurable GitHub App integration for repository access
- Health checks for container status monitoring

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
docker compose build --no-cache
```

## Usage

1. Start the container:
   ```bash
   docker compose up -d
   ```

2. Access the Qwen Code CLI:
   ```bash
   docker exec -ti qwen-code qwen
   ```

3. For interactive shell access:
   ```bash
   docker exec -ti qwen-code /bin/bash
   ```

## Update

To update to the latest version:
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Volumes

The container mounts two volumes by default:
- `/projects`: Your local project files
- `/home/node/.qwen`: Qwen configuration and data

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Qwen Code is licensed under separate terms - see [QwenLM/Qwen](https://github.com/QwenLM/Qwen) for details.