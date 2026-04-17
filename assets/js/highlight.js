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

    this.currentDefaultColor = this.colors[0].hex;
    this.currentDefaultType = 'highlight';

    this.activeHighlightId = van.state(null);
    this.activeColor = van.state(this.currentDefaultColor);
    this.activeType = van.state(this.currentDefaultType);

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

  _attachSelectionListener() {
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
      }, 600);
    });
  }

  _attachOutsideClickListener() {
    // Use capture phase so this runs BEFORE the highlight's onclick
    document.addEventListener('click', (e) => {
      if (this.isDraggingHandle.val) return;
      if (e.target.closest(`.${this.handleClass}`)) return;

      // Don't close when clicking on buttons (color menu, type buttons, etc.)
      if (e.target.tagName === 'BUTTON') return;

      const clickedHighlight = e.target.closest(`.${this.highlightClass}`);

      if (clickedHighlight) {
        const id = clickedHighlight.getAttribute('data-id');
        const color = clickedHighlight.getAttribute('data-color');
        const type = clickedHighlight.getAttribute('data-type') || 'highlight';

        this.activeHighlightId.val = id;
        this.activeColor.val = color;
        this.activeType.val = type;

        this._updateHandles(id);
      } else if (!window.getSelection().toString()) {
        this.activeHighlightId.val = null;
        this._clearHandles();
      }
    }, true);

    window.addEventListener('scroll', () => {
      if (this.activeHighlightId.val && !this.isDraggingHandle.val) {
        this._updateHandles(this.activeHighlightId.val);
      }
    }, { passive: true });
  }

  _attemptHighlight() {
    const now = Date.now();
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
      const id = this._generateUUID();
      const color = this.currentDefaultColor;
      const type = this.currentDefaultType;

      const serializedData = this._serializeRange(range, color, id, null, [], type);
      this._highlightRangeSecure(range, color, id, type);

      this.activeColor.val = color;
      this.activeType.val = type;
      this.activeHighlightId.val = id;

      selection.removeAllRanges();
      this._sendToFlutter('create', serializedData);
      this._updateHandles(id);
    } catch (error) { console.error(error); }
  }

  _renderColorMenu() {
    const menu = div({
      style: () => `
            position: fixed;
            bottom: ${this.activeHighlightId.val && !this.isDraggingHandle.val ? '50px' : '-240px'};
            left: 50%;
            transform: translateX(-50%);
            background: white;
            padding: 12px;
            border-radius: 20px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: column;
            gap: 12px;
            z-index: 99999;
            transition: bottom 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            width: max-content;
        `
    },
      div({ style: "display: flex; gap: 8px; align-items: center;" },
        this.colors.map(c =>
          button({
            style: () => `
                    width: 28px; height: 28px; border-radius: 50%;
                    border: 2px solid ${this.activeColor.val === c.hex ? '#333' : 'transparent'};
                    background-color: ${c.hex};
                    cursor: pointer;
                `,
            onclick: (e) => {
              e.preventDefault();
              e.stopPropagation();
              this.updateHighlightColor(this.activeHighlightId.val, c.hex)
            }
          })
        ),
        div({ style: "width: 1px; background: #eee; height: 20px; margin: 0 4px;" }),
        button({
          style: "background: none; border: none; font-size: 18px; cursor: pointer;",
          onclick: () => this.copyHighlightText(this.activeHighlightId.val)
        }, "📋")
      ),
      div({ style: "display: flex; gap: 10px; align-items: center; border-top: 1px solid #eee; padding-top: 8px;" },
        button({
          style: () => `border: none; background: ${this.activeType.val === 'highlight' ? '#eee' : 'transparent'}; padding: 4px 12px; border-radius: 8px; font-size: 13px; font-weight: bold; transition: background 0.2s;`,
          onclick: (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.updateHighlightType(this.activeHighlightId.val, 'highlight')
          }
        }, "Marker"),
        button({
          style: () => `border: none; background: ${this.activeType.val === 'underline' ? '#eee' : 'transparent'}; padding: 4px 12px; border-radius: 8px; font-size: 13px; font-weight: bold; transition: background 0.2s;`,
          onclick: (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.updateHighlightType(this.activeHighlightId.val, 'underline')
          }
        }, "Unterstreichen"),

        div({ style: "flex-grow: 1; min-width: 10px;" }),

        button({
          style: "background: none; border: none; font-size: 18px; cursor: pointer;",
          onclick: () => this._sendToFlutter('edit_note', { id: this.activeHighlightId.val })
        }, "📝"),
        button({
          style: "background: none; border: none; font-size: 18px; cursor: pointer;",
          onclick: () => this.deleteHighlight(this.activeHighlightId.val)
        }, "🗑️")
      )
    );
    van.add(document.body, menu);
  }

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

    const currentHighlightColor = elements[0].getAttribute('data-color')

    const firstEl = elements[0];
    const lastEl = elements[elements.length - 1];
    const startRect = firstEl.getClientRects()[0];
    const lastRects = lastEl.getClientRects();
    const endRect = lastRects[lastRects.length - 1];

    if (!startRect || !endRect) return;

    const scrollX = window.scrollX;
    const scrollY = window.scrollY;

    this._createHandle(startRect.left + scrollX, startRect.top + scrollY, startRect.height, true, id, currentHighlightColor);
    this._createHandle(endRect.right + scrollX, endRect.top + scrollY, endRect.height, false, id, currentHighlightColor);
  }

  _createHandle(x, y, height, isStart, id, color) {
    const handleSize = 30;
    const visual = div({
      style: `width: 4px; background-color: ${color}; border-radius: 2px; position: absolute; left: 50%; top: 0; transform: translateX(-50%); z-index: 2;`
    });
    const knob = div({
      style: `width: 20px; height: 20px; background-color: ${color}; border-radius: ${isStart ? '50% 50% 0 50%' : '0 50% 50% 50%'}; transform: rotate(45deg); position: absolute; left: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.2); z-index: 1;`
    });
    const handleWrapper = div({
      class: this.handleClass,
      style: `position: absolute; left: ${x}px; top: ${y}px; width: ${handleSize}px; transform: translateX(-50%); pointer-events: auto; touch-action: none; cursor: col-resize; z-index: 10001;`,
      onpointerdown: (e) => this._initResizeDrag(e, isStart, id)
    }, visual, knob);

    this._styleHandleInner(handleWrapper, height, isStart);
    van.add(this.handlesContainer, handleWrapper);
  }

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

  _removeHighlightVisualsOnly(id, skipNormalize = false) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      const parent = el.parentNode;
      while (el.firstChild) {
        parent.insertBefore(el.firstChild, el);
      }
      parent.removeChild(el);
      if (!skipNormalize) parent.normalize();
    });
  }

  updateHighlightColor(id, newColor) {
    if (!id) return;
    this.currentDefaultColor = newColor;
    this.activeColor.val = newColor;

    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      el.setAttribute("data-color", newColor);
      if (el.classList.contains('type-underline')) {
        el.style.textDecorationColor = newColor;
      } else {
        el.style.backgroundColor = newColor + '80';
      }
    });
    this._updateHandles(id);
    this._sendToFlutter('update', { id: id, color: newColor });
  }

  updateHighlightType(id, newType) {
    if (!id) return;
    this.currentDefaultType = newType;
    this.activeType.val = newType;

    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      const color = el.getAttribute('data-color');
      el.classList.remove('type-highlight', 'type-underline');
      el.classList.add(`type-${newType}`);
      el.setAttribute('data-type', newType);

      if (newType === 'underline') {
        el.style.backgroundColor = 'transparent';
        el.style.textDecorationColor = color;
      } else {
        el.style.backgroundColor = color + '80';
      }
    });
    this._sendToFlutter('update', { id: id, type: newType });
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
    }
  }

  _highlightRangeSecure(range, color, id, type = 'highlight') {
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
        this._replaceTextNodeWithVan(node, start, end, color, id, type);
      }
    }
  }

  _replaceTextNodeWithVan(textNode, start, end, color, id, type) {
    const text = textNode.textContent;
    const parts = [
      text.substring(0, start),
      text.substring(start, end),
      text.substring(end)
    ];

    const newNodes = [];
    if (parts[0]) newNodes.push(document.createTextNode(parts[0]));

    let lastClick = 0;

    newNodes.push(
      mark({
        class: `${this.highlightClass} type-${type}`,
        "data-id": id,
        "data-color": color,
        "data-type": type,
        style: type === 'underline'
          ? `text-decoration-color: ${color}; background-color: transparent !important;`
          : `background-color: ${color}80;`,
        onclick: (e) => {
          e.stopPropagation();
          const now = Date.now();
          const DIFF = now - lastClick;
          lastClick = now;

          // Aktuelle Farbe und Typ aus dem Element lesen (nicht aus der Closure)
          const currentColor = e.currentTarget.getAttribute('data-color') || color;
          const currentType = e.currentTarget.getAttribute('data-type') || type;

          this.activeHighlightId.val = id;
          this.activeColor.val = currentColor;
          this.activeType.val = currentType;
          this._updateHandles(id);

          if (DIFF < 300) {
            this._sendToFlutter('edit_note', { id: id });
            lastClick = 0;
          }
        }
      }, parts[1])
    );

    if (parts[2]) newNodes.push(document.createTextNode(parts[2]));
    textNode.replaceWith(...newNodes);
  }

  _serializeRange(range, color, id, note = null, tags = [], type = 'highlight') {
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
      color: color,
      type: type,
      note: note,
      tags: tags
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
      // Restore nutzt den in den Daten gespeicherten Typ (data.type)
      this._highlightRangeSecure(range, data.color, data.id, data.type || 'highlight');
      this.updateNoteIcon(data.id, data.note, data.tags);
    }
  }

  _generateUUID() {
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
      return crypto.randomUUID();
    }
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  _renderPreview(range, color) {
    if (!this.previewLayer) {
      this.previewLayer = div({
        style: 'position: absolute; top: 0; left: 0; width: 100%; height: 0; pointer-events: none; z-index: 9999;'
      });
      document.body.appendChild(this.previewLayer);
    }
    this.previewLayer.innerHTML = '';
    const rects = range.getClientRects();
    const scrollX = window.scrollX;
    const scrollY = window.scrollY;
    const type = this.currentDefaultType;

    for (const rect of rects) {
      const el = div({
        style: `
            position: absolute;
            left: ${rect.left + scrollX}px;
            top: ${rect.top + scrollY}px;
            width: ${rect.width}px;
            height: ${rect.height}px;
            ${type === 'underline'
            ? `border-bottom: 3px solid ${color};`
            : `background-color: ${color}40;`
          }
            pointer-events: none;
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
    const startHandle = handles[0];
    startHandle.style.left = (startRect.left + scrollX) + 'px';
    startHandle.style.top = (startRect.top + scrollY) + 'px';
    this._styleHandleInner(startHandle, startRect.height, true);
    const endHandle = handles[1];
    endHandle.style.left = (endRect.right + scrollX) + 'px';
    endHandle.style.top = (endRect.top + scrollY) + 'px';
    this._styleHandleInner(endHandle, endRect.height, false);
  }

  _getSafeCaretPosition(clientX, clientY) {
    let caretInfo = null;
    if (document.caretRangeFromPoint) {
      const range = document.caretRangeFromPoint(clientX, clientY);
      if (range) caretInfo = { node: range.startContainer, offset: range.startOffset };
    } else if (document.caretPositionFromPoint) {
      const pos = document.caretPositionFromPoint(clientX, clientY);
      if (pos) caretInfo = { node: pos.offsetNode, offset: pos.offset };
    }
    if (!caretInfo || caretInfo.node.nodeType !== Node.TEXT_NODE) return null;
    return caretInfo;
  }

  _initResizeDrag(e, isStartHandle, id) {
    e.preventDefault();
    e.stopPropagation();
    const handleElement = e.currentTarget;
    handleElement.setPointerCapture(e.pointerId);
    this.isDraggingHandle.val = true;
    document.body.style.userSelect = 'none';
    document.body.style.webkitUserSelect = 'none';
    const currentRange = this._reconstructRangeFromId(id);
    if (!currentRange) return;
    const existingMarks = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    const existingNoteText = existingMarks.length > 0 ? existingMarks[0].getAttribute('data-note') : null;
    existingMarks.forEach(el => el.style.opacity = '0.2');
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
    this.handlesContainer.style.pointerEvents = 'none';
    handleElement.style.pointerEvents = 'auto';
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
      lastValidRange = newRange;
      this._renderPreview(newRange, color);
      this._updateHandlesFromRange(newRange);
    };

    const onPointerUp = (upEvent) => {
      handleElement.releasePointerCapture(upEvent.pointerId);
      handleElement.removeEventListener('pointermove', onPointerMove);
      handleElement.removeEventListener('pointerup', onPointerUp);
      this.isDraggingHandle.val = false;
      document.body.style.userSelect = '';
      document.body.style.webkitUserSelect = '';
      this.handlesContainer.style.pointerEvents = 'none';
      Array.from(this.handlesContainer.children).forEach(el => el.style.pointerEvents = 'auto');
      this._removePreview();
      let finalRange = null;

      if (lastValidRange) {
        const startMarker = document.createElement('span');
        const endMarker = document.createElement('span');
        const rStart = lastValidRange.cloneRange();
        rStart.collapse(true);
        rStart.insertNode(startMarker);
        const rEnd = lastValidRange.cloneRange();
        rEnd.collapse(false);
        rEnd.insertNode(endMarker);
        const anchorEl = document.getElementById('cr-drag-anchor');
        if (anchorEl) anchorEl.remove();
        this._removeHighlightVisualsOnly(id, true);
        document.body.normalize();
        finalRange = document.createRange();
        finalRange.setStartAfter(startMarker);
        finalRange.setEndBefore(endMarker);
        startMarker.remove();
        endMarker.remove();
        document.body.normalize();
      } else {
        const anchorEl = document.getElementById('cr-drag-anchor');
        if (anchorEl) anchorEl.remove();
        this._removeHighlightVisualsOnly(id, true);
        document.body.normalize();
      }

      if (finalRange) {
        const oldEl = document.querySelector(`.${this.highlightClass}[data-id="${id}"]`);
        const type = this.activeType.val;
        const existingTagsStr = oldEl ? oldEl.getAttribute('data-tags') : '[]';
        const existingTags = JSON.parse(existingTagsStr || '[]');
        const serialized = this._serializeRange(finalRange, color, id, existingNoteText, existingTags, type);
        this._highlightRangeSecure(finalRange, color, id, type);
        this.updateNoteIcon(id, existingNoteText, existingTagsStr);
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

  _styleHandleInner(handleWrapper, height, isStart) {
    handleWrapper.style.height = height + 'px';
    const visual = handleWrapper.children[0];
    if (visual) visual.style.height = height + 'px';
    const knob = handleWrapper.children[1];
    if (knob) {
      const startOffset = -22;
      const endOffset = 0;
      knob.style.top = isStart ? `${startOffset}px` : `${height + endOffset}px`;
    }
  }

  scrollToHighlight(id) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    if (elements.length > 0) {
      const el = elements[0];
      el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      elements.forEach(mark => {
        const originalBg = mark.style.backgroundColor;
        mark.style.transition = 'background-color 0.4s ease';
        mark.style.backgroundColor = '#ffff00';
        setTimeout(() => {
          mark.style.backgroundColor = originalBg;
          setTimeout(() => mark.style.transition = '', 400);
        }, 800);
      });
    }
  }

  openNotesSheet(noteId) {
    this._sendToFlutter('open_notes_sheet', { noteId: noteId });
  }

  copyHighlightText(id) {
    if (!id) return;
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    let fullText = "";
    elements.forEach(el => { fullText += el.textContent; });
    this._sendToFlutter('copy_to_clipboard', { text: fullText.trim() });
    this._blinkFeedback(id);
  }

  _blinkFeedback(id) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    elements.forEach(el => {
      const originalOpacity = el.style.opacity || "1";
      el.style.opacity = "0.5";
      setTimeout(() => el.style.opacity = originalOpacity, 200);
    });
  }

  updateNoteIcon(id, noteText, tagsArray) {
    const elements = document.querySelectorAll(`.${this.highlightClass}[data-id="${id}"]`);
    if (elements.length === 0) return;

    // Erstmal bei allen Elementen aufräumen
    elements.forEach(el => {
      el.classList.remove('has-note');
      el.removeAttribute('data-note');
      el.removeAttribute('data-tags');
    });

    // Bestimme, ob wir Inhalt haben (Notiz oder Tags)
    let parsedTags = [];
    if (typeof tagsArray === 'string') {
      try { parsedTags = JSON.parse(tagsArray); } catch (e) { }
    } else if (Array.isArray(tagsArray)) {
      parsedTags = tagsArray;
    }

    const hasNote = noteText !== null && String(noteText).trim().length > 0;
    const hasTags = parsedTags && parsedTags.length > 0;

    if (hasNote || hasTags) {
      // Das Icon (::before) wird per CSS an .has-note gebunden
      elements[0].classList.add('has-note');

      if (hasNote) {
        elements[0].setAttribute('data-note', noteText);
      }
      if (hasTags) {
        elements[0].setAttribute('data-tags', JSON.stringify(parsedTags));
      }
    }
  }
}

window.cleanReadEngine = new CleanReadEngine();
