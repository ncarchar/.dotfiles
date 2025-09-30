#!/usr/bin/env bash

echo "Pruning containers..."
docker container prune -f
docker ps -a

echo "Pruning images..."
docker image prune -f
docker images -a
