# Makefile for Taskinity Render package

.PHONY: help install build test lint serve push publish publish-github publish-npm version clean diagnostic \
      gh-check gh-issues gh-issue-new gh-issue-close gh-issue-view

# Variables
DIST_DIR = dist
SRC_DIR = src
EXAMPLES_DIR = examples
GITHUB_PAGES_DIR = /tmp/taskinity-pages
SERVER_PORT = 9999
REPO_OWNER = taskinity
REPO_NAME = render

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

## Display help information
help:
	@echo "Taskinity Render Makefile"
	@echo ""
	@echo "${YELLOW}Project Commands:${RESET}"
	@echo "  ${GREEN}help${RESET}             - Display this help message"
	@echo "  ${GREEN}install${RESET}          - Install dependencies"
	@echo "  ${GREEN}build${RESET}            - Build package"
	@echo "  ${GREEN}test${RESET}             - Run tests"
	@echo "  ${GREEN}lint${RESET}             - Run linter"
	@echo "  ${GREEN}serve${RESET}            - Start local server for testing"
	@echo "  ${GREEN}version${RESET}          - Bump package version (patch, minor, major)"
	@echo "  ${GREEN}clean${RESET}            - Clean build artifacts"
	@echo "  ${GREEN}diagnostic${RESET}       - Run diagnostic tests"
	@echo ""
	@echo "${YELLOW}GitHub & Publishing:${RESET}"
	@echo "  ${GREEN}push${RESET}             - Push changes to GitHub"
	@echo "  ${GREEN}publish${RESET}          - Publish to both npm and GitHub"
	@echo "  ${GREEN}publish-github${RESET}   - Publish to GitHub Pages"
	@echo "  ${GREEN}publish-npm${RESET}      - Publish to npm"
	@echo ""
	@echo "${YELLOW}GitHub Issues:${RESET}"
	@echo "  ${GREEN}gh-check${RESET}         - Check if GitHub CLI is installed"
	@echo "  ${GREEN}gh-issues${RESET}        - List all open issues"
	@echo "  ${GREEN}gh-issue-new${RESET}     - Create a new issue (TITLE='title' BODY='body' LABELS='bug,enhancement')"
	@echo "  ${GREEN}gh-issue-close${RESET}   - Close an issue (ISSUE=123)"
	@echo "  ${GREEN}gh-issue-view${RESET}    - View issue details (ISSUE=123)"

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
	git tag -l
	@echo "Current version: $$(npm version | grep taskinity-render | cut -d\' -f4)"
	@echo "Specify version bump type (patch, minor, major):"
	@read TYPE && npm version $$TYPE
	@echo "New version: $$(npm version | grep taskinity-render | cut -d\' -f4)"

patch-version:
	@echo "Current version: $$(npm version | grep taskinity-render | cut -d\' -f4)"
	npm version patch
	@echo "New version: $$(npm version | grep taskinity-render | cut -d\' -f4)"

## Publish to GitHub Pages
publish-github:
	@echo "Building package for GitHub Pages..."
	npm run build
	
	@echo "Checking if GitHub Pages directory exists..."
	@if [ ! -d "$(GITHUB_PAGES_DIR)" ]; then \
		echo "Creating GitHub Pages directory..."; \
		mkdir -p $(GITHUB_PAGES_DIR); \
		cd $(GITHUB_PAGES_DIR) && git init && \
		echo "# Taskinity GitHub Pages" > README.md && \
		git add README.md && \
		git commit -m "Initial commit"; \
	else \
		echo "Updating local repository..."; \
		cd $(GITHUB_PAGES_DIR) && git pull origin main || true; \
	fi
	
	@echo "Creating necessary directories..."
	@mkdir -p $(GITHUB_PAGES_DIR)/render
	
	@echo "Copying built files..."
	cp -r $(DIST_DIR)/* $(GITHUB_PAGES_DIR)/render/
	
	@echo "Copying examples..."
	@mkdir -p $(GITHUB_PAGES_DIR)/render/examples
	cp -r examples/* $(GITHUB_PAGES_DIR)/render/examples/
	
	@echo "Creating or updating index.html..."
	@# Create a simple index.html that redirects to /render/
	@echo '<!DOCTYPE html><html><head>' > $(GITHUB_PAGES_DIR)/index.html
	@echo '<meta charset="UTF-8">' >> $(GITHUB_PAGES_DIR)/index.html
	@echo '<meta http-equiv="refresh" content="0; url=/render/" />' >> $(GITHUB_PAGES_DIR)/index.html
	@echo '<title>Taskinity Render</title>' >> $(GITHUB_PAGES_DIR)/index.html
	@echo '</head><body>' >> $(GITHUB_PAGES_DIR)/index.html
	@echo '<p>Redirecting to <a href="/render/">Taskinity Render</a>...</p>' >> $(GITHUB_PAGES_DIR)/index.html
	@echo '</body></html>' >> $(GITHUB_PAGES_DIR)/index.html
	
	@echo "Committing and pushing changes..."
	@cd $(GITHUB_PAGES_DIR) && \
	git add . && \
	git commit -m "Update Taskinity Render to version $$(node -p 'require("../package.json").version')" || echo "No changes to commit" && \
	if ! git remote get-url origin > /dev/null 2>&1; then \
		echo "Adding remote origin..."; \
		git remote add origin https://github.com/taskinity/taskinity.github.io.git; \
	fi && \
	git push -u origin main || (echo "Could not push to GitHub. Please make sure you have created the repository at https://github.com/taskinity/taskinity.github.io and have the necessary permissions." && exit 1)
	
	@echo "\n✅ Published to GitHub Pages successfully!"
	@echo "🌐 You can access it at: https://taskinity.github.io/render/"
	@echo ""
	@echo "If you haven't already, you need to:"
	@echo "1. Create a new repository named 'taskinity.github.io' at https://github.com/organizations/taskinity/repositories/new"
	@echo "2. Make sure it's public"
	@echo "3. Then run 'make publish-github' again"

## Publish to both npm and GitHub Pages
publish: patch-version publish-npm publish-github
	@echo "Publish completed successfully!"

## Publish to npm
publish-npm:
	@echo "Building package for npm..."
	npm run build
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

## GitHub CLI Commands

## Check if GitHub CLI is installed
gh-check:
	@if ! command -v gh &> /dev/null; then \
		echo "GitHub CLI is not installed. Please install it from https://cli.github.com/"; \
		exit 1; \
	else \
		echo "✅ GitHub CLI is installed"; \
		gh --version; \
	fi

## List all open issues
gh-issues: gh-check
	@echo "${YELLOW}Listing open issues...${RESET}"
	@gh issue list --repo $(REPO_OWNER)/$(REPO_NAME)

## Create a new issue
## Usage: make gh-issue-new TITLE="Title" BODY="Description" [LABELS="bug,enhancement"]
gh-issue-new: gh-check
	@if [ -z "$(TITLE)" ]; then \
		echo "Error: TITLE is not set. Usage: make gh-issue-new TITLE=\"Title\" BODY=\"Description\" [LABELS=\"bug,enhancement\"]"; \
		exit 1; \
	fi
	@echo "${YELLOW}Creating new issue...${RESET}"
	@if [ -z "$(LABELS)" ]; then \
		gh issue create --title "$(TITLE)" --body "$(BODY)" --repo $(REPO_OWNER)/$(REPO_NAME); \
	else \
		gh issue create --title "$(TITLE)" --body "$(BODY)" --label "$(LABELS)" --repo $(REPO_OWNER)/$(REPO_NAME); \
	fi

## Close an issue
## Usage: make gh-issue-close ISSUE=123
gh-issue-close: gh-check
	@if [ -z "$(ISSUE)" ]; then \
		echo "Error: ISSUE number is not set. Usage: make gh-issue-close ISSUE=123"; \
		exit 1; \
	fi
	@echo "${YELLOW}Closing issue #$(ISSUE)...${RESET}"
	@gh issue close $(ISSUE) --repo $(REPO_OWNER)/$(REPO_NAME)

## View issue details
## Usage: make gh-issue-view ISSUE=123
gh-issue-view: gh-check
	@if [ -z "$(ISSUE)" ]; then \
		echo "Error: ISSUE number is not set. Usage: make gh-issue-view ISSUE=123"; \
		exit 1; \
	fi
	@gh issue view $(ISSUE) --repo $(REPO_OWNER)/$(REPO_NAME)
