# Makefile for Taskinity Render package

.PHONY: help install build test lint serve push publish publish-github publish-npm version clean diagnostic

# Variables
DIST_DIR = dist
SRC_DIR = src
EXAMPLES_DIR = examples
GITHUB_PAGES_DIR = /tmp/taskinity-pages
SERVER_PORT = 9999

## Display help information
help:
	@echo "Taskinity Render Makefile"
	@echo ""
	@echo "Available commands:"
	@echo "  help             - Display this help message"
	@echo "  install          - Install dependencies"
	@echo "  build            - Build package"
	@echo "  test             - Run tests"
	@echo "  lint             - Run linter"
	@echo "  serve            - Start local server for testing"
	@echo "  version          - Bump package version (patch, minor, major) and create git tag"
	@echo "  publish-github   - Publish to GitHub Pages"
	@echo "  publish-npm      - Publish to npm"
	@echo "  clean            - Clean build artifacts"
	@echo "  diagnostic       - Run diagnostic tests"
	@echo "  push             - Push changes to GitHub"

## Install dependencies
install:
	@echo "Installing dependencies..."
	npm install

## Build package
build:
	@echo "Building package..."
	npm run build

## Run tests
test:
	@echo "Running tests..."
	@if [ -f "test/test.js" ]; then \
		npm test; \
	else \
		echo "No tests found. Create tests in the test/ directory."; \
	fi

## Run linter
lint:
	@echo "Running linter..."
	npm run lint

## Start local server for testing
serve:
	@echo "Starting local server on port $(SERVER_PORT)..."
	@mkdir -p $(EXAMPLES_DIR)
	python -m http.server $(SERVER_PORT)

## Get the current version from package.json
VERSION := $(shell node -p "require('./package.json').version")

## Bump package version (patch, minor, major) and create git tag
version: check-git-clean
	@echo "Current version: $(VERSION)"
	@echo "Enter version increment (patch, minor, major):"
	@read INCREMENT && \
	npm version $$INCREMENT --no-git-tag-version --force && \
	NEW_VERSION=$$(node -p "require('./package.json').version") && \
	git add --force package.json package-lock.json && \
	git commit -m "Bump version to v$$NEW_VERSION" && \
	git tag -a v$$NEW_VERSION -m "v$$NEW_VERSION" && \
	git push origin v$$NEW_VERSION && \
	git push && \
	echo "Version bumped to $$NEW_VERSION and tag v$$NEW_VERSION created"

## Check if git working directory is clean
check-git-clean:
	@if [ -n "$(shell git status --porcelain)" ]; then \
		echo "Error: Git working directory is not clean. Please commit or stash your changes first."; \
		exit 1; \
	fi

## Publish to GitHub Pages
publish-github:
	@echo "Building package for GitHub Pages..."
	npm run build
	@echo "Checking if GitHub Pages directory exists..."
	@if [ ! -d "$(GITHUB_PAGES_DIR)" ]; then \
	echo "Cloning taskinity.github.io repository..."; \
	git clone https://github.com/taskinity/taskinity.github.io.git $(GITHUB_PAGES_DIR); \
	else \
	echo "Updating taskinity.github.io repository..."; \
	cd $(GITHUB_PAGES_DIR) && git pull; \
	fi
	@echo "Creating render directory if it doesn't exist..."
	@mkdir -p $(GITHUB_PAGES_DIR)/render
	@echo "Copying built files to GitHub Pages repository..."
	cp $(DIST_DIR)/taskinity-render.min.js $(GITHUB_PAGES_DIR)/render/
	@echo "Committing and pushing changes..."
	@cd $(GITHUB_PAGES_DIR) && \
	git add render/taskinity-render.min.js && \
	git commit -m "Update render script to version $$(npm version | grep taskinity-render | cut -d\' -f4)" && \
	git push
	@echo "Published to GitHub Pages successfully!"

## Publish to both npm and GitHub Pages
publish: publish-npm publish-github
	@echo "Publish completed successfully!"

## Publish to npm
publish-npm: check-git-clean
	@echo "Current version: $(VERSION)"
	@echo "Building package for npm..."
	npm run build
	@echo "Publishing version $(VERSION) to npm..."
	npm publish

## Push changes to GitHub
push:
	@echo "Staging all changes..."
	git add .
	@echo "Enter commit message: "
	@read MSG && git commit -m "$$MSG"
	@echo "Pushing to GitHub..."
	git push
	@echo "Successfully pushed changes to GitHub!"

## Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(DIST_DIR)
	rm -rf node_modules

## Run diagnostic tests
diagnostic:
	@echo "Running diagnostic tests..."
	@echo "Checking Node.js version..."
	node --version
	@echo "Checking npm version..."
	npm --version
	@echo "Checking package.json..."
	cat package.json | grep -e "name" -e "version" -e "main" -e "scripts"
	@echo "Checking webpack config..."
	cat webpack.config.js | grep -e "entry" -e "output"
	@echo "Checking distribution files..."
	ls -la $(DIST_DIR)
	@echo "Checking file sizes..."
	du -h $(DIST_DIR)/*
	@echo "Checking if script is valid JavaScript..."
	node -c $(DIST_DIR)/taskinity-render.min.js 2>/dev/null && echo "✅ Script is valid JavaScript" || echo "❌ Script has syntax errors"
	@echo "Diagnostic tests completed. No HTML file was created as it has been removed from the Makefile."
