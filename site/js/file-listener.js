//////////////////////////////////////////////////////////////////////
//
// file-listener.js
// Define the `file-listener` custom element.
// Copyright (c) 2018 Bill St. Clair <billstclair@gmail.com>
// Some rights reserved.
// Distributed under the MIT License
// See LICENSE
//
//////////////////////////////////////////////////////////////////////

/* Debugging code
var file;
var body;
var listener;

function setupFileListener() {
  file = document.createElement('input');
  file.id = 'thefile';
  file.type = 'file';
  body = document.children[0].children[1];
  body.appendChild(file);
  listener = document.createElement('file-listener');
  body.appendChild(listener);
  listener.fileId = 'thefile';
}
*/

(function() {

  // *** Begin patch to enable sending binary data. ***
  //

  // From https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
  function binarySend(sData) {
    var nBytes = sData.length, ui8Data = new Uint8Array(nBytes);
    for (var nIdx = 0; nIdx < nBytes; nIdx++) {
      ui8Data[nIdx] = sData.charCodeAt(nIdx) & 0xff;
    }
    /* send as ArrayBufferView...: */
    this.wwsUnpatchedSend(ui8Data);
    /* ...or as ArrayBuffer (legacy)...: this.send(ui8Data.buffer); */
  }

  function patchedSend(data) {
    if (typeof(data) != 'string') {
      return this.wwsUnpatchedSend(data);
    }
    var lines = data.split('\r\n');
    for (var i in lines) {
      var line = lines[i];
      if (line.startsWith('Content-Type: image')) {
        return this.wwsBinarySend(data);
      }
    }
    return this.wwsUnpatchedSend(data);
  }

  // Install the patch
  if (!XMLHttpRequest.prototype.wwsUnpatchedSend) {
    XMLHttpRequest.prototype.wwsUnpatchedSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.wwsBinarySend = binarySend;
    XMLHttpRequest.prototype.send = patchedSend;
  }


  //
  // *** End patch to enable sending binary data ***


  function getFile(id) {
    return document.getElementById(id);
  }

  function attachFile(listener, fileId, count) {
    var file = getFile(fileId);
    if (file) {
      listener._file = file;
      listener._onChange = function() {
        // `this` should be the file here. Use `file` instead?
        onFileChange(listener, this);
      };
      // Will Elm's DOM synchronization remove this? We'll see.
      file.addEventListener('change', listener._onChange, false);
    } else {
      count = 1 + (count || 0);
      if (count > 10) return;
      setTimeout(function() { attachFile(listener, fileId, count) }, 100);
    }
  }

  function onFileChange(listener, file) {
    var files = file.files;
    if (!files || files.length < 1) return;
    file = files[0];

    var reader = new FileReader();
    reader.onload = function(e) {
      var data = e.target.result;
      reader = new FileReader();
      reader.onload = function(e) {
        listener._contents =
          { name: file.name,
            lastModified: file.lastModified,
            mimeType: file.type,
            size: file.size,
            data: data,
            dataUrl: e.target.result
        };
        //console.log('Loaded:', listener._contents);
        listener.dispatchEvent(new CustomEvent('load'));
      }
      reader.readAsDataURL(file);
    }
    //console.log('Reading:', file);
    reader.readAsBinaryString(file);
  }

  customElements.define('file-listener', class extends HTMLElement {
    constructor() {
      super();

      // Properties
      this._fileId = null;
      this._contents = null;

      // State
      this._file = null;
      this._onChange = null;
    }

    get contents() {
      return this._contents;
    }

    get fileId() {
      return this._fileId
    }

    set fileId(value) {
      if (this._fileId === value) return;
      var file = this._file;
      if (file) {
        file.removeEventListener('change', this._onChange);
        this._file = null;
        this._onChange = null;
      }
      var fileId = value;
      this._fileId = fileId;
      if (fileId) {
        attachFile(this, fileId);
      }
    }

    connectedCallback() {
      // Move along. Nothing to see here.
    }
  })

})();
