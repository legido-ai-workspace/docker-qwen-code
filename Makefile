# Makefile for Docker Qwen Code

# Default values
IMAGE_NAME ?= docker-qwen-code
REGISTRY ?= ghcr.io/legido-ai-workspace
TAG ?= latest
DOCKER_GID ?= $(shell getent group docker 2>/dev/null | cut -d: -f3 || echo 999)

# Full image name
IMAGE_FULL_NAME := $(REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: build push run stop exec shell test clean help

help: ## Show this help message
	@echo "usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "targets:"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(word 1,$(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg DOCKER_GID=$(DOCKER_GID) -t $(IMAGE_FULL_NAME) .

push: ## Push the Docker image to registry
	docker push $(IMAGE_FULL_NAME)

run: ## Run the container in detached mode
	docker run -d --name qwen-code \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(HOME)/.qwen:/home/node/.qwen \
		-v $(PWD):/projects \
		$(IMAGE_FULL_NAME)

stop: ## Stop and remove the running container
	docker stop qwen-code || true
	docker rm qwen-code || true

exec: ## Execute qwen command in the running container
	docker exec -ti qwen-code qwen

shell: ## Access shell in the running container
	docker exec -ti qwen-code /bin/bash

test: ## Run a quick test to verify the container works
	docker run --rm $(IMAGE_FULL_NAME) node --version

clean: ## Remove built images (use with caution)
	docker rmi -f $(IMAGE_FULL_NAME) || true

login: ## Login to GitHub Container Registry
	@echo "Enter your GitHub username and personal access token when prompted"
	docker login ghcr.io