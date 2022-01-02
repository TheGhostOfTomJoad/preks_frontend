import './node_modules/codemirror/lib/codemirror.js'
//import './node_modules/codemirror/theme/monokai.css'
//import './node_modules/codemirror/lib/codemirror.css'
//import './codemirror.css'
import './node_modules/codemirror/mode/markdown/markdown.js'
import './node_modules/codemirror/mode/python/python.js'
import './node_modules/codemirror/mode/haskell/haskell.js'

import './node_modules/codemirror/keymap/vim.js'
import './node_modules/codemirror/keymap/sublime.js'
import './node_modules/codemirror/addon/search/searchcursor.js'
import './node_modules/codemirror/addon/mode/simple.js'

//import './node_modules/codemirror/mode/preks/preks.js'
import './preks.js'

customElements.define('code-mirror',
  class extends HTMLElement {
    connectedCallback() {
      this._editor = CodeMirror(this, {
        indentUnit: 4,
        mode: this.mode,
        theme: this.theme,
        lineNumbers: true,
        keyMap: this.keymap,
        value: this._editorValue,
        autofocus: true
      });

      this._editor.on('changes', () => {
          this._editorValue = this._editor.getValue()
          this.dispatchEvent(new CustomEvent('editorChanged'))
          })
    }

    constructor() {
      super();

      this.mode = this.getAttribute('mode');
      this.keymap = this.getAttribute('keymap');
      this.theme = this.getAttribute('theme');
      this._editorValue = this.getAttribute('editorValue');

      const editorElem = document.createElement("editor");
    }

    get editorValue() {
        return this._editorValue;
    }
    set editorValue(v) {
        if (this._editorValue === v) return
        this._editorValue = v
        if (!this._editor) return
        this._editor.setValue(v)
    }

  })

