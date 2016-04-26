class SimditorMention extends SimpleModule

  @pluginName: 'Mention'

  opts:
    mention: false

  active: false

  _init: ->
    @editor = @_module


    @_bind()


  _bind: ->
    @editor.on 'decorate', (e,$el)=>
      $el.find('a[data-mention]').each (i,link)=>
        @decorate $(link)

    @editor.on 'undecorate', (e,$el)=>
      $el.find('a[data-mention]').each (i,link)=>
        @undecorate $(link)

      $el.find('simditor-mention').children().unwrap()

    @editor.on 'pushundostate', (e)=>
      return false if @editor.body.find('span.simditor-mention').length > 0
      e.result


    @editor.on 'keydown', (e)=>
      return unless e.which is 229
      setTimeout =>
        range = @editor.selection.range()
        return unless range? and range.collapsed
        range = range.cloneRange()
        range.setStart range.startContainer, Math.max(range.startOffset - 1, 0)
        if range.toString() is '@' and not @active
          @editor.trigger $.Event 'keypress', {
            which: 64
          }
      , 50

    @editor.on 'keypress', (e)=>
      return unless e.which is 64

      $closestBlock = @editor.selection.blockNodes().last()
      return if $closestBlock.is 'pre'

      setTimeout =>
        range = @editor.selection.range()
        return unless range?

        range = range.cloneRange()
        range.setStart range.startContainer, Math.max(range.startOffset - 2, 0)
        return if /^[A-Za-z0-9]@/.test range.toString()
        @show()
      , 50

    @editor
    .on('keydown.simditor-mention', $.proxy(@_onKeyDown, this))
    .on('keyup.simditor-mention', $.proxy(@_onKeyUp, this))


    @editor.on 'blur',=>
      @hide() if @active




  show: ($target)->
    @active = true
    if $target
      @target = $target
    else
      @target = $('<span class="simditor-mention" />')
      range = @editor.selection.range()
      range.setStart range.startContainer, range.endOffset - 1
      range.surroundContents @target[0]

    @editor.selection.setRangeAtEndOf @target, range

    @popoverEl.find('.item:first')
    .addClass 'selected'
    .siblings '.item'
    .removeClass 'selected'

    @popoverEl.show()
    @popoverEl.find('.item').show()
    @refresh()





  decorate: ($link)->
    $link.addClass 'simditor-mention'

  undecorate: ($link)->
    $link.removeClass 'simditor-mention'




  selectItem: ->
    $selectedItem = @popoverEl.find '.item.selected'
    return unless $selectedItem.length > 0
    data = $selectedItem.data 'item'
    href = data.url || "javascript:;"
    $itemLink = $('<a/>',{
      'class':'simditor-mention'
      text: '@' + $selectedItem.attr('data-name')
      href: href
      'data-mention': true
    })

    @target.replaceWith $itemLink
    @editor.trigger "mention",[$itemLink,data]
    if @opts.mention.linkRenderer
      @opts.mention.linkRenderer($itemLink,data)

    if @target.hasClass 'edit'
      @editor.selection.setRangeAfter $itemLink
    else
      spaceNode = document.createTextNode '\u00A0'
      $itemLink.after spaceNode
      range = document.createRange()
      @editor.selection.setRangeAtEndOf spaceNode, range

    @hide()


  _changeFocus: (type)->
    selectedItem = @popoverEl.find '.item.selected'
    if selectedItem.length < 1
      @popoverEl.find '.item:first' .addClass 'selected'
      return false
    itemEl = selectedItem[type + 'All']('.item:visible').first()
    return false if itemEl.length < 1
    selectedItem.removeClass 'selected'
    itemEl.addClass 'selected'

    parentEl = itemEl.parent()
    parentH = parentEl.height()

    position = itemEl.position()
    itemH = itemEl.outerHeight()

    if position.top > parentH - itemH
      parentEl.scrollTop( itemH * itemEl.prevAll('.item:visible').length - parentH + itemH )
    if position.top < 0
      parentEl.scrollTop( itemH * itemEl.prevAll('.item:visible').length )


  _onKeyDown: (e)->
    return unless @active

    # left and right arrow
    if e.which is 37 or e.which is 39 or e.which is 27
      @editor.selection.save()
      @hide()
      @editor.selection.restore()
      return false
#up and down arrow, ctrl+p and ctrl+n
    else if e.which is 38 or (e.which is 80 and e.ctrlKey)
      @_changeFocus('prev')
      return false
    else if e.which is 40 or (e.which is 78 and e.ctrlKey)
      @_changeFocus('next')
      return false

#enter or tab to select item
    else if e.which is 13 or e.which is 9
      selectedItem = @popoverEl.find '.item.selected'
      if selectedItem.length
        @selectItem()
        return false
      else
        node = document.createTextNode @target.text()
        @target.before(node).remove()
        @hide()
        @editor.selection.setRangeAtEndOf node
# delete
    else if e.which is 8 and (@target.text() is '@' or @target.text() is '')
      node = document.createTextNode '@'
      @target.replaceWith node
      @hide()
      @editor.selection.setRangeAtEndOf node
# space
    else if e.which is 32
      text = @target.text()
      selectedItem = @popoverEl.find '.item.selected'
      if selectedItem.length and (text.substr(1) is selectedItem.text().trim())
        @selectItem()
      else
        node = document.createTextNode text + '\u00A0'
        @target.before(node).remove()
        @hide()
        @editor.selection.setRangeAtEndOf node
      return false

  _onKeyUp: (e)->
# 过滤快捷键, 以免触发refresh
    return if !@active or $.inArray(e.which, [9,16,17,27,37,38,39,40]) > -1 or (e.shiftKey and e.which == 50) or (e.ctrlKey and (e.which == 78 or e.which == 80))
    @filterItem()
    @refresh()

Simditor.connect SimditorMention

