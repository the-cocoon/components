# Сколько бы событий не произошло
# Обработчик будет выполнен только 1 раз
# после завершения событий через N ms
@debounce = (func, wait, immediate) ->
  timeout = undefined
  result  = undefined

  ->
    context = this
    args = arguments

    later = ->
      timeout = null
      result  = func.apply(context, args) unless immediate
      return true

    callNow = immediate and not timeout
    clearTimeout timeout

    timeout = setTimeout(later, wait)

    if callNow
      result = func.apply(context, args)

    result

# Сколько бы событий не произошло
# Обработчик будет выполнятся толко 1 раз каждые N ms
@throttle = (func, wait) ->
  previous = 0

  context = undefined
  args    = undefined
  timeout = undefined
  result  = undefined

  later = ->
    timeout  = null
    previous = new Date
    result   = func.apply(context, args)
    return true

  ->
    now = new Date
    remaining = wait - (now - previous)

    context = this
    args    = arguments

    if remaining <= 0
      clearTimeout timeout
      timeout  = null
      previous = now

      result = func.apply(context, args)
    else
      unless timeout
        timeout = setTimeout(later, remaining)

    result