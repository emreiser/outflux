$(document).ready ->
  Outflux.renderMap()
  Outflux.getData(event, "211")

  $('#origins').click(Outflux.getData)
  $('#year-slider').on('change', Outflux.renderYear)
  Outflux.showHoverBox()

  $(document).mousemove((event) ->
    Outflux.mouseX = event.pageX
    Outflux.mouseY = event.pageY

    Outflux.moveHoverBox(Outflux.mouseX, Outflux.mouseY)
  )

  $('#map-container').on('mousemove', Outflux.hideBox)