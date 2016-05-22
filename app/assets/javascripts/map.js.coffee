L.Icon.Default.imagePath = '/assets/images'

window.Map =
  init: ->
    latLon = [parseFloat(gon.fault.item.item_latitude), parseFloat(gon.fault.item.item_longitude)]
    map = L.map('map').setView(latLon, 13)

    L.tileLayer( 'http://{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png',
        attribution: '&copy; <a href="http://osm.org/copyright" title="OpenStreetMap" target="_blank">OpenStreetMap</a> contributors | Tiles Courtesy of <a href="http://www.mapquest.com/" title="MapQuest" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png" width="16" height="16">',
        subdomains: ['otile1','otile2','otile3','otile4']
      ).addTo(map)

    L.marker(latLon).addTo(map)
      .bindPopup("Latitude: " + gon.fault.item.item_latitude + "\n\n" + "Longitude: " + gon.fault.item.item_longitude)
      .openPopup()
ready = ->
  Map.init() if $("#map").length

$(document).ready(ready)
$(document).on('page:load', ready)
