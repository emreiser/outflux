Outflux.updateShare = (event) ->
  if Outflux.currentCountry.alias
    hash_tag = "%23#{Outflux.currentCountry.alias}"
  else
    hash_tag = "%23#{Outflux.currentCountry.name.split(' ').join('')}"
  path = Routes.country_year_path(Outflux.currentCountry, Outflux.currentYear)
  $('.fb').attr('href',"http://www.facebook.com/share.php?u=http://outflux.herokuapp.com#{path}/")
  $('.tw').attr('href',"http://twitter.com/home?status=Outflux%20-Interactive%20map%20of%20international%20Refugee%20flows%20from%20#{hash_tag}.%20Data%20via%20@Refugees+http://outflux.herokuapp.com#{path}")

