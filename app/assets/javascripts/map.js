$(document).ready(function(){
  Outflux.renderMap();

  $('#origins').click(Outflux.getData);

});


var Outflux = {};

Outflux.getData = function(event){
  Outflux.currentCountry = $(event.target).attr("data-code");
  var country_id = $(event.target).attr("data-country");

  $.ajax({
    url: '/',
    type: 'GET',
    dataType: 'json',
    data: {id: country_id},
  })
  .done(function(data) {
    Outflux.highlightCountry(parseInt(Outflux.currentCountry));
  })
  .fail(function() {
    console.log("error");
  })
  .always(function() {
    console.log("complete");
  });
};


Outflux.renderMap = function(){

  var width, height, path, svg, g, draw;

  width = 800, height = 600;

  projection = d3.geo.mercator()
    .translate([(width/2), (height/2)])
    .scale( width / 2 / Math.PI);

  path = d3.geo.path().projection(projection);

  draw = function(countries) {
    svg.append("path")
    .datum(d3.geo.graticule())
    .attr("class", "graticule")
    .attr("d", path);

    var country = g.selectAll(".country")
      .data(countries)
      .enter()
      .insert("path")
      .attr("title", function(d) { return d.properties.name; })
      .attr("id", function(d){ return d.id; })
      .attr("d", path);
  };

  svg = d3.select('#map-container').append('svg')
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("class", "map");

  g = svg.append("g");

  d3.json("/world-topo-min.json", function(error, world){
    Outflux.world = world;
    var countries = topojson.feature(world, world.objects.countries).features;
    draw(countries);
  });

};

Outflux.highlightCountry = function(id){
  country_id = '#' + id
  $('.map path').attr("class", "");
  $(country_id).attr("class", "highlight");
};
