#!/usr/bin/env bash

sed 's/\r//g' $1 > "$1_converted"
cat "$1_converted" > $1
rm "$1_converted"

