#!/bin/bash

# Test script to validate Docker setup
set -e

echo "Validating Docker setup..."

# Check if Dockerfile exists and is readable
if [ ! -f Dockerfile ]; then
    echo "ERROR: Dockerfile not found!"
    exit 1
else
    echo "✓ Dockerfile exists"
fi

# Check if docker-compose.yml exists and is readable
if [ ! -f docker-compose.yml ]; then
    echo "ERROR: docker-compose.yml not found!"
    exit 1
else
    echo "✓ docker-compose.yml exists"
fi

# Check if build script exists and is executable
if [ ! -f build.sh ]; then
    echo "ERROR: build.sh not found!"
    exit 1
elif [ ! -x build.sh ]; then
    echo "ERROR: build.sh is not executable!"
    exit 1
else
    echo "✓ build.sh exists and is executable"
fi

# Check if Makefile exists
if [ ! -f Makefile ]; then
    echo "ERROR: Makefile not found!"
    exit 1
else
    echo "✓ Makefile exists"
fi

# Check if .dockerignore exists
if [ ! -f .dockerignore ]; then
    echo "ERROR: .dockerignore not found!"
    exit 1
else
    echo "✓ .dockerignore exists"
fi

# Validate Dockerfile syntax (basic check)
if grep -q "FROM node:" Dockerfile; then
    echo "✓ Dockerfile contains base image specification"
else
    echo "WARNING: Dockerfile might not contain base image specification"
fi

# Validate build script content
if grep -q "docker build" build.sh && grep -q "DOCKER_GID" build.sh; then
    echo "✓ build.sh contains relevant docker build commands and DOCKER_GID handling"
else
    echo "WARNING: build.sh might not contain expected content"
fi

# Validate GitHub workflow
if [ -f .github/workflows/docker.yml ]; then
    if grep -q "docker/build-push-action" .github/workflows/docker.yml; then
        echo "✓ GitHub workflow contains docker build-push action"
    else
        echo "WARNING: GitHub workflow might not contain expected content"
    fi
else
    echo "ERROR: GitHub workflow file not found!"
    exit 1
fi

echo ""
echo "Validation completed successfully!"
echo ""
echo "The Docker setup includes:"
echo "- Dockerfile with multi-stage build for Qwen Code"
echo "- docker-compose.yml for easier container management"
echo "- build.sh script for building and pushing images"
echo "- Makefile with convenient targets"
echo "- GitHub Actions workflow for automated builds"
echo "- .dockerignore to exclude unnecessary files from build context"