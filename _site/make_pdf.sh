#!/bin/bash -
## NOTES ##
# https://github.com/ResponSySS/responsyss.github.io/wiki/make_pdf.sh
# TODO: faire une Makefile à la place de ça
set -o nounset -o errexit -o pipefail

SEARCH_PATH="textes/" 
TEMPLATE_PDF="./template.pdf.pandoc"
TEMPLATE_EPUB="./template.epub.pandoc"
TEST_IN="./textes/internationale_situationniste/de_la_misère_en_milieu_étudiant.md"
CMD_PDF=(  ./pdc_gen.sh -i md -o pdf  -j 1 -p 	-a "--template=$TEMPLATE_PDF" )
CMD_EPUB=( ./pdc_gen.sh -i md -o epub -j 2  	-a "--template=$TEMPLATE_EPUB" )

[[ $# -ge 1 ]] && {
	case "$1" in 	
		"help"|"-h"|"--help") 		echo -e "[$0] Usage: $0 [--help] [--test] [SEARCH_PATH]\n  SEARCH_PATH defaults to: \"${SEARCH_PATH}\" (see ${CMD_PDF[0]} --help)\n[$0] Command to be executed:\n  (for PDF)\t ${CMD_PDF[@]} [SEARCH_PATH]\n  (for EPUB)\t ${CMD_EPUB[@]} [SEARCH_PATH]" ; exit ;;
		"--test") 			echo "[$0] Testing templates!"
						pandoc --template="$TEMPLATE_PDF" -t latex <$TEST_IN > /dev/null || { echo "[$0] TEST FAILED FOR PDF TEMPLATE '$TEMPLATE_PDF'"; exit;  }
						pandoc --template="$TEMPLATE_EPUB" -t epub <$TEST_IN > /dev/null || { echo "[$0] TEST FAILED FOR EPUB TEMPLATE '$TEMPLATE_EPUB'"; exit; }
						echo "[$0] All good!"; exit ;;
		*) 				SEARCH_PATH="$1" ;;
	esac
}

# Don't exit on error
${CMD_PDF[@]} 	${SEARCH_PATH} || :
${CMD_EPUB[@]} 	${SEARCH_PATH} || :
