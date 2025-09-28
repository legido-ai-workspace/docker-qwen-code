#!/bin/bash

# Script to build and optionally push the Docker image
set -e

# Default values
IMAGE_NAME="docker-qwen-code"
REGISTRY="ghcr.io/legido-ai-workspace"
TAG="latest"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --push)
            PUSH="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [--tag TAG] [--registry REGISTRY] [--image-name NAME] [--push]"
            echo ""
            echo "Options:"
            echo "  --tag        Docker image tag (default: latest)"
            echo "  --registry   Docker registry (default: ghcr.io/legido-ai-workspace)"
            echo "  --image-name Docker image name (default: docker-qwen-code)"
            echo "  --push       Push the image to registry after building (default: false)"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get Docker group ID for the build
DOCKER_GID=$(getent group docker | cut -d: -f3)
if [ -z "$DOCKER_GID" ]; then
    echo "Warning: Could not determine Docker group ID. Using default 999."
    DOCKER_GID=999
fi

echo "Building Docker image: $REGISTRY/$IMAGE_NAME:$TAG"
echo "Docker GID: $DOCKER_GID"

# Build the Docker image
docker build --build-arg DOCKER_GID=$DOCKER_GID -t $REGISTRY/$IMAGE_NAME:$TAG .

if [ "$PUSH" = "true" ]; then
    echo "Pushing Docker image to $REGISTRY/$IMAGE_NAME:$TAG"
    docker push $REGISTRY/$IMAGE_NAME:$TAG
fi

echo "Build completed successfully!"