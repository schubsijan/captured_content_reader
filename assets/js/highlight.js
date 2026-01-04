/**
 * @type {import('./van.d.ts').Van}
 */
const van = window.van;
const { div, button, mark } = van.tags;

class CleanReadEngine {
  constructor() {
    this.highlightClass = 'cr-highlight';

    // Farbschema
    this.colors = [
      { hex: '#F8CF01', name: 'Yellow' },
      { hex: '#F86464', name: 'Red' },
      { hex: '#5EB037', name: 'Green' },
      { hex: '#30A6E1', name: 'Blue' },
      { hex: '#9E87DF', name: 'Purple' },
      { hex: '#DF6CE8', name: 'Magenta' },
      { hex: '#EB9436', name: 'Orange' },
      { hex: '#A6A6A6', name: 'Gray' }
    ];

    this.activeHighlightId = van.state(null);
    this.activeColor = van.state(this.colors[0].hex);
    this.selectionTimer = null; // Für Debouncing

    this._attachSelectionListener();
    this._renderColorMenu();
    this._attachOutsideClickListener();
  }

  // --- LÖSUNG 1: Selection Change statt MouseUp ---
  _attachSelectionListener() {
    // Mobile Browser feuern 'selectionchange' sehr oft. Wir brauchen einen Debounce.
    document.addEventListener('selectionchange', () => {
      // Alten Timer löschen
      if (this.selectionTimer) clearTimeout(this.selectionTimer);

      // Neuen Timer setzen (wartet 300ms bis die Auswahl "ruht")
      this.selectionTimer = setTimeout(() => {
        this._handleSelectionChange();
      }, 600);
    });
  }

  _handleSelectionChange() {
    const selection = window.getSelection();

    // Prüfen, ob wirklich Text ausgewählt ist
    if (!selection.isCollapsed && selection.toString().trim().length > 0) {
      // Checken, ob wir bereits innerhalb eines existierenden Highlights sind, 
      // um Konflikte zu vermeiden (optional)
      this.createHighlightFromSelection(selection);
    }
  }

  _renderColorMenu() {
    const menu = div({
      onclick: (e) => e.stopPropagation(),
      style: () => `
        position: fixed;
        bottom: ${this.activeHighlightId.val ? '60px' : '-120px'};
        left: 50%;
        transform: translateX(-50%);
        background: white;
        padding: 10px;
        border-radius: 30px; 
        box-shadow: 0 4px 20px rgba(0,0,0,0.25);
        display: flex;
        gap: 8px;
        z-index: 99999;
        transition: bottom 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      `
    },
      this.colors.map(c =>
        button({
          style: () => `
            width: 30px; height: 30px; border-radius: 50%;
            border: 2px solid ${this.activeColor.val === c.hex ? '#333' : 'transparent'};
            background-color: ${c.hex}80; // 50% Transparenz hier hinzufügen
            cursor: pointer; transition: all 0.1s;
          `,
          onclick: () => this.updateHighlightColor(this.activeHighlightId.val, c.hex)
        })
      ),
      div({ style: "width: 1px; background: #ddd; margin: 0 4px;" }),
      button({
        style: "background: none; border: none; font-size: 18px;",
        onclick: () => this.deleteHighlight(this.activeHighlightId.val)
      }, "🗑️")
    );
    van.add(document.body, menu);
  }

  _attachOutsideClickListener() {
    // Um das Menü zu schließen, wenn man den Text "deselektiert"
    document.addEventListener('click', (e) => {
      const clickedHighlight = e.target.closest(`.${this.highlightClass}`);
      if (!clickedHighlight && !window.getSelection().toString()) {
        this.activeHighlightId.val = null;
      }
    });
  }

  createHighlightFromSelection(selection) {
    try {
      const range = selection.getRangeAt(0);
      const color = this.colors[0].hex;
      const id = crypto.randomUUID();

      const serializedData = this._serializeRange(range, color, id);

      this._highlightRangeSecure(range, color, id);

      this.activeColor.val = color;
      this.activeHighlightId.val = id;

      // WICHTIG: Auswahl entfernen, damit das native Android Menü verschwindet 
      // und unser Menü sichtbar bleibt.
      selection.removeAllRanges();

      this._sendToFlutter('create', serializedData);
    } catch (error) {
      console.error("Create Error:", error);
    }
  }

  // ... (updateHighlightColor, deleteHighlight, _sendToFlutter bleiben gleich) ...
  updateHighlightColor(id, newColor) {
    if (!id) return;
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      el.style.backgroundColor = newColor + '80'; // Transparenz
      el.setAttribute("data-color", newColor);
    });
    this.activeColor.val = newColor;
    this._sendToFlutter('update', { id: id, color: newColor });
  }

  deleteHighlight(id) {
    if (!id) return;
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      const text = document.createTextNode(el.textContent);
      el.replaceWith(text);
      // Nodes zusammenfügen (clean up), damit zukünftige XPaths stimmen
      if (text.previousSibling && text.previousSibling.nodeType === 3) {
        text.previousSibling.nodeValue += text.nodeValue;
        text.remove();
      } else if (text.nextSibling && text.nextSibling.nodeType === 3) {
        text.nodeValue += text.nextSibling.nodeValue;
        text.nextSibling.remove();
      }
    });
    this.activeHighlightId.val = null;
    this._sendToFlutter('delete', { id: id });
  }

  _sendToFlutter(action, data) {
    if (window.CleanReadApp) {
      window.CleanReadApp.postMessage(JSON.stringify({ action, data }));
    }
  }

  _highlightRangeSecure(range, color, id) {
    // ... (Logik bleibt weitgehend gleich, nur Style Anpassung) ...
    const rootNode = range.commonAncestorContainer.nodeType === Node.TEXT_NODE
      ? range.commonAncestorContainer.parentNode
      : range.commonAncestorContainer;

    const treeWalker = document.createTreeWalker(
      rootNode, NodeFilter.SHOW_TEXT,
      { acceptNode: (node) => range.intersectsNode(node) ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT }
    );

    const nodesToWrap = [];
    let currentNode;
    while (currentNode = treeWalker.nextNode()) nodesToWrap.push(currentNode);

    if (nodesToWrap.length === 0 && range.commonAncestorContainer.nodeType === Node.TEXT_NODE) {
      if (range.intersectsNode(range.commonAncestorContainer)) nodesToWrap.push(range.commonAncestorContainer);
    }

    // Rückwärts iterieren ist oft sicherer beim Modifizieren
    for (let i = nodesToWrap.length - 1; i >= 0; i--) {
      const node = nodesToWrap[i];
      const start = (node === range.startContainer) ? range.startOffset : 0;
      const end = (node === range.endContainer) ? range.endOffset : node.length;
      if (start < end) {
        this._replaceTextNodeWithVan(node, start, end, color, id);
      }
    }
  }

  _replaceTextNodeWithVan(textNode, start, end, color, id) {
    const text = textNode.textContent;
    const parts = [
      text.substring(0, start),
      text.substring(start, end),
      text.substring(end)
    ];

    const newNodes = [];
    if (parts[0]) newNodes.push(document.createTextNode(parts[0]));

    newNodes.push(
      mark({
        class: this.highlightClass,
        "data-id": id,
        "data-color": color,
        style: `background-color: ${color}80; color: inherit; padding: 0;`, // Padding 0 verhindert Layout-Verschiebungen
        onclick: (e) => {
          e.stopPropagation();
          this.activeHighlightId.val = id;
          this.activeColor.val = e.target.getAttribute("data-color");
        }
      }, parts[1])
    );

    if (parts[2]) newNodes.push(document.createTextNode(parts[2]));

    textNode.replaceWith(...newNodes);
  }

  _serializeRange(range, color, id) {
    // 1. Finde das stabile Container-Element
    let container = range.commonAncestorContainer;
    while (container && container.nodeType === Node.TEXT_NODE) {
      container = container.parentNode;
    }

    // 2. Berechne den Offset relativ zum gesamten Text des Containers
    const preCaretRange = range.cloneRange();
    preCaretRange.selectNodeContents(container);
    preCaretRange.setEnd(range.startContainer, range.startOffset);

    const startOffset = preCaretRange.toString().length;
    const text = range.toString();

    return {
      id: id,
      text: text,
      xpath: this._getXPath(container),
      startOffset: startOffset,
      endOffset: startOffset + text.length,
      color: color
    };
  }

  _getXPath(node) {
    if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;
    if (node.id) return `//*[@id="${node.id}"]`;
    if (node === document.body) return '/HTML/BODY';
    let ix = 0;
    const siblings = node.parentNode ? node.parentNode.childNodes : [];
    for (let i = 0; i < siblings.length; i++) {
      const sibling = siblings[i];
      if (sibling === node) return this._getXPath(node.parentNode) + '/' + node.tagName + '[' + (ix + 1) + ']';
      if (sibling.nodeType === 1 && sibling.tagName === node.tagName) ix++;
    }
    return '';
  }

  // --- LÖSUNG 2: Sortierung für korrektes Restore ---
  restoreHighlights(jsonList) {
    let highlights = typeof jsonList === 'string' ? JSON.parse(jsonList) : jsonList;

    // SORTIERUNG: Wir müssen von HINTEN nach VORNE wiederherstellen (Reverse Document Order).
    // Grund: Wenn wir oben etwas einfügen, verschieben sich die Offsets für alles, was danach kommt.
    // Wenn wir hinten anfangen, bleiben die vorderen Indizes gültig.
    highlights.sort((a, b) => {
      // 1. Sortiere nach XPath Länge (Tiefe)
      if (a.xpath > b.xpath) return -1;
      if (a.xpath < b.xpath) return 1;

      // 2. Bei gleichem Element: Sortiere nach StartOffset (Größeres zuerst)
      return b.startOffset - a.startOffset;
    });

    highlights.forEach(h => {
      try {
        this._restoreSingle(h);
      } catch (e) { console.warn("Restore error", e); }
    });
  }

  _restoreSingle(data) {
    const result = document.evaluate(data.xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    const container = result.singleNodeValue;
    if (!container) return;

    const range = document.createRange();
    let charCount = 0;
    let startFound = false;
    let endFound = false;

    const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, null);
    let node;

    // Wir lesen jetzt data.startOffset und data.endOffset
    const targetStart = data.startOffset;
    const targetEnd = data.endOffset;

    while (node = walker.nextNode()) {
      const nextCharCount = charCount + node.length;

      // Start finden
      if (!startFound && targetStart >= charCount && targetStart < nextCharCount) {
        range.setStart(node, targetStart - charCount);
        startFound = true;
      }

      // Ende finden
      if (!endFound && targetEnd > charCount && targetEnd <= nextCharCount) {
        range.setEnd(node, targetEnd - charCount);
        endFound = true;
      }

      charCount = nextCharCount;
      if (startFound && endFound) break;
    }

    if (startFound && endFound) {
      this._highlightRangeSecure(range, data.color, data.id);
    } else {
      console.warn("Konnte Highlight nicht wiederherstellen (Offset mismatch):", data.text);
    }
  }
}

window.cleanReadEngine = new CleanReadEngine();
