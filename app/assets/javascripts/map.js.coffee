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

  $('#map-container').on('mouseenter', 'path', Outflux.updateBox)
  $('#map-container').on('mousemove', Outflux.hideBox)

Outflux.getData = (event, code) ->
  if code
    country_code = code
  else
    country_code = $(event.target).attr('data-code')

  $.ajax(
    url: '/'
    type: 'GET'
    dataType: 'json'
    data:
      code: country_code
  )

  .done((data) ->
    Outflux.currentCountry = data.meta
    Outflux.data = d3.nest().key((d) ->
      d.year
    ).entries(data.refugee_counts)
    console.log(data)

    Outflux.highlightOrigin(Outflux.currentCountry)
    Outflux.populateInfo()
    Outflux.highlightDestination(Outflux.selectYearData('2012', Outflux.data).values)
  )

Outflux.renderMap = ->

  width = 800
  height = 500

  projection = d3.geo.mercator()
    .translate([(width/2), (height/2 + 100)])
    .scale( width / 2 / Math.PI)

  path = d3.geo.path().projection(projection)

  draw = (countries) ->
    svg.append('path')
    .datum(d3.geo.graticule())
    .attr('class', 'graticule')
    .attr('d', path)

    country = g.selectAll('.country')
      .data(countries)
      .enter()
      .insert('path')
      .attr('title', (d) -> d.properties.name )
      .attr('class', 'country')
      .attr('id', (d) -> "c-#{d.id}" )
      .attr('d', path)

  svg = d3.select('#map-container').append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('class', 'map')

  g = svg.append('g')
    .attr('class', 'country-countainer')

  d3.json '/world-topo-min.json', (error, world) ->
    Outflux.world = world
    countries = topojson.feature(world, world.objects.countries).features
    draw(countries)

Outflux.highlightOrigin = (country) ->
  $('.map path').attr('class', 'country')
  d3.select("#c-#{country.code}")
    .attr('class', 'country highlight')

Outflux.highlightDestination = (data) ->
  sections = 10

  getLevel = d3.scale.quantize().domain([
    d3.min data, (d) ->
      d.total
    d3.max data, (d) ->
      d.total
  ])
  .range(d3.range(sections).map((i) ->
    return 'level-' + i
  ))

  levelList = (num) ->
    array = []
    x = 0
    while x < num
      array.push("level-#{x}")
      x += 1

    return array

  colors = [
    '#ecfcf9'
    '#dbfaf4'
    '#caf8ef'
    '#b9f5e9'
    '#a7f3e4'
    '#96f0df'
    '#dbfaf4'
    '#74ecd4'
    '#62e9cf'
    '#51e7c9'
  ]

  fillScale = d3.scale.ordinal().domain(levelList(sections)).range(colors.reverse())
  Outflux.clearDestinations()
  Outflux.totalRefugees = 0

  for country in data
    console.log(country['destination']['name'])
    d3.select("#c-#{country['destination']['code']}").transition()
      .duration(500)
      .attr('fill', fillScale(getLevel(country.total)))
      .attr('stroke', 'gray')
    Outflux.totalRefugees += country.total
    $('#total-refugees').text(Outflux.numberWithCommas(Outflux.totalRefugees))

  Outflux.populateInfo()
  Outflux.fillRefugeeViz(Outflux.totalRefugees)

Outflux.selectYearData = (year, array) ->
  for object in array
    return object if object.key == year

Outflux.renderYear = () ->
  # Remember to populate Info bar
  year = $('#year-slider').val()
  Outflux.populateInfo()
  if Outflux.data
    year_data = Outflux.selectYearData(year, Outflux.data).values
    Outflux.highlightDestination(year_data)

Outflux.clearDestinations = ->
  $('.map path').attr('fill', 'black')
  $('.map path').attr('stroke', '')

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

Outflux.showHoverBox = () ->
  box = $('<div />', {class: 'hover-box'})
  $('#map-container').append(box)

Outflux.moveHoverBox = (x, y) ->
  $box = $('.hover-box')
  $box.css({left: "#{x + 20}px", top: "#{y + 20}px"})

Outflux.updateBox = (event) ->
  name = $(event.target).attr('title')
  $('.hover-box').text(name)
  $('.hover-box').css({display: 'block'})

Outflux.hideBox = (event) ->
  if $(event.target).get(0).tagName != 'path'
    $('.hover-box').css({display: 'none'})
