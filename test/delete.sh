#!/bin/bash

curl -s -X DELETE http://myretail.localhost/products/1 | jq .
