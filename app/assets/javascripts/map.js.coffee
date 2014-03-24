$(document).ready ->
  Outflux.renderMap()
  $('#origins').click(Outflux.getData)

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
    ).entries(data)

    Outflux.highlightDestination(Outflux.selectYearData("2012", Outflux.data).values)
    # setTimeout (->
    #   Outflux.highlightDestination(data)
    # ), 500
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
  $('.map path').attr("fill", "black")
  $('.map path').attr("stroke", "")
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
  for country in data
    console.log(country["destination"]["name"])
    $("##{country["destination"]["code"]}").attr("fill", fillScale(getLevel(country.total)))
    $("##{country["destination"]["code"]}").attr("stroke", "gray")

Outflux.selectYearData = (year, array) ->
  for object in array
    return object if object.key == year

Outflux.selectCountry = (id, array) ->
  for object in array
    return object if object.destination_id == id

Outflux.renderYear = (year) ->
