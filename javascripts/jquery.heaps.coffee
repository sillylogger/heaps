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

      width = @$el.outerWidth()
      height = @$el.outerHeight()

      @top = 0
      @right = width
      @bottom = height
      @left = 0

      @center = [ width/2, height/2 ]

      @sortedCoordinates = sortCoordinates width, height
      @placedElements = []

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

      placement = @findBestPlacement width, height

      return null unless placement
      @placedElements.push placement

      $el.css({
        position: 'absolute',
        left: placement.left + 'px',
        top: placement.top + 'px'
      })

      $el.show()

    @findBestPlacement = (width, height) =>

      for coordinate in @sortedCoordinates
        # continue unless coordinate # the coordinate may have been 'picked' out  of this array

        placement = coordinateToPlacement width, height, coordinate

        continue if (placement.top < @top ||
                     placement.right > @right ||
                     placement.bottom > @bottom ||
                     placement.left < @left)

        return placement if isFit placement

    coordinateToPlacement = (width, height, coordinate) =>
      x = coordinate[0] - width/2
      y = coordinate[1] - height/2

      # round to the closest grid position (in case half the width or height isn't on the grid)
      x = x - (x % @options.step)
      y = y - (y % @options.step)

      { top: y, right: x + width - 1, bottom: y + height - 1, left: x }

    rectsIntersect = (placement, otherPlacement) ->
      !(placement.right < otherPlacement.left ||
        placement.bottom < otherPlacement.top ||
        placement.left > otherPlacement.right ||
        placement.top > otherPlacement.bottom)

    isFit = (placement) =>

      for otherPlacement in @placedElements
        return false if rectsIntersect(placement, otherPlacement)

      true

    sortCoordinates = (width, height) =>
      coordinates = []
      for x in [0...(width-@options.step)] by @options.step
        for y in [0...(height-@options.step)] by @options.step
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


