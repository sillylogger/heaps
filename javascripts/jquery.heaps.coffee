(($) ->
  $.heap = (el, selector, options) ->

    # Access to jQuery and DOM versions of element
    @el = el
    @$el = $ el

    #fat arrow '=>' makes creating jq plugins much easier.
    @init = =>

      # we need to attach elements to the dom to get css styles
      @body = $ 'body'

      @options = $.extend {}, $.heap.defaultOptions, options

      @$el.css({ position: 'relative' })

      @width = @$el.outerWidth()
      @height = @$el.outerHeight()
      @center = [ @width/2, @height/2 ]

      @sortedCoordinates = sortCoordinates @width, @height

      @canvas = {}
      for k,v in @sortedCoordinates
        @canvas[k] = v

      if selector
        elements = $(selector, @el)
        elements = elements.sort(bySize) if @options.sort
        elements.each place

      @ # return this

    place = (i, el) =>
      @place(el)

    @place = (el) =>
      $el = $ el
      $el.hide()

      width = $el.outerWidth()
      height = $el.outerHeight()

      position = @findBestPosition width, height

      return null unless position
      occupyPosition width, height, position

      $el.css({
        position: 'absolute',
        left: position[0] + 'px',
        top: position[1] + 'px'
      })

      $el.show()

    @findBestPosition = (width, height) =>

      if (height > @height || width > @width)
        return

      for coordinate in @sortedCoordinates
        continue unless coordinate # the coordinate may have been 'picked' out  of this array

        position = coordinateToPosition width, height, coordinate

        if isFit width, height, position
          return position

    occupyPosition = (width, height, position) =>
      left = position[0]
      top = position[1]

      for x in [left...(left+width)] by @options.step
        for y in [top...(top+height)] by @options.step
          # @debugOccupiedPosition [x,y]
          delete @sortedCoordinates[ @canvas[[x,y]] ]
          @canvas[[x,y]] = false

      null

    coordinateToPosition = (width, height, coordinate) =>
      x = Math.floor(coordinate[0] - width/2)
      y = Math.floor(coordinate[1] - height/2)

      # round to the closest grid position (in case half the width or height isn't on the grid)
      [ x - (x % @options.step), y - (y % @options.step) ]

    isFit = (width, height, position) =>
      left = position[0]
      top = position[1]

      for x in [left...(left+width)] by @options.step
        for y in [top...(top+height)] by @options.step
          potentialPoint = @canvas[[x,y]]
          return false unless potentialPoint?
          return false if potentialPoint == false

      true

    sortCoordinates = (width, height) =>
      coordinates = []
      for x in [0..(width-@options.step)] by @options.step
        for y in [0..(height-@options.step)] by @options.step
          coordinates.push [x,y]

      coordinates.sort scoreCoordinates

    scoreCoordinates = (a, b) =>
      if @options.scoring
        @options.scoring.call(@,a) - @options.scoring.call(@,b)
      else
        scoreCoordinate(a) - scoreCoordinate(b)

    scoreCoordinate = (coordinate) =>
      Math.sqrt(
        Math.pow(coordinate[0] - @center[0], 2) +
        Math.pow(coordinate[1] - @center[1], 2)
      )

    @debugPosition = (position) =>
      @$el.append $("<div class=\"dot\" title=\"available: #{position}\" style=\"left: #{position[0]}px; top: #{position[1]}px;\"></div>")

    @debugOccupiedPosition = (position) =>
      @$el.append $("<div class=\"occupied\" title=\"occupied: #{position}\" style=\"left: #{position[0]}px; top: #{position[1]}px;\"></div>")

    bySize = (a, b) ->
      $a = $(a)
      $b = $(b)
      areaA = ($a.width() * $a.height())
      areaB = ($b.width() * $b.height())
      (areaB - areaA)

    # call init, and return the output
    @init()

  # object literal containing default options
  $.heap.defaultOptions = {
    step: 10
  }

  $.fn.heapify = (selector, options) ->
    $.each @, (i, el) ->
      $el = ($ el)

      # Only instantiate if not previously done.
      unless $el.data 'heap'

        # call plugin on el with options, and set it to the data.
        # the instance can always be retrieved as element.data 'pluginName'
        # You can do things like:
        # (element.data 'heap').place( el );

        $el.data 'heap', new $.heap el, selector, options

  undefined

)(jQuery)


