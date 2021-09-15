#!/bin/bash

sudo perl api_server.pl daemon -l 'https://*:443?cert=./server.crt&key=./server.key'
