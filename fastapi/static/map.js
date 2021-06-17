var map = new L.map('map').setView([43.747172091712066, -79.46050067203855],11);

var ws = new WebSocket("ws://localhost:8080/ws");

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


var circleLayerGroup = new L.layerGroup()
var markerLayerGroup = new L.layerGroup()


ws.onmessage = async function(event) {
    var message = JSON.parse(event.data);
    if (message.TOPIC === "traffic_flow") {
        circleLayerGroup.clearLayers()
        console.log("Clearing the map now")
        await sleep(3000);
        var rw_segs = message.RWS[0].RW
        var rw_seg, fis, fi, cf, shps, su, ff, cn, lat_long, lat, long, shp;
        for (rw_seg of rw_segs) {
            fis = rw_seg.FIS[0].FI
            for (fi of fis) {
                cf = fi.CF[0]
                shps = fi.SHP
                if ('SU' in cf) {
                    su = cf.SU;
                }
                if ('FF' in cf) {
                    ff = cf.FF;
                }
                if ('CN' in cf) {
                    cn = cf.CN;
                }

                if (cn >= 0.7) {
                    for (shp of shps) {
                        lat_long = shp.value[0].trim().replace(/,/g, ' ').split(" ");
                        for (let i = 0; i < lat_long.length / 2; i++) {
                            lat = lat_long[2 * i]
                            long = lat_long[2 * i + 1]
                            if (su / ff < 0.25) {
                                L.circleMarker([lat, long], {'color': 'brown'}).addTo(circleLayerGroup);
                            } else if (su / ff < 0.5) {
                                L.circleMarker([lat, long], {'color': 'red'}).addTo(circleLayerGroup);
                            } else if (su / ff < 0.75) {
                                L.circleMarker([lat, long], {'color': 'yellow'}).addTo(circleLayerGroup);
                            } else {
                                L.circleMarker([lat, long], {'color': 'green'}).addTo(circleLayerGroup);
                            }

                        }
                    }
                }
            }

        }
        console.log("Adding to map")
        circleLayerGroup.addTo(map)
        console.log("Added to map")
    }
    else {
        try {
            var tis_f = message.TRAFFIC_ITEMS.TRAFFIC_ITEM
            markerLayerGroup.clearLayers()
            console.log("Clearing incident markers")
            for (var ti of tis_f) {
                lat = ti.LOCATION.GEOLOC.ORIGIN.LATITUDE
                long = ti.LOCATION.GEOLOC.ORIGIN.LONGITUDE
                short_desc = ti.TRAFFIC_ITEM_DESCRIPTION[0].value;
                // var popup = L.popup().setLatLng([lat, long]).setContent(short_desc).openOn(map);
                L.marker([lat, long]).addTo(markerLayerGroup).bindPopup(short_desc);

            }
            markerLayerGroup.addTo(map)
        }
        catch {
            console.log("There are no accidents at the moment")
            console.log(event.data)
        }
    }
}


window.addEventListener("unload", function(event) {
    ws.close()
}, false);