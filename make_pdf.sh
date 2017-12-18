#!/bin/bash -
## NOTES ##
# https://github.com/ResponSySS/responsyss.github.io/wiki/make_pdf.sh
SEARCH_PATH="textes/" 
CMD=(./pdc_gen.sh -i md -o pdf:epub -a '--template=./template.pdf.pandoc' -j 1 -p)

case "$1" in 	"help"|"usage"|"-h"|"--help")
			{ echo -e "[$0] Usage: $0 [SEARCH_PATH]\t(SEARCH_PATH defaults to: \"${SEARCH_PATH}\"; see ${CMD[0]} --help)\n[$0] Command to be executed: ${CMD[@]} [SEARCH_PATH]"; exit; }
			;;
		*)
			SEARCH_PATH="$1"
			;;
esac

${CMD[@]} ${SEARCH_PATH}
