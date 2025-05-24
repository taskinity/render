# Contributing to Taskinity Render

Thank you for your interest in contributing to the Taskinity Render library! This document provides guidelines and instructions for developing and publishing the JavaScript rendering library.

## Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Using Makefile](#using-makefile)
- [Building](#building)
- [Testing](#testing)
- [Diagnostics](#diagnostics)
- [Publishing Process](#publishing-process)
- [Code Style](#code-style)

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/taskinity/render.git
   cd render
   ```

2. Install dependencies:
   ```bash
   make install
   # or npm install
   ```

3. Start development server:
   ```bash
   make serve
   # or npm run dev
   ```

## Project Structure

The project is structured as follows:

```
render/
├── dist/                 # Built distribution files
├── src/                  # Source code
│   └── index.js          # Main entry point
├── examples/             # Example files for testing
├── package.json          # Project configuration
└── webpack.config.js     # Build configuration
```

## Development Workflow

1. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes to files in the `src` directory

3. Test your changes by running a local server:
   ```bash
   make serve
   ```
   Then open `http://localhost:9999/examples/index.html` in your browser

4. Run linting to ensure code quality:
   ```bash
   make lint
   ```

5. Build the production version:
   ```bash
   make build
   ```

6. Commit your changes:
   ```bash
   git add .
   git commit -m "Add feature: description of your changes"
   ```

7. Push your branch and create a pull request

## Using Makefile

The project includes a Makefile with various commands to simplify development:

```bash
# Display all available commands
make help

# Install dependencies
make install

# Build the project
make build

# Run tests
make test

# Run linter
make lint

# Start local server
make serve

# Update version
make version

# Publish to GitHub Pages
make publish-github

# Publish to npm
make publish-npm

# Clean build artifacts
make clean

# Run diagnostics
make diagnostic
```

## Building

To build the production version of the library:

```bash
make build
# or npm run build
```

This will create minified JavaScript files in the `dist` directory.

## Testing

To run tests:

```bash
make test
# or npm test
```

## Diagnostics

To run diagnostics and verify that everything is working correctly:

```bash
make diagnostic
```

This will:
- Check Node.js and npm versions
- Verify package.json and webpack configuration
- Check distribution files and sizes
- Validate JavaScript syntax
- Create a test HTML file
- Provide instructions for testing

## Publishing Process

### Publishing to GitHub Pages

The easiest way to publish to GitHub Pages is using the Makefile:

```bash
# Update version first
make version

# Publish to GitHub Pages
make publish-github
```

This will:
1. Build the production version
2. Clone or update the taskinity.github.io repository
3. Copy the built files to the repository
4. Commit and push the changes

Alternatively, you can do it manually:

```bash
# Update version
npm version patch  # or minor, or major

# Build the production version
npm run build

# Copy to GitHub Pages repository
cp dist/taskinity-render.min.js /path/to/taskinity.github.io/render/
cd /path/to/taskinity.github.io
git add render/taskinity-render.min.js
git commit -m "Update render script to version X.Y.Z"
git push
```

You can also use GitHub Actions for automatic deployment:

```bash
# Push to main branch to trigger GitHub Actions workflow
git push origin main
```

### Publishing to npm

To publish the package to npm:

```bash
# Using Makefile
make publish-npm
```

Or manually:

```bash
# Make sure you're logged in to npm
npm login

# Update version
npm version patch  # or minor, or major

# Build and publish
npm run build
npm publish
```

## Code Style

- Follow ESLint configuration
- Use modern JavaScript features (ES6+)
- Document all public functions and classes with JSDoc
- Keep the code simple and maintainable

## Documentation

When making changes, please update the relevant documentation:

- Update README.md if you change user-facing features
- Update JSDoc comments for any modified functions
- Add examples for new features

## GitHub Actions

This repository uses GitHub Actions for continuous integration and deployment:

- **CI Workflow**: Runs tests on every push and pull request
- **Publish Workflow**: Automatically publishes to GitHub Pages when changes are pushed to the main branch

## Questions?

If you have any questions about contributing, please open an issue or contact the maintainers.

Thank you for contributing to Taskinity Render!
