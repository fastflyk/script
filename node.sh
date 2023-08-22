#!/usr/bin/env bash

curl -o ~/node.py -L https://raw.githubusercontent.com/fastflyk/script/main/node.py &&
cd ~ &&
python3 -c 'from node import init; init()' &&
python3 -c 'from node import yh; yh()' &&
python3 node.py $0 $1 $2 $3
