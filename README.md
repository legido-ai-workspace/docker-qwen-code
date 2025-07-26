# docker-gemini-cli

Docker container to run Gemini CLI safely

# Configuration

1. Get '.env' file:

```
cp .env.example .env
```

2. adjust settings that you want to use.

For instance get GID used by docker:

```
getent group docker | cut -d: -f3
```

And if the value is different from default one (998) set variable `DOCKER_GID`

# Build

```
docker compose build --no-cache
```

# Execute

1. Start docker container

```
docker compose up -d
```

2. Run Gemini Cli

```
docker exec -ti gemini-cli gemini
```

# Update

```
docker compose down
docker compose build --no-cache
docker compose up -d
```
