Outflux.updateShare = (event) ->
  if Outflux.currentCountry.alias
    hash_tag = "%23#{Outflux.currentCountry.alias}"
  else
    hash_tag = "%23#{Outflux.currentCountry.name}"
  path = Routes.country_year_path(Outflux.currentCountry, Outflux.currentYear)
  $('.fb').attr('href',"http://www.facebook.com/share.php?u=http://outflux.herokuapp.com#{path}/")
  $('.tw').attr('href',"http://twitter.com/home?status=Outflux%20-Interactive%20map%20of%20international%20Refugee%20flows.%20Data%20via%20@Refugees.%20#{hash_tag}+http://outflux.herokuapp.com#{path}")
