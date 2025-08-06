#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR/..
docker build -f pkg/app/Dockerfile -t event_pdcr .