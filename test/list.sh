#!/bin/bash

curl -s -X GET http://myretail.localhost/products | jq .
