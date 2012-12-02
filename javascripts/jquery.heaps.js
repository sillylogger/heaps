// Generated by CoffeeScript 1.4.0
(function() {

  (function($) {
    $.heap = function(el, selector, options) {
      var columnIsFit, coordinateToPosition, initializeCanvas, isFit, occupyPosition, place, positionToCoordinate, scoreCoordinate, scoreCoordinates,
        _this = this;
      this.el = el;
      this.$el = $(el);
      this.init = function() {
        _this.body = $('body');
        _this.options = $.extend({}, $.heap.defaultOptions, options);
        _this.$el.css({
          position: 'relative'
        });
        _this.width = _this.$el.width();
        _this.height = _this.$el.height();
        _this.center = [_this.width / 2, _this.height / 2];
        _this.canvas = initializeCanvas(_this.width, _this.height);
        if (selector) {
          $(selector, _this.el).each(place);
        }
        return _this;
      };
      place = function(i, el) {
        return _this.place(el);
      };
      this.place = function(el) {
        var $el, height, position, width;
        $el = $(el);
        $el.hide();
        width = $el.outerWidth();
        height = $el.outerHeight();
        position = _this.findBestPosition(width, height);
        if (!position) {
          return null;
        }
        occupyPosition(width, height, position);
        $el.css({
          position: 'absolute',
          left: position[0] + 'px',
          top: position[1] + 'px'
        });
        return $el.show();
      };
      this.findBestPosition = function(width, height) {
        var availableCoordinates, currentIsFit, lastIsFit, position, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
        availableCoordinates = [];
        if (height > _this.height || width > _this.width) {
          return;
        }
        for (y = _i = 0, _ref = _this.height - height, _ref1 = _this.options.step; 0 <= _ref ? _i <= _ref : _i >= _ref; y = _i += _ref1) {
          lastIsFit = false;
          for (x = _j = 0, _ref2 = _this.width - width, _ref3 = _this.options.step; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; x = _j += _ref3) {
            position = [x, y];
            if (lastIsFit && columnIsFit(width, height, position)) {
              currentIsFit = true;
              availableCoordinates.push(positionToCoordinate(width, height, position));
            } else if (isFit(width, height, position)) {
              currentIsFit = true;
              availableCoordinates.push(positionToCoordinate(width, height, position));
            } else {
              currentIsFit = false;
            }
            lastIsFit = currentIsFit;
          }
        }
        if (availableCoordinates.length > 0) {
          availableCoordinates.sort(scoreCoordinates);
          return coordinateToPosition(width, height, availableCoordinates[0]);
        }
      };
      occupyPosition = function(width, height, position) {
        var left, top, x, y, _i, _ref, _results;
        left = position[0];
        top = position[1];
        _results = [];
        for (x = _i = left, _ref = left + width; left <= _ref ? _i < _ref : _i > _ref; x = left <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (y = _j = top, _ref1 = top + height; top <= _ref1 ? _j < _ref1 : _j > _ref1; y = top <= _ref1 ? ++_j : --_j) {
              _results1.push(this.canvas[x][y] = true);
            }
            return _results1;
          }).call(_this));
        }
        return _results;
      };
      positionToCoordinate = function(width, height, position) {
        return [Math.floor(position[0] + width / 2), Math.floor(position[1] + height / 2)];
      };
      coordinateToPosition = function(width, height, coordinate) {
        return [Math.floor(coordinate[0] - width / 2), Math.floor(coordinate[1] - height / 2)];
      };
      isFit = function(width, height, position) {
        var left, top, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
        left = position[0];
        top = position[1];
        for (x = _i = left, _ref = left + width, _ref1 = _this.options.step; left <= _ref ? _i < _ref : _i > _ref; x = _i += _ref1) {
          for (y = _j = top, _ref2 = top + height, _ref3 = _this.options.step; top <= _ref2 ? _j < _ref2 : _j > _ref2; y = _j += _ref3) {
            if (!_this.canvas[x] || _this.canvas[x][y] === true) {
              return false;
            }
          }
        }
        return true;
      };
      columnIsFit = function(width, height, position) {
        var left, top, y, _i, _ref, _ref1;
        left = position[0] + width;
        top = position[1];
        for (y = _i = top, _ref = top + height, _ref1 = _this.options.step; top <= _ref ? _i <= _ref : _i >= _ref; y = _i += _ref1) {
          if (!_this.canvas[left] || _this.canvas[left][y] === true) {
            return false;
          }
        }
        return true;
      };
      this.debugPosition = function(position) {
        return _this.$el.append($("<div class=\"dot\" title=\"available: " + position + "\" style=\"left: " + position[0] + "px; top: " + position[1] + "px;\"></div>"));
      };
      this.debugOccupiedPosition = function(position) {
        return _this.$el.append($("<div class=\"occupied\" title=\"occupied: " + position + "\" style=\"left: " + position[0] + "px; top: " + position[1] + "px;\"></div>"));
      };
      scoreCoordinates = function(a, b) {
        return scoreCoordinate(a) - scoreCoordinate(b);
      };
      scoreCoordinate = function(coordinate) {
        return Math.sqrt(Math.pow(coordinate[0] - _this.center[0], 2) + Math.pow(coordinate[1] - _this.center[1], 2));
      };
      initializeCanvas = function(width, height) {
        var canvas, x, y, _i, _j;
        canvas = [];
        for (x = _i = 0; 0 <= width ? _i <= width : _i >= width; x = 0 <= width ? ++_i : --_i) {
          canvas[x] = [];
          for (y = _j = 0; 0 <= height ? _j <= height : _j >= height; y = 0 <= height ? ++_j : --_j) {
            canvas[x][y] = false;
          }
        }
        return canvas;
      };
      return this.init();
    };
    $.heap.defaultOptions = {
      step: 10
    };
    $.fn.heapify = function(selector, options) {
      return $.each(this, function(i, el) {
        var $el;
        $el = $(el);
        if (!$el.data('heap')) {
          return $el.data('heap', new $.heap(el, selector, options));
        }
      });
    };
    return void 0;
  })(jQuery);

}).call(this);
