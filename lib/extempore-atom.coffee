###
#  Extempore Plugin for Atom.
#  Implements the following public commands:
#
#      1. Connect():    [alt-o] connects to an already-running extempore server
#                       at 127.0.0.1:7099
#
#      2. Disconnect(): [shift-alt-o] disconnects from the existing server
#
#      3. Evaluate():   [alt-w] sends the selected text or, if there is none,
#                       the s-expression containing the cursor
#
# Todo-list:
#      @TODO: Add arguments for connect, to set port and server ip
#      @DONE: Consider converting entire file to Coffescript (easily doable
#             with js2.coffee) for maintanability
#
###

net = require('net')
StatusMessage = require('./status-message')
Dialog = require './dialog'

connected = false
client = null
statusClear = null
message = new StatusMessage('Message')
prompt = '<span style=\'color:rgb(206,89,97)\'>xtm>  </span>'
#function panic() {
#  send_string("(bind-func dsp (lambda (in:SAMPLE time:i64 channel:i64 data:SAMPLE*) 0))");
#}

###* Print string to status bar and remove it three seconds later ###

notify = (string) ->
  message.setText prompt + string
  clearTimeout statusClear
  statusClear = setTimeout((->
    message.setText prompt
    return
  ), 3000)
  return

###* ERROR specific version of notify() ###

error = (string) ->
  notify '<span style=\'color:rgb(206,89,97)\'>ERROR:</span> ' + string
  return

###* Send string to Extempore server for evaluation ###

send_string = (string) ->
  if !connected
    error 'Not connected'
  else
    client.write string + '\r\n'
  return

###* Reset the prompt and end the client, if required ###

disconnect = ->
  if client
    client.end()
  client = null
  connected = false
  message.setText '<span style=\'color:rgb(206,89,97)\'>DISCONNECTED</span>'
  clearTimeout statusClear
  statusClear = setTimeout((->
    message.setText ''
    return
  ), 3000)
  return

###*
# This function is an activationCommand. When it is called, it also calls
# this.activate()
###

connect = ->
  @dialog = new Dialog("localhost:7099")
  @dialog.attach()
  @dialog.on 'file-created', (event, createdPath) =>
    @dialog.close()
    connect_to_host(createdPath)

connect_to_host = (string) ->
  [HOST, PORT] = string.split(":")
  if !HOST
    HOST='localhost'
  if !PORT
    PORT=7099

  client = new (net.Socket)
  client.connect PORT, HOST, ->
    connected = true
    return
  client.on 'data', (data) ->
    notify data
    return
  client.on 'close', ->
    disconnect()
    return
  return

###*
# Looks for the first line above (or at) the cursor which starts with
###

evaluate = ->
  # Make sure we are in an Editor window
  editor = atom.workspace.getActiveTextEditor()
  # If there is currently selected text then send it
  selectedText = editor.getSelectedText()
  if selectedText
    range = editor.getSelectedBufferRange()
    marker = editor.markBufferRange(range)
    decoration = editor.decorateMarker(marker,
      type: 'highlight'
      class: 'highlight-region')
    setTimeout (->
      `var decoration`
      `var marker`
      `var range`
      decoration.destroy()
      return
    ), 100
    send_string selectedText
    return
  range = get_s_expression(editor)
  if !range
    return false
  marker = editor.markBufferRange(range)
  decoration = editor.decorateMarker(marker,
    type: 'line'
    class: 'highlight-line')
  setTimeout (->
    decoration.destroy()
    return
  ), 100
  lines = editor.getBuffer().getLines().slice(range[0][0], range[1][0] + 1).join('\n')
  send_string lines
  return

get_s_expression = (editor) ->
  # if there's no selected text, send the current s-expression the cursor is
  # in. @TODO Add additional error checking
  cursorRow = editor.getCursorBufferPosition().row
  bufferLines = editor.getBuffer().getLines()
  while cursorRow >= 0
    if bufferLines[cursorRow][0] == '('
      break
    cursorRow--
  left_parens = 0
  right_parens = 0
  endRow = cursorRow
  while endRow < bufferLines.length
    line = bufferLines[endRow]
    if !line
      error 's-expr parser failed'
      return null
    left_parens += (line.match(/\(/g) or []).length
    right_parens += (line.match(/\)/g) or []).length
    if left_parens == right_parens
      break
    endRow++
  range = [
    [
      cursorRow
      1
    ]
    [
      endRow
      bufferLines[endRow].length
    ]
  ]
  range

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'extempore-atom:Connect', @Connect
    atom.commands.add 'atom-workspace', 'extempore-atom:Disconnect', @Disconnect
    atom.commands.add 'atom-text-editor', 'extempore-atom:Evaluate', @Evaluate
    #atom.commands.add('atom-workspace', "extempore-atom:Panic", this.Panic);
    return
  Connect: ->
    connect()
    return
  Disconnect: ->
    disconnect()
    return
  Evaluate: ->
    evaluate()
    return
