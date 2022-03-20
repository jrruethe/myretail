#!/bin/bash

curl -s -X POST \
-H 'Content-Type: application/json' \
-d '{"id": 1, "name": "test", "price": 1.5, "currency": "USD"}' \
http://myretail.localhost/products | jq .
