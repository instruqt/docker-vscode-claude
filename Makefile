# docker-debug — multi-arch image build

IMAGE       ?= vscode-claude
TAG         ?= latest
REGISTRY    ?= gcr.io/instruqt
PLATFORMS   ?= linux/amd64,linux/arm64
BUILDER     ?= docker-debug-builder

# Prefix the image with the registry when one is set (note the trailing slash).
IMAGE_REF   := $(if $(REGISTRY),$(REGISTRY)/)$(IMAGE):$(TAG)

.DEFAULT_GOAL := build

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

.PHONY: builder
builder: ## Create/bootstrap the buildx builder (idempotent)
	@docker buildx inspect $(BUILDER) >/dev/null 2>&1 || \
		docker buildx create --name $(BUILDER) --driver docker-container --bootstrap

.PHONY: build
build: ## Build for the local arch and load into docker
	docker buildx build --load -t $(IMAGE_REF) .

.PHONY: buildx
buildx: builder ## Build multi-arch image (in-cache only, not loaded)
	docker buildx build --builder $(BUILDER) --platform $(PLATFORMS) -t $(IMAGE_REF) .

.PHONY: push
push: builder ## Build multi-arch image and push to the registry
	@test -n "$(REGISTRY)" || { echo "REGISTRY is required for push (e.g. make push REGISTRY=ghcr.io/you)"; exit 1; }
	docker buildx build --builder $(BUILDER) --platform $(PLATFORMS) -t $(IMAGE_REF) --push .

.PHONY: run
run: ## Run an interactive shell in the locally-built image
	docker run --rm -it $(IMAGE_REF)

.PHONY: clean
clean: ## Remove the buildx builder
	-docker buildx rm $(BUILDER)
