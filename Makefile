## NOTES ##
# Voir : https://github.com/ResponSySS/responsyss.github.io/wiki/Générer-les-PDFs
# TODO: arranger la partie 'test'
# TODO: how to handle/trap errors?
# TODO: faire une target pour 'ln -s sous_doss/* .' les images d'un texte?

SHELL = /bin/bash
# Path to script
GEN_SCRIPT = ./pdc_gen/pdc_gen.sh
# Root dir for searching files
ROOT = ./textes/
# Templates
TEMPLATE_PDF =  ./pdc_gen/template.pdf.pandoc
TEMPLATE_EPUB = ./pdc_gen/template.epub.pandoc
# File for testing
TEST_IN = ./textes/internationale_situationniste/de_la_misère_en_milieu_étudiant.md

help usage:
	@echo "Targets:"
	@echo "    test   - Test generation with $(TEMPLATE_PDF) and $(TEMPLATE_EPUB)"
	@echo "    all    - Build all targets marked with [*]"
	@echo " *  pdf    - Build all PDFs"
	@echo " *  epub   - Build all EPUBs"
	@echo
	@echo "$(MAKE) ROOT=/path/to/dir/ [TARGET(S)]"
	@echo "    Set root dir for searching files to '/path/to/dir/' (defaults to '$(ROOT)')"
	@echo
	@echo "Examples:"
	@echo "    $(MAKE) ROOT=./textes/guy_debord/ pdf"
	@echo "        Recursively build PDF files from MD files in ./textes/guy_debord/**"
	@echo
	@echo "For further info, see '$(GEN_SCRIPT) --help'"

all: pdf epub

test: $(TEMPLATE_PDF) $(TEMPLATE_EPUB) $(TEST_IN)
	pandoc --template="$(TEMPLATE_PDF)" -t latex <$(TEST_IN) > /dev/null || { echo ":: TEST FAILED FOR PDF TEMPLATE '$(TEMPLATE_PDF)'"   ; } && { echo ":: SUCCESS!" ; }
	pandoc --template="$(TEMPLATE_EPUB)" -t epub <$(TEST_IN) > /dev/null || { echo ":: TEST FAILED FOR EPUB TEMPLATE '$(TEMPLATE_EPUB)'" ; } && { echo ":: SUCCESS!" ; }

pdf: $(GEN_SCRIPT) $(TEMPLATE_PDF)
	$(GEN_SCRIPT) -i md -o pdf  -j 1 -p -a "--template=$(TEMPLATE_PDF)" $(ROOT)

epub: $(GEN_SCRIPT) $(TEMPLATE_EPUB)
	$(GEN_SCRIPT) -i md -o epub -j 2    -a "--template=$(TEMPLATE_EPUB)" $(ROOT)
