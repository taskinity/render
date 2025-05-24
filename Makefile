# Makefile for Taskinity Render package

.PHONY: help install build test lint serve publish-github publish-npm version clean diagnostic

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
@echo "  version          - Bump package version (patch, minor, major)"
@echo "  publish-github   - Publish to GitHub Pages"
@echo "  publish-npm      - Publish to npm"
@echo "  clean            - Clean build artifacts"
@echo "  diagnostic       - Run diagnostic tests"

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
npm test

## Run linter
lint:
@echo "Running linter..."
npm run lint

## Start local server for testing
serve:
@echo "Starting local server on port $(SERVER_PORT)..."
@mkdir -p $(EXAMPLES_DIR)
python -m http.server $(SERVER_PORT)

## Bump package version (patch, minor, major)
version:
@echo "Current version: $$(npm version | grep taskinity-render | cut -d\' -f4)"
@echo "Specify version bump type (patch, minor, major):"
@read TYPE && npm version $$TYPE
@echo "New version: $$(npm version | grep taskinity-render | cut -d\' -f4)"

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

## Publish to npm
publish-npm:
@echo "Building package for npm..."
npm run build
@echo "Do you want to publish to npm? (y/n)"
@read CONFIRM && if [ $$CONFIRM = "y" ]; then npm publish; else echo "Publishing canceled"; fi

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
@echo "Using example HTML file for diagnostic test..."
@if [ -f "$(EXAMPLES_DIR)/index.html" ]; then \
	cp $(EXAMPLES_DIR)/index.html $(EXAMPLES_DIR)/diagnostic.html; \
	sed -i 's|https://taskinity.github.io/render/taskinity-render.min.js|../dist/taskinity-render.min.js|g' $(EXAMPLES_DIR)/diagnostic.html; \
	echo "Using existing example file for diagnostic"; \
else \
	echo "Example file not found, creating a simple diagnostic file"; \
	mkdir -p $(EXAMPLES_DIR); \
	echo '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Taskinity Render Diagnostic</title>
  <script src="../dist/taskinity-render.min.js"></script>
</head>
<body>
  <h1>Taskinity Render Diagnostic</h1>
  <pre><code>
flow TestFlow:
    description: "Test Flow"
    task1 -> task2
    task2 -> task3
  </code></pre>
</body>
</html>' > $(EXAMPLES_DIR)/diagnostic.html; \
fi
@echo "Diagnostic HTML file created at $(EXAMPLES_DIR)/diagnostic.html"
@echo "To view diagnostic results, run 'make serve' and open http://localhost:$(SERVER_PORT)/$(EXAMPLES_DIR)/diagnostic.html"
