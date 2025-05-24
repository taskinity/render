# Taskinity Render

Prosta biblioteka JavaScript do renderowania diagramów przepływu Taskinity i kolorowania składni w dokumentach Markdown.

## Instalacja

```bash
npm install taskinity-render
```

lub bezpośrednio z CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>
```

## Użycie

Wystarczy dodać jeden tag script do dokumentu Markdown:

```html
<script src="https://cdn.jsdelivr.net/npm/taskinity-render/dist/taskinity-render.min.js"></script>
```

Biblioteka automatycznie:

1. Koloruje składnię wszystkich bloków kodu (Python, Bash, JavaScript, YAML, JSON, Markdown)
2. Renderuje diagramy przepływu dla bloków kodu DSL (zaczynających się od słowa kluczowego "flow")
3. Dodaje przyciski kopiowania do bloków kodu
4. Dodaje numerację linii do bloków kodu

## Przykład

Dla następującego bloku kodu DSL:

```
flow EmailProcessing:
    description: "Email Processing Flow"
    fetch_emails -> classify_emails
    classify_emails -> process_urgent_emails
    classify_emails -> process_regular_emails
```

Biblioteka automatycznie wygeneruje interaktywny diagram przepływu.

## Konfiguracja

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

## Rozwój

```bash
# Instalacja zależności
npm install

# Uruchomienie w trybie deweloperskim
npm run dev

# Budowanie wersji produkcyjnej
npm run build
```