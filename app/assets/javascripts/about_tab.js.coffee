$(document).ready ->
  Outflux.tab = false
  $('#about-tab').click(Outflux.slideTab)

Outflux.slideTab = (event) ->
  arrow = $('#about-tab span')
  if Outflux.tab
    Outflux.tab = false
    $('.tab').animate({left: "-=400"}, 1000)
    arrow.removeClass('glyphicon glyphicon-chevron-left').addClass('glyphicon glyphicon-chevron-right')
  else
    Outflux.tab = true
    $('.tab').animate({left: "+=400"}, 1000)
    arrow.removeClass('glyphicon glyphicon-chevron-right').addClass('glyphicon glyphicon-chevron-left')
