# PtzEditor.init('#redactor_intro')
# PtzEditor.init('#redactor_conetnt')

@PtzEditor = do ->
  tab_symbol: "    "
  tab_symbol_reg: new RegExp("^\ {1,4}")

  init: (selector) ->
    @init_events()
    @build_editor(selector)

  build_editor: (selector) ->
    items = $ selector

    for item, index in items
      item = $ item

      if !item.hasClass('ptz-editor--textarea')
        item.addClass 'ptz-editor--textarea'

        item_html = item[0].outerHTML

        item.replaceWith """
          <div class='ptz-editor--editor mt15 mb15 p10'>
            <div class='ptz-editor--tools pb5'>
              <span class='ptz_btn ptz_size-11 mr5' role='h2'>h2</span>
              <span class='ptz_btn ptz_size-11 mr5' role='h3'>h3</span>
              <span class='ptz_btn ptz_size-11 mr30' role='h4'>h4</span>

              <span class='ptz_btn ptz_size-11 mr5 b' role='b'>B</span>
              <span class='ptz_btn ptz_size-11 mr5 i' role='i'>I</span>
              <span class='ptz_btn ptz_size-11 mr5 u' role='u'>U</span>
              <span class='ptz_btn ptz_size-11 mr5 u' role='hl'>HL</span>
              <span class='ptz_btn ptz_size-11 mr30'   role='del'>DEL</span>

              <span class='ptz_btn ptz_size-11 mr5'      role='link'>LINK</span>
              <span class='ptz_btn ptz_size-11 mr5 mr30' role='img'>IMG</span>

              <span class='ptz_btn ptz_size-11 mr5' role='code'>CODE</span>
              <span class='ptz_btn ptz_size-11 mr5' role='yt'>YT</span>
              <span class='ptz_btn ptz_size-11 mr5 mr30' role='ig'>IG</span>

              <span class='ptz_btn ptz_size-11 mr5'      role='ol'>OL</span>
              <span class='ptz_btn ptz_size-11 mr5' role='ul'>UL</span>
            </div>
            <div class='ptz-tools--textarea-holder'>
              #{ item_html }
            </div>
          </div>
        """

  get_pattern_for: (role, selected_text = '') ->
    default_pattern = selected_text.length is 0

    if default_pattern
      switch role
        when 'h2'
          "\n## HEADER 2\n\n"
        when 'h3'
          "\n### HEADER 3\n\n"
        when 'h4'
          "\n#### HEADER 4\n\n"

        when 'b'
          "**BOLD TEXT**"
        when 'i'
          "*ITALIC TEXT*"
        when 'u'
          "_UNDERLINE_"
        when 'del'
          "~~DELETED~~"
        when 'hl'
          "==highlighted=="

        when 'link'
          """[LINK TEXT](http://site.com "Link title")"""
        when 'img'
          """![IMG ALT](http://site.com/img.png "Img title")"""

        when 'code'
          "\n\n```ruby\n# your code here\n```\n\n"

        when 'ol'
          """
            0. List item
            0. List item
            0. List item
          """
        when 'ul'
          """
            * List item
            * List item
            * List item
          """

        else
          " [PATTERN => #{ role } <= REQUIRED] "
    else
      switch role
        when 'h2'
          "\n\n## #{ selected_text }\n\n"
        when 'h3'
          "\n\n### #{ selected_text }\n\n"
        when 'h4'
          "\n\n#### #{ selected_text }\n\n"

        when 'b'
          "**#{ selected_text }**"
        when 'i'
          "*#{ selected_text }*"
        when 'u'
          "_#{ selected_text }_"
        when 'del'
          "~~#{ selected_text }~~"
        when 'hl'
          "==#{ selected_text }=="

        when 'link'
          """[LINK TEXT](#{ selected_text } "Link title")"""
        when 'img'
          """![IMG ALT](#{ selected_text } "Img title")"""

        when 'code'
          "\n\n```ruby\n#{ selected_text }\n```\n\n"

        else
          selected_text

  add_leading_tab: (text) ->
    _lines = []
    lines  = text.split "\n"

    for line, index in lines
      _lines.push "#{ PtzEditor.tab_symbol }#{ line }"

    _lines.join "\n"

  del_leading_tab: (text) ->
    _lines  = []
    lines   = text.split "\n"
    reg_exp = PtzEditor.tab_symbol_reg

    for line, index in lines
      _lines.push line.replace(reg_exp, '')

    _lines.join "\n"

  init_events: ->
    @events_inited ||= do ->
      doc = $ document

      doc.on 'keydown', '.ptz-editor--textarea', (e) ->
        ta = $(e.currentTarget)[0]

        # IF `TAB`
        if e.keyCode is $.ui.keyCode.TAB
          text      = ta.value
          ta_length = ta.value.length

          startPos  = ta.selectionStart
          endPos    = ta.selectionEnd

          # IF `TEXT SELECTED`
          if endPos - startPos > 0
            selected_text = text.substring(startPos, endPos)

            # IF `SHIFT`
            precessed_text = if e.shiftKey
              PtzEditor.del_leading_tab(selected_text)
            else
              PtzEditor.add_leading_tab(selected_text)

            first_part = text.substring(0, startPos) + precessed_text
            last_part  = text.substring(endPos, ta_length)
            ta.value   = first_part + last_part

            ta.selectionStart = startPos
            ta.selectionEnd   = first_part.length

            ta.focus()

            return false
          else
            # default behaviour =>
            # focus to new next item
            return true

      doc.on 'click', '.ptz-editor--editor [role]', (e) ->
        btn  = $ e.target
        role = btn.attr('role')

        editor = btn.parents('.ptz-editor--editor')
        ta     = editor.find('textarea')[0]

        text      = ta.value
        ta_length = ta.value.length

        startPos  = ta.selectionStart
        endPos    = ta.selectionEnd

        if endPos - startPos > 0
          selected_text = text.substring(startPos, endPos)
          pattern = PtzEditor.get_pattern_for(role, selected_text)
        else
          pattern = PtzEditor.get_pattern_for(role)

        first_part = text.substring(0, startPos) + pattern
        last_part  = text.substring(endPos, ta_length)
        ta.value   = first_part + last_part

        ta.selectionStart = first_part.length
        ta.selectionEnd   = ta.selectionStart

        ta.focus()
