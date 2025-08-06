#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR
mkdir -p ../src/pb
rm -rf ../src/pb/*

find ../resources/proto -name "*.proto" | xargs protoc \
    --proto_path=../resources/proto \
    --go_out=../src/pb \
    --go_opt=paths=source_relative \
    --go-grpc_out=../src/pb \
    --go-grpc_opt=paths=source_relative
