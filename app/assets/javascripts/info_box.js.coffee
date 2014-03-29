$(document).ready ->
  $('.toggle-stories').click(Outflux.toggleStories)
  Outflux.story = false


Outflux.numberWithCommas = (int) ->
  int.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

Outflux.populateInfo = () ->
  if Outflux.currentCountry.code == "211"
    $('.origin-name').text("#{Outflux.currentCountry.alias}")
  else
    $('.origin-name').text("#{Outflux.currentCountry.name}")

  year = $('#year-slider').val()
  $('.year-output').text(year)

  if Outflux.totalRefugees
    $('.total-refugees').text(Outflux.numberWithCommas(Outflux.totalRefugees))

Outflux.fillRefugeeViz = (count) ->
  box = $('#refugee-box')
  bar = $('<div>', {class: 'refugee-viz'})
  increment = 100000

  times = Math.floor(count / increment)
  remainder = count % increment

  box.empty()

  if times > 0
    for n in [1..times]
      box.append(bar.clone())

  if remainder
    bar = bar.clone()
    partial = $('<div>', {css: {margin: 0, height: '100%', background: 'white'}})
    percent = (100 - Math.floor(remainder/increment * 100)) + '%'
    partial.css('width': "#{percent}")
    bar.append(partial)
    box.append(bar)

Outflux.getStories = (country_code) ->
  $.ajax(
    url: '/stories'
    type: 'GET'
    dataType: 'json'
    data:
      code: country_code
  )
  .done((data) ->
    console.log(data)
    Outflux.stories = data.stories
    Outflux.renderStories(Outflux.stories)
  )

Outflux.renderStories = (stories) ->
  $('#stories').empty()
  if Outflux.currentCountry.emergency
    for story in stories
      $('#stories').append(HandlebarsTemplates['story'](story))
  else
    $('#stories').append(HandlebarsTemplates['country_page'](Outflux.currentCountry))

Outflux.toggleStories = (event) ->
  if Outflux.story
    $('.toggle-stories').text('In the news')
    $('#stories').fadeOut(500, () -> $('#stats').fadeIn())
    Outflux.story = false

  else
    $('.toggle-stories').text('See stats')
    $('#stats').fadeOut(500, () -> $('#stories').fadeIn())
    Outflux.story = true

Outflux.loadStats = () ->
  Outflux.story = true
  Outflux.toggleStories()
