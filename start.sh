#!/bin/bash

# Build the Docker images
docker-compose build

# Start the services
docker-compose up -d

# Display the logs
docker-compose logs -f