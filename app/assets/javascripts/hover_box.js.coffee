Outflux.addHoverBox = () ->
  $box = $('<div />', {class: 'hover-box', css: {display: 'none'}})
  $name = $('<h4 />', {class: 'hover-name'})
  $stat = $('<p />', {class: 'hover-stat'})

  $box.append($name)
  $box.append($stat)
  $('#map-container').append($box)

Outflux.moveHoverBox = (x, y) ->
  $box = $('.hover-box')
  $box.css({left: "#{x + 20}px", top: "#{y + 20}px"})

Outflux.updateBox = (event) ->
  name = event.properties.name

  $('.hover-box').css({display: 'block'})
  $('.hover-name').text(name)
  $('.hover-stat').text('')

  if this.total
    $('.hover-stat').text("#{Outflux.numberWithCommas(this.total)} refugees")

Outflux.hideBox = (event) ->
  if $(event.target).get(0).tagName != 'path'
    $('.hover-box').css({display: 'none'})
