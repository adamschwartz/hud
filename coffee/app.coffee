delay = (time, fn) ->
  setTimeout fn, time * 1000

dom = ->
  dom =
    messagesEl: document.querySelector '.center-messages'
    clock: document.querySelector '.clock'

animateLetters = (text) ->
  """<div class="animate-letters"><span>#{ text.split('').join('</span><span>') }</span></div>"""

uiText = (text) ->
  """<div class="ui-text">#{ text }</div>"""

message = (text) ->
  dom.messagesEl.innerHTML = """
    <div class="center-message">
      <div class="content">
        #{ uiText animateLetters text }
      </div>
    </div>
  """

messageOut = (next) ->
  lastMessage = dom.messagesEl.querySelector('.center-message')
  if lastMessage?
    lastMessage.classList.add 'animate-blur-out'

    # TODO - use animation CSS event here instead
    delay 1.05, -> next()

  else
    next()

prompt = (text, responses = ['Yes', 'No'], callback = ->) ->
  messageOut ->
    message text

    dom.messagesEl.querySelector('.content').insertAdjacentHTML 'beforeend', """
      <div class="buttons" style="opacity: 0; pointer-events: none"><div class="button">#{ uiText '&nbsp;' }</div></div>
    """

    delay text.length * .05, ->
      buttons = dom.messagesEl.querySelector('.buttons')
      buttons.parentNode?.removeChild buttons

      html = '<div class="buttons">'
      for response in responses
        html += """<a tabindex="0" class="button animate-fade-in animate-in-dominos">#{ uiText animateLetters response }</a>"""
      html += '</div>'

      dom.messagesEl.querySelector('.content').insertAdjacentHTML 'beforeend', html

      for response, i in responses
        do (response, i) ->
          dom.messagesEl.querySelector(".buttons a.button:nth-child(#{ i + 1 })").addEventListener 'mousedown', (event) ->
            callback response

startWelcomeMessages = ->
  return unless dom.messagesEl

  message 'One day'

  delay 2, ->
    prompt 'One day make a choice', ['Red', 'Blue'], (choice) ->
      messageOut ->
        message "You selected #{ choice }" # TODO

        delay 2, ->
          messageOut ->
            message "Personalizing..."

          delay 2, ->
            messageOut ->
              message ''
              startClock()

startClock = ->
  return unless dom.clock

  setInterval ->
    dom.clock.querySelector('.seconds').setAttribute 'data-progress', Math.floor((new Date()).getSeconds() * (100 / 60))
    dom.clock.querySelector('.minutes').setAttribute 'data-progress', Math.floor((new Date()).getMinutes() * (100 / 60))
    dom.clock.querySelector('.hours').setAttribute 'data-progress', Math.floor(((new Date()).getHours() % 12) * (100 / 12))

startDraggableWindows = ->
  windowAtDepth = (z) ->
    found = false
    $('.world .window').each ->
      if parseInt($(@).data('z'), 10) is z
        found = true
    return found

  nonCollidingDepth = (z) ->
    z = -40 if z < -40 # TODO - base off of grid depth
    z = 15 if z > 15

    while windowAtDepth z
      z += 1

    z

  zIndexFromDepth = (z) ->
    zIndex = parseInt 1000 + z

  urls = [
    'http://mit.edu'
    'http://duckduckgo.com'
    'http://adamschwartz.co'
  ]

  $(window).dblclick (event) ->
    size = 600

    url = urls[Math.floor Math.random() * urls.length]

    win = $("""<div class="window"><div class="bar"></div><iframe src="#{ url }"></iframe></div>""").css
      left: event.clientX - (size / 2)
      top: event.clientY - (size / 2)
      width: size
      height: size

    win.draggable()
    win.resizable()

    z = nonCollidingDepth(-5) # TODO - why -5?

    # TODO - refactor
    win.data 'z', z
    win.css
      '-webkit-transform': "translateZ(#{ win.data 'z' }em)"
      'z-index': zIndexFromDepth(z)

    win.on 'mousewheel', (event, delta) ->
      event.preventDefault()
      event.stopPropagation()

      z = parseFloat win.data('z')
      z = z + delta
      z = nonCollidingDepth z

      # TODO - refactor
      win.data 'z', z
      win.css
        # TODO
        '-webkit-animation': 'none'
        'opacity': 1

        '-webkit-transform': "translateZ(#{ win.data 'z' }em)"
        'z-index': zIndexFromDepth(z)

      setWindowInteractable win

      return false

    $('.world').append win

    return false

init = ->
  dom()

  startWelcomeMessages()
  startClock()
  startDraggableWindows()

document.addEventListener 'DOMContentLoaded', ->
  init()
