/*
 *  Extempore Plugin for Atom.
 *  Implements the following public commands:
 *
 *      1. Connect():    [alt-o] connects to an already-running extempore server
 *                       at 127.0.0.1:7099
 *
 *      2. Disconnect(): [shift-alt-o] disconnects from the existing server
 *
 *      3. Evaluate():   [alt-w] sends the selected text or, if there is none,
 *                       the s-expression containing the cursor
 *
 * Todo-list:
 *      @TODO: Add arguments for connect, to set port and server ip
 *      @TODO: Consider converting entire file to Coffescript (easily doable
 *             with js2.coffee) for maintanability
 *
 */

var net = require('net');
var StatusMessage = require('./status-message')

var connected = false;
var client = null;
var statusClear = null;

var message = new StatusMessage('Message')
var prompt = "<span style='color:rgb(206,89,97)'>xt>  </span>";

/** Print string to status bar and remove it three seconds later */
function notify(string) {
  message.setText(prompt+string);
  clearTimeout(statusClear);
  statusClear = setTimeout(function() {message.setText(prompt)}, 3000);
}

/** Used instead of notify for errors */
function error(string) {
  notify("<span style='color:rgb(206,89,97)'>ERROR:</span> "+string);
}

/** Send string to server */
function send_string(string) {
  if(!connected) error("Not connected")
  else client.write(string+"\r\n");
}

/** Reset the prompt and end the client, if required */
function lost_connection() {
  if(client)
    client.end();
  client = null;
  connected = false;
  message.setText("<span style='color:rgb(206,89,97)'>DISCONNECTED</span>");
  clearTimeout(statusClear);
  statusClear = setTimeout(function() {message.setText("")}, 3000);
}


module.exports = {

  activate: function() {
    atom.commands.add('atom-workspace', "extempore-atom:Connect", this.Connect);
    atom.commands.add('atom-workspace', "extempore-atom:Disconnect", this.Disconnect);
    atom.commands.add('atom-text-editor', "extempore-atom:Evaluate", this.Evaluate);
    atom.commands.add('atom-text-editor', "extempore-atom:EvaluateFile", this.EvaluateFile);
    atom.commands.add('atom-workspace', "extempore-atom:Panic", this.Panic);
  },

  /**
   * This function is an activationCommand. When it is called, it also calls
   * this.activate()
   */
  Connect: function() {
    //selection.insertText("123");
    var HOST = '127.0.0.1';
    var PORT = 7099;
    client = new net.Socket();
    client.connect(PORT, HOST, function() { connected = true });
    client.on('data', function(data) { notify(data); });
    client.on('close', function() { lost_connection() });
  },

  /**
   * Disconnects from the server.
   */
  Disconnect: function() {
    lost_connection();
  },

  /**
   * Looks for the first line above (or at) the cursor which starts with
   */
  Evaluate: function() {
    // Make sure we are in an Editor window
    editor = atom.workspace.getActiveTextEditor();

    // If there is currently selected text then send it
    var selectedText = editor.getSelectedText();
    if(selectedText) {
      send_string(selectedText);
      return
    }

    // if there's no selected text, send the current s-expression the cursor is
    // in. @TODO Add additional error checking
    var cursorRow = editor.getCursorBufferPosition().row;
    var bufferLines = editor.getBuffer().getLines();
    for(;cursorRow>=0;cursorRow--) {
      if(bufferLines[cursorRow][0]=='(') {
        break;
      }
    }

    var left_parens=0
    var right_parens= 0
    for(var endRow = cursorRow; endRow<bufferLines.length;endRow++) {
      var line = bufferLines[endRow];
      if(!line) {
        error("s-expr parser failed")
        continue;
      }
      left_parens+=(line.match(/\(/g)||[]).length;
      right_parens+=(line.match(/\)/g)||[]).length;
      if(left_parens==right_parens)
        break;
    }

    var lines = bufferLines.slice(cursorRow,endRow+1).join("\n");
    send_string(lines);
  },

  EvaluateFile: function() {
    var editor = atom.workspace.getActivePaneItem();
    var editorText = editor.getText();

    send_string(editorText)
  },

  Panic: function () {
      send_string("(bind-func dsp (lambda (in:SAMPLE time:i64 channel:SAMPLE data:SAMPLE*) 0.0))");
  }

};
