$(document).ready ->
  Outflux.renderMap()
  $('#origins').click(Outflux.getData)

Outflux = {}

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
    Outflux.highlightOrigin(Outflux.currentCountry)
    Outflux.data = data
    setTimeout (->
      Outflux.highlightDestination(data)
    ), 500
    console.log(data)
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
  for country in data
    console.log(country["destination_id"]["code"])
    $("##{country["destination_id"]["code"]}").attr("class", "destination");

