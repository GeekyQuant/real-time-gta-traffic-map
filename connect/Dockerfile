FROM confluentinc/cp-kafka-connect

ENV CONNECT_BOOTSTRAP_SERVERS "kafka:9092"
ENV CONNECT_REST_ADVERTISED_HOST_NAME "connect"
ENV CONNECT_REST_PORT "8083"
ENV CONNECT_GROUP_ID "compose-connect-group"
ENV CONNECT_CONFIG_STORAGE_TOPIC "docker-connect-configs"
ENV CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR "1"
ENV CONNECT_OFFSET_FLUSH_INTERVAL_MS "10000"
ENV CONNECT_OFFSET_STORAGE_TOPIC "docker-connect-offsets"
ENV CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR "1"
ENV CONNECT_STATUS_STORAGE_TOPIC "docker-connect-status"
ENV CONNECT_STATUS_STORAGE_REPLICATION_FACTOR "1"
ENV CONNECT_PRODUCER_MAX_REQUEST_SIZE "20970000"
ENV CONNECT_CONSUMER_MAX_PARTITION_FETCH_BYTES "20970000"
ENV CONNECT_KEY_CONVERTER "io.confluent.connect.avro.AvroConverter"
ENV CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL "http://schema-registry:8081"
ENV CONNECT_VALUE_CONVERTER "io.confluent.connect.avro.AvroConverter"
ENV CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL "http://schema-registry:8081"
ENV CONNECT_INTERNAL_KEY_CONVERTER "org.apache.kafka.connect.json.JsonConverter"
ENV CONNECT_INTERNAL_VALUE_CONVERTER "org.apache.kafka.connect.json.JsonConverter"
ENV CONNECT_PLUGIN_PATH '/jars'

WORKDIR /connect

COPY . /connect

CMD ["./connect_init.sh"]