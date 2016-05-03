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
#      ...
#
###

net = require('net')
StatusMessage = require('./status-message')
Dialog = require './dialog'

connected = false
client = null
statusClear = null
message = new StatusMessage('Message')
message.setText("")
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
  client.setKeepAlive(true,60000);
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

    # TODO: use more robust comment and string checking
    line = (line.match(/^([^"]|"[^"]*")*?(;)/) or [line])[0]; # ignore comments
    line = line.replace(/"(.*?)"/,"\"\""); # ignore strings
    
    left_parens += (line.match(/\(/g) or []).length
    right_parens += (line.match(/\)/g) or []).length
    if left_parens == right_parens
      break
    endRow++
  if endRow == bufferLines.length
    error 'Unmatched bracket in expression (reached EOF)'
    return null
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

start_extempore = ->
  ###term2path = atom.packages.resolvePackagePath('term2')
  TermView = require(term2path + '/lib/TermView.coffee')
  options =
    runCommand: 'extempore'
  termView = new TermView(options)###
  #term2path = atom.packages.resolvePackagePath('term2')
  #Term2  = require(term2path + '/index.coffee')
  #Term2.newTerm()

  ###
  opts =
    runCommand    : 'extempore'
    shellOverride : atom.config.get 'term2.shellOverride'
    shellArguments: atom.config.get 'term2.shellArguments'
    titleTemplate : atom.config.get 'term2.titleTemplate'
    cursorBlink   : atom.config.get 'term2.cursorBlink'
    fontFamily    : atom.config.get 'term2.fontFamily'
    fontSize      : atom.config.get 'term2.fontSize'
    colors        : Term2.getColors()

  termView = new TermView opts
  termView.on 'remove', Term2.handleRemoveTerm.bind Term2

  #Term2.termViews.push? termView

  #termView = Term2.createTermView()

  pane = atom.workspace.getActivePane()
  item = pane.addItem termView
  #pane.activateItem item
  item.bind(Term2)
  ###



module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'extempore-atom:Connect', @Connect
    atom.commands.add 'atom-workspace', 'extempore-atom:Disconnect', @Disconnect
    atom.commands.add 'atom-text-editor', 'extempore-atom:Evaluate', @Evaluate
    #atom.commands.add 'atom-text-editor', 'extempore-atom:Start Extempore (requires term2)', @StartExtempore
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
  StartExtempore: ->
    start_extempore()
    return
