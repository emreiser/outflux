Outflux.getData = (event, code, year) ->
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
    console.log(data)
    Outflux.currentCountry = data.meta
    Outflux.setYear()

    Outflux.data = d3.nest().key((d) ->
      d.year
    ).entries(data.refugee_counts)

    Outflux.updateShare()
    Outflux.pushHistory()
    Outflux.highlightOrigin(Outflux.currentCountry)
    Outflux.populateInfo()
    if year
      Outflux.highlightDestination(Outflux.selectYearData(year, Outflux.data).values)
    else
      Outflux.highlightDestination(Outflux.selectYearData(Outflux.currentYear, Outflux.data).values)
  )

Outflux.color_keys = [
  {color: '#2fe2bf', title: "0 - 1,000"}
  {color: '#18ab8e', title: "1,000 - 100,000"}
  {color: '#138871', title: "1,000 - 500,000"}
  {color: '#107763', title: "5,000 - 1,000,000"}
  {color: '#0e6655', title: "1,000,000 +"}
]

Outflux.renderLegend = (color_keys) ->
  legend = d3.select('.map-svg').append('svg')
    .attr('class', 'legend')
    .append('g')
    .attr('transform', 'translate(0, 330)')

  legend.append('rect')
    .attr('class', 'legend-box')
    .attr('width', 130)
    .attr('height', 100)
    .attr('rx', 5)
    .attr('ry', 5)

  line = legend.selectAll('.bar')
    .data(color_keys)
    .enter()
    .append('g')
    .attr('transform', 'translate(15, 15)')

  line.append('rect')
    .attr('width', 10)
    .attr('height', 10)
    .attr('fill', (d) -> d.color )
    .attr('y', (d, i) -> i * 15 )

  line.append('text')
    .text((d) -> d.title )
    .attr('x', 15)
    .attr('y', (d, i) -> 10 + i * 15 )


Outflux.renderMap = ->

  width = 800
  height = 500

  projection = d3.geo.mercator()
    .translate([(width/2), (height/2 + 100)])
    .scale( width / 2 / Math.PI)

  path = d3.geo.path().projection(projection)

  draw = (countries) ->
    svg = d3.select('#map-container').append('svg')
      .attr('class', 'map-svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('class', 'map')

    g = svg.append('g')
      .attr('class', 'country-countainer')

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
      .on('mouseenter', Outflux.updateBox)

  d3.json '/world-topo-min.json', (error, world) ->
    countries = topojson.feature(world, world.objects.countries).features
    draw(countries)
    Outflux.renderLegend(Outflux.color_keys)


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

Outflux.renderYear = (event, year) ->
  Outflux.setYear()
  Outflux.updateShare()

  if !year
    year = Outflux.currentYear

  Outflux.populateInfo()
  if Outflux.data
    year_data = Outflux.selectYearData(year, Outflux.data).values
    Outflux.highlightDestination(year_data)

Outflux.clearDestinations = ->
  $('.map path').attr('fill', 'black')
  $('.map path').attr('stroke', '')
