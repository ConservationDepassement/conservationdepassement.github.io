#!/bin/bash -
## NOTES ##
# https://github.com/ResponSySS/responsyss.github.io/wiki/make_pdf.sh
SEARCH_PATH="textes/" 
CMD_PDF=(./pdc_gen.sh -i md -o pdf -j 1 -p -a '--template=./template.pdf.pandoc')
CMD_EPUB=(./pdc_gen.sh -i md -o epub -j 2) # add EPUB template arg

case "$1" in 	"help"|"usage"|"-h"|"--help")
			{ echo -e "[$0] Usage: $0 [SEARCH_PATH]\n  SEARCH_PATH defaults to: \"${SEARCH_PATH}\" (see ${CMD_PDF[0]} --help)\n[$0] Command to be executed:\n  (for PDF)\t ${CMD_PDF[@]} [SEARCH_PATH]\n  (for EPUB)\t ${CMD_EPUB[@]} [SEARCH_PATH]"; exit; } ;;
		*)
			SEARCH_PATH="$1" ;;
esac

${CMD_PDF[@]} 	${SEARCH_PATH}
${CMD_EPUB[@]} 	${SEARCH_PATH}
