#!/bin/sh

/etc/confluent/docker/run &

sleep 7
echo "Creating topic for traffic flow"
kafka-topics --zookeeper zookeeper --topic traffic_flow --create --replication-factor 1 --partitions 1
sleep 7

echo "Creating topic for traffic incident"
kafka-topics --zookeeper zookeeper --topic traffic_incident --create --replication-factor 1 --partitions 1
sleep 7

echo "Configuring source connector for traffic flow"
./config/traffic_flow_source.sh
sleep 10

echo "Configuring source connector for traffic incident"
./config/traffic_incident_source.sh
sleep 10

echo "Configuring sink connector"
./config/mongo_sink.sh

sleep infinity
