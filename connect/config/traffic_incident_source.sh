curl -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    http://localhost:8083/connectors/ \
    -d '{
    "name": "traffic_incident_connector",
    "config": {
        "connector.class": "com.tm.kafka.connect.rest.RestSourceConnector",
        "tasks.max": "1",
        "rest.source.poll.interval.ms": "120000",
        "rest.source.method": "GET",
        "rest.source.url": "https://traffic.ls.hereapi.com/traffic/6.2/flow.json?apiKey=${YOUR_API_KEY}&bbox=43.47653,-79.931948;44.048999,-79.010904&responseattributes=sh,fc&maxfunctionalclass=2",
        "rest.source.properties": "Content-Type:application/json,Accept::application/json",
        "rest.source.topic.selector": "com.tm.kafka.connect.rest.selector.SimpleTopicSelector",
        "rest.source.destination.topics": "traffic_incident",
        "max.request.size": "20970000"
        }
    }'