$(document).ready ->
  Outflux.renderMap()
  Outflux.setUpBar()

  $('#origins').click(Outflux.getData)
  $("#year-slider").on("change", Outflux.renderYear)

Outflux.getData = (event) ->
  Outflux.currentCountry = $(event.target).attr("data-code")
  country_id = $(event.target).attr("data-country")

  $.ajax(
    url: '/'
    type: 'GET'
    dataType: 'json'
    data:
      id: country_id
  )

  .done((data) ->
    console.log(data)
    Outflux.highlightOrigin(Outflux.currentCountry)
    Outflux.data = d3.nest().key((d) ->
      d.year
    ).entries(data.refugee_counts)
    console.log(data)
    Outflux.drawBar(data.meta)
    Outflux.highlightDestination(Outflux.selectYearData("2012", Outflux.data).values)
  )

Outflux.renderMap = ->

  width = 800
  height = 600

  projection = d3.geo.mercator()
    .translate([(width/2), (height/2)])
    .scale( width / 2 / Math.PI)

  path = d3.geo.path().projection(projection)

  draw = (countries) ->
    svg.append("path")
    .datum(d3.geo.graticule())
    .attr("class", "graticule")
    .attr("d", path)

    country = g.selectAll(".country")
      .data(countries)
      .enter()
      .insert("path")
      .attr("title", (d) -> return d.properties.name )
      .attr("class", "country")
      .attr("id", (d) -> return d.id )
      .attr("d", path)

  svg = d3.select('#map-container').append('svg')
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("class", "map")

  g = svg.append("g")

  d3.json "/world-topo-min.json", (error, world) ->
    Outflux.world = world
    countries = topojson.feature(world, world.objects.countries).features
    draw(countries)

Outflux.highlightOrigin = (id) ->
  $('.map path').attr("class", "")
  $("##{id}").attr("class", "highlight")


Outflux.highlightDestination = (data) ->
  sections = 10

  getLevel = d3.scale.quantize().domain([
    d3.min data, (d) ->
      d.total
    d3.max data, (d) ->
      d.total
  ])
  .range(d3.range(sections).map((i) ->
    return "level-" + i
  ))

  levelList = (num) ->
    array = []
    x = 0
    while x < num
      array.push("level-#{x}")
      x += 1

    return array

  colors = [
    "#ecfcf9"
    "#dbfaf4"
    "#caf8ef"
    "#b9f5e9"
    "#a7f3e4"
    "#96f0df"
    "#dbfaf4"
    "#74ecd4"
    "#62e9cf"
    "#51e7c9"
  ]

  fillScale = d3.scale.ordinal().domain(levelList(sections)).range(colors.reverse())
  Outflux.clearDestinations()
  Outflux.totalRefugees = 0
  for country in data
    console.log(country["destination"]["name"])
    $("##{country["destination"]["code"]}").attr("fill", fillScale(getLevel(country.total)))
    $("##{country["destination"]["code"]}").attr("stroke", "gray")
    Outflux.totalRefugees += country.total
    $('#total-refugees').text(Outflux.totalRefugees)

  Outflux.redrawBar(Outflux.totalRefugees)

Outflux.selectYearData = (year, array) ->
  for object in array
    return object if object.key == year

Outflux.renderYear = () ->
  year = $("#year-slider").val()
  $('#year-output').text(year)
  if Outflux.data
    year_data = Outflux.selectYearData(year, Outflux.data).values
    Outflux.highlightDestination(year_data)

Outflux.clearDestinations = ->
  $('.map path').attr("fill", "black")
  $('.map path').attr("stroke", "")

Outflux.setUpBar = (country) ->
  height = 60
  width = 800
  $('#bar-title').text(' ')
  d3.select('#bar').append('svg')
  .attr('height', height)
  .attr('width', width)
  .append('g')
  .attr('class', 'bar')

Outflux.drawBar = (country) ->
  $('#bar-title').text("Total refugees originating from  #{country.name}")
  d3.select('.bar').append('rect')
  .attr('x', 0)
  .attr('y', 10)
  .attr('height', 40)
  .attr('width', 0)
  .attr('fill', 'tomato')

Outflux.redrawBar = (total) ->
  d3.select('rect')
  .transition()
    .duration(500)
    .attr("width", total/1000)
