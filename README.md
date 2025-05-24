# Taskinity Render

[![npm version](https://img.shields.io/npm/v/taskinity-render.svg?style=flat-square)](https://www.npmjs.com/package/taskinity-render)
[![GitHub license](https://img.shields.io/github/license/taskinity/render?style=flat-square)](https://github.com/taskinity/render/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/taskinity/render?style=flat-square)](https://github.com/taskinity/render/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/taskinity/render?style=flat-square)](https://github.com/taskinity/render/issues)

A JavaScript library for rendering Taskinity flow diagrams and syntax highlighting in Markdown documents.

🔗 **Live Demo**: https://taskinity.github.io/render/

## Features

- 🎨 Automatic syntax highlighting for code blocks (Python, Bash, JavaScript, YAML, JSON, Markdown)
- 📊 Interactive flow diagram rendering for DSL code blocks
- 📋 Copy-to-clipboard buttons for code blocks
- 🔢 Line numbering for code blocks
- 🎨 Theme support
- 📦 Lightweight and easy to integrate

## Installation

### Using npm

```bash
npm install taskinity-render
```

### Using CDN

```html
<!-- Load Taskinity Render from CDN -->
<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>

<!-- Initialize after the script is loaded -->
<script>
  document.addEventListener('DOMContentLoaded', () => {
    window.taskinityRender = new TaskinityRender({
      theme: 'github',
      lineNumbers: true,
      copyButton: true
    });
  });
</script>
```

## Usage

### Basic Usage

#### Option 1: Using a module bundler (recommended)

```javascript
import TaskinityRender from 'taskinity-render';

// Initialize with options
const taskinityRender = new TaskinityRender({
  theme: 'github',
  lineNumbers: true,
  copyButton: true
});
```

#### Option 2: Using a script tag with CDN

Add the following code to your HTML document, just before the closing `</body>` tag:

```html
<script>
  // Configuration object
  window.taskinityRenderConfig = {
    theme: 'github',
    lineNumbers: true,
    copyButton: true
  };

  // Error handler
  function handleScriptError(error) {
    console.error('Error loading Taskinity Render:', error);
    // Show error message to the user
    const errorDiv = document.createElement('div');
    errorDiv.style.cssText = 'background: #ffebee; border-left: 4px solid #f44336; color: #b71c1c; padding: 1em; margin: 1em 0; border-radius: 4px;';
    errorDiv.innerHTML = `
      <h3 style="margin-top: 0;">Error loading Taskinity Render</h3>
      <p>Failed to load the Taskinity Render script. Please check the following:</p>
      <ol>
        <li>Make sure you're connected to the internet</li>
        <li>Check the browser's console for detailed error messages</li>
        <li>Try refreshing the page</li>
      </ol>
    `;
    document.body.insertBefore(errorDiv, document.body.firstChild);
  }

  // Load the script
  document.addEventListener('DOMContentLoaded', function() {
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js';
    script.onerror = () => handleScriptError(new Error('Failed to load script'));
    script.onload = function() {
      try {
        if (typeof TaskinityRender === 'function') {
          window.taskinityRender = new TaskinityRender(window.taskinityRenderConfig);
          console.log('Taskinity Render initialized successfully!');
        } else {
          throw new Error('TaskinityRender is not defined');
        }
      } catch (error) {
        handleScriptError(error);
      }
    };
    document.head.appendChild(script);
  });
</script>
```

### For Markdown Content

If you're using Markdown, make sure your DSL code blocks are wrapped with triple backticks and marked with the `dsl` language:

```dsl
flow EmailProcessing:
    description: "Email Processing Flow"
    fetch_emails -> classify_emails
    classify_emails -> process_urgent_emails
    classify_emails -> process_regular_emails
```

### For HTML Content

If you're writing HTML directly, use the following format:

```html
<pre><code class="language-dsl">flow EmailProcessing:
    description: "Email Processing Flow"
    fetch_emails -> classify_emails
    classify_emails -> process_urgent_emails
    classify_emails -> process_regular_emails</code></pre>
```

## Example

Here's an example of a DSL flow that will be automatically rendered as a diagram:

```dsl
flow EmailProcessing:
    description: "Email Processing Flow"
    fetch_emails -> classify_emails
    classify_emails -> process_urgent_emails
    classify_emails -> process_regular_emails
```

Biblioteka automatycznie wygeneruje interaktywny diagram przepływu.

## Configuration

Można dostosować działanie biblioteki:

```html
<script>
  document.addEventListener('DOMContentLoaded', () => {
    window.taskinityRender = new TaskinityRender({
      theme: 'default',
      lineNumbers: true,
      copyButton: true
    });
  });
</script>
```

## Development

### Using npm

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Run linter
npm run lint

# Start local server for testing
npm start
```

### Using Makefile

The project includes a Makefile with useful commands for development and deployment:

```bash
# Show help and available commands
make help

# Install dependencies
make install

# Build the package
make build

# Run tests
make test

# Run linter
make lint

# Start local development server (port 9999)
make serve

# Bump version (interactive, asks for patch/minor/major)
make version

# Bump patch version automatically
make patch-version

# Publish to GitHub Pages
make publish-github

# Publish to npm
make publish-npm

# Publish to both npm and GitHub Pages (runs patch-version, publish-npm, and publish-github)
make publish

# Stage, commit, and push changes to GitHub (interactive commit message)
make push

# Clean build artifacts and node_modules
make clean

# Run diagnostic tests
make diagnostic
```

### Development Workflow

1. Install dependencies:
   ```bash
   make install
   ```

2. Make your changes to the source code in the `src` directory

3. Run the development server to test your changes:
   ```bash
   make serve
   ```
   Then open http://localhost:9999 in your browser

4. When ready to publish:
   ```bash
   make publish
   ```
   This will bump the version, publish to npm, and update GitHub Pages.

## Links

- [NPM Package](https://www.npmjs.com/package/taskinity-render)
- [GitHub Repository](https://github.com/taskinity/render)
- [Live Demo](https://taskinity.github.io/render/)

## Troubleshooting

### Common Issues

#### 1. "TaskinityRender is not defined" Error
This error occurs when the script fails to load or initialize properly. Here's how to fix it:

1. **Check the script source**
   - Verify the path to the script is correct
   - If using a CDN, make sure the URL is accessible
   - If hosting locally, ensure the file exists in the specified location

2. **Check the browser's console**
   - Look for any network errors (404, CORS issues, etc.)
   - Check for syntax errors in your JavaScript code

3. **Loading order**
   - Make sure the script is loaded before you try to use `TaskinityRender`
   - Use the `DOMContentLoaded` event as shown in the examples

#### 2. Script Loading Issues

If the script fails to load:
- Check your internet connection
- Try clearing your browser cache (Ctrl+F5 or Cmd+Shift+R)
- Verify the CDN URL is correct
- Consider downloading the script and hosting it yourself

#### 3. Styling Issues

If the diagrams or syntax highlighting don't look correct:
- Make sure you've included the necessary CSS files
- Check for CSS conflicts with your existing styles
- Verify that the theme you're using is valid

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/taskinity/render.git
cd render

# Install dependencies
npm install

# Build the project
npm run build

# Start the development server
npm start
```

### Testing

```bash
# Run tests
npm test

# Run linter
npm run lint
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.


<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>