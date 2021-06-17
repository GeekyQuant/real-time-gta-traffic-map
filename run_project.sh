#!/bin/sh

argument=$1

if [ $argument = "up" ]
then
    echo "Changing permissions for the shell files"
    chmod +x ./connect/connect_init.sh
    for file in ./connect/config/*; do
      chmod +x $file
    done
    echo "Setting up the dev environment"
    COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build
    echo "Bringing up mongodb"
    docker-compose up -d mongo
    sleep 2
    echo "Setting up database credentials"
    docker exec -it mongo /usr/local/bin/mongo_init.sh
    sleep 2
    echo "Setting up background infrastructure"
    docker-compose up -d zookeeper kafka schema-registry connect
    sleep 5
    echo "Setting up fastapi for development"
    docker-compose up fastapi
elif [ $argument = "stop" ]
then
    echo "Stopping the environment"
    docker-compose stop
elif [ $argument = "down" ]
then
    echo "Removing the environment"
    docker-compose down
else
    echo "Unexpected argument! Please choose from dev, up, stop, down"
    echo "dev allows for faster-rebuild and keep the screen to fastapi at the end"
    echo "up runs everything in detached mode... stop for pausing and down for removal"
fi


