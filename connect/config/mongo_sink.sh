curl -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    http://localhost:8083/connectors/ \
    -d '{
    "name":"mongo-sink",
    "config": {
        "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
        "tasks.max":"2",
        "topics":"traffic_flow,traffic_incident",
        "connection.uri":"mongodb://user:user@mongo:27017/?authSource=admin",
        "database":"traffic_db",
        "topic.override.traffic_flow.collection": "traffic_flow",
        "topic.override.traffic_incident.collection": "traffic_incident",
        "key.converter":"io.confluent.connect.avro.AvroConverter",
        "key.converter.schema.registry.url": "http://schema-registry:8081",
        "value.converter":"io.confluent.connect.avro.AvroConverter",
        "value.converter.schema.registry.url": "http://schema-registry:8081",
        "post.processor.chain": "com.mongodb.kafka.connect.sink.processor.BlockListValueProjector",
        "value.projection.type": "BlockList",
        "value.projection.list": "EXTENDED_COUNTRY_CODE,TIMESTAMP,TIMESTAMP2,VERSION",
        "document.id.strategy":"com.mongodb.kafka.connect.sink.processor.id.strategy.BsonOidStrategy",
        "topic.override.traffic_incident.writemodel.strategy": "com.mongodb.kafka.connect.sink.writemodel.strategy.UpdateOneTimestampsStrategy",
        "max.partition.fetch.bytes": "20970000"
        }
    }'