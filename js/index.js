(function() {
  var Camera, Plane, Triplet, Viewport, World, ease, frame, mouseX, mouseY, paused, updateCamera, viewport, viewportElement, world;

  Triplet = (function() {
    function Triplet(x, y, z) {
      this.x = x || 0;
      this.y = y || 0;
      this.z = z || 0;
    }

    return Triplet;

  })();

  Viewport = (function() {
    function Viewport(node) {
      this.node = node;
      this.camera = new Camera();
    }

    return Viewport;

  })();

  World = (function() {
    function World(node, viewport) {
      this.node = node;
      viewport.camera.world = this;
    }

    World.prototype.addPlane = function(plane) {
      return this.node.appendChild(plane.node);
    };

    return World;

  })();

  Camera = (function() {
    function Camera(world, x, y, z, rx, ry, rz) {
      this.world = world;
      this.position = new Triplet(x, y, z);
      this.rotation = new Triplet(rx, ry, rz);
      this.fov = 0;
    }

    Camera.prototype.update = function() {
      var _ref;
      return (_ref = this.world) != null ? _ref.node.style.cssText = CSSUtils.originCentered(-this.position.x, -this.position.y, -this.position.z) + CSSUtils.translate(this.position.x, this.position.y, this.fov, this.rotation.x, this.rotation.y, this.rotation.z) : void 0;
    };

    return Camera;

  })();

  Plane = (function() {
    function Plane(node, w, h, x, y, z, rx, ry, rz) {
      this.node = node;
      this.width = w;
      this.height = h;
      this.position = new Triplet(x, y, z);
      this.rotation = new Triplet(rx, ry, rz);
      this.update();
    }

    Plane.prototype.update = function() {
      return this.style.cssText += 'width:' + this.width + 'px;' + 'height:' + this.height + 'px;' + CSSUtils.originCentered(0, 0, 0) + CSSUtils.translate(this.position.x, this.position.y, this.position.z, this.rotation.x, this.rotation.y, this.rotation.z);
    };

    return Plane;

  })();

  window.CSSUtils = (function() {
    var s, vendorPrefix;
    s = document.documentElement.style;
    vendorPrefix = (s.WebkitTransform !== void 0 && '-webkit-') || (s.MozTransform !== void 0 && '-moz-');
    return {
      translate: function(x, y, z, rx, ry, rz) {
        return vendorPrefix + 'transform:' + 'translate3d(' + x + 'px,' + y + 'px,' + z + 'px)' + 'rotateX(' + rx + 'deg)' + 'rotateY(' + ry + 'deg)' + 'rotateZ(' + rz + 'deg);';
      },
      origin: function(x, y, z) {
        return vendorPrefix + 'transform-origin:' + x + 'px ' + y + 'px ' + z + 'px;';
      },
      originCentered: function(x, y, z) {
        return vendorPrefix + 'transform-origin: calc(50% + ' + x + 'px) calc(50% + ' + y + 'px) ' + z + 'px;';
      }
    };
  })();

  viewportElement = document.querySelector('.viewport');

  viewport = new Viewport(viewportElement);

  world = new World(viewportElement.children[0], viewport);

  mouseX = 0;

  mouseY = 0;

  paused = false;

  window.addEventListener('dblclick', function() {
    return paused = !paused;
  });

  window.addEventListener('mousemove', function(event) {
    mouseX = event.x;
    return mouseY = event.y;
  });

  ease = function(host, property, target, amount) {
    if (amount == null) {
      amount = 20;
    }
    return host[property] += (target - host[property]) / amount;
  };

  updateCamera = function() {
    var cameraPositionX, cameraPositionY, cameraRotationX, cameraRotationY;
    if (paused) {
      return;
    }
    cameraPositionX = (window.innerWidth / 2 - mouseX) * .05;
    cameraPositionY = (window.innerHeight / 2 - mouseY) * .05;
    cameraRotationX = (mouseY - window.innerHeight / 2) * -.005;
    cameraRotationY = (mouseX - window.innerWidth / 2) * -.001;
    ease(viewport.camera.position, 'x', cameraPositionX);
    ease(viewport.camera.position, 'y', cameraPositionY);
    ease(viewport.camera.rotation, 'x', cameraRotationX);
    ease(viewport.camera.rotation, 'y', cameraRotationY);
    return viewport.camera.update();
  };

  frame = function() {
    return updateCamera();
  };

  setInterval(frame, 20);

}).call(this);
