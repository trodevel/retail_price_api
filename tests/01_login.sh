#!/bin/bash

IS_SSL=$1

PREFIX=""
HOST="http://localhost:3000"

[[ -n $IS_SSL ]] && { PREFIX=" -k "; HOST="https://localhost:443"; }

curl -XPOST $PREFIX $HOST/v1/login -d 'email=test@test.com&password=test' | jq '.'
