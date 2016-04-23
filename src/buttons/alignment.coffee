class AlignmentButton extends Button

  name: "alignment"

  icon: 'align-left'

  htmlTag: 'p, h1, h2, h3, h4, td, th'

#  _init: ->
#    @menu = [{
#      name: 'left',
#      text: @_t('alignLeft'),
#      icon: 'align-left',
#      param: 'left'
#    }, {
#      name: 'center',
#      text: @_t('alignCenter'),
#      icon: 'align-center',
#      param: 'center'
#    }, {
#      name: 'right',
#      text: @_t('alignRight'),
#      icon: 'align-right',
#      param: 'right'
#    }]
#    super()

  setActive: (active, align = 'left') ->
    align = 'left' unless align in ['left', 'center', 'right']
    if align == 'left'
      @editor.toolbar.buttons['alignLeft'].setActive(false)
      @editor.toolbar.buttons['alignCenter'].setActive(false)
      @editor.toolbar.buttons['alignRight'].setActive(false)
    else if align == 'center'
      @editor.toolbar.buttons['alignLeft'].setActive(false)
      @editor.toolbar.buttons['alignCenter'].setActive(active)
      @editor.toolbar.buttons['alignRight'].setActive(false)
    else if align == 'right'
      @editor.toolbar.buttons['alignLeft'].setActive(false)
      @editor.toolbar.buttons['alignCenter'].setActive(false)
      @editor.toolbar.buttons['alignRight'].setActive(active)
      #super active
    else align == 'right'
    @el.removeClass 'align-left align-center align-right'
    @el.addClass('align-' + align) if active
#    @setIcon 'align-' + align
#    @menuEl.find('.menu-item').show().end()
#    .find('.menu-item-' + align).hide()

  _status: ->
    @nodes = @editor.selection.nodes().filter(@htmlTag)
    if @nodes.length < 1
      @setDisabled true
      @setActive false
    else
      @setDisabled false
      @setActive true, @nodes.first().css('text-align')

  command: (align) ->
    unless align in ['left', 'center', 'right']
      throw new Error("simditor alignment button: invalid align #{align}")

    @nodes.css
      'text-align': if align == 'left' then '' else align

    @editor.trigger 'valuechanged'
    @editor.inputManager.throttledSelectionChanged()

class AlignLeftButton extends Button
  name: "alignLeft"
  icon: 'align-left'
  disableTag: 'pre'


  command: ()->
    @editor.toolbar.buttons['alignment'].command('left')
  _status: ()->
    @_disableStatus()
    return if @disabled

class AlignRightButton extends Button
  name: "alignRight"
  icon: 'align-right'
  disableTag: 'pre'


  command: ()->
    @editor.toolbar.buttons['alignment'].command('right')
  _status: ()->
    @_disableStatus()
    return if @disabled

class AlignCenterButton extends Button
  name: "alignCenter"
  icon: 'align-center'
  disableTag: 'pre'

  command: ()->
    @editor.toolbar.buttons['alignment'].command('center')
  _status: ()->
    @_disableStatus()
    return if @disabled

Simditor.Toolbar.addButton AlignmentButton
Simditor.Toolbar.addButton AlignLeftButton
Simditor.Toolbar.addButton AlignRightButton
Simditor.Toolbar.addButton AlignCenterButton

