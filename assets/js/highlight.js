/**
 * @type {import('./van.d.ts').Van}
 */
const van = window.van;
const { div, button, mark } = van.tags;

class CleanReadEngine {
  constructor() {
    this.highlightClass = 'cr-highlight';
    this.handleClass = 'cr-handle';

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
    this.isDraggingHandle = van.state(false);

    this.selectionTimer = null;
    this.retryTimer = null;
    this.isUserInteraction = false;
    this.lastInteractTimestamp = 0;

    this._attachSelectionListener();
    this._attachOutsideClickListener();
    this._renderColorMenu();
    this._renderHandlesContainer();
  }

  // --- INITIALISIERUNG ---

  _attachSelectionListener() {
    // Pointer Events decken Mouse UND Touch ab
    document.addEventListener('pointerdown', () => {
      this.isUserInteraction = true;
      this.lastInteractTimestamp = Date.now();
    }, { passive: true });

    document.addEventListener('pointermove', () => {
      this.lastInteractTimestamp = Date.now();
    }, { passive: true });

    document.addEventListener('pointerup', () => {
      this.isUserInteraction = false;
      if (this.isDraggingHandle.val) return;

      if (this.retryTimer) clearTimeout(this.retryTimer);
      this.retryTimer = setTimeout(() => this._attemptHighlight(), 50);
    });

    document.addEventListener('selectionchange', () => {
      if (this.isDraggingHandle.val) return;
      if (this.selectionTimer) clearTimeout(this.selectionTimer);
      this.selectionTimer = setTimeout(() => {
        this._attemptHighlight();
      }, 600); // Etwas verkürzt für snappier UX
    });
  }

  _attachOutsideClickListener() {
    document.addEventListener('click', (e) => {
      if (this.isDraggingHandle.val) return;
      // Wenn wir auf einen Handle klicken, nichts tun (wird von pointerdown handled)
      if (e.target.closest(`.${this.handleClass}`)) return;

      const clickedHighlight = e.target.closest(`.${this.highlightClass}`);

      if (clickedHighlight) {
        const id = clickedHighlight.getAttribute('data-id');
        const color = clickedHighlight.getAttribute('data-color');
        this.activeHighlightId.val = id;
        this.activeColor.val = color;
        this._updateHandles(id);
      } else if (!window.getSelection().toString()) {
        this.activeHighlightId.val = null;
        this._clearHandles();
      }
    });

    window.addEventListener('scroll', () => {
      if (this.activeHighlightId.val && !this.isDraggingHandle.val) {
        this._updateHandles(this.activeHighlightId.val);
      }
    }, { passive: true });
  }

  // --- HIGHLIGHT CREATION ---

  _attemptHighlight() {
    const now = Date.now();
    // Safety Check: Ist der User wirklich fertig?
    if (this.isUserInteraction) {
      if (now - this.lastInteractTimestamp > 800) {
        this.isUserInteraction = false;
        this._handleSelectionChange();
        return;
      }
      if (this.retryTimer) clearTimeout(this.retryTimer);
      this.retryTimer = setTimeout(() => this._attemptHighlight(), 200);
      return;
    }
    this._handleSelectionChange();
  }

  _handleSelectionChange() {
    const selection = window.getSelection();
    if (!selection.isCollapsed && selection.toString().trim().length > 0) {
      this.createHighlightFromSelection(selection);
    }
  }

  createHighlightFromSelection(selection) {
    try {
      const range = selection.getRangeAt(0);
      const color = this.colors[0].hex;

      // HIER GEÄNDERT: Eigene Methode nutzen statt crypto.randomUUID()
      const id = this._generateUUID();

      const serializedData = this._serializeRange(range, color, id);
      this._highlightRangeSecure(range, color, id);

      this.activeColor.val = color;
      this.activeHighlightId.val = id;

      selection.removeAllRanges();
      this._sendToFlutter('create', serializedData);
      this._updateHandles(id);

    } catch (error) {
      console.error("Create Error:", error);
    }
  }

  // --- MENU ---

  _renderColorMenu() {
    const menu = div({
      onclick: (e) => e.stopPropagation(),
      style: () => `
        position: fixed;
        bottom: ${this.activeHighlightId.val && !this.isDraggingHandle.val ? '60px' : '-120px'};
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
        max-width: calc(100vw - 26px);
      `
    },
      this.colors.map(c =>
        button({
          style: () => `
            width: 30px; height: 30px; border-radius: 50%;
            border: 2px solid ${this.activeColor.val === c.hex ? '#333' : 'transparent'};
            background-color: ${c.hex}80;
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

  // --- HANDLES (Logic Fixed for Pointer Events) ---

  _renderHandlesContainer() {
    this.handlesContainer = div({
      style: 'position: absolute; top: 0; left: 0; width: 100%; height: 0; pointer-events: none; z-index: 10000;'
    });
    van.add(document.body, this.handlesContainer);
  }

  _clearHandles() {
    this.handlesContainer.innerHTML = '';
  }

  _updateHandles(id) {
    this._clearHandles();
    if (!id) return;

    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    if (elements.length === 0) return;

    const firstEl = elements[0];
    const lastEl = elements[elements.length - 1];

    const startRect = firstEl.getClientRects()[0];
    const lastRects = lastEl.getClientRects();
    const endRect = lastRects[lastRects.length - 1];

    if (!startRect || !endRect) return;

    const scrollX = window.scrollX;
    const scrollY = window.scrollY;

    this._createHandle(startRect.left + scrollX, startRect.top + scrollY, startRect.height, true, id);
    // WICHTIG: Hier 'endRect.top' statt 'bottom', damit der Balken AUF dem Text liegt
    this._createHandle(endRect.right + scrollX, endRect.top + scrollY, endRect.height, false, id);
  }

  _createHandle(x, y, height, isStart, id) {
    const handleSize = 30;

    // Statische Styles definieren wir hier einmalig
    const visual = div({
      style: `
            width: 4px; 
            /* height wird von _styleHandleInner gesetzt */
            background-color: ${this.activeColor.val}; 
            border-radius: 2px;
            position: absolute; left: 50%; top: 0; transform: translateX(-50%);
            z-index: 2;
        `
    });

    const knob = div({
      style: `
            width: 20px; height: 20px; 
            background-color: ${this.activeColor.val}; 
            border-radius: ${isStart ? '50% 50% 0 50%' : '0 50% 50% 50%'};
            transform: rotate(45deg);
            position: absolute;
            left: 5px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            z-index: 1;
        `
    });

    const handleWrapper = div({
      class: this.handleClass,
      style: `
            position: absolute; left: ${x}px; top: ${y}px;
            width: ${handleSize}px; 
            /* height wird von _styleHandleInner gesetzt */
            transform: translateX(-50%);
            pointer-events: auto; 
            touch-action: none;
            cursor: col-resize;
            z-index: 10001; 
        `,
      onpointerdown: (e) => this._initResizeDrag(e, isStart, id)
    }, visual, knob);

    // Initiales Styling anwenden
    this._styleHandleInner(handleWrapper, height, isStart);

    van.add(this.handlesContainer, handleWrapper);
  }

  // --- UTILS ---

  _reconstructRangeFromId(id) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    if (elements.length === 0) return null;
    const range = document.createRange();
    const firstMark = elements[0];
    const lastMark = elements[elements.length - 1];
    range.setStart(firstMark.firstChild, 0);
    range.setEnd(lastMark.lastChild, lastMark.lastChild.length);
    return range;
  }

  // Update: Neuer Parameter 'skipNormalize'
  _removeHighlightVisualsOnly(id, skipNormalize = false) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      const parent = el.parentNode;
      while (el.firstChild) {
        parent.insertBefore(el.firstChild, el);
      }
      parent.removeChild(el);
      // Beim Draggen nicht normalisieren, sonst verlieren wir Referenzen
      if (!skipNormalize) parent.normalize();
    });
  }

  updateHighlightColor(id, newColor) {
    if (!id) return;
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      el.style.backgroundColor = newColor + '80';
      el.setAttribute("data-color", newColor);
    });
    this.activeColor.val = newColor;
    this._updateHandles(id);
    this._sendToFlutter('update', { id: id, color: newColor });
  }

  deleteHighlight(id) {
    if (!id) return;
    this._removeHighlightVisualsOnly(id);
    this._clearHandles();
    this.activeHighlightId.val = null;
    this._sendToFlutter('delete', { id: id });
  }

  _sendToFlutter(action, data) {
    if (window.CleanReadApp) {
      window.CleanReadApp.postMessage(JSON.stringify({ action, data }));
    } else {
      console.log(`To Flutter [${action}]:`, data);
    }
  }

  _highlightRangeSecure(range, color, id) {
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
        style: `background-color: ${color}80; color: inherit; padding: 0;`,
        onclick: (e) => {
          e.stopPropagation();
          this.activeHighlightId.val = id;
          this.activeColor.val = e.target.getAttribute("data-color");
          this._updateHandles(id);
        }
      }, parts[1])
    );

    if (parts[2]) newNodes.push(document.createTextNode(parts[2]));
    textNode.replaceWith(...newNodes);
  }

  _serializeRange(range, color, id) {
    let container = range.commonAncestorContainer;
    while (container && container.nodeType === Node.TEXT_NODE) {
      container = container.parentNode;
    }
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

  restoreHighlights(jsonList) {
    let highlights = typeof jsonList === 'string' ? JSON.parse(jsonList) : jsonList;
    highlights.sort((a, b) => {
      if (a.xpath > b.xpath) return -1;
      if (a.xpath < b.xpath) return 1;
      return b.startOffset - a.startOffset;
    });
    highlights.forEach(h => {
      try { this._restoreSingle(h); } catch (e) { console.warn("Restore error", e); }
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
    const targetStart = data.startOffset;
    const targetEnd = data.endOffset;

    while (node = walker.nextNode()) {
      const nextCharCount = charCount + node.length;
      if (!startFound && targetStart >= charCount && targetStart < nextCharCount) {
        range.setStart(node, targetStart - charCount);
        startFound = true;
      }
      if (!endFound && targetEnd > charCount && targetEnd <= nextCharCount) {
        range.setEnd(node, targetEnd - charCount);
        endFound = true;
      }
      charCount = nextCharCount;
      if (startFound && endFound) break;
    }
    if (startFound && endFound) {
      this._highlightRangeSecure(range, data.color, data.id);
    }
  }

  // Hilfsmethode: Generiert UUID auch in unsicheren Umgebungen (HTTP im LAN)
  _generateUUID() {
    // 1. Versuche native API (funktioniert auf localhost/https)
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
      return crypto.randomUUID();
    }

    // 2. Fallback für HTTP im lokalen Netzwerk (Math.random ist hier okay)
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  _renderPreview(range, color) {
    // Layer erstellen, falls nicht vorhanden
    if (!this.previewLayer) {
      this.previewLayer = div({
        style: 'position: absolute; top: 0; left: 0; width: 100%; height: 0; pointer-events: none; z-index: 9999;'
      });
      document.body.appendChild(this.previewLayer);
    }
    this.previewLayer.innerHTML = ''; // Alten Preview löschen

    // Rechtecke berechnen (Super schnell im Vergleich zu DOM Node Manipulation)
    const rects = range.getClientRects();
    const scrollX = window.scrollX;
    const scrollY = window.scrollY;

    for (const rect of rects) {
      const el = div({
        style: `
                position: absolute;
                left: ${rect.left + scrollX}px;
                top: ${rect.top + scrollY}px;
                width: ${rect.width}px;
                height: ${rect.height}px;
                background-color: ${color}80; /* Gleiche Farbe/Transparenz wie Highlight */
                mix-blend-mode: multiply; /* Optional: sieht besser aus auf Text */
            `
      });
      this.previewLayer.appendChild(el);
    }
  }

  _removePreview() {
    if (this.previewLayer) {
      this.previewLayer.remove();
      this.previewLayer = null;
    }
  }

  _updateHandlesFromRange(range) {
    const rects = range.getClientRects();
    if (rects.length === 0) return;

    const startRect = rects[0];
    const endRect = rects[rects.length - 1];
    const scrollX = window.scrollX;
    const scrollY = window.scrollY;

    const handles = this.handlesContainer.children;
    if (handles.length < 2) return;

    // 1. Start Handle bewegen
    const startHandle = handles[0];
    startHandle.style.left = (startRect.left + scrollX) + 'px';
    startHandle.style.top = (startRect.top + scrollY) + 'px';
    // Design updaten (via Helper)
    this._styleHandleInner(startHandle, startRect.height, true);

    // 2. End Handle bewegen
    const endHandle = handles[1];
    endHandle.style.left = (endRect.right + scrollX) + 'px';
    endHandle.style.top = (endRect.top + scrollY) + 'px';
    // Design updaten (via Helper)
    this._styleHandleInner(endHandle, endRect.height, false);
  }

  _moveHandleEl(handle, x, y, height, isStart) {
    handle.style.left = x + 'px';
    handle.style.top = y + 'px';
    handle.style.height = height + 'px';

    const knob = handle.children[1];
    if (knob) {
      if (isStart) {
        knob.style.top = '-22px'; // Dein fester Wert
      } else {
        // Dynamisch ans untere Ende setzen
        knob.style.top = (height) + 'px';
      }
    }
    const visual = handle.children[0];
    if (visual) visual.style.height = height + 'px';
  }

  // --- NEUE HILFSMETHODE (Gegen das Springen) ---
  _getSafeCaretPosition(clientX, clientY) {
    let caretInfo = null;

    // Standard API
    if (document.caretRangeFromPoint) {
      const range = document.caretRangeFromPoint(clientX, clientY);
      if (range) caretInfo = { node: range.startContainer, offset: range.startOffset };
    } else if (document.caretPositionFromPoint) {
      const pos = document.caretPositionFromPoint(clientX, clientY);
      if (pos) caretInfo = { node: pos.offsetNode, offset: pos.offset };
    }

    if (!caretInfo) return null;

    if (caretInfo.node.nodeType !== Node.TEXT_NODE) {
      return null;
    }

    return caretInfo;
  }

  _initResizeDrag(e, isStartHandle, id) {
    e.preventDefault();
    e.stopPropagation();

    const handleElement = e.currentTarget;
    handleElement.setPointerCapture(e.pointerId);

    this.isDraggingHandle.val = true;

    // Verhindert Text-Selektion systemweit
    document.body.style.userSelect = 'none';
    document.body.style.webkitUserSelect = 'none';

    // 1. Initialisierung
    const currentRange = this._reconstructRangeFromId(id);
    if (!currentRange) return;

    // Altes Highlight optisch ausblenden
    const existingMarks = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    existingMarks.forEach(el => el.style.opacity = '0.2');

    // Anker setzen
    const anchorSpan = document.createElement('span');
    anchorSpan.id = 'cr-drag-anchor';
    anchorSpan.style.display = 'none';

    const anchorRange = document.createRange();
    if (isStartHandle) {
      anchorRange.setStart(currentRange.endContainer, currentRange.endOffset);
    } else {
      anchorRange.setStart(currentRange.startContainer, currentRange.startOffset);
    }
    anchorRange.collapse(true);
    anchorRange.insertNode(anchorSpan);

    const color = this.activeColor.val;

    // Pointer Events Setup
    this.handlesContainer.style.pointerEvents = 'none';
    handleElement.style.pointerEvents = 'auto';

    // WICHTIG: Wir merken uns immer die letzte gültige Range aus dem Move-Event
    let lastValidRange = null;

    const onPointerMove = (moveEvent) => {
      const caretInfo = this._getSafeCaretPosition(moveEvent.clientX, moveEvent.clientY);
      if (!caretInfo) return;

      const anchorNode = document.getElementById('cr-drag-anchor');
      if (!anchorNode) return;

      const newRange = document.createRange();
      const rangeToFinger = document.createRange();
      rangeToFinger.setStart(caretInfo.node, caretInfo.offset);

      const rangeToAnchor = document.createRange();
      rangeToAnchor.setStartBefore(anchorNode);

      const comparison = rangeToFinger.compareBoundaryPoints(Range.START_TO_START, rangeToAnchor);

      if (comparison <= 0) {
        newRange.setStart(caretInfo.node, caretInfo.offset);
        newRange.setEndBefore(anchorNode);
      } else {
        newRange.setStartAfter(anchorNode);
        newRange.setEnd(caretInfo.node, caretInfo.offset);
      }

      // Speichern für onPointerUp
      lastValidRange = newRange;

      this._renderPreview(newRange, color);
      this._updateHandlesFromRange(newRange);
    };

    const onPointerUp = (upEvent) => {
      handleElement.releasePointerCapture(upEvent.pointerId);
      handleElement.removeEventListener('pointermove', onPointerMove);
      handleElement.removeEventListener('pointerup', onPointerUp);

      this.isDraggingHandle.val = false;

      // Styles Reset
      document.body.style.userSelect = '';
      document.body.style.webkitUserSelect = '';
      this.handlesContainer.style.pointerEvents = 'none';
      Array.from(this.handlesContainer.children).forEach(el => el.style.pointerEvents = 'auto');

      this._removePreview();

      let finalRange = null;

      if (lastValidRange) {
        // Wir setzen temporäre Marker an Start und Ende der Range.
        // Warum? Weil _removeHighlightVisualsOnly und normalize() die Text-Knoten zerstören/verändern.
        // Marker sind Elemente (Spans), die bleiben stabil im Baum, egal was mit dem Text passiert.

        const startMarker = document.createElement('span');
        const endMarker = document.createElement('span');

        // Marker einfügen (Vorsicht: Range clonen, damit wir nicht mutieren während wir lesen)
        const rStart = lastValidRange.cloneRange();
        rStart.collapse(true); // Zum Start
        rStart.insertNode(startMarker);

        const rEnd = lastValidRange.cloneRange();
        rEnd.collapse(false); // Zum Ende
        rEnd.insertNode(endMarker);

        // JETZT Aufräumen (zerstört Textknoten, aber Marker bleiben)
        const anchorEl = document.getElementById('cr-drag-anchor');
        if (anchorEl) anchorEl.remove();

        this._removeHighlightVisualsOnly(id, true);
        document.body.normalize(); // Textknoten mergen

        // Jetzt bauen wir die finale Range zwischen unseren stabilen Markern
        finalRange = document.createRange();
        finalRange.setStartAfter(startMarker);
        finalRange.setEndBefore(endMarker);

        // Marker wieder entfernen
        startMarker.remove();
        endMarker.remove();
        // Nochmal normalize für Sauberkeit
        document.body.normalize();
      } else {
        // Fallback, falls gar nicht bewegt wurde
        const anchorEl = document.getElementById('cr-drag-anchor');
        if (anchorEl) anchorEl.remove();
        this._removeHighlightVisualsOnly(id, true);
        document.body.normalize();
      }

      // Commit
      if (finalRange) {
        const serialized = this._serializeRange(finalRange, color, id);

        this._highlightRangeSecure(finalRange, color, id);

        this._sendToFlutter('delete', { id: id });
        setTimeout(() => this._sendToFlutter('create', serialized), 50);

        requestAnimationFrame(() => {
          this._updateHandles(id);
          this._renderColorMenu();
        });
      } else {
        this.activeHighlightId.val = null;
        this._clearHandles();
      }
    };

    handleElement.addEventListener('pointermove', onPointerMove);
    handleElement.addEventListener('pointerup', onPointerUp);
  }

  // ZENTRALE LOGIK für das Aussehen des Handles
  _styleHandleInner(handleWrapper, height, isStart) {
    // 1. Wrapper Höhe
    handleWrapper.style.height = height + 'px';

    // 2. Der visuelle Strich (Kind 0)
    const visual = handleWrapper.children[0];
    if (visual) {
      visual.style.height = height + 'px';
    }

    // 3. Der Knob (Kind 1)
    const knob = handleWrapper.children[1];
    if (knob) {
      // Hier sind deine Design-Konstanten an EINEM Ort:
      const startOffset = -22; // Pixel nach oben
      const endOffset = 0;    // Pixel relative zur Unterkante (negativ = nach oben)

      knob.style.top = isStart
        ? `${startOffset}px`
        : `${height + endOffset}px`;

      // Auch statische Styles wie 'rotate' oder 'borderRadius' könnten hier
      // bei Bedarf dynamisch gesetzt werden, aber 'top' ist das Wichtige.
    }
  }
}

window.cleanReadEngine = new CleanReadEngine();
