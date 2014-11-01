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

  return {
    translate: (x, y, z, rx, ry, rz) ->
      vendorPrefix + 'transform:' +
        'translate3d(' + x + 'px,' + y + 'px,' + z + 'px)' +
        'rotateX(' + rx + 'deg)' +
        'rotateY('  +ry + 'deg)' +
        'rotateZ(' + rz + 'deg);'

    origin: (x, y, z) ->
      vendorPrefix + 'transform-origin:' + x + 'px ' + y + 'px ' + z + 'px;'

    originCentered: (x, y, z) ->
      vendorPrefix + 'transform-origin: calc(50% + ' + x + 'px) calc(50% + ' + y + 'px) ' + z + 'px;'
  }

viewportElement = document.querySelector '.viewport'
viewport = new Viewport viewportElement
world = new World viewportElement.children[0], viewport

mouseX = 0
mouseY = 0

paused = false

window.addEventListener 'dblclick', -> paused = not paused

window.addEventListener 'mousemove', (event) ->
  mouseX = event.x
  mouseY = event.y

ease = (host, property, target, amount = 20) ->
  host[property] += (target - host[property]) / amount

updateCamera = ->
  return if paused

  cameraPositionX = ((window.innerWidth / 2 - mouseX) * .05)
  cameraPositionY = ((window.innerHeight / 2 - mouseY) * .05)
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
