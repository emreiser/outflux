Outflux.numberWithCommas = (int) ->
  int.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

Outflux.populateInfo = () ->
  $('.origin-name').text("#{Outflux.currentCountry.name}")

  year = $('#year-slider').val()
  $('.year-output').text(year)

  if Outflux.totalRefugees
    $('.total-refugees').text(Outflux.numberWithCommas(Outflux.totalRefugees))

Outflux.fillRefugeeViz = (count) ->
  box = $('#refugee-box')
  bar = $('<div>', {class: 'refugee-viz'})

  times = Math.floor(count/100000)
  remainder = count % 100000

  box.empty()

  for n in [1..times]
    box.append(bar.clone())

  if remainder
    bar = bar.clone()
    partial = $('<div>', {css: {margin: 0, height: '100%', background: 'white'}})
    percent = (100 - Math.floor(remainder/100000 * 100)) + '%'
    partial.css('width': "#{percent}")
    bar.append(partial)
    box.append(bar)