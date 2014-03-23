$(document).ready(function(){
  Outflux.renderMap();

  $('#origins').click(Outflux.getData);

});


var Outflux = {};

Outflux.getData = function(event){
  var country_id = $(event.target).attr("data-country");
};


Outflux.renderMap = function(){

  var width, height, path, svg, g, draw;

  width = 800, height = 600;

  projection = d3.geo.mercator()
    .translate([(width/2), (height/2)])
    .scale( width / 2 / Math.PI);
  path = d3.geo.path().projection(projection);

  svg = d3.select('#map-container').append('svg')
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("class", "g-container");

  g = svg.append("g");

  d3.json("/world-topo-min.json", function(error, world){
    Outflux.world = world;
    var countries = topojson.feature(world, world.objects.countries).features;
    draw(countries);
  });

  function draw(countries) {
    svg.append("path")
    .datum(d3.geo.graticule())
    .attr("class", "graticule")
    .attr("d", path);

    var country = g.selectAll(".country")
      .data(countries)
      .enter()
      .insert("path")
      .attr("title", function(d) { return d.properties.name; })
      .attr("class", "country")
      .attr("id", function(d){ return d.id; })
      .attr("d", path);
  }

};
