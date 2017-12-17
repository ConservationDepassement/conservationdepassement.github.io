#!/bin/bash -
## NOTES ##
# https://github.com/ResponSySS/responsyss.github.io/wiki/make_pdf.sh

./pdc_gen.sh textes/ -i md -o pdf:epub -a '--template=./template.pdf.pandoc' -j 1 -p

