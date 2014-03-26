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
    .on('mouseenter', Outflux.updateBox)

Outflux.highlightDestination = (data) ->
  sections = 5

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
    '#2fe2bf'
    '#18ab8e'
    '#138871'
    '#107763'
    '#0e6655'
  ]

  fillScale = d3.scale.ordinal().domain(levelList(sections)).range(colors)
  Outflux.clearDestinations()
  Outflux.totalRefugees = 0

  for country in data
    current = d3.select("#c-#{country['destination']['code']}")
    current.transition()
      .duration(500)
      .attr('fill', fillScale(getLevel(country.total)))
      .attr('stroke-width', '.7')
      .attr('stroke', 'gray')

    current.on('mouseenter', Outflux.updateBox.bind(country))
    Outflux.totalRefugees += country.total
    $('#total-refugees').text(Outflux.numberWithCommas(Outflux.totalRefugees))

  Outflux.populateInfo()
  Outflux.fillRefugeeViz(Outflux.totalRefugees)

Outflux.selectYearData = (year, array) ->
  for object in array
    return object if object.key == year

Outflux.renderYear = () ->
  year = $('#year-slider').val()
  Outflux.populateInfo()
  if Outflux.data
    year_data = Outflux.selectYearData(year, Outflux.data).values
    Outflux.highlightDestination(year_data)

Outflux.clearDestinations = ->
  $('.map path').attr('fill', 'black')
  $('.map path').attr('stroke', '')
