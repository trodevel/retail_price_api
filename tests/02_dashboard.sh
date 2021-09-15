#!/bin/bash

IS_SSL=$1

PREFIX=""
HOST="http://localhost:3000"

[[ -n $IS_SSL ]] && { PREFIX=" -k "; HOST="https://localhost:443"; }

curl -XGET $PREFIX $HOST/v1/dashboard -d 'api_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfa2V5IjoiMWEyYjNjNGQ1ZTZmN2E4YjljIiwiaWQiOjF9.LWjXWE0yptTp7xGwxS0YMAMUWfRXzSlpslDIaskaFBE' | jq '.'
