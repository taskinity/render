const { DSLFlowVisualizer } = require('../src/index');

describe('DSLFlowVisualizer', () => {
  let visualizer;

  beforeEach(() => {
    // Mock document.createElementNS for SVG creation
    document.createElementNS = jest.fn().mockImplementation((namespace, tagName) => {
      const element = document.createElement(tagName);
      element.setAttribute = jest.fn();
      element.appendChild = jest.fn();
      return element;
    });
    
    visualizer = new DSLFlowVisualizer();
  });

  test('should be defined', () => {
    expect(DSLFlowVisualizer).toBeDefined();
  });

  test('should initialize with default options', () => {
    expect(visualizer.options.codeBlockSelector).toBe(
      'pre code.language-dsl, pre code.language-flow, pre code:not([class])'
    );
  });

  test('should parse DSL content correctly', () => {
    const dsl = `flow test_flow:
      description: "Test description"
      task1 -> task2
      task2 -> task3`;
    
    const result = visualizer.parseDSL(dsl);
    
    expect(result).toBeDefined();
    expect(result.name).toBe('test_flow');
    expect(result.description).toBe('Test description');
    expect(result.connections).toHaveLength(2);
    expect(Object.keys(result.tasks)).toHaveLength(3);
  });
});
