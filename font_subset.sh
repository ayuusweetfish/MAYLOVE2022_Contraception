#!/bin/sh

pyftsubset res/1574853606.ttf \
  --output-file=res/1574853606_subset.ttf \
  --text="0123456789.`cat *.lua | perl -CIO -pe 's/[\p{ASCII} \N{U+2500}-\N{U+257F}]//g'`"
