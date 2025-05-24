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

```bash
npm install taskinity-render
```

lub bezpośrednio z CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>
```

## Usage

### Basic Usage

Add the following script tag to your HTML document, just before the closing `</body>` tag:

```html
<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>
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

### For Markdown Content

If you're using Markdown, make sure your DSL code blocks are wrapped with triple backticks and marked with the `dsl` language:

````markdown
```dsl
flow EmailProcessing:
    description: "Email Processing Flow"
    fetch_emails -> classify_emails
    classify_emails -> process_urgent_emails
    classify_emails -> process_regular_emails
```
````

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

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build
```

## Links

- [NPM Package](https://www.npmjs.com/package/taskinity-render)
- [GitHub Repository](https://github.com/taskinity/render)
- [Live Demo](https://taskinity.github.io/render/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.