Outflux.getData = (event, code, year) ->
  $('#stories').hide()
  Outflux.loadStats()
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
    Outflux.mapResponse(data, year)
  )

Outflux.color_keys = [
  {color: '#2fe2bf', title: "0 - 1,000", name: 'lev-1'}
  {color: '#18ab8e', title: "1,000 - 10,000", name: 'lev-2'}
  {color: '#138871', title: "10,000 - 50,000", name: 'lev-3'}
  {color: '#107763', title: "50,000 - 100,000", name: 'lev-4'}
  {color: '#0e6655', title: "100,000 +", name: 'lev-5'}
]

Outflux.mapResponse = (data, year) ->
  Outflux.currentCountry = data.meta
  Outflux.setYear()

  Outflux.data = d3.nest().key((d) -> d.year).entries(data.refugee_counts)

  Outflux.getStories(Outflux.currentCountry.code)

  Outflux.updateShare()
  Outflux.pushHistory()
  Outflux.highlightOrigin(Outflux.currentCountry)
  Outflux.populateInfo()
  if year
    Outflux.highlightDestination(Outflux.selectYearData(year, Outflux.data).values)
  else
    Outflux.highlightDestination(Outflux.selectYearData(Outflux.currentYear, Outflux.data).values)


Outflux.renderLegend = (color_keys) ->
  legend = d3.select('.map-svg').append('svg')
    .attr('class', 'legend')
    .append('g')
    .attr('transform', 'translate(0, 280)')

  legend.append('rect')
    .attr('class', 'legend-box')
    .attr('width', 185)
    .attr('height', 120)
    .attr('rx', 5)
    .attr('ry', 5)

  legend.append('text')
    .text('Number of refugees received')
    .attr('y', 20)
    .attr('x', 15)
    .attr('fill', 'black')
    .attr('font-weight', 'bold')

  line = legend.selectAll('.bar')
    .data(color_keys)
    .enter()
    .append('g')
    .attr('transform', 'translate(15, 35)')

  line.append('rect')
    .attr('width', 10)
    .attr('height', 10)
    .attr('rx', 1)
    .attr('ry', 1)
    .attr('fill', (d) -> d.color )
    .attr('y', (d, i) -> i * 15 )

  line.append('text')
    .text((d) -> d.title )
    .attr('x', 15)
    .attr('y', (d, i) -> 9 + i * 15 )


Outflux.renderMap = ->

  width = $(document).width() * .7
  height = 430

  projection = d3.geo.mercator()
    .translate([(width/2 - 25), (height/2 + 30)])
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
  $('#origins button').removeClass('highlight')
  $("[data-code='#{country.code}']").addClass('highlight')
  $('.map path').attr('class', 'country')
  d3.select("#c-#{country.code}")
    .attr('class', 'country highlight')
    .on('mouseenter', Outflux.updateBox)

Outflux.highlightDestination = (data) ->

  getLevel = (total) ->
    if total <= 1000
      'lev-1'
    else if total <= 10000
      'lev-2'
    else if total <= 50000
      'lev-3'
    else if total <= 100000
      'lev-4'
    else
      'lev-5'

  getColor = (level) ->
    for set in Outflux.color_keys
      if set['name'] == level
        res = set['color']
    return res

  Outflux.clearDestinations()
  Outflux.totalRefugees = 0

  for country in data
    current = d3.select("#c-#{country['destination']['code']}")
    current.transition()
      .duration(500)
      .attr('fill', getColor(getLevel(country.total)))
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
