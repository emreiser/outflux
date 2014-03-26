$(document).ready ->
  Outflux.renderMap()

  params = document.URL.match(/\/(\d+)/g)
  if params
    country = params[0].slice(1)
    year = params[1].slice(1)
    $('#year-slider').val(year)

    Outflux.getData(event, country, year)

  else
    Outflux.getData(event, "211")

  $('#origins').click(Outflux.getData)
  $('#year-slider').on('change', Outflux.renderYear)

  $('#year-slider').on('mouseup', Outflux.pushHistory)
  Outflux.addHoverBox()

  $(document).mousemove((event) ->
    Outflux.mouseX = event.pageX
    Outflux.mouseY = event.pageY

    Outflux.moveHoverBox(Outflux.mouseX, Outflux.mouseY)
  )

  $('#map-container').on('mousemove', Outflux.hideBox)

Outflux.pushHistory = (event) ->
  year = $('#year-slider').val()
  window.history.pushState('','',"/#{Outflux.currentCountry.code}/#{year}")
