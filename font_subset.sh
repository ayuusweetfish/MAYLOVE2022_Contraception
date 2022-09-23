#!/bin/sh

pyftsubset res/ZCOOL_Kuaile.ttf \
  --output-file=res/ZCOOL_Kuaile_subset.ttf \
  --text="0123456789.`cat *.lua | perl -CIO -pe 's/[\p{ASCII} \N{U+2500}-\N{U+257F}]//g'`"
