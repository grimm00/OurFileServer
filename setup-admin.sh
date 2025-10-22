#!/bin/bash

# Stop the container
docker compose down

# Create a temporary container to set up the database
docker run --rm -v "$(pwd)/config:/config" -v "/mnt/s/fileserver:/srv" filebrowser/filebrowser:latest sh -c "
  filebrowser config init -d /config/database.db &&
  filebrowser users add admin admin --perm.admin -d /config/database.db
"

# Start the container with the config volume
docker compose up -d
