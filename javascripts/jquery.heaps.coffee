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

      @canvas = initializeCanvas( @width, @height )

      if selector
        elements = $(selector, el)
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
      availableCoordinates = []

      if (height > @height || width > @width)
        return

      for y in [0..(@height - height)] by @options.step
        lastIsFit = false

        for x in [0..(@width - width)] by @options.step
          position = [x,y]

          if lastIsFit && columnIsFit(width, height, position)
            currentIsFit = true
            availableCoordinates.push positionToCoordinate(width, height, position)

          else if isFit(width, height, position)
            currentIsFit = true
            availableCoordinates.push positionToCoordinate(width, height, position)

          else
            currentIsFit = false

          # if currentIsFit != lastIsFit
            # you found an edge after jumping by ten... go back by ones
            # the problem with this is it only works in the axi of the inner loop
            # betterCoordinates = @backupToEdge width, height, position
            # availableCoordinates = availableCoordinates.concat betterCoordinates

          lastIsFit = currentIsFit

      if availableCoordinates.length > 0
        availableCoordinates.sort scoreCoordinates
        coordinateToPosition width, height, availableCoordinates[0]

    # @backupToEdge = (width, height, position) =>
    #   availableCoordinates = []

    #   x = position[0]
    #   y = position[1]
    #   backToX = x - @options.step
    #   backToY = y - @options.step

    #   for dy in [y...backToY]
    #     for dx in [x...backToX]
    #       dPosition = [dx, dy]

    #       if @isFit(width, height, dPosition)
    #         availableCoordinates.unshift positionToCoordinate width, height, dPosition

    #   availableCoordinates

    occupyPosition = (width, height, position) =>
      left = position[0]
      top = position[1]

      for x in [left...(left+width)]
        for y in [top...(top+height)]
          @canvas[x][y] = true

    positionToCoordinate = (width, height, position) =>
      [ Math.floor(position[0] + width/2), Math.floor(position[1] + height/2) ]

    coordinateToPosition = (width, height, coordinate) =>
      [ Math.floor(coordinate[0] - width/2), Math.floor(coordinate[1] - height/2) ]

    isFit = (width, height, position) =>
      left = position[0]
      top = position[1]

      for x in [left...(left+width)] by @options.step
        for y in [top...(top+height)] by @options.step
          return false if (!@canvas[x] || @canvas[x][y] == true)

      true

    columnIsFit = (width, height, position) =>
      left = position[0] + width
      top = position[1]

      for y in [top..(top+height)] by @options.step
        return false if (!@canvas[left] || @canvas[left][y] == true)

      true

    @debugPosition = (position) =>
      @$el.append $("<div class=\"dot\" title=\"available: #{position}\" style=\"left: #{position[0]}px; top: #{position[1]}px;\"></div>")

    @debugOccupiedPosition = (position) =>
      @$el.append $("<div class=\"occupied\" title=\"occupied: #{position}\" style=\"left: #{position[0]}px; top: #{position[1]}px;\"></div>")

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

    initializeCanvas = (width, height) ->
      canvas = []

      for x in [0..width]
        canvas[x] = []
        for y in [0..height]
          canvas[x][y] = false

      canvas

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


