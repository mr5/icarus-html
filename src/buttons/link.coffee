class LinkButton extends Button

  name: 'link'

  icon: 'link'

  htmlTag: 'a'

  disableTag: 'pre'

  render: (args...) ->
    super args...
#@popover = new LinkPopover
#  button: @
  _getAllAttributes: (element)->
    hash = {}
    return hash unless attrs = element.attributes
    for attr in attrs
      hash[attr.name] = attr.value
    console.log(hash)
    return hash
  _setAttributes: (element, attributes)->
    console.log '_setAttributes()', attributes
    for key of attributes
      element.attr(key, attributes[key])
  _status: ->
    super()

    if @active and !@editor.selection.rangeAtEndOf(@node)
      callback_id = @editor.addCallback this, (params)->
        @_setAttributes(@node, params.attributes)
        @node.text params.text
        @editor.inputManager.throttledValueChanged()
        @editor.removeCallback(callback_id)

      IcarusBridge.popover @name,
        JSON.stringify
          text: @node.text()
          attributes: @_getAllAttributes(@node[0])
        callback_id

      console.log("popover:" + @name);

#@popover.show @node
#else
#@popover.hide()

  command: ->
    range = @editor.selection.range()

    if @active
      txtNode = document.createTextNode @node.text()
      @node.replaceWith txtNode
      range.selectNode txtNode
    else
      $contents = $(range.extractContents())
      linkText = @editor.formatter.clearHtml($contents.contents(), false)
      if !linkText

        callback_id = @editor.addCallback this, (params)->
          $link = $('<a/>', params.attributes)
          $link.text params.text

          if @editor.selection.blockNodes().length > 0
            range.insertNode $link[0]
          else
            $newBlock = $('<p/>').append($link)
            range.insertNode $newBlock[0]

          range.selectNodeContents $link[0]

          @editor.trigger 'valuechanged'
          @editor.removeCallback(callback_id)
      else
        $link = $('<a/>', {})
        $link.text linkText
        if @editor.selection.blockNodes().length > 0
          range.insertNode $link[0]
        else
          $newBlock = $('<p/>').append($link)
          range.insertNode $newBlock[0]

        range.selectNodeContents $link[0]
        callback_id = @editor.addCallback this, (params)->
          @_setAttributes($link, params.attributes)
          $link.text params.text
          @editor.inputManager.throttledValueChanged()
          @editor.removeCallback(callback_id)

      IcarusBridge.popover @name,
        JSON.stringify
          text: linkText || ''
          attributes: {}
        callback_id

    #@popover.one 'popovershow', =>
    #  if linkText
    #    @popover.urlEl.focus()
    #    @popover.urlEl[0].select()
    #  else
    #    @popover.textEl.focus()
    #    @popover.textEl[0].select()
    @editor.selection.range range
    @editor.trigger 'valuechanged'


Simditor.Toolbar.addButton LinkButton
