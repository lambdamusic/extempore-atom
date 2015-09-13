{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class Dialog extends View
  @content: () ->
    @div class: 'tree-view-dialog', =>
      @label "Choose Extempore process to connect to:", class: 'icon', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)

  initialize: (initialPath) ->
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close()
    @miniEditor.getModel().setText(initialPath)

  onConfirm: (newPath) ->
    @trigger 'file-created', [newPath]

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
