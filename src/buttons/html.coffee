class HtmlButton extends Button

  name: 'html'

  icon: 'html5'

  disableTag: 'pre'


  _init: ->
    super()

  insertHtml: (html)->
    range = @editor.selection.range()
    console.log("insertHtml", range);
    $node = $(html)
    if @editor.selection.blockNodes().length > 0
      range.insertNode $node[0]
    else
      $newBlock = $('<p/>').append($node)
      range.insertNode $newBlock[0]
    $brNode = $('<br>')[0]
    range.insertNode $brNode
    range.selectNode $brNode
  command: ()->
    callback_id = @editor.addCallback @, (params)->
      @insertHtml params.content
    IcarusBridge.popover @name,
      JSON.stringify
        content: ""
      callback_id

    #@popover.one 'popovershow', =>
    #  if linkText
    #    @popover.urlEl.focus()
    #    @popover.urlEl[0].select()
    #  else
    #    @popover.textEl.focus()
    #    @popover.textEl[0].select()

    #@editor.selection.range range

    #@editor.selection.set();
    @editor.focus()
    @editor.trigger 'valuechanged'


Simditor.Toolbar.addButton HtmlButton
