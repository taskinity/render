/**
 * Taskinity Render - Simple renderer for Taskinity flow diagrams and syntax highlighting
 *
 * This single script handles:
 * 1. Syntax highlighting for code blocks (Python, Bash, etc.)
 * 2. Flow diagram rendering for DSL code blocks
 */

// Import Prism.js for syntax highlighting
import Prism from 'prismjs';

// Import Prism languages
import 'prismjs/components/prism-python';
import 'prismjs/components/prism-bash';
import 'prismjs/components/prism-javascript';
import 'prismjs/components/prism-yaml';
import 'prismjs/components/prism-json';
import 'prismjs/components/prism-markdown';

// Import Prism plugins
import 'prismjs/plugins/line-numbers/prism-line-numbers';
import 'prismjs/plugins/line-numbers/prism-line-numbers.css';

// Import Prism themes
import 'prismjs/themes/prism.css';

// DSL Flow Visualizer Class
class DSLFlowVisualizer {
  constructor(options = {}) {
    this.options = {
      codeBlockSelector: 'pre code.language-dsl, pre code.language-flow, pre code:not([class])',
      ...options,
    };

    this.init();
  }

  init() {
    // Add custom language definition for DSL
    this.defineDSLLanguage();

    // Find and process all DSL code blocks
    this.processDSLBlocks();

    // Add styles
    this.addStyles();
  }

  defineDSLLanguage() {
    // Define DSL syntax for Prism
    Prism.languages.dsl = {
      keyword: /\b(flow|task|description)\b/,
      arrow: /->/,
      string: /{(\w+)}|"([^"\\]|\\.)*"/,
      punctuation: /[{}:]/,
      comment: /#.*/,
    };

    // Register the language
    Prism.languages.flow = Prism.languages.dsl;
  }

  processDSLBlocks() {
    // Find all DSL code blocks
    const codeBlocks = document.querySelectorAll(this.options.codeBlockSelector);

    codeBlocks.forEach((codeBlock) => {
      const content = codeBlock.textContent.trim();

      // Check if this is a DSL block
      if (content.startsWith('flow ')) {
        // Add language class if not present
        if (!codeBlock.classList.contains('language-dsl')) {
          codeBlock.classList.add('language-dsl');
        }

        // Highlight the code
        Prism.highlightElement(codeBlock);

        // Create and add the diagram
        this.createDiagram(codeBlock, content);
      }
    });
  }

  createDiagram(codeBlock, dslContent) {
    // Parse the DSL content
    const flowData = this.parseDSL(dslContent);

    // Create diagram container
    const diagramContainer = document.createElement('div');
    diagramContainer.className = 'dsl-flow-diagram';

    // Create SVG diagram
    const svg = this.createSVG(flowData);
    diagramContainer.appendChild(svg);

    // Add download button
    const downloadBtn = document.createElement('button');
    downloadBtn.className = 'dsl-download-btn';
    downloadBtn.textContent = 'Download SVG';
    downloadBtn.addEventListener('click', () => this.downloadSVG(svg, flowData.name));
    diagramContainer.appendChild(downloadBtn);

    // Insert diagram after the code block
    const preElement = codeBlock.parentElement;
    preElement.parentNode.insertBefore(diagramContainer, preElement.nextSibling);
  }

  parseDSL(dslContent) {
    const lines = dslContent.split('\n');
    const flowData = {
      name: '',
      description: '',
      tasks: {},
      connections: [],
    };

    // Extract flow name
    const flowMatch = lines[0].match(/flow\s+(\w+):/);
    if (flowMatch) {
      flowData.name = flowMatch[1];
    }

    // Process each line
    let currentTask = null;

    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim();

      // Skip empty lines
      if (!line) continue;

      // Extract flow description
      if (line.startsWith('description:')) {
        flowData.description = line.split(':', 2)[1].trim().replace(/"/g, '');
        continue;
      }

      // Extract task connections
      const connectionMatch = line.match(/(\w+)\s*->\s*(\w+)/);
      if (connectionMatch) {
        const [_, source, target] = connectionMatch;
        flowData.connections.push({ source, target });

        // Add tasks if they don't exist
        if (!flowData.tasks[source]) {
          flowData.tasks[source] = { name: source };
        }
        if (!flowData.tasks[target]) {
          flowData.tasks[target] = { name: target };
        }

        continue;
      }

      // Extract task definition
      const taskMatch = line.match(/task\s+(\w+):/);
      if (taskMatch) {
        currentTask = taskMatch[1];
        flowData.tasks[currentTask] = { name: currentTask };
        continue;
      }

      // Extract task properties
      if (currentTask && line.includes(':')) {
        const [key, value] = line.split(':', 2).map((s) => s.trim());
        flowData.tasks[currentTask][key] = value.replace(/"/g, '');
      }
    }

    return flowData;
  }

  createSVG(flowData) {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('width', '100%');
    svg.setAttribute('height', '100%');
    svg.setAttribute('viewBox', '0 0 800 600');

    // Add title
    const title = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    title.setAttribute('x', '400');
    title.setAttribute('y', '30');
    title.setAttribute('text-anchor', 'middle');
    title.setAttribute('font-size', '20');
    title.setAttribute('font-weight', 'bold');
    title.textContent = flowData.name;
    svg.appendChild(title);

    // Add description if available
    if (flowData.description) {
      const desc = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      desc.setAttribute('x', '400');
      desc.setAttribute('y', '55');
      desc.setAttribute('text-anchor', 'middle');
      desc.setAttribute('font-size', '14');
      desc.textContent = flowData.description;
      svg.appendChild(desc);
    }

    // Create task nodes
    const taskNodes = {};
    const tasks = Object.values(flowData.tasks);

    // Calculate layout
    const nodeWidth = 120;
    const nodeHeight = 60;
    const horizontalSpacing = 200;
    const verticalSpacing = 100;
    const startX = 400 - (Math.min(tasks.length, 3) * horizontalSpacing) / 2;
    const startY = 120;

    // Create dependency graph
    const dependencies = {};
    tasks.forEach((task) => {
      dependencies[task.name] = [];
    });

    flowData.connections.forEach((conn) => {
      dependencies[conn.target].push(conn.source);
    });

    // Topological sort
    const visited = new Set();
    const temp = new Set();
    const order = [];

    const visit = (taskName) => {
      if (temp.has(taskName)) {
        throw new Error('Circular dependency detected');
      }
      if (visited.has(taskName)) {
        return;
      }

      temp.add(taskName);
      for (const dep of dependencies[taskName]) {
        visit(dep);
      }
      temp.delete(taskName);
      visited.add(taskName);
      order.push(taskName);
    };

    for (const task of tasks) {
      if (!visited.has(task.name)) {
        visit(task.name);
      }
    }

    // Reverse to get correct order
    order.reverse();

    // Calculate node positions
    const positions = {};
    const levels = {};

    // Assign levels
    order.forEach((taskName) => {
      const deps = dependencies[taskName];
      let level = 0;

      if (deps.length > 0) {
        level = Math.max(...deps.map((dep) => levels[dep])) + 1;
      }

      levels[taskName] = level;

      if (!positions[level]) {
        positions[level] = [];
      }
      positions[level].push(taskName);
    });

    // Calculate coordinates
    const coordinates = {};
    Object.entries(positions).forEach(([level, taskNames]) => {
      const levelNum = parseInt(level);
      const y = startY + levelNum * verticalSpacing;
      const levelWidth = taskNames.length * nodeWidth + (taskNames.length - 1) * (horizontalSpacing - nodeWidth);
      const x = 400 - levelWidth / 2;

      taskNames.forEach((taskName, index) => {
        coordinates[taskName] = {
          x: x + index * horizontalSpacing,
          y,
        };
      });
    });

    // Create nodes
    Object.entries(flowData.tasks).forEach(([taskName, task]) => {
      const { x, y } = coordinates[taskName];

      // Create group for the task
      const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
      g.setAttribute('transform', `translate(${x}, ${y})`);

      // Create rectangle
      const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
      rect.setAttribute('width', nodeWidth.toString());
      rect.setAttribute('height', nodeHeight.toString());
      rect.setAttribute('rx', '5');
      rect.setAttribute('ry', '5');
      rect.setAttribute('fill', '#4682b4');
      rect.setAttribute('stroke', '#36648b');
      rect.setAttribute('stroke-width', '2');
      g.appendChild(rect);

      // Create text
      const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      text.setAttribute('x', (nodeWidth / 2).toString());
      text.setAttribute('y', (nodeHeight / 2).toString());
      text.setAttribute('text-anchor', 'middle');
      text.setAttribute('dominant-baseline', 'middle');
      text.setAttribute('fill', 'white');
      text.setAttribute('font-size', '14');
      text.textContent = taskName;
      g.appendChild(text);

      svg.appendChild(g);
      taskNodes[taskName] = {
        x, y, width: nodeWidth, height: nodeHeight,
      };
    });

    // Create connections
    flowData.connections.forEach((conn) => {
      const source = taskNodes[conn.source];
      const target = taskNodes[conn.target];

      // Calculate path points
      const startX = source.x + source.width / 2;
      const startY = source.y + source.height;
      const endX = target.x + target.width / 2;
      const endY = target.y;

      // Create path
      const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('d', `M${startX},${startY} C${startX},${startY + 30} ${endX},${endY - 30} ${endX},${endY}`);
      path.setAttribute('fill', 'none');
      path.setAttribute('stroke', '#36648b');
      path.setAttribute('stroke-width', '2');
      path.setAttribute('marker-end', 'url(#arrowhead)');
      svg.appendChild(path);
    });

    // Add arrowhead marker
    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
    const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
    marker.setAttribute('id', 'arrowhead');
    marker.setAttribute('markerWidth', '10');
    marker.setAttribute('markerHeight', '7');
    marker.setAttribute('refX', '10');
    marker.setAttribute('refY', '3.5');
    marker.setAttribute('orient', 'auto');

    const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
    polygon.setAttribute('points', '0 0, 10 3.5, 0 7');
    polygon.setAttribute('fill', '#36648b');
    marker.appendChild(polygon);
    defs.appendChild(marker);
    svg.appendChild(defs);

    return svg;
  }

  downloadSVG(svg, flowName) {
    // Create a blob from the SVG
    const svgData = new XMLSerializer().serializeToString(svg);
    const blob = new Blob([svgData], { type: 'image/svg+xml' });

    // Create download link
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `${flowName || 'flow'}_diagram.svg`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  addStyles() {
    // Add CSS styles
    const style = document.createElement('style');
    style.textContent = `
      .dsl-flow-diagram {
        margin: 20px 0;
        padding: 10px;
        border: 1px solid #e0e0e0;
        border-radius: 5px;
        background-color: #f9f9f9;
        overflow-x: auto;
        min-height: 400px;
      }
      
      .dsl-download-btn {
        background-color: #4682b4;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 5px 10px;
        font-size: 14px;
        cursor: pointer;
        margin-top: 10px;
      }
      
      .dsl-download-btn:hover {
        background-color: #36648b;
      }
      
      /* Prism.js line numbers */
      pre.line-numbers {
        position: relative;
        padding-left: 3.8em;
        counter-reset: linenumber;
      }
      
      pre.line-numbers > code {
        position: relative;
        white-space: inherit;
      }
    `;
    document.head.appendChild(style);
  }
}

// Main TaskinityRender class
class TaskinityRender {
  constructor(options = {}) {
    this.options = {
      theme: 'default',
      lineNumbers: true,
      copyButton: true,
      ...options,
    };

    // Initialize components
    this.init();
  }

  init() {
    // Initialize syntax highlighter
    this.initSyntaxHighlighter();

    // Initialize flow visualizer
    this.flowVisualizer = new DSLFlowVisualizer({
      codeBlockSelector: 'pre code.language-dsl, pre code.language-flow, pre code:not([class])',
    });
  }

  initSyntaxHighlighter() {
    // Add line numbers to all code blocks if enabled
    if (this.options.lineNumbers) {
      document.querySelectorAll('pre').forEach((pre) => {
        pre.classList.add('line-numbers');
      });
    }

    // Add copy button to all code blocks if enabled
    if (this.options.copyButton) {
      this.addCopyButtons();
    }

    // Highlight all code blocks
    Prism.highlightAll();
  }

  addCopyButtons() {
    document.querySelectorAll('pre').forEach((pre) => {
      const copyButton = document.createElement('button');
      copyButton.className = 'copy-button';
      copyButton.textContent = 'Copy';

      copyButton.addEventListener('click', () => {
        const code = pre.querySelector('code').textContent;
        navigator.clipboard.writeText(code).then(() => {
          copyButton.textContent = 'Copied!';
          setTimeout(() => {
            copyButton.textContent = 'Copy';
          }, 2000);
        });
      });

      pre.appendChild(copyButton);
    });

    // Add styles for copy button
    const style = document.createElement('style');
    style.textContent = `
      pre {
        position: relative;
      }
      
      .copy-button {
        position: absolute;
        top: 5px;
        right: 5px;
        background-color: #f5f5f5;
        border: 1px solid #ccc;
        border-radius: 3px;
        color: #333;
        font-size: 12px;
        padding: 2px 6px;
        cursor: pointer;
        opacity: 0.6;
      }
      
      .copy-button:hover {
        opacity: 1;
      }
    `;
    document.head.appendChild(style);
  }
}

// Auto-initialize when the DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.TaskinityRender = TaskinityRender; // Expose globally
  window.taskinityRender = new TaskinityRender();
});

// Export the classes
export { TaskinityRender, DSLFlowVisualizer };

// Export as default for ES modules
export default TaskinityRender;

// Export a simple initialization function
export function initTaskinityRender(options = {}) {
  return new TaskinityRender(options);
}
