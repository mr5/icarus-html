class HtmlButton extends Button

  name: 'html'

  icon: 'html5'

  disableTag: 'pre'


  _init: ->
    super()

  insertHtml: (html)->
    range = @editor.selection.range()
    console.log("insertHtml", range);
    if range is null
      @editor.setValue(@editor.sync() + html)
      @editor.trigger 'valuechanged'
      return


    if @editor.selection.blockNodes != undefined and @editor.selection.blockNodes().length > 0
      $node = $('<span></span>').html(html);
    else
      $node = $('<p></p>').html(html);

    range.insertNode $node[0]
    range.setStart($node[0], 1)
    @editor.selection.range range
    @editor.trigger 'valuechanged'
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


Simditor.Toolbar.addButton HtmlButton
