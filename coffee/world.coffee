class Triplet
  constructor: (x, y, z) ->
    @x = x or 0
    @y = y or 0
    @z = z or 0

class Viewport
  constructor: (node) ->
    @node = node
    @camera = new Camera()

class World
  constructor: (node, viewport) ->
    @node = node
    viewport.camera.world = @

  addPlane: (plane) ->
    @node.appendChild plane.node

class Camera
  constructor: (world, x, y, z, rx, ry, rz) ->
    @world = world
    @position = new Triplet(x, y, z)
    @rotation = new Triplet(rx, ry, rz)
    @fov = 0

  update: ->
    @world?.node.style.cssText =
      CSSUtils.originCentered(-this.position.x, -this.position.y, -this.position.z) +
      CSSUtils.translate(this.position.x, this.position.y, this.fov, this.rotation.x, this.rotation.y, this.rotation.z)

class Plane
  constructor: (node, w, h, x, y, z, rx, ry, rz) ->
    @node = node
    @width = w
    @height = h
    @position = new Triplet(x, y, z)
    @rotation = new Triplet(rx, ry, rz)
    @update()

  update: ->
    @style.cssText +=
      'width:' + this.width + 'px;' +
      'height:' + this.height + 'px;' +
      #'background:' + this.color + ';' +
      CSSUtils.originCentered(0, 0, 0) + #TODO - make this a plane option please?
      CSSUtils.translate(this.position.x, this.position.y, this.position.z, this.rotation.x, this.rotation.y, this.rotation.z)

window.CSSUtils = do ->
  s = document.documentElement.style
  vendorPrefix = (s.WebkitTransform isnt undefined and '-webkit-') or (s.MozTransform isnt undefined and '-moz-')

  round = (num) -> Math.round(num * 10000) / 10000

  return {
    translate: (x, y, z, rx, ry, rz) ->
      vendorPrefix + 'transform:' +
        'translate3d(' + round(x) + 'px,' + round(y) + 'px,' + round(z) + 'px)' +
        'rotateX(' + round(rx) + 'deg)' +
        'rotateY(' + round(ry) + 'deg)' +
        'rotateZ(' + round(rz) + 'deg);'

    origin: (x, y, z) ->
      vendorPrefix + 'transform-origin:' + round(x) + 'px ' + round(y) + 'px ' + round(z) + 'px;'

    originCentered: (x, y, z) ->
      vendorPrefix + 'transform-origin: calc(50% + ' + round(x) + 'px) calc(50% + ' + round(y) + 'px) ' + round(z) + 'px;'
  }

viewportElement = document.querySelector '.viewport'
viewport = new Viewport viewportElement
world = new World viewportElement.children[0], viewport

# ZONE
# TODO - figure out an API for this???
window.zoneX = 0
window.zoneY = 0

document.addEventListener 'keydown', (event) ->
  return unless event.shiftKey

  switch event.keyCode
    when 37
      window.zoneX -= 1
    when 38
      window.zoneY -= 1
    when 39
      window.zoneX += 1
    when 40
      window.zoneY += 1

  setTimeout ->
    window.zoneX = -1 if window.zoneX < -1
    window.zoneX = 1 if window.zoneX > 1
    window.zoneY = -1 if window.zoneY < -1
    window.zoneY = 1 if window.zoneY > 1
  , 100

# TODO - provide API instead of assigning to window
window.mouseX = 0
window.mouseY = 0

paused = false

window.addEventListener 'contextmenu', ->
  paused = not paused

window.addEventListener 'mousemove', (event) ->
  window.mouseX = event.x
  window.mouseY = event.y

ease = (host, property, target, amount = 20) ->
  host[property] += (target - host[property]) / amount

updateCamera = ->
  return if paused

  cameraPositionX = ((window.innerWidth / 2 - mouseX) * .05)
  cameraPositionY = ((window.innerHeight / 2 - mouseY) * .05)

  cameraPositionX -= window.zoneX * window.innerWidth
  cameraPositionY -= window.zoneY * window.innerHeight

  cameraRotationX = (mouseY - window.innerHeight / 2) * -.005
  cameraRotationY = (mouseX - window.innerWidth / 2) * -.001

  ease viewport.camera.position, 'x', cameraPositionX
  ease viewport.camera.position, 'y', cameraPositionY
  ease viewport.camera.rotation, 'x', cameraRotationX
  ease viewport.camera.rotation, 'y', cameraRotationY

  viewport.camera.update()

frame = ->
  updateCamera()

setInterval frame, 20
