String::interpolate = (o) ->
  @replace /%{([^{}]*)}/g, (a, b) ->
    r = o[b]
    if typeof r == 'string' or typeof r == 'number' then r else a

@CustomSelect = do ->
  init: (selector, options) ->
    items = $ selector
    return false unless items.length
    @new($(item), options) for item in items

  new: (select, options) ->
    @set_options_for(select, options)

    select.hide()

    holder   = @wrap_item_with_html(select)
    selected = holder.find('.custom-select--selected')
    ul       = holder.find('.custom-select--select')

    selected.html @selected_text_for(select)

    options_html = @build_options_for(select)
    ul.append(options_html)

    if @get_options_for(select)['solid']
      # Set inited state
      @no_results_visibility_for select, inited=true
      @recalc_list_height_for    select, inited=true
      @recalc_list_min_width_for select

    @events_init()

  # ms = $('select:first')
  # CustomSelect.rebuild(ms, { size: 5, disabled: false, search: true })
  rebuild: (select, options) ->
    holder  = select.parents('.custom-select')

    _select = select.clone(true, true)
    _opts   = _select.find('option')

    # clone selected options
    for option, index in select.find('option')
      option = $ option
      $(_opts[index]).prop('selected', true) if option.is(':selected')

    holder.replaceWith _select
    @new(_select, options)

  # OPTIONS
  set_options_for: (select, _options) ->
    # inline opts
    _noscroll = select.attr('noscroll')
    _noscroll = true if _noscroll is 'noscroll'

    _checkboxed = select.attr('checkboxed')
    _checkboxed = true if (_checkboxed is 'true') || (_checkboxed is 'checkboxed')

    _solid = select.attr('solid')
    _solid = true if (_solid is 'true') || (_solid is 'solid')

    _disabled = select.is(':disabled')
    _size     = parseInt (select.attr('size') || 5), 10

    # default values
    options =
      size:   _size
      solid:  false
      search: false
      disabled:   _disabled
      noscroll:   _noscroll
      checkboxed: _checkboxed

    # options by priority
    if html_options = select.data('custom-select-options')
      $.extend(options, html_options) if html_options

    if data_options = select.data('options')
      $.extend(options, data_options)

    if _options
      $.extend(options, _options)

    # store options
    select.data('options', options)

  get_options_for: (select) ->
    select.data('options')

  # EVENTS
  events_init: ->
    @events_inited ||= do =>
      doc = $ document

      # ON DOCUMENT
      doc.on 'click', (e) ->
        item      = $ e.target
        ms_holder = item.parents('.custom-select:not(.solid)')
        non_solid_selects = $('.custom-select:not(.solid)')

        # item is not custom-selector child
        if ms_holder.length is 0
          return non_solid_selects.find('.custom-select--list').fadeOut(100)

        # item is custom-selector child
        # we will close all custom-selectors except this
        all_lists = non_solid_selects.find('.custom-select--list:visible')
        this_list = ms_holder.find('.custom-select--list')
        all_lists.not(this_list).hide()

      # SHOW LIST
      doc.on 'click', '.custom-select .custom-select--selected', (e) =>
        item   = $ e.currentTarget
        return true if item.hasClass('disabled')

        holder = item.parents('.custom-select')
        select = holder.find('select')
        list   = holder.find('.custom-select--list')

        # Set inited state
        @no_results_visibility_for select, inited=true
        @recalc_list_height_for    select, inited=true
        @recalc_list_min_width_for select

        list.fadeToggle 100, ->
          # set carriage at the end of Search Input
          input = list.find('input:visible')
          if input.length isnt 0
            len = input.val().length
            input.focus()[0].setSelectionRange(len, len)

      # ON OPTION CLICK
      doc.on 'click', '.custom-select--option:not(.no-results)', (e) =>
        item = $ e.currentTarget
        @set_option_for(item)

      # SEARCH
      doc.on 'keyup', '.custom-select--search-input', (e) =>
        input  = $ e.currentTarget

        holder = input.parents('.custom-select')
        lis    = holder.find('.custom-select--option:not(.no-results)')
        select = holder.find('select')

        text = input.val().trim()
        rexp = RegExp(text, 'mig')
        replacer = "<b>$&</b>"

        if text.length is 0
          lis.removeClass('hidden')

          lis.each (index, li) ->
            li = $ li
            new_text = li.text().replace(rexp, replacer)

            li.html new_text
        else
          lis.addClass('hidden')

          selected = lis.each (index, li) ->
            li = $ li
            new_text = li.text().replace(rexp, replacer)

            if li.text().match(rexp)
              li.removeClass('hidden')
              li.html new_text

        @no_results_visibility_for(select)
        @recalc_list_height_for(select)

      true

  recalc_list_min_width_for: (select) ->
    # holder   = select.parents('.custom-select')
    # list     = holder.find('.custom-select--list')
    # list.css { 'min-width': holder.outerWidth() }

  # option `inited`
  # on first show of list we haven't worry about visibility of options
  #
  recalc_list_height_for: (select, inited = false) ->
    holder  = select.parents('.custom-select')
    opts    = @get_options_for(select)

    ul      = holder.find('.custom-select--select')
    hiddens = ul.find('.custom-select--option.hidden')

    visibilty = if inited then '' else ':visible'

    # NOTE:
    # It's very important to have css rule `height` for `li`
    # because it will be impossible to find actual height for hidden items
    li_height = ul.find('.custom-select--option').first().outerHeight()

    max_size  = opts['size']
    real_size = ul.find(".custom-select--option#{ visibilty }").not(hiddens).length

    if opts['solid']
      ul.css 'height': li_height * max_size
    else
      if real_size < max_size
        ul.css 'height': 'auto'
      else
        ul.css 'height': li_height * max_size

  # option `inited`
  # on first show of list we haven't worry about visibility of options
  #
  no_results_visibility_for: (select, inited = false) ->
    holder = select.parents('.custom-select')

    no_results = holder.find('.custom-select--option.no-results')
    hiddens    = holder.find('.custom-select--option.hidden')

    visibilty = if inited then '' else ':visible'

    if holder.find(".custom-select--option#{ visibilty }").not(hiddens).not(no_results).length is 0
      no_results.removeClass 'hidden'
      no_results.show()
    else
      no_results.addClass 'hidden'
      no_results.hide()

  set_option_for: (item) ->
    holder = item.parents('.custom-select')
    select = holder.find('select')
    opts   = @get_options_for(select)

    if select.attr('multiple') is 'multiple'
      @set_multiple_selected_value_for(item)
    else
      @set_single_selected_value_for(item)

    # CHANGE EVENT CALLBACK EXEC
    opts['change'](select, item) if opts['change']
    select.change()

  set_selected_value_for: (holder) ->
    selected = holder.find('.custom-select--selected')
    select   = holder.find('select')
    selected.html @selected_text_for(select)

  selected_text_for: (select) ->
    selected_text = if select.attr('multiple') is 'multiple'
      @text_for_multiple_selected_for(select)
    else
      @text_for_single_selected_for(select)

  # MULTIPLE
  set_multiple_selected_value_for: (item) ->
    holder   = item.parents('.custom-select')
    selected = holder.find('.custom-select--selected')
    select   = holder.find('select')

    item.toggleClass('true')

    k = item.text()
    v = item.data('value')
    state = item.hasClass('true')

    select.find("option[value='#{ v }']").prop('selected', state)
    selected.html @selected_text_for(select)

  text_for_multiple_selected_for: (select) ->
    count = select.find('option:selected').length

    if count is 0
      @locale(select, 'not_set')
    else
      @locale(select, 'selected').interpolate { count: count }

  # SINGLE
  set_single_selected_value_for: (item) ->
    holder   = item.parents('.custom-select')
    selected = holder.find('.custom-select--selected')
    select   = holder.find('select')

    item.addClass('true')

    # get current state
    k = item.text()
    v = item.data('value')
    state = item.hasClass('true')

    # reset values
    holder.find('.custom-select--option').removeClass('true')
    select.find('option').prop("selected", false)

    # set select value
    select.find("option[value='#{ v }']").prop("selected", state)
    item.addClass('true') if state

    selected.html @selected_text_for(select)
    holder.find('.list').fadeOut(100)

  text_for_single_selected_for: (select) ->
    selected = select.find('option:selected')
    return selected.text() if selected.length
    "&nbsp;"

  # RENDERING
  build_options_for: (select) ->
    options = select.find('option')

    html = ''

    for option in options
      option = $ option

      s = option.is(':selected')
      k = option.text()
      v = option.val()

      html += @option_template(k, v, s)

    html += @no_options_template( @locale(select, 'no_results') )
    html

  # LOCALE
  locale: (select, key)  ->
    locale = select.data('locale') || {}
    return text if text = locale[key]
    key

  # HTML TEMPLATES

  # .custom-select
  #   div(style='display:none')
  #   .custom-select--selected= 0
  #   .custom-select--list-holder
  #     .custom-select--list
  #       .custom-select--list-title Some title
  #       .custom-select--search
  #         input.custom-select-input(type=text)
  #       ul.custom-select--select
  #         li.custom-select--option= 10
  #         li.custom-select--option= 20
  #         li.custom-select--option= 30
  #         li.custom-select--option= 40

  wrap_item_with_html: (select) ->
    opts = @get_options_for(select)

    title       = @locale(select, 'title')
    placeholder = @locale(select, 'placeholder')

    with_search = if opts['search']     then 'with-search' else ''
    disabled    = if opts['disabled']   then 'disabled'    else ''
    noscroll    = if opts['noscroll']   then 'noscroll'    else ''
    checkboxed  = if opts['checkboxed'] then 'checkboxed'  else ''
    solid       = if opts['solid']      then 'solid'       else ''

    select.wrap """
      <div class='custom-select #{ solid }'>
        <div style='display:none'></div>

        <div class='custom-select--selected #{ disabled }' style='z-index:2'></div>
        <div class='custom-select--list-holder' style='z-index:3'>

          <div class='custom-select--list #{ with_search } #{ checkboxed }'>
            <div class='custom-select--list-title'>#{ title }</div>

            <div class='custom-select--search'>
              <input type='text' placeholder='#{ placeholder }' class='custom-select--search-input'>
            </div>

            <ul class='custom-select--select #{ noscroll }'></ul>
          </div>

        </div>
      </div>
    """

    # return root item
    select.parents('.custom-select')

  option_template: (k, v, selected) ->
    """
    <li data-value='#{ v }' class='custom-select--option #{ selected }'>#{ k }</li>
    """

  no_options_template: (text) ->
    """
    <li data-role='no-results' class='custom-select--option no-results'>#{ text }</li>
    """

# RESET BUTTON
# doc.on 'click', '@custom_select_reset', (e) =>
#   btn = $ e.currentTarget
#   return if btn.hasClass 'disabled'

#   ms_id  = btn.data('custom-select-id')

#   select = $("select[data-custom-select-id=#{ ms_id }]")
#   holder = select.parents('.custom-select')
#   list   = holder.find('.list')

#   select.find('option').prop('selected', false)
#   list.find('li').removeClass 'true'
#   @set_selected_value_for(holder)
