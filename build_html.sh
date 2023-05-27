#!/usr/bin/env bash

for f in markdown/*; do
  name="$(echo "$f" | sed -n "s/markdown\/\(.*\).md/\1/p")"
  markdown < "$f" > "html/$name.html"
done

