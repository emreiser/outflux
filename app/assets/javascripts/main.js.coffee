$(document).ready (event) ->
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

  $('body').on('mousemove', Outflux.hideBox)

Outflux.pushHistory = (event) ->
  window.history.pushState('','', Routes.country_year_path(Outflux.currentCountry.code, Outflux.currentYear))

Outflux.setYear = () ->
  Outflux.currentYear = $('#year-slider').val()

