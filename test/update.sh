#!/bin/bash

curl -s -X PUT \
-H 'Content-Type: application/json' \
-d '{"price": 3.14}' \
http://myretail.localhost/products/1 | jq .
