#!/bin/bash
echo "http://localhost:8081"
docker run --rm -it \
  -p 8081:8080 \
  fullstorydev/grpcui \
  -plaintext host.docker.internal:50051 > /dev/null
