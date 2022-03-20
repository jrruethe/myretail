#!/bin/bash

echo "Performing tests against the API"

echo "Deleting any existing items"
./delete.sh

echo "Listing items (should be empty)"
./list.sh

echo "Creating an item"
./create.sh

echo "Listing items (should have 1)"
./list.sh

echo "Reading the item"
./read.sh

echo "Updating the item (price change)"
./update.sh

echo "Reading the item"
./read.sh

echo "Deleting the item"
./delete.sh

echo "Listing items (should be empty)"
./list.sh
